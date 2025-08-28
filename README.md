###  Lanproxy-go-client
go client for [lanproxy](https://github.com/ffay/lanproxy)

## 🐳 Docker 快速开始（推荐）

### 使用 Docker 运行

```bash
# 直接运行
docker run -d --name lanproxy-client \
  blackhaoke/lanproxy-go-client:latest \
  -k YOUR_CLIENT_KEY \
  -s YOUR_SERVER_HOST \
  -p 4900
```

### 使用 Docker Compose

1. 创建 `docker-compose.yml` 文件：
```yaml
version: '3.8'

services:
  lanproxy-client:
    image: blackhaoke/lanproxy-go-client:latest
    container_name: lanproxy-client
    restart: unless-stopped
    command: [
      "-k", "YOUR_CLIENT_KEY",
      "-s", "YOUR_SERVER_HOST", 
      "-p", "4900"
    ]
```

2. 启动服务：
```bash
docker-compose up -d
```

### 环境变量配置

创建 `.env` 文件：
```bash
CLIENT_KEY=your_client_key_here
SERVER_HOST=your_server_host_here
SERVER_PORT=4900
ENABLE_SSL=false
```

然后使用：
```bash
docker run -d --name lanproxy-client \
  --env-file .env \
  blackhaoke/lanproxy-go-client:latest \
  -k "${CLIENT_KEY}" \
  -s "${SERVER_HOST}" \
  -p "${SERVER_PORT}"
```

### SSL 支持

如果需要使用 SSL 连接：
```bash
docker run -d --name lanproxy-client \
  -v /path/to/your/cert:/app/cert.pem:ro \
  blackhaoke/lanproxy-go-client:latest \
  -k YOUR_CLIENT_KEY \
  -s YOUR_SERVER_HOST \
  -p 4443 \
  --ssl true \
  --cer /app/cert.pem
```

## 📦 传统安装方式

### QuickStart

Download precompiled [Releases](https://github.com/ffay/lanproxy/releases).

```
./client_darwin_amd64 -s SERVER_IP -p SERVER_PORT -k CLIENT_KEY
```
> eg: nohup ./client_darwin_amd64 -s lp.thingsglobal.org -p 4900 -k 01c1e176d6ee466c8db717a8 &

```shell
GLOBAL OPTIONS:
   -k value       client key
   -s value       proxy server host
   -p value       proxy server port (default: 4900)
   --ssl value    enable ssl (default: "false", -p value should be server ssl port)
   --cer value    ssl cert path, default skip verify certificate
   --help, -h     show help
   --version, -v  print the version
```

### Install from source

```
$go get -u github.com/ffay/lanproxy-go-client/src/main
```

All precompiled releases are genereated from `build-release.sh` script.

## 🔧 开发和构建

### 本地构建 Docker 镜像

```bash
# 克隆项目
git clone https://github.com/ffay/lanproxy-go-client.git
cd lanproxy-go-client

# 构建镜像
docker build -t lanproxy-client .

# 运行
docker run -d --name lanproxy-client \
  lanproxy-client \
  -k YOUR_CLIENT_KEY \
  -s YOUR_SERVER_HOST \
  -p 4900
```

### 查看日志

```bash
# Docker 容器日志
docker logs -f lanproxy-client

# Docker Compose 日志
docker-compose logs -f
```

### 停止服务

```bash
# 停止 Docker 容器
docker stop lanproxy-client
docker rm lanproxy-client

# 停止 Docker Compose
docker-compose down
```

## 📋 配置说明

| 参数 | 说明 | 默认值 | 示例 |
|------|------|--------|---------|
| `-k` | 客户端密钥 | - | `01c1e176d6ee466c8db717a8` |
| `-s` | 代理服务器地址 | - | `lp.thingsglobal.org` |
| `-p` | 代理服务器端口 | `4900` | `4900` |
| `--ssl` | 启用SSL | `false` | `true` |
| `--cer` | SSL证书路径 | - | `/path/to/cert.pem` |

## 🐛 故障排除

### 常见问题

1. **连接超时**：检查服务器地址和端口是否正确
2. **认证失败**：确认客户端密钥是否正确
3. **SSL 错误**：检查证书路径和格式

### 获取帮助

```bash
# 查看帮助信息
docker run --rm blackhaoke/lanproxy-go-client:latest -h
```