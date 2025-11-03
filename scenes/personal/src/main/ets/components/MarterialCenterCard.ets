import { ImageShowModel } from 'common'
import { Constants } from '../model/Constants'

@Component
export struct MaterialCenterCard {
  build() {
    Column() {
      Row() {
        Text('素材中心')
          .fontSize(16)
        Image($r('app.media.forward'))
          .width(13)
          .height(13)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 14 })

      Row({ space: 12 }) {
        this.materialBuilder(Constants.materialList[0])
        this.materialBuilder(Constants.materialList[1])
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height(166)
    .padding(12)
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
  }

  @Builder
  materialBuilder(showImage: ImageShowModel) {
    Column() {
      Stack() {
        Image(showImage.imageSource)
          .borderRadius(8)
        Image($r('app.media.image_vip'))
          .width(16)
          .height(16)
        Image($r('app.media.download_cloud'))
          .width(24)
          .height(24)
          .position({
            right: 8,
            bottom: 8
          })
      }
      .height(86)
      .alignContent(Alignment.BottomStart)
      .margin({ bottom: 4 })

      Text(showImage.text)
        .fontSize(12)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }
}