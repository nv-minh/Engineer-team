---
name: spring-boot
description: >
  Spring Boot application development — auto-configuration, dependency injection,
  REST APIs, JPA data access, Spring Security, testing, Actuator monitoring, and
  deployment. Use when building Java backend services with Spring Boot.
version: "3.0.0"
category: "expert-spring"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "spring boot"
  - "spring-boot"
  - "spring boot api"
  - "spring jpa"
  - "spring security"
  - "spring actuator"
intent: >
  Guide Spring Boot backend development from project creation to deployment. Covers
  auto-configuration, DI patterns, REST API design, JPA data access, security
  configuration, testing strategies, and production monitoring.
scenarios:
  - "Creating REST APIs with Spring Boot controllers"
  - "Implementing JPA repositories with Hibernate"
  - "Configuring Spring Security with JWT or OAuth2"
  - "Setting up health checks and monitoring with Actuator"
  - "Writing unit and integration tests with MockMvc"
  - "Deploying Spring Boot as containerized services"
best_for: "Java backend services, REST APIs, enterprise applications, microservices"
estimated_time: "15-60 min"
anti_patterns:
  - "Field injection with @Autowired — use constructor injection"
  - "Business logic in controllers — keep them thin, delegate to services"
  - "Using application.properties over application.yml for complex configs"
  - "Ignoring @Transactional on service methods that modify data"
  - "Not configuring Actuator endpoints for production monitoring"
related_skills: ["backend-patterns", "api-interface-design"]

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

# Spring Boot

[ROLE]
Act as a Spring Boot expert. Deliver production-grade Java backend services using constructor injection, thin controllers, JPA repositories, and Actuator monitoring.

[OBJECTIVE]
Build Spring Boot services with proper layering (controller -> service -> repository), constructor injection, transactional boundaries, and production-ready security and monitoring.

[RULES]
1. <thought>Before writing any Spring component, determine: Is this a controller (HTTP), service (business logic), or repository (data access)? Use constructor injection for all dependencies.</thought>
2. Use constructor injection exclusively — never `@Autowired` on fields.
3. Keep controllers thin — validate input, call service, return DTO. No business logic.
4. Apply `@Transactional` on all service methods that modify data.
5. Set `spring.jpa.open-in-view=false` to avoid lazy loading outside transactions.
6. Use `ddl-auto=validate` in production — never update/create.
7. Return DTOs from controllers, not entities.
8. DO NOT use field injection with @Autowired — use constructor injection.
9. DO NOT place business logic in controllers.
10. DO NOT ignore Actuator endpoint configuration for production.
11. Use Flyway/Liquibase for schema changes in production, not ddl-auto.
12. Use Testcontainers for integration tests with real databases instead of H2.
13. ABC: The thin controller pattern means controller validates input, calls service, returns DTO. All business logic belongs in @Service classes.

[PROCESS]

### Project Setup

```bash
spring init --dependencies=web,data-jpa,postgresql,security,actuator my-project
```

```
src/main/java/com/example/
  ├── controller/    # REST controllers
  ├── service/       # Business logic
  ├── repository/    # Data access (JPA)
  ├── entity/        # JPA entities
  ├── dto/           # Data transfer objects
  ├── config/        # Configuration classes
  └── exception/     # Custom exceptions + handler
```

### Auto-Configuration

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/mydb
    username: postgres
    password: ${DB_PASSWORD}
  jpa:
    hibernate:
      ddl-auto: validate
    open-in-view: false
```

### Dependency Injection

```java
@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;

    @Transactional
    public User save(User user) {
        return userRepository.save(user);
    }
}
```

### REST API

```java
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public UserResponse create(@Valid @RequestBody CreateUserRequest req) {
        return UserResponse.from(userService.create(req));
    }
}
```

### JPA Data Access

```java
@Entity
@Table(name = "users")
public class User {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(nullable = false) private String name;
    @Column(unique = true, nullable = false) private String email;
}

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
}
```

### Security Configuration

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http.authorizeHttpRequests(auth -> auth
            .requestMatchers("/api/public/**").permitAll()
            .requestMatchers("/actuator/health").permitAll()
            .anyRequest().authenticated())
            .oauth2ResourceServer(oauth2 -> oauth2.jwt(Customizer.withDefaults()));
        return http.build();
    }
}
```

### Testing

```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureMockMvc
class UserControllerTest {
    @Autowired private MockMvc mockMvc;

    @Test
    void getUserReturns200() throws Exception {
        mockMvc.perform(get("/api/users/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.name").exists());
    }
}
```

### Actuator

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
```

### Verification

- [ ] All dependencies use constructor injection (no `@Autowired` on fields)
- [ ] Controllers are thin — business logic in `@Service` classes
- [ ] `@Transactional` on all service methods that modify data
- [ ] Security configuration explicitly defines public and protected endpoints
- [ ] Actuator endpoints configured and secured for production

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation` with code and explanation, `patterns_applied` listing Spring Boot patterns used, and `recommendations` for improvements.
