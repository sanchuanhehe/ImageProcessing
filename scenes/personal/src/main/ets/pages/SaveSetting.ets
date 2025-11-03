import { TitleBar } from 'common';

@Component
export struct SaveSettingPage {
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @Prop pathStack: NavPathStack;
  @StorageLink('imageStyle') imageStyle: string = 'jpeg'
  @State imageQuality: string[] = ['高', '中', '低']
  @StorageLink('imageQualityLevel') imageQualityLevel: number = 0

  build() {
    NavDestination() {
      TitleBar({
        pathStack: this.pathStack,
        isBack: true,
        title: '保存设置'
      }).margin({ bottom: 20, left: 16, right: 16 })
      Column() {
        Row() {
          Text('图片格式')
            .fontSize(16)
          Row() {
            Text(this.imageStyle)
              .fontSize(16)
              .margin({ right: 13 })
            Image($r('app.media.forward'))
              .width(13)
              .height(13)
          }
          .onClick(() => {
            TextPickerDialog.show({
              range: ['jpeg', 'png'],
              selected: this.imageStyle === 'jpeg' ? 0 : 1,
              onAccept: (value: TextPickerResult) => {
                this.imageStyle = value.value as string;
                if (value.value === 'png') {
                  this.imageQuality = ['高']
                  this.imageQualityLevel = 0
                } else {
                  this.imageQuality = ['高','中','低']
                }
              },
              canLoop: false
            });
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Divider()
          .margin({ top: 13, bottom: 13 })

        Row() {
          Text('图片质量')
            .fontSize(16)
          Row() {
            Text(this.imageQuality[this.imageQualityLevel])
              .fontSize(16)
              .margin({ right: 13 })
            Image($r('app.media.forward'))
              .width(13)
              .height(13)
          }
          .onClick(() => {
            TextPickerDialog.show({
              range: this.imageQuality,
              selected: this.imageQualityLevel,
              onAccept: (value: TextPickerResult) => {
                this.imageQualityLevel = value.index as number;
              },
              canLoop: false
            });
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .padding(12)
      .borderRadius(16)
      .margin({ left: 16, right: 16 })
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
}