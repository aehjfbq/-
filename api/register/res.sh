#!/bin/bash

# 打印当前时间
echo "Starting register service at $(date)"

# 编译 C++ 文件
echo "Compiling register.c++..."
g++ /var/www/html/api/register/register.c++ -o /var/www/html/api/register/register.out -lfcgi -lmysqlclient -ljsoncpp 

# 启动 FastCGI 服务
echo "Starting spawn-fcgi..."
spawn-fcgi -a 127.0.0.1 -p 9002 -f /var/www/html/api/register/register.out

# 打印结束时间
echo "Register service started at $(date)"
