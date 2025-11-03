import { TitleBar } from 'common';

@Component
export struct TermsPage {
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @Prop pathStack: NavPathStack;

  build() {
    NavDestination() {
      TitleBar({
        pathStack: this.pathStack,
        isBack: true,
        title: '服务条款'
      }).margin({ bottom: 20, left: 16, right: 16 })
      Column() {
        Text('特别提醒：在您（下或称“用户”）开始阅读' +
          '并决定是否接受《美化创意平台服务协议》' +
          '（“本协议”）之前，特别提醒您仔细阅读并留意本协议中内容；' +
          '未成年人用户请在法定监护人陪同下仔细阅读本协议并决定是否接受本协议。' +
          '若您对本协议存在疑问，或者无法全部或者' +
          '部分接受本协议，或者在使用过程中需要向' +
          '美图公司反馈（含建议、投诉、举报等）。')
          .fontSize(16)
          .opacity(0.6)
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