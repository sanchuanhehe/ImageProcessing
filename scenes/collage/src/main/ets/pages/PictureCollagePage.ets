import { BeautyParam, MockService, TitleBar } from 'common';
import { componentSnapshot } from '@kit.ArkUI';
import { PictureCollage } from 'picture_collage';
import { Constants } from '../model/Constants';

@Component
export struct PictureCollagePage {
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @State title: string = '直接拼图'
  @Prop pathStack: NavPathStack;
  originImageUri: string[] = []
  @State barIndex: number = 0
  @StorageProp('loginState') loginState: boolean = false;
  @StorageProp('isVip') isVip: boolean = false
  vipDialogController: CustomDialogController = new CustomDialogController({
    builder: this.toastVipBuilder
  });

  @Builder
  toastVipBuilder() {
    Column({ space: 16 }) {
      Column() {
        Text('当前内容需要开通会员后可体验，')
          .fontSize(14)
        Text('是否立即前往开通会员？')
          .fontSize(14)
      }

      Text('前往开通')
        .fontSize(14)
        .fontColor('#FFAA00')
        .onClick(() => {
          this.vipDialogController.close()
          this.pathStack.pushPath({ name: 'openVip' })
        })
      Text('继续使用')
        .fontSize(14)
        .opacity(0.4)
        .onClick(() => {
          this.vipDialogController.close()
        })
    }
    .padding(16)
    .borderRadius(16)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
  }

  build() {
    NavDestination() {
      TitleBar({
        title: this.title,
        isBack: true,
        pathStack: this.pathStack
      })
        .margin({ bottom: 20, left: 16, right: 16 })
      Row() {
        Row() {
          SaveButton({ text: SaveDescription.SAVE })
            .fontColor($r('sys.color.black'))
            .fontSize(16)
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .onClick(async (_event: ClickEvent, result: SaveButtonOnClickResult) => {
              if (result === SaveButtonOnClickResult.SUCCESS) {
                let pixelMap = componentSnapshot.getSync('PosterCollageContent')
                MockService.saveImage(pixelMap)
              }
            })
        }
        .height(40)
        .width('100%')
        .justifyContent(FlexAlign.End)
      }
      .margin({ bottom: 16, left: 16, right: 16 })

      PictureCollage({
        imageUris: this.originImageUri,
        indexChange: this.getTitle,
        directTemplates: Constants.directTemplates,
        posterList: Constants.posterList,
        templateList: Constants.templateList,
        clickVipCallBack: this.clickVipCallBack,
      })
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx.pathStack
      let param = ctx?.pathInfo?.param as BeautyParam;
      this.originImageUri = param.uris
    })
    .backgroundColor($r('app.color.main_background_color'))
    .padding({
      top: px2vp(this.topRectHeight),
      bottom: 0
    })
  }

  getTitle: (index: number) => void = (index: number) => {
    switch (index) {
      case 0:
        this.title = '直接拼图'
        break;
      case 1:
        this.title = '海报拼图'
        break;
      case 2:
        this.title = '模板拼接'
        break;
      default:
        this.title = '拼图'
        break;
    }
  }
  clickVipCallBack: () => void = () => {
    if (!this.loginState) {
      this.pathStack.pushPath({ name: 'quickLoginPage' })
    } else {
      if (!this.isVip) {
        this.vipDialogController.open()
      }
    }
  }
}
