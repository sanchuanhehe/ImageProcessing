import { TitleBar } from 'common';
import { NearlinkCard } from 'personal';
import { promptAction } from '@kit.ArkUI';

@Component
export struct NewPage {
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  pathStack: NavPathStack = new NavPathStack()
  @StorageLink('loginState') loginState: boolean = false;
  @StorageLink('isVip') isVip: boolean = false

  build() {
    Column() {
      // 页面名称
      TitleBar({
        isBack: false,
        title: '后台管理',
        pathStack: this.pathStack
      }).margin({ bottom: 20 })

      NearlinkCard({ pathStack: this.pathStack })
      .margin({ bottom: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('app.color.main_background_color'))
    .padding({
      top: px2vp(this.topRectHeight),
      left: 16,
      right: 16
    })
  }

  showNotOpenToast() {
    try {
      promptAction.showToast({ message: '当前功能暂未实现' })
    } catch (error) {
      console.error('Show toast failed:', error);
    }
  }
}