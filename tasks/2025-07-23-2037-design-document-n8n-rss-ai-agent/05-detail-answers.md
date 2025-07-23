# Expert-Level Implementation Answers

**Updated:** 2025-07-23  
**Phase:** Expert Requirements Clarification  
**Agent:** claude-agent-1753299359126  

## Question 1: Article Deduplication Strategy

**Answer:** **Hash article title for deduplication** - Use SHA-256 hashing of the article title to create unique identifiers for deduplication.

**Implementation Decision:**
- Hash function: `SHA-256(article_title)`
- Database constraint: `UNIQUE` constraint on `title_hash` column
- Behavior: Identical titles will be deduplicated, different titles will be processed even if content is similar
- Benefits: Simple, fast lookup, prevents duplicate processing of same articles

**Technical Impact:**
- Database schema includes `title_hash VARCHAR(64) UNIQUE NOT NULL`
- Processing flow checks hash before AI processing
- Allows content updates to same articles (different titles)

---

## Question 2: Ollama Circuit Breaker Configuration

**Answer:** **More lenient circuit breaker** - Use 10 failures with 10-minute cooldown for RSS processing.

**Implementation Decision:**
- Failure threshold: `10` failed requests
- Cooldown period: `10 minutes`
- Behavior: More tolerant of Ollama issues since RSS processing delays are acceptable
- Recovery: Auto-reset failure count on successful request

**Technical Impact:**
- Circuit breaker logic: `failureCount >= 10 && time.Since(lastFailure) < 10*time.Minute`
- Better resilience for transient Ollama issues
- Allows processing to continue with temporary AI server problems

---

## Question 3: Database Connection Strategy

**Answer:** **Connection per request with connection pooling** - Use connection pooling for efficient database access.

**Implementation Decision:**
- Pattern: Open connection per request, close after response
- Pooling: Maintain connection pool to reduce connection overhead
- Pool size: 5-10 connections (appropriate for single replica)
- Timeout: Connection timeout aligned with HTTP request timeout

**Technical Impact:**
- Use `psycopg2.pool.ThreadedConnectionPool` or similar
- Better resource management for sporadic request patterns
- Reduced database load compared to persistent connections
- Automatic connection cleanup and recovery

---

## Question 4: Processing Response Format

**Answer:** **Structured response with metadata** - Return comprehensive response data with processing metadata.

**Implementation Decision:**
- Response format: JSON with summary, original_link, source, and metadata object
- Metadata includes: processing_time_ms, model_used, processed_at, title_hash
- Benefits: Enables monitoring, debugging, and audit trails
- n8n compatibility: n8n can use relevant fields and ignore metadata if needed

**Response Structure:**
```json
{
  "summary": "• Bullet point 1\n• Bullet point 2\n• Bullet point 3",
  "original_link": "https://example.com/article",
  "source": "RSS feed name",
  "metadata": {
    "processing_time_ms": 1250,
    "model_used": "gemma3:latest",
    "processed_at": "2025-07-23T14:37:00Z",
    "title_hash": "sha256:abc123..."
  }
}
```

**Technical Impact:**
- Follows established comprehensive API response patterns
- Enables service monitoring and performance tracking
- Provides debugging information for troubleshooting

---

## Question 5: Service Scaling and Resource Management

**Answer:** **Multiple replicas with HPA** - Deploy with Horizontal Pod Autoscaler for automatic scaling based on demand.

**Implementation Decision:**
- Initial replicas: 2 (for high availability)
- HPA scaling: 2-5 replicas based on CPU/memory utilization
- Scaling metrics: CPU > 70% or Memory > 80%
- PodDisruptionBudget: `minAvailable: 1` to ensure service availability during scaling/maintenance

**Resource Configuration:**
```yaml
replicas: 2
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "2Gi"
    cpu: "1500m"
```

**HPA Configuration:**
```yaml
minReplicas: 2
maxReplicas: 5
targetCPUUtilizationPercentage: 70
targetMemoryUtilizationPercentage: 80
```

**Technical Impact:**
- Better handling of RSS processing bursts
- High availability during maintenance
- Automatic scaling for variable n8n workflow demands
- Follows critical service deployment patterns

---

## Summary of Expert Questions Phase

All 5 expert-level questions completed. Key technical decisions:

1. **Deduplication**: SHA-256 hash of article title for uniqueness
2. **Circuit Breaker**: 10 failures, 10-minute cooldown (lenient)
3. **Database**: Connection pooling with per-request connections
4. **Response Format**: Structured JSON with comprehensive metadata
5. **Scaling**: HPA with 2-5 replicas, CPU/memory-based scaling

**Next Phase**: Generate comprehensive requirements specification incorporating all discovery and expert decisions.