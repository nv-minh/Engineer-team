---
name: nestjs
description: >
  NestJS patterns covering controllers, providers, modules, middleware, guards,
  pipes, interceptors, dependency injection, GraphQL, WebSockets, microservices,
  and testing. Use when building scalable server-side Node.js applications.
version: "3.0.0"
category: "expert-nest"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "nestjs"
  - "nest.js"
  - "nest controller"
  - "nest module"
  - "nest guard"
  - "nest middleware"
  - "nest microservice"
intent: >
  Build structured, scalable server-side applications with NestJS using
  its module architecture, dependency injection, and cross-cutting concerns.
scenarios:
  - "Building a REST API with controllers, DTOs, validation pipes, and Swagger docs"
  - "Implementing JWT auth with guards, protected routes, and role-based access"
  - "Setting up a microservice with Redis transport and event-driven communication"
best_for: "NestJS backend, controllers, DI, guards, pipes, microservices"
estimated_time: "30-60 min"
anti_patterns:
  - "Placing business logic in controllers instead of service providers"
  - "Skipping DTO validation on API endpoints"
  - "Using modules as namespaces instead of organizing by feature/domain"
related_skills: ["backend-patterns", "api-interface-design", "typescript-patterns", "security-hardening"]

input_schema:
  type: object
  required: [task_description]
  properties:
    task_description:
      type: string
      description: "What to implement, review, or investigate"
    context:
      type: object
      description: "Project context — existing code, tech stack, constraints"
    mode:
      type: string
      enum: [implement, review, investigate, advise]
      default: implement
      description: "Execution mode"

output_schema:
  type: object
  required: [status, implementation]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    implementation:
      type: object
      description: "Implementation details, code, or analysis results"
    patterns_applied:
      type: array
      items: { type: string }
      description: "Patterns and best practices used"
    recommendations:
      type: array
      items:
        type: object
        properties:
          priority: { type: string, enum: [high, medium, low] }
          action: { type: string }
          reasoning: { type: string }

error_schema:
  type: object
  required: [error_type, message]
  properties:
    error_type: { type: string, enum: [missing_input, ambiguous_scope, blocked, tool_failure, validation_error] }
    message: { type: string }
    attempted_action: { type: string }
    suggestion: { type: string }
    retry_possible: { type: boolean }
---

# NestJS

[ROLE]
Act as a NestJS expert. Deliver structured, scalable server-side applications using NestJS module architecture, dependency injection, and the request lifecycle pipeline.

[OBJECTIVE]
Build NestJS backends where controllers are thin, business logic lives in injectable services, and cross-cutting concerns (auth, validation, logging) use the correct pipeline component (guards, pipes, interceptors).

[RULES]
1. <thought>Before placing any logic, ask: Does this belong in a guard (auth), pipe (validation), interceptor (transform/log), service (business logic), or controller (HTTP concerns)?</thought>
2. Keep controllers thin — delegate business logic to service providers.
3. Organize modules by feature/domain — not by technical type.
4. Validate all inputs with DTOs + ValidationPipe — never trust client data.
5. Use guards for authorization — protect routes declaratively, not imperatively.
6. Leverage interceptors for cross-cutting concerns — logging, caching, response transforms.
7. DO NOT place business logic in controllers — delegate to services.
8. DO NOT skip DTO validation on API endpoints.
9. DO NOT use modules as namespaces — organize by feature/domain.
10. Use ConfigService for environment variables, never `process.env` directly.
11. Write unit tests for services, e2e tests for API endpoints.
12. ABC: The NestJS pipeline is the key mental model — understanding Middleware -> Guard -> Pipe -> Controller -> Interceptor tells you exactly where to put each concern.

[PROCESS]

### Request Lifecycle

Middleware -> Guard -> Interceptor (before) -> Pipe -> Controller -> Service -> Interceptor (after) -> Exception Filter

### Controller

```typescript
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() dto: CreateUserDto): Promise<UserResponse> {
    return this.usersService.create(dto);
  }

  @Get(':id')
  async findOne(@Param('id', ParseUUIDPipe) id: string): Promise<UserResponse> {
    return this.usersService.findOne(id);
  }
}
```

### Provider (Business Logic)

```typescript
@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User) private readonly userRepo: Repository<User>,
    private readonly eventsService: EventsService,
  ) {}

  async create(dto: CreateUserDto): Promise<User> {
    const hashedPassword = await bcrypt.hash(dto.password, 10);
    const user = this.userRepo.create({ ...dto, password: hashedPassword });
    const saved = await this.userRepo.save(user);
    this.eventsService.emit('user.created', saved);
    return saved;
  }
}
```

### Module

```typescript
@Module({
  imports: [TypeOrmModule.forFeature([User]), forwardRef(() => AuthModule)],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
```

### Guard (Authorization)

```typescript
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}
  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.get<string[]>('roles', context.getHandler());
    if (!requiredRoles) return true;
    const { user } = context.switchToHttp().getRequest();
    return requiredRoles.includes(user.role);
  }
}
```

### Pipe (Validation)

```typescript
export class CreateUserDto {
  @IsEmail() email: string;
  @IsString() @MinLength(8) password: string;
  @IsString() @IsNotEmpty() name: string;
}

// Global validation pipe (main.ts)
app.useGlobalPipes(new ValidationPipe({
  whitelist: true, forbidNonWhitelisted: true, transform: true,
}));
```

### Interceptor

```typescript
@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const now = Date.now();
    return next.handle().pipe(tap(() => console.log(`Completed in ${Date.now() - now}ms`)));
  }
}
```

### Microservice

```typescript
@Controller()
export class AppController {
  @MessagePattern({ cmd: 'get_user' })
  async getUser(@Payload() id: string): Promise<User> {
    return this.usersService.findOne(id);
  }
  @EventPattern('user_created')
  async handleUserCreated(@Payload() data: UserCreatedEvent) { /* Handle event */ }
}
```

### Testing

```typescript
describe('UsersService', () => {
  let service: UsersService;
  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [UsersService, { provide: getRepositoryToken(User), useValue: mockRepo }],
    }).compile();
    service = module.get(UsersService);
  });
  it('should find a user by id', async () => {
    jest.spyOn(repo, 'findOne').mockResolvedValue(mockUser);
    expect(await service.findOne('1')).toEqual(mockUser);
  });
});
```

### Verification

- [ ] Controllers delegate to services (no business logic in controllers)
- [ ] Modules organized by feature/domain
- [ ] All inputs validated with DTOs and class-validator
- [ ] Auth implemented with guards (not inline checks)
- [ ] Cross-cutting concerns use interceptors or filters
- [ ] Environment config via ConfigService
- [ ] Unit tests for services, e2e tests for endpoints

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation` with code and explanation, `patterns_applied` listing NestJS patterns used, and `recommendations` for improvements.
