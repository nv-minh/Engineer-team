# Stage 2: STRIDE Threat Modeling

## Agents

**Security Reviewer** (`em-agent:security-reviewer`) + **Staff Engineer** (`em-agent:staff-engineer`)

## STRIDE Categories

- **S**poofing: Identity impersonation
- **T**ampering: Data modification
- **R**epudiation: Denying actions
- **I**nformation Disclosure: Data exposure
- **D**enial of Service: Service unavailability
- **E**levation of Privilege: Unauthorized access

## Process

1. Create architecture diagram
2. Identify trust boundaries
3. Apply STRIDE to each component
4. Identify threats per category
5. Propose mitigations

## Input

- System architecture
- Data flows
- Component list
- Security context

## Output

STRIDE Threat Model with:
- Architecture diagram
- Trust boundaries
- Threats per STRIDE category
- Mitigation strategies

## Quality Gate

- [ ] Architecture diagram created
- [ ] Trust boundaries identified
- [ ] All STRIDE categories applied
- [ ] Threats mitigated

## Completion Marker

## ✅ STRIDE_THREAT_MODELING_COMPLETE
