import { StickerShowModel } from 'common';
import { StickerModel } from '../model/BeautificationParam';
import { Constants } from '../model/Constants';
import { JSON, util } from '@kit.ArkTS';

@Component
export struct StickerToolBar {
  @Link barIndex: number
  @State stickerTabIndex: number = 0;
  private stickerController: TabsController = new TabsController();
  @State searchList: StickerShowModel[] = []
  @Link stickerList: StickerModel[]
  saveImage?: () => void
  @StorageProp('isVip') @Watch('vipChange') isVip: boolean = false
  @StorageProp('loginState') loginState: boolean = false;
  pathStack: NavPathStack = new NavPathStack()
  vipDialogController?: CustomDialogController
  @State wantSticker?: StickerModel = undefined

  build() {
    Column() {
      Row() {
        Image($r('app.media.xmark'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick(() => {
            this.barIndex = -1
            this.cleanSticker()
          })
        Text('2.5D贴纸')
          .fontSize(16)
        Image($r('app.media.checkMark'))
          .width(24)
          .height(24)
          .margin({ right: 16 })
          .onClick(() => {
            if (this.saveImage) {
              this.saveImage()
            }
            this.cleanSticker()
          })
      }
      .width('100%')
      .margin({ top: 14, bottom: 24 })
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Row({ space: 24 }) {
          ForEach(Constants.stickerTagList, (item: string, index: number) => {
            Text(item)
              .fontSize(16)
              .fontColor(this.stickerTabIndex === index ? '#ED6F21' : Color.Black)
              .onClick(() => {
                this.stickerTabIndex = index
                this.stickerController.changeIndex(index);
              })
          }, (item: string) => item)
        }
        .margin({ left: 16, right: 16 })
      }
      .width('100%')
      .height(22)
      .margin({ left: 16, right: 16 })

      Tabs({ barPosition: BarPosition.Start, controller: this.stickerController }) {
        ForEach(Constants.stickerTagList, (item: string) => {
          TabContent() {
            this.stickerContentBuilder(this.getList(item))
          }
        }, (item: string) => item)
      }
      .height(180)
      .barHeight(0)

      Row() {
        Grid() {
          ForEach(this.searchList, (item: StickerShowModel) => {
            GridItem() {
              Stack() {
                Image(item.imageSource)
                  .height(68)
                Image($r('app.media.image_vip'))
                  .width(16)
                  .height(16)
                  .visibility(item.isVip ? Visibility.Visible : Visibility.None)
              }
              .height(68)
              .backgroundColor($r('app.color.main_background_color'))
              .borderRadius(8)
              .alignContent(Alignment.BottomStart)
              .onClick(() => {
                if (item.isVip) {
                  if (!this.loginState) {
                    this.pathStack.pushPath({ name: 'quickLoginPage' })
                  } else {
                    if (!this.isVip) {
                      this.wantSticker = {
                        id: util.generateRandomUUID(),
                        positionX: 0,
                        positionY: 0,
                        img: item.imageSource
                      }
                      this.vipDialogController?.open()
                    } else {
                      this.stickerList.push({
                        id: util.generateRandomUUID(),
                        positionX: 0,
                        positionY: 0,
                        img: item.imageSource
                      })
                    }
                  }
                } else {
                  this.stickerList.push({
                    id: util.generateRandomUUID(),
                    positionX: 0,
                    positionY: 0,
                    img: item.imageSource
                  })
                }
              })
            }
          }, (item: StickerShowModel) => JSON.stringify(item))
        }
        .height(152)
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .rowsGap(16)
        .columnsGap(19)
        .margin({ left: 16, right: 16 })
      }
      .height(180)
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius({ topLeft: 16, topRight: 16 })
  }

  @Builder
  stickerContentBuilder(list: StickerShowModel[]) {
    Grid() {
      ForEach(list, (item: StickerShowModel) => {
        GridItem() {
          Stack() {
            Image(item.imageSource)
              .height(68)
            Image($r('app.media.image_vip'))
              .width(16)
              .height(16)
              .visibility(item.isVip ? Visibility.Visible : Visibility.None)
          }
          .height(68)
          .backgroundColor($r('app.color.main_background_color'))
          .borderRadius(8)
          .alignContent(Alignment.BottomStart)
          .onClick(() => {
            if(item.isVip) {
              if (!this.loginState) {
                this.pathStack.pushPath({ name: 'quickLoginPage' })
              } else {
                if (!this.isVip) {
                  this.wantSticker = {
                    id: util.generateRandomUUID(),
                    positionX: 0,
                    positionY: 0,
                    img: item.imageSource
                  }
                  this.vipDialogController?.open()
                } else {
                  this.stickerList.push({
                    id: util.generateRandomUUID(),
                    positionX: 0,
                    positionY: 0,
                    img: item.imageSource
                  })
                }
              }
            } else {
              this.stickerList.push({
                id: util.generateRandomUUID(),
                positionX: 0,
                positionY: 0,
                img: item.imageSource
              })
            }
          })
        }
      }, (item: StickerShowModel) => JSON.stringify(item))
    }
    .height(152)
    .columnsTemplate('1fr 1fr 1fr 1fr')
    .rowsGap(16)
    .columnsGap(19)
    .margin({ left: 16, right: 16 })
  }

  getList(tag?: string): StickerShowModel[] {
    let list: StickerShowModel[] = []
    if (tag) {
      list = Constants.stickerList.filter((item) => item.tag.includes(tag))
      return list
    }
    return list
  }

  cleanSticker() {
    this.stickerTabIndex = 0;
    this.stickerList = []
  }

  vipChange() {
    if (this.isVip && this.wantSticker) {
      this.stickerList.push(this.wantSticker)
      this.wantSticker = undefined
    }
  }
}