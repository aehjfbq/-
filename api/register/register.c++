#include <iostream>
#include <cstdlib>
#include <cstring>
#include <string>
#include <fcgi_stdio.h>
#include <sstream>
#include<mysql/mysql.h>
#include<jsoncpp/json/json.h>
using namespace std;
string tables="users";//数据库表
Json::Value responseData;//返回json数据

string getmpostdata(){

    // 获取 POST 数据
    char* contentLength = getenv("CONTENT_LENGTH");
    int len, i, ch;
    // 动态分配内存来存储 POST 请求数据
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
                printf("Error: Not enough bytes received on standard input<p>\n");
                break;
            }
            // 输出字符值和字符的类型
            result+=static_cast<char>(ch);
            //putchar(ch);  // 将字符输出到响应流
        }
        result+="\0";
    }
    return result;
}

void parsepostdata(string postData){
        
    MYSQL *conn;// MySQL 连接句柄
    
    // 初始化 MySQL 连接
    conn = mysql_init(NULL);
    if (conn == NULL) {
        responseData["status"] = 0;
        responseData["message"] = "Error: mysql_init() failed";
        return ;
    }
    // 连接到 MySQL 数据库
    if (mysql_real_connect(conn, "127.0.0.1", "root", "sakura123", "user", 0, NULL, 0) == NULL) {
        responseData["status"] = 0;
        responseData["message"]="mysql_real_connect() failed";
        mysql_close(conn);
        return ;
    }
    
    // 解析 JSON 数据
    Json::Reader reader;
    Json::Value root;
    if (!reader.parse(postData, root)) {
        responseData["status"] = 0;
        responseData["message"]="Failed to parse JSON data";
        return ;
    }

    // 从 JSON 中获取字段
    std::string username = root["username"].asString();
    std::string account = root["account"].asString();
    std::string password = root["password"].asString();
    std::string gender = root["gender"].asString();

    // 构造 SQL 插入语句
    std::string insertQuery = "INSERT INTO users (username, account, password, gender) "
                                "VALUES ('" + username + "', '" + account + "', '" + password + "', '" + gender + "')";

    // 执行插入 SQL
    if (mysql_query(conn, insertQuery.c_str())) {
        responseData["status"] = 0;
        responseData["message"]="Failed to register Account";
        return ;
    }
    responseData["status"] = 1;
    responseData["message"]="Registration successful!";
}
int main() {
    // FastCGI 处理请求
    while (FCGI_Accept() >= 0) {
        string resdata=getmpostdata();
        parsepostdata(resdata);
        printf("Content-type: application/json; charset=utf-8\r\n\r\n");
        printf("%s",responseData.toStyledString().c_str());
    }
    return 0;
}
