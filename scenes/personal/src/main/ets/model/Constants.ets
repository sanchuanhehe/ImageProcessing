import { ImageShowModel } from 'common';
import { loginComponentManager } from '@kit.AccountKit';

export class Constants {
  static materialList:ImageShowModel[] = [
    {
      imageSource:$r('app.media.material1'),
      text:'海边夕阳滤镜',
      isVip:true
    },
    {
      imageSource:$r('app.media.material2'),
      text:'海洋灯塔滤镜',
      isVip:true
    },
    {
      imageSource:$r('app.media.material3'),
      text:'晴朗海风滤镜',
      isVip:true
    },
    {
      imageSource:$r('app.media.material4'),
      text:'春意童趣滤镜',
      isVip:true
    }
  ]
  static privacyText: loginComponentManager.PrivacyText[] = [{
    text: '已阅读并同意',
    type: loginComponentManager.TextType.PLAIN_TEXT
  }, {
    text: '《用户服务协议》',
    type: loginComponentManager.TextType.RICH_TEXT
  },{
    text: '《隐私协议》',
    type: loginComponentManager.TextType.RICH_TEXT
  },{
    text: '和',
    type: loginComponentManager.TextType.PLAIN_TEXT
  },{
    text: '《华为账号用户认证协议》',
    type: loginComponentManager.TextType.RICH_TEXT
  },{
    text: '.',
    type: loginComponentManager.TextType.PLAIN_TEXT
  }]
  static memberText: loginComponentManager.PrivacyText[] = [{
    text: '已阅读并同意',
    type: loginComponentManager.TextType.PLAIN_TEXT
  }, {
    text: '《会员服务协议》',
    type: loginComponentManager.TextType.RICH_TEXT
  }, {
    text: '.',
    type: loginComponentManager.TextType.PLAIN_TEXT
  }];
}