FROM alpine:3.18

# Install necessary packages
RUN apk add --no-cache \
    ca-certificates \
    curl \
    bash \
    && rm -rf /var/cache/apk/*

# Create otel user
RUN addgroup -g 1001 -S otel && \
    adduser -u 1001 -S otel -G otel

# Download and install OpenTelemetry Collector
ARG OTEL_COLLECTOR_VERSION=0.93.0
RUN wget -O /tmp/otelcol-contrib_${OTEL_COLLECTOR_VERSION}_linux_amd64.tar.gz \
    https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v${OTEL_COLLECTOR_VERSION}/otelcol-contrib_${OTEL_COLLECTOR_VERSION}_linux_amd64.tar.gz && \
    tar -xzf /tmp/otelcol-contrib_${OTEL_COLLECTOR_VERSION}_linux_amd64.tar.gz -C /tmp/ && \
    mv /tmp/otelcol-contrib /usr/local/bin/otelcol && \
    rm -rf /tmp/*

# Create directories
RUN mkdir -p /etc/otelcol-contrib /var/log/otelcol

# Copy configuration
COPY otel-collector-config.yaml /etc/otelcol-contrib/config.yaml

# Set permissions
RUN chown -R otel:otel /etc/otelcol-contrib /var/log/otelcol

# Switch to non-root user
USER otel

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:13133 || exit 1

# Expose ports
EXPOSE 4317 4318 8888 8889 13133 55679

# Command
ENTRYPOINT ["/usr/local/bin/otelcol", "--config=/etc/otelcol-contrib/config.yaml"]
