import { CanvasTextItem } from '../model/BeautificationParam'

@CustomDialog
export struct TextEditDialog {
  @Link canvasItemStack: CanvasTextItem
  controller?: CustomDialogController
  textInputController: TextInputController = new TextInputController()

  build() {
    Row() {
      TextInput({placeholder: this.canvasItemStack.text ? '' : '点击输入文字',
        text: $$this.canvasItemStack.text,
        controller: this.textInputController })
        .fontSize(15)
        .backgroundColor(Color.White)
        .layoutWeight(1)
        .borderRadius(5)

      Image($r('app.media.xmark'))
        .width(24)
        .height(24)
        .margin({left: 5})
        .onClick(() => {
          this.controller?.close()
        })
    }
    .width('90%')
    .height(60)
    .borderRadius($r('sys.float.corner_radius_level8'))
    .padding({left: 5, right: 15})
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)

  }
}