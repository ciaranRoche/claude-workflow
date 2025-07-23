# Discovery Answers

**Updated:** 2025-07-23  
**Phase:** Context Discovery  
**Agent:** claude-agent-1753299359126  

## Question 1: RSS Feed Sources and Discord Integration Method

**Answer:** **n8n workflow integration** - The AI agent should integrate directly with the n8n workflow. The workflow will push RSS content to the agent for processing.

**Impact:** This means the AI agent will be a service endpoint that receives content from n8n workflows rather than pulling from RSS feeds directly. The n8n workflow handles all RSS fetching and content extraction.

---

## Question 2: Discord Notification Integration Approach

**Answer:** **Return to n8n workflow** - The AI agent returns the generated summary and original link back to the n8n workflow. The n8n workflow handles all Discord delivery.

**Impact:** The AI agent is purely a processing service that receives content from n8n and returns structured summary data. Discord integration remains within n8n workflow logic.

---

## Question 3: AI Agent Deployment Architecture

**Answer:** **Standalone Kubernetes service** - Deploy as a separate microservice following your established patterns.

**Research Summary:**
- **HTTP Request Node Approach**: n8n has built-in Ollama nodes, but for custom AI processing workflows, HTTP Request nodes are the recommended approach for 2025
- **Your Architecture Pattern**: Your existing gotify-webhook-adapter shows the pattern - simple Python HTTP services that handle specific processing tasks
- **Benefits for Your Use Case**: 
  - Matches your existing microservice pattern (gotify-webhook-adapter, wopr-display, etc.)
  - Easier to monitor, scale, and maintain independently
  - Can leverage your existing Kubernetes infrastructure (monitoring, PDBs, security contexts)
  - Follows your established development workflow

**Technical Decision**: Based on your existing `gotify-webhook-adapter` service (which is exactly this pattern - receives HTTP requests, processes data, returns responses), this approach is proven in your environment.

---

## Question 4: Data Storage and Persistence Strategy

**Answer:** **Create new database on existing PostgreSQL instance** - Use the existing PostgreSQL instance (`postgres.postgres.svc.cluster.local`) but create a dedicated database for the RSS AI agent.

**Impact:** 
- New database (e.g., `rss_ai_agent`) on existing PostgreSQL server
- Dedicated tables for RSS processing history, summaries, and deduplication
- Leverages existing backup, monitoring, and management infrastructure
- Follows your pattern of centralizing data storage

---

## Question 5: AI Processing Model and Performance Requirements

**Answer:** **Quick summaries with gemma3:latest** - Use the existing gemma3:latest model for fast bullet-point summaries.

**Impact:**
- Consistent with existing AI applications (WOPR Display, MTG Chat App, Weather Bot)
- Target: 2-3 bullet point summaries processed within 30 seconds
- Leverages proven model performance in your infrastructure
- Optimal for Discord notification format

---

## Summary of Discovery Phase

All 5 discovery questions completed. Key decisions:
1. **Integration**: Direct n8n workflow integration (n8n pushes content to agent)
2. **Response**: Agent returns summary + link back to n8n workflow  
3. **Architecture**: Standalone Kubernetes service (like gotify-webhook-adapter pattern)
4. **Storage**: New database on existing PostgreSQL instance
5. **AI Model**: gemma3:latest for quick bullet-point summaries

**Next Phase**: Targeted context gathering and analysis of existing patterns.