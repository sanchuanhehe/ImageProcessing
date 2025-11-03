import { CollagePartSize } from '../model/CollageModel';

@Component
export struct ImageShow {
  @Prop imageUri: string
  @State collageSize: CollagePartSize = new CollagePartSize(0, 0, 1, 0, 0, 1)
  @State imageHeight: Length = 100
  @State imageWidth: Length = 100
  @State showWidth: Length = 100 // 展示区域宽度
  @State showHeight: Length = 100 // 展示区域高度

  build() {
    Column() {
      Image(this.imageUri)
        .objectFit(ImageFit.Contain)
        .width(this.imageWidth)
        .height(this.imageHeight)
        .onComplete((event) => {
          if (event?.loadingStatus === 1) {
            this.updateImageSize(event.contentWidth, event.contentHeight)
          }
        })
        .offset({ x: this.collageSize.offsetX, y: this.collageSize.offsetY })
        .scale({ x: this.collageSize.scale, y: this.collageSize.scale, z: 1 })
    }
    .width('100%')
    .height('100%')
    .onAreaChange((_oldValue: Area, newValue: Area) => {
      this.showWidth = newValue.width
      this.showHeight = newValue.height
    })
    .gesture(
      GestureGroup(GestureMode.Exclusive,
        PanGesture()
          .onActionUpdate((event?: GestureEvent) => {
            if (event) {
              this.collageSize.offsetX = this.collageSize.offsetStartX + event.offsetX
              this.collageSize.offsetY = this.collageSize.offsetStartY + event.offsetY
            }
          })
          .onActionEnd(() => {
            this.collageSize.offsetStartX = this.collageSize.offsetX
            this.collageSize.offsetStartY = this.collageSize.offsetY
          }),
        PinchGesture()
          .onActionUpdate((event: GestureEvent) => {
            this.collageSize.scale = this.collageSize.scaleStart * event.scale
          })
          .onActionEnd(() => {
            this.collageSize.scaleStart = this.collageSize.scale
          })
      )
    )
    .justifyContent(FlexAlign.Start)
  }

  updateImageSize(originWidth: number, originHeight: number) {
    if (this.showHeight > this.showWidth) {
      this.imageWidth = this.showHeight as number * 1.5  * originWidth / originHeight
      this.imageHeight = this.imageWidth / originWidth * originHeight
    } else {
      this.imageHeight = this.showWidth as number * 1.5  * originHeight / originWidth
      this.imageWidth = this.imageHeight / originHeight * originWidth
    }
  }
}