# Claude Code Design Document Review Workflow

This workflow guides Claude Code through comprehensive design document review, alternative research, and improvement recommendations, with mandatory activity logging integration.

## Prerequisites

- Ensure `workspace-config.json` exists in the current directory
- Git is installed and configured with access to target repositories
- Target design document must be accessible through workspace configuration
- Original design document creation task should be completed

## MANDATORY FIRST STEPS: Activity Log Integration

### Step 0A: Bootstrap Initialization

**CRITICAL: These files MUST exist and be readable. If any file cannot be read, STOP and inform the user.**

1. **Read Bootstrap Instructions**:
    - **File Path**: `.claude/bootstrap.md` (relative to current working directory)
    - **Action**: Use Read tool to load this file
    - **Error Handling**: If file doesn't exist or cannot be read, STOP execution and display: "ERROR: Cannot read .claude/bootstrap.md - Bootstrap file is missing or inaccessible. Please ensure this file exists in the workspace."

2. **Load Global Configuration**:
    - **File Path**: `.claude/config.md` (relative to current working directory)
    - **Action**: Use Read tool to load this file
    - **Error Handling**: If file doesn't exist or cannot be read, STOP execution and display: "ERROR: Cannot read .claude/config.md - Global configuration file is missing or inaccessible. Please ensure this file exists in the workspace."

3. **Validate Workspace Structure**:
    - **File Path**: `workspace-activity.json` (relative to current working directory)
    - **Action**: Use Read tool to check if file exists and is valid JSON
    - **Error Handling**: If file doesn't exist, create it with empty structure. If file exists but is invalid JSON, STOP execution and display: "ERROR: workspace-activity.json exists but contains invalid JSON. Please fix or delete this file."

### Step 0B: Activity Log Initialization

**MANDATORY: Follow the exact activity logging protocol defined in the bootstrap and config files.**

1. **Initialize Activity Log**:
    - **Action**: Read `workspace-activity.json` (already validated in Step 0A)
    - **Purpose**: Load current workspace state and existing tasks
    - **Error Handling**: If JSON parsing fails after validation, STOP execution and display: "ERROR: workspace-activity.json format is corrupted. Please restore from backup or recreate."

2. **Register Agent Session**:
    - **Action**: Create unique agent ID using format: `claude-agent-{timestamp}`
    - **Purpose**: Identify this specific Claude Code session for coordination
    - **Record**: Log agent registration in workspace activity

3. **Check Active Tasks**:
    - **Action**: Review `active_tasks` array in workspace-activity.json
    - **Purpose**: Identify conflicts with other active agents and resumable tasks
    - **Conflict Check**: Ensure no conflicts with ongoing design review operations

4. **Create Design Review Task**:
    - **Action**: Generate new task entry with type "design-review"
    - **Format**: Follow task structure defined in bootstrap.md
    - **Validation**: Ensure all required fields are populated

### Step 0C: Task Setup
Create task record with the following structure:
```json
{
  "id": "task-{YYYY-MM-DD-HHmm}-design-review",
  "type": "design-review",
  "project": "{project-alias}",
  "title": "Review design document: {design-document-reference}",
  "status": "in-progress",
  "assigned_agent": "claude-agent-{timestamp}",
  "created": "2025-07-23T10:00:00Z",
  "last_activity": "2025-07-23T14:30:00Z",
  "context": {
    "design_document_path": "{design-document-path}",
    "arguments": "{original-arguments}",
    "project_alias": "{project-alias}",
    "review_scope": "comprehensive"
  },
  "progress": {
    "completed_steps": [],
    "current_step": "initial-setup",
    "remaining_steps": ["initial-setup", "document-analysis", "alternative-research", "improvement-identification", "expert-review", "recommendations", "review-report"]
  }
}
```

```claude-code
# Autonomous design document review with alternative research and improvements
# Usage: claude-code review-design-document DESIGN_DOCUMENT_PATH_OR_FEATURE_NAME
# Context: Review and improve design document : $ARGUMENTS
```

---

## Core Workflow Steps

### Step 1: Initial Setup & Document Analysis

**Log Progress**: Update task progress to "initial-setup"

**Goal**: Locate and analyze the target design document

1. **Create timestamped workspace**:
   ```bash
   mkdir -p "reviews/$(date +%Y-%m-%d-%H%M)-design-review-${FEATURE_SLUG}"
   cd "reviews/$(date +%Y-%m-%d-%H%M)-design-review-${FEATURE_SLUG}"
   ```

2. **Locate target design document**:
    - If $ARGUMENTS is a file path, use directly
    - If $ARGUMENTS is a feature name, search for matching design documents in:
        - `tasks/*/07-design-document.md`
        - `design/requirements/*/07-design-document.md`
        - `reports/design-document-*.md`
    - Use Glob and Grep tools to find the most recent relevant design document

3. **Create initial files**:
    - `00-review-request.md` with the user's review request
    - `01-original-design.md` (copy of the design document being reviewed)
    - `metadata.json` with review tracking and document information

4. **Update tracking**: Read and update `design/reviews/.current-review` with folder name

**Activity Logging**: Record workspace setup, document location, and review initialization

**Log Progress**: Update task progress to "document-analysis"

### Step 2: Comprehensive Document Analysis

**Log Progress**: Update task progress to "document-analysis"

**Goal**: Deep analysis of current design document structure and content

5. **Analyze design document structure**:
    - Evaluate completeness of sections (architecture, APIs, data models, etc.)
    - Identify missing components or incomplete specifications
    - Assess clarity and technical depth of explanations
    - Check for consistency across different sections
    - Validate alignment with stated requirements

6. **Technical feasibility assessment**:
    - Use mcp__RepoPrompt__search (if available) to verify proposed implementations against current codebase
    - Use Grep tool to check for existing similar implementations
    - Analyze proposed architecture against current system patterns
    - Identify potential integration challenges or conflicts
    - Assess scalability and performance implications

7. **Document analysis findings**:
    - Record all findings in `02-analysis-findings.md` including:
    - Structural completeness assessment
    - Technical accuracy validation
    - Implementation feasibility concerns
    - Consistency and clarity issues
    - Missing critical components
    - Alignment with project patterns

**Activity Logging**: Record document analysis results, technical validation, and structural assessment

### Step 3: Alternative Research & Industry Best Practices

**Log Progress**: Update task progress to "alternative-research"

**Goal**: Research alternative approaches and industry best practices

8. **Industry research**:
    - Use WebSearch to research current best practices for the specific feature/component type
    - Search for alternative architectural patterns and approaches
    - Research similar implementations in popular open-source projects
    - Investigate newer technologies or frameworks that could improve the solution
    - Look for common pitfalls and lessons learned from similar projects

9. **Technology alternatives**:
    - Research alternative libraries, frameworks, or tools
    - Compare different implementation strategies
    - Investigate performance optimization opportunities
    - Research security best practices for the specific domain
    - Explore accessibility and user experience improvements

10. **Competitive analysis**:
    - Research how major companies/products solve similar problems
    - Look for documented case studies and architectural decisions
    - Identify industry standards and emerging trends
    - Research regulatory or compliance considerations

11. **Document research findings**:
    - Record all research in `03-alternative-research.md` including:
    - Alternative architectural approaches with pros/cons
    - Technology alternatives and trade-offs
    - Industry best practices and standards
    - Performance optimization opportunities
    - Security and accessibility considerations
    - Competitive insights and case studies

**Activity Logging**: Record research activities, alternative approaches discovered, and best practices identified

### Step 4: Improvement Identification & Gap Analysis

**Log Progress**: Update task progress to "improvement-identification"

**Goal**: Identify specific improvements and address gaps

12. **Gap analysis**:
    - Compare current design against research findings
    - Identify areas where alternatives offer significant advantages
    - Spot missing components or considerations
    - Evaluate design against non-functional requirements (performance, security, maintainability)
    - Assess future-proofing and extensibility

13. **Improvement opportunities**:
    - Technical improvements (better algorithms, architectures, patterns)
    - Performance optimizations and scalability enhancements
    - Security hardening and vulnerability mitigation
    - User experience and accessibility improvements
    - Maintainability and code quality enhancements
    - Integration and interoperability improvements

14. **Risk assessment**:
    - Identify potential risks in current design
    - Evaluate implementation complexity and effort
    - Assess impact on existing systems and users
    - Consider rollback and migration strategies
    - Evaluate long-term maintenance implications

15. **Document improvements**:
    - Record all findings in `04-improvement-analysis.md` including:
    - Specific gaps identified with severity levels
    - Improvement opportunities with impact assessment
    - Risk analysis and mitigation strategies
    - Implementation complexity estimates
    - Priority ranking of improvements

**Activity Logging**: Record gap analysis results, improvement opportunities, and risk assessments

### Step 5: Expert Review Questions

**Log Progress**: Update task progress to "expert-review"

**Goal**: Generate expert-level questions to validate assumptions and priorities

16. **Generate expert review questions**:
    - Create 5-7 critical questions in `05-expert-questions.md`
    - Focus on trade-offs between current design and identified alternatives
    - Ask about priorities: performance vs. maintainability, speed vs. security, etc.
    - Question assumptions about user behavior, system constraints, or business requirements
    - Validate importance of identified improvements
    - Include smart defaults based on research and industry best practices

17. **Interactive expert consultation**:
    - Present questions ONE at a time with full context
    - Show: question + research context + recommended approach + reasoning
    - Wait for user input/override before proceeding to next question
    - Only after ALL questions are answered, record responses in `06-expert-answers.md`
    - Update `metadata.json` with expert consultation completion status

**Activity Logging**: Record expert questions generated, user decisions, and priority clarifications

### Step 6: Comprehensive Recommendations

**Log Progress**: Update task progress to "recommendations"

**Goal**: Generate prioritized, actionable improvement recommendations

18. **Generate improvement recommendations**:
    - Create detailed recommendations in `07-recommendations.md` including:
    - High-priority improvements with clear justification
    - Alternative architectural approaches with migration paths
    - Technology upgrades or replacements with cost-benefit analysis
    - Performance optimization strategies with expected impact
    - Security enhancements with threat mitigation details
    - User experience improvements with accessibility considerations
    - Implementation timeline and resource requirements

19. **Prioritization matrix**:
    - Rank improvements by impact vs. effort
    - Consider dependencies between improvements
    - Account for team expertise and available resources
    - Factor in business priorities and deadlines
    - Provide clear rationale for prioritization decisions

**Activity Logging**: Record recommendation generation and prioritization decisions

### Step 7: Final Review Report

**Log Progress**: Update task progress to "review-report"

**Goal**: Create comprehensive review report with executive summary

20. **Generate review report**:
    - Create comprehensive report in `08-review-report.md` including:
    - Executive summary with key findings and recommendations
    - Current design assessment with strengths and weaknesses
    - Alternative approaches analysis with detailed comparisons
    - Improvement roadmap with phases and milestones
    - Risk assessment and mitigation strategies
    - Resource requirements and implementation timeline
    - Success metrics and validation criteria

21. **Create artifacts**:
    - Generate updated design document incorporating accepted improvements
    - Create implementation checklist for development team
    - Provide decision matrix for architectural choices
    - Include research references and supporting documentation

**Activity Logging**: Record review report creation and final deliverable completion

---

## MANDATORY FINAL STEPS: Activity Log Completion

### Step 8: Complete Task and Update Metrics

1. **Mark Task Complete**: Update task status to "completed" in activity log
2. **Record Final Results**: Log comprehensive review summary and recommendations
3. **Update Workspace Metrics**: Refresh counters and statistics
4. **Save Activity Log**: Persist all changes to `workspace-activity.json`
5. **Update Workspace Timestamp**: Set `last_updated` in workspace config

### Step 9: Generate Artifacts

1. **Save Review Report**: Create `design-review-{timestamp}.md` in reports directory
2. **Update Project Metadata**: Update `last_synced` if applicable
3. **Log Task Completion**: Record final activity entry with outcomes and deliverables

---

## Important Rules:
- ONE question at a time during expert consultation
- Base ALL recommendations on research and evidence
- Provide clear justification for each suggested improvement
- Consider implementation complexity and team capabilities
- Focus on actionable improvements rather than theoretical ideals
- Validate suggestions against current project constraints

## Metadata Structure:
```json
{
  "id": "review-slug",
  "originalDesignDocument": "path/to/original/document",
  "started": "ISO-8601-timestamp",
  "lastUpdated": "ISO-8601-timestamp",
  "status": "active",
  "phase": "analysis|research|improvement|expert|complete",
  "progress": {
    "analysis": { "completed": false },
    "research": { "alternatives_found": 0, "best_practices": 0 },
    "improvements": { "identified": 0, "prioritized": 0 },
    "expert": { "answered": 0, "total": 0 }
  },
  "researchSources": ["urls/and/references"],
  "improvementAreas": ["performance", "security", "maintainability"],
  "recommendationCount": 0
}
```

## Research Strategy:
- **Technical Alternatives**: Search for proven alternative architectures and patterns
- **Performance Optimization**: Research latest optimization techniques and tools
- **Security Best Practices**: Investigate current security standards and threat models
- **Industry Standards**: Compare against established industry practices and frameworks
- **Emerging Technologies**: Evaluate newer solutions that could provide advantages
- **Case Studies**: Learn from documented real-world implementations and failures

## Review Scope Categories:
- **Architecture Review**: System design, component interactions, scalability
- **Technical Review**: Implementation approach, technology choices, performance
- **Security Review**: Threat modeling, vulnerability assessment, compliance
- **UX Review**: User experience, accessibility, usability considerations
- **Operational Review**: Deployment, monitoring, maintenance, support requirements
- **Business Review**: Cost implications, timeline feasibility, ROI considerations

## Phase Transitions:
- After each phase, announce: "Phase complete. Starting [next phase]..."
- Save all work before moving to next phase
- Log phase completion in activity log with progress summary

## Usage Examples

**Comprehensive Review:**
"Review design document for user authentication system"

**Focused Review:**
"Review design document tasks/2025-07-20-1430-design-document-user-profile/07-design-document.md"

**Performance-Focused Review:**
"Review design document with focus on performance and scalability improvements"

**Security-Focused Review:**
"Review design document for security vulnerabilities and compliance requirements"

## Expected Outcomes

After completing this workflow:

1. **Comprehensive Review Report**: Detailed analysis of current design with improvement recommendations
2. **Alternative Solutions Analysis**: Research-backed alternative approaches with trade-off analysis
3. **Prioritized Improvement Roadmap**: Clear action items ranked by impact and feasibility
4. **Complete Activity Trail**: Full audit log of review process, research, and expert consultations
5. **Task Coordination**: Other agents can see review status and recommendations
6. **Research Documentation**: Curated collection of best practices and alternative approaches
7. **Implementation Guidance**: Clear next steps for incorporating improvements
8. **Executive Summary**: High-level findings suitable for stakeholder communication

## Error Handling

If any step fails:
- **Log the Failure**: Record error details in activity log
- **Update Task Status**: Mark task as "failed" with error context
- **Continue Where Possible**: Complete remaining analysis and research steps
- **Provide Recovery Guidance**: Offer specific steps to resolve issues
- **Maintain State**: Ensure partial progress and research findings are not lost

## Usage with Claude Code

To execute this workflow:

> "Review design document for real-time notification system"

> "Review design document tasks/2025-07-23-1200-design-document-user-auth/07-design-document.md"

Claude Code will automatically integrate with the activity logging system and provide complete tracking of the design review process with comprehensive improvement recommendations.