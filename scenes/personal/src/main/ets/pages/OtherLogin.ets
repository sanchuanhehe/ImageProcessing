import { LevelMode, promptAction } from '@kit.ArkUI';
import { TitleBar } from 'common';
import { AgreementDialog } from '../components/AgreementView';
import { Constants } from '../model/Constants';
import { PrivacyTextSpan } from '../components/PrivacyTextSpan';


@Component
export struct OtherLogin {
  @State pathStack: NavPathStack = new NavPathStack()
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageLink('loginState') loginState: boolean = false;
  @State verifyCodeTime: number = 0;
  @State phoneNum: string = '';
  @State verifyCode: string = ''
  @State isSelected: boolean = false;
  @State enableStatus: boolean = true;
  agreementDialog: CustomDialogController = new CustomDialogController({
    builder: AgreementDialog({
      cancel: () => {
        this.enableStatus = true;
        this.agreementDialog.close();
      },
      confirm: () => {
        this.enableStatus = false;
        this.agreementDialog.close();
        this.isSelected = true;
      },
      pathStack: this.pathStack,
      title:'用户协议和隐私政策',
      text:Constants.privacyText
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    levelMode: LevelMode.EMBEDDED
  });

  build() {
    NavDestination() {
      TitleBar({
        title: '',
        isBack: true,
        pathStack: this.pathStack
      })
        .margin({ left: 16 })
      Column() {
        Column() {
          // 登录图标
          this.buildLogInSymbolView();

          // 登录信息输入视图
          this.buildLogInfoInputView();
        }

        this.buildUserPrivacySelectView();
      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('sys.color.navigation_drag_bar_item_default'))
    }
    .onReady((ctx) => {
      this.pathStack = ctx.pathStack
    })
    .hideTitleBar(true)
    .padding({
      top: px2vp(this.topRectHeight)
    })
  }

  @Builder
  buildLogInSymbolView() {
    Image($r('app.media.icon'))
      .width(80)
      .height(80)
      .borderRadius(20)
      .margin({ top: 38, bottom: 38 })
      .objectFit(ImageFit.Cover)
  }

  @Builder
  buildLogInfoInputView() {
    Row() {
      Row() {
        TextInput({ placeholder: '请输入手机号' })
          .width('50%')
          .borderRadius($r('sys.float.corner_radius_level8'))
          .backgroundColor($r('sys.color.background_primary'))
          .placeholderColor($r('sys.color.font_secondary'))
          .placeholderFont({ size: $r('sys.float.Body_L') })
          .onChange((value) => this.phoneNum = value);
      }
      .width('100%')
    }
    .margin({ left: 16, right: 16, bottom: 20 })
    .height(50)
    .borderWidth($r('sys.float.border_larger'))
    .borderColor('#D6D6D6')
    .borderRadius($r('sys.float.corner_radius_level8'))
    .padding({ right: 10 })
    .justifyContent(FlexAlign.SpaceBetween)

    Row() {
      Row() {
        TextInput({ placeholder: '请输入验证码' })
          .width('50%')
          .borderRadius($r('sys.float.corner_radius_level8'))
          .backgroundColor($r('sys.color.background_primary'))
          .placeholderColor($r('sys.color.font_secondary'))
          .placeholderFont({ size: $r('sys.float.Body_L') })
          .onChange((value) => this.verifyCode = value);

        if (this.verifyCodeTime === 0) {
          Text('获取验证码')
            .width(85)
            .fontColor('#989898')
            .fontSize($r('sys.float.Body_L'))
            .textAlign(TextAlign.End)
            .onClick(() => {
              promptAction.showDialog({
                title: '提示',
                message: '获取验证码为模拟场景，真实获取验证码以业务实现为准',
              })
              this.verifyCodeTime = 60;
              this.getVerifyCode();
            });
        } else {
          Row() {
            Text(`${this.verifyCodeTime}`)
              .height(11)
              .fontColor('#989898')
              .fontSize($r('sys.float.Body_L'))
            Text('秒后重新获取')
              .height(11)
              .fontColor('#989898')
              .fontSize($r('sys.float.Body_L'))
          };
        }
      }.width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .margin({ left: 16, right: 16 })
    .height(50)
    .borderWidth($r('sys.float.border_larger'))
    .borderColor('#D6D6D6')
    .borderRadius($r('sys.float.corner_radius_level8'))
    .padding({ right: 10 })

    Row() {
      Text('点击登录')
        .width('100%')
        .textAlign(TextAlign.Center)
        .fontColor($r('sys.color.font_on_primary'))
    }
    .borderRadius(20)
    .backgroundColor(this.isSelected ? '#4f616d' : '#D2D2D2')
    .height(38)
    .margin({
      left: 16,
      right: 16,
      top: 50,
      bottom: 14
    })
    .onClick(() => this.clickLogInButton())

    Column() {
      Text('其他方式登录').fontColor('#999')
    }
    .margin({ top: 16, bottom: 20 })

    Column({ space: 10 }) {
      Image($r('app.media.huawei_account'))
        .width(38)
        .height(38)
        .objectFit(ImageFit.Cover);
      Text('华为账号一键登录')
        .fontColor('#999')
        .margin({ right: 4 })
        .fontSize(12)
    }
    .onClick(() => {
      this.pathStack.replacePathByName('quickLoginPage', null);
    })
  }

  @Builder
  buildUserPrivacySelectView() {
    Row() {
      Row() {
        Checkbox({ name: 'privacyCheckbox', group: 'privacyCheckboxGroup' })
          .width(24)
          .height(24)
          .focusable(true)
          .focusOnTouch(true)
          .selectedColor($r('sys.color.comp_background_emphasize'))
          .select(this.isSelected)
          .enabled(this.enableStatus)
          .margin({ top: 0 })
          .onChange((value: boolean) => {
            if (value) {
              this.isSelected = true;
            } else {
              this.isSelected = false;
            }
          })
      }.padding({
        right: 12
      })

      PrivacyTextSpan({
        privacyTexts: Constants.privacyText,
        clickAction: () => {
          if (this.enableStatus) {
            this.pathStack.pushPathByName('terms', null);
          }
        }
      })
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .margin({
      bottom: 44,
      left: 16,
      right: 16
    })
  }

  /**
   * 点击登录按钮
   **/
  validateLogin(): boolean {
    if (this.verifyCode === '' || this.phoneNum === '') {
      promptAction.showToast({ message: '手机号或验证码不能为空！' })
      return false
    }
    return true
  }

  /**
   * 点击登录按钮
   **/
  clickLogInButton(): void {
    // 先勾选协议
    if (!this.isSelected) {
      this.agreementDialog.open();
      return;
    }

    if (!this.validateLogin()) {
      return
    }
    this.loginState = true
    this.pathStack.pop();
  }

  /**
   * 获取验证码计数
   **/
  getVerifyCode(): void {
    let timer = setInterval(() => {
      this.verifyCodeTime--;
      if (!this.verifyCodeTime) {
        clearInterval(timer)
      }
    }, 1000)
  }
}