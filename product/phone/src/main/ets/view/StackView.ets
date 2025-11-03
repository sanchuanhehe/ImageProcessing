import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BeautyParam } from 'picture_beautification';

@Component
export struct StackView {
  @State imageSource: Resource = $r('app.media.icon');
  @State text1: string = '';
  @State text2: string = '';
  @State pageUrl: string = '';
  pathStack: NavPathStack = new NavPathStack();
  maxIamgeCount: number = 0;

  build() {
    Stack() {
      Image(this.imageSource)
        .width('100%')
        .borderRadius(16)
        .height(260)

      Column() {
        Text(this.text1)
          .fontFamily('鸿蒙黑体')
          .fontWeight(FontWeight.Bold)
          .fontSize(26)
          .fontColor($r('sys.color.comp_background_list_card'))
          .margin({ bottom: 6 })

        Text(this.text2)
          .fontFamily('鸿蒙黑体')
          .fontWeight(FontWeight.Medium)
          .fontSize(20)
          .fontColor($r('sys.color.comp_background_list_card'))
          .margin({ bottom: 16 })

        Button('立即体验')
          .width(74)
          .height(28)
          .fontColor($r('sys.color.comp_background_list_card'))
          .backgroundColor('#ED6F21')
          .borderRadius(16)
          .onClick(() => {
            this.choosePicture()
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .padding(16)
    }
    .width('100%')
    .height(260)
  }

  choosePicture() {
    try {
      // 设置图片选择器选项
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = this.maxIamgeCount;
      // 创建并实例化图片选择器
      const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
      // 选择图片并获取图片URI
      photoViewPicker.select(photoSelectOptions).then((result: photoAccessHelper.PhotoSelectResult) => {
        if (result.photoUris.length > 0) {
          let param: BeautyParam = {
            uris: result.photoUris,
            barIndex: -1
          }
          this.pathStack.pushPath({ name: this.pageUrl, param: param })
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