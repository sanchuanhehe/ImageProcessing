import { TitleBar } from 'common';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { scan } from '@kit.NearLinkKit';
import { SleClientService } from '../services/SleClientService';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { image } from '@kit.ImageKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { dataSharePredicates } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

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
  
  // 图片传输相关状态
  @State selectedImageUri: string = '';
  @State isTransferring: boolean = false;
  @State transferProgress: number = 0;
  
  // SLE 客户端服务
  private sleClientService: SleClientService = SleClientService.getInstance();
  
  // 获取UIAbilityContext
  private getContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext;
  }  // 安全显示 Toast 消息
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

        // 图片传输区域 - 仅在已连接时显示
        if (this.isConnected) {
          this.ImageTransferArea()
        }

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
        
        if (this.isConnected) {
          Button('断开连接')
            .fontSize(12)
            .backgroundColor(Color.Red)
            .fontColor(Color.White)
            .onClick(() => {
              this.disconnectDevice();
            })
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      if (this.connectedDeviceName) {
        Row() {
          Text(`已连接设备: ${this.connectedDeviceName}`)
            .fontSize(12)
            .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
            .margin({ top: 4 })
        }
        .width('100%')
      }
    }
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .padding(12)
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

  @Builder
  ImageTransferArea() {
    Column() {
      Row() {
        Text('图片传输')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Blank()
        Text('仅支持 240×416 尺寸')
          .fontSize(12)
          .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 图片选择区域
      Column() {
        if (this.selectedImageUri) {
          Image(this.selectedImageUri)
            .width(120)
            .height(208) // 保持 240:416 的比例
            .borderRadius(8)
            .objectFit(ImageFit.Contain)
        } else {
          Column() {
            Image($r('app.media.add_image'))
              .width(24)
              .height(24)
            Text('选择图片')
              .fontSize(12)
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .margin({ top: 4 })
            Text('必须为240×416尺寸')
              .fontSize(10)
              .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
              .margin({ top: 2 })
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .width(120)
          .height(208)
          .borderRadius(8)
          .backgroundColor('#E5E5EA')
        }
      }
      .onClick(() => {
        this.choosePicture()
      })

      // 传输进度
      if (this.isTransferring) {
        Column() {
          Text(`传输中... ${Math.round(this.transferProgress)}%`)
            .fontSize(12)
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .margin({ top: 8, bottom: 4 })
          Progress({
            value: this.transferProgress,
            total: 100,
            type: ProgressType.Linear
          })
          .width('100%')
          .height(4)
        }
        .width('100%')
        .margin({ top: 12 })
      }

      // 传输按钮
      if (this.selectedImageUri && !this.isTransferring) {
        Row() {
          Button('发送图片')
            .fontSize(14)
            .backgroundColor(Color.Blue)
            .fontColor(Color.White)
            .onClick(() => {
              this.sendSelectedImage()
            })
          
          Blank()
          
          Button('重新选择')
            .fontSize(14)
            .backgroundColor(Color.Orange)
            .fontColor(Color.White)
            .onClick(() => {
              this.selectedImageUri = ''
            })
        }
        .width('100%')
        .margin({ top: 12 })
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
        // 开始监听连接状态
        this.startConnectionMonitoring();
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

  // 断开连接
  async disconnectDevice(): Promise<void> {
    try {
      this.connectionStatus = '断开中...';
      await this.sleClientService.disconnect();
      this.resetConnectionState();
      this.showToast('已断开连接');
    } catch (error) {
      this.connectionStatus = '断开失败';
      const err = error as BusinessError;
      this.showToast(`断开连接失败: ${err.message}`);
    }
  }

  // 重置连接状态
  private resetConnectionState(): void {
    this.isConnected = false;
    this.connectedDeviceName = '';
    this.connectionStatus = '未连接';
    // 清理传图状态
    this.selectedImageUri = '';
    this.isTransferring = false;
    this.transferProgress = 0;
  }

  // 开始连接状态监听
  private startConnectionMonitoring(): void {
    // 每2秒检查一次连接状态
    const checkConnection = () => {
      if (this.isConnected) {
        const isStillConnected = this.sleClientService.getConnectionState();
        if (!isStillConnected) {
          // 连接意外断开，自动更新状态
          this.resetConnectionState();
          this.showToast('设备连接已断开');
        } else {
          // 继续监听
          setTimeout(checkConnection, 2000);
        }
      }
    };
    setTimeout(checkConnection, 2000);
  }

  // 选择图片
  async choosePicture(): Promise<void> {
    try {
      // 设置图片选择器选项
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;
      
      // 创建并实例化图片选择器
      const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
      
      // 选择图片并获取图片URI
      const result = await photoViewPicker.select(photoSelectOptions);
      if (result.photoUris && result.photoUris.length > 0) {
        const imageUri = result.photoUris[0];
        console.log(`Selected image URI: ${imageUri}`);
        
        // 立即验证图片尺寸
        this.showToast('正在验证图片尺寸...');
        
        const isValid = await this.validateImageSize(imageUri);
        if (isValid) {
          this.selectedImageUri = imageUri;
          this.showToast('图片选择成功');
        } else {
          this.selectedImageUri = '';
          this.showToast('请选择 240×416 尺寸的图片');
        }
      } else {
        this.showToast('未选择任何图片');
      }
    } catch (error) {
      const err = error as BusinessError;
      console.error('Choose picture failed:', err);
      this.showToast(`选择图片失败: ${err.message}`);
    }
  }

  // 验证图片尺寸 - 使用PhotoAccessHelper标准方法
  async validateImageSize(imageUri: string): Promise<boolean> {
    try {
      console.log(`Validating media URI: ${imageUri}`);
      
      // 验证URI是否有效
      if (!imageUri || imageUri.trim() === '') {
        console.error('Invalid image URI: empty or null');
        return false;
      }

      // 方法1: 使用PhotoAccessHelper获取图片信息（推荐方法）
      try {
        const context = this.getContext();
        const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
        const predicates = new dataSharePredicates.DataSharePredicates();
        
        // 配置查询条件，使用PhotoViewPicker返回的uri进行查询
        predicates.equalTo('uri', imageUri);
        
        const fetchOption: photoAccessHelper.FetchOptions = {
          fetchColumns: [
            photoAccessHelper.PhotoKeys.WIDTH, 
            photoAccessHelper.PhotoKeys.HEIGHT,
            photoAccessHelper.PhotoKeys.DISPLAY_NAME
          ],
          predicates: predicates
        };
        
        const fetchResult = await phAccessHelper.getAssets(fetchOption);
        const asset = await fetchResult.getFirstObject();
        
        if (asset) {
          const width = asset.get(photoAccessHelper.PhotoKeys.WIDTH) as number;
          const height = asset.get(photoAccessHelper.PhotoKeys.HEIGHT) as number;
          const displayName = asset.get(photoAccessHelper.PhotoKeys.DISPLAY_NAME) as string;
          const isValidSize = width === 240 && height === 416;
          
          console.log(`PhotoAccessHelper - Image: ${displayName}, Size: ${width}x${height}, Required: 240x416, Valid: ${isValidSize}`);
          
          if (!isValidSize) {
            console.warn(`Size mismatch: expected 240x416, got ${width}x${height}`);
          }
          
          // 关闭fetchResult
          fetchResult.close();
          
          return isValidSize;
        } else {
          console.error('Failed to get PhotoAsset from URI');
        }
        
        // 关闭fetchResult
        fetchResult.close();
      } catch (photoAccessError) {
        console.warn('PhotoAccessHelper method failed, trying fallback method:', photoAccessError);
      }

      // 方法2: 直接使用ImageSource作为备用方法
      try {
        const imageSource = image.createImageSource(imageUri);
        if (imageSource) {
          const imageInfo = await imageSource.getImageInfo();
          if (imageInfo && imageInfo.size) {
            const width = imageInfo.size.width;
            const height = imageInfo.size.height;
            const isValidSize = width === 240 && height === 416;
            
            console.log(`Fallback ImageSource - Size: ${width}x${height}, Required: 240x416, Valid: ${isValidSize}`);
            
            if (!isValidSize) {
              console.warn(`Size mismatch: expected 240x416, got ${width}x${height}`);
            }
            
            return isValidSize;
          }
        }
      } catch (imageSourceError) {
        console.error('ImageSource fallback method failed:', imageSourceError);
      }

      console.error('All validation methods failed');
      return false;
    } catch (error) {
      console.error('Validate image size failed:', error);
      return false;
    }
  }

  // 发送选中的图片
  async sendSelectedImage(): Promise<void> {
    if (!this.selectedImageUri || !this.isConnected) {
      this.showToast('无法发送图片');
      return;
    }

    try {
      this.isTransferring = true;
      this.transferProgress = 0;
      
      // 发送前再次验证图片尺寸
      const isValid = await this.validateImageSize(this.selectedImageUri);
      if (!isValid) {
        this.showToast('图片尺寸不符合要求（需要240×416）');
        this.selectedImageUri = ''; // 清空不合格的图片
        return;
      }
      
      // 获取图片数据
      const imageData = await this.getImageArrayBuffer(this.selectedImageUri);
      
      // 发送图片数据，带进度回调
      const success = await this.sleClientService.sendImageData(
        imageData,
        (sent: number, total: number) => {
          this.transferProgress = (sent / total) * 100;
        }
      );
      
      if (success) {
        this.showToast('图片传输成功');
        this.selectedImageUri = ''; // 清空已选择的图片
      } else {
        this.showToast('图片传输失败');
      }
    } catch (error) {
      const err = error as BusinessError;
      this.showToast(`传输失败: ${err.message}`);
    } finally {
      this.isTransferring = false;
      this.transferProgress = 0;
    }
  }

  // 获取图片的ArrayBuffer数据 - 使用PhotoAccessHelper标准方法
  async getImageArrayBuffer(imageUri: string): Promise<ArrayBuffer> {
    try {
      console.log(`Getting image data from media URI: ${imageUri}`);
      
      // 验证URI
      if (!imageUri || imageUri.trim() === '') {
        throw new Error('图片URI无效');
      }

      // 方法1: 使用PhotoAccessHelper获取PhotoAsset然后创建PixelMap（推荐方法）
      try {
        const context = this.getContext();
        const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
        const predicates = new dataSharePredicates.DataSharePredicates();
        
        predicates.equalTo('uri', imageUri);
        
        const fetchOption: photoAccessHelper.FetchOptions = {
          fetchColumns: [
            photoAccessHelper.PhotoKeys.WIDTH, 
            photoAccessHelper.PhotoKeys.HEIGHT
          ],
          predicates: predicates
        };
        
        const fetchResult = await phAccessHelper.getAssets(fetchOption);
        const asset = await fetchResult.getFirstObject();
        
        if (asset) {
          console.log(`PhotoAccessHelper - Getting pixel data for: ${asset.displayName}`);
          
          // 使用PhotoAsset创建ImageSource
          const imageSource = image.createImageSource(asset.uri);
          if (imageSource) {
            const pixelMap = await imageSource.createPixelMap();
            if (pixelMap) {
              const imageInfo = await pixelMap.getImageInfo();
              if (imageInfo && imageInfo.size) {
                const width = imageInfo.size.width;
                const height = imageInfo.size.height;
                
                console.log(`PhotoAccessHelper - Image size: ${width}x${height}`);
                
                const rowDataSize = width * 4; // RGBA，每像素4字节
                const bufferSize = rowDataSize * height;
                const buffer = new ArrayBuffer(bufferSize);
                await pixelMap.readPixelsToBuffer(buffer);
                
                // 关闭资源
                fetchResult.close();
                
                console.log(`PhotoAccessHelper - Successfully read ${buffer.byteLength} bytes`);
                return buffer;
              }
            }
          }
        }
        
        // 确保关闭fetchResult
        fetchResult.close();
      } catch (photoAccessError) {
        console.warn('PhotoAccessHelper method failed, trying fallback:', photoAccessError);
      }

      // 方法2: 直接使用URI创建ImageSource作为备用方法
      try {
        console.log('Using fallback ImageSource method...');
        
        const imageSource = image.createImageSource(imageUri);
        if (imageSource) {
          const pixelMap = await imageSource.createPixelMap();
          if (pixelMap) {
            const imageInfo = await pixelMap.getImageInfo();
            if (imageInfo && imageInfo.size) {
              const width = imageInfo.size.width;
              const height = imageInfo.size.height;
              
              console.log(`Fallback - Image size: ${width}x${height}`);
              
              const rowDataSize = width * 4;
              const bufferSize = rowDataSize * height;
              const buffer = new ArrayBuffer(bufferSize);
              await pixelMap.readPixelsToBuffer(buffer);
              
              console.log(`Fallback - Successfully read ${buffer.byteLength} bytes`);
              return buffer;
            }
          }
        }
      } catch (fallbackError) {
        console.error('Fallback method also failed:', fallbackError);
      }

      throw new Error('所有方法都无法读取图片数据');
      
    } catch (error) {
      const err = error as BusinessError;
      console.error('Get image array buffer failed:', err);
      throw new Error(`获取图片数据失败: ${err.message}`);
    }
  }
}