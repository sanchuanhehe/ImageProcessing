@Component
export struct NewPage {
  pathStack: NavPathStack

  build() {
    Column() {
      Text('新页面内容')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin(20)
    }
    .width('100%')
    .height('100%')
  }
}