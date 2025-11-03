@Component
export struct TitleBar {
  @State isBack: boolean = false;
  @Prop title: string
  pathStack: NavPathStack = new NavPathStack();

  build() {
    Row() {
      Image($r('app.media.back'))
        .height(40)
        .width(40)
        .padding(12)
        .margin({ right: 8 })
        .backgroundColor('#E6E8E9')
        .borderRadius(20)
        .visibility(this.isBack ? Visibility.Visible : Visibility.None)
        .onClick(() => {
          this.pathStack.pop()
        })

      Text(this.title)
        .fontFamily('鸿蒙黑体')
        .fontWeight(FontWeight.Medium)
        .fontSize(24)
        .fontColor($r('sys.color.black'))
    }
    .width('100%')
    .height(40)
    .margin({ top: 8 })
  }
}