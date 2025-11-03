export enum ChannelType {
  HUAWEI_PAY = 0,
  ALI_PAY = 1,
  WECHAT_PAY = 2
}

export class ChannelInfo {
  channelType: ChannelType = ChannelType.HUAWEI_PAY
  name: string = '';
  appId?: string = '';
  icon: ResourceStr = '';
  preOrderInfo: string = '';
  event?: ()=> void = ()=> {}
}