# Comprehensive Requirements Specification
## n8n RSS AI Agent Integration

**Generated:** 2025-07-23  
**Phase:** Requirements Specification  
**Agent:** claude-agent-1753299359126  
**Project:** home-lab  

## 1. Problem Statement and Solution Overview

### Problem Statement
The existing n8n RSS workflow processes RSS feeds and forwards raw content to Discord. Users need AI-generated summaries of RSS articles to quickly understand content without reading full articles, improving information consumption efficiency.

### Solution Overview
Deploy a dedicated RSS AI Agent as a Kubernetes microservice that:
- Receives RSS article content from n8n workflows via HTTP API
- Generates concise bullet-point summaries using local Ollama server
- Returns structured summary data to n8n for Discord delivery
- Provides deduplication, persistence, and monitoring capabilities

### Integration Architecture
```
n8n Workflow → RSS AI Agent → Ollama (gemma3:latest) → PostgreSQL → Response to n8n → Discord
```

## 2. Functional Requirements

### 2.1 Core Processing Requirements

**FR-001: RSS Content Processing**
- **Description**: Process RSS article content received from n8n workflows
- **Input**: JSON payload with article content, title, link, and source
- **Processing**: Generate 2-3 bullet point summaries using AI
- **Output**: Structured JSON response with summary and metadata
- **Performance**: Complete processing within 30 seconds per article

**FR-002: Article Deduplication**
- **Description**: Prevent processing of duplicate articles based on title hashing
- **Method**: SHA-256 hash of article title for uniqueness detection
- **Behavior**: Skip processing if title hash exists in database
- **Storage**: Maintain processing history for audit and deduplication

**FR-003: AI Summary Generation**
- **Description**: Generate concise, relevant summaries using local Ollama
- **Model**: gemma3:latest (consistent with existing home-lab AI services)
- **Format**: 2-3 bullet points per article
- **Prompt**: Structured prompt for consistent summary quality
- **Fallback**: Graceful degradation when Ollama is unavailable

### 2.2 Integration Requirements

**FR-004: n8n Workflow Integration**
- **Description**: Seamless integration with existing n8n workflows
- **Method**: HTTP Request node calling RSS AI Agent API
- **Endpoint**: POST `/process` for article processing
- **Protocol**: RESTful JSON API following home-lab patterns
- **Authentication**: Service-to-service (no authentication within K8s cluster)

**FR-005: Response Format Standardization**
- **Description**: Structured response format for n8n consumption
- **Format**: JSON with summary, original_link, source, and metadata
- **Metadata**: processing_time_ms, model_used, processed_at, title_hash
- **Compatibility**: n8n can extract required fields and ignore metadata

### 2.3 Data Management Requirements

**FR-006: PostgreSQL Integration**
- **Description**: Store processing history and summaries in dedicated database
- **Database**: New `rss_ai_agent` database on existing PostgreSQL instance
- **Connection**: Connection pooling with per-request pattern
- **Tables**: processed_articles, summaries, processing_logs
- **Constraints**: Unique constraints on title_hash for deduplication

**FR-007: Data Persistence and Retrieval**
- **Description**: Maintain comprehensive processing history
- **Storage**: Article metadata, generated summaries, processing statistics
- **Retention**: Configurable retention policy for historical data
- **Backup**: Leverage existing PostgreSQL backup infrastructure

## 3. Technical Requirements

### 3.1 Architecture and Deployment

**TR-001: Kubernetes Microservice Architecture**
- **Deployment**: Standalone Kubernetes service in dedicated namespace
- **Pattern**: Follow gotify-webhook-adapter service pattern
- **Namespace**: `rss-ai-agent` with dedicated resources
- **Service Discovery**: Internal DNS at `rss-ai-agent.rss-ai-agent.svc.cluster.local:8080`

**TR-002: Container Standards**
- **Base Image**: Python 3.11 Alpine (following existing patterns)
- **Security**: Non-root user (uid 1000), dropped capabilities
- **Platform**: linux/arm64 for Raspberry Pi K3s cluster
- **Registry**: muldoon/rss-ai-agent following naming convention

**TR-003: High Availability and Scaling**
- **Replicas**: 2 initial replicas for high availability
- **HPA**: Horizontal Pod Autoscaler, 2-5 replicas based on resource utilization
- **Scaling Metrics**: CPU > 70% or Memory > 80%
- **PDB**: PodDisruptionBudget with minAvailable: 1

### 3.2 Resource Management

**TR-004: Resource Allocation**
```yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "2Gi"    # Buffer for large article processing
    cpu: "1500m"     # AI processing requirements
```

**TR-005: Storage Requirements**
- **Persistent Volume**: Not required (stateless service)
- **Database Storage**: Use existing PostgreSQL PVC
- **Temporary Storage**: EmptyDir for processing artifacts

### 3.3 External Service Integration

**TR-006: Ollama Integration**
- **Endpoint**: http://192.168.1.185:11434/api/generate
- **Model**: gemma3:latest (consistent with existing services)
- **Timeout**: 60 seconds per request
- **Circuit Breaker**: 10 failures, 10-minute cooldown (lenient for RSS processing)
- **Fallback**: Return error response when circuit breaker active

**TR-007: PostgreSQL Integration**
- **Host**: postgres.postgres.svc.cluster.local:5432
- **Database**: rss_ai_agent (new database)
- **Connection Pool**: 5-10 connections using psycopg2.pool.ThreadedConnectionPool
- **Authentication**: External Secrets integration with Vault

## 4. Implementation Hints and Patterns

### 4.1 HTTP Service Implementation

**Following gotify-webhook-adapter Pattern:**
```python
class RSSAIHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path == '/process':
            # Process RSS article content
        elif self.path == '/health':
            # Health check for K8s probes
```

**Key Components:**
- HTTP server on port 8080
- JSON request/response handling
- Comprehensive error handling with proper HTTP status codes
- Health check endpoint for Kubernetes probes

### 4.2 Ollama Client Implementation

**Following wopr-display Pattern:**
```python
class OllamaClient:
    def __init__(self, base_url, model):
        self.base_url = base_url
        self.model = model
        self.failure_count = 0
        self.last_failure = None
    
    def generate_summary(self, content):
        # Circuit breaker logic
        # HTTP request to Ollama
        # Error handling and recovery
```

**Circuit Breaker Logic:**
- Track failure count and timestamps
- Skip requests during cooldown period
- Reset counters on successful requests

### 4.3 Database Schema Design

**Following mtgjson_importer Pattern:**
```sql
-- Database: rss_ai_agent
CREATE TABLE processed_articles (
    id SERIAL PRIMARY KEY,
    title_hash VARCHAR(64) UNIQUE NOT NULL,
    title TEXT NOT NULL,
    original_link TEXT NOT NULL,
    source VARCHAR(255) NOT NULL,
    content_preview TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE summaries (
    id SERIAL PRIMARY KEY,
    article_id INTEGER REFERENCES processed_articles(id),
    summary TEXT NOT NULL,
    model_used VARCHAR(100) NOT NULL,
    processing_time_ms INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE processing_logs (
    id SERIAL PRIMARY KEY,
    article_id INTEGER REFERENCES processed_articles(id),
    status VARCHAR(50) NOT NULL, -- 'success', 'failed', 'skipped'
    error_message TEXT,
    processing_duration_ms INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### 4.4 Kubernetes Manifest Structure

**Following Established Service Patterns:**
```yaml
# Namespace, Deployment, Service, HPA, PDB
# External Secret for database credentials
# ServiceMonitor for Prometheus integration
# PrometheusRule for alerting
```

## 5. Acceptance Criteria

### 5.1 Functional Acceptance Criteria

**AC-001: Article Processing**
- ✅ Service receives n8n HTTP requests with article data
- ✅ Generates 2-3 bullet point summaries using Ollama
- ✅ Returns structured JSON response with summary and metadata
- ✅ Processes articles within 30-second timeout

**AC-002: Deduplication**
- ✅ Prevents processing of articles with identical titles
- ✅ Uses SHA-256 hashing for title uniqueness
- ✅ Maintains processing history in PostgreSQL

**AC-003: Error Handling**
- ✅ Graceful handling of Ollama service unavailability
- ✅ Circuit breaker prevents cascade failures
- ✅ Proper HTTP status codes for all scenarios

### 5.2 Technical Acceptance Criteria

**AC-004: Kubernetes Integration**
- ✅ Deploys as microservice in dedicated namespace
- ✅ Service discovery via internal DNS
- ✅ Health checks pass for readiness/liveness probes
- ✅ HPA scales based on resource utilization

**AC-005: Database Integration**
- ✅ Creates dedicated database on PostgreSQL instance
- ✅ Connection pooling works correctly
- ✅ External Secrets provides database credentials

**AC-006: Monitoring and Observability**
- ✅ Prometheus metrics exposed for monitoring
- ✅ Structured logging for debugging
- ✅ Alert rules for service health monitoring

### 5.3 Performance Acceptance Criteria

**AC-007: Response Time**
- ✅ Article processing completes within 30 seconds
- ✅ Service responds to health checks within 5 seconds
- ✅ Database operations complete within 10 seconds

**AC-008: Resource Utilization**
- ✅ Service operates within defined resource limits
- ✅ HPA scaling triggers work correctly
- ✅ Memory usage remains stable under load

## 6. Assumptions and Dependencies

### 6.1 Assumptions

**A-001**: Ollama server at 192.168.1.185:11434 remains accessible and stable
**A-002**: gemma3:latest model provides adequate summary quality for RSS content
**A-003**: n8n workflows can be modified to integrate with new HTTP endpoint
**A-004**: PostgreSQL instance has capacity for additional database and connections
**A-005**: K3s cluster has sufficient resources for 2-5 replicas with specified limits

### 6.2 Dependencies

**D-001**: Existing PostgreSQL service in postgres namespace
**D-002**: External Secrets Operator for credential management
**D-003**: Prometheus Operator for monitoring integration
**D-004**: Ollama server with gemma3:latest model available
**D-005**: n8n workflow modifications for API integration

### 6.3 Risks and Mitigations

**R-001: Ollama Service Unavailability**
- Risk: AI processing fails when Ollama is down
- Mitigation: Circuit breaker pattern with graceful degradation

**R-002: Database Connection Issues**
- Risk: Service fails when database is unavailable
- Mitigation: Connection pooling with retry logic and health checks

**R-003: Resource Constraints**
- Risk: K3s cluster resources insufficient for scaling
- Mitigation: Resource monitoring and alerts, configurable scaling limits

## 7. Success Metrics

### 7.1 Operational Metrics
- **Availability**: >99% uptime for RSS processing requests
- **Response Time**: <30 seconds average processing time
- **Throughput**: Handle 50+ articles per hour during peak RSS activity
- **Error Rate**: <5% failure rate for article processing

### 7.2 Quality Metrics
- **Deduplication Accuracy**: 100% prevention of duplicate title processing
- **Summary Quality**: Consistent 2-3 bullet point format
- **Integration Success**: Seamless n8n workflow operation
- **Resource Efficiency**: Stable memory usage, effective HPA scaling

This comprehensive requirements specification provides complete guidance for implementing the RSS AI Agent integration, incorporating all technical decisions and patterns from the home-lab codebase analysis.