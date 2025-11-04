import { MockService } from 'common';
import { MainPage } from './MainPage';
import { MinePage } from './Mine';
import { NewPage } from './NewPage';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common, abilityAccessCtrl } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
  struct Index {
  @State currentIndex: number = 0
  pathStack: NavPathStack = new NavPathStack()
  
  // 日志标签
  logTag: string = 'Index';
  domainId: number = 0x0000;

  build() {
    Navigation(this.pathStack) {
      Tabs({ barPosition: BarPosition.End }) {
      TabContent() {
        MainPage({ pathStack: this.pathStack })
      }
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
      .tabBar(this.tabBuilder('首页', 0, $r('app.media.homepage_fill'), $r('app.media.homepage')))

      TabContent() {
        NewPage({ pathStack: this.pathStack })
      }
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
      .tabBar(this.tabBuilder('新页面', 1, $r('app.media.homepage_fill'), $r('app.media.homepage')))

      TabContent() {
        MinePage({ pathStack: this.pathStack })
      }
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
      .tabBar(this.tabBuilder('我的', 2, $r('app.media.mine_fill'), $r('app.media.mine')))
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
      .onAppear(() => {
        // 自动申请 NearLink 权限
        this.requestNearLinkPermission();
      })
  }

  aboutToAppear() {
    hilog.info(this.domainId, this.logTag, `${this.logTag} aboutToAppear`);
    MockService.init()
  }

  /**
   * 申请 NearLink 相关权限
   */
  private requestNearLinkPermission(): void {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    try {
      let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      // 申请 NearLink 访问权限和媒体访问权限
      // 应用首次启动时会弹出权限申请对话框
      atManager.requestPermissionsFromUser(context, [
        'ohos.permission.ACCESS_NEARLINK',
        'ohos.permission.READ_MEDIA',
        'ohos.permission.WRITE_MEDIA'
      ]).then((result) => {
        hilog.info(this.domainId, this.logTag, `Permission request result: ${JSON.stringify(result)}`);
        
        // 检查权限申请结果
        for (let i = 0; i < result.permissions.length; i++) {
          if (result.authResults[i] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
            hilog.info(this.domainId, this.logTag, `Permission granted: ${result.permissions[i]}`);
          } else {
            hilog.warn(this.domainId, this.logTag, `Permission denied: ${result.permissions[i]}`);
          }
        }
      }).catch((error: BusinessError) => {
        hilog.error(this.domainId, this.logTag, 
          `Permission request failed. errCode: ${error.code}, errMessage: ${error.message}`);
      });
    } catch (err) {
      hilog.error(this.domainId, this.logTag,
        `errCode: ${(err as BusinessError).code}, errMessage: ${(err as BusinessError).message}`);
    }
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