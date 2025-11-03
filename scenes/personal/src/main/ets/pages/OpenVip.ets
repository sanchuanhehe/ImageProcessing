import { ImageShowModel, TitleBar } from 'common';
import { AggregatedPaymentPicker } from '../components/AggregatedPaymentPicker';
import { AgreementDialog } from '../components/AgreementView';
import { ChannelType } from '../model/Channel';
import { Constants } from '../model/Constants';
import { LevelMode } from '@kit.ArkUI';
import { JSON } from '@kit.ArkTS';

@Component
export struct OpenVipPage {
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @Prop pathStack: NavPathStack;
  @State selectCombo: string = '会员年卡'
  @State channelShow: boolean = false
  @State isSelected: boolean = false
  @StorageProp('isVip') isVip: boolean = false
  agreementDialog: CustomDialogController = new CustomDialogController({
    builder: AgreementDialog({
      cancel: () => {
        this.agreementDialog.close();
      },
      confirm: () => {
        this.agreementDialog.close();
        this.isSelected = true;
      },
      pathStack: this.pathStack,
      title: '会员服务协议',
      text: Constants.memberText
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    levelMode: LevelMode.EMBEDDED,
  });

  @Builder
  vipComboBuilder(title: string, price: number, desc: string) {
    Column() {
      Column() {
        Text(title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .margin({ top: 16 })
        Text() {
          Span('¥')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
          Span(price.toString())
            .fontSize(30)
            .fontWeight(FontWeight.Medium)
        }
        .height(40)
        .fontColor(this.selectCombo === title ? '#ED6F21' : '#000000')
        .margin({ top: 8 })
      }.height(100)

      Stack() {
        Row()
          .width('100%')
          .height('100%')
          .opacity(this.selectCombo === title ? 0.2 : 0.05)
          .backgroundColor(this.selectCombo === title ? '#ED6F21' : '#000000')
        Text(desc)
          .fontSize(12)
          .fontColor(this.selectCombo === title ? '#562E15' : '#000000')
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .layoutWeight(1)
      .borderRadius({
        topLeft: 0,
        topRight: 0,
        bottomLeft: 8,
        bottomRight: 8
      })
    }
    .border({
      radius: 8,
      width: this.selectCombo === title ? 2 : 1,
      style: BorderStyle.Solid,
      color: this.selectCombo === title ? '#F8E6CE' : $r('app.color.main_background_color')
    })
    .backgroundColor(this.selectCombo === title ? '#FFFCF2' : '#FFFFFF')
    .width(104)
    .height(124)
    .onClick(() => {
      this.selectCombo = title
    })
  }

  @Builder
  rightsShowBuilder() {
    Stack() {
      Row()
        .margin({ top: 8 })
        .width('100%')
        .height('100%')
        .borderRadius(16)
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#FDF8EC', 0], ['#FFFFFF', 1]]
        })
      Column() {
        Image($r('app.media.rights_title'))
          .width(120)
          .height(33)
          .margin({ bottom: 16 })
        Row() {
          Text('海量素材资源，随意使用')
            .fontColor('#FEAD27')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
        }
        .margin({ bottom: 12 })

        Text() {
          Span('3500')
            .fontColor('#D37F0F')
            .fontWeight(FontWeight.Medium)
            .fontSize(24)
          Span('+高级素材')
            .fontColor('#D37F0F')
            .fontWeight(FontWeight.Medium)
            .fontSize(14)
        }

        Text('专属趣味贴纸，特殊文字')
          .fontSize(12)
          .margin({ bottom: 12 })
        Grid() {
          ForEach(Constants.materialList, (item: ImageShowModel) => {
            GridItem() {
              Stack() {
                Image(item.imageSource)
                  .borderRadius(8)
                Image($r('app.media.image_vip'))
                  .width(16)
                  .height(16)
                  .visibility(item.isVip ? Visibility.Visible : Visibility.None)
              }
              .alignContent(Alignment.BottomStart)
            }
          }, (item: ImageShowModel) => JSON.stringify(item))
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(12)
        .rowsGap(12)
      }
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .height('100%')
      .padding({ left: 12, right: 12 })

    }
    .alignContent(Alignment.Top)
    .width('100%')
    .height(364)
    .backgroundColor($r('sys.color.comp_background_list_card'))

    .padding({
      left: 16,
      right: 16,
      top: 12,
      bottom: 12
    })
  }

  build() {
    NavDestination() {
      TitleBar({
        pathStack: this.pathStack,
        isBack: true,
        title: this.isVip ? '会员中心' : '开通会员'
      }).margin({ bottom: 20, left: 16, right: 16 })
      Column() {
        Text('会员套餐')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .textAlign(TextAlign.Start)
          .margin({ bottom: 12 })
        Row() {
          this.vipComboBuilder('会员年卡', 388, '每天仅需0.8元')
          this.vipComboBuilder('会员季卡', 118, '低至0.93元/天')
          this.vipComboBuilder('会员月卡', 40, '畅享VIP权益31天')
        }.width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 12 })

        Text(this.isVip ? 'VIP续费' : '升级VIP')
          .width('100%')
          .height(40)
          .fontColor(Color.White)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .borderRadius(20)
          .backgroundColor('#ED6F21')
          .textAlign(TextAlign.Center)
          .margin({ bottom: 8 })
          .onClick(() => {
            // 先勾选协议
            if (!this.isSelected) {
              this.agreementDialog.open();
              return;
            } else {
              this.channelShow = true
            }
          })
        Row() {
          Checkbox({ name: 'privacyCheckbox', group: 'privacyCheckboxGroup' })
            .width(20)
            .height(20)
            .focusable(true)
            .focusOnTouch(true)
            .selectedColor($r('sys.color.comp_background_emphasize'))
            .select(this.isSelected)
            .margin({ top: 0 })
            .onChange((value: boolean) => {
              if (value) {
                this.isSelected = true;
              } else {
                this.isSelected = false;
              }
            })
          Text('购买前请阅读并同意')
            .fontSize(12)
            .opacity(0.6)
          Text('《会员服务协议》')
            .fontSize(12)
            .fontColor('#562E15')
            .onClick(() => {
              this.pathStack?.pushPathByName('terms', null);
            })
        }
        .justifyContent(FlexAlign.Center)

      }
      .width('100%')
      .height(260)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .padding({
        left: 16,
        right: 16,
        top: 12,
        bottom: 12
      })
      .margin({ bottom: 16 })

      this.rightsShowBuilder()
    }
    .bindSheet($$this.channelShow, this.channelBuilder(), {
      keyboardAvoidMode: SheetKeyboardAvoidMode.RESIZE_ONLY,
      height: 200,
      preferType: SheetType.BOTTOM,
      backgroundColor: $r('sys.color.background_primary'),
      showClose: true,
      onWillDismiss: async (dismissSheetAction: DismissSheetAction) => {
        // 0: 点击三键back、左滑/右滑、键盘ESC 1 点击蒙层  3: 跟手拖拽
        let reason = dismissSheetAction.reason
        if (reason === DismissReason.SLIDE_DOWN) {
          return
        }
        dismissSheetAction.dismiss()
      },
      title: {
        title: '立即开通',
      }
    })
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx.pathStack
    })
    .hideTitleBar(true)
    .backgroundColor($r('app.color.main_background_color'))
    .padding({
      top: px2vp(this.topRectHeight),
      bottom: px2vp(this.bottomRectHeight)
    })
  }

  @Builder
  channelBuilder() {
    AggregatedPaymentPicker({
      channelInfo: [{
        channelType: ChannelType.HUAWEI_PAY,
        name: '华为支付',
        icon: $r('app.media.hwpay'),
        preOrderInfo: '',
      }],
      pathStack: this.pathStack,
      isShow: this.channelShow
    })
  }
}
