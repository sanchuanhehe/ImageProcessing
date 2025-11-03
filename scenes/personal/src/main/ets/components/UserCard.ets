import { CustomContentDialog } from '@kit.ArkUI';

@Component
export struct UserCard {
  @StorageLink('loginState') loginState: boolean = false;
  @StorageLink('isVip') isVip: boolean = false
  pathStack: NavPathStack = new NavPathStack();
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

  build() {
    Row() {
      Image($r('app.media.avatar_no_login'))
        .width(48)
        .height(48)
        .margin({ right: 12 })
      if (this.loginState) {
        Column() {
          Text('华为用户')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
          Row() {
            Image($r('app.media.connect'))
              .width(12)
              .height(12)
              .margin({ right: 1 })
            Text('解除关联')
              .fontSize(10)
          }
          .justifyContent(FlexAlign.Center)
          .borderRadius(8)
          .width(64)
          .height(16)
          .padding(1)
          .backgroundColor($r('app.color.main_background_color'))
          .onClick(() => {
            this.dialogController.open()
          })
        }
        .height('100%')
        .justifyContent(FlexAlign.SpaceAround)
        .alignItems(HorizontalAlign.Start)

        Column() {
          Row() {
            Image(this.isVip ? $r('app.media.vip') : $r('app.media.no_vip'))
              .width(12)
              .height(12)
              .margin({ right: 1 })
            Text(this.isVip ? '已开通' : '未开通')
              .fontSize(10)
          }
          .width(55)
          .height(16)
          .borderRadius(4)
          .padding(1)
          .backgroundColor($r('app.color.main_background_color'))
        }
        .margin({ top: 8, left: 4 })
        .height('100%')
        .justifyContent(FlexAlign.Start)
      } else {
        Column() {
          Text('点击登录')
            .fontWeight(FontWeight.Medium)
            .fontSize(18)
          Text('登录后享受更多服务')
            .fontWeight(FontWeight.Medium)
            .fontSize(12)
        }
        .height('100%')
        .justifyContent(FlexAlign.SpaceAround)
        .alignItems(HorizontalAlign.Start)
        Blank()
        Column() {
          Image($r('app.media.forward'))
            .width(14)
            .height(14)
        }
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height(72)
    .padding(12)
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .onClick(() => {
      if (!this.loginState) {
        this.pathStack.pushPath({ name: 'quickLoginPage' })
      }
    })
  }

  @Builder
  disConnectContent() {
    Text('请确认是否解除账号关联')
      .width('100%')
      .textAlign(TextAlign.Center)
      .fontSize(14)
  }
}