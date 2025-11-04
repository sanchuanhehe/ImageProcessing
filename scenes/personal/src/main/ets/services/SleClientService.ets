import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { scan, ssap, constant } from '@kit.NearLinkKit';

/**
 * SLE 客户端服务管理类
 * 基于 NearLink Kit API 实现图片传输功能
 */
export class SleClientService {
  private static instance: SleClientService;
  private client: ssap.Client | null = null;
  private services: Array<ssap.Service> = [];
  private scanResults: Array<scan.ScanResults> = [];
  private isConnected: boolean = false;
  private connectedDeviceAddress: string = '';
  
  // 图片传输服务 UUID（与服务端保持一致）
  private readonly IMAGE_SERVICE_UUID = '0x1234';
  private readonly IMAGE_DATA_PROPERTY_UUID = '0x5678';
  private readonly IMAGE_CONTROL_PROPERTY_UUID = '0x9ABC';
  
  // 日志标签
  private readonly logTag: string = 'SleClientService';
  private readonly domainId: number = 0x0000;

  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): SleClientService {
    if (!SleClientService.instance) {
      SleClientService.instance = new SleClientService();
    }
    return SleClientService.instance;
  }

  /**
   * 初始化 SLE 客户端
   */
  public async initialize(): Promise<boolean> {
    try {
      // 注册设备发现回调
      this.registerDeviceFoundCallback();
      hilog.info(this.domainId, this.logTag, 'SLE client initialized successfully');
      return true;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(this.domainId, this.logTag, `Initialize failed: ${err.code}, ${err.message}`);
      return false;
    }
  }

  /**
   * 开始扫描 SLE 设备
   */
  public async startScan(): Promise<void> {
    try {
      // 配置扫描过滤器，寻找图片传输服务
      const scanFilter: scan.ScanFilters = {
        deviceName: 'sleserver' // 匹配服务端设备名
      };
      
      const scanOptions: scan.ScanOptions = {
        scanMode: 2 // 平衡模式
      };
      
      // 开始扫描
      await scan.startScan([scanFilter], scanOptions);
      hilog.info(this.domainId, this.logTag, 'Started scanning for SLE devices');
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(this.domainId, this.logTag, `Start scan failed: ${err.code}, ${err.message}`);
      throw new Error(`Start scan failed: ${err.message}`);
    }
  }

  /**
   * 停止扫描
   */
  public async stopScan(): Promise<void> {
    try {
      await scan.stopScan();
      hilog.info(this.domainId, this.logTag, 'Stopped scanning');
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(this.domainId, this.logTag, `Stop scan failed: ${err.code}, ${err.message}`);
    }
  }

  /**
   * 注册设备发现回调
   */
  private registerDeviceFoundCallback(): void {
    try {
      const scanCallback: (data: Array<scan.ScanResults>) => void = (data: Array<scan.ScanResults>) => {
        // 检查新发现的设备是否已存在
        for (let indexData = 0; indexData < data.length; indexData++) {
          let existingDevice = false;
          for (let indexResult = 0; indexResult < this.scanResults.length; indexResult++) {
            if (this.scanResults[indexResult].address === data[indexData].address) {
              existingDevice = true;
              break;
            }
          }
          if (!existingDevice) {
            this.scanResults.push(data[indexData]);
            hilog.info(this.domainId, this.logTag, 
              `Found new device: ${data[indexData].deviceName}, address: ${data[indexData].address}`);
          }
        }
      };
      
      scan.on('deviceFound', scanCallback);
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(this.domainId, this.logTag, `Register device found callback failed: ${err.code}, ${err.message}`);
    }
  }

  /**
   * 连接到指定设备
   */
  public async connectToDevice(address: string): Promise<boolean> {
    try {
      hilog.info(this.domainId, this.logTag, `Connecting to device: ${address}`);
      
      // 创建 SSAP 客户端
      this.client = ssap.createClient(address);
      this.services = []; // 清空服务数组
      this.connectedDeviceAddress = address;
      
      // 注册连接状态变化回调
      this.registerConnectionStateCallback();
      
      // 连接设备
      await this.client.connect();
      
      // 延时获取服务列表
      setTimeout(async () => {
        await this.getServices();
      }, 500);
      
      return true;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(this.domainId, this.logTag, `Connect failed: ${err.code}, ${err.message}`);
      return false;
    }
  }

  /**
   * 注册连接状态变化回调
   */
  private registerConnectionStateCallback(): void {
    if (!this.client) return;
    
    try {
      const connectionStateChangeCallback = (data: ssap.ConnectionChangeState) => {
        hilog.info(this.domainId, this.logTag, `Connection state changed: ${JSON.stringify(data)}`);
        
        if (data.state === constant.ConnectionState.STATE_CONNECTED) {
          this.isConnected = true;
          hilog.info(this.domainId, this.logTag, 'Device connected successfully');
        } else if (data.state === constant.ConnectionState.STATE_DISCONNECTED) {
          this.isConnected = false;
          hilog.info(this.domainId, this.logTag, 'Device disconnected');
        }
      };
      
      this.client.on('connectionStateChange', connectionStateChangeCallback);
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(this.domainId, this.logTag, `Register connection state callback failed: ${err.code}, ${err.message}`);
    }
  }

  /**
   * 获取服务列表
   */
  private async getServices(): Promise<void> {
    if (!this.client) return;
    
    try {
      const result = await this.client.getServices();
      this.services = result;
      hilog.info(this.domainId, this.logTag, `Got services: ${JSON.stringify(result)}`);
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(this.domainId, this.logTag, `Get services failed: ${err.code}, ${err.message}`);
    }
  }

  /**
   * 发送图片控制命令
   */
  public async sendImageControlCommand(command: number, data?: ArrayBuffer): Promise<boolean> {
    if (!this.client || !this.isConnected || this.services.length === 0) {
      hilog.error(this.domainId, this.logTag, 'Client not ready for sending commands');
      return false;
    }

    try {
      // 构造控制命令数据
      const commandData = new ArrayBuffer(data ? data.byteLength + 1 : 1);
      const commandView = new Uint8Array(commandData);
      commandView[0] = command;
      
      if (data) {
        const dataView = new Uint8Array(data);
        commandView.set(dataView, 1);
      }

      // 构建属性对象
      const controlProperty: ssap.Property = {
        serviceUuid: this.IMAGE_SERVICE_UUID,
        propertyUuid: this.IMAGE_CONTROL_PROPERTY_UUID,
        value: commandData
      };

      // 写入控制命令 - 使用 WRITE_NO_RESPONSE 类型以提高传输效率
      await this.client.writeProperty(controlProperty, ssap.PropertyWriteType.WRITE_NO_RESPONSE);
      hilog.info(this.domainId, this.logTag, `Sent control command: ${command}`);
      return true;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(this.domainId, this.logTag, `Send control command failed: ${err.code}, ${err.message}`);
      return false;
    }
  }

  /**
   * 发送图片数据包
   */
  public async sendImageDataPacket(packetData: ArrayBuffer): Promise<boolean> {
    if (!this.client || !this.isConnected || this.services.length === 0) {
      hilog.error(this.domainId, this.logTag, 'Client not ready for sending data');
      return false;
    }

    try {
      // 构建数据属性对象
      const dataProperty: ssap.Property = {
        serviceUuid: this.IMAGE_SERVICE_UUID,
        propertyUuid: this.IMAGE_DATA_PROPERTY_UUID,
        value: packetData
      };

      // 发送数据包 - 使用 WRITE_NO_RESPONSE 以提高传输效率
      await this.client.writeProperty(dataProperty, ssap.PropertyWriteType.WRITE_NO_RESPONSE);
      return true;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(this.domainId, this.logTag, `Send data packet failed: ${err.code}, ${err.message}`);
      return false;
    }
  }

  /**
   * 发送完整图片（分包传输）
   */
  public async sendImageData(
    imageData: ArrayBuffer, 
    progressCallback?: (sent: number, total: number) => void
  ): Promise<boolean> {
    const maxPacketSize = 236; // 240 - 4字节包头
    const totalSize = imageData.byteLength;
    const totalPackets = Math.ceil(totalSize / maxPacketSize);
    
    try {
      hilog.info(this.domainId, this.logTag, 
        `Starting image transfer: ${totalSize} bytes, ${totalPackets} packets`);

      // 1. 发送开始传输命令
      const startCommandData = new ArrayBuffer(8);
      const startView = new DataView(startCommandData);
      startView.setUint32(0, totalSize, true); // 图片总大小
      startView.setUint16(4, totalPackets, true); // 总包数
      startView.setUint16(6, maxPacketSize, true); // 每包大小
      
      if (!await this.sendImageControlCommand(0x01, startCommandData)) { // IMAGE_CMD_START_TRANSFER
        return false;
      }

      // 2. 分包发送图片数据
      for (let packetIndex = 0; packetIndex < totalPackets; packetIndex++) {
        const start = packetIndex * maxPacketSize;
        const end = Math.min(start + maxPacketSize, totalSize);
        const chunkData = imageData.slice(start, end);
        
        // 构造数据包：包序号(2) + 总包数(2) + 数据
        const packetBuffer = new ArrayBuffer(4 + chunkData.byteLength);
        const packetView = new DataView(packetBuffer);
        
        packetView.setUint16(0, packetIndex + 1, true); // 包序号从1开始
        packetView.setUint16(2, totalPackets, true); // 总包数
        
        // 复制数据
        const packetData = new Uint8Array(packetBuffer);
        const chunkArray = new Uint8Array(chunkData);
        packetData.set(chunkArray, 4);
        
        // 发送数据包
        if (!await this.sendImageDataPacket(packetBuffer)) {
          hilog.error(this.domainId, this.logTag, `Failed to send packet ${packetIndex + 1}`);
          return false;
        }

        // 更新进度
        if (progressCallback) {
          progressCallback(end, totalSize);
        }

        // 添加小延迟避免数据拥塞
        await this.delay(10);
      }

      // 3. 发送传输完成命令
      await this.sendImageControlCommand(0x04); // IMAGE_CMD_TRANSFER_COMPLETE
      
      hilog.info(this.domainId, this.logTag, 'Image transfer completed successfully');
      return true;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(this.domainId, this.logTag, `Image transfer failed: ${err.code}, ${err.message}`);
      return false;
    }
  }

  /**
   * 断开连接
   */
  public async disconnect(): Promise<void> {
    if (this.client && this.isConnected) {
      try {
        await this.client.disconnect();
        this.isConnected = false;
        this.connectedDeviceAddress = '';
        hilog.info(this.domainId, this.logTag, 'Disconnected from device');
      } catch (error) {
        const err = error as BusinessError;
        hilog.error(this.domainId, this.logTag, `Disconnect failed: ${err.code}, ${err.message}`);
      }
    }
  }

  /**
   * 获取扫描结果
   */
  public getScanResults(): Array<scan.ScanResults> {
    return this.scanResults;
  }

  /**
   * 获取连接状态
   */
  public getConnectionState(): boolean {
    return this.isConnected;
  }

  /**
   * 获取已连接设备地址
   */
  public getConnectedDeviceAddress(): string {
    return this.connectedDeviceAddress;
  }

  /**
   * 清空扫描结果
   */
  public clearScanResults(): void {
    this.scanResults = [];
  }

  /**
   * 延迟函数
   */
  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  /**
   * 销毁服务
   */
  public destroy(): void {
    try {
      // 注销回调
      scan.off('deviceFound');
      
      // 断开连接
      this.disconnect();
      
      // 清理资源
      this.client = null;
      this.services = [];
      this.scanResults = [];
      this.isConnected = false;
      this.connectedDeviceAddress = '';
      
      hilog.info(this.domainId, this.logTag, 'SLE client service destroyed');
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(this.domainId, this.logTag, `Destroy failed: ${err.code}, ${err.message}`);
    }
  }
}
