# Mermaid Diagram Patterns

Copy-paste templates for common Mermaid diagram types. Each section includes when to use the type, ready-to-edit templates, and Mermaid-specific gotchas.

---

## 1. Flowchart

**When to use:** Business logic, decision trees, user journeys, process flows.

### Basic Flowchart with Decisions

```mermaid
flowchart TD
    A([Start: User submits form]) --> B{Validate input?}
    B -- Yes --> C[Process data]
    B -- No --> D[Return 400 with errors]
    D --> A
    C --> E{Payment required?}
    E -- Yes --> F[Charge payment]
    E -- No --> G[Save to database]
    F --> H{Payment success?}
    H -- Yes --> G
    H -- No --> I[Rollback + notify user]
    I --> A
    G --> J([End: Confirmation email sent])
```

### Flowchart with Subgraphs (Swimlanes)

```mermaid
flowchart LR
    subgraph Client
        A[Browser] --> B[SPA Router]
        B --> C[API Client]
    end

    subgraph Gateway
        C --> D[Rate Limiter]
        D --> E[Auth Middleware]
        E --> F[Router]
    end

    subgraph Services
        F --> G[User Service]
        F --> H[Order Service]
        F --> I[Payment Service]
    end
```

### Flowchart with Styling

```mermaid
flowchart TD
    A[Deploy Trigger] --> B[Run Tests]
    B --> C{Tests pass?}
    C -- Yes --> D[Build Image]
    C -- No --> E[Block + Notify]
    D --> F[Push to Registry]
    F --> G[Deploy to Staging]
    G --> H[Smoke Tests]
    H --> I{Healthy?}
    I -- Yes --> J[Deploy to Production]
    I -- No --> K[Rollback]
    J --> L([Done])

    style A fill:#fed7aa,stroke:#c2410c
    style J fill:#a7f3d0,stroke:#047857
    style E fill:#fee2e2,stroke:#dc2626
    style K fill:#fee2e2,stroke:#dc2626
```

**Gotchas:**
- Use `TD` (top-down) or `LR` (left-right) explicitly. Default is TD.
- Node IDs cannot contain spaces. Use labels with square brackets: `A[This is the label]`.
- `()` for rounded (start/end), `{}` for diamonds (decisions), `[]` for rectangles (processes), `([ ])` for stadium shapes.
- Mermaid reflows nodes automatically. If you need precise control, use Excalidraw instead.
- Long labels break layout. Keep labels under 30 characters.

---

## 2. Sequence Diagram

**When to use:** API interactions, multi-service request flows, authentication flows, event-driven communication.

### API Request/Response

```mermaid
sequenceDiagram
    participant C as Client
    participant G as API Gateway
    participant A as Auth Service
    participant U as User Service
    participant DB as Database

    C->>G: POST /api/users {name, email}
    G->>A: Validate JWT token
    A-->>G: Token valid (userId: usr_123)
    G->>U: createUser({name, email})
    U->>DB: INSERT INTO users ...
    DB-->>U: {id: usr_456, ...}
    U-->>G: 201 {id: usr_456, name: "..."}
    G-->>C: 201 Created {data: {...}}
```

### Sequence with Alt/Opt/Loop Blocks

```mermaid
sequenceDiagram
    participant Client
    participant Server
    participant Cache as Redis Cache
    participant DB as PostgreSQL

    Client->>Server: GET /api/products/:id

    alt Cache Hit
        Server->>Cache: GET product:123
        Cache-->>Server: {cached product data}
        Server-->>Client: 200 {data}
    else Cache Miss
        Server->>Cache: GET product:123
        Cache-->>Server: null
        Server->>DB: SELECT * FROM products WHERE id = 123
        DB-->>Server: {product data}
        Server->>Cache: SET product:123 {data} TTL 300
        Server-->>Client: 200 {data}
    end

    opt Rate Limit Exceeded
        Server-->>Client: 429 Too Many Requests
    end
```

### Event-Driven Sequence

```mermaid
sequenceDiagram
    participant O as Order Service
    participant B as Event Bus (Kafka)
    participant P as Payment Service
    participant N as Notification Service

    O->>B: Publish: order.created {orderId: "ord_789"}
    B->>P: Consume: order.created
    P->>P: Process payment
    P->>B: Publish: payment.completed {orderId: "ord_789"}
    B->>N: Consume: payment.completed
    N->>N: Send confirmation email
    B->>O: Consume: payment.completed
    O->>O: Update order status -> confirmed
```

**Gotchas:**
- `->>` for solid arrows (requests), `-->>` for dashed arrows (responses).
- `participant` aliases (`participant A as Long Name`) keep diagram text readable.
- `alt`/`else` for mutually exclusive paths, `opt` for optional, `loop` for repeated steps.
- `Note over A,B: Text` places notes between participants.
- Avoid more than 6-7 participants. Beyond that, use a simplified view plus a detail view.

---

## 3. Class Diagram

**When to use:** OOP design, domain models, entity relationships with methods, design pattern documentation.

### Inheritance and Composition

```mermaid
classDiagram
    class User {
        +string id
        +string email
        +string name
        +Role role
        +getProfile() Profile
        +updateEmail(email: string) void
    }

    class Admin {
        +getPermissions() Permission[]
        +revokeAccess(userId: string) void
    }

    class Member {
        +Date membershipDate
        +Order[] orders
    }

    class Permission {
        +string resource
        +string action
    }

    User <|-- Admin : extends
    User <|-- Member : extends
    Admin *-- Permission : has many
```

### Service Layer Pattern

```mermaid
classDiagram
    class UserController {
        -UserService userService
        +getUser(req: Request) Response
        +createUser(req: Request) Response
    }

    class UserService {
        -UserRepository repo
        -EventBus eventBus
        +findById(id: string) User
        +create(data: CreateUserDTO) User
    }

    class UserRepository {
        -Database db
        +findById(id: string) User
        +save(user: User) User
    }

    class EventBus {
        +publish(event: DomainEvent) void
    }

    UserController --> UserService : depends on
    UserService --> UserRepository : depends on
    UserService --> EventBus : depends on
```

**Gotchas:**
- `<|--` for inheritance, `*--` for composition, `o--` for aggregation, `-->` for dependency, `--` for association.
- `+` public, `-` private, `#` protected (standard UML visibility markers).
- Mermaid class diagrams do not support generics well. Use string labels like `List~User~` with tildes.
- Keep method signatures short. Long signatures break the rendered layout.

---

## 4. ER Diagram

**When to use:** Database schema design, data model documentation, migration planning.

### Basic ER Diagram

```mermaid
erDiagram
    USER ||--o{ ORDER : "places"
    USER {
        uuid id PK
        string email UK
        string name
        enum role
        timestamp created_at
    }

    ORDER ||--|{ ORDER_ITEM : "contains"
    ORDER {
        uuid id PK
        uuid user_id FK
        decimal total
        enum status
        timestamp created_at
    }

    ORDER_ITEM }o--|| PRODUCT : "references"
    ORDER_ITEM {
        uuid id PK
        uuid order_id FK
        uuid product_id FK
        int quantity
        decimal unit_price
    }

    PRODUCT {
        uuid id PK
        string name
        decimal price
        int stock
        timestamp updated_at
    }
```

### Multi-Schema ER Diagram

```mermaid
erDiagram
    CUSTOMER ||--o{ SUBSCRIPTION : "has"
    CUSTOMER {
        uuid id PK
        string email UK
        string stripe_customer_id UK
    }

    SUBSCRIPTION ||--o{ INVOICE : "generates"
    SUBSCRIPTION {
        uuid id PK
        uuid customer_id FK
        string plan_id FK
        enum status
        timestamp current_period_end
    }

    PLAN {
        string id PK
        string name
        int price_cents
        string interval
    }

    INVOICE ||--o{ PAYMENT : "paid by"
    INVOICE {
        uuid id PK
        uuid subscription_id FK
        decimal amount
        enum status
    }

    PAYMENT {
        uuid id PK
        uuid invoice_id FK
        string stripe_payment_id
        enum method
        timestamp paid_at
    }

    SUBSCRIPTION }o--|| PLAN : "subscribes to"
```

**Gotchas:**
- Relationship syntax: `||--||` (one-to-one), `||--o{` (one-to-many), `}o--o{` (many-to-many).
- `PK` for primary keys, `FK` for foreign keys, `UK` for unique keys — these are labels, not enforced.
- Mermaid ER diagrams do not support composite keys natively. Document them in notes.
- Table names in UPPERCASE by convention (Mermaid requirement for clean rendering).

---

## 5. C4 Architecture

**When to use:** System-level architecture documentation, high-level technical design, onboarding diagrams.

### System Context (Level 1)

```mermaid
graph TB
    subgraph External
        User[End User<br/>Browser/Mobile]
        ThirdParty[Payment Provider<br/>Stripe API]
    end

    subgraph System["E-Commerce Platform"]
        Core[Web Application<br/>Next.js + Node.js]
    end

    subgraph Infrastructure
        DB[(PostgreSQL<br/>Primary Database)]
        Cache[(Redis<br/>Session Cache)]
        S3[(S3 Bucket<br/>File Storage)]
    end

    User -->|HTTPS| Core
    Core -->|SQL| DB
    Core -->|GET/SET| Cache
    Core -->|Upload/Download| S3
    Core -->|REST API| ThirdParty
    ThirdParty -->|Webhook| Core
```

### Container Diagram (Level 2)

```mermaid
graph TB
    subgraph Frontend
        SPA[Single Page App<br/>React + TypeScript]
        SSR[SSR Server<br/>Next.js]
    end

    subgraph Backend
        API[API Server<br/>Node.js + Express]
        Worker[Background Worker<br/>BullMQ]
        WS[WebSocket Server<br/>Socket.io]
    end

    subgraph Data
        DB[(PostgreSQL)]
        Redis[(Redis)]
        S3[(S3)]
    end

    SPA -->|REST| API
    SPA -->|SSR| SSR
    SSR -->|REST| API
    API -->|SQL| DB
    API -->|Enqueue| Redis
    Worker -->|Dequeue| Redis
    Worker -->|SQL| DB
    Worker -->|Upload| S3
    WS -->|Pub/Sub| Redis
    API -->|Push| WS
```

**Gotchas:**
- Mermaid does not have native C4 syntax. Use `graph` with subgraphs and styled nodes.
- Use `[( )]` for database cylinders, `[ ]` for containers, `{{ }}` for external systems.
- C4 is about zoom levels. One diagram per level: Context -> Container -> Component -> Code.
- Keep System Context under 10 elements. Add detail in Container/Component diagrams.

---

## 6. Gantt Chart

**When to use:** Project timelines, sprint planning, release schedules.

### Sprint Timeline

```mermaid
gantt
    title Sprint 14: Payment Integration
    dateFormat YYYY-MM-DD
    axisFormat %b %d

    section Design
        API Contract Definition       :done, des1, 2025-01-06, 2d
        Database Schema Design        :done, des2, 2025-01-06, 1d

    section Backend
        Payment Service Implementation :active, be1, 2025-01-08, 4d
        Webhook Handler               :be2, 2025-01-13, 2d
        Integration Tests             :be3, after be2, 2d

    section Frontend
        Checkout UI                   :fe1, 2025-01-08, 3d
        Payment Confirmation Page     :fe2, after fe1, 2d

    section QA
        End-to-End Testing            :qa1, after be3, 2d
        Security Review               :qa2, after qa1, 1d
```

**Gotchas:**
- `dateFormat` is required. Use `YYYY-MM-DD` for consistency.
- Status markers: `done`, `active`, or no marker (future).
- Dependencies: `after taskid` or specific dates.
- `axisFormat` controls the time axis display. `%b %d` = "Jan 06".
- Gantt charts in Mermaid cannot express parallel tracks within the same section. Use multiple sections.

---

## 7. State Diagram

**When to use:** State machines, order/payment/status workflows, protocol states.

### Order State Machine

```mermaid
stateDiagram-v2
    [*] --> Draft : Order created

    Draft --> Pending : User submits
    Pending --> PaymentProcessing : Payment initiated

    state PaymentProcessing {
        [*] --> Charging
        Charging --> Held : 3DS required
        Held --> Charging : 3DS confirmed
        Charging --> Captured : Payment success
        Charging --> Failed : Payment declined
    }

    PaymentProcessing --> Confirmed : Payment captured
    PaymentProcessing --> Cancelled : Payment failed 3x

    Confirmed --> Preparing : Warehouse picks
    Preparing --> Shipped : Carrier collects
    Shipped --> Delivered : Tracking confirmed
    Delivered --> [*]

    Cancelled --> [*]
```

### Feature Flag State

```mermaid
stateDiagram-v2
    [*] --> Disabled : Feature created

    Disabled --> Internal : Enable for staff
    Internal --> Beta : Enable for beta users
    Beta --> Gradual : Ramp to 10%
    Gradual --> Gradual : Ramp +10%
    Gradual --> Enabled : Ramp to 100%

    Enabled --> Disabled : Kill switch
    Beta --> Disabled : Kill switch
    Internal --> Disabled : Kill switch
    Gradual --> Disabled : Kill switch

    Enabled --> [*] : Feature removed
```

**Gotchas:**
- `stateDiagram-v2` (not `stateDiagram`) — the v2 syntax supports nested states and better rendering.
- `[*]` represents the initial and final pseudostates.
- State names must be unique across the diagram (including nested states).
- Nested states are defined with `state Name { ... }` blocks.
- Transition labels after the colon: `Source --> Target : event description`.

---

## 8. Mindmap

**When to use:** Concept exploration, feature breakdown, information architecture, brainstorming documentation.

### Feature Breakdown

```mermaid
mindmap
  root((Payment
  System))
    Accept Payments
      Credit Card
        Stripe Integration
        PCI Compliance
        Tokenization
      Bank Transfer
        Plaid Integration
        ACH Processing
    Manage Subscriptions
      Plan Management
        Free
        Pro
        Enterprise
      Billing Cycle
        Monthly
        Annual
        Usage-based
    Security
      Fraud Detection
        ML-based scoring
        Rule engine
      Compliance
        SOC 2
        PCI DSS Level 1
```

### System Architecture Exploration

```mermaid
mindmap
  root((Platform
  Architecture))
    Frontend
      Web App
        React
        Next.js SSR
        State Management
      Mobile
        React Native
        Push Notifications
    Backend
      API Layer
        REST Endpoints
        WebSocket
        Rate Limiting
      Business Logic
        Domain Services
        Event Sourcing
        CQRS
    Data
      Primary DB
        PostgreSQL
        Read Replicas
      Cache
        Redis
        CDN
    Infrastructure
      CI/CD
        GitHub Actions
        Docker
        Kubernetes
      Monitoring
        Datadog
        PagerDuty
```

**Gotchas:**
- Mindmap support in Mermaid is relatively new. Test rendering before committing.
- Indentation determines hierarchy. Use consistent spacing (2 or 4 spaces per level).
- `root(( ))` is the center node. All children are indented below it.
- Keep depth to 3-4 levels. Beyond that, the diagram becomes unreadable.
- Line breaks in node text use `<br/>` or actual newlines within the label.
