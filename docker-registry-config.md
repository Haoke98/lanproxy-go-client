# Docker 镜像加速配置

如果在构建Docker镜像时遇到网络连接问题，可以通过配置Docker镜像加速器来解决。

## 方法一：配置Docker Desktop镜像加速器（推荐）

### macOS/Windows Docker Desktop

1. **打开Docker Desktop设置**
   - 点击Docker Desktop图标
   - 选择 "Settings" 或 "Preferences"

2. **配置镜像加速器**
   - 进入 "Docker Engine" 选项卡
   - 在JSON配置中添加以下内容：
   ```json
   {
     "registry-mirrors": [
       "https://docker.mirrors.ustc.edu.cn",
       "https://hub-mirror.c.163.com",
       "https://mirror.baidubce.com"
     ]
   }
   ```

3. **应用并重启**
   - 点击 "Apply & Restart"
   - 等待Docker重启完成

### Linux系统

1. **创建或编辑daemon.json文件**
   ```bash
   sudo mkdir -p /etc/docker
   sudo tee /etc/docker/daemon.json <<-'EOF'
   {
     "registry-mirrors": [
       "https://docker.mirrors.ustc.edu.cn",
       "https://hub-mirror.c.163.com",
       "https://mirror.baidubce.com"
     ]
   }
   EOF
   ```

2. **重启Docker服务**
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl restart docker
   ```

## 方法二：使用国内镜像源（备选方案）

如果上述方法仍然有问题，可以修改Dockerfile使用国内镜像源：

```dockerfile
# 使用网易云镜像
FROM hub.c.163.com/library/golang:1.19-alpine AS builder
# 或使用腾讯云镜像
# FROM ccr.ccs.tencentyun.com/library/golang:1.19-alpine AS builder

# 运行阶段也使用相同镜像源
FROM hub.c.163.com/library/alpine:latest
# 或
# FROM ccr.ccs.tencentyun.com/library/alpine:latest
```

## 常用国内镜像加速器地址

| 提供商 | 镜像加速器地址 |
|--------|----------------|
| 中科大 | https://docker.mirrors.ustc.edu.cn |
| 网易云 | https://hub-mirror.c.163.com |
| 百度云 | https://mirror.baidubce.com |
| 阿里云 | https://[你的加速器地址].mirror.aliyuncs.com |
| 腾讯云 | https://mirror.ccs.tencentyun.com |

## 验证配置

配置完成后，可以通过以下命令验证：

```bash
# 查看Docker配置信息
docker info

# 查看Registry Mirrors部分是否包含配置的镜像源
docker info | grep -A 10 "Registry Mirrors"
```

## 构建镜像

配置完成后，重新构建镜像：

```bash
docker build -t lanproxy-client .
```

## 故障排除

1. **如果仍然超时**：
   - 尝试更换不同的镜像加速器
   - 检查网络连接
   - 考虑使用VPN或代理

2. **权限问题**：
   - 确保Docker服务正在运行
   - 检查用户是否在docker组中（Linux）

3. **配置不生效**：
   - 确保重启了Docker服务
   - 检查JSON格式是否正确
   - 查看Docker日志：`docker system events`