# 使用官方Go镜像作为构建环境
FROM golang:1.19-alpine AS builder

# 设置工作目录
WORKDIR /app

# 配置Alpine镜像源并安装git（用于获取依赖）
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk add --no-cache git

# 复制源代码
COPY . .

# 设置Go模块代理（可选，用于加速依赖下载）
ENV GOPROXY=https://goproxy.cn,direct

# 初始化Go模块并下载依赖
RUN go mod init lanproxy-go-client && \
    go mod tidy

# 构建应用
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o lanproxy-client ./src/main

# 使用轻量级的alpine镜像作为运行环境
FROM alpine:latest

# 配置Alpine镜像源并安装ca-certificates（用于HTTPS连接）
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk --no-cache add ca-certificates

# 创建非root用户
RUN addgroup -g 1001 -S lanproxy && \
    adduser -S -D -H -u 1001 -h /app -s /sbin/nologin -G lanproxy -g lanproxy lanproxy

# 设置工作目录
WORKDIR /app

# 从构建阶段复制二进制文件
COPY --from=builder /app/lanproxy-client .

# 修改文件权限
RUN chmod +x lanproxy-client

# 切换到非root用户
USER lanproxy

# 暴露端口（如果需要的话）
# EXPOSE 4900

# 设置入口点
ENTRYPOINT ["./lanproxy-client"]

# 默认参数（用户可以覆盖）
CMD ["-h"]