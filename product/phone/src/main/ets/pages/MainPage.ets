import { MyPosition, TitleBar } from 'common';
import { BeautyActionSimplyBar } from 'picture_beautification';
import { StackView } from '../view/StackView';

@Component
export struct MainPage {
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  pathStack: NavPathStack = new NavPathStack()
  @State beautyBarIndex: number = -1
  @State cropRatio: number = 0
  @State clipRect: MyPosition = { x: 0, y: 0 }

  build() {
    Column() {
      // 页面名称
      TitleBar({
        isBack: false,
        title: '首页',
        pathStack: this.pathStack
      }).margin({ bottom: 20 })

      // 图片美化
      StackView({
        imageSource: $r('app.media.picture_beautification'),
        text1: '图片美化',
        text2: '轻松修图，美化配方',
        pageUrl: 'pictureBeautification',
        pathStack: this.pathStack,
        maxIamgeCount: 1,
      })

      // 选项
      BeautyActionSimplyBar({
        pathStack: this.pathStack,
      }).margin({ top: 16, bottom: 16 })

      // 拼图
      StackView({
        imageSource: $r('app.media.collage'),
        text1: '拼图',
        text2: '海量拼图模版',
        pageUrl: 'pictureCollage',
        pathStack: this.pathStack,
        maxIamgeCount: 3,
      })
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
}