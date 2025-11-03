import { TitleBar } from 'common';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';

export const PHONE_REG = /^[1][3,4,5,6,7,8,9][0-9]{9}$/;
@Component
export struct NearlinkPage {
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  pathStack: NavPathStack = new NavPathStack();
  @State imageUri?: string = undefined

  build() {
    NavDestination() {
      TitleBar({
        pathStack: this.pathStack,
        isBack: true,
        title: '图片传输'
      }).margin({ bottom: 20, left: 16, right: 16 })

      Column() {
        Text('附加图片/视频')
          .fontSize(16)
          .opacity(0.6)
          .width('100%')
          .textAlign(TextAlign.Start)
          .margin({ bottom: 12 })

        if (this.imageUri) {
          Image(this.imageUri)
            .width(64)
            .height(64)
            .borderRadius(8)
        } else {
          Row() {
            Image($r('app.media.add_image'))
              .width(24)
              .height(24)
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .width(64)
          .height(64)
          .borderRadius(8)
          .backgroundColor('#E5E5EA')
        }
      }
      .alignItems(HorizontalAlign.Start)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(16)
      .padding(12)
      .margin({ left: 16, right: 16, bottom: 16 })
      .onClick(() => {
        this.choosePicture()
      })

      Row() {
        Text('保存')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
          .width('100%')
          .textAlign(TextAlign.Center)
      }
      .height(40)
      .backgroundColor('#ED6F21')
      .margin({ left: 28, right: 28 })
      .borderRadius(20)
      .onClick(() => {

        promptAction.showToast({ message: '保存成功' })
        this.pathStack.pop()

      })
    }
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx.pathStack
    })
    .hideTitleBar(true)
    .backgroundColor($r('app.color.main_background_color'))
    .padding({
      top: px2vp(this.topRectHeight),
      bottom: px2vp(this.bottomRectHeight)
    })
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
          this.imageUri = result.photoUris[0]
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