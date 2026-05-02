---
name: spring-boot
description: >
  Spring Boot application development — auto-configuration, dependency injection,
  REST APIs, JPA data access, Spring Security, testing, Actuator monitoring, and
  deployment. Use when building Java backend services with Spring Boot.
version: "1.0.0"
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
---

# Spring Boot

## Overview

Spring Boot backend development for Java applications. Provides auto-configuration, embedded servers, and production-ready features. Standard stack: Spring Web for REST APIs, Spring Data JPA for persistence, Spring Security for auth, and Actuator for monitoring.

## When to Use

- Building REST APIs and microservices in Java
- Enterprise applications needing DI, AOP, and transaction management
- Apps requiring rapid setup with auto-configuration
- Production services needing health checks and metrics

## When NOT to Use

- Lightweight serverless functions (consider plain Java or Kotlin functions)
- Real-time applications (consider Vert.x or WebFlux for reactive)
- Non-Java projects (use Python/Go/Rust patterns skills instead)

## Process

### 1. Project Setup

Create via Spring Initializr (https://start.spring.io) or CLI:

```bash
spring init --dependencies=web,data-jpa,postgresql,security,actuator my-project
```

**Project structure:**

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

### 2. Auto-Configuration

```yaml
# application.yml
spring:
  application:
    name: my-app
  datasource:
    url: jdbc:postgresql://localhost:5432/mydb
    username: postgres
    password: ${DB_PASSWORD}
  jpa:
    hibernate:
      ddl-auto: validate
    open-in-view: false
  server:
    port: 8080
```

### 3. Dependency Injection (Constructor Injection)

```java
@Service
@RequiredArgsConstructor  // Lombok generates constructor
public class UserService {
    private final UserRepository userRepository;

    public User findById(Long id) {
        return userRepository.findById(id)
            .orElseThrow(() -> new UserNotFoundException(id));
    }

    @Transactional
    public User save(User user) {
        return userRepository.save(user);
    }
}
```

### 4. REST API

```java
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;

    @GetMapping
    public List<UserResponse> getAll() {
        return userService.findAll().stream()
            .map(UserResponse::from).toList();
    }

    @GetMapping("/{id}")
    public UserResponse getById(@PathVariable Long id) {
        return UserResponse.from(userService.findById(id));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public UserResponse create(@Valid @RequestBody CreateUserRequest req) {
        return UserResponse.from(userService.create(req));
    }
}
```

### 5. JPA Data Access

```java
@Entity
@Table(name = "users")
public class User {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(unique = true, nullable = false)
    private String email;
}

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);

    @Query("SELECT u FROM User u WHERE u.name ILIKE :name")
    List<User> searchByName(@Param("name") String name);
}
```

### 6. Security Configuration

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/public/**").permitAll()
                .requestMatchers("/actuator/health").permitAll()
                .anyRequest().authenticated())
            .oauth2ResourceServer(oauth2 -> oauth2.jwt(Customizer.withDefaults()));
        return http.build();
    }
}
```

### 7. Testing

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

### 8. Actuator and Monitoring

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: when-authorized
```

## Best Practices

- Use constructor injection (not `@Autowired` field injection)
- Keep controllers thin — delegate to service layer
- Use `@ConfigurationProperties` for type-safe config binding
- Set `spring.jpa.open-in-view=false` to avoid lazy loading outside transactions
- Use `ddl-auto=validate` in production (never update/create)
- Return DTOs from controllers, not entities

## Coaching Notes

- **Thin controller pattern**: Controller validates input, calls service, returns DTO. No business logic in controllers
- **Flyway/Liquibase over ddl-auto**: Use database migration tools for schema changes in production
- **Record types for DTOs**: Java 16+ records reduce DTO boilerplate dramatically
- **Testcontainers**: Use Testcontainers for integration tests with real databases instead of H2

## Verification

- [ ] All dependencies use constructor injection (no `@Autowired` on fields)
- [ ] Controllers are thin — business logic in `@Service` classes
- [ ] `@Transactional` on all service methods that modify data
- [ ] Security configuration explicitly defines public and protected endpoints
- [ ] Actuator endpoints configured and secured for production

## Related Skills

- **backend-patterns** — General backend API and database patterns
- **api-interface-design** — Contract-first API design principles
