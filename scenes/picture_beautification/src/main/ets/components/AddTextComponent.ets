import { CanvasTextItem } from '../model/BeautificationParam'
import { TextEditDialog } from './TextEditDialog'

@Component
export struct AddTextComponent {
  private panGestureFlag: boolean = false
  @Link canvasItemStack: CanvasTextItem
  private selectedCanvasItem: CanvasTextItem | undefined = undefined
  @Link @Watch('save') saveText: boolean
  // 文本编辑
  private textEditDialogController: CustomDialogController | null = new CustomDialogController({
    builder: TextEditDialog({
      canvasItemStack: this.canvasItemStack,
    }),
    customStyle: true
  })
  saveImage?: () => void

  onDidBuild(): void {
    this.selectedCanvasItem = this.canvasItemStack.clone()
    this.saveText = false
  }

  build() {
    Stack() {
      Text(this.canvasItemStack.text ? this.canvasItemStack.text : '点击输入文字')
        .fontFamily(this.canvasItemStack.font)
        .fontSize(this.canvasItemStack.fontSize)
        .fontColor(this.canvasItemStack.currentColor)
        .opacity(this.canvasItemStack.opacity)
        .fontWeight(this.canvasItemStack.isBold ? FontWeight.Bold : FontWeight.Normal)
        .fontStyle(this.canvasItemStack.isItalics ? FontStyle.Italic : FontStyle.Normal)
        .position({ x: this.canvasItemStack.dx, y: this.canvasItemStack.dy })
        .decoration({
          type: this.canvasItemStack.isUnderline ? TextDecorationType.Underline : TextDecorationType.None,
          color: this.canvasItemStack.currentColor
        })
        .borderColor(this.saveText ? Color.Transparent : Color.Black)
        .borderWidth(2)
        .borderStyle(BorderStyle.Dashed)
        .gesture(
          GestureGroup(GestureMode.Exclusive,
            // 单击
            TapGesture({ count: 1 }).onAction(() => {
              // 弹出文本编辑框
              if (this.textEditDialogController != null) {
                this.textEditDialogController.open()
              }
            }),
            // 滑动
            PanGesture().onActionStart(() => {
              this.panGestureFlag = true;
            })
              .onActionUpdate((event: GestureEvent) => {
                if (event && this.panGestureFlag && this.selectedCanvasItem) {
                  this.canvasItemStack.dx = this.selectedCanvasItem.dx + event.offsetX
                  this.canvasItemStack.dy = this.selectedCanvasItem.dy + event.offsetY
                }
              })
              .onActionEnd((event: GestureEvent) => {
                this.panGestureFlag = false
                if (event && this.selectedCanvasItem) {
                  this.canvasItemStack.dx = this.selectedCanvasItem.dx + event.offsetX
                  this.canvasItemStack.dy = this.selectedCanvasItem.dy + event.offsetY
                  this.selectedCanvasItem.dx = this.selectedCanvasItem.dx + event.offsetX
                  this.selectedCanvasItem.dy = this.selectedCanvasItem.dy + event.offsetY
                }
              })

          )
        )
    }
    .width('100%')
    .height('100%')

  }

  save() {
    if (this.saveText) {
      setTimeout(() => {
        if (this.saveImage) {
          this.saveImage()
        }
        this.saveText = false
        this.canvasItemStack = new CanvasTextItem('#000000', 16, 100, false, false, false, 'Noto', '', 150, 200);
      }, 200)
    }
  }
}