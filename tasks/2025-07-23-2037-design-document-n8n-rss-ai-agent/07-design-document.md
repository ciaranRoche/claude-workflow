# Design Document: n8n RSS AI Agent Integration
## Home Lab Infrastructure Enhancement

**Document Version:** 1.0  
**Date:** 2025-07-23  
**Author:** Claude AI Agent  
**Project:** home-lab  
**Status:** Ready for Implementation  

---

## Table of Contents
1. [Executive Summary](#1-executive-summary)
2. [System Architecture](#2-system-architecture)
3. [Component Design](#3-component-design)
4. [API Specifications](#4-api-specifications)
5. [Database Design](#5-database-design)
6. [Deployment Architecture](#6-deployment-architecture)
7. [Security Considerations](#7-security-considerations)
8. [Monitoring and Observability](#8-monitoring-and-observability)
9. [Implementation Plan](#9-implementation-plan)
10. [Testing Strategy](#10-testing-strategy)
11. [Risk Assessment](#11-risk-assessment)

---

## 1. Executive Summary

### 1.1 Project Overview
The RSS AI Agent is a Kubernetes microservice designed to enhance the existing n8n RSS workflow by providing AI-powered article summaries. The service integrates seamlessly with the home-lab infrastructure, following established patterns for security, monitoring, and deployment.

### 1.2 Key Features
- **AI-Powered Summaries**: Generate concise bullet-point summaries using local Ollama server
- **Deduplication**: Prevent duplicate processing using title-based hashing
- **High Availability**: HPA-enabled deployment with 2-5 replicas
- **n8n Integration**: RESTful API compatible with n8n HTTP Request nodes
- **Comprehensive Monitoring**: Prometheus metrics and structured logging

### 1.3 Success Criteria
- Process RSS articles within 30 seconds
- Achieve 99% uptime with automatic scaling
- Seamless integration with existing n8n workflows
- Zero duplicate article processing

---

## 2. System Architecture

### 2.1 High-Level Architecture

```mermaid
graph TB
    subgraph "n8n Workflow"
        A[RSS Feed Reader] --> B[Content Extractor]
        B --> C[HTTP Request Node]
        F[Format Response] --> G[Discord Notification]
    end

    subgraph "RSS AI Agent Service"
        C --> D[Load Balancer]
        D --> E1[Pod 1]
        D --> E2[Pod 2]
        D --> E3[Pod N]
        E1 --> H[Ollama Client]
        E2 --> H
        E3 --> H
    end

    subgraph "External Services"
        H --> I[Ollama Server<br/>192.168.1.185:11434]
        E1 --> J[PostgreSQL<br/>rss_ai_agent DB]
        E2 --> J
        E3 --> J
    end

    subgraph "Infrastructure"
        K[Prometheus] --> E1
        K --> E2
        K --> E3
        L[External Secrets] --> E1
        L --> E2
        L --> E3
    end

    E1 --> F
    E2 --> F
    E3 --> F
```

### 2.2 Integration Flow

1. **n8n RSS Workflow** fetches and parses RSS feeds
2. **HTTP Request Node** sends article data to RSS AI Agent
3. **RSS AI Agent** processes content through multiple steps:
   - Article deduplication check
   - AI summary generation via Ollama
   - Database persistence
   - Response formatting
4. **n8n Workflow** receives structured summary response
5. **Discord Integration** delivers formatted notifications

### 2.3 Technology Stack

| Component | Technology | Rationale |
|-----------|------------|-----------|
| Application Runtime | Python 3.11 | Consistent with existing services |
| HTTP Framework | Built-in http.server | Follows gotify-webhook-adapter pattern |
| Database Client | psycopg2 with connection pooling | Proven pattern from mtgjson_importer |
| AI Integration | HTTP client to Ollama | Follows wopr-display pattern |
| Container Platform | Kubernetes (K3s) | Existing infrastructure |
| Base Image | Python 3.11 Alpine | Security and consistency |

---

## 3. Component Design

### 3.1 Core Components

#### 3.1.1 HTTP Request Handler
```python
class RSSAIHandler(BaseHTTPRequestHandler):
    """Main HTTP request handler following gotify-webhook-adapter pattern"""
    
    def do_POST(self):
        """Handle article processing requests"""
        if self.path == '/process':
            return self._process_article()
        elif self.path == '/health':
            return self._health_check()
        else:
            self.send_error(404)
    
    def _process_article(self):
        """Process RSS article with AI summary generation"""
        # 1. Parse request JSON
        # 2. Validate input data
        # 3. Check deduplication
        # 4. Generate AI summary
        # 5. Store in database
        # 6. Return structured response
```

#### 3.1.2 Ollama Integration Client
```python
class OllamaClient:
    """AI summary generation client with circuit breaker"""
    
    def __init__(self, base_url, model, timeout=60):
        self.base_url = base_url
        self.model = model
        self.timeout = timeout
        self.failure_count = 0
        self.last_failure = None
        self.circuit_threshold = 10
        self.cooldown_minutes = 10
    
    def generate_summary(self, article_content):
        """Generate AI summary with circuit breaker protection"""
        if self._is_circuit_open():
            raise CircuitBreakerException("Ollama circuit breaker active")
        
        try:
            return self._call_ollama_api(article_content)
        except Exception as e:
            self._record_failure()
            raise
    
    def _call_ollama_api(self, content):
        """Make HTTP request to Ollama /api/generate endpoint"""
        prompt = f"""Summarize this article in exactly 3 bullet points:

{content}

Format as:
• [First key point]
• [Second key point] 
• [Third key point]"""
        
        payload = {
            "model": self.model,
            "prompt": prompt,
            "stream": False
        }
        # HTTP request implementation
```

#### 3.1.3 Database Manager
```python
class DatabaseManager:
    """PostgreSQL integration with connection pooling"""
    
    def __init__(self):
        self.pool = psycopg2.pool.ThreadedConnectionPool(
            minconn=2,
            maxconn=10,
            host='postgres.postgres.svc.cluster.local',
            port=5432,
            database='rss_ai_agent',
            user=os.getenv('POSTGRES_USER'),
            password=os.getenv('POSTGRES_PASSWORD')
        )
    
    def check_duplicate(self, title_hash):
        """Check if article title has been processed"""
        with self.pool.getconn() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    "SELECT id FROM processed_articles WHERE title_hash = %s",
                    (title_hash,)
                )
                return cur.fetchone() is not None
    
    def store_article_and_summary(self, article_data, summary_data):
        """Store article and generated summary"""
        with self.pool.getconn() as conn:
            with conn.cursor() as cur:
                # Insert article
                cur.execute("""
                    INSERT INTO processed_articles 
                    (title_hash, title, original_link, source, content_preview)
                    VALUES (%s, %s, %s, %s, %s)
                    RETURNING id
                """, (
                    article_data['title_hash'],
                    article_data['title'],
                    article_data['link'],
                    article_data['source'],
                    article_data['content'][:500]
                ))
                article_id = cur.fetchone()[0]
                
                # Insert summary
                cur.execute("""
                    INSERT INTO summaries 
                    (article_id, summary, model_used, processing_time_ms)
                    VALUES (%s, %s, %s, %s)
                """, (
                    article_id,
                    summary_data['summary'],
                    summary_data['model_used'],
                    summary_data['processing_time_ms']
                ))
                
                conn.commit()
                return article_id
```

### 3.2 Service Architecture

#### 3.2.1 Application Structure
```
rss-ai-agent/
├── src/
│   ├── main.py              # Application entry point
│   ├── handlers/
│   │   ├── __init__.py
│   │   ├── http_handler.py  # HTTP request handling
│   │   └── health_check.py  # Health check logic
│   ├── clients/
│   │   ├── __init__.py
│   │   ├── ollama_client.py # AI integration
│   │   └── database.py      # PostgreSQL client
│   ├── models/
│   │   ├── __init__.py
│   │   ├── article.py       # Article data models
│   │   └── response.py      # Response models
│   └── utils/
│       ├── __init__.py
│       ├── hashing.py       # SHA-256 utilities
│       └── logging.py       # Structured logging
├── requirements.txt         # Python dependencies
├── Dockerfile              # Container definition
├── Makefile               # Build automation
└── manifests/             # Kubernetes manifests
    ├── namespace.yaml
    ├── deployment.yaml
    ├── service.yaml
    ├── hpa.yaml
    ├── pdb.yaml
    ├── external-secret.yaml
    ├── servicemonitor.yaml
    └── prometheusrule.yaml
```

---

## 4. API Specifications

### 4.1 Process Article Endpoint

**Endpoint:** `POST /process`  
**Description:** Process RSS article content and generate AI summary

#### Request Format
```json
{
  "title": "Article Title",
  "content": "Full article content text...",
  "link": "https://example.com/article",
  "source": "RSS Feed Name"
}
```

#### Success Response (200)
```json
{
  "summary": "• First key insight from the article\n• Second important point discussed\n• Third main takeaway for readers",
  "original_link": "https://example.com/article",
  "source": "RSS Feed Name",
  "metadata": {
    "processing_time_ms": 1250,
    "model_used": "gemma3:latest",
    "processed_at": "2025-07-23T14:37:00Z",
    "title_hash": "sha256:a1b2c3d4...",
    "article_id": 12345
  }
}
```

#### Duplicate Article Response (409)
```json
{
  "error": "duplicate_article",
  "message": "Article with this title has already been processed",
  "title_hash": "sha256:a1b2c3d4...",
  "original_processed_at": "2025-07-23T10:15:00Z"
}
```

#### Error Responses
```json
// Circuit Breaker Active (503)
{
  "error": "service_unavailable", 
  "message": "AI processing temporarily unavailable - circuit breaker active",
  "retry_after": 600
}

// Processing Timeout (504)
{
  "error": "processing_timeout",
  "message": "Article processing exceeded 30 second timeout",
  "processing_time_ms": 30000
}

// Invalid Request (400)
{
  "error": "invalid_request",
  "message": "Missing required field: title",
  "required_fields": ["title", "content", "link", "source"]
}
```

### 4.2 Health Check Endpoint

**Endpoint:** `GET /health`  
**Description:** Service health check for Kubernetes probes

#### Response (200)
```json
{
  "status": "healthy",
  "timestamp": "2025-07-23T14:37:00Z",
  "checks": {
    "database": "connected",
    "ollama": "available",
    "circuit_breaker": "closed"
  },
  "uptime_seconds": 86400
}
```

### 4.3 Metrics Endpoint

**Endpoint:** `GET /metrics`  
**Description:** Prometheus metrics exposure

#### Metrics Exposed
```
# HELP rss_ai_articles_processed_total Total articles processed
# TYPE rss_ai_articles_processed_total counter
rss_ai_articles_processed_total{status="success"} 1234
rss_ai_articles_processed_total{status="duplicate"} 567
rss_ai_articles_processed_total{status="failed"} 89

# HELP rss_ai_processing_duration_seconds Article processing duration
# TYPE rss_ai_processing_duration_seconds histogram
rss_ai_processing_duration_seconds_bucket{le="1"} 100
rss_ai_processing_duration_seconds_bucket{le="5"} 1200
rss_ai_processing_duration_seconds_bucket{le="30"} 1234

# HELP rss_ai_circuit_breaker_state Current circuit breaker state
# TYPE rss_ai_circuit_breaker_state gauge
rss_ai_circuit_breaker_state{service="ollama"} 0
```

---

## 5. Database Design

### 5.1 Database Schema

#### 5.1.1 processed_articles Table
```sql
CREATE TABLE processed_articles (
    id SERIAL PRIMARY KEY,
    title_hash VARCHAR(64) UNIQUE NOT NULL,
    title TEXT NOT NULL,
    original_link TEXT NOT NULL,
    source VARCHAR(255) NOT NULL,
    content_preview TEXT, -- First 500 characters for reference
    created_at TIMESTAMP DEFAULT NOW(),
    
    INDEX idx_title_hash (title_hash),
    INDEX idx_source_created (source, created_at),
    INDEX idx_created_at (created_at)
);
```

#### 5.1.2 summaries Table
```sql
CREATE TABLE summaries (
    id SERIAL PRIMARY KEY,
    article_id INTEGER NOT NULL REFERENCES processed_articles(id),
    summary TEXT NOT NULL,
    model_used VARCHAR(100) NOT NULL,
    processing_time_ms INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    
    INDEX idx_article_id (article_id),
    INDEX idx_model_created (model_used, created_at)
);
```

#### 5.1.3 processing_logs Table
```sql
CREATE TABLE processing_logs (
    id SERIAL PRIMARY KEY,
    article_id INTEGER REFERENCES processed_articles(id),
    status VARCHAR(50) NOT NULL, -- 'success', 'failed', 'duplicate', 'timeout'
    error_message TEXT,
    processing_duration_ms INTEGER,
    ollama_response_time_ms INTEGER,
    database_response_time_ms INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    
    INDEX idx_status_created (status, created_at),
    INDEX idx_article_id (article_id)
);
```

### 5.2 Database Operations

#### 5.2.1 Deduplication Check
```sql
-- Fast lookup for duplicate detection
SELECT id, created_at 
FROM processed_articles 
WHERE title_hash = ? 
LIMIT 1;
```

#### 5.2.2 Summary Retrieval
```sql
-- Get article with summary for debugging
SELECT 
    pa.title,
    pa.original_link,
    pa.source,
    s.summary,
    s.model_used,
    s.processing_time_ms,
    pa.created_at
FROM processed_articles pa
JOIN summaries s ON pa.id = s.article_id
WHERE pa.title_hash = ?;
```

#### 5.2.3 Performance Statistics
```sql
-- Processing performance metrics
SELECT 
    DATE_TRUNC('day', created_at) as date,
    COUNT(*) as total_articles,
    AVG(processing_time_ms) as avg_processing_time,
    MAX(processing_time_ms) as max_processing_time,
    COUNT(CASE WHEN processing_time_ms > 30000 THEN 1 END) as timeouts
FROM summaries
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE_TRUNC('day', created_at)
ORDER BY date DESC;
```

---

## 6. Deployment Architecture

### 6.1 Kubernetes Manifests

#### 6.1.1 Namespace
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: rss-ai-agent
  labels:
    app.kubernetes.io/name: rss-ai-agent
    app.kubernetes.io/part-of: home-lab
```

#### 6.1.2 Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rss-ai-agent
  namespace: rss-ai-agent
  labels:
    app.kubernetes.io/name: rss-ai-agent
    app.kubernetes.io/component: api
    app.kubernetes.io/part-of: home-lab
spec:
  replicas: 2
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: rss-ai-agent
  template:
    metadata:
      labels:
        app: rss-ai-agent
        app.kubernetes.io/name: rss-ai-agent
        app.kubernetes.io/component: api
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
      containers:
        - name: rss-ai-agent
          image: muldoon/rss-ai-agent:1.0.0
          ports:
            - containerPort: 8080
              name: http
          env:
            - name: OLLAMA_BASE_URL
              value: "http://192.168.1.185:11434"
            - name: OLLAMA_MODEL
              value: "gemma3:latest"
            - name: DATABASE_HOST
              value: "postgres.postgres.svc.cluster.local"
            - name: DATABASE_PORT
              value: "5432"
            - name: DATABASE_NAME
              value: "rss_ai_agent"
          envFrom:
            - secretRef:
                name: rss-ai-agent-secret
          securityContext:
            allowPrivilegeEscalation: false
            runAsNonRoot: true
            runAsUser: 1000
            capabilities:
              drop: ["ALL"]
            readOnlyRootFilesystem: true
          resources:
            requests:
              memory: "512Mi"
              cpu: "500m"
            limits:
              memory: "2Gi"
              cpu: "1500m"
          volumeMounts:
            - name: tmp
              mountPath: /tmp
            - name: var-tmp
              mountPath: /var/tmp
          livenessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 30
            periodSeconds: 30
            timeoutSeconds: 10
          readinessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 10
            periodSeconds: 15
            timeoutSeconds: 5
      volumes:
        - name: tmp
          emptyDir:
            medium: Memory
        - name: var-tmp
          emptyDir:
            medium: Memory
```

#### 6.1.3 Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: rss-ai-agent
  namespace: rss-ai-agent
  labels:
    app.kubernetes.io/name: rss-ai-agent
spec:
  selector:
    app: rss-ai-agent
  ports:
    - port: 8080
      targetPort: 8080
      protocol: TCP
      name: http
  type: ClusterIP
```

#### 6.1.4 Horizontal Pod Autoscaler
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: rss-ai-agent-hpa
  namespace: rss-ai-agent
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: rss-ai-agent
  minReplicas: 2
  maxReplicas: 5
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50  
        periodSeconds: 60
```

#### 6.1.5 Pod Disruption Budget
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: rss-ai-agent-pdb
  namespace: rss-ai-agent
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: rss-ai-agent
```

#### 6.1.6 External Secret
```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: rss-ai-agent-secrets
  namespace: rss-ai-agent
spec:
  refreshInterval: 5m
  secretStoreRef:
    name: vault-backend
    kind: ClusterSecretStore
  target:
    name: rss-ai-agent-secret
    creationPolicy: Owner
    template:
      type: Opaque
  data:
    - secretKey: POSTGRES_USER
      remoteRef:
        key: secret/data/postgres
        property: postgres-user
    - secretKey: POSTGRES_PASSWORD
      remoteRef:
        key: secret/data/postgres
        property: postgres-password
```

### 6.2 Container Build Process

#### 6.2.1 Dockerfile
```dockerfile
FROM python:3.11-alpine

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Create non-root user
RUN adduser -D -u 1000 rssai

# Set working directory
WORKDIR /app

# Copy application
COPY src/ .

# Change ownership
RUN chown -R rssai:rssai /app

# Switch to non-root user
USER rssai

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')"

# Run the application
CMD ["python3", "main.py"]
```

#### 6.2.2 Build and Deploy Script
```bash
#!/bin/bash
# Build and deploy RSS AI Agent

VERSION=${1:-latest}
IMAGE_NAME="muldoon/rss-ai-agent"
PLATFORM="linux/arm64"

echo "Building ${IMAGE_NAME}:${VERSION} for ${PLATFORM}"

# Build image
podman build --platform=${PLATFORM} -t ${IMAGE_NAME}:${VERSION} .
podman tag ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:latest

# Push to registry
podman push ${IMAGE_NAME}:${VERSION}
podman push ${IMAGE_NAME}:latest

# Deploy to Kubernetes
kubectl apply -f manifests/

echo "Deployment complete!"
```

---

## 7. Security Considerations

### 7.1 Container Security

#### 7.1.1 Security Context
- **Non-root User**: Container runs as uid 1000 (rssai user)
- **Read-only Root Filesystem**: Prevents runtime modifications
- **Dropped Capabilities**: All Linux capabilities dropped for minimal attack surface
- **No Privilege Escalation**: Prevents escalation attacks

#### 7.1.2 Network Security
- **Cluster-only Access**: Service only accessible within Kubernetes cluster
- **Service Discovery**: Uses internal DNS for service communication
- **No External Exposure**: No ingress or external load balancer

### 7.2 Secrets Management

#### 7.2.1 Database Credentials
- **External Secrets Operator**: Integrates with existing Vault infrastructure
- **Automatic Rotation**: 5-minute refresh interval for credentials
- **No Hardcoded Secrets**: All secrets sourced from Vault

#### 7.2.2 API Security
- **No Authentication Required**: Service-to-service communication within cluster
- **Input Validation**: Comprehensive validation of all API inputs
- **Rate Limiting**: Inherent rate limiting through HPA resource constraints

### 7.3 Data Security

#### 7.3.1 Data at Rest
- **PostgreSQL Encryption**: Leverages existing PostgreSQL security
- **No Sensitive Data Storage**: Only article titles and summaries stored
- **Retention Policies**: Configurable data retention for compliance

#### 7.3.2 Data in Transit
- **Cluster Network**: All traffic stays within secure K8s network
- **HTTPS to Ollama**: Ollama integration uses HTTP (internal network)
- **Database Connections**: Encrypted connections to PostgreSQL

---

## 8. Monitoring and Observability

### 8.1 Prometheus Metrics

#### 8.1.1 ServiceMonitor
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: rss-ai-agent
  namespace: rss-ai-agent
  labels:
    app.kubernetes.io/name: rss-ai-agent
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: rss-ai-agent
  endpoints:
  - port: http
    path: /metrics
    interval: 30s
    scrapeTimeout: 10s
```

#### 8.1.2 Custom Metrics
```python
# Prometheus metrics definitions
from prometheus_client import Counter, Histogram, Gauge

# Request counters
ARTICLES_PROCESSED = Counter(
    'rss_ai_articles_processed_total',
    'Total articles processed',
    ['status']  # success, duplicate, failed, timeout
)

# Processing duration
PROCESSING_DURATION = Histogram(
    'rss_ai_processing_duration_seconds',
    'Article processing duration',
    buckets=[1, 5, 10, 30, 60]
)

# Circuit breaker state
CIRCUIT_BREAKER_STATE = Gauge(
    'rss_ai_circuit_breaker_state',
    'Circuit breaker state (0=closed, 1=open)',
    ['service']
)

# Database connection pool
DB_CONNECTIONS = Gauge(
    'rss_ai_database_connections',
    'Database connection pool status',
    ['state']  # active, idle, total
)
```

### 8.2 Alerting Rules

#### 8.2.1 PrometheusRule
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: rss-ai-agent-alerts
  namespace: rss-ai-agent
spec:
  groups:
  - name: rss-ai-agent.rules
    rules:
    - alert: RSSAIAgentDown
      expr: up{job="rss-ai-agent"} == 0
      for: 5m
      labels:
        severity: critical
        service: rss-ai-agent
      annotations:
        summary: "RSS AI Agent service is down"
        description: "RSS AI Agent has been down for more than 5 minutes"
        runbook_url: "https://github.com/ciaranRoche/home-lab/blob/main/docs/alert-runbooks.md#rss-ai-agent-down"

    - alert: RSSAIProcessingErrors
      expr: rate(rss_ai_articles_processed_total{status="failed"}[5m]) > 0.1
      for: 2m
      labels:
        severity: warning
        service: rss-ai-agent
      annotations:
        summary: "High RSS AI processing error rate"
        description: "RSS AI Agent error rate is {{ $value }} errors per second"

    - alert: RSSAICircuitBreakerOpen
      expr: rss_ai_circuit_breaker_state{service="ollama"} == 1
      for: 1m
      labels:
        severity: warning
        service: rss-ai-agent
      annotations:
        summary: "RSS AI circuit breaker is open"
        description: "Ollama circuit breaker has been open for {{ $for }}"

    - alert: RSSAIHighProcessingTime
      expr: histogram_quantile(0.95, rss_ai_processing_duration_seconds) > 25
      for: 5m
      labels:
        severity: warning
        service: rss-ai-agent
      annotations:
        summary: "RSS AI processing time is high"
        description: "95th percentile processing time is {{ $value }}s"

    - alert: RSSAIHighMemoryUsage
      expr: container_memory_usage_bytes{pod=~"rss-ai-agent-.*"} / container_spec_memory_limit_bytes > 0.9
      for: 5m
      labels:
        severity: warning
        service: rss-ai-agent
      annotations:
        summary: "RSS AI Agent high memory usage"
        description: "Memory usage is {{ $value | humanizePercentage }}"
```

### 8.3 Structured Logging

#### 8.3.1 Log Format
```python
import logging
import json
from datetime import datetime

class StructuredLogger:
    def __init__(self, name):
        self.logger = logging.getLogger(name)
        handler = logging.StreamHandler()
        handler.setFormatter(self.JsonFormatter())
        self.logger.addHandler(handler)
        self.logger.setLevel(logging.INFO)
    
    class JsonFormatter(logging.Formatter):
        def format(self, record):
            log_entry = {
                "timestamp": datetime.utcnow().isoformat() + "Z",
                "level": record.levelname,
                "logger": record.name,
                "message": record.getMessage(),
                "module": record.module,
                "function": record.funcName,
                "line": record.lineno
            }
            
            # Add extra fields if present
            if hasattr(record, 'article_id'):
                log_entry['article_id'] = record.article_id
            if hasattr(record, 'processing_time_ms'):
                log_entry['processing_time_ms'] = record.processing_time_ms
            if hasattr(record, 'error_type'):
                log_entry['error_type'] = record.error_type
                
            return json.dumps(log_entry)

# Usage examples
logger = StructuredLogger('rss-ai-agent')

# Success logging
logger.info("Article processed successfully", extra={
    'article_id': 12345,
    'processing_time_ms': 1250,
    'model_used': 'gemma3:latest'
})

# Error logging
logger.error("Failed to process article", extra={
    'article_id': 12346,
    'error_type': 'ollama_timeout',
    'processing_time_ms': 30000
})
```

### 8.4 Health Checks

#### 8.4.1 Comprehensive Health Check
```python
def health_check():
    """Comprehensive health check for Kubernetes probes"""
    checks = {
        "database": check_database_connection(),
        "ollama": check_ollama_availability(),
        "circuit_breaker": check_circuit_breaker_state(),
        "memory": check_memory_usage(),
        "disk_space": check_disk_space()
    }
    
    overall_status = "healthy" if all(checks.values()) else "unhealthy"
    
    return {
        "status": overall_status,
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "checks": checks,
        "uptime_seconds": get_uptime_seconds()
    }
```

---

## 9. Implementation Plan

### 9.1 Development Phases

#### Phase 1: Core Service Development (Week 1)
- [ ] **HTTP Handler Implementation**
  - Basic HTTP server with /process and /health endpoints
  - Request/response JSON handling
  - Input validation and error handling
  
- [ ] **Database Integration**
  - PostgreSQL connection pooling setup
  - Schema creation and migration scripts
  - Basic CRUD operations for articles and summaries

- [ ] **Ollama Client Development**
  - HTTP client for Ollama API integration
  - Circuit breaker implementation
  - Error handling and retry logic

#### Phase 2: Advanced Features (Week 2)
- [ ] **Deduplication Logic**
  - SHA-256 hashing implementation for article titles
  - Database constraint enforcement
  - Duplicate detection and response handling

- [ ] **Monitoring Integration**
  - Prometheus metrics implementation
  - Structured logging setup
  - Health check enhancements

- [ ] **Container and Build System**
  - Dockerfile creation following security best practices
  - Makefile for build automation
  - Container image optimization

#### Phase 3: Kubernetes Deployment (Week 3)
- [ ] **Kubernetes Manifests**
  - All K8s resource definitions
  - External Secrets integration
  - HPA and PDB configuration

- [ ] **Database Setup**
  - Create rss_ai_agent database on PostgreSQL
  - Run schema migration scripts
  - Verify connection and permissions

- [ ] **Initial Deployment**
  - Deploy to K8s cluster
  - Verify service discovery and networking
  - Test basic functionality

#### Phase 4: Integration and Testing (Week 4)
- [ ] **n8n Workflow Integration**
  - Modify existing n8n RSS workflow
  - Add HTTP Request node calling RSS AI Agent
  - Test end-to-end flow with real RSS feeds

- [ ] **Monitoring Setup**
  - Deploy ServiceMonitor and PrometheusRule
  - Configure Grafana dashboards
  - Test alerting scenarios

- [ ] **Performance Testing**
  - Load testing with multiple concurrent requests
  - HPA scaling verification
  - Resource utilization monitoring

### 9.2 Development Environment Setup

#### 9.2.1 Local Development
```bash
# Setup Python environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Database setup (using Docker)
docker run -d \
  --name postgres-dev \
  -e POSTGRES_DB=rss_ai_agent \
  -e POSTGRES_USER=dev \
  -e POSTGRES_PASSWORD=devpass \
  -p 5432:5432 \
  postgres:13-alpine

# Run application locally
export DATABASE_HOST=localhost
export DATABASE_PORT=5432
export DATABASE_NAME=rss_ai_agent
export POSTGRES_USER=dev
export POSTGRES_PASSWORD=devpass
export OLLAMA_BASE_URL=http://192.168.1.185:11434
export OLLAMA_MODEL=gemma3:latest

python src/main.py
```

#### 9.2.2 Testing Framework
```python
# Unit tests
import unittest
from unittest.mock import Mock, patch
from src.handlers.http_handler import RSSAIHandler

class TestRSSAIHandler(unittest.TestCase):
    def setUp(self):
        self.handler = RSSAIHandler()
        
    @patch('src.clients.ollama_client.OllamaClient.generate_summary')
    @patch('src.clients.database.DatabaseManager.check_duplicate')
    def test_process_article_success(self, mock_check_dup, mock_generate):
        mock_check_dup.return_value = False
        mock_generate.return_value = "• Point 1\n• Point 2\n• Point 3"
        
        # Test successful article processing
        request_data = {
            "title": "Test Article",
            "content": "Test content",
            "link": "https://example.com/test",
            "source": "Test Source"
        }
        
        response = self.handler.process_article(request_data)
        self.assertEqual(response['status'], 'success')
        self.assertIn('summary', response)

# Integration tests  
class TestRSSAIIntegration(unittest.TestCase):
    def test_end_to_end_processing(self):
        # Test complete flow from HTTP request to database storage
        pass
        
    def test_ollama_integration(self):
        # Test actual Ollama API calls
        pass
        
    def test_database_operations(self):
        # Test database CRUD operations
        pass
```

### 9.3 Deployment Checklist

#### Pre-Deployment Verification
- [ ] **Database Preparation**
  - [ ] Create `rss_ai_agent` database on PostgreSQL instance
  - [ ] Run schema migration scripts
  - [ ] Verify database user permissions
  - [ ] Test database connectivity from K8s cluster

- [ ] **Secrets Management**
  - [ ] Verify Vault secrets for PostgreSQL credentials
  - [ ] Test External Secrets Operator integration
  - [ ] Validate secret mounting in pods

- [ ] **Infrastructure Prerequisites**
  - [ ] Verify Ollama server accessibility at 192.168.1.185:11434
  - [ ] Test gemma3:latest model availability
  - [ ] Confirm K8s cluster resource availability

#### Deployment Steps
1. **Deploy Database Schema**
   ```bash
   kubectl run schema-migration --image=postgres:13-alpine --rm --restart=Never -- \
     psql postgresql://user:pass@postgres.postgres.svc.cluster.local:5432/rss_ai_agent \
     -f schema.sql
   ```

2. **Deploy Kubernetes Resources**
   ```bash
   kubectl apply -f manifests/namespace.yaml
   kubectl apply -f manifests/external-secret.yaml
   kubectl apply -f manifests/deployment.yaml
   kubectl apply -f manifests/service.yaml
   kubectl apply -f manifests/hpa.yaml
   kubectl apply -f manifests/pdb.yaml
   kubectl apply -f manifests/servicemonitor.yaml
   kubectl apply -f manifests/prometheusrule.yaml
   ```

3. **Verify Deployment**
   ```bash
   # Check pod status
   kubectl get pods -n rss-ai-agent
   
   # Verify service endpoints
   kubectl get endpoints -n rss-ai-agent
   
   # Test health check
   kubectl run test-pod --image=curlimages/curl --rm --restart=Never -- \
     curl -f http://rss-ai-agent.rss-ai-agent.svc.cluster.local:8080/health
   
   # Test processing endpoint
   kubectl run test-process --image=curlimages/curl --rm --restart=Never -- \
     curl -X POST -H "Content-Type: application/json" \
     -d '{"title":"Test","content":"Test content","link":"https://test.com","source":"Test"}' \
     http://rss-ai-agent.rss-ai-agent.svc.cluster.local:8080/process
   ```

4. **n8n Integration Setup**
   - Modify existing RSS workflow to include HTTP Request node
   - Configure endpoint: `http://rss-ai-agent.rss-ai-agent.svc.cluster.local:8080/process`
   - Test with sample RSS feed data
   - Verify Discord notifications include AI summaries

---

## 10. Testing Strategy

### 10.1 Unit Testing

#### 10.1.1 Test Coverage Requirements
- **Minimum Coverage**: 80% code coverage for all modules
- **Critical Path Coverage**: 95% coverage for core processing logic
- **Error Handling**: 100% coverage for error scenarios

#### 10.1.2 Test Categories
```python
# HTTP Handler Tests
class TestHTTPHandler:
    def test_process_article_valid_input()
    def test_process_article_invalid_input()
    def test_process_article_duplicate()
    def test_health_check_healthy()
    def test_health_check_unhealthy()

# Ollama Client Tests  
class TestOllamaClient:
    def test_generate_summary_success()
    def test_generate_summary_timeout()
    def test_circuit_breaker_open()
    def test_circuit_breaker_recovery()

# Database Manager Tests
class TestDatabaseManager:
    def test_connection_pool_initialization()
    def test_check_duplicate_exists()
    def test_check_duplicate_not_exists()
    def test_store_article_and_summary()
    def test_database_connection_failure()

# Utility Tests
class TestUtils:
    def test_sha256_hashing()
    def test_structured_logging()
    def test_input_validation()
```

### 10.2 Integration Testing

#### 10.2.1 Component Integration Tests
```python
class TestComponentIntegration:
    def test_http_to_database_flow(self):
        """Test complete HTTP request to database storage"""
        # Mock Ollama, test HTTP -> DB flow
        
    def test_http_to_ollama_flow(self):
        """Test HTTP request to Ollama integration"""
        # Use real Ollama, mock database
        
    def test_database_transaction_rollback(self):
        """Test transaction rollback on errors"""
        # Test database transaction handling
```

#### 10.2.2 End-to-End Testing
```python
class TestEndToEnd:
    def test_complete_article_processing(self):
        """Test full article processing workflow"""
        # Use real database and Ollama instances
    
    def test_duplicate_article_handling(self):
        """Test duplicate detection end-to-end"""
        
    def test_error_recovery_scenarios(self):
        """Test various error scenarios and recovery"""
```

### 10.3 Performance Testing

#### 10.3.1 Load Testing Scenarios
```bash
# Basic load test using curl
for i in {1..100}; do
  curl -X POST \
    -H "Content-Type: application/json" \
    -d "{\"title\":\"Test Article $i\",\"content\":\"Test content for article $i\",\"link\":\"https://test.com/$i\",\"source\":\"Test Source\"}" \
    http://rss-ai-agent.rss-ai-agent.svc.cluster.local:8080/process &
done
wait

# Concurrent processing test
ab -n 1000 -c 10 -T application/json -p test_article.json \
  http://rss-ai-agent.rss-ai-agent.svc.cluster.local:8080/process
```

#### 10.3.2 Performance Benchmarks
- **Response Time**: < 30 seconds for 95% of requests
- **Throughput**: Handle 50+ concurrent requests
- **Resource Usage**: Stay within defined resource limits
- **HPA Scaling**: Scale up/down within 2 minutes

### 10.4 Monitoring and Alerting Tests

#### 10.4.1 Prometheus Metrics Validation
```bash
# Test metrics endpoint
curl http://rss-ai-agent.rss-ai-agent.svc.cluster.local:8080/metrics

# Verify metric values
kubectl run prometheus-query --image=prom/prometheus --rm --restart=Never -- \
  promtool query instant http://prometheus-k8s.monitoring.svc.cluster.local:9090 \
  'rss_ai_articles_processed_total'
```

#### 10.4.2 Alert Testing
```bash
# Trigger circuit breaker alert
# Stop Ollama temporarily and send requests

# Trigger high memory alert  
# Send large concurrent requests

# Trigger service down alert
# Scale deployment to 0 replicas
```

---

## 11. Risk Assessment

### 11.1 Technical Risks

#### 11.1.1 High Impact Risks

**R-001: Ollama Service Unavailability**
- **Impact**: Complete service degradation, no summary generation
- **Probability**: Medium (external dependency)
- **Mitigation**: Circuit breaker pattern, graceful degradation, monitoring alerts
- **Contingency**: Manual Ollama service restart, fallback to raw content forwarding

**R-002: Database Connection Issues**
- **Impact**: Service unable to check duplicates or store summaries
- **Probability**: Low (internal infrastructure)
- **Mitigation**: Connection pooling, health checks, PostgreSQL HA
- **Contingency**: Service restart, database connection troubleshooting

**R-003: Resource Exhaustion**
- **Impact**: Service degradation, failed scaling
- **Probability**: Medium (AI processing is resource-intensive)
- **Mitigation**: Resource limits, HPA scaling, monitoring
- **Contingency**: Manual scaling, resource limit adjustment

#### 11.1.2 Medium Impact Risks

**R-004: n8n Workflow Integration Issues**
- **Impact**: RSS processing pipeline broken
- **Probability**: Low (well-defined API contract)
- **Mitigation**: Comprehensive API documentation, integration testing
- **Contingency**: Rollback to previous n8n workflow configuration

**R-005: Circuit Breaker False Positives**
- **Impact**: Service unavailable despite Ollama being healthy
- **Probability**: Low (lenient threshold settings)
- **Mitigation**: Monitoring, adjustable thresholds, manual reset capability
- **Contingency**: Circuit breaker parameter tuning

### 11.2 Operational Risks

#### 11.2.1 Deployment Risks

**R-006: Database Schema Migration Issues**
- **Impact**: Service deployment failure
- **Probability**: Low (simple schema)
- **Mitigation**: Schema validation, rollback scripts, backup procedures
- **Contingency**: Manual schema fixes, database restoration

**R-007: Secret Management Failures**
- **Impact**: Service unable to authenticate with database
- **Probability**: Low (existing External Secrets infrastructure)
- **Mitigation**: Secret validation, Vault integration testing
- **Contingency**: Manual secret creation, troubleshoot External Secrets

#### 11.2.2 Performance Risks

**R-008: AI Processing Latency**
- **Impact**: Slow response times, timeout errors
- **Probability**: Medium (dependent on article complexity)
- **Mitigation**: Timeout configuration, model optimization, content preprocessing
- **Contingency**: Timeout adjustment, model replacement

**R-009: Memory Leaks**
- **Impact**: Pod restarts, service degradation
- **Probability**: Low (Python garbage collection)
- **Mitigation**: Memory monitoring, resource limits, regular restarts
- **Contingency**: Pod restart policies, memory limit adjustment

### 11.3 Security Risks

#### 11.3.1 Low Impact Risks

**R-010: Information Disclosure**
- **Impact**: RSS article content visible in logs/metrics
- **Probability**: Low (no sensitive content expected)
- **Mitigation**: Log sanitization, structured logging practices
- **Contingency**: Log cleanup, monitoring review

**R-011: Denial of Service**
- **Impact**: Service overwhelmed by too many requests
- **Probability**: Low (internal service, rate limiting via resources)
- **Mitigation**: Resource limits, HPA scaling, monitoring
- **Contingency**: Manual scaling, request throttling

### 11.4 Risk Monitoring

#### 11.4.1 Risk Indicators
```yaml
# Prometheus alerts for risk monitoring
- alert: HighOllamaFailureRate
  expr: rate(rss_ai_articles_processed_total{status="failed"}[5m]) > 0.1
  
- alert: DatabaseConnectionErrors
  expr: increase(rss_ai_database_errors_total[5m]) > 5

- alert: MemoryLeakDetection
  expr: increase(container_memory_usage_bytes{pod=~"rss-ai-agent-.*"}[1h]) > 100000000

- alert: ProcessingLatencyHigh
  expr: histogram_quantile(0.95, rss_ai_processing_duration_seconds) > 25
```

#### 11.4.2 Risk Response Procedures
1. **Immediate Response** (< 5 minutes)
   - Alert acknowledgment
   - Initial impact assessment
   - Emergency mitigation activation

2. **Short-term Response** (< 30 minutes)
   - Root cause analysis
   - Service restoration
   - Communication to stakeholders

3. **Long-term Response** (< 24 hours)
   - Permanent fix implementation
   - Documentation updates
   - Process improvements

---

## Conclusion

This design document provides comprehensive guidance for implementing the RSS AI Agent integration within the home-lab infrastructure. The solution follows established patterns, maintains security best practices, and provides robust monitoring and scalability features.

### Key Implementation Benefits
- **Seamless Integration**: Fits naturally into existing n8n and infrastructure patterns
- **High Availability**: HPA scaling and circuit breaker patterns ensure reliability
- **Comprehensive Monitoring**: Full observability with metrics, logging, and alerting
- **Security First**: Follows all established home-lab security practices
- **Maintainable**: Clear code structure and comprehensive documentation

### Next Steps
1. Review and approve design document
2. Begin Phase 1 development (Core Service Development)
3. Set up development environment and testing framework
4. Execute implementation plan following defined milestones

The design is ready for implementation and will enhance the RSS processing workflow with AI-powered summarization capabilities while maintaining the high standards of the home-lab infrastructure.