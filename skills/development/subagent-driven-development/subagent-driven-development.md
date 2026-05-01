---
name: subagent-driven-development
description: Use fresh subagent for each task to maintain context quality. Use when working on complex features, needing isolation between tasks, or when context is getting large.
version: "2.0.0"
category: "development"
origin: "superpowers"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["subagent", "fresh context", "task isolation", "parallel execution"]
intent: "Prevent context-window degradation by dispatching focused subagents so quality stays high across every task."
scenarios:
  - "Building a multi-module authentication system where each module needs isolated attention"
  - "Parallelizing independent feature work across a user dashboard and settings page"
  - "Orchestrating a complex migration where each step must be reviewed before the next begins"
best_for: "complex features, large codebases, parallel tasks, context management"
estimated_time: "30-45 min"
anti_patterns:
  - "Dumping the entire spec and codebase into every subagent prompt"
  - "Skipping the two-stage review and letting subagent output merge unchecked"
  - "Running tasks sequentially when they have no dependencies on each other"
related_skills: ["incremental-implementation", "writing-plans", "code-review"]
---

# Subagent-Driven Development

## Overview

Subagent-driven development dispatches a fresh agent for each task, giving each task a clean context window and focused attention. The main agent orchestrates work, reviews between tasks, and maintains overall direction.

## When to Use

- Working on complex features with many tasks
- Context window is getting large
- Need isolation between tasks
- Want frequent review checkpoints
- Parallelizing independent work

## Benefits

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  Single Agent (❌ Bad)         Subagents (✅ Good)      │
│  ─────────────────             ───────────────          │
│                                                         │
│  Context grows                Fresh context            │
│  Quality degrades              Quality maintained       │
│  No checkpoints               Frequent reviews          │
│  Hard to debug                Easy to isolate issues    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## The Workflow

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  Main Agent                                             │
│  ┌─────────────────────────────────────────────┐       │
│  │ 1. Read plan                               │       │
│  │ 2. For each task:                          │       │
│  │    a. Dispatch subagent with task context  │       │
│  │    b. Review subagent output               │       │
│  │    c. Approve or request changes           │       │
│  │    d. Mark task complete                   │       │
│  └─────────────────────────────────────────────┘       │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Subagent Dispatch Pattern

### 1. Prepare Task Context

Give each subagent exactly what it needs:

```typescript
// ✅ Good: Focused task context
const taskContext = {
  task: 'Task 1: Create user data model',
  spec: {
    // Only the relevant spec section
    dataModel: 'User has id, name, email, password'
  },
  files: {
    // Only relevant files
    existing: 'src/models/User.ts (does not exist yet)',
    related: 'src/models/index.ts (export barrel)'
  },
  constraints: {
    // Specific constraints for this task
    'Use Prisma ORM',
    'Password must be hashed',
    'Add timestamps'
  },
  previousTasks: [], // No dependencies
  nextTasks: ['Task 2: Create user repository'] // What comes next
};
```

### 2. Dispatch Subagent

Use the Task tool to dispatch:

```typescript
// Dispatch subagent for Task 1
const result = await Task({
  description: 'Create user data model',
  prompt: `
    <task>
    ${taskContext.task}
    </task>

    <spec>
    ${taskContext.spec}
    </spec>

    <files>
    ${taskContext.files}
    </files>

    <constraints>
    ${taskContext.constraints}
    </constraints>

    <output_format>
    Return a summary of:
    1. What you created
    2. File paths and their purpose
    3. Any decisions you made
    4. Tests added
    </output_format>
  `,
  subagent_type: 'general-purpose'
});
```

### 3. Review Subagent Output

Review the subagent's work before proceeding:

```typescript
// ✅ Good: Review checklist
const review = {
  filesCreated: ['src/models/User.ts', 'src/models/User.test.ts'],
  testsAdded: true,
  conventionsFollowed: true,
  decisions: ['Used Prisma schema', 'Added bcrypt for password hashing'],
  issues: [] // Any problems to address
};

// If issues found, request fixes
if (review.issues.length > 0) {
  await Task({
    description: 'Fix user data model issues',
    prompt: `
      Your previous work had these issues:
      ${review.issues.join('\n')}

      Please fix them.
    `,
    subagent_type: 'general-purpose'
  });
}
```

### 4. Continue to Next Task

Once approved, move to the next task:

```typescript
// Task 1 complete, proceed to Task 2
const task2Context = {
  task: 'Task 2: Create user repository',
  spec: {
    repositoryPattern: 'Separate data access logic',
    methods: ['findById', 'findByEmail', 'create', 'update', 'delete']
  },
  files: {
    existing: 'src/models/User.ts',
    related: 'src/repositories/index.ts'
  },
  dependencies: ['Task 1: User model created'],
  constraints: [
    'Use repository pattern',
    'Handle not found cases',
    'Add error handling'
  ]
};
```

## Two-Stage Review

### Stage 1: Subagent Self-Review

Instruct subagents to review their own work:

```typescript
const prompt = `
<main_task>
Create user repository
</main_task>

<self_review_checklist>
Before returning, review your work:
1. Does it match the spec?
2. Are all methods implemented?
3. Is error handling complete?
4. Are tests passing?
5. Is code clean and follows conventions?
</self_review_checklist>

<output_format>
Return:
1. Summary of what you created
2. Self-review results (pass/fail each checklist item)
3. Any concerns or questions
</output_format>
`;
```

### Stage 2: Main Agent Review

Main agent reviews subagent output:

```typescript
function reviewSubagentOutput(output: SubagentOutput) {
  const review = {
    specCompliance: checkSpecCompliance(output),
    codeQuality: checkCodeQuality(output),
    testsComplete: checkTests(output),
    conventions: checkConventions(output),
    issues: []
  };

  if (!review.specCompliance) {
    review.issues.push('Does not match spec requirements');
  }
  if (!review.codeQuality) {
    review.issues.push('Code quality issues found');
  }
  if (!review.testsComplete) {
    review.issues.push('Tests incomplete or missing');
  }
  if (!review.conventions) {
    review.issues.push('Does not follow project conventions');
  }

  return review;
}
```

## Parallel Execution

For independent tasks, dispatch multiple subagents in parallel:

```typescript
// ✅ Good: Parallel execution for independent tasks
const parallelTasks = [
  {
    task: 'Task 3: Create user service',
    dependencies: ['Task 1', 'Task 2']
  },
  {
    task: 'Task 4: Create auth controller',
    dependencies: ['Task 1', 'Task 2']
  },
  {
    task: 'Task 5: Create user UI components',
    dependencies: ['Task 1']
  }
];

// Execute independent tasks in parallel
const results = await Promise.all(
  parallelTasks.map(task =>
    Task({
      description: task.task,
      prompt: buildTaskPrompt(task),
      subagent_type: 'general-purpose'
    })
  )
);

// Review all results
const reviews = results.map(reviewSubagentOutput);
```

## Context Management

### Include Only What's Needed

Each subagent gets focused context:

```typescript
// ❌ Bad: Too much context
const badContext = {
  entireSpec: '5000 words of spec',
  entireCodebase: 'All files in the project',
  allPreviousTasks: 'Complete history of all tasks'
};

// ✅ Good: Focused context
const goodContext = {
  relevantSpec: 'Only the section for this task',
  relevantFiles: 'Only files being modified',
  directDependencies: 'Only tasks this depends on'
};
```

### Handoff Contracts

Define clear handoff between tasks:

```typescript
// Task 1 handoff
const task1Output = {
  files: ['src/models/User.ts'],
  exports: ['User', 'UserCreateInput', 'UserUpdateInput'],
  patterns: ['Uses Prisma base model', 'Has timestamps']
};

// Task 2 receives handoff
const task2Input = {
  previousTask: task1Output,
  imports: ['User from @models/User'],
  patterns: ['Follow Prisma patterns']
};
```

## Common Mistakes

| Mistake | Problem | Solution |
|---|---|---|
| Too much context | Subagent loses focus | Include only relevant context |
| No review | Quality degrades | Two-stage review process |
| Sequential when parallel possible | Slower execution | Identify independent tasks |
| Poor handoff | Subagent confused | Clear handoff contracts |
| Skipping checkpoints | Errors propagate | Review after each task |

## Coaching Notes

> **ABC - Always Be Coaching:** Subagent-driven development teaches you to treat every task as a self-contained assignment with clear inputs, outputs, and quality gates.

1. **Context is a scarce resource:** A subagent that receives the entire codebase will produce worse results than one that gets exactly what it needs. Curate context like a senior engineer curates a task brief -- relevant, minimal, sufficient.
2. **Review is not optional:** The two-stage review (self-review plus orchestrator review) is what separates subagent-driven development from blind delegation. If you skip review, errors compound across tasks.
3. **Handoff contracts create trust:** When Task 1 declares its exports and Task 2 declares its imports, you catch integration mismatches before they become runtime bugs. Treat handoff contracts like API contracts between services.

## Verification

After subagent-driven development:

- [ ] Each task had focused context
- [ ] Subagents completed tasks independently
- [ ] Two-stage review was performed
- [ ] Issues were addressed before proceeding
- [ ] Independent tasks were parallelized
- [ ] Handoffs were clear between tasks
- [ ] All tests pass across all tasks
- [ ] Code follows project conventions
