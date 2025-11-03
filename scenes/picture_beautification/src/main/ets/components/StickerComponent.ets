import { StickerModel } from '../model/BeautificationParam';

@Component
export struct StickerComponent {
  @ObjectLink item: StickerModel
  @State offsetX: number = 0;
  @State offsetY: number = 0;
  @State borderShow: boolean = false
  private timerId: number = 0
  onDelete?: (id: string) => void; // 删除回调

  aboutToAppear(): void {
    this.clearTimer()
    this.borderShow = true
    this.timerId = setTimeout(() => {
      this.borderShow = false
    }, 2000)
  }

  build() {
    Column() {
      Image(this.item.img)
        .width(100)
        .height(100)
        .objectFit(ImageFit.Contain)
      Image($r('app.media.xmark'))
        .backgroundColor($r('app.color.main_background_color'))
        .width(20)
        .height(20)
        .borderRadius(10)
        .position({ top: -10, right: -10 })
        .opacity(0.5)
        .visibility(this.borderShow ? Visibility.Visible : Visibility.None)
        .onClick(() => {
          if (this.onDelete) {
            this.onDelete(this.item.id)
          }
        })
    }
    .width(100)
    .height(100)
    .translate({ x: this.offsetX, y: this.offsetY, z: 0 })
    .border({
      width: 1,
      color: this.borderShow ? Color.Gray : Color.Transparent,
      style: BorderStyle.Solid
    })
    .animation({
      duration: 300,
      curve: Curve.EaseOut
    })
    .onClick(() => {
      this.clearTimer()
      this.borderShow = true
      this.timerId = setTimeout(() => {
        this.borderShow = false
      }, 2000)
    })
    .gesture(
      PanGesture()
        .onActionUpdate((event: GestureEvent | undefined) => {
          if (event) {
            this.offsetX = this.item.positionX + event.offsetX;
            this.offsetY = this.item.positionY + event.offsetY;
          }
        })
        .onActionEnd(() => {
          this.item.positionX = this.offsetX
          this.item.positionY = this.offsetY
        })
    )
  }

  // 清理定时器
  private clearTimer() {
    if (this.timerId) {
      clearTimeout(this.timerId)
      this.timerId = 0
    }
  }
}