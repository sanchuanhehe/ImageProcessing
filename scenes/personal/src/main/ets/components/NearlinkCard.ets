import { CustomContentDialog } from '@kit.ArkUI';

@Component
export struct NearlinkCard {
  @StorageLink('loginState') loginState: boolean = false;
  @StorageLink('isVip') isVip: boolean = false
  pathStack: NavPathStack = new NavPathStack();

  build() {
    Row() {
      Column() {
        Text('点击传图')
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
    .width('100%')
    .height(72)
    .padding(12)
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .onClick(() => {
      if (!this.loginState) {
        this.pathStack.pushPath({ name: 'nearlinkPage' })
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