import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { Constants } from '../model/Constants'
import { BeautyParam, IconAndTextView, ImageShowModel } from 'common'

@Component
export struct BeautyActionSimplyBar {
  pathStack: NavPathStack = new NavPathStack()
  @State barIndex:number = 0

  build() {
    Row() {
      Row() {
        ForEach(Constants.barList, (item: ImageShowModel, index:number) => {
          IconAndTextView(item)
            .onClick(() => {
              this.choosePicture()
              this.barIndex = index
            })
        }, (item: ImageShowModel) => JSON.stringify(item))
      }
      .width('100%')
      .height(75)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
    }
  }

  choosePicture() {
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
            barIndex: this.barIndex
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