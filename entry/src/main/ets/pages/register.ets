// pages/LoginPage.ets
import http from '@ohos.net.http';
import router from '@ohos.router';

interface register_mess{
  message: string,
  status: string
}
interface register_send{
  username:string,
  account: string,
  password: string,
  gender:string
}
@Entry
@Component
struct LoginPage {
  @State private username: string = '' // 用户名
  @State private gender: string = '' // 性别
  @State private account: string = '' // 账号
  @State private password: string = '' // 密码
  @State private message: string = '' // 提示信息
  @State select:SelectOption[]=[{value:"Male"},{value:"Female"},{value:"Other"}]
  build() {
    Column({ space: '20vp' }) {
        // 标题
        Text('注册')
          .fontSize(50)
          .fontWeight(FontWeight.Bolder)
          .fontColor(Color.Black)
          .margin({ bottom: 15 })
          .height('10%')
        // 用户名输入框
        TextInput({
          placeholder: '请输入用户名',
        })
          .onChange((value: string) => {
            this.username = value;
          })
          .height('6%')
          .backgroundColor(Color.White)
      //性别输入框
        Row() {
          Select(this.select)
            .value('请选择性别')
            .borderStyle(BorderStyle.Dotted)
            .enabled(true)
            .onSelect((index: number) => {
              this.gender=this.select[index].value.toString();
            })
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')


        // 账号输入框
        TextInput({
          placeholder: '请输入账号',
        })
          .onChange((value: string) => {
            this.account = value;
          })
          .height('6%')
          .backgroundColor(Color.White)
        // 密码输入框
        TextInput({
          placeholder: '请输入密码',
        })
          .showPasswordIcon(true)
          .type(InputType.Password)
          .onChange((value: string) => {
            this.password = value;
          })
          .height('6%')
          .backgroundColor(Color.White)

        // 登录/注册按钮
        Button('确认注册')
          .margin({ bottom: 30 })
        .onClick(async () => {
          const res = await this.handleregister();
          if (res == '1') {
            AlertDialog.show(
              {
                title: '注册成功',//标题
                message: '点击返回登录界面',//内容
                autoCancel: true,// 自动关闭
                alignment: DialogAlignment.Center,
                gridCount: 3,// 设置按钮布局为 3 列，可影响弹窗中按钮的显示排列方式
                // 确认按钮
                confirm: {
                  value: '关闭',
                  action: () => {
                    router.back();
                    console.info('Button-clicking callback')
                  }
                },
                cancel: () => {
                  router.back();
                  console.info('Closed callbacks')
                }
              }
            )
          }
          else {
            AlertDialog.show(
              {
                title: '注册失败',//标题
                message: this.message,//内容
                autoCancel: true,// 自动关闭
                alignment: DialogAlignment.Center,
                gridCount: 3,// 设置按钮布局为 3 列，可影响弹窗中按钮的显示排列方式
                // 确认按钮
                confirm: {
                  value: '关闭',
                  action: () => {
                    console.info('Button-clicking callback')
                  }
                },
                cancel: () => {
                  console.info('Closed callbacks')
                }
              }
            )
          }
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

  //注册逻辑
  private async handleregister(): Promise<string> {
    if (this.gender.trim()==''||this.username.trim()==''|| this.account.trim() === '' || this.password.trim() === '') {
      this.message = '输入项不能为空！'
      return '01';
    }
    let httpRequest = http.createHttp();
    let url_a: string = 'http://134.175.7.53:8800/api/register';
    const send: register_send = {
      username:this.username,
      gender:this.gender,
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
                const res: register_mess = JSON.parse(data.result.toString());
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
