import router from '@ohos.router'
@Entry
@Component
struct Setting_page {
  @State message: string = 'Hello World'

  build() {
    Column(){

      //标题
      Row(){
        Button(){
          Image($r('app.media.chevron_left'))
            .width(24)
            .objectFit(ImageFit.Cover)
        }
        .backgroundColor(Color.Transparent)
        .width(25)
        .height(50)
        .onClick(()=>{
          router.back()
        })


        Text('设置')
          //.backgroundColor(Color.Pink)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .flexGrow(1)
          .height(50)
        Text('')
          .width(25)
      }
      .width('100%')
      .height(60)
      .padding({  right: 10 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      //选项设置
      Column(){
        Button(){
          Row(){
            Text('设置1')
              .fontWeight(FontWeight.Normal)
              .fontSize(20)
          }
          .width('100%')
          .height(50)
          .padding({left:20,right:20})
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
        }
        .backgroundColor('#ffffff')
        .fontColor(Color.Black)

        Button(){
          Row(){
            Text('设置2')
              .fontWeight(FontWeight.Normal)
              .fontSize(20)
          }
          .width('100%')
          .height(50)
          .padding({left:20,right:20})
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
        }
        .backgroundColor('#ffffff')
        .fontColor(Color.Black)
      }
      .margin({top:10})

    }
    .padding({top:20,right:15,left:15,bottom:15})
    .backgroundColor('#f5f5f5')
    .height('100%')
    .width('100%')
  }
}