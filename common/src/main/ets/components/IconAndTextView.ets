@Component
export struct IconAndTextView {
  @State imageSource: Resource = $r('app.media.back');
  @State text: string = '';

  build() {
    Column() {
      Image(this.imageSource)
        .width(55)
        .height(55)

      Text(this.text)
        .fontFamily('鸿蒙黑体')
        .fontWeight(FontWeight.Regular)
        .fontSize(14)
        .fontColor($r('sys.color.black'))
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(HorizontalAlign.Center)
  }
}