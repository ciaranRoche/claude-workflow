# Expert-Level Implementation Questions

**Generated:** 2025-07-23  
**Phase:** Expert Requirements Clarification  
**Agent:** claude-agent-1753299359126  

Based on deep analysis of your home-lab codebase patterns and the discovery answers, here are 5 critical technical questions that need clarification for proper implementation:

## Question 1: Article Deduplication Strategy

**Question:** Should the AI agent implement content-based deduplication using SHA-256 hashing of article content (following your MTGJson importer pattern), or should it rely on URL-based deduplication, considering that RSS feeds sometimes republish articles with identical URLs but updated content?

**Smart Default:** **Content-based SHA-256 hashing** - Hash the article title + content to create unique identifiers, preventing processing of identical articles while allowing updates to existing articles to be re-processed.

**Technical Context:** Your `mtgjson_importer` uses database constraints for deduplication. RSS articles can have identical URLs but different content (updates), or different URLs but identical content (cross-posting).

**Implementation Impact:** Affects database schema design and processing logic flow.

---

## Question 2: Ollama Circuit Breaker Configuration

**Question:** Should the AI agent implement the same circuit breaker pattern as your WOPR Display (5 failures, 5-minute cooldown), or use more aggressive settings given that RSS processing is less time-critical than real-time display monitoring?

**Smart Default:** **More lenient circuit breaker** - 10 failures with 10-minute cooldown, since RSS processing can be delayed without impacting user experience, and allows more retry attempts for transient Ollama issues.

**Technical Context:** Your WOPR Display uses `failureCount >= 5 && time.Since(c.lastFailure) < 5*time.Minute` for circuit breaking. RSS processing has different reliability requirements.

**Implementation Impact:** Affects error handling resilience and service recovery behavior.

---

## Question 3: Database Connection Strategy

**Question:** Should the RSS AI agent maintain a persistent database connection (like your MTGJson importer pattern) or use connection pooling, considering the service will handle intermittent n8n requests rather than batch processing operations?

**Smart Default:** **Connection per request with connection pooling** - Open connection when needed, close after response, but maintain a connection pool to avoid repeated connection overhead for frequent requests.

**Technical Context:** Your MTGJson importer maintains persistent connections for batch operations. The RSS agent will have sporadic request patterns from n8n workflows.

**Implementation Impact:** Affects service resource usage, scalability, and database load patterns.

---

## Question 4: Processing Response Format

**Question:** Should the AI agent return structured summary data with processing metadata (processing time, confidence score, model version) following your comprehensive API patterns, or keep responses minimal with just summary and link for optimal n8n workflow simplicity?

**Smart Default:** **Structured response with metadata** - Include processing metadata for monitoring and debugging, following your established pattern of comprehensive service responses in gotify-webhook-adapter.

**Example Response:**
```json
{
  "summary": "• Key point 1\n• Key point 2\n• Key point 3",
  "original_link": "https://example.com/article",
  "source": "TechCrunch",
  "metadata": {
    "processing_time_ms": 1250,
    "model_used": "gemma3:latest",
    "processed_at": "2025-07-23T14:37:00Z",
    "content_hash": "sha256:abc123..."
  }
}
```

**Technical Context:** Your services provide rich response data for monitoring. n8n can ignore unused fields while preserving debugging capability.

**Implementation Impact:** Affects monitoring capabilities and debugging information available in n8n workflows.

---

## Question 5: Service Scaling and Resource Management

**Question:** Should the RSS AI agent be deployed with Kubernetes Horizontal Pod Autoscaler (HPA) and multiple replicas like your critical services, or as a single replica with Pod Disruption Budget only, given the non-critical nature of RSS processing?

**Smart Default:** **Single replica with PDB** - Deploy one replica with PodDisruptionBudget following your pattern for utility services, since RSS processing delays are acceptable and Ollama processing doesn't benefit from parallel scaling.

**Technical Context:** Your critical services (Vault, External Secrets) use multiple replicas. Utility services often use single replicas with PDB protection. Ollama processing is CPU/memory intensive and doesn't parallelize well.

**Resource Configuration:**
```yaml
replicas: 1
resources:
  requests:
    memory: "512Mi"  # Higher than webhook-adapter due to AI processing
    cpu: "500m"
  limits:
    memory: "2Gi"    # Buffer for large article processing
    cpu: "1500m"
```

**Implementation Impact:** Affects service availability, resource allocation, and operational complexity.

---

## Additional Technical Considerations

These questions address the most critical implementation decisions that aren't covered by following existing patterns. The smart defaults are based on:

1. **Your Service Patterns**: Analyzed from 8 existing services
2. **Resource Constraints**: Raspberry Pi K3s cluster limitations  
3. **Use Case Requirements**: RSS processing vs real-time monitoring
4. **Operational Complexity**: Balance between features and maintainability

**Next Steps:** After receiving answers, generate comprehensive requirements specification incorporating all technical decisions and implementation patterns.