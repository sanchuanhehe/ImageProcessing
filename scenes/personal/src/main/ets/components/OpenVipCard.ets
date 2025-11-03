@Component
export struct OpenVipCard {
  pathStack: NavPathStack = new NavPathStack()
  @StorageLink('loginState') loginState: boolean = false;
  @StorageLink('isVip') isVip: boolean = false;

  build() {
    Row() {
      Column() {
        if (this.isVip) {
          Row(){
            Text('请查看您的会员权益')
              .fontSize(18)
          }
          .height('100%')
          .alignItems(VerticalAlign.Center)
        } else {
          Row() {
            Text('会员')
              .fontSize(18)
            Image($r('app.media.vip'))
              .width(16)
              .height(16)
              .margin(4)
            Text('订阅')
              .fontSize(18)
          }

          Text('现在订阅低至0.8元/天')
            .fontSize(12)
        }
      }
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(HorizontalAlign.Start)

      Button(this.isVip ? '会员中心' : '现在开通')
        .fontColor($r('sys.color.font_on_primary'))
        .fontSize($r('sys.float.Body_M'))
        .height(28)
        .backgroundColor('#ED6F21')
        .onClick(() => {
          if (!this.loginState) {
            this.pathStack.pushPath({ name: 'quickLoginPage' })
          } else {
            this.pathStack.pushPath({ name: 'openVip' })
          }
        })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundImage($r('app.media.open_vip_background'))
    .backgroundImageSize({ width: '120%', height: '100%' })
    .width('100%')
    .height(72)
    .padding(12)
    .borderRadius(16)
  }
}