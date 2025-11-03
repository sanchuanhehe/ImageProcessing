import { AreaConfig, DirectTemplate } from '../model/CollageModel';
import { ImageShow } from './ImageShowComponent';

@Component
export struct DirectCollageComponent {
  @Link @Watch('setImageMap') currentDirectCollageTemplate: DirectTemplate
  @State imageMap: Map<string, string> = new Map();
  @Prop @Watch('setImageMap') imageUris: string[]

  onDidBuild(): void {
    this.setImageMap()
  }

  setImageMap() {
    for (let i = 0; i < this.currentDirectCollageTemplate.areas.length; i++) {
      let areaId = this.currentDirectCollageTemplate.areas[i].id
      // 选择图片比模板格子少的时候，循环填充
      this.imageMap.set(areaId, this.imageUris[i%this.imageUris.length]);
    }
  }

  build() {
    Column() {
      Grid() {
        ForEach(this.currentDirectCollageTemplate.areas, (area: AreaConfig) => {
          GridItem() {
            ImageShow({ imageUri: this.imageMap.get(area.id) })
          }
          .clip(true)
          .rowStart(area.rowStart)
          .rowEnd(area.rowEnd)
          .columnStart(area.colStart)
          .columnEnd(area.colEnd)
        }, (item: AreaConfig) => JSON.stringify(item))
      }
      .rowsTemplate(this.currentDirectCollageTemplate.rowsTemplate)
      .columnsTemplate(this.currentDirectCollageTemplate.columnsTemplate)
      .width('100%')
      .height('100%')
    }
  }
}