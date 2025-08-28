# Docker 使用说明

本文档介绍如何使用 Docker 运行 lanproxy-go-client。

## 快速开始

### 方法一：使用 Docker 直接构建和运行

1. **构建镜像**
   ```bash
   docker build -t lanproxy-client .
   ```

2. **运行容器**
   ```bash
   docker run -d --name lanproxy-client \
     lanproxy-client \
     -k your_client_key \
     -s your_server_host \
     -p 4900
   ```

### 方法二：使用 Docker Compose（推荐）

1. **创建环境变量文件**
   ```bash
   cp .env.example .env
   # 编辑 .env 文件，设置你的配置
   ```

   或者创建 `.env` 文件：
   ```bash
   echo "CLIENT_KEY=your_client_key_here" > .env
   echo "SERVER_HOST=your_server_host_here" >> .env
   echo "SERVER_PORT=4900" >> .env
   echo "ENABLE_SSL=false" >> .env
   ```

2. **启动服务**
   ```bash
   docker-compose up -d
   ```

3. **查看日志**
   ```bash
   docker-compose logs -f
   ```

4. **停止服务**
   ```bash
   docker-compose down
   ```

## 配置选项

### 环境变量

| 变量名 | 描述 | 默认值 | 示例 |
|--------|------|--------|---------|
| `CLIENT_KEY` | 客户端密钥 | - | `01c1e176d6ee466c8db717a8` |
| `SERVER_HOST` | 代理服务器地址 | - | `lp.thingsglobal.org` |
| `SERVER_PORT` | 代理服务器端口 | `4900` | `4900` |
| `ENABLE_SSL` | 启用SSL | `false` | `true` |
| `CERT_PATH` | SSL证书路径 | - | `/app/certs/server.crt` |

### 命令行参数

```bash
docker run lanproxy-client -h
```

可用参数：
- `-k value`: 客户端密钥
- `-s value`: 代理服务器地址
- `-p value`: 代理服务器端口（默认：4900）
- `--ssl value`: 启用SSL（默认："false"）
- `--cer value`: SSL证书路径

## SSL 配置

如果需要使用SSL连接，请按以下步骤操作：

1. **准备证书文件**
   ```bash
   mkdir certs
   # 将你的证书文件放入 certs 目录
   cp your_certificate.crt certs/
   ```

2. **修改 docker-compose.yml**
   取消注释 volumes 部分：
   ```yaml
   volumes:
     - ./certs:/app/certs:ro
   ```

3. **设置环境变量**
   ```bash
   echo "ENABLE_SSL=true" >> .env
   echo "CERT_PATH=/app/certs/your_certificate.crt" >> .env
   ```

## 故障排除

### 查看容器状态
```bash
docker ps -a
```

### 查看容器日志
```bash
docker logs lanproxy-client
# 或使用 docker-compose
docker-compose logs lanproxy-client
```

### 进入容器调试
```bash
docker exec -it lanproxy-client /bin/sh
```

### 重启容器
```bash
docker restart lanproxy-client
# 或使用 docker-compose
docker-compose restart
```

## 网络配置

如果需要访问宿主机上的服务，可以使用以下配置：

```yaml
# 在 docker-compose.yml 中添加
network_mode: "host"
```

或者使用桥接网络：
```yaml
networks:
  - lanproxy-network

networks:
  lanproxy-network:
    driver: bridge
```

## 性能优化

### 资源限制
```yaml
# 在 docker-compose.yml 中添加
deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 128M
    reservations:
      cpus: '0.1'
      memory: 64M
```

### 日志轮转
```yaml
# 在 docker-compose.yml 中添加
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

## 示例配置

### 基本配置示例
```bash
# .env 文件
CLIENT_KEY=01c1e176d6ee466c8db717a8
SERVER_HOST=lp.thingsglobal.org
SERVER_PORT=4900
ENABLE_SSL=false
```

### SSL配置示例
```bash
# .env 文件
CLIENT_KEY=01c1e176d6ee466c8db717a8
SERVER_HOST=secure.example.com
SERVER_PORT=4443
ENABLE_SSL=true
CERT_PATH=/app/certs/server.crt
```