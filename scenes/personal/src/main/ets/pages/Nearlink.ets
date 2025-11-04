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

// 定义颜色接口
interface Color {
  r: number;
  g: number;
  b: number;
}

// 定义权重接口
interface Weight {
  dx: number;
  dy: number;
  weight: number;
}

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
  @State processedImageUri: string = '';
  @State isProcessing: boolean = false;
  @State isTransferring: boolean = false;
  @State transferProgress: number = 0;
  @State processedDataArray: Uint8Array = new Uint8Array();
  
  // SLE 客户端服务
  private sleClientService: SleClientService = SleClientService.getInstance();
  
  // 获取UIAbilityContext
  private getContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext;
  }

  // 4色调色板
  private colors: Color[] = [
    { r: 0, g: 0, b: 0 } as Color,           // 黑色 0x000000 => 0x0
    { r: 255, g: 255, b: 255 } as Color,     // 白色 0xffffff => 0x1
    { r: 255, g: 255, b: 0 } as Color,       // 黄色 0xffff00 => 0x2
    { r: 255, g: 0, b: 0 } as Color,         // 红色 0xff0000 => 0x3
  ];

  // 目标尺寸
  private readonly targetWidth = 240;
  private readonly targetHeight = 416;  // 安全显示 Toast 消息
  private showToast(message: string): void {
    try {
      promptAction.showToast({ message: message });
    } catch (error) {
      console.error('Show toast failed:', error);
    }
  }

  // 验证媒体文件URI格式是否正确
  private isValidMediaUri(uri: string): boolean {
    try {
      // 标准媒体文件URI格式: 'file://media/Photo/<id>/IMG_datetime_0001/displayName.jpg'
      const mediaUriPattern = /^file:\/\/media\/(Photo|Audio)\/\d+\/(IMG|VID|AUD)_\d+_\d+\/.+\.(jpg|jpeg|png|gif|webp|bmp|mp4|mp3|wav)$/i;
      
      // 也接受content://和datashare://格式的URI
      const contentUriPattern = /^(content:\/\/|datashare:\/\/)/i;
      
      return mediaUriPattern.test(uri) || contentUriPattern.test(uri);
    } catch (error) {
      console.error('URI validation failed:', error);
      return false;
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

      // 图片选择和预览区域
      Row() {
        // 原图区域
        Column() {
          Text('原图')
            .fontSize(12)
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .margin({ bottom: 4 })
          
          if (this.selectedImageUri) {
            Image(this.selectedImageUri)
              .width(100)
              .height(173) // 保持 240:416 的比例
              .borderRadius(8)
              .objectFit(ImageFit.Contain)
          } else {
            Column() {
              Image($r('app.media.add_image'))
                .width(20)
                .height(20)
              Text('选择图片')
                .fontSize(10)
                .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                .margin({ top: 4 })
              Text('240×416尺寸')
                .fontSize(8)
                .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                .margin({ top: 2 })
            }
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .width(100)
            .height(173)
            .borderRadius(8)
            .backgroundColor('#E5E5EA')
          }
        }
        .onClick(() => {
          this.choosePicture()
        })

        Blank().width(10)

        // 处理后图片区域
        Column() {
          Text('处理后')
            .fontSize(12)
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .margin({ bottom: 4 })
          
          if (this.processedImageUri) {
            Column() {
              Image($r('app.media.add_image'))
                .width(20)
                .height(20)
                .fillColor(Color.Green)
              Text('处理完成')
                .fontSize(10)
                .fontColor(Color.Green)
                .margin({ top: 4 })
              Text(`${this.processedDataArray.length}字节`)
                .fontSize(8)
                .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                .margin({ top: 2 })
            }
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .width(100)
            .height(173)
            .borderRadius(8)
            .backgroundColor('#E8F5E8')
          } else if (this.isProcessing) {
            Column() {
              LoadingProgress()
                .width(20)
                .height(20)
              Text('处理中...')
                .fontSize(10)
                .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                .margin({ top: 4 })
            }
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .width(100)
            .height(173)
            .borderRadius(8)
            .backgroundColor('#F5F5F5')
          } else {
            Column() {
              Text('待处理')
                .fontSize(10)
                .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
            }
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .width(100)
            .height(173)
            .borderRadius(8)
            .backgroundColor('#F5F5F5')
          }
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

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

      // 操作按钮
      if (this.selectedImageUri && !this.isTransferring) {
        Row() {
          // 处理按钮
          if (!this.processedImageUri && !this.isProcessing) {
            Button('处理图片')
              .fontSize(14)
              .backgroundColor(Color.Green)
              .fontColor(Color.White)
              .onClick(() => {
                this.processSelectedImage()
              })
          }
          
          // 发送按钮 - 只有处理完成后才能发送
          if (this.processedImageUri) {
            Button('发送图片')
              .fontSize(14)
              .backgroundColor(Color.Blue)
              .fontColor(Color.White)
              .onClick(() => {
                this.sendProcessedImage()
              })
          }
          
          Blank()
          
          Button('重新选择')
            .fontSize(14)
            .backgroundColor(Color.Orange)
            .fontColor(Color.White)
            .onClick(() => {
              this.resetImageState()
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
    this.resetImageState();
  }

  // 重置图片状态
  private resetImageState(): void {
    this.selectedImageUri = '';
    this.processedImageUri = '';
    this.isProcessing = false;
    this.isTransferring = false;
    this.transferProgress = 0;
    this.processedDataArray = new Uint8Array();
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
        
        // 使用文档推荐的支持临时授权的PhotoKeys
        const fetchOption: photoAccessHelper.FetchOptions = {
          fetchColumns: [
            photoAccessHelper.PhotoKeys.URI,
            photoAccessHelper.PhotoKeys.WIDTH, 
            photoAccessHelper.PhotoKeys.HEIGHT,
            photoAccessHelper.PhotoKeys.DISPLAY_NAME,
            photoAccessHelper.PhotoKeys.PHOTO_TYPE,
            photoAccessHelper.PhotoKeys.SIZE
          ],
          predicates: predicates
        };
        
        const fetchResult = await phAccessHelper.getAssets(fetchOption);
        const asset = await fetchResult.getFirstObject();
        
        if (asset) {
          const width = asset.get(photoAccessHelper.PhotoKeys.WIDTH) as number;
          const height = asset.get(photoAccessHelper.PhotoKeys.HEIGHT) as number;
          const displayName = asset.get(photoAccessHelper.PhotoKeys.DISPLAY_NAME) as string;
          const photoType = asset.get(photoAccessHelper.PhotoKeys.PHOTO_TYPE) as number;
          const fileSize = asset.get(photoAccessHelper.PhotoKeys.SIZE) as number;
          const isValidSize = width === 240 && height === 416;
          
          console.log(`PhotoAccessHelper - Validation Details:`);
          console.log(`  URI: ${asset.uri}`);
          console.log(`  Display Name: ${displayName}`);
          console.log(`  Size: ${width}x${height}`);
          console.log(`  Photo Type: ${photoType}`);
          console.log(`  File Size: ${fileSize} bytes`);
          console.log(`  Required: 240x416`);
          console.log(`  Valid Size: ${isValidSize}`);
          
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



  // 获取图片的ArrayBuffer数据 - 使用PhotoAccessHelper标准方法
  async getImageArrayBuffer(imageUri: string): Promise<ArrayBuffer> {
    try {
      console.log(`Getting image data from media URI: ${imageUri}`);
      
      // 验证URI格式
      if (!imageUri || imageUri.trim() === '') {
        throw new Error('图片URI无效');
      }
      
      // 验证是否为标准媒体文件URI格式
      if (!this.isValidMediaUri(imageUri)) {
        console.warn(`URI may not be standard media format: ${imageUri}`);
      }

      // 方法1: 使用PhotoAccessHelper获取PhotoAsset然后创建PixelMap（推荐方法）
      try {
        const context = this.getContext();
        const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
        const predicates = new dataSharePredicates.DataSharePredicates();
        
        predicates.equalTo('uri', imageUri);
        
        // 根据文档使用支持临时授权的PhotoKeys
        const fetchOption: photoAccessHelper.FetchOptions = {
          fetchColumns: [
            photoAccessHelper.PhotoKeys.URI,
            photoAccessHelper.PhotoKeys.WIDTH, 
            photoAccessHelper.PhotoKeys.HEIGHT,
            photoAccessHelper.PhotoKeys.DISPLAY_NAME,
            photoAccessHelper.PhotoKeys.SIZE,
            photoAccessHelper.PhotoKeys.PHOTO_TYPE
          ],
          predicates: predicates
        };
        
        const fetchResult = await phAccessHelper.getAssets(fetchOption);
        if (fetchResult && fetchResult.getCount() > 0) {
          const asset = await fetchResult.getFirstObject();
          
          if (asset) {
            console.log(`PhotoAccessHelper - Asset found:`);
            console.log(`  Display Name: ${asset.displayName}`);
            console.log(`  URI: ${asset.uri}`);
            console.log(`  Photo Type: ${asset.photoType}`);
            console.log(`  Width: ${asset.get(photoAccessHelper.PhotoKeys.WIDTH)}`);
            console.log(`  Height: ${asset.get(photoAccessHelper.PhotoKeys.HEIGHT)}`);
            console.log(`  Size: ${asset.get(photoAccessHelper.PhotoKeys.SIZE)} bytes`);
            
            try {
              // 使用PhotoAsset的URI创建ImageSource
              const imageSource = image.createImageSource(asset.uri);
              if (!imageSource) {
                console.error('Failed to create ImageSource from asset URI');
                throw new Error('ImageSource creation failed');
              }
              
              const pixelMap = await imageSource.createPixelMap();
              if (!pixelMap) {
                console.error('Failed to create PixelMap from ImageSource');
                throw new Error('PixelMap creation failed');
              }
              
              const imageInfo = await pixelMap.getImageInfo();
              if (imageInfo && imageInfo.size) {
                const width = imageInfo.size.width;
                const height = imageInfo.size.height;
                
                console.log(`PhotoAccessHelper - Image size: ${width}x${height}`);
                
                const rowDataSize = width * 4; // RGBA，每像素4字节
                const bufferSize = rowDataSize * height;
                const buffer = new ArrayBuffer(bufferSize);
                await pixelMap.readPixelsToBuffer(buffer);
                
                // 释放资源
                pixelMap.release();
                imageSource.release();
                fetchResult.close();
                
                console.log(`PhotoAccessHelper - Successfully read ${buffer.byteLength} bytes`);
                return buffer;
              } else {
                throw new Error('Failed to get image info');
              }
            } catch (processingError) {
              console.error('Error processing asset:', processingError);
              throw processingError;
            }
          } else {
            console.error('No asset found for URI');
            throw new Error('No asset found');
          }
        } else {
          console.error('No fetch result or empty result');
          throw new Error('No fetch result');
        }
        
        // 确保关闭fetchResult
        fetchResult.close();
      } catch (photoAccessError) {
        console.warn('PhotoAccessHelper method failed, trying fallback:', photoAccessError);
      }

      // 方法2: 直接使用URI创建ImageSource作为备用方法
      try {
        console.log('Using fallback ImageSource method...');
        console.log(`Original URI: ${imageUri}`);
        
        // 根据文档，标准媒体URI格式应该是 'file://media/Photo/...'
        let processedUri = imageUri;
        
        // 检查并处理不同格式的URI
        if (imageUri.startsWith('file://media/Photo/') || 
            imageUri.startsWith('file://media/Audio/') ||
            imageUri.startsWith('content://') || 
            imageUri.startsWith('datashare://')) {
          console.log('Using standard media URI format');
          processedUri = imageUri;
        } else if (!imageUri.startsWith('file://')) {
          // 如果不是标准格式，尝试添加file://前缀
          processedUri = imageUri.startsWith('/') ? `file://${imageUri}` : `file:///${imageUri}`;
          console.log(`Converted to file URI: ${processedUri}`);
        }
        
        console.log(`Processing URI: ${processedUri}`);
        
        const imageSource = image.createImageSource(processedUri);
        if (!imageSource) {
          console.error(`Failed to create ImageSource from URI: ${processedUri}`);
          throw new Error('ImageSource creation failed from URI');
        }
        
        console.log('ImageSource created successfully from URI');
        
        const pixelMap = await imageSource.createPixelMap();
        if (!pixelMap) {
          console.error('Failed to create PixelMap from ImageSource');
          throw new Error('PixelMap creation failed from URI');
        }
        
        const imageInfo = await pixelMap.getImageInfo();
        if (imageInfo && imageInfo.size) {
          const width = imageInfo.size.width;
          const height = imageInfo.size.height;
          
          console.log(`Fallback - Image size: ${width}x${height}`);
          
          const rowDataSize = width * 4;
          const bufferSize = rowDataSize * height;
          const buffer = new ArrayBuffer(bufferSize);
          await pixelMap.readPixelsToBuffer(buffer);
          
          // 释放资源
          pixelMap.release();
          imageSource.release();
          
          console.log(`Fallback - Successfully read ${buffer.byteLength} bytes`);
          return buffer;
        } else {
          throw new Error('Failed to get image info from fallback method');
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

  // 处理选中的图片
  async processSelectedImage(): Promise<void> {
    if (!this.selectedImageUri) {
      this.showToast('请先选择图片');
      return;
    }

    try {
      this.isProcessing = true;
      this.showToast('正在处理图片...');

      // 获取原始图片数据 - 添加错误检查
      const imageSource = image.createImageSource(this.selectedImageUri);
      if (!imageSource) {
        throw new Error('无法创建ImageSource');
      }
      
      const pixelMap = await imageSource.createPixelMap();
      if (!pixelMap) {
        throw new Error('无法创建PixelMap');
      }
      
      // 缩放到目标尺寸
      const scaledPixelMap = await this.scalePixelMapToTarget(pixelMap);
      if (!scaledPixelMap) {
        throw new Error('图片缩放失败');
      }
      
      // 获取像素数据
      const imageInfo = await scaledPixelMap.getImageInfo();
      if (!imageInfo || !imageInfo.size) {
        throw new Error('无法获取图片信息');
      }
      
      const bufferSize = imageInfo.size.width * imageInfo.size.height * 4;
      const buffer = new ArrayBuffer(bufferSize);
      await scaledPixelMap.readPixelsToBuffer(buffer);
      
      // 应用Floyd-Steinberg抖动算法
      const processedBuffer = this.applyFloydSteinbergDithering(buffer, imageInfo.size.width, imageInfo.size.height);
      
      // 标记处理完成
      this.markProcessingComplete();
      
      // 生成C数组数据
      this.processedDataArray = this.generateCArrayData(processedBuffer, imageInfo.size.width, imageInfo.size.height);
      
      // 释放资源
      pixelMap.release();
      scaledPixelMap.release();
      imageSource.release();
      
      this.showToast('图片处理完成');
      
    } catch (error) {
      const err = error as BusinessError;
      console.error('Process image failed:', err);
      console.error('Error details:', {
        message: err.message,
        code: err.code,
        name: err.name,
        selectedImageUri: this.selectedImageUri
      });
      
      let errorMessage = '图片处理失败';
      if (err.message && err.message.includes('createPixelMap')) {
        errorMessage = '无法解析图片格式，请选择其他图片';
      } else if (err.message && err.message.includes('ImageSource')) {
        errorMessage = '无法读取图片文件，请检查文件路径';
      } else if (err.message) {
        errorMessage = `处理失败: ${err.message}`;
      }
      
      this.showToast(errorMessage);
    } finally {
      this.isProcessing = false;
    }
  }

  // 缩放PixelMap到目标尺寸
  private async scalePixelMapToTarget(pixelMap: image.PixelMap): Promise<image.PixelMap> {
    try {
      const imageInfo = await pixelMap.getImageInfo();
      if (!imageInfo || !imageInfo.size) {
        throw new Error('无法获取图片信息');
      }
      
      const originalWidth = imageInfo.size.width;
      const originalHeight = imageInfo.size.height;
      
      console.log(`Original size: ${originalWidth}x${originalHeight}, Target: ${this.targetWidth}x${this.targetHeight}`);
      
      // 如果已经是目标尺寸，直接返回副本
      if (originalWidth === this.targetWidth && originalHeight === this.targetHeight) {
        console.log('Image already at target size');
        return pixelMap;
      }
      
      // 直接缩放原PixelMap（scale方法会修改原对象）
      await pixelMap.scale(this.targetWidth, this.targetHeight);
      
      console.log(`Successfully scaled to ${this.targetWidth}x${this.targetHeight}`);
      return pixelMap;
      
    } catch (error) {
      console.error('Scale PixelMap failed:', error);
      throw new Error(`图片缩放失败: ${error}`);
    }
  }

  // Floyd-Steinberg抖动算法
  private applyFloydSteinbergDithering(buffer: ArrayBuffer, width: number, height: number): ArrayBuffer {
    const pixels = new Uint8Array(buffer);
    
    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        const index = (y * width + x) * 4;
        
        // 获取原始像素
        const oldPixel: Color = {
          r: pixels[index],
          g: pixels[index + 1],
          b: pixels[index + 2]
        };
        
        // 找到最接近的颜色
        const newPixel = this.findNearestColor(oldPixel);
        
        // 设置新像素颜色
        pixels[index] = newPixel.r;
        pixels[index + 1] = newPixel.g;
        pixels[index + 2] = newPixel.b;
        pixels[index + 3] = 255; // alpha
        
        // 计算量化误差
        const quantErrorR = oldPixel.r - newPixel.r;
        const quantErrorG = oldPixel.g - newPixel.g;
        const quantErrorB = oldPixel.b - newPixel.b;
        
        // 分发误差到相邻像素
        this.distributeFloydSteinbergError(pixels, width, height, x, y, quantErrorR, quantErrorG, quantErrorB);
      }
    }
    
    return buffer;
  }

  // 找到最接近的颜色
  private findNearestColor(pixel: Color): Color {
    let nearestColor = this.colors[0];
    let minDistance = this.colorDistance(pixel, this.colors[0]);
    
    for (let i = 1; i < this.colors.length; i++) {
      const distance = this.colorDistance(pixel, this.colors[i]);
      if (distance < minDistance) {
        minDistance = distance;
        nearestColor = this.colors[i];
      }
    }
    
    return nearestColor;
  }

  // 计算颜色距离
  private colorDistance(c1: Color, c2: Color): number {
    return Math.sqrt(
      Math.pow(c1.r - c2.r, 2) +
      Math.pow(c1.g - c2.g, 2) +
      Math.pow(c1.b - c2.b, 2)
    );
  }

  // 分发Floyd-Steinberg误差
  private distributeFloydSteinbergError(
    pixels: Uint8Array, 
    width: number, 
    height: number, 
    x: number, 
    y: number, 
    quantErrorR: number, 
    quantErrorG: number, 
    quantErrorB: number
  ): void {
    // Floyd-Steinberg权重
    const weights: Weight[] = [
      { dx: 1, dy: 0, weight: 7 / 16 } as Weight,   // 右
      { dx: -1, dy: 1, weight: 3 / 16 } as Weight,  // 左下
      { dx: 0, dy: 1, weight: 5 / 16 } as Weight,   // 下
      { dx: 1, dy: 1, weight: 1 / 16 } as Weight    // 右下
    ];

    weights.forEach((w: Weight) => {
      const dx = w.dx;
      const dy = w.dy;
      const weight = w.weight;
      const nx = x + dx;
      const ny = y + dy;
      
      if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
        const index = (ny * width + nx) * 4;
        pixels[index] = this.clamp(pixels[index] + quantErrorR * weight);
        pixels[index + 1] = this.clamp(pixels[index + 1] + quantErrorG * weight);
        pixels[index + 2] = this.clamp(pixels[index + 2] + quantErrorB * weight);
      }
    });
  }

  // 限制值在0-255范围内
  private clamp(value: number): number {
    return Math.max(0, Math.min(255, value));
  }

  // 从buffer创建PixelMap（简化版）
  private async createPixelMapFromBuffer(buffer: ArrayBuffer, width: number, height: number): Promise<image.PixelMap> {
    try {
      // 创建一个简单的PixelMap
      const options: image.InitializationOptions = {
        size: { width: width, height: height },
        pixelFormat: image.PixelMapFormat.RGBA_8888,
        editable: true
      };
      
      const pixelMap = await image.createPixelMap(buffer, options);
      return pixelMap;
    } catch (error) {
      console.error('Create PixelMap from buffer failed:', error);
      throw new Error(`Create PixelMap from buffer failed: ${error}`);
    }
  }

  // 将处理后的数据标记为已完成（简化实现）
  private markProcessingComplete(): void {
    // 生成一个唯一标识表示处理完成
    this.processedImageUri = `processed_${Date.now()}`;
    console.log('Image processing completed, ready for transmission');
  }



  // 生成C数组数据
  private generateCArrayData(buffer: ArrayBuffer, width: number, height: number): Uint8Array {
    const pixels = new Uint8Array(buffer);
    const result: number[] = [];
    
    // 每4个像素打包成一个字节
    for (let i = 0; i < pixels.length; i += 16) { // 每次处理4个像素，每个像素4字节
      const pixel1 = this.compareColor(pixels, i);
      const pixel2 = this.compareColor(pixels, i + 4);
      const pixel3 = this.compareColor(pixels, i + 8);
      const pixel4 = this.compareColor(pixels, i + 12);
      
      // 将4个2位值打包成一个8位值
      const packedValue = (pixel1 << 6) | (pixel2 << 4) | (pixel3 << 2) | pixel4;
      result.push(packedValue);
    }
    
    return new Uint8Array(result);
  }

  // 比较颜色并返回索引
  private compareColor(pixels: Uint8Array, index: number): number {
    const r = pixels[index];
    const g = pixels[index + 1];
    const b = pixels[index + 2];
    
    for (let i = 0; i < this.colors.length; i++) {
      if (r === this.colors[i].r && g === this.colors[i].g && b === this.colors[i].b) {
        return i;
      }
    }
    return 0; // 默认返回黑色
  }

  // 发送处理后的图片数据
  async sendProcessedImage(): Promise<void> {
    if (!this.processedDataArray.length || !this.isConnected) {
      this.showToast('无法发送图片');
      return;
    }

    try {
      this.isTransferring = true;
      this.transferProgress = 0;
      
      // 转换为ArrayBuffer发送
      const arrayBuffer = new ArrayBuffer(this.processedDataArray.length);
      const view = new Uint8Array(arrayBuffer);
      view.set(this.processedDataArray);
      
      // 发送图片数据，带进度回调
      const success = await this.sleClientService.sendImageData(
        arrayBuffer,
        (sent: number, total: number) => {
          this.transferProgress = (sent / total) * 100;
        }
      );
      
      if (success) {
        this.showToast('图片传输成功');
        this.resetImageState(); // 清空状态
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
}