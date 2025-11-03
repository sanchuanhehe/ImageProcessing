import { TitleBar } from 'common';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
export const PHONE_REG = /^[1][3,4,5,6,7,8,9][0-9]{9}$/;
@Component
export struct HelpPage {
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @Prop pathStack: NavPathStack;
  @State imageUri?: string = undefined
  @State inputValue: string = ''
  @State inputNumber: string = ''

  build() {
    NavDestination() {
      TitleBar({
        pathStack: this.pathStack,
        isBack: true,
        title: '帮助与反馈'
      }).margin({ bottom: 20, left: 16, right: 16 })
      Column() {
        Text() {
          Span('*')
            .fontSize(12)
            .fontColor('#DB6B42')
          Span('反馈内容')
            .fontSize(16)
            .opacity(0.6)
        }
        .width('100%')
        .margin({ top: 13 })
        .padding({ left: 8 })
        .textAlign(TextAlign.Start)

        TextArea({ placeholder: '请输入详细内容，以便我们更好的理解您的诉求', text: $$this.inputValue })
          .fontSize(14)
          .maxLength(100)
          .margin(12)
          .borderRadius(16)
          .height(162)
          .showCounter(true)
      }
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(16)
      .margin({ left: 16, right: 16, bottom: 16 })

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

      Column() {
        Text() {
          Span('*')
            .fontSize(12)
            .fontColor('#DB6B42')
          Span('联系方式')
            .fontSize(16)
            .opacity(0.6)
        }
        .width('100%')
        .margin({ top: 13 })
        .padding({ left: 8 })
        .textAlign(TextAlign.Start)

        TextInput({ placeholder: '请输入',text: $$this.inputNumber  })
          .fontSize(16)
          .margin(12)
          .borderRadius(0)
          .backgroundColor(Color.White)
          .padding(0)
          .maxLength(11)
          .type(InputType.Number)
        Divider()
          .margin({ left: 12, right: 12, bottom: 12 })
      }
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(16)
      .margin({ left: 16, right: 16, bottom: 107 })

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
        if (!this.inputValue) {
          promptAction.showToast({ message: '请输入反馈内容' })
        } else if (!this.inputNumber) {
          promptAction.showToast({ message: '请输入联系方式' })
        } else if (!PHONE_REG.test(this.inputNumber)) {
          promptAction.showToast({ message: '手机号格式不正确' })
        } else {
          promptAction.showToast({ message: '保存成功' })
          this.pathStack.pop()
        }
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