import { CollagePartSize, PosterCollagePart, PosterInfo } from '../model/CollageModel';
import { JSON } from '@kit.ArkTS';
import { ImageShow } from './ImageShowComponent';

@Component
export struct PosterCollage {
  @Link @Watch('setImageMap') selectedPoster: PosterInfo;
  @State posterList: PosterInfo[] = []
  @Prop @Watch('setImageMap') imageUris: string[]
  @Prop barIndex: number
  @State imageMap: Map<number, string> = new Map();
  @State imageWidth: number = 0
  @State imageHeight: number = 0
  @State imagePositionX: number = 0
  @State imagePositionY: number = 0

  onDidBuild(): void {
    this.setImageMap()
  }

  setImageMap() {
    for (let i = 0; i < this.selectedPoster.collageParts.length; i++) {
      // 选择图片比模板格子少的时候，循环填充
      this.imageMap.set(i, this.imageUris[i%this.imageUris.length]);
    }
  }

  build() {
    Column() {
      Stack() {
        Image(this.selectedPoster?.posterImage)
          .visibility(this.barIndex === 1 ? Visibility.Visible : Visibility.None)
          .objectFit(ImageFit.Contain)
          .onComplete((event) => {
            if (event?.loadingStatus === 1) {
              this.imageHeight = event!.contentHeight
              this.imageWidth = event!.contentWidth
              this.imagePositionX = event!.contentOffsetX
              this.imagePositionY = event!.contentOffsetY
              this.updateCollageParts()
            }
          })

        ForEach(this.selectedPoster.collageParts, (item: PosterCollagePart, index: number) => {
          CollagePart({
            imageUri: this.imageMap.get(index),
            collagePart: item,
            barIndex: this.barIndex
          })
        }, (item: Resource) => JSON.stringify(item))
      }
      .clip(true)
      .height('90%')
      .width('100%')
    }
  }

  updateCollageParts() {
    this.selectedPoster.collageParts.forEach((item: PosterCollagePart) => {
      // 计算实际位置，去除百分号相乘
      item.collagePositionX = px2vp(this.imagePositionX +
        parseFloat(item.collagePositionX.toString().replace('%', '')) / 100 * this.imageWidth)
      item.collagePositionY = px2vp(this.imagePositionY +
        parseFloat(item.collagePositionY.toString().replace('%', '')) / 100 * this.imageHeight)
      item.collageWidth = px2vp(this.imageWidth * parseFloat(item.collageWidth.toString().replace('%', '')) / 100)
      item.collageHeight = px2vp(this.imageHeight * parseFloat(item.collageHeight.toString().replace('%', '')) / 100)
    })
  }
}

@Component
struct CollagePart {
  @State collageSize: CollagePartSize = new CollagePartSize(0, 0, 1, 0, 0, 1)
  @Prop imageUri: string
  @ObjectLink collagePart: PosterCollagePart
  @Prop @Watch('barIndexChange') barIndex: number

  build() {
    Row() {
      ImageShow({ imageUri: this.imageUri })
    }
    .clip(true)
    .position({ x: this.collagePart.collagePositionX, y: this.collagePart.collagePositionY })
    .width(this.collagePart.collageWidth)
    .height(this.collagePart.collageHeight)
    .borderRadius(this.collagePart.borderRadius)
    .backgroundColor($r('app.color.main_background_color'))
  }

  barIndexChange() {
    this.collageSize = new CollagePartSize(0, 0, 1, 0, 0, 1)
  }
}

