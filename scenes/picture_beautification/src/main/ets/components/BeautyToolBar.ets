import { FilterModel } from '../model/BeautificationParam';
import { Constants } from '../model/Constants';
import { faceDetector } from '@kit.CoreVisionKit';
import { ImageProcessingUtil } from '../util/ImageProcessingUtil';

@Component
export struct BeautyToolBar {
  @State selectIndex: number = 0;
  @Link barIndex: number
  originImagePixelMap?: PixelMap = undefined
  @Link imagePixelMap: PixelMap
  saveImage?: () => void
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
            this.selectIndex = 0
          })
        Text(Constants.beautyList[this.selectIndex].text)
          .fontSize(16)
        Image($r('app.media.checkMark'))
          .width(24)
          .height(24)
          .margin({ right: 16 })
          .onClick(() => {
            if (this.saveImage) {
              this.saveImage()
            }
            this.selectIndex = 0
          })
      }
      .width('100%')
      .margin({ top: 14 })
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Row() {
          ForEach(Constants.beautyList, (item: FilterModel, index: number) => {
            Column() {
              Stack() {
                Image(item.imageSource)
                  .width(50)
                  .height(68)
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
                .visibility(this.selectIndex === index ? Visibility.None : Visibility.Visible)
              Image($r('app.media.beauty_selected'))
                .width(18)
                .height(18)
                .visibility(this.selectIndex === index ? Visibility.Visible : Visibility.None)
            }.onClick(() => {
              if (item.isVip) {
                if (!this.loginState) {
                  this.pathStack.pushPath({ name: 'quickLoginPage' })
                } else {
                  if (!this.isVip) {
                    this.wantIndex = index
                    this.vipDialogController?.open()
                  } else {
                    this.selectIndex = index
                    this.filterImage(item)
                  }
                }
              } else {
                this.selectIndex = index
                this.filterImage(item)
              }
            })
          }, (item: FilterModel) => JSON.stringify(item))
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
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

  detectFaces() {
    faceDetector.init({ faceBlock: true }).then((initResult) => {
      if (initResult) {
        faceDetector.detect({ pixelMap: this.imagePixelMap }).then((result: faceDetector.Face[]) => {
          result.forEach((face: faceDetector.Face) => {
            const rect = face.rect
            this.applyBeautyFilter(this.imagePixelMap, rect)
          })
        })
      }
    });
  }

  applyBeautyFilter(pixelMap: PixelMap, faceRect: faceDetector.FaceRectangle) {
    // 获取图像尺寸
    const imgInfo = pixelMap.getImageInfoSync();
    const width = imgInfo.size.width;
    const height = imgInfo.size.height;

    // 读取像素数据（RGBA_8888格式）
    const pixels: Uint8Array = new Uint8Array(width * height * 4);
    pixelMap.readPixelsSync({
      pixels: pixels,
      offset: 0,
      stride: width * 4,
      region: {
        x: 0,
        y: 0,
        size: {
          width,
          height
        }
      }
    });

    // 对人脸区域进行平滑处理
    for (let y = faceRect.top; y < faceRect.top + faceRect.height; y++) {
      for (let x = faceRect.left; x < faceRect.left + faceRect.width; x++) {
        const pixelIndex = (y * width + x) * 4;
        this.smoothPixel(pixels, pixelIndex, width);
      }
    }

    // 写回处理后的像素
    pixelMap.writePixelsSync({
      pixels: pixels,
      offset: 0,
      stride: width * 4,
      region: {
        x: 0,
        y: 0,
        size: {
          width,
          height
        }
      }
    });
  }

  /**
   * 平滑单个像素（3x3邻域平均算法）
   * @param pixels - 像素数组
   * @param index - 当前像素索引
   * @param width - 图像宽度
   */
  smoothPixel(pixels: Uint8Array, index: number, width: number): void {
    let r = 0, g = 0, b = 0, count = 0;
    const offsets = [-4, 0, 4]; // RGBA_8888每个像素占4字节

    // 3x3邻域采样
    for (const dy of offsets) {
      for (const dx of offsets) {
        const neighborIndex = index + dy * width + dx;
        if (neighborIndex >= 0 && neighborIndex < pixels.length) {
          r += pixels[neighborIndex];
          g += pixels[neighborIndex + 1];
          b += pixels[neighborIndex + 2];
          count++;
        }
      }
    }

    // 计算平均值并更新像素
    pixels[index] = r / count; // Red
    pixels[index + 1] = g / count; // Green
    pixels[index + 2] = b / count; // Blue
    // Alpha通道保持不变 (pixels[index + 3])
  }

  filterImage(item: FilterModel) {
    if (this.originImagePixelMap === undefined) {
      this.detectFaces()
      this.originImagePixelMap = this.imagePixelMap
    }
    ImageProcessingUtil.filterImage(item, this.originImagePixelMap)
      .then(data => {
        this.imagePixelMap = data
      })
  }

  vipChange() {
    if (this.isVip && this.wantIndex) {
      this.selectIndex = this.wantIndex
      this.filterImage(Constants.beautyList[this.wantIndex])
      this.wantIndex = undefined
    }
  }
}