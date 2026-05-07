# Graylog Configuration

This directory contains Graylog server configuration files for centralized log management in the DevOps & Observability Platform.

## Configuration Files

### graylog.conf
Main Graylog server configuration file that defines:
- **Server Settings** - Master node configuration and authentication
- **HTTP Settings** - Web interface and CORS configuration
- **Elasticsearch/OpenSearch Integration** - Backend storage configuration
- **MongoDB Connection** - Metadata database settings
- **Performance Tuning** - Buffer sizes and thread pools
- **Security Settings** - Trusted proxies and access control

### log4j2.xml
Logging configuration for Graylog itself:
- **Console Appender** - Development logging
- **Rolling File Appender** - Production log rotation
- **Error File Appender** - Separate error logging
- **Audit File Appender** - Security audit logging
- **Logger Configuration** - Component-specific log levels

## Integration Points

### OpenSearch Integration
Graylog uses OpenSearch as the backend for log storage and indexing:

```yaml
elasticsearch_hosts = http://opensearch:9200
elasticsearch_index_prefix = graylog
elasticsearch_max_docs_per_index = 20000000
```

### MongoDB Integration
MongoDB stores Graylog metadata, user information, and stream configurations:

```yaml
mongodb_uri = mongodb://mongodb:27017/graylog
mongodb_max_connections = 1000
```

### Filebeat Integration
Filebeat ships application logs to Graylog via GELF protocol:

```yaml
# In docker-compose.yml
ports:
  - "12201:12201/udp"  # GELF input
  - "1514:1514/udp"    # Syslog input
```

## Key Features

### Log Processing
- **GELF Protocol** - Structured log ingestion
- **JSON Parsing** - Automatic JSON field extraction
- **Stream Processing** - Log routing and filtering
- **Content Packs** - Pre-built parsing rules

### Security
- **Authentication** - Admin user with SHA2 password
- **CORS Support** - Cross-origin requests enabled
- **Trusted Proxies** - Load balancer support
- **Audit Logging** - Security event tracking

### Performance
- **Message Journal** - Persistent message buffering
- **Process Buffers** - Optimized message processing
- **Batch Processing** - Efficient bulk operations
- **Resource Limits** - Controlled memory usage

## Configuration Variables

Graylog configuration uses environment variables for flexibility:

```bash
# Authentication
GRAYLOG_PASSWORD_SECRET=somepasswordpepper
GRAYLOG_ROOT_PASSWORD_SHA2=8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918

# External Access
GRAYLOG_HTTP_EXTERNAL_URI=http://localhost:9000/

# Backend Integration
GRAYLOG_ELASTICSEARCH_HOSTS=http://opensearch:9200
GRAYLOG_MONGODB_URI=mongodb://mongodb:27017/graylog
```

## Log Flow

```
Application Logs → Filebeat → Graylog → OpenSearch → Grafana
                    ↓
                 MongoDB (metadata)
```

1. **Application Logs** - JSON logs written by Spring Boot application
2. **Filebeat** - Collects and ships logs to Graylog
3. **Graylog** - Processes, parses, and routes logs
4. **OpenSearch** - Stores and indexes log data
5. **Grafana** - Visualizes log data and metrics

## Management

### Web Interface
Access Graylog web interface at: http://localhost:9000

**Default Credentials:**
- Username: `admin`
- Password: `admin`

### Input Configuration
Graylog automatically configures inputs for:
- **GELF UDP** - Port 12201 (from Filebeat)
- **Syslog UDP** - Port 1514 (system logs)
- **HTTP API** - Port 9000 (web interface)

### Stream Management
Default streams are created for:
- **All Messages** - Catch-all stream
- **Application Logs** - Filtered for application messages
- **Error Logs** - Filtered for error messages
- **Audit Logs** - Security and access logs

## Troubleshooting

### Common Issues

#### Graylog Won't Start
```bash
# Check configuration
docker exec graylog graylog-cli config show

# Check logs
docker logs graylog

# Verify OpenSearch connectivity
curl http://localhost:9200/_cluster/health
```

#### Log Ingestion Issues
```bash
# Check input status
curl http://localhost:9000/api/system/inputs

# Verify Filebeat connectivity
docker logs filebeat

# Check message journal
docker exec graylog ls -la /usr/share/graylog/data/journal
```

#### Performance Issues
```bash
# Monitor resource usage
docker stats graylog

# Check buffer utilization
curl http://localhost:9000/api/system/buffers

# Review processing metrics
curl http://localhost:9000/api/system/metrics
```

### Log Locations
- **Graylog Logs**: `/var/log/graylog/server.log`
- **Error Logs**: `/var/log/graylog/error.log`
- **Audit Logs**: `/var/log/graylog/audit.log`
- **Message Journal**: `/usr/share/graylog/data/journal/`

## Scaling Considerations

### High Availability
- **Multiple Graylog Nodes** - Active-active clustering
- **OpenSearch Cluster** - Distributed storage
- **MongoDB Replica Set** - Metadata redundancy
- **Load Balancer** - Traffic distribution

### Performance Optimization
- **Increase Processors** - More processing threads
- **Optimize Buffers** - Larger buffer sizes
- **SSD Storage** - Faster I/O operations
- **Memory Allocation** - Adjust JVM heap size

## Security Best Practices

### Network Security
- **TLS Encryption** - HTTPS for web interface
- **Firewall Rules** - Restrict port access
- **VPN Access** - Secure remote access
- **Network Isolation** - Separate management network

### Data Security
- **Encryption at Rest** - OpenSearch encryption
- **Access Control** - Role-based permissions
- **Audit Logging** - Comprehensive tracking
- **Data Retention** - Automated cleanup policies

## Integration with Other Services

### Prometheus Integration
Graylog exposes metrics at `/api/metrics/multiple` for Prometheus scraping.

### Grafana Integration
Use the Graylog datasource in Grafana to create log-based dashboards.

### Alerting
Configure Graylog alerts to notify on:
- **Error Rate Spikes** - Application issues
- **Log Volume Changes** - System anomalies
- **Security Events** - Unauthorized access attempts
- **Service Availability** - Health check failures
