# GitHub Webhook Setup for Automatic Jenkins Builds

## 🚀 Automatic Build Triggers

### Option 1: GitHub Webhook (Recommended - Instant Triggers)

#### 1. Configure Jenkins for Webhooks
```bash
# In Jenkins Dashboard:
# 1. Go to Manage Jenkins > Configure System
# 2. Find 'GitHub' section
# 3. Add GitHub Server配置
# 4. Add credentials (GitHub Personal Access Token)
```

#### 2. Create GitHub Personal Access Token
```bash
# Go to GitHub > Settings > Developer settings > Personal access tokens
# Generate new token with permissions:
# - repo (Full control)
# - admin:repo_hook
# - read:org
```

#### 3. Configure Webhook in GitHub
```bash
# In your GitHub repository:
# 1. Go to Settings > Webhooks
# 2. Click "Add webhook"
# 3. Payload URL: http://your-jenkins-server:8081/github-webhook/
# 4. Content type: application/json
# 5. Secret: (generate a secure secret)
# 6. Select events: "Just the push event"
# 7. Active: ✅
```

#### 4. Update Jenkinsfile for Webhook
```groovy
pipeline {
    triggers {
        // GitHub webhook trigger (instant on push)
        githubPush()
    }
    // ... rest of pipeline
}
```

### Option 2: SCM Polling (Current Setup - Every 2 Minutes)

```groovy
pipeline {
    triggers {
        // Poll SCM every 2 minutes
        pollSCM('H/2 * * * *')
    }
    // ... rest of pipeline
}
```

## 🏷️ Semantic Versioning Strategy

### Current Implementation
- **Semantic Version**: `v1.${BUILD_NUMBER}`
- **Commit Hash**: `${GIT_COMMIT_SHORT}`
- **Latest Tag**: `latest`

### Example Tags
```bash
# Build #1
- slmakomazi/fullcycle-api:v1.1
- slmakomazi/fullcycle-api:a1b2c3d
- slmakomazi/fullcycle-api:latest

# Build #2
- slmakomazi/fullcycle-api:v1.2
- slmakomazi/fullcycle-api:e4f5g6h
- slmakomazi/fullcycle-api:latest
```

### Version Tracking
```bash
# View all versions
docker images slmakomazi/fullcycle-api

# Pull specific version
docker pull slmakomazi/fullcycle-api:v1.1

# Pull by commit
docker pull slmakomazi/fullcycle-api:a1b2c3d
```

## 🔧 Jenkins Configuration

### Environment Variables
```groovy
environment {
    DOCKER_IMAGE = 'slmakomazi/fullcycle-api'
    DOCKER_TAG = "v1.${env.BUILD_NUMBER}"
    GIT_COMMIT_SHORT = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
}
```

### Build Output Example
```
✅ Build successful!
📦 Docker images pushed:
   - slmakomazi/fullcycle-api:v1.1 (semantic version)
   - slmakomazi/fullcycle-api:a1b2c3d (commit hash)
   - slmakomazi/fullcycle-api:latest (production tag)
```

## 📋 Setup Checklist

### ✅ Completed
- [x] Semantic versioning implemented
- [x] Multiple Docker tags pushed
- [x] Build logging improved
- [x] SCM polling configured (2-minute interval)

### 🔄 Next Steps
- [ ] Configure GitHub webhook for instant triggers
- [ ] Add GitHub personal access token to Jenkins
- [ ] Test automatic build on code push
- [ ] Set up build notifications (optional)

## 🎯 Benefits

1. **Instant Builds**: Webhook triggers build immediately on push
2. **Version Tracking**: Semantic versioning for releases
3. **Rollback Support**: Commit hash tags for easy rollback
4. **Production Ready**: Latest tag always points to stable build
5. **Traceability**: Build logs show version and commit info
