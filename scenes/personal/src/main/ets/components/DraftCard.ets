import { DraftModel, MockService } from 'common'

@Component
export struct DraftCard {
  @State draftList: DraftModel[] = []
  @StorageProp('draftChange') @Watch('updateDraftList') draftChange: boolean = false

  aboutToAppear(): void {
    this.updateDraftList()
  }

  build() {
    Column() {
      Row() {
        Text('我的草稿')
          .fontSize(16)
        Image($r('app.media.forward'))
          .width(13)
          .height(13)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Row({ space: 14 }) {
        ForEach(this.draftList, (item: DraftModel) => {
          this.draftBuilder(item)
        }, (item: DraftModel) => JSON.stringify(item))
      }
      .margin({ top: 14 })
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .visibility(this.draftList.length > 0 ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .padding(12)
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
  }

  @Builder
  draftBuilder(draft: DraftModel) {
    Column() {
      Image(draft.uri)
        .width(92)
        .height(86)
        .borderRadius(8)
        .margin({ bottom: 4 })
        .objectFit(ImageFit.Cover)
      Text(draft.updateTime)
        .fontSize(10)
    }
    .layoutWeight(1)
  }

  updateDraftList() {
    if (MockService.draftList.length >= 3) {
      this.draftList = MockService.draftList.slice(0, 3)
    } else {
      this.draftList = MockService.draftList
    }
  }
}