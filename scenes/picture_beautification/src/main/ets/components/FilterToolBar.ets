import { FilterModel } from '../model/BeautificationParam';
import { Constants } from '../model/Constants';
import { ImageProcessingUtil } from '../util/ImageProcessingUtil';

@Component
export struct FilterToolBar {
  @Link barIndex: number
  @Link imagePixelMap: PixelMap
  @State filterTabIndex: number = 0;
  @State searchWord: string = ''
  @State onSearch: boolean = false
  @State filterList: FilterModel[] = Constants.filterList
  @State title: string = Constants.filterList[0].text
  private controller: SwiperController = new SwiperController()
  @State swiperIndex: number = 0
  tagSwiperIndex: number[] = [0, 3, 6, 9]
  saveImage?: () => void
  originImagePixelMap?: PixelMap = undefined
  @StorageProp('isVip') @Watch('vipChange') isVip: boolean = false
  @StorageProp('loginState') loginState: boolean = false;
  pathStack: NavPathStack = new NavPathStack()
  vipDialogController?: CustomDialogController
  @State wantIndex?: number = undefined

  build() {
    Column() {
      Row() {
        Image($r('app.media.xmark'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick(() => {
            this.barIndex = -1
            if (this.originImagePixelMap) {
              this.imagePixelMap = this.originImagePixelMap
            }
            this.cleanFilter()
          })
        Text(this.title)
          .fontSize(16)
        Image($r('app.media.checkMark'))
          .width(24)
          .height(24)
          .margin({ right: 16 })
          .onClick(() => {
            if (this.saveImage) {
              this.saveImage()
            }
            this.cleanFilter()
          })
      }
      .width('100%')
      .margin({ top: 14, bottom: 24 })
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Search({ placeholder: 'Search', value: $$this.searchWord })
          .layoutWeight(1)
          .margin({ left: 16, right: 20 })
          .onClick(() => {
            animateTo({ duration: 300 }, () => {
              this.onSearch = true
            })
          })
          .onSubmit(() => {
            this.updateList()
          })
        Row({ space: 24 }) {
          ForEach(Constants.filterTagList, (item: string, index: number) => {
            Text(item)
              .fontSize(16)
              .fontColor(this.filterTabIndex === index ? '#ED6F21' : Color.Black)
              .onClick(() => {
                this.filterTabIndex = index
                this.controller.changeIndex(this.tagSwiperIndex[index], true)
              })
          }, (item: string) => item)
        }
        .margin({ right: 16 })
        .visibility(this.onSearch ? Visibility.None : Visibility.Visible)

        Text('取消搜索')
          .fontSize(16)
          .margin({ right: 16 })
          .visibility(this.onSearch ? Visibility.Visible : Visibility.None)
          .onClick(() => {
            animateTo({ duration: 300 }, () => {
              this.onSearch = false
              this.searchWord = ''
              this.getUIContext().getFocusController().clearFocus()
              this.updateList()
            })
            this.controller.changeIndex(this.swiperIndex)
          })
      }
      .width('100%')
      .height(22)
      .margin({ left: 16, right: 16 })

      Row() {
        Swiper(this.controller) {
          ForEach(this.filterList, (item: FilterModel, index: number) => {
            Column() {
              Stack() {
                Image(item.imageSource)
                  .width(70)
                  .height(70)
                  .borderRadius(8)
                Image($r('app.media.image_vip'))
                  .width(16)
                  .height(16)
                  .visibility(item.isVip ? Visibility.Visible : Visibility.None)
              }
              .margin({ bottom: 4 })
              .alignContent(Alignment.BottomStart)

              Text(item.text)
                .fontSize(12)
                .height(18)
                .visibility(this.title === this.filterList[index].text ? Visibility.None : Visibility.Visible)
              Image($r('app.media.beauty_selected'))
                .width(18)
                .height(18)
                .visibility(this.title === this.filterList[index].text ? Visibility.Visible : Visibility.None)
            }.onClick(() => {
              if (item.isVip) {
                if (!this.loginState) {
                  this.pathStack.pushPath({ name: 'quickLoginPage' })
                } else {
                  if (!this.isVip) {
                    this.wantIndex = index
                    this.vipDialogController?.open()
                  } else {
                    this.title = this.filterList[index].text
                    this.filterImage(item)
                  }
                }
              } else {
                this.title = this.filterList[index].text
                this.filterImage(item)
              }
            })
          }, (item: FilterModel) => JSON.stringify(item))
        }
        .width('100%')
        .autoPlay(false)
        .loop(false)
        .displayCount(4)
        .effectMode(EdgeEffect.Spring)
        .indicator(false)
        .curve(Curve.Linear)
        .onChange((index: number) => {
          this.updateTabIndex(index)
          if (!this.onSearch) {
            this.swiperIndex = index
          }
        })
      }
      .margin({
        top: 24,
        bottom: 20,
        left: 16,
        right: 16
      })
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius({ topLeft: 16, topRight: 16 })
  }

  updateList() {
    if (this.onSearch) {
      this.filterList = Constants.filterList.filter(item => item.text.includes(this.searchWord))
    } else {
      this.filterList = Constants.filterList
    }
  }

  updateTabIndex(index: number) {
    if (index >= this.tagSwiperIndex[0] && index < this.tagSwiperIndex[1]) {
      this.filterTabIndex = 0
    } else if (index >= this.tagSwiperIndex[1] && index < this.tagSwiperIndex[2]) {
      this.filterTabIndex = 1
    } else if (index >= this.tagSwiperIndex[2] && index < this.tagSwiperIndex[3]) {
      this.filterTabIndex = 2
    } else {
      this.filterTabIndex = 3
    }
  }

  filterImage(item: FilterModel) {
    if (this.originImagePixelMap === undefined) {
      this.originImagePixelMap = this.imagePixelMap
    }
    ImageProcessingUtil.filterImage(item, this.originImagePixelMap)
      .then(data => {
        this.imagePixelMap = data
      })
  }

  cleanFilter() {
    this.filterTabIndex = 0;
    this.swiperIndex = 0;
    this.searchWord = ''
    this.onSearch = false
    this.title = Constants.filterList[0].text
  }

  vipChange() {
    if (this.isVip && this.wantIndex) {
      this.title = this.filterList[this.wantIndex].text
      this.filterImage(this.filterList[this.wantIndex])
      this.wantIndex = undefined
    }
  }
}