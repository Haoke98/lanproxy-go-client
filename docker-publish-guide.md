# Docker 镜像发布指南

本文档介绍如何将构建好的 lanproxy-go-client 镜像发布到 Docker Hub 或其他镜像仓库。

## 问题分析

错误 `push access denied, repository does not exist or may require authorization` 通常由以下原因引起：

1. **未登录 Docker Hub**
2. **仓库不存在或命名不正确**
3. **没有推送权限**
4. **镜像标签格式不正确**

## 解决方案

### 方法一：发布到 Docker Hub（推荐）

#### 1. 注册 Docker Hub 账号
- 访问 [Docker Hub](https://hub.docker.com/)
- 注册账号并记住用户名

#### 2. 登录 Docker Hub
```bash
docker login
# 输入用户名和密码
```

#### 3. 重新标记镜像
```bash
# 格式：docker tag 本地镜像名 用户名/仓库名:标签
docker tag lanproxy-client 你的用户名/lanproxy-go-client:latest

# 示例
docker tag lanproxy-client johndoe/lanproxy-go-client:latest
```

#### 4. 推送镜像
```bash
# 推送到你的仓库
docker push 你的用户名/lanproxy-go-client:latest

# 示例
docker push johndoe/lanproxy-go-client:latest
```

#### 5. 验证发布
- 访问 `https://hub.docker.com/r/你的用户名/lanproxy-go-client`
- 确认镜像已成功上传

### 方法二：发布到阿里云容器镜像服务

#### 1. 登录阿里云镜像仓库
```bash
# 替换为你的阿里云镜像仓库地址
docker login --username=你的用户名 registry.cn-hangzhou.aliyuncs.com
```

#### 2. 标记镜像
```bash
docker tag lanproxy-client registry.cn-hangzhou.aliyuncs.com/你的命名空间/lanproxy-go-client:latest
```

#### 3. 推送镜像
```bash
docker push registry.cn-hangzhou.aliyuncs.com/你的命名空间/lanproxy-go-client:latest
```

### 方法三：发布到腾讯云容器镜像服务

#### 1. 登录腾讯云镜像仓库
```bash
docker login --username=你的用户名 ccr.ccs.tencentyun.com
```

#### 2. 标记和推送镜像
```bash
docker tag lanproxy-client ccr.ccs.tencentyun.com/你的命名空间/lanproxy-go-client:latest
docker push ccr.ccs.tencentyun.com/你的命名空间/lanproxy-go-client:latest
```

## 完整发布流程示例

假设你的 Docker Hub 用户名是 `myusername`：

```bash
# 1. 构建镜像
docker build -t lanproxy-client .

# 2. 登录 Docker Hub
docker login

# 3. 标记镜像
docker tag lanproxy-client myusername/lanproxy-go-client:latest
docker tag lanproxy-client myusername/lanproxy-go-client:v1.0.0

# 4. 推送镜像
docker push myusername/lanproxy-go-client:latest
docker push myusername/lanproxy-go-client:v1.0.0

# 5. 验证
docker pull myusername/lanproxy-go-client:latest
```

## 使用发布的镜像

### 直接运行
```bash
docker run -d --name lanproxy-client \
  myusername/lanproxy-go-client:latest \
  -k your_client_key \
  -s your_server_host \
  -p 4900
```

### 更新 docker-compose.yml
```yaml
version: '3.8'

services:
  lanproxy-client:
    image: myusername/lanproxy-go-client:latest  # 使用发布的镜像
    # 移除 build: . 这一行
    container_name: lanproxy-client
    restart: unless-stopped
    command: [
      "-k", "${CLIENT_KEY:-your_client_key_here}",
      "-s", "${SERVER_HOST:-your_server_host_here}", 
      "-p", "${SERVER_PORT:-4900}",
      "--ssl", "${ENABLE_SSL:-false}"
    ]
```

## 自动化发布（GitHub Actions）

创建 `.github/workflows/docker-publish.yml`：

```yaml
name: Docker Publish

on:
  push:
    tags:
      - 'v*'
  release:
    types: [published]

jobs:
  docker:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v3
      
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
      
    - name: Login to Docker Hub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKERHUB_USERNAME }}
        password: ${{ secrets.DOCKERHUB_TOKEN }}
        
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v4
      with:
        images: ${{ secrets.DOCKERHUB_USERNAME }}/lanproxy-go-client
        
    - name: Build and push
      uses: docker/build-push-action@v4
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
```

## 常见问题

### 1. 登录失败
```bash
# 检查登录状态
docker info | grep Username

# 重新登录
docker logout
docker login
```

### 2. 推送超时
```bash
# 使用镜像加速器或切换网络
# 参考 docker-registry-config.md
```

### 3. 仓库不存在
- 确保在 Docker Hub 上创建了对应的仓库
- 或者推送时会自动创建公共仓库

### 4. 权限不足
- 确保使用正确的用户名
- 检查是否有推送权限（私有仓库）

## 最佳实践

1. **使用语义化版本标签**：`v1.0.0`, `v1.1.0` 等
2. **同时推送 latest 和版本标签**
3. **使用多阶段构建减少镜像大小**
4. **添加镜像标签和描述**
5. **定期清理旧版本镜像**