#include <iostream>
#include <cstdlib>
#include <cstring>
#include <string>
#include <fcgi_stdio.h>
#include <sstream>
#include <mysql/mysql.h>
#include <jsoncpp/json/json.h>
#include <sw/redis++/redis++.h>  // Redis C++ 客户端

using namespace std;
namespace redis = sw::redis;

// 数据库表
string tables = "users"; 

// 返回 JSON 数据
Json::Value responseData;

// 获取 POST 数据
string getmpostdata() {
    // 获取 POST 数据
    char* contentLength = getenv("CONTENT_LENGTH");
    int len, i, ch;
    std::string result;  // 用于存储读取的数据

    // 获取 Content-Length
    if (contentLength != NULL) {
        len = strtol(contentLength, NULL, 10);  // 将内容长度转换为整数
    } else {
        len = 0;
    }

    if (len <= 0) {
        printf("<p>No data from standard input.<p>\n");
    } 
    else {
        // 逐字节读取输入数据
        for (i = 0; i < len; i++) {
            if ((ch = getchar()) < 0) {
                break;
            }
            result += static_cast<char>(ch);
        }
        result+="\0";
    }
    return result;
}

// 用户认证：查询数据库检查用户名和密码
bool authenticate(const string& account, const string& password) {
    MYSQL *conn;  // MySQL 连接句柄
    MYSQL_RES *res;
    MYSQL_ROW row;

    // 初始化 MySQL 连接
    conn = mysql_init(NULL);
    if (conn == NULL) {
        responseData["status"] = 0;
        responseData["message"] = "Error: mysql_init() failed";
        return false;
    }

    // 连接到 MySQL 数据库
    if (mysql_real_connect(conn, "127.0.0.1", "root", "sakura123", "user", 0, NULL, 0) == NULL) {
        responseData["status"] = 0;
        responseData["message"]="mysql_real_connect() failed";
        mysql_close(conn);
        return false;
    }

    // 构建查询语句，检查用户名是否存在
    std::string query = "SELECT password FROM users WHERE account = '" + account + "' LIMIT 1";
    if (mysql_query(conn, query.c_str())) {
        responseData["status"] = 0;
        responseData["message"]="Failed to find data";
        mysql_close(conn);
        return false;
    }

    // 获取查询结果
    res = mysql_store_result(conn);
    if (res == NULL) {
        responseData["status"] = 0;
        responseData["message"]="Failed to null result";
        mysql_close(conn);
        return false;
    }

    row = mysql_fetch_row(res);
    if (row == NULL) {
        responseData["status"] = 0;
        responseData["message"]="Failed to find Account";
        mysql_free_result(res);
        mysql_close(conn);
        return false;  // 用户名不存在
    }

    std::string dbPassword = row[0];  // 获取数据库中的密码

    // 关闭数据库连接
    mysql_free_result(res);
    mysql_close(conn);

    // 对比用户输入的密码和数据库中的密码
    if (password == dbPassword) {
        return true;  // 密码正确
    }
    responseData["status"] = 0;
        responseData["message"]="Failed to password";
    return false;  // 密码错误
}

// 使用时间戳生成简单的 Token
string generate_token(const string& username) {
    // 使用当前时间戳生成一个简单的 token
    time_t now = time(0);
    string token = username + "_" + to_string(now);  // Token = 用户名 + 时间戳
    return token;
}

// 保存 Token 到 Redis
void store_token_in_redis(const string& token, const string& username, redis::Redis& redis_client) {
    // 保存 token 到 Redis，设置过期时间为 1 小时
    redis_client.set(token, username, std::chrono::hours(6));
}

// 从 Redis 验证 Token 是否有效
bool validate_token_in_redis(const string& token, redis::Redis& redis_client) {
    auto value = redis_client.get(token);
    return value.has_value();  // 如果 token 存在，则验证通过
}

void parse_post_data(string postData) {
    // 解析 JSON 数据
    Json::Reader reader;
    Json::Value root;
    if (!reader.parse(postData, root)) {
        responseData["status"] = 0;
        responseData["message"] = "Failed to parse JSON data";
        return;
    }

    // 从 JSON 中获取字段
    std::string account = root["account"].asString();
    std::string password = root["password"].asString();

    // 认证用户
    if (authenticate(account, password)) {
        // 生成 token
        std::string token = generate_token(account);

        // 创建 Redis 客户端连接
        redis::Redis redis_client("tcp://127.0.0.1:6379");

        // 保存 token 到 Redis
        store_token_in_redis(token, account, redis_client);

        // 返回成功响应及 Token
        responseData["status"] = 1;
        responseData["message"] = "Login successful";
        responseData["token"] = token;
    } 
}

int main() {


    // FastCGI 处理请求
    while (FCGI_Accept() >= 0) {
        string resdata = getmpostdata();  // 获取 POST 数据
        parse_post_data(resdata);  // 处理 POST 数据
        // 输出 JSON 响应
        printf("Content-type: application/json; charset=utf-8\r\n\r\n");
        printf("%s", responseData.toStyledString().c_str());
    }

    return 0;
}
