# Jenkins CI/CD Setup Guide

## Quick Start

### 1. Start Jenkins
```bash
docker-compose -f jenkins/jenkins-compose.yml up -d
```

### 2. Access Jenkins
- URL: http://localhost:8081
- Initial setup required on first launch

### 3. Get Initial Admin Password
```bash
docker logs jenkins
```
Look for this line in the output:
```
Jenkins initial setup is required. An admin user has been created and a password generated.
Please use the following password to proceed to installation:
*************************************************************
<YOUR_PASSWORD_HERE>
*************************************************************
```

## Required Jenkins Plugins

Install these plugins via **Manage Jenkins → Plugins → Available plugins**:

### Core Plugins
- **Pipeline** (if not installed)
- **Git** 
- **Docker Pipeline**
- **Docker Plugin**
- **GitHub Integration**
- **Credentials Binding**

### Recommended Plugins
- **Blue Ocean** (better pipeline visualization)
- **Workspace Cleanup**
- **Timestamper**
- **Pipeline Utility Steps**

## Docker Hub Credentials Setup

### 1. Add Docker Hub Credentials
1. Go to **Manage Jenkins → Manage Credentials**
2. Click **(global)** → **Add Credentials**
3. Select **Username with password**
4. Fill in:
   - **Username**: Your Docker Hub username
   - **Password**: Your Docker Hub access token
   - **ID**: `docker-hub-credentials`
   - **Description**: Docker Hub Access Token

### 2. Generate Docker Hub Access Token
1. Login to Docker Hub
2. Go to **Account Settings → Security**
3. Click **New Access Token**
4. Give it a name (e.g., "jenkins-ci")
5. Copy the generated token
6. Use this token as your password in Jenkins

## Pipeline Configuration

### 1. Create New Pipeline Job
1. Go to **New Item**
2. Enter job name (e.g., `fullcycle-api`)
3. Select **Pipeline**
4. Click **OK**

### 2. Configure Pipeline
1. Scroll to **Pipeline** section
2. Select **Pipeline script from SCM**
3. **SCM**: Git
4. **Repository URL**: `https://github.com/SLMakomazi/FullCycleDevOps.git`
5. **Branch Specifier**: `*/main`
6. **Script Path**: `jenkins/Jenkinsfile`
7. Click **Save**

## Pipeline Stages

The Jenkinsfile includes these stages:

1. **Checkout** - Clones the repository
2. **Maven Build** - Compiles the Spring Boot application
3. **Maven Test** - Runs unit tests and publishes results
4. **Docker Build** - Builds Docker image from `/api/Dockerfile`
5. **Docker Tag Latest** - Tags and pushes to Docker Hub

## Environment Variables

The pipeline uses these configurable variables:
- `DOCKER_IMAGE`: `slmakomazi/fullcycle-api`
- `DOCKER_TAG`: `latest`
- `DOCKERFILE_PATH`: `./api/Dockerfile`
- `BUILD_CONTEXT`: `./api`

## Windows + Docker Desktop Considerations

### Volume Mounting
- Docker socket mounted: `/var/run/docker.sock:/var/run/docker.sock`
- Jenkins workspace: `/workspace`
- Jenkins home: `/var/jenkins_home`

### Docker Commands
Jenkins container can run Docker commands because:
1. Docker socket is mounted
2. Jenkins user has Docker permissions
3. DOCKER_HOST environment variable is set

## Best Practices

### Security
- Use Docker Hub access tokens (not passwords)
- Rotate tokens regularly
- Keep credentials in Jenkins credential store
- Use read-only tokens when possible

### Performance
- Use Jenkins workspace volume for build artifacts
- Clean workspace after each build (`cleanWs()`)
- Use multi-stage Dockerfile for smaller images

### Reliability
- Set up pipeline triggers (webhooks)
- Configure email notifications on failure
- Monitor build times and success rates

## Troubleshooting

### Docker Permission Issues
```bash
# On Windows with Docker Desktop, ensure:
# 1. Docker Desktop is running
# 2. Docker socket is accessible
# 3. Jenkins container has necessary permissions
```

### Build Failures
1. Check Jenkins logs: `docker logs jenkins`
2. Check pipeline logs in Jenkins UI
3. Verify Docker Hub credentials
4. Test Docker build locally first

### Network Issues
- Ensure Jenkins can reach GitHub
- Ensure Jenkins can reach Docker Hub
- Check firewall settings

## Future Improvements

1. **Multi-branch Pipelines** - Build feature branches
2. **Automated Testing** - Integration tests, security scans
3. **Deployment Stages** - Staging, production environments
4. **Notifications** - Slack, Teams integration
5. **Artifact Management** - Nexus, Artifactory integration
6. **Infrastructure as Code** - Terraform integration

## Cleanup Commands

### Stop Jenkins
```bash
docker-compose -f jenkins/jenkins-compose.yml down
```

### Remove Jenkins Data (WARNING: deletes all Jenkins data)
```bash
docker-compose -f jenkins/jenkins-compose.yml down -v
```

### View Logs
```bash
docker logs -f jenkins
```

## Validation

After setup, validate by:

1. **Access Jenkins**: http://localhost:8081
2. **Run Pipeline**: Trigger build manually or via webhook
3. **Check Results**: Verify Docker image appears in Docker Hub
4. **Test Deployment**: Pull and run the new image
```bash
docker run -p 8080:8080 slmakomazi/fullcycle-api:latest
```
