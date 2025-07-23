# Context Findings and Technical Analysis

**Updated:** 2025-07-23  
**Phase:** Targeted Context Gathering  
**Agent:** claude-agent-1753299359126  

Based on analysis of the home-lab codebase and discovery answers, here are the specific patterns and implementation details for the RSS AI agent:

## 1. Service Architecture Patterns

### HTTP Service Pattern (gotify-webhook-adapter)
The `gotify-webhook-adapter` provides the exact pattern for our RSS AI agent:

**Key Implementation Elements:**
- **Python HTTP Server**: Simple `http.server.HTTPServer` with `BaseHTTPRequestHandler`
- **POST Endpoint**: Receives JSON payloads, processes them, returns structured responses
- **Error Handling**: Comprehensive try/catch with proper HTTP status codes
- **Health Check**: `/health` endpoint for Kubernetes readiness/liveness probes
- **Environment Configuration**: Uses `os.getenv()` for configuration management

**Code Pattern:**
```python
class WebhookHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        # Parse JSON request
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        data = json.loads(post_data.decode('utf-8'))
        
        # Process data and return JSON response
        response = process_data(data)
        
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(response).encode())
```

## 2. Ollama Integration Patterns

### WOPR Display Ollama Client (Go implementation)
The `wopr-display` app provides robust Ollama integration patterns:

**Key Features:**
- **Circuit Breaker**: Prevents cascade failures with failure tracking
- **Context Timeout**: 60-second timeout for AI requests
- **Request Structure**: Standard Ollama `/api/generate` endpoint
- **Error Recovery**: Automatic failure count reset on success
- **Payload Optimization**: Truncates large inputs to prevent timeouts

**Request Pattern:**
```json
{
  "model": "gemma3:latest",
  "prompt": "Your prompt here",
  "stream": false
}
```

**Response Pattern:**
```json
{
  "response": "Generated text response",
  "done": true
}
```

## 3. PostgreSQL Integration Patterns

### MTGJson Importer Database Pattern
The `mtgjson_importer` shows comprehensive PostgreSQL integration:

**Connection Configuration:**
- **Service Discovery**: Uses Kubernetes DNS names
- **Environment Variables**: Standard PostgreSQL env vars
- **Connection Pooling**: Context managers for transaction safety
- **Migration Support**: Schema initialization and updates

**Connection Pattern:**
```python
connection_params = {
    'host': 'postgres.postgres.svc.cluster.local',
    'port': 5432,
    'database': 'your_database_name',
    'user': os.getenv('POSTGRES_USER'),
    'password': os.getenv('POSTGRES_PASSWORD')
}
```

**Transaction Pattern:**
```python
@contextmanager
def transaction(self):
    try:
        yield self.conn
        self.conn.commit()
    except Exception:
        self.conn.rollback()
        raise
```

## 4. Container and Deployment Patterns

### Docker Container Standards
Based on `gotify-webhook-adapter/Dockerfile`:

**Security Standards:**
- **Non-root User**: Creates dedicated user (uid 1000)
- **Alpine Base**: Minimal Python 3.11 Alpine image
- **Dependency Management**: pip with --no-cache-dir flag
- **Port Exposure**: Single port (8080) for HTTP service
- **Working Directory**: Dedicated /app directory

**Build Pattern:**
- **Multi-arch Support**: `linux/arm64` for Raspberry Pi compatibility
- **Registry**: `muldoon/[service-name]` naming convention
- **Versioning**: Semantic versioning with latest tag
- **Build Tool**: Podman for container builds

## 5. Kubernetes Deployment Patterns

### Service Integration Standards
Based on analysis of existing services:

**Namespace Strategy:**
- **Dedicated Namespace**: Each service gets its own namespace
- **Consistent Naming**: Service name matches namespace name
- **Resource Isolation**: Separate PVCs, ConfigMaps, Secrets per service

**Security Context Pattern:**
```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  runAsGroup: 1000
  fsGroup: 1000
  allowPrivilegeEscalation: false
  capabilities:
    drop: ["ALL"]
```

**Resource Management:**
```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "1Gi"
    cpu: "1000m"
```

## 6. Secrets Management Pattern

### External Secrets Integration
Based on `postgres/external-secret.yaml`:

**Vault Integration:**
- **ClusterSecretStore**: `vault-backend` for centralized secret access
- **Refresh Interval**: 5-minute refresh cycle
- **Creation Policy**: `Owner` for lifecycle management
- **Template Type**: `Opaque` for generic secrets

**Secret Structure:**
```yaml
data:
  - secretKey: SERVICE_CONFIG_KEY
    remoteRef:
      key: secret/data/service-name
      property: config-property
```

## 7. Monitoring and Observability

### Service Monitoring Standards
Based on existing service patterns:

**Health Checks:**
- **Readiness Probe**: HTTP endpoint for service readiness
- **Liveness Probe**: HTTP endpoint for service health
- **Metrics Exposure**: Prometheus metrics on standard port

**Logging Standards:**
- **Structured Logging**: JSON format with timestamp, level, message
- **Log Levels**: INFO for normal operations, ERROR for failures
- **Context Correlation**: Request IDs for tracing

## 8. n8n Integration Patterns

### HTTP Request Node Configuration
From n8n-integrations.md documentation:

**Request Configuration:**
- **Method**: POST for data processing
- **Content-Type**: application/json
- **Authentication**: Service-to-service communication (no auth within cluster)
- **Timeout**: 30-second timeout for AI processing
- **Retry Logic**: n8n built-in retry for failed requests

**Expected Request/Response Pattern:**
```javascript
// n8n sends:
{
  "content": "RSS article content",
  "title": "Article title",
  "link": "Original URL",
  "source": "RSS feed name"
}

// Agent returns:
{
  "summary": "• Bullet point 1\n• Bullet point 2\n• Bullet point 3",
  "original_link": "Original URL",
  "processed_at": "2025-07-23T14:37:00Z",
  "source": "RSS feed name"
}
```

## 9. Database Schema Requirements

### RSS Processing Schema
Based on PostgreSQL patterns and use case requirements:

**Required Tables:**
1. **processed_articles**: Deduplication and history tracking
2. **summaries**: Generated AI summaries with metadata
3. **processing_logs**: Audit trail and debugging information

**Schema Pattern:**
```sql
CREATE TABLE processed_articles (
    id SERIAL PRIMARY KEY,
    article_hash VARCHAR(64) UNIQUE NOT NULL,
    title TEXT NOT NULL,
    original_link TEXT NOT NULL,
    source VARCHAR(255) NOT NULL,
    processed_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE summaries (
    id SERIAL PRIMARY KEY,
    article_id INTEGER REFERENCES processed_articles(id),
    summary TEXT NOT NULL,
    model_used VARCHAR(100) NOT NULL,
    processing_time_ms INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);
```

## 10. Service Communication Flow

### n8n → RSS AI Agent → n8n Flow
Based on existing webhook patterns:

1. **n8n Workflow**: Fetches RSS content, extracts article data
2. **HTTP Request**: POST to `http://rss-ai-agent.rss-ai-agent.svc.cluster.local/process`
3. **AI Agent**: Processes content, generates summary, stores in PostgreSQL
4. **Response**: Returns structured summary data to n8n
5. **n8n Workflow**: Formats summary + link for Discord notification

**Service Discovery:**
- **Internal DNS**: `rss-ai-agent.rss-ai-agent.svc.cluster.local`
- **Port**: 8080 (following gotify-webhook-adapter pattern)
- **Health Check**: `/health` endpoint for Kubernetes probes

## Implementation Priority

Based on patterns analysis, implementation should follow:
1. **Core HTTP Service** (following gotify-webhook-adapter pattern)
2. **Ollama Integration** (following wopr-display client pattern)
3. **PostgreSQL Integration** (following mtgjson_importer pattern)
4. **Kubernetes Deployment** (following established service patterns)
5. **n8n Workflow Integration** (using existing HTTP Request node patterns)

All patterns are well-established in the codebase, providing clear implementation guidance.