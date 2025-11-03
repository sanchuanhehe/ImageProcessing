import { CanvasTextItem } from '../model/BeautificationParam'
import { Constants } from '../model/Constants'

@Component
export struct AddTextToolBar {
  @Link barIndex: number
  @State textTabIndex: number = 0
  private textTabController: TabsController = new TabsController()
  tabTitle: string[] = ['样式', '字体', '文案']
  @Link canvasItemStack: CanvasTextItem
  saveImageWithText?: () => void

  build() {
    Column() {
      Row() {
        Image($r('app.media.xmark'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick(() => {
            this.barIndex = -1
            this.cleanText()
          })

        Row({ space: 32 }) {
          ForEach(this.tabTitle, (item: string, index: number) => {
            Text(item)
              .fontColor(this.textTabIndex === index ? '#ED6F21' : Color.Black)
              .fontSize(16)
              .fontWeight(this.textTabIndex === index ? FontWeight.Medium : FontWeight.Regular)
              .onClick(() => {
                this.textTabIndex = index
                this.textTabController.changeIndex(index);
              })
          }, (item: string) => item)
        }

        Image($r('app.media.checkMark'))
          .width(24)
          .height(24)
          .margin({ right: 16 })
          .onClick(() => {
            if (this.saveImageWithText) {
              this.saveImageWithText()
            }
          })
      }
      .width('100%')
      .margin({ top: 14 })
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Tabs({ barPosition: BarPosition.Start, controller: this.textTabController }) {
          TabContent() {
            this.fontStyleBuilder()
          }

          TabContent() {
            this.fontFamilyBuilder()
          }

          TabContent() {
            this.textRecommendBuilder()
          }
        }
        .barHeight(0)
        .onChange((index: number) => {
          this.textTabIndex = index
        })
      }
      .height(170)
      .margin({
        top: 24,
        bottom: 24,
        left: 16,
        right: 16
      })
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius({ topLeft: 16, topRight: 16 })
  }

  @Builder
  fontStyleBuilder() {
    Column() {
      Row() {
        ForEach(Constants.fontColorList, (item: string) => {
          Stack() {
            Circle({ width: 24, height: 24 })
              .fill(item)
              .stroke(item === '#FFFFFF' ? '#000000' : Color.Transparent)

            Circle({ width: 12, height: 12 })
              .fill(item === '#FFFFFF' ? '#000000' : '#FFFFFF')
              .visibility(this.canvasItemStack.currentColor === item ? Visibility.Visible : Visibility.None)
          }
          .onClick(() => {
            this.canvasItemStack.currentColor = item
          })
        }, (item: string) => item)
      }
      .justifyContent(FlexAlign.SpaceAround)
      .alignItems(VerticalAlign.Center)
      .width('100%')
      .height(40)
      .margin({ bottom: 12 })

      Row() {
        Text('字号')
          .fontSize(16)
          .margin({ right: 16 })
        Row() {
          Image($r('app.media.minus'))
            .borderRadius(700)
            .backgroundColor($r('app.color.main_background_color'))
            .height(28)
            .width(28)
            .padding(4)
            .onClick(() => {
              this.canvasItemStack.fontSize--
            })
          Text(this.canvasItemStack.fontSize.toString())
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
          Image($r('app.media.plus'))
            .borderRadius(700)
            .height(28)
            .width(28)
            .padding(4)
            .backgroundColor($r('app.color.main_background_color'))
            .onClick(() => {
              this.canvasItemStack.fontSize++
            })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width(120)
        .height(32)
        .border({
          radius: 16,
          color: $r('app.color.main_background_color'),
          width: 1,
          style: BorderStyle.Solid
        })
      }.width('100%')
      .justifyContent(FlexAlign.Start)

      Row() {
        Text('透明')
          .fontSize(16)
          .margin({ right: 16 })
        Slider({
          value: this.canvasItemStack.opacity,
          min: 0,
          max: 1,
          step: 0.1,
          style: SliderStyle.OutSet
        })
          .layoutWeight(1)
          .showTips(true)
          .onChange((value: number) => {
            this.canvasItemStack.opacity = value
          })
      }
      .margin({ bottom: 12 })

      Row() {
        Image($r('app.media.bold'))
          .width(24)
          .height(24)
          .margin({ left: 8 })
          .onClick(() => {
            this.canvasItemStack.isBold = !this.canvasItemStack.isBold
          })
          .backgroundColor(this.canvasItemStack.isBold ? $r('app.color.main_background_color') : Color.White)
        Image($r('app.media.italic'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.canvasItemStack.isItalics = !this.canvasItemStack.isItalics
          })
          .backgroundColor(this.canvasItemStack.isItalics ? $r('app.color.main_background_color') : Color.White)
        Image($r('app.media.decoration'))
          .width(24)
          .height(24)
          .margin({ right: 8 })
          .onClick(() => {
            this.canvasItemStack.isUnderline = !this.canvasItemStack.isUnderline
          })
          .backgroundColor(this.canvasItemStack.isUnderline ? $r('app.color.main_background_color') : Color.White)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }.width('100%')
  }

  @Builder
  fontFamilyBuilder() {
    Grid() {
      ForEach(Constants.fontFamilyList, (item: string) => {
        GridItem() {
          Column() {
            Row() {
              Text(item)
                .fontSize(14)
                .fontFamily(item)
            }
            .justifyContent(FlexAlign.Center)
            .width(170)
            .backgroundColor($r('app.color.main_background_color'))
            .borderRadius(8)
            .borderColor(this.canvasItemStack.font === item ? '#ED6F21' : Color.Transparent)
            .borderWidth(1)
            .borderStyle(BorderStyle.Solid)
            .height(44)
            .margin({ bottom: 12 })

            Text(item)
              .fontSize(12)
              .fontFamily(item)
          }
          .onClick(() => {
            this.canvasItemStack.font = item
          })
        }
      }, (item: string) => item)
    }
    .columnsTemplate('1fr 1fr')
    .columnsGap(14)
    .rowsGap(16)
    .scrollBar(BarState.Off)
  }

  @Builder
  textRecommendBuilder() {
    List({ space: 12 }) {
      ForEach(Constants.recommendTextList, (item: string) => {
        ListItem() {
          Text(item)
            .fontSize(16)
            .onClick(() => {
              this.canvasItemStack.text = item
            })
        }
      }, (item: string) => item)
    }.width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }

  cleanText() {
    this.textTabIndex = 0;
    this.canvasItemStack = new CanvasTextItem('#000000', 16, 100, false, false, false, '鸿蒙黑体', '', 25, 25);
  }
}