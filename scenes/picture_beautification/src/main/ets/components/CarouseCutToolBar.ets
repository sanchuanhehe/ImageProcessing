import { ImageShowModel, MyPosition } from 'common';
import { Constants } from '../model/Constants';
import { display } from '@kit.ArkUI';

@Component
export struct CarouseCutToolBar {
  @State cutSelectIndex: number = 0;
  @State carouseSelectIndex: number = 0;
  @Link carouselCutTabIndex: number;
  @Link barIndex: number
  private carouselCutController: TabsController = new TabsController();
  tabTitle: string[] = ['裁切', '旋转']
  @Link cropRatio: number
  @Link clipRect: MyPosition
  @Prop imageArea: MyPosition
  @Link clipRectMaxH: number;
  @Link clipRectMaxW: number;
  saveImage?: () => void
  rotateImage?: (rotate: number) => void

  build() {
    Column() {
      Row() {
        Image($r('app.media.xmark'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick(() => {
            this.barIndex = -1
            this.carouselCutTabIndex = 0
            this.carouseSelectIndex = 0
            this.cutSelectIndex = 0
            this.cleanReact()
          })
        Row({ space: 32 }) {
          ForEach(this.tabTitle, (item: string, index: number) => {
            Text(item)
              .fontColor(this.carouselCutTabIndex === index ? '#ED6F21' : Color.Black)
              .fontSize(16)
              .fontWeight(this.carouselCutTabIndex === index ? FontWeight.Medium : FontWeight.Regular)
              .onClick(() => {
                this.carouselCutTabIndex = index
                this.carouselCutController.changeIndex(index);
              })
          }, (item: string) => item)
        }

        Image($r('app.media.checkMark'))
          .width(24)
          .height(24)
          .margin({ right: 16 })
          .onClick(() => {
            if (this.carouselCutTabIndex === 1) {
              this.cleanReact()
            }
            if (this.saveImage) {
              this.saveImage()
            }
            this.carouselCutTabIndex = 0
            this.carouseSelectIndex = 0
            this.cutSelectIndex = 0
          })
      }
      .width('100%')
      .margin({ top: 14 })
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Tabs({ barPosition: BarPosition.Start, controller: this.carouselCutController }) {
          TabContent() {
            Row() {
              ForEach(Constants.cutList, (item: ImageShowModel, index: number) => {
                Column() {
                  Image(item.imageSource)
                    .width(32)
                    .height(32)
                    .objectFit(ImageFit.Contain)
                    .margin({ bottom: 4 })
                    .fillColor(this.cutSelectIndex === index ? '#ED6F21' : Color.Black)

                  Text(item.text)
                    .fontSize(12)
                    .fontColor(this.cutSelectIndex === index ? '#ED6F21' : Color.Black)
                }.onClick(() => {
                  this.cutSelectIndex = index
                  this.cropRatio = this.getCropRatio()
                  this.determineCropType()
                })
              }, (item: ImageShowModel) => JSON.stringify(item))
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%')
          }

          TabContent() {
            Row() {
              ForEach(Constants.carouseList, (item: ImageShowModel, index: number) => {
                Column() {
                  Image(item.imageSource)
                    .width(32)
                    .height(32)
                    .objectFit(ImageFit.Contain)
                    .margin({ bottom: 4 })
                    .fillColor(Color.Black)

                  Text(item.text)
                    .fontSize(12)
                    .fontColor(Color.Black)
                }.onClick(() => {
                  this.carouseSelectIndex = index
                  if (this.rotateImage) {
                    let number = this.getRotate(index)
                    this.rotateImage(number)
                  }
                })
              }, (item: ImageShowModel) => JSON.stringify(item))
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%')
          }
        }
        .barHeight(0)
        .onChange((index: number) => {
          this.carouselCutTabIndex = index
        })
      }
      .height(80)
      .margin({
        top: 24,
        bottom: 20,
        left: 16,
        right: 16
      })
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius({ topLeft: 16, topRight: 16 })
  }

  getRotate(index: number): number {
    switch (index) {
      case 0:
        return -90;
      case 1:
        return 90;
      case 2:
        return 180;
      case 3:
        return 360;
      default:
        return 0
    }
  }

  getCropRatio() {
    let cropRatio = 0
    switch (this.cutSelectIndex) {
      case 0:
        cropRatio = 0;
        break;
      case 1:
        const displayInfo = display.getDefaultDisplaySync();
        const width = displayInfo.width;
        const height = displayInfo.height;
        cropRatio = height / width;
        break;
      case 2:
        cropRatio = 16 / 9;
        break;
      case 3:
        cropRatio = 9 / 16;
        break;
      case 4:
        cropRatio = 1;
        break;
      case 5:
        cropRatio = 2 / 3;
        break;
      case 6:
        cropRatio = 3 / 4;
        break;
      default:
        break
    }
    return cropRatio
  }

  determineCropType() {
    let cropRatio = this.cropRatio
    let imageRatio = (this.imageArea.height!) / this.imageArea.width!
    if (cropRatio === 0) {
      this.clipRectMaxH = this.imageArea.height!
      this.clipRectMaxW = this.imageArea.width!
      this.clipRect = {
        x: Math.round(this.imageArea.x),
        y: Math.round(this.imageArea.y),
        width: Math.round(this.clipRectMaxW),
        height: Math.round(this.clipRectMaxH)
      };
    } else {
      if (this.imageArea.width! > this.imageArea.height!) {
        if (cropRatio < imageRatio) {
          this.clipRectMaxH = this.imageArea.width! * cropRatio
          this.clipRectMaxW = this.imageArea.width!
          this.clipRect = {
            x: Math.round(this.imageArea.x),
            y: Math.round(this.imageArea.y + (this.imageArea.height! - this.imageArea.width! * cropRatio) / 2),
            width: Math.round(this.clipRectMaxW),
            height: Math.round(this.clipRectMaxH)
          };
        } else {
          this.clipRectMaxH = this.imageArea.height!
          this.clipRectMaxW = (this.imageArea.height!) / cropRatio
          this.clipRect = {
            x: Math.round(this.imageArea.x + (this.imageArea.width! - (this.imageArea.height!) / cropRatio) / 2),
            y: Math.round(this.imageArea.y),
            width: Math.round(this.clipRectMaxW),
            height: Math.round(this.clipRectMaxH)
          };
        }

      } else {
        if (cropRatio > 1) {
          this.clipRectMaxH = this.imageArea.height!
          this.clipRectMaxW = (this.imageArea.height!) / cropRatio
          this.clipRect = {
            x: Math.round(this.imageArea.x + (this.imageArea.width! - this.clipRectMaxW) / 2),
            y: Math.round(this.imageArea.y),
            width: Math.round(this.clipRectMaxW),
            height: Math.round(this.clipRectMaxH)
          };
        } else {
          this.clipRectMaxH = this.imageArea.width! * cropRatio
          this.clipRectMaxW = this.imageArea.width!
          this.clipRect = {
            x: Math.round(this.imageArea.x),
            y: Math.round(this.imageArea.y + (this.imageArea.height! - this.clipRectMaxH) / 2),
            width: Math.round(this.clipRectMaxW),
            height: Math.round(this.clipRectMaxH)
          };
        }
      }
    }

    //console.debug('clipRectMaxW='+this.clipRectMaxW+'  clipRectMaxH='+this.clipRectMaxH)

  }

  cleanReact() {
    this.clipRect.x = this.imageArea.x
    this.clipRect.y = this.imageArea.y
    this.clipRect.width = this.imageArea.width
    this.clipRect.height = this.imageArea.height
  }
}