import { authentication, loginComponentManager, LoginWithHuaweiIDButton } from '@kit.AccountKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import promptAction from '@ohos.promptAction';
import { util } from '@kit.ArkTS';
import { AgreementDialog } from '../components/AgreementView';
import { LoginErrorCode } from '../model/ErrorCodeEntity';
import { Constants } from '../model/Constants';
import { PrivacyTextSpan } from '../components/PrivacyTextSpan';

@Component
export struct QuickLoginPage {
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageLink('loginState') loginState: boolean = false;
  pathStack: NavPathStack = new NavPathStack();
  logTag: string = 'QuickLoginButtonComponent';
  domainId: number = 0x0000;
  // 是否勾选协议
  @State isSelected: boolean = false;
  @State quickLoginAnonymousPhone: string = '';
  // 弹窗是否已开启
  private customerDiaLogOpen: boolean = false;
  error?: BusinessError;
  response: loginComponentManager.HuaweiIDCredential = {} as loginComponentManager.HuaweiIDCredential;
  // 控制登录中不可点击协议和复选框的状态变量
  @State enableStatus: boolean = true;
  @State anonymousPhone: string = ''
  controller: loginComponentManager.LoginWithHuaweiIDButtonController =
    new loginComponentManager.LoginWithHuaweiIDButtonController()
      // 需要用户同意协议才能完成华为账号登录，请先设置协议状态为NOT_ACCEPTED，当用户同意协议后设置协议状态为ACCEPTED，才可以完成华为账号登录
      .setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED)
      .onClickLoginWithHuaweiIDButton((_error: BusinessError, response: loginComponentManager.HuaweiIDCredential) => {
        // 处理用户点击一键登录按钮逻辑，灰度传入undefined模拟流程，应用申请权限后，传入error
        this.handleLoginWithHuaweiIDButton(undefined, response);
      });
  agreementDialog: CustomDialogController = new CustomDialogController({
    builder: AgreementDialog({
      cancel: () => {
        this.enableStatus = true;
        this.agreementDialog.close();
        this.customerDiaLogOpen = false
        // 设置协议状态为NOT_ACCEPTED
        this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED);
      },
      confirm: () => {
        this.enableStatus = false;
        this.agreementDialog.close();
        this.customerDiaLogOpen = false
        this.isSelected = true;
        // 设置协议状态为ACCEPTED
        this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
        if (this.error?.code === LoginErrorCode.ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED) {
          this.handleLoginWithHuaweiIDButton(undefined, this.response);
        } else {
          this.handleLoginWithHuaweiIDButton(this.error, this.response);
        }
      },
      pathStack: this.pathStack,
      title:'用户协议和隐私政策',
      text:Constants.privacyText,
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
  });

  aboutToAppear(): void {
    this.getQuickLoginAnonymousPhone()
  }

  // 处理点击一键登录后的方法
  handleLoginWithHuaweiIDButton(error: BusinessError | undefined,
    response: loginComponentManager.HuaweiIDCredential) {
    this.enableStatus = false;
    // if部分内容配置好可用的调试证书和client_id后再放开
    if (error) {
      hilog.error(this.domainId, this.logTag,
        `Failed to click LoginWithHuaweiIDButton. Code is ${error.code}, message is ${error.message}`);
      this.error = error;
      if (error.code === LoginErrorCode.ERROR_CODE_NETWORK_ERROR) {
        AlertDialog.show(
          {
            message: 'No Internet connection. Check your network settings. ',
            offset: { dx: 0, dy: -12 },
            alignment: DialogAlignment.Bottom,
            autoCancel: false,
            confirm: {
              value: 'OK',
              action: () => {
              }
            }
          }
        );
      } else if (error.code === LoginErrorCode.ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED) {
        // 未同意协议，弹出协议弹框，推荐使用该回调方式
        this.agreementDialog.open();
        this.customerDiaLogOpen = true
      } else if (error.code === LoginErrorCode.ERROR_CODE_LOGIN_OUT) {
        // 华为账号未登录提示
        this.showToast('You have not logged in with your Huawei ID. Please try again.')
      } else if (error.code === LoginErrorCode.ERROR_CODE_NOT_SUPPORTED) {
        // 账号不支持该scopes或permissions提示
        this.showToast('The scopes or permissions are not supported.');
      } else if (error.code === LoginErrorCode.ERROR_CODE_NOT_REQUIRED_SCOPE_OR_PERMISSION) {
        // 应用没有申请scope权限
        this.showToast('The app does not have the required scopes or permissions.');
      } else {
        // 其他提示系统或服务异常
        this.showToast('Service or network error. Please try again later.');
      }
      this.enableStatus = true;
      return;
    }
    try {
      if (this.isSelected) {
        // 配置好可用的调试证书和client_id后再放开校验
        // if (response) {
        hilog.info(this.domainId, this.logTag, 'Succeed in clicking LoginWithHuaweiIDButton.');
        if (this.response.unionID === undefined) {
          this.response = response;
        }
        this.loginState = true
        this.pathStack.pop();
        // }
      } else {
        this.agreementDialog.open();
        this.customerDiaLogOpen = true
      }
    } catch (e) {
      hilog.info(this.domainId, this.logTag,
        `Failed to LoginWithHuaweiIDButton, errCode: ${e.code}, errMessage: ${e.message}`);
      AlertDialog.show(
        {
          message: 'Service or network error. Please try again later.',
          offset: { dx: 0, dy: -12 },
          alignment: DialogAlignment.Bottom,
          autoCancel: false,
          confirm: {
            value: 'OK',
            action: () => {
            }
          }
        }
      );
    } finally {
      this.enableStatus = true;
    }
  }

  // Toast提示
  showToast(resource: string) {
    try {
      promptAction.showToast({
        message: resource,
        duration: 2000
      });
    } catch (error) {
      let message = (error as BusinessError).message
      let code = (error as BusinessError).code
      hilog.error(this.domainId, this.logTag, `showToast args error code is ${code}, message is ${message}`);
    }
    ;
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Column() {
            Row() {
              Image($r('app.media.icon'))
                .width(80)
                .height(80)
                .draggable(false)
                .copyOption(CopyOptions.None)
                .borderRadius(20)
                .onComplete(() => {
                  hilog.info(this.domainId, this.logTag, 'Succeed in loading appIcon.');
                })
                .onError(() => {
                  hilog.error(this.domainId, this.logTag, 'Failed to load appIcon.');
                })
            }.margin({
              top: 44,
              left: 124,
              right: 124
            })

            Column() {
              Text(this.anonymousPhone)
                .fontSize(36)
                .fontColor($r('sys.color.ohos_id_color_text_primary'))
                .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
                .fontWeight(FontWeight.Bold)
                .lineHeight(48)
                .textAlign(TextAlign.Center)
                .maxLines(1)
                .constraintSize({ maxWidth: '100%', minHeight: 48 })

              Text('华为账号绑定号码')
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
                .fontWeight(FontWeight.Regular)
                .lineHeight(19)
                .textAlign(TextAlign.Center)
                .maxLines(1)
                .constraintSize({ maxWidth: '100%' })
                .margin({
                  top: 8
                })
            }.margin({
              top: 64
            })

            Column() {
              LoginWithHuaweiIDButton({
                params: {
                  style: loginComponentManager.Style.BUTTON_RED,
                  loginType: loginComponentManager.LoginType.QUICK_LOGIN,
                  supportDarkMode: true,
                },
                controller: this.controller
              }).id('login_with_huaweiId_button')
            }
            .height(40)
            .width('100%')
            .constraintSize({ maxWidth: 448 })
            .margin({
              top: 56,
              bottom: 16
            })

            Column() {
              Column() {
                Text('其他方式登录')
                  .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
                  .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r('sys.float.ohos_id_text_size_button1'))
                  .focusable(true)
                  .focusOnTouch(true)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .maxLines(1)
                  .padding({ left: 8, right: 8 })
              }
              .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
              .constraintSize({ minHeight: 40 })
              .justifyContent(FlexAlign.Center)
              .borderRadius(16)
              .width('100%')
              .onClick(() => {
                this.pathStack.replacePathByName('otherLogin', null)
              })
            }
          }

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
                  hilog.info(this.domainId, this.logTag, `agreementChecked: ${value}`);
                  if (value) {
                    this.isSelected = true;
                    // 设置协议状态为ACCEPTED
                    this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
                  } else {
                    this.isSelected = false;
                    // 设置协议状态为NOT_ACCEPTED
                    this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED);
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
            bottom: 44
          })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .constraintSize({ minHeight: '100%' })
        .margin({
          left: 16,
          right: 16
        })
      }.backgroundColor('#F1F3F5')
    }
    .padding({
      top: px2vp(this.topRectHeight)
    })
    .width('100%')
    .height('100%')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .onShown(() => {
      if (this.customerDiaLogOpen) {
        this.agreementDialog.open()
      }
    })
    .onBackPressed(() => {
      const popDestinationInfo = this.pathStack.pop(); // 弹出路由栈栈顶元素
      console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo));
      return true;
    })
    .backgroundColor($r('app.color.main_background_color'));
  }

  getQuickLoginAnonymousPhone() {
    // 创建授权请求，并设置参数
    const authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    // 获取匿名手机号需传quickLoginAnonymousPhone这个scope，传参之前需要先申请“华为账号一键登录”权限
    authRequest.scopes = ['quickLoginAnonymousPhone'];
    // 用于防跨站点请求伪造
    authRequest.state = util.generateRandomUUID();
    // 一键登录场景该参数必须设置为false
    authRequest.forceAuthorization = false;
    const controller = new authentication.AuthenticationController();
    try {
      controller.executeRequest(authRequest).then((response: authentication.AuthorizationWithHuaweiIDResponse) => {
        // 获取到匿名手机号
        const anonymousPhone = response.data?.extraInfo?.quickLoginAnonymousPhone as string;
        if (anonymousPhone) {
          hilog.info(0x0000, 'testTag', 'Succeeded in authentication.');
          this.anonymousPhone = anonymousPhone
          return;
        }
        hilog.info(0x0000, 'testTag', 'Succeeded in authentication. AnonymousPhone is empty.');
      }).catch((error: BusinessError) => {
        // 以下内容配置好可用的调试证书和client_id后删除，当前为写死虚拟号码
        this.anonymousPhone = '123******90'
        hilog.error(0x0000, 'testTag',
          `Failed to get quickLoginAnonymousPhone, errorCode is ${error.code}, errorMessage is ${error.message}`);
      })
    } catch (error) {
      hilog.error(0x0000, 'testTag',
        `Failed to get quickLoginAnonymousPhone, errorCode is ${error.code}, errorMessage is ${error.message}`);
    }
  }
}