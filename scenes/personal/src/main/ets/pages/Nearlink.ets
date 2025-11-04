import { TitleBar } from 'common';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { scan } from '@kit.NearLinkKit';
import { SleClientService } from '../services/SleClientService';

export const PHONE_REG = /^[1][3,4,5,6,7,8,9][0-9]{9}$/;

@Component
export struct NearlinkPage {
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  pathStack: NavPathStack = new NavPathStack();

  // SLE 连接相关状态
  @State scanResults: Array<scan.ScanResults> = [];
  @State isScanning: boolean = false;
  @State isConnected: boolean = false;
  @State connectedDeviceName: string = '';
  @State connectionStatus: string = '未连接';

  // SLE 客户端服务
  private sleClientService: SleClientService = SleClientService.getInstance();

  // 安全显示 Toast 消息
  private showToast(message: string): void {
    try {
      promptAction.showToast({ message: message });
    } catch (error) {
      console.error('Show toast failed:', error);
    }
  }

  async aboutToAppear(): Promise<void> {
    // 初始化 SLE 客户端服务
    await this.sleClientService.initialize();
  }

  aboutToDisappear(): void {
    // 清理资源
    this.sleClientService.destroy();
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          pathStack: this.pathStack,
          isBack: true,
          title: 'NearLink 设备连接'
        }).margin({ bottom: 20, left: 16, right: 16 })

        // 连接状态区域
        this.ConnectionStatusArea()

        // 设备扫描和连接区域
        this.DeviceScanArea()

        Blank()
      }
      .width('100%')
        .height('100%')
    }
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx.pathStack
    })
      .hideTitleBar(true)
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
      .padding({
        top: px2vp(this.topRectHeight),
        bottom: this.bottomRectHeight
      })
  }

  @Builder
  ConnectionStatusArea() {
    Column() {
      Row() {
        Text('连接状态: ')
          .fontSize(14)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        Text(this.connectionStatus)
          .fontSize(14)
          .fontColor(this.isConnected ? Color.Green : Color.Red)
        Blank()
        Text(this.connectedDeviceName)
          .fontSize(12)
          .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
      }
      .width('100%')
        .padding(12)
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(16)
      .margin({ left: 16, right: 16, bottom: 16 })
  }

  @Builder
  DeviceScanArea() {
    Column() {
      Row() {
        Text('设备扫描')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Blank()
        Button(this.isScanning ? '停止扫描' : '开始扫描')
          .fontSize(12)
          .backgroundColor(this.isScanning ? Color.Red : Color.Blue)
          .onClick(() => {
            if (this.isScanning) {
              this.stopScan();
            } else {
              this.startScan();
            }
          })
      }
      .width('100%')
        .margin({ bottom: 12 })

      if (this.scanResults.length > 0) {
        List() {
          ForEach(this.scanResults, (item: scan.ScanResults) => {
            ListItem() {
              Row() {
                Column() {
                  Text(item.deviceName || '未知设备')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                  Text(`地址: ${item.address}`)
                    .fontSize(12)
                    .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                }
                .alignItems(HorizontalAlign.Start)
                Blank()
                Button('连接')
                  .fontSize(12)
                  .onClick(() => {
                    this.connectToDevice(item.address, item.deviceName || '未知设备');
                  })
              }
              .width('100%')
                .padding(8)
            }
          })
        }
        .height(120)
          .borderRadius(8)
          .backgroundColor($r('sys.color.ohos_id_color_background'))
      } else if (this.isScanning) {
        Text('正在扫描设备...')
          .fontSize(12)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .textAlign(TextAlign.Center)
          .width('100%')
          .height(40)
      }
    }
    .alignItems(HorizontalAlign.Start)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(16)
      .padding(12)
      .margin({ left: 16, right: 16, bottom: 16 })
  }





  // 开始扫描设备
  async startScan(): Promise<void> {
    try {
      this.isScanning = true;
      this.scanResults = [];
      await this.sleClientService.startScan();

      // 定期更新扫描结果
      const updateResults = () => {
        if (this.isScanning) {
          this.scanResults = this.sleClientService.getScanResults();
          setTimeout(updateResults, 1000);
        }
      };
      updateResults();

      try {
        promptAction.showToast({ message: '开始扫描设备' });
      } catch (e) { }
    } catch (error) {
      this.isScanning = false;
      const err = error as BusinessError;
      this.showToast(`扫描失败: ${err.message}`);
    }
  }

  // 停止扫描设备
  async stopScan(): Promise<void> {
    try {
      this.isScanning = false;
      await this.sleClientService.stopScan();
      this.showToast('停止扫描');
    } catch (error) {
      const err = error as BusinessError;
      this.showToast(`停止扫描失败: ${err.message}`);
    }
  }

  // 连接到指定设备
  async connectToDevice(address: string, deviceName: string): Promise<void> {
    try {
      this.connectionStatus = '连接中...';
      await this.stopScan(); // 连接前停止扫描

      const success = await this.sleClientService.connectToDevice(address);
      if (success) {
        this.isConnected = true;
        this.connectedDeviceName = deviceName;
        this.connectionStatus = '已连接';
        this.showToast(`连接到 ${deviceName} 成功`);
      } else {
        this.connectionStatus = '连接失败';
        this.showToast('连接设备失败');
      }
    } catch (error) {
      this.connectionStatus = '连接失败';
      const err = error as BusinessError;
      this.showToast(`连接失败: ${err.message}`);
    }
  }
}