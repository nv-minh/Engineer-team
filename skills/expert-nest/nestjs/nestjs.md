---
name: nestjs
description: >
  NestJS patterns covering controllers, providers, modules, middleware, guards,
  pipes, interceptors, dependency injection, GraphQL, WebSockets, microservices,
  and testing. Use when building scalable server-side Node.js applications.
version: "1.0.0"
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
---

# NestJS

## Overview

NestJS is a progressive Node.js framework for building scalable server-side applications. It uses TypeScript, dependency injection, and a modular architecture inspired by Angular. This skill covers the core building blocks: controllers, providers, modules, and the cross-cutting concern pipeline (middleware, guards, pipes, interceptors).

## When to Use

- Building REST APIs, GraphQL services, or microservices with Node.js
- Implementing structured backend architectures with DI and modular design
- Adding validation, authorization, logging, or caching as cross-cutting concerns
- Integrating WebSocket gateways or message-queue-based microservices

## When NOT to Use

- For simple Express/Fastify apps -- use those directly for lightweight APIs
- For serverless functions -- consider a lighter framework unless you need NestJS structure
- For frontend applications -- see `react`, `vue3`, or `nextjs` skills

## Core Architecture

### Controller (Route Handling)

```typescript
@Controller('users')
@ApiTags('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() dto: CreateUserDto): Promise<UserResponse> {
    return this.usersService.create(dto);
  }

  @Get()
  async findAll(@Query() query: PaginationQuery): Promise<PaginatedResponse<UserResponse>> {
    return this.usersService.findAll(query);
  }

  @Get(':id')
  async findOne(@Param('id', ParseUUIDPipe) id: string): Promise<UserResponse> {
    return this.usersService.findOne(id);
  }

  @Patch(':id')
  async update(@Param('id', ParseUUIDPipe) id: string, @Body() dto: UpdateUserDto) {
    return this.usersService.update(id, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Param('id', ParseUUIDPipe) id: string): Promise<void> {
    await this.usersService.remove(id);
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

  async findOne(id: string): Promise<User> {
    const user = await this.userRepo.findOne({ where: { id } });
    if (!user) throw new NotFoundException(`User ${id} not found`);
    return user;
  }
}
```

### Module (Feature Grouping)

```typescript
@Module({
  imports: [
    TypeOrmModule.forFeature([User]),
    forwardRef(() => AuthModule),
  ],
  controllers: [UsersController],
  providers: [UsersService, UsersRepository],
  exports: [UsersService],
})
export class UsersModule {}
```

### Root Module

```typescript
@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        url: config.get('DATABASE_URL'),
        autoLoadEntities: true,
        synchronize: config.get('NODE_ENV') !== 'production',
      }),
    }),
    UsersModule,
    AuthModule,
  ],
})
export class AppModule {}
```

## Cross-Cutting Concerns Pipeline

Request lifecycle: **Middleware -> Guard -> Interceptor (before) -> Pipe -> Controller -> Service -> Interceptor (after) -> Exception Filter**

### Guard (Authorization)

```typescript
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  canActivate(context: ExecutionContext): boolean | Promise<boolean> | Observable<boolean> {
    return super.canActivate(context);
  }
}

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

// Usage: @UseGuards(JwtAuthGuard, RolesGuard) @Roles('admin')
```

### Pipe (Validation and Transformation)

```typescript
// DTO with class-validator
export class CreateUserDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(8)
  password: string;

  @IsString()
  @IsNotEmpty()
  name: string;
}

// Global validation pipe (main.ts)
app.useGlobalPipes(new ValidationPipe({
  whitelist: true,        // Strip unknown properties
  forbidNonWhitelisted: true,
  transform: true,        // Transform to DTO class instances
}));
```

### Interceptor (Logging, Transform, Cache)

```typescript
@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const now = Date.now();
    const request = context.switchToHttp().getRequest();
    console.log(`${request.method} ${request.url}`);
    return next.handle().pipe(
      tap(() => console.log(`Completed in ${Date.now() - now}ms`)),
    );
  }
}

// Response transformation
@Injectable()
export class TransformInterceptor<T> implements NestInterceptor<T, Response<T>> {
  intercept(context: ExecutionContext, next: CallHandler): Observable<Response<T>> {
    return next.handle().pipe(map(data => ({ success: true, data })));
  }
}
```

### Exception Filter

```typescript
@Catch(HttpException)
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: HttpException, host: ArgumentHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse();
    const status = exception.getStatus();
    response.status(status).json({
      statusCode: status,
      message: exception.message,
      timestamp: new Date().toISOString(),
    });
  }
}
```

## Advanced Patterns

### Custom Decorators

```typescript
export const CurrentUser = createParamDecorator(
  (data: string, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    return data ? request.user?.[data] : request.user;
  },
);

// Usage: @CurrentUser() user: JwtPayload
```

### Dynamic Module (Configuration)

```typescript
@Module({})
export class DatabaseModule {
  static register(options: DatabaseOptions): DynamicModule {
    return {
      module: DatabaseModule,
      providers: [
        { provide: 'DATABASE_OPTIONS', useValue: options },
        DatabaseService,
      ],
      exports: [DatabaseService],
    };
  }
}
```

### Microservice

```typescript
// Main: const app = await NestFactory.createMicroservice(AppModule, {
//   transport: Transport.Redis, options: { url: 'redis://localhost:6379' }
// });

@Controller()
export class AppController {
  @MessagePattern({ cmd: 'get_user' })
  async getUser(@Payload() id: string): Promise<User> {
    return this.usersService.findOne(id);
  }

  @EventPattern('user_created')
  async handleUserCreated(@Payload() data: UserCreatedEvent) {
    // Handle event
  }
}
```

### GraphQL (Code-First)

```typescript
@Resolver(() => User)
export class UsersResolver {
  constructor(private readonly usersService: UsersService) {}

  @Query(() => [User])
  async users(): Promise<User[]> {
    return this.usersService.findAll();
  }

  @Mutation(() => User)
  async createUser(@Args('input') input: CreateUserInput): Promise<User> {
    return this.usersService.create(input);
  }
}
```

## Testing

```typescript
describe('UsersService', () => {
  let service: UsersService;
  let repo: Repository<User>;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        UsersService,
        { provide: getRepositoryToken(User), useValue: mockRepo },
      ],
    }).compile();

    service = module.get(UsersService);
    repo = module.get(getRepositoryToken(User));
  });

  it('should find a user by id', async () => {
    jest.spyOn(repo, 'findOne').mockResolvedValue(mockUser);
    expect(await service.findOne('1')).toEqual(mockUser);
  });
});
```

## Best Practices

1. **Keep controllers thin** -- delegate business logic to service providers
2. **Organize modules by feature/domain** -- not by technical type (all controllers together)
3. **Validate all inputs with DTOs + ValidationPipe** -- never trust client data
4. **Use guards for authorization** -- protect routes declaratively, not imperatively
5. **Leverage interceptors for cross-cutting concerns** -- logging, caching, response transforms
6. **Use custom decorators** for clean, reusable parameter extraction
7. **Write unit tests for services, e2e tests for API endpoints**
8. **Use ConfigService** for environment variables, never `process.env` directly

## Coaching Notes

- **The NestJS pipeline is the key mental model** -- understanding the request lifecycle (Middleware -> Guard -> Pipe -> Controller -> Interceptor) tells you exactly where to put each concern. Authorization in guards, validation in pipes, logging in interceptors.
- **Modules are feature boundaries, not folders** -- a UsersModule should contain its controller, service, DTOs, and entities. Cross-module communication happens through exported services.
- **DI is not magic, it is architecture** -- constructor injection makes dependencies explicit and testable. Every provider should declare its dependencies, making the dependency graph visible and mockable.

## Verification

- [ ] Controllers delegate to services (no business logic in controllers)
- [ ] Modules organized by feature/domain
- [ ] All inputs validated with DTOs and class-validator
- [ ] Auth implemented with guards (not inline checks)
- [ ] Cross-cutting concerns use interceptors or filters
- [ ] Environment config via ConfigService
- [ ] Unit tests for services, e2e tests for endpoints

## Related Skills

- **backend-patterns** -- General backend patterns (API design, databases)
- **api-interface-design** -- Contract-first API design
- **typescript-patterns** -- TypeScript patterns for NestJS
- **security-hardening** -- Security patterns for Node.js backends
