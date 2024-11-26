// import router from '@ohos.router'
// import {content,contentdata,message,local_contentdata} from "../utils/getmessage";
// import {AudioRecorderDemo} from "../utils/input_voice"
// import {premission} from  "../utils/premission"
// import common from '@ohos.app.ability.common';
// import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
// import {AVPlayerDemo} from  "../utils/output_voice";
// import {voice_tomessage} from "../utils/getmessage"
//
// @Entry
// @Component
// struct Index {
//   //状态栏避让高度
//   @StorageProp("topRectHeight")
//   topRectHeight: number = 0
//   //键盘避让高度
//   @StorageProp("keyboardHeight")
//   keyboardHeight: number = 0
//   message_manage: contentdata = new contentdata();//信息管理类
//   @State local_message:local_contentdata=new local_contentdata();
//   @State input_message:string='';//输入栏输入信息
//   @State show_voice: boolean = false//切换语音输入
//   @State page_init:boolean=true;//初始化页面
//   @State local_num:number=-1;//历史消息数
//   input_voi:AudioRecorderDemo=new AudioRecorderDemo();//录音模块类
//   output_voi:AVPlayerDemo=new AVPlayerDemo();//播放模块类
//   //创建访问控制模块对象。
//   atManager = abilityAccessCtrl.createAtManager();
//   //获取一个上下文对象
//   context = getContext(this) as common.UIAbilityContext;
//
//   build() {
//     SideBarContainer(SideBarContainerType.Overlay) {
//       // 侧边栏界面
//       Column() {
//         Text(this.message_manage.num.toString())
//           .width("100%")
//           .fontSize(30)
//           .textAlign(TextAlign.Center);
//         // Text(this.local_message.local_num.toString())
//         //   .width("100%")
//         //   .fontSize(30)
//         //   .textAlign(TextAlign.Center);
//       }
//       .backgroundColor("#aabbcc")
//       //主界面
//       Column() {
//
//         //标题
//         Row(){
//           Text('原神机器人')
//             .height(50)
//             .fontStyle(FontStyle.Italic)//斜体
//             .fontSize(36)//字体大小
//             .fontWeight(700)//字体粗细
//             .layoutWeight(1)
//             .margin({left:80})
//           //.backgroundColor(Color.Gray)
//
//           Button(){
//             Image($r('app.media.gearshape'))
//               .height(40)
//           }
//           .width('10%')
//           .margin({right:10})
//           .backgroundColor(Color.Transparent)
//           .onClick(()=>{
//             router.pushUrl({
//               url:'pages/setting_page'
//             })
//           })
//         }
//         .width('100%')
//         .margin({top:`${this.keyboardHeight}px`})
//         .justifyContent(FlexAlign.Center)//水平居中
//         .alignItems(VerticalAlign.Center) // 垂直居中
//         .backgroundColor(Color.White)
//         //.margin({ top: `${this.keyboardHeight}px` })
//         if(this.page_init){
//           Text('Hello World')
//             .fontSize(50)
//             .fontWeight(FontWeight.Bold)
//         }
//         else{
//           //内容界面
//           List() {
//             ListItem() {
//               Row() {
//                 Text(this.local_message.local_data[this.local_num].data.length.toString())
//                   .fontColor(Color.White )
//                   .backgroundColor( '#1866e4' )
//                   .borderRadius(10) //设置边框圆角
//                   .fontWeight(FontWeight.Normal)
//                   .fontSize(16)
//                   .padding(10)
//               }
//               .width('100%')
//               .justifyContent(FlexAlign.End )
//             }
//             .margin({top:5,bottom:10})
//             ForEach(this.local_message.local_data[this.local_num].data, (item: content) => {
//               ListItem() {
//                 Row() {
//                   Text(item.text)
//                     .fontColor(item.name == 'user' ? Color.White : Color.Black)
//                     .backgroundColor(item.name == 'user' ? '#1866e4' : '#f4f4f4')
//                     .borderRadius(10) //设置边框圆角
//                     .fontWeight(FontWeight.Normal)
//                     .fontSize(16)
//                     .padding(10)
//                 }
//                 .width('100%')
//                 .justifyContent(item.name == 'user' ?FlexAlign.End:FlexAlign.Start )
//               }
//               .margin({top:5,bottom:10})
//               //.borderWidth(2)
//               //.borderColor(Color.Gray)
//
//             });
//           }
//           .margin({left:15,right:15,top:10,bottom:15})
//           .layoutWeight(1)
//         }
//
//         //输入界面
//         Stack({alignContent:Alignment.End}) {
//           //默认输入框界面
//           if(this.show_voice==false){
//             //输入框
//             TextInput({ placeholder: "发消息...", text: this.input_message })
//               .opacity(1)
//               .fontSize(20)
//               .width('96%')
//               .height(55)
//               .margin({ left:'2%', right:'2%',bottom:5})
//               .padding({ left: 10, right: 80 })
//               .borderColor('#f4f4f4') //边框颜色
//               .borderWidth(2) //边框宽度
//               .backgroundColor(Color.White) //背景颜色
//               .onChange((value: string) => {
//                 this.input_message = value;
//               })
//             //有文字时显示发送按钮
//
//             if (this.input_message != ''&&this.show_voice==false) {
//               //发送
//               Button() {
//                 Image($r('app.media.arrow_up_circle_fill'))
//                   .width('100%')
//                   .height('100%')
//                   .objectFit(ImageFit.Cover)
//               }
//               .height(40)
//               .width(40)
//               .backgroundColor(Color.Transparent)
//               .borderRadius(24) // 圆形按钮
//               .margin({ right: 20, bottom: 10 })
//               .onClick( () => {
//                 console.log('page_init: '+this.page_init)
//                 if (this.input_message != '') {
//                   if(this.page_init){
//                     this.local_message.pushmessage(this.message_manage);
//                     this.local_num++;
//                     this.page_init=false;
//                   }
//                   this.local_message.local_data[this.local_num].pushmessage(this.input_message, 'user');
//                   //this.local_message.current_message_num++;
//                   message(this.input_message,this.local_message.local_data[this.local_num]);
//                   this.local_message.current_message_num++;
//                   console.log('current_message: '+this.local_message.current_message_num.toString())
//                   this.input_message = '';
//                 }
//               })
//             }
//             else {
//               //切换语音输入按钮
//               Button(){
//                 Image($r('app.media.mic'))
//                   .width('100%')
//                   .height('100%')
//                   .objectFit(ImageFit.Cover)
//               }
//               .height(40)
//               .width(40)
//               .backgroundColor(Color.Transparent)
//               .borderRadius(24) // 圆形按钮
//               .margin({ right: 20, bottom: 10 })
//               .onClick(()=>{
//                 this.show_voice=true;
//               })
//             }
//           }
//           //切换语音输入界面
//           else{
//             //语音输入按钮
//             Button('按住说话')
//               .fontSize(20)
//               .fontColor(Color.Black)
//               .fontWeight(FontWeight.Bold)
//               .width('96%')
//               .height(55)
//               .margin({ left:'2%', right:'2%', bottom:5 })
//               .borderColor('#f4f4f4') //边框颜色
//               .borderWidth(2) //边框宽度
//               .backgroundColor(Color.Transparent) //背景颜色
//               .onTouch(async  (event:TouchEvent)=>{
//                 switch (event.type) {
//                   case TouchType.Down:
//                     if(this.page_init){
//                       this.local_message.pushmessage(this.message_manage);
//                       this.local_num++;
//                     }
//                     this.page_init=false;
//                     premission(this.atManager,this.context,"ohos.permission.MICROPHONE");
//                     await this.input_voi.startRecordingProcess(this.context);
//                     break;
//                   case TouchType.Up:
//                     await this.input_voi.stopRecordingProcess();
//                     await voice_tomessage(`${this.context.filesDir}/test_audio.m4a`,this.local_message.local_data[this.local_num])
//                     break;
//                   default:
//                     break;
//                 }
//               })
//
//             //切换为文字输入
//             Button(){
//               Image($r('app.media.input_mode'))
//                 .width('100%')
//                 .height('100%')
//                 .objectFit(ImageFit.Cover)
//             }
//             .height(40)
//             .width(40)
//             .backgroundColor(Color.Transparent)
//             .margin({ right: 30 ,bottom:5})
//             .onClick(()=>{
//               this.show_voice=false;
//             })
//           }
//
//         }
//         .width('100%')
//         .height(60)
//         .margin({bottom:`${this.topRectHeight}px`})
//         .backgroundColor(Color.Transparent)
//       }
//       .justifyContent(FlexAlign.SpaceBetween)
//     }
//     .margin({top:`${this.topRectHeight}px`})
//     .sideBarWidth('100%') // 侧边栏宽度
//     .showControlButton(true) // 是否显示侧边栏按钮
//     .showSideBar(false) // 默认是否显示侧边栏
//     .controlButton({
//       top:px2vp(20),
//       left:20
//     })
//     .height('100%');
//
//   }
// }