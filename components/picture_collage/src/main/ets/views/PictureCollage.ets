import { CollageBar } from '../components/CollageBar'
import { DirectCollageComponent } from '../components/DirectCollageComponent'
import { PosterCollage } from '../components/PosterCollage'
import { DirectTemplate, PosterCollagePart, PosterInfo } from '../model/CollageModel'

@Component
export struct PictureCollage {
  @State templateList: PosterInfo[] = [
    new PosterInfo($r('app.media.poster1'),
      [
        new PosterCollagePart(0, 0, '100%', '100%', 0),
        new PosterCollagePart('40%', '40%', 200, 200, 100),
      ],
      false),
    new PosterInfo($r('app.media.poster2'),
      [
        new PosterCollagePart(0, 0, '100%', '100%', 0),
        new PosterCollagePart('12%', '5%', 100, 100, 50),
        new PosterCollagePart('10%', '60%', 150, 150, 100),
      ],
      false)
  ]
  @State posterList: PosterInfo[] = [
    new PosterInfo($r('app.media.poster5'),
      [
        new PosterCollagePart('28.3%', '27%', '21%', '54%', 0),
        new PosterCollagePart('53.8%', '27%', '21%', '54%', 0),
      ],
      false, $r('app.media.poster5_back')),
    new PosterInfo($r('app.media.poster7'),
      [
        new PosterCollagePart('7%', '32.5%', '25%', '55%', 0),
        new PosterCollagePart('37.5%', '13.4%', '25%', '55%', 0),
        new PosterCollagePart('67.7%', '32.5%', '25%', '55%', 0),
      ],
      false, $r('app.media.poster7_back'))
  ]
  @State directTemplates: DirectTemplate[] = [{
    rowsTemplate: '1fr 1fr',
    columnsTemplate: '1fr 1fr',
    imageResource: $r('app.media.direct1'),
    areas: [
      {
        id: 'top',
        rowStart: 0,
        rowEnd: 0,
        colStart: 0,
        colEnd: 1
      }, // 跨两列
      {
        id: 'leftBottom',
        rowStart: 1,
        rowEnd: 1,
        colStart: 0,
        colEnd: 0
      },
      {
        id: 'rightBottom',
        rowStart: 1,
        rowEnd: 1,
        colStart: 1,
        colEnd: 1
      }
    ]
  },
  {
    rowsTemplate: '1fr 1fr',
    columnsTemplate: '1fr 1fr',
    imageResource: $r('app.media.direct4'),
    areas: [
      {
        id: 'left',
        rowStart: 0,
        rowEnd: 1,
        colStart: 0,
        colEnd: 0
      }, // 跨两行
      {
        id: 'right',
        rowStart: 0,
        rowEnd: 1,
        colStart: 1,
        colEnd: 1
      }
    ]
  }]
  @State @Watch('changeIndex') barIndex: number = 0
  @State currentDirectCollageTemplate: DirectTemplate = this.directTemplates[0]
  @State selectPoster: PosterInfo = new PosterInfo($r('app.media.direct1'),
    [
      new PosterCollagePart(0, 0, '100%', '100%', 0),
      new PosterCollagePart('40%', '40%', 200, 200, 100),
    ],
    false)
  @Prop @Watch('filterTemplates') imageUris: string[] = []
  @State showBar: boolean = true
  indexChange?: (index: number) => void
  clickVipCallBack?: () => void

  aboutToAppear(): void {
    this.filterTemplates()
  }

  build() {
    Column() {
      Row() {
        if (this.barIndex === 0) {
          DirectCollageComponent({
            currentDirectCollageTemplate: this.currentDirectCollageTemplate,
            imageUris: this.imageUris
          })
            .layoutWeight(1)
        } else {
          PosterCollage({ imageUris: this.imageUris, barIndex: this.barIndex, selectedPoster: this.selectPoster })
            .layoutWeight(1)
        }
      }
      .margin({ left: 16, right: 16 })
      .height('70%')
      .id('PosterCollageContent')

      CollageBar({
        currentDirectCollageTemplate: this.currentDirectCollageTemplate,
        barIndex: this.barIndex,
        selectPoster: this.selectPoster,
        imageUris: this.imageUris,
        showBar: this.showBar,
        posterList: this.posterList,
        templateList: this.templateList,
        directTemplates: this.directTemplates,
        clickVipCallBack: this.clickVipCallBack
      })
        .margin({ top: 16 })
        .visibility(this.showBar ? Visibility.Visible : Visibility.None)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .layoutWeight(1)
  }

  changeIndex() {
    if (this.indexChange) {
      this.indexChange(this.barIndex)
    }
  }

  filterTemplates() {
    if (this.imageUris.length > 1) {
      this.directTemplates =
        this.directTemplates.filter((item: DirectTemplate) => item.areas.length === this.imageUris.length)
      this.templateList =
        this.templateList.filter((item: PosterInfo) => item.collageParts.length === this.imageUris.length)
      this.posterList = this.posterList.filter((item: PosterInfo) => item.collageParts.length === this.imageUris.length)
    }
    this.selectPoster = this.templateList[0]
    this.currentDirectCollageTemplate = this.directTemplates[0]
  }
}