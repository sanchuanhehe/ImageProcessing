import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { Constants } from '../model/Constants'
import { BeautyToolBar } from './BeautyToolBar'
import { CarouseCutToolBar } from './CarouseCutToolBar'
import { FilterToolBar } from './FilterToolBar'
import { AddTextToolBar } from './AddTextToolBar'
import { BeautyParam, IconAndTextView, ImageShowModel, MyPosition } from 'common'
import { StickerToolBar } from './StickerToolBar'
import { CanvasTextItem, StickerModel } from '../model/BeautificationParam'

@Component
export struct BeautyActionBar {
  pathStack: NavPathStack = new NavPathStack()
  @Link barIndex: number
  @Link imagePixelMap: PixelMap
  @Link cropRatio: number
  @Link clipRect: MyPosition
  @Prop imageArea: MyPosition
  @Link clipRectMaxH: number;
  @Link clipRectMaxW: number;
  @Link carouselCutTabIndex: number
  @Link stickerList: StickerModel[]
  saveImage?: () => void
  saveImageWithText?: () => void
  rotateImage?: (rotate: number) => void
  @Link canvasItemStack: CanvasTextItem
  vipDialogController?: CustomDialogController

  build() {
    Row() {
      this.allToolsBuilder()
      BeautyToolBar({
        barIndex: this.barIndex,
        imagePixelMap: this.imagePixelMap,
        saveImage: this.saveImage,
        pathStack:this.pathStack,
        vipDialogController:this.vipDialogController
      })
        .visibility(this.barIndex === 0 ? Visibility.Visible : Visibility.None)
      CarouseCutToolBar({
        barIndex: this.barIndex,
        cropRatio: this.cropRatio,
        clipRect: this.clipRect,
        imageArea: this.imageArea,
        clipRectMaxH: this.clipRectMaxH,
        clipRectMaxW: this.clipRectMaxW,
        carouselCutTabIndex: this.carouselCutTabIndex,
        saveImage: this.saveImage,
        rotateImage: this.rotateImage,
      })
        .visibility(this.barIndex === 1 ? Visibility.Visible : Visibility.None)
      AddTextToolBar({
        barIndex: this.barIndex,
        canvasItemStack: this.canvasItemStack,
        saveImageWithText: this.saveImageWithText,
      })
        .visibility(this.barIndex === 2 ? Visibility.Visible : Visibility.None)
      FilterToolBar({
        barIndex: this.barIndex,
        imagePixelMap: this.imagePixelMap,
        originImagePixelMap: this.imagePixelMap,
        saveImage: this.saveImage,
        pathStack:this.pathStack,
        vipDialogController:this.vipDialogController
      })
        .visibility(this.barIndex === 3 ? Visibility.Visible : Visibility.None)
      StickerToolBar({
        barIndex: this.barIndex,
        stickerList: this.stickerList,
        saveImage: this.saveImage,
        pathStack: this.pathStack,
        vipDialogController:this.vipDialogController
      })
        .visibility(this.barIndex === 4 ? Visibility.Visible : Visibility.None)
    }
  }

  @Builder
  allToolsBuilder() {
    Row() {
      ForEach(Constants.barList, (item: ImageShowModel, index: number) => {
        IconAndTextView(item)
          .onClick(() => {
            this.barIndex = index
          })
      }, (item: ImageShowModel) => JSON.stringify(item))
    }
    .width('100%')
    .height(75)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .visibility(this.barIndex === -1 ? Visibility.Visible : Visibility.None)
  }

  choosePicture(barIndex: number) {
    try {
      // 设置图片选择器选项
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;
      // 创建并实例化图片选择器
      const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
      // 选择图片并获取图片URI
      photoViewPicker.select(photoSelectOptions).then((result: photoAccessHelper.PhotoSelectResult) => {
        if (result.photoUris.length > 0) {
          let param: BeautyParam = {
            uris: result.photoUris,
            barIndex: barIndex
          }
          this.pathStack.pushPath({ name: 'pictureBeautification', param: param })
        }
      }).catch((err: BusinessError) => {
        console.error(`PhotoViewPicker.select failed with err: ${err.code}, ${err.message}`);
      });
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      console.error(`PhotoViewPicker failed with err: ${err.code}, ${err.message}`);
    }
  }
}