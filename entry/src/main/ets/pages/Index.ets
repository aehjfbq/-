import router from '@ohos.router'
import {content,contentdata,message,local_contentdata} from "../utils/getmessage";
import {AudioRecorderDemo} from "../utils/input_voice"
import {premission} from  "../utils/premission"
import common from '@ohos.app.ability.common';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import {AVPlayerDemo} from  "../utils/output_voice";
import {voice_tomessage} from "../utils/getmessage"
@Entry
@Component
struct Index {
  //状态栏避让高度
  @StorageProp("topRectHeight")
  topRectHeight: number = 0
  //键盘避让高度
  @StorageProp("keyboardHeight")
  keyboardHeight: number = 0
  @State local_message_mange:local_contentdata=new local_contentdata();
  @State page_init:boolean=true;//初始化页面
  @State input_message:string='';//输入栏输入信息
  @State show_voice: boolean = false//切换语音输入
  @State sideBarVisible: boolean = false; // 控制侧边栏显示状态
  @State current_page:number=0;//当前加载聊天记录
  @State show_local_message:boolean=true;//显示历史聊天页面
  output_message:string='';//输出信息
  inpput_voice:string='';//语言输入信息
  input_voi:AudioRecorderDemo=new AudioRecorderDemo();//录音模块类
  output_voi:AVPlayerDemo=new AVPlayerDemo();//播放模块类
  //创建访问控制模块对象。
  atManager = abilityAccessCtrl.createAtManager();
  //获取一个上下文对象
  context = getContext(this) as common.UIAbilityContext;

  build() {
    SideBarContainer(SideBarContainerType.Overlay) {
      // 侧边栏界面
      Column() {
        Column(){
          //返回内容区按钮
          Row(){
            Button(){
              Image($r('app.media.xmark'))
                .height(40)
            }
            .width('10%')
            .margin({right:20})
            .backgroundColor(Color.Transparent)
            .onClick(()=>{
              this.sideBarVisible=false;
            })
          }
          .width('100%')
          .margin({bottom:10})
          .justifyContent(FlexAlign.End)

          //开始新对话
          Button(){
            Row(){
              Image($r('app.media.plus'))
                .width(36)
                .height(36)
                .margin({right:5})
              Text('新对话')
                .layoutWeight(1)
                .height(24)
                .fontSize(24)
                .textAlign(TextAlign.Start)
                .fontWeight(500)
            }
            .alignItems(VerticalAlign.Center)
            .margin(20)
          }
          .width('100%')
          .height('9%')
          .backgroundColor(Color.Transparent)
          .onClick(()=>{
            if(this.page_init==false){
              this.page_init=true;
            }
            this.sideBarVisible = false; // 点击隐藏侧边栏
            //console.log('点击后： ',this.sideBarVisible)
          })
          Divider()
            .strokeWidth(2)
            .margin({top:15,bottom:5})
          //历史对话提示区域
          Row(){
            Image($r('app.media.ellipsis_message'))
              .width(36)
              .height(36)
              .margin({right:5})
            Text('最近对话')
              .layoutWeight(1)
              .height(24)
              .fontSize(24)
              .textAlign(TextAlign.Start)
              .fontWeight(500)

            Button(){
              if(this.show_local_message){
                Image($r('app.media.chevron_down'))
                  .width(36)
                  .height(36)
              }
              else{
                Image($r('app.media.chevron_right'))
                  .width(18)
                  .height(36)
              }
            }
            .backgroundColor(Color.Transparent)
            .margin({right:5})
            .onClick(()=>{
              this.show_local_message=this.show_local_message?false:true;
            })
          }
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.SpaceBetween)
          .padding(20)
          .height('9%')
          .width('100%')

          //历史对话记录
          if(this.show_local_message){
            List(){
              //if(this.index_localpage!=0){this.index_localpage=0;}
              ForEach(this.local_message_mange.local_data,(text:contentdata,index?:number)=>{
                //每行历史对话显示格式
                ListItem(){
                  Button(){
                    Row(){
                      Text(text.data[0].text)
                        .fontSize(20)
                        .fontWeight(500)
                        .layoutWeight(1)
                        .textAlign(TextAlign.Start)
                        .textOverflow({overflow:TextOverflow.Ellipsis})
                        .maxLines(1)
                        .margin({left:20})
                      Image($r('app.media.chevron_right'))
                        .width(18)
                        .margin({left:10,right:30})
                    }
                    .alignItems(VerticalAlign.Center)
                  }
                  .backgroundColor(Color.Transparent)
                  .margin({top:5,bottom:10})
                  .height('5%')
                  .width('100%')
                  .onClick(()=>{
                    this.current_page=index;
                    this.sideBarVisible = false; // 点击隐藏侧边栏
                  })
                }
              })
            }
            .margin({top:5,bottom:10})
          }

        }
        .padding(5)
        .margin({left:5,right:5})
      }
      .backgroundColor("#fcfcfc")

      //主界面
      Column() {
        //标题
        Row(){
          Button(){
            Image($r('app.media.square_grid_2x2'))
              .height(40)
          }
          .width('10%')
          .margin({left:10})
          .backgroundColor(Color.Transparent)
          .onClick(()=>{
           this.sideBarVisible=true;
          })
          Text('原神机器人')
            .height(50)
            .fontStyle(FontStyle.Italic)//斜体
            .fontSize(36)//字体大小
            .fontWeight(700)//字体粗细
            .layoutWeight(1)
            .margin({left:80})
          //.backgroundColor(Color.Gray)

          Button(){
            Image($r('app.media.gearshape'))
              .height(40)
          }
          .width('10%')
          .margin({right:10})
          .backgroundColor(Color.Transparent)
          .onClick(()=>{
            router.pushUrl({
              url:'pages/setting_page'
            })
          })
        }
        .width('100%')
        .margin({top:`${this.keyboardHeight}px`})
        .justifyContent(FlexAlign.SpaceBetween)//水平居中
        .alignItems(VerticalAlign.Center) // 垂直居中
        //.margin({ top: `${this.keyboardHeight}px` })
        
        if(this.page_init){
          Text('Hello World')
            .fontSize(50)
            .fontWeight(FontWeight.Bold)
        }
        else{
          //内容界面
          List() {
            ForEach(this.local_message_mange.local_data[this.current_page].data, (item: content) => {
              ListItem() {
                Row() {
                  Text(item.text)
                    .fontColor(item.name == 'user' ? Color.White : Color.Black)
                    .backgroundColor(item.name == 'user' ? '#1866e4' : '#f4f4f4')
                    .borderRadius(10) //设置边框圆角
                    .fontWeight(FontWeight.Normal)
                    .fontSize(16)
                    .padding(10)
                }
                .width('100%')
                .justifyContent(item.name == 'user' ?FlexAlign.End:FlexAlign.Start )
              }
              .margin({top:5,bottom:10})
              //.borderWidth(2)
              //.borderColor(Color.Gray)
            });
          }
          .margin({left:15,right:15,top:10,bottom:15})
          .layoutWeight(1)
        }
        //输入界面
        Stack({alignContent:Alignment.End}) {
          //默认输入框界面
          if(this.show_voice==false){
            //输入框
            TextInput({ placeholder: "发消息...", text: this.input_message })
              .opacity(1)
              .fontSize(20)
              .width('96%')
              .height(55)
              .margin({ left:'2%', right:'2%',bottom:5})
              .padding({ left: 10, right: 80 })
              .borderColor('#f4f4f4') //边框颜色
              .borderWidth(2) //边框宽度
              .backgroundColor(Color.White) //背景颜色
              .onChange((value: string) => {
                this.input_message = value;
              })
            //有文字时显示发送按钮
            if (this.input_message != ''&&this.show_voice==false) {
              Button() {
                Image($r('app.media.arrow_up_circle_fill'))
                  .width('100%')
                  .height('100%')
                  .objectFit(ImageFit.Cover)
              }
              .height(40)
              .width(40)
              .backgroundColor(Color.Transparent)
              .borderRadius(24) // 圆形按钮
              .margin({ right: 20, bottom: 10 })
              .onClick(async () => {
                if (this.input_message != '') {
                  if(this.page_init){
                    const mes:contentdata=new contentdata([{name:'user',text:this.input_message,islove:false}],0);
                    this.local_message_mange.local_data.push(mes);
                    this.local_message_mange.local_num++;
                    this.current_page=this.local_message_mange.local_num;
                    this.page_init=false;
                  }
                  else{ this.local_message_mange.pushmessage_manage(this.input_message, 'user',this.current_page);}
                  this.output_message= await message(this.input_message);
                  this.local_message_mange.pushmessage_manage(this.output_message, '原神',this.current_page);
                  this.input_message = '';
                  this.output_message = '';
                }
              })
            }
            else {
              //切换语音输入按钮
              Button(){
                Image($r('app.media.mic'))
                  .width('100%')
                  .height('100%')
                  .objectFit(ImageFit.Cover)
              }
              .height(40)
              .width(40)
              .backgroundColor(Color.Transparent)
              .borderRadius(24) // 圆形按钮
              .margin({ right: 20, bottom: 10 })
              .onClick(()=>{
                this.show_voice=true;
              })
            }
          }
          //切换语音输入界面
          else{
            //语音输入按钮
            Button('按住说话')
              .fontSize(20)
              .fontColor(Color.Black)
              .fontWeight(FontWeight.Bold)
              .width('96%')
              .height(55)
              .margin({ left:'2%', right:'2%', bottom:5 })
              .borderColor('#f4f4f4') //边框颜色
              .borderWidth(2) //边框宽度
              .backgroundColor(Color.Transparent) //背景颜色
              .onTouch(async  (event:TouchEvent)=>{
                switch (event.type) {
                  case TouchType.Down:
                    premission(this.atManager,this.context,"ohos.permission.MICROPHONE");
                    await this.input_voi.startRecordingProcess(this.context);
                    break;
                  case TouchType.Up:
                    await this.input_voi.stopRecordingProcess();
                    this.inpput_voice=await voice_tomessage(`${this.context.filesDir}/test_audio.m4a`)
                    if(this.page_init){
                      const mes:contentdata=new contentdata([{name:'user',text:this.inpput_voice,islove:false}],0);
                      this.local_message_mange.local_data.push(mes);
                      this.local_message_mange.local_num++;
                      this.current_page=this.local_message_mange.local_num;
                      this.page_init=false;
                    }
                    else {this.local_message_mange.pushmessage_manage(this.inpput_voice, 'user',this.current_page);}
                    this.output_message= await message(this.inpput_voice);
                    this.local_message_mange.pushmessage_manage(this.output_message, '原神',this.current_page);
                    this.output_message='';
                    break;
                  default:
                    break;
                }
              })

            //切换为文字输入
            Button(){
              Image($r('app.media.input_mode'))
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
            }
            .height(40)
            .width(40)
            .backgroundColor(Color.Transparent)
            .margin({ right: 30 ,bottom:5})
            .onClick(()=>{
              this.show_voice=false;
            })
          }
        }
        .width('100%')
        .height(60)
        .margin({bottom:`${this.topRectHeight}px`})
        .backgroundColor(Color.Transparent)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor(this.sideBarVisible?'#9c9c9c':Color.White);
    }
    .margin({top:`${this.topRectHeight}px`})
    .sideBarWidth('100%') // 侧边栏宽度
    .maxSideBarWidth('50%')
    .showControlButton(false) // 是否显示侧边栏按钮
    .showSideBar(this.sideBarVisible) // 根据状态显示或隐藏侧边栏
    .controlButton({
      top:px2vp(20),
      left:20
    })
    .height('100%');
  }
}