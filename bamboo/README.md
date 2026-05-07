# Bamboo CI/CD Pipeline Configuration

## Overview

This directory contains Bamboo CI/CD pipeline configuration for the DevOps & Observability Platform. The pipeline is defined using Bamboo Specs as code for version control and reproducibility.

## Pipeline Architecture

The CI/CD pipeline follows a multi-stage approach:

1. **Build** - Compile and unit test the Spring Boot application
2. **Test** - Run integration tests and performance tests
3. **Security** - Perform security scans and vulnerability assessments
4. **Package** - Build Docker image and publish to registry
5. **Deploy** - Deploy to Kubernetes cluster

## Pipeline Stages

### Build Stage
- Checks out source code from repository
- Compiles the Spring Boot application using Maven
- Runs unit tests with JUnit
- Generates code coverage reports with JaCoCo
- Publishes test results

### Test Stage
- Runs integration tests using Testcontainers
- Executes performance tests with Gatling
- Validates database interactions
- Tests API endpoints

### Security Stage
- Scans dependencies for vulnerabilities using OWASP Dependency Check
- Performs static code analysis with SonarQube
- Scans Docker image for security issues with Trivy
- Generates security reports

### Package Stage
- Builds production-ready JAR file
- Creates Docker image with multi-stage build
- Pushes image to container registry
- Creates deployment artifacts with proper image tags

### Deploy Stage
- Sets up kubectl configuration
- Applies Kubernetes manifests
- Performs rolling updates
- Runs smoke tests to verify deployment

## Environment Configuration

### Development Environment
- **Trigger**: Automatic on develop branch
- **Target**: Development Kubernetes cluster
- **Features**: Full pipeline execution

### Staging Environment
- **Trigger**: Manual on main branch
- **Target**: Staging Kubernetes cluster
- **Features**: Pre-production validation

### Production Environment
- **Trigger**: Manual after staging approval
- **Target**: Production Kubernetes cluster
- **Features**: Production deployment with rollback capability

## Required Bamboo Variables

### Authentication Variables
- `bamboo.docker_username` - Docker registry username
- `bamboo.docker_password` - Docker registry password
- `bamboo.kubeconfig` - Base64 encoded Kubernetes configuration
- `bamboo.slack_webhook` - Slack notification webhook

### Configuration Variables
- `docker_registry` - Container registry URL
- `app_name` - Application name for tagging
- `k8s_namespace` - Kubernetes namespace for deployment

## Setup Instructions

### 1. Configure Bamboo Project

1. Create a new Bamboo project
2. Link to your Git repository
3. Enable Bamboo Specs
4. Add the `bamboo-spec.yml` file to your repository root

### 2. Configure Required Variables

In Bamboo project settings, add the following variables:

**Plan Variables:**
```
docker_registry = your-registry.com
app_name = devops-observability-api
k8s_namespace = devops-observability
```

**Secret Variables:**
```
bamboo.docker_username = your-docker-username
bamboo.docker_password = your-docker-password
bamboo.kubeconfig = <base64-encoded-kubeconfig>
bamboo.slack_webhook = your-slack-webhook-url
```

### 3. Configure Build Permissions

Ensure the Bamboo agent has:
- Docker daemon access
- Kubernetes cluster access
- Internet connectivity for dependency downloads
- Sufficient disk space for builds

## Pipeline Customization

### Adding New Stages

To add new stages to the pipeline:

1. Add stage definition in `stages` section
2. Create corresponding job in `jobs` section
3. Define tasks and dependencies
4. Update environment configurations if needed

### Modifying Build Steps

To modify build steps:

1. Update task definitions in relevant jobs
2. Adjust Maven commands or Docker commands
3. Update artifact paths and patterns
4. Modify test configurations

### Integration with External Tools

The pipeline integrates with:
- **Docker Registry**: For image storage
- **Kubernetes**: For deployment
- **SonarQube**: For code quality
- **Trivy**: For container security
- **Slack**: For notifications

## Monitoring and Troubleshooting

### Build Failures

Common issues and solutions:

1. **Maven Build Failures**
   - Check dependency versions
   - Verify network connectivity
   - Review Maven settings

2. **Docker Build Failures**
   - Verify Dockerfile syntax
   - Check base image availability
   - Review build context

3. **Kubernetes Deployment Failures**
   - Validate manifests with `kubectl apply --dry-run`
   - Check resource quotas
   - Verify RBAC permissions

### Performance Optimization

1. **Build Caching**
   - Enable Maven dependency caching
   - Use Docker layer caching
   - Cache test dependencies

2. **Parallel Execution**
   - Configure parallel test execution
   - Use multiple build agents
   - Optimize stage dependencies

## Security Considerations

### Credential Management
- Use Bamboo secret variables for sensitive data
- Rotate credentials regularly
- Implement least privilege access

### Pipeline Security
- Scan all dependencies
- Validate Docker images
- Implement branch protection rules
- Use signed commits

### Runtime Security
- Implement network policies
- Use security contexts
- Monitor for anomalies

## Best Practices

1. **Version Control**
   - Store pipeline configuration in Git
   - Use semantic versioning
   - Tag releases properly

2. **Testing Strategy**
   - Test at multiple levels
   - Automate quality gates
   - Monitor test coverage

3. **Deployment Strategy**
   - Use rolling updates
   - Implement health checks
   - Plan rollback procedures

4. **Monitoring**
   - Track build metrics
   - Monitor deployment success
   - Set up alerting

## Next Steps

1. Configure automated testing
2. Set up monitoring dashboards
3. Implement blue-green deployments
4. Add chaos engineering tests
5. Configure automated rollback
