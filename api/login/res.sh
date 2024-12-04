#!/bin/bash

# 打印当前时间
echo "Starting login service at $(date)"

# 编译 C++ 文件
echo "Compiling login.c++..."
g++ -std=c++17  /var/www/html/api/login/login.c++ -o  /var/www/html/api/login/login.out -lfcgi -lmysqlclient -ljsoncpp -lhiredis -lredis++ -pthread

# 启动 FastCGI 服务
echo "Starting spawn-fcgi..."
spawn-fcgi -a 127.0.0.1 -p 9001 -f /var/www/html/api/login/login.out

# 打印结束时间
echo "Register service started at $(date)"
