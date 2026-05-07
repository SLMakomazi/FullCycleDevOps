package com.fullcycle.devops.config;

import io.opentelemetry.api.OpenTelemetry;
import io.opentelemetry.api.common.Attributes;
import io.opentelemetry.api.trace.Tracer;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.api.trace.StatusCode;
import io.opentelemetry.context.Scope;
import io.opentelemetry.context.propagation.TextMapPropagator;
import io.opentelemetry.exporter.otlp.trace.OtlpGrpcSpanExporter;
import io.opentelemetry.exporter.otlp.metrics.OtlpGrpcMetricExporter;
import io.opentelemetry.exporter.otlp.logs.OtlpGrpcLogRecordExporter;
import io.opentelemetry.sdk.OpenTelemetrySdk;
import io.opentelemetry.sdk.metrics.SdkMeterProvider;
import io.opentelemetry.sdk.metrics.export.PeriodicMetricReader;
import io.opentelemetry.sdk.resources.Resource;
import io.opentelemetry.sdk.trace.SdkTracerProvider;
import io.opentelemetry.sdk.trace.export.BatchSpanProcessor;
import io.opentelemetry.sdk.logs.SdkLoggerProvider;
import io.opentelemetry.sdk.logs.export.BatchLogRecordProcessor;
import io.opentelemetry.semconv.ResourceAttributes;
import io.opentelemetry.semconv.incubating.SemanticAttributes;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@Configuration
@Slf4j
public class OpenTelemetryConfig {

    @Value("${otel.exporter.otlp.endpoint:http://otel-collector:4317}")
    private String otlpEndpoint;

    @Value("${otel.service.name:devops-observability-api}")
    private String serviceName;

    @Value("${otel.service.version:1.0.0}")
    private String serviceVersion;

    @Bean
    public OpenTelemetry openTelemetry() {
        Resource resource = Resource.getDefault()
                .merge(Resource.builder()
                        .put(ResourceAttributes.SERVICE_NAME, serviceName)
                        .put(ResourceAttributes.SERVICE_VERSION, serviceVersion)
                        .put(ResourceAttributes.DEPLOYMENT_ENVIRONMENT, "docker")
                        .build());

        // Tracing
        OtlpGrpcSpanExporter spanExporter = OtlpGrpcSpanExporter.builder()
                .setEndpoint(otlpEndpoint)
                .build();

        SdkTracerProvider tracerProvider = SdkTracerProvider.builder()
                .addSpanProcessor(BatchSpanProcessor.builder(spanExporter).build())
                .setResource(resource)
                .build();

        // Metrics
        OtlpGrpcMetricExporter metricExporter = OtlpGrpcMetricExporter.builder()
                .setEndpoint(otlpEndpoint)
                .build();

        PeriodicMetricReader metricReader = PeriodicMetricReader.builder(metricExporter)
                .setInterval(java.time.Duration.ofSeconds(30))
                .build();

        SdkMeterProvider meterProvider = SdkMeterProvider.builder()
                .registerMetricReader(metricReader)
                .setResource(resource)
                .build();

        // Logging
        OtlpGrpcLogRecordExporter logExporter = OtlpGrpcLogRecordExporter.builder()
                .setEndpoint(otlpEndpoint)
                .build();

        SdkLoggerProvider loggerProvider = SdkLoggerProvider.builder()
                .addLogRecordProcessor(BatchLogRecordProcessor.builder(logExporter).build())
                .setResource(resource)
                .build();

        return OpenTelemetrySdk.builder()
                .setTracerProvider(tracerProvider)
                .setMeterProvider(meterProvider)
                .setLoggerProvider(loggerProvider)
                .build();
    }

    @Bean
    public Tracer tracer(OpenTelemetry openTelemetry) {
        return openTelemetry.getTracer(serviceName, serviceVersion);
    }

    @Bean
    public OpenTelemetryFilter openTelemetryFilter(OpenTelemetry openTelemetry) {
        return new OpenTelemetryFilter(openTelemetry);
    }

    public static class OpenTelemetryFilter extends OncePerRequestFilter {

        private final OpenTelemetry openTelemetry;
        private final TextMapPropagator propagator;

        public OpenTelemetryFilter(OpenTelemetry openTelemetry) {
            this.openTelemetry = openTelemetry;
            this.propagator = openTelemetry.getPropagators().getTextMapPropagator();
        }

        @Override
        protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, 
                                      FilterChain filterChain) throws ServletException, IOException {
            
            // Extract context from incoming headers
            var extractedContext = propagator.extract(request, HttpServletRequestTextMapGetter.INSTANCE);
            
            // Start span
            Span span = openTelemetry.getTracer("spring-boot")
                    .spanBuilder(request.getMethod() + " " + request.getRequestURI())
                    .setParent(extractedContext)
                    .setAttribute(SemanticAttributes.HTTP_METHOD, request.getMethod())
                    .setAttribute(SemanticAttributes.HTTP_URL, request.getRequestURL().toString())
                    .setAttribute(SemanticAttributes.HTTP_TARGET, request.getRequestURI())
                    .setAttribute(SemanticAttributes.HTTP_HOST, request.getServerName())
                    .setAttribute(SemanticAttributes.HTTP_SCHEME, request.getScheme())
                    .setAttribute(SemanticAttributes.HTTP_USER_AGENT, request.getHeader("User-Agent"))
                    .setAttribute(SemanticAttributes.HTTP_CLIENT_IP, request.getRemoteAddr())
                    .startSpan();

            try (Scope scope = span.makeCurrent()) {
                // Inject context for downstream calls
                propagator.inject(extractedContext, response, HttpServletResponseTextMapSetter.INSTANCE);
                
                // Continue with the request
                filterChain.doFilter(request, response);
                
                // Set response attributes
                span.setAttribute(SemanticAttributes.HTTP_STATUS_CODE, response.getStatus());
                
                if (response.getStatus() >= 400) {
                    span.setStatus(StatusCode.ERROR, "HTTP request failed");
                }
                
            } catch (Exception e) {
                span.recordException(e);
                span.setStatus(StatusCode.ERROR, e.getMessage());
                throw e;
            } finally {
                span.end();
            }
        }
    }

    private static class HttpServletRequestTextMapGetter implements TextMapPropagator.TextMapGetter<HttpServletRequest> {
        public static final HttpServletRequestTextMapGetter INSTANCE = new HttpServletRequestTextMapGetter();

        @Override
        public Iterable<String> keys(HttpServletRequest carrier) {
            return java.util.Collections.list(carrier.getHeaderNames());
        }

        @Override
        public String get(HttpServletRequest carrier, String key) {
            return carrier.getHeader(key);
        }
    }

    private static class HttpServletResponseTextMapSetter implements TextMapPropagator.TextMapSetter<HttpServletResponse> {
        public static final HttpServletResponseTextMapSetter INSTANCE = new HttpServletResponseTextMapSetter();

        @Override
        public void set(HttpServletResponse carrier, String key, String value) {
            carrier.setHeader(key, value);
        }
    }
}
