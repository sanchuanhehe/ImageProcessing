import { TitleBar } from 'common';
import { CustomContentDialog } from '@kit.ArkUI';

@Component
export struct SettingPage {
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @Prop pathStack: NavPathStack;
  @StorageLink('loginState') loginState: boolean = true
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: '账号解除关联',
      contentBuilder: () => {
        this.disConnectContent();
      },
      buttons: [
        {
          value: '取消',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
          }
        },
        {
          value: '确定',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            this.loginState = false;
          }
        }
      ],
    }),
  });
  @Builder
  disConnectContent() {
    Text('请确认是否解除账号关联')
      .width('100%')
      .textAlign(TextAlign.Center)
      .fontSize(14)
  }

  build() {
    NavDestination() {
      TitleBar({
        pathStack: this.pathStack,
        isBack: true,
        title: '设置'
      }).margin({ bottom: 20, left: 16, right: 16 })
      Column() {
        Row() {
          Text('账号设置')
            .fontSize(16)
          Row() {
            Text(this.loginState ? '退出账号' : '关联账号')
              .fontSize(16)
              .fontColor('#E84026')
              .margin({ right: 13 })
            Image($r('app.media.forward'))
              .width(13)
              .height(13)
          }.onClick(() => {
            if(this.loginState) {
              this.dialogController.open()
            } else {
              this.pathStack.pushPath({ name: 'quickLoginPage' })
            }
          })

        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Divider()
          .margin({ top: 13, bottom: 13 })

        Row() {
          Text('保存设置')
            .fontSize(16)
          Image($r('app.media.forward'))
            .width(13)
            .height(13)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => {
          this.pathStack.pushPath({ name: 'saveSetting' })
        })

        Divider()
          .margin({ top: 13, bottom: 13 })

        Row() {
          Text('服务条款')
            .fontSize(16)
          Image($r('app.media.forward'))
            .width(13)
            .height(13)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => {
          this.pathStack.pushPath({ name: 'terms' })
        })
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