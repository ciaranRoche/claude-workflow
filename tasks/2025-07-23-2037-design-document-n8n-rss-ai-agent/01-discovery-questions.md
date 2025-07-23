# Discovery Questions for n8n RSS AI Agent Integration

**Generated:** 2025-07-23  
**Phase:** Context Discovery  
**Agent:** claude-agent-1753299359126  

Based on analysis of the home-lab project and existing n8n infrastructure, here are the 5 most critical questions to understand the requirements for the RSS AI agent integration:

## Question 1: RSS Feed Sources and Discord Integration Method

**Question:** Should the AI agent process RSS feeds directly from external sources or integrate with your existing FreshRSS instance (`freshrss.freshrss.svc.cluster.local`) for consistent feed management?

**Smart Default:** **Integrate with FreshRSS** - Your home lab already has FreshRSS deployed with proper monitoring and persistence. This provides centralized feed management, prevents duplicate processing, and leverages existing infrastructure.

**Reasoning:** The home lab follows a pattern of using existing services (like PostgreSQL for data persistence, Gotify for notifications). FreshRSS integration would be more consistent with the architecture and provide better feed management capabilities.

---

## Question 2: Discord Notification Integration Approach

**Question:** Should the AI agent send Discord notifications directly via Discord webhooks/API, or route through your existing Gotify notification system for centralized notification management?

**Smart Default:** **Route through Gotify** - Your n8n instance is already configured to send notifications via Gotify (`gotify.gotify.svc.cluster.local`), and this provides consistent notification handling, logging, and delivery reliability.

**Reasoning:** The existing n8n-integrations.md shows extensive Gotify integration patterns. This approach maintains consistency with your current notification architecture and provides better monitoring/alerting capabilities.

---

## Question 3: AI Agent Deployment Architecture

**Question:** Should the AI agent be deployed as a standalone Kubernetes service with its own namespace and resources, or as a custom n8n node/plugin that runs within the existing n8n worker processes?

**Smart Default:** **Standalone Kubernetes service** - Deploy as a separate microservice in its own namespace (e.g., `rss-ai-agent`) following your established patterns with proper monitoring, PDB, and resource management.

**Reasoning:** Your home lab consistently uses separate namespaces for each service with dedicated monitoring, security contexts, and resource allocation. This approach provides better isolation, scaling, and follows your established service deployment patterns.

---

## Question 4: Data Storage and Persistence Strategy

**Question:** How should the AI agent store processed RSS items, generated summaries, and processing history - using your existing PostgreSQL instance, a dedicated database, or stateless operation with n8n workflow storage?

**Smart Default:** **Use existing PostgreSQL instance** - Create dedicated tables in your PostgreSQL instance (`postgres.postgres.svc.cluster.local`) for RSS processing history, summaries, and deduplication tracking.

**Reasoning:** Your n8n already uses PostgreSQL for execution storage, and your infrastructure shows a pattern of centralizing data in PostgreSQL rather than per-service databases. This simplifies backup, monitoring, and management.

---

## Question 5: AI Processing Model and Performance Requirements

**Question:** What level of summary detail and processing speed do you need - quick bullet-point summaries using smaller models (like gemma3:latest) for real-time processing, or detailed analysis using larger models that may take longer?

**Smart Default:** **Quick summaries with gemma3:latest** - Use your existing Ollama configuration with gemma3:latest model for consistent 2-3 bullet point summaries, processed within 30 seconds per article.

**Reasoning:** Your existing AI applications (WOPR Display, MTG Chat App, Weather Bot) all use gemma3:latest model for good balance of speed and quality. This ensures consistent performance with your current infrastructure capabilities and matches the Discord notification use case.

---

## Next Steps

After receiving answers to these questions, we will:
1. Analyze similar existing patterns in your codebase
2. Gather specific implementation details from your n8n and Ollama integrations
3. Ask expert-level technical questions about implementation specifics
4. Generate comprehensive requirements specification
5. Create detailed design document

The smart defaults above are based on analysis of your existing infrastructure patterns and will ensure consistency with your current architecture.