@Component
export struct SettingAndHelpCard {
  pathStack: NavPathStack = new NavPathStack()

  build() {
    Column() {
      Row() {
        Row() {
          Image($r('app.media.setting'))
            .width(16)
            .height(16)
            .margin({ right: 4 })
          Text('设置')
            .fontSize(16)
        }

        Image($r('app.media.forward'))
          .width(13)
          .height(13)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(()=>{
        this.pathStack.pushPath({name:'setting'})
      })

      Divider()
        .margin({ top: 13, bottom: 13 })

      Row() {
        Row() {
          Image($r('app.media.help'))
            .width(16)
            .height(16)
            .margin({ right: 4 })
          Text('帮助与反馈')
            .fontSize(16)
        }

        Image($r('app.media.forward'))
          .width(13)
          .height(13)
      }
      .onClick(()=>{
        this.pathStack.pushPath({name:'help'})
      })
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(12)
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
  }
}