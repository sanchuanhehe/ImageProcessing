import { DirectTemplate, PosterCollagePart, PosterInfo } from '../model/CollageModel'

@Component
export struct CollageBar {
  pathStack: NavPathStack = new NavPathStack()
  @Link @Watch('barIndexChange') barIndex: number
  tabTitle: string[] = ['直接拼图', '海报', '模板拼接']
  barTabController: TabsController = new TabsController()
  @State selectDirectIndex: number = 0
  @State posterTabIndex: number = 0
  tagSwiperIndex: number[] = [0, 1, 2, 3]
  private controller: SwiperController = new SwiperController()
  @State swiperIndex: number = 0
  @Link currentDirectCollageTemplate: DirectTemplate
  @Link selectPoster: PosterInfo
  @Prop imageUris: string[]
  @Link showBar: boolean
  @Prop directTemplates: DirectTemplate[]
  @Prop posterList: PosterInfo[] = []
  @Prop templateList: PosterInfo[] = []
  clickVipCallBack?: () => void
  @StorageProp('isVip') @Watch('vipChange') isVip: boolean = false
  @State wantIndex?: number = undefined
  @State wantPoster?: PosterInfo = undefined

  aboutToAppear(): void {
    this.barIndexChange()
  }

  barIndexChange() {
    if (this.barIndex === -1) {
      return
    }
    if (this.barIndex !== 0) {
      this.swiperIndex = 0
      if (this.barIndex === 1) {
        this.selectPoster = this.copyPoster(this.posterList[this.swiperIndex])
      } else {
        this.selectPoster = this.copyPoster(this.templateList[this.swiperIndex])
      }
    }
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.xmark'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick(() => {
            this.showBar = false
          })

        Row({ space: 32 }) {
          ForEach(this.tabTitle, (item: string, index: number) => {
            Text(item)
              .fontColor(this.barIndex === index ? '#ED6F21' : Color.Black)
              .fontSize(16)
              .fontWeight(this.barIndex === index ? FontWeight.Medium : FontWeight.Regular)
              .onClick(() => {
                this.barIndex = index
                this.barTabController.changeIndex(index);
              })
          }, (item: string) => item)
        }

        Image($r('app.media.checkMark'))
          .width(24)
          .height(24)
          .margin({ right: 16 })
          .onClick(() => {
            this.showBar = false
          })
      }
      .width('100%')
      .margin({ top: 14 })
      .justifyContent(FlexAlign.SpaceBetween)

      Tabs({ barPosition: BarPosition.Start, controller: this.barTabController }) {
        TabContent() {
          this.directCollageBuilder()
        }

        TabContent() {
          this.posterCollageBuilder(this.posterList)
        }

        TabContent() {
          this.posterCollageBuilder(this.templateList)
        }
      }
      .height(this.barIndex === 0 ? 80 : 120)
      .barHeight(0)
      .onChange((index: number) => {
        this.barIndex = index
      })
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius({ topLeft: 16, topRight: 16 })
  }

  @Builder
  directCollageBuilder() {
    Row() {
      ForEach(this.directTemplates, (item: DirectTemplate, index: number) => {
        Image(item.imageResource)
          .width(44)
          .height(44)
          .fillColor(this.selectDirectIndex === index ? '#ED6F21' : '#000000')
          .onClick(() => {
            this.selectDirectIndex = index
            this.currentDirectCollageTemplate = this.directTemplates[index]
          })
      }, (item: DirectTemplate) => JSON.stringify(item))
    }.width('100%')
    .justifyContent(FlexAlign.SpaceAround)
  }

  @Builder
  posterCollageBuilder(posterList: PosterInfo[]) {
    Column() {
      Row() {
        Swiper(this.controller) {
          ForEach(posterList, (item: PosterInfo, index: number) => {
            Column() {
              Stack() {
                Image(item.showImage)
                  .width(70)
                  .height(70)
                  .borderRadius(8)
                  .objectFit(ImageFit.Contain)
                Image($r('app.media.image_vip'))
                  .width(16)
                  .height(16)
                  .visibility(item.isVip ? Visibility.Visible : Visibility.None)
              }
              .margin({ bottom: 4 })
              .alignContent(Alignment.BottomStart)
              .borderColor(this.swiperIndex === index ? '#ED6F21' : Color.Transparent)
              .borderWidth(2)
              .borderRadius(8)
              .borderStyle(BorderStyle.Solid)
            }.onClick(() => {
              if (this.clickVipCallBack && item.isVip && !this.isVip) {
                this.wantIndex = index
                this.wantPoster = this.copyPoster(posterList[index])
                this.clickVipCallBack()
              } else {
                this.swiperIndex = index
                this.selectPoster = this.copyPoster(posterList[index])
              }
            })
          }, (item: PosterInfo) => JSON.stringify(item))
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
          this.swiperIndex = index
        })
      }
      .width('100%')
    }
    .margin({
      top: 25,
      left: 16,
      right: 16,
      bottom: 20,
    })
  }

  updateTabIndex(index: number) {
    if (index >= this.tagSwiperIndex[0] && index < this.tagSwiperIndex[1]) {
      this.posterTabIndex = 0
    } else if (index >= this.tagSwiperIndex[1] && index < this.tagSwiperIndex[2]) {
      this.posterTabIndex = 1
    } else if (index >= this.tagSwiperIndex[2] && index < this.tagSwiperIndex[3]) {
      this.posterTabIndex = 2
    } else {
      this.posterTabIndex = 3
    }
  }

  copyPoster(origin: PosterInfo): PosterInfo {
    let collage: PosterCollagePart[] = []
    origin.collageParts.forEach((item: PosterCollagePart) => {
      collage.push(
        new PosterCollagePart(item.collagePositionX, item.collagePositionY, item.collageWidth, item.collageHeight,
          item.borderRadius))
    })
    return new PosterInfo(origin.showImage, collage, origin.isVip, origin.posterImage)
  }

  vipChange() {
    if (this.isVip && this.wantIndex) {
      this.swiperIndex = this.wantIndex
      this.selectPoster = this.wantPoster!
      this.wantIndex = undefined
      this.wantPoster = undefined
    }
  }
}