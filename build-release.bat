@echo off
setlocal EnableDelayedExpansion

:: 设置版本号（使用当前日期）
for /f "tokens=1-3 delims=/" %%a in ('echo %date%') do (
    set VERSION=%%c%%a%%b
)

:: 初始化go mod
if not exist go.mod (
    echo Initializing go module...
    go mod init lanproxy-go-client
    go mod tidy
)

:: 设置编译参数
set LDFLAGS=-X lanproxy-go-client/src/main.VERSION=%VERSION% -s -w
set GCFLAGS=

:: 检查是否存在UPX
where upx >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set UPX=true
) else (
    set UPX=false
)

:: 创建临时目录
if exist build rd /s /q build
mkdir build
cd build

:: 编译不同平台和架构的版本
set OSES=windows linux darwin freebsd
set ARCHS=amd64 386

for %%o in (%OSES%) do (
    for %%a in (%ARCHS%) do (
        :: 跳过不支持的组合
        if not "%%o"=="darwin" if not "%%a"=="386" (
            set suffix=
            if "%%o"=="windows" set suffix=.exe
            
            set GOOS=%%o
            set GOARCH=%%a
            set CGO_ENABLED=0
            
            echo Building for %%o/%%a...
            go build -o client_%%o_%%a!suffix! ..\src\main
            
            if "%UPX%"=="true" (
                upx -9 client_%%o_%%a!suffix!
            )
            
            :: 创建临时目录用于打包
            mkdir temp_%%o_%%a
            copy client_%%o_%%a!suffix! temp_%%o_%%a\
            tar -czf lanproxy-client-%%o-%%a-%VERSION%.tar.gz -C temp_%%o_%%a client_%%o_%%a!suffix!
            rd /s /q temp_%%o_%%a
            certutil -hashfile lanproxy-client-%%o-%%a-%VERSION%.tar.gz SHA1 > nul
        )
    )
)

:: 编译ARM版本
set ARMS=5 6 7
mkdir temp_arm
for %%v in (%ARMS%) do (
    set GOOS=linux
    set GOARCH=arm
    set GOARM=%%v
    set CGO_ENABLED=0
    
    echo Building for linux/arm%%v...
    go build -o client_linux_arm%%v ..\src\main
    copy client_linux_arm%%v temp_arm\
)

if "%UPX%"=="true" (
    upx -9 client_linux_arm*
)

tar -czf lanproxy-client-linux-arm-%VERSION%.tar.gz -C temp_arm client_linux_arm*
rd /s /q temp_arm
certutil -hashfile lanproxy-client-linux-arm-%VERSION%.tar.gz SHA1 > nul

:: 编译MIPS版本
set GOOS=linux
set GOARCH=mipsle
set CGO_ENABLED=0
echo Building for linux/mipsle...
go build -o client_linux_mipsle ..\src\main

mkdir temp_mips
copy client_linux_mipsle temp_mips\

set GOARCH=mips
echo Building for linux/mips...
go build -o client_linux_mips ..\src\main
copy client_linux_mips temp_mips\

if "%UPX%"=="true" (
    upx -9 client_linux_mips*
)

tar -czf lanproxy-client-linux-mipsle-%VERSION%.tar.gz -C temp_mips client_linux_mipsle
tar -czf lanproxy-client-linux-mips-%VERSION%.tar.gz -C temp_mips client_linux_mips
rd /s /q temp_mips
certutil -hashfile lanproxy-client-linux-mipsle-%VERSION%.tar.gz SHA1 > nul
certutil -hashfile lanproxy-client-linux-mips-%VERSION%.tar.gz SHA1 > nul

:: 清理工作
cd ..
echo Build complete! Check the build directory for output files.

endlocal 