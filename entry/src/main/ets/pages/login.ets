// pages/LoginPage.ets
import http from '@ohos.net.http';
import router from '@ohos.router';

interface login_mess{
  message: string,
  status: string,
  token: string
}
interface login_send{
  account: string,
  password: string
}
@Entry
@Component
struct LoginPage {
  @State private account: string = '' // 账号
  @State private password: string = '' // 密码
  @State private message: string = '' // 提示信息

  build() {
    Column({ space: '20vp' }) {
      // 标题
      Text('登录')
        .fontSize(50)
        .fontWeight(FontWeight.Bolder)
        .fontColor(Color.Black)
        .margin({ bottom: 15 })
        .height('10%')

      // 账号输入框
      TextInput({
        placeholder: '请输入账号',
        text: this.account
      })
        .onChange((value: string) => {
          this.account = value;
        })
        .height('6%')
        .backgroundColor(Color.White)
      // 密码输入框
      TextInput({
        placeholder: '请输入密码',
        text: this.password
      })
        .showPasswordIcon(true)
        .type(InputType.Password)
        .onChange((value: string) => {
          this.password = value;
        })
        .height('6%')
        .backgroundColor(Color.White)

      // 登录/注册按钮
      Button('登录')
        .margin({ bottom: 30 })
        .onClick(async () => {
          const res = await this.handleLogin();
          if (res == '1') {
            router.replaceUrl({
              url: 'pages/Index'
            })
          }
          else {
            AlertDialog.show(
              {
                title: '登陆失败',//标题
                message: this.message,//内容
                autoCancel: true,// 自动关闭
                alignment: DialogAlignment.Center,
                gridCount: 3,// 设置按钮布局为 3 列，可影响弹窗中按钮的显示排列方式
                // 确认按钮
                confirm: {
                  value: '关闭',
                  action: () => {
                    this.account='';
                    this.password='';
                    console.info('Button-clicking callback')
                  }
                },
                cancel: () => {
                  this.account='';
                  this.password='';
                  console.info('Closed callbacks')
                }
              }
            )
          }
        })

      // 切换模式的链接
      Text('没有账号？点击注册')
        .fontSize(16)
        .fontColor(Color.Blue)
        .textAlign(TextAlign.Center)
        .onClick(() => {
          router.pushUrl({
            url:'pages/register'
          }
          )
        })
    }
    .backgroundImage($r("app.media.login"))
    .backgroundImageSize(ImageSize.Cover)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .padding(20)
    .width('100%')
    .height('100%')
  }

  // 登录逻辑
  private async handleLogin(): Promise<string> {
    if (this.account.trim() === '' || this.password.trim() === '') {
      this.message = '用户名和密码不能为空！'
      return '01';
    }
    let httpRequest = http.createHttp();
    let url_a: string = 'http://134.175.7.53:8800/api/login';
    const send: login_send = {
      account: this.account,
      password: this.password
    }
    // 使用 Promise 封装异步请求
    return new Promise<string>((resolve) => {
      httpRequest.request(
        url_a, {
        method: http.RequestMethod.POST,
        // 设置请求头为 JSON 格式
        header: { 'Content-Type': 'application/json' },
        // 将请求数据转换为字符串后发送
        extraData: JSON.stringify(send)
      },
        (error, data) => {
          if (error) {
            this.message = '网络错误'
            resolve('02');
          } else {
            if (http.ResponseCode.OK === data.responseCode) {
              try {
                const res: login_mess = JSON.parse(data.result.toString());
                this.message = res.message;
                resolve(res.status); // 成功时返回结果
              } catch (e) {
                this.message = '结果解析错误'
                resolve('03');
              }
            } else {
              this.message = '访问错误'
              resolve('04');
            }
          }
        }
      );
    })
  }
}
