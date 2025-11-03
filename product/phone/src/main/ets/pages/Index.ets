import { MockService } from 'common';
import { MainPage } from './MainPage';
import { MinePage } from './Mine';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0
  pathStack: NavPathStack = new NavPathStack()

  build() {
    Navigation(this.pathStack) {
      Tabs({ barPosition: BarPosition.End }) {
        TabContent() {
          MainPage({ pathStack: this.pathStack })
        }
        .backgroundColor($r('app.color.main_background_color'))
        .tabBar(this.tabBuilder('首页', 0, $r('app.media.homepage_fill'), $r('app.media.homepage')))

        TabContent() {
          MinePage({ pathStack: this.pathStack })
        }
        .backgroundColor($r('app.color.main_background_color'))
        .tabBar(this.tabBuilder('我的', 1, $r('app.media.mine_fill'), $r('app.media.mine')))
      }
      .barHeight(70)
      .scrollable(false)
      .onChange((index: number) => {
        this.currentIndex = index
      })
    }
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
  }

  aboutToAppear() {
    MockService.init()
  }

  @Builder
  tabBuilder(text: string, targetIndex: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      Image(this.currentIndex === targetIndex ? selectedImg : normalImg)
        .size({ width: 25, height: 25 })

      Text(text)
        .fontFamily('鸿蒙黑体')
        .fontWeight(FontWeight.Regular)
        .fontSize(12)
        .fontColor(this.currentIndex === targetIndex ? '#ED6F21' : '#000000')
        .margin({ top: '2%' })
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
  }

}