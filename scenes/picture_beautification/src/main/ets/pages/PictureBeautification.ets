import { BeautyParam, MockService, MyPosition, TitleBar } from 'common';
import { BeautyActionBar } from '../components/BeautyActionBar';
import { image } from '@kit.ImageKit';
import { ActionType, CanvasTextItem, StickerModel } from '../model/BeautificationParam';
import fs from '@ohos.file.fs';
import { ImageProcessingUtil } from '../util/ImageProcessingUtil';
import { componentSnapshot } from '@kit.ArkUI';
import { StickerComponent } from '../components/StickerComponent';
import { AddTextComponent } from '../components/AddTextComponent';

@Component
export struct PictureBeautification {
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @Prop pathStack: NavPathStack;
  @State pixelMapList: PixelMap[] = []
  @State currentPixelMap?: PixelMap = undefined;
  @State currentPixelMapIndex: number = 0
  @State totalPixelMapCount: number = 0
  @State barIndex: number = 0
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private maskContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private cropContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  @State imageArea: MyPosition = {
    x: 0,
    y: 0,
    width: 0,
    height: 0,
  }
  @State @Watch('drawMask') clipRect: MyPosition = {
    x: 0,
    y: 0,
    height: 0,
    width: 0
  };
  private touchPosition: MyPosition = {
    x: 0,
    y: 0,
  };
  private actionType: ActionType = ActionType.move;
  @State cropRatio: number = 0; // 固定裁剪比例，为0表示自由裁剪
  @State clipRectMaxH: number = 0;
  @State clipRectMaxW: number = 0;
  @State carouselCutTabIndex: number = 0;
  @State stickerList: StickerModel[] = []
  @State canvasItemStack: CanvasTextItem =
    new CanvasTextItem('#000000', 16, 100, false, false, false, 'Noto', '', 150, 200);
  @State saveText: boolean = false

  vipDialogController: CustomDialogController  = new CustomDialogController ({
    builder:this.toastVipBuilder
  });

  @Builder
  toastVipBuilder() {
    Column({ space: 16 }) {
      Column(){
        Text('当前内容需要开通会员后可体验，')
          .fontSize(14)
        Text( '是否立即前往开通会员？')
          .fontSize(14)
      }

      Text('前往开通')
        .fontSize(14)
        .fontColor('#FFAA00')
        .onClick(() => {
          this.vipDialogController.close()
          this.pathStack.pushPath({ name: 'openVip' })
        })
      Text('继续使用')
        .fontSize(14)
        .opacity(0.4)
        .onClick(()=>{
          this.vipDialogController.close()
        })
    }
    .padding(16)
    .borderRadius(16)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
  }

  build() {
    NavDestination() {
      TitleBar({
        title: this.getTitle(),
        isBack: true,
        pathStack: this.pathStack
      })
        .margin({ bottom: 20, left: 16, right: 16 })
      Column() {
        this.beautifyContentBuilder();
        BeautyActionBar({
          barIndex: this.barIndex,
          cropRatio: this.cropRatio,
          clipRect: this.clipRect,
          imageArea: this.imageArea,
          clipRectMaxH: this.clipRectMaxH,
          clipRectMaxW: this.clipRectMaxW,
          carouselCutTabIndex: this.carouselCutTabIndex,
          saveImage: this.saveImage,
          saveImageWithText: this.saveImageWithText,
          rotateImage: this.rotateImage,
          imagePixelMap: this.currentPixelMap,
          stickerList: this.stickerList,
          canvasItemStack: this.canvasItemStack,
          vipDialogController:this.vipDialogController,
          pathStack:this.pathStack
        })
          .margin({ top: 16, left: this.barIndex === -1 ? 16 : 0, right: this.barIndex === -1 ? 16 : 0 })
      }.justifyContent(FlexAlign.SpaceBetween)
      .layoutWeight(1)
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx.pathStack
      let param = ctx?.pathInfo?.param as BeautyParam;
      const uri = param.uris[0]
      this.initData(uri)
      this.barIndex = param.barIndex
    })
    .backgroundColor($r('app.color.main_background_color'))
    .padding({
      top: px2vp(this.topRectHeight),
      bottom: this.barIndex === -1 ? px2vp(this.bottomRectHeight) : 0
    })
  }

  @Builder
  beautifyContentBuilder() {
    Column() {
      Stack() {
        Row() {
          Image($r('app.media.cancel'))
            .height(24)
            .width(24)
            .opacity(this.totalPixelMapCount > 1 && this.currentPixelMapIndex !== 0 ? 0.8 :
              0.4)
            .onClick(() => {
              if (this.currentPixelMapIndex !== 0) {
                this.currentPixelMapIndex--;
                this.currentPixelMap = this.pixelMapList[this.currentPixelMapIndex]
              }
            })
          Image($r('app.media.recover'))
            .height(24)
            .width(24)
            .margin({ left: 24 })
            .opacity(this.totalPixelMapCount - 1 !== this.currentPixelMapIndex ? 0.8 : 0.4)
            .onClick(() => {
              if (this.currentPixelMapIndex !== this.totalPixelMapCount - 1) {
                this.currentPixelMapIndex++;
                this.currentPixelMap = this.pixelMapList[this.currentPixelMapIndex]
              }
            })
        }
        .width('100%')
        .height(40)
        .justifyContent(FlexAlign.Center)

        SaveButton({ text: SaveDescription.SAVE })
          .fontColor($r('sys.color.black'))
          .fontSize(16)
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .onClick(async (_event: ClickEvent, result: SaveButtonOnClickResult) => {
            if (result === SaveButtonOnClickResult.SUCCESS) {
              let pixelMap = this.pixelMapList[this.currentPixelMapIndex]
              MockService.saveImage(pixelMap)
            }
          })
      }
      .width('100%')
      .height(40)
      .alignContent(Alignment.End)
      .visibility(this.barIndex === -1 ? Visibility.Visible : Visibility.None)
      .margin({ bottom: 20 })

      Stack() {
        Stack() {
          Image(this.currentPixelMap)
            .width('100%')

          // 贴纸
          ForEach(this.stickerList, (item: StickerModel) => {
            StickerComponent({ item: item, onDelete: this.deleteSticker })
          }, (item: StickerModel) => item.id)

          if (this.barIndex === 2 || this.saveText) {
            AddTextComponent({
              canvasItemStack: this.canvasItemStack,
              saveText: this.saveText,
              saveImage: this.saveImage
            })
          }
        }.id('ImageContent')
        .onAreaChange((_value: Area, newVal: Area) => {
          // 获取图片位置xy
          this.imageArea.x = Math.round(newVal.position.x as number)
          this.imageArea.y = Math.round(newVal.position.y as number)
          this.clipRect.x = this.imageArea.x
          this.clipRect.y = this.imageArea.y
          this.clipRect.width = newVal.width as number
          this.clipRect.height = newVal.height as number
          this.imageArea.width = newVal.width as number
          this.imageArea.height = newVal.height as number
        })

        // 蒙层
        Canvas(this.maskContext)
          .position({
            x: this.imageArea.x,
            y: this.imageArea.y
          })
          .width(this.imageArea.width)
          .height(this.imageArea.height)
          .visibility(this.barIndex === 1 && this.carouselCutTabIndex === 0 ? Visibility.Visible : Visibility.None)
        // 裁剪框
        Canvas(this.cropContext)
          .position({
            x: this.clipRect.x - 2,
            y: this.clipRect.y - 2
          })
          .width(this.clipRect.width! + 4)
          .height(this.clipRect.height! + 4)
          .visibility(this.barIndex === 1 && this.carouselCutTabIndex === 0 ? Visibility.Visible : Visibility.None)
          .onReady(() => {
            this.drawClipImage()
          })
          .onTouch(event => {
            if (event.type === TouchType.Down) {
              this.isMove(event.target.area, event.touches[0]);
              this.touchPosition = {
                x: event.touches[0].displayX,
                y: event.touches[0].displayY
              }
            } else if (event.type === TouchType.Move) {
              let moveX = event.changedTouches[0].displayX - this.touchPosition.x;
              let moveY = event.changedTouches[0].displayY - this.touchPosition.y;
              this.touchPosition = {
                x: event.changedTouches[0].displayX,
                y: event.changedTouches[0].displayY
              }
              if (this.cropRatio === 0) {
                this.moveClipCanvasFreeType(moveX, moveY);
              } else {
                this.moveClipCanvasRatioType(moveX, moveY);
              }

            }
          })
        Image($r('app.media.switch'))
          .width(32)
          .height(32)
          .position({ bottom: 16, right: 16 })
          .visibility(this.barIndex === -1 ? Visibility.Visible : Visibility.None)
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              this.currentPixelMapIndex = 0
              this.currentPixelMap = this.pixelMapList[this.currentPixelMapIndex]
            } else if (event.type === TouchType.Up) {
              this.currentPixelMapIndex = this.totalPixelMapCount - 1
              this.currentPixelMap = this.pixelMapList[this.currentPixelMapIndex]
            }
          })
      }
      .width('100%')
      .height(this.barIndex === 2 || this.barIndex === 4 ? '60%' : '70%')
    }
    .margin({ left: 16, right: 16 })
  }

  initData(uri: string) {
    let resFile: fs.File = fs.openSync(uri, fs.OpenMode.READ_ONLY)
    try {
      const imageSource: image.ImageSource = image.createImageSource(resFile.fd);
      imageSource.createPixelMap().then((result: PixelMap) => {
        this.pushPixelMap(result)
      })
    } catch (err) {
      console.error('init data failed with error message: ' + err.message + ', error code: ' + err.code);
    } finally {
      fs.closeSync(resFile)
    }
  }

  // 绘制蒙层
  drawMask() {
    this.maskContext.clearRect(0, 0, this.imageArea.width, this.imageArea.height);
    this.maskContext.fillStyle = 'rgba(0,0,0,0.7)';
    this.maskContext.fillRect(0, 0, this.imageArea.width, this.imageArea.height);
    this.maskContext.clearRect(this.clipRect.x - this.imageArea.x, this.clipRect.y - this.imageArea.y,
      this.clipRect.width, this.clipRect.height);
  }

  // 绘制裁剪框
  drawClipImage() {
    let lineWidth = vp2px(2)
    let clipRectW = this.clipRect.width! + 4
    let clipRectH = this.clipRect.height! + 4
    this.cropContext.clearRect(2, 2, this.clipRect.width, this.clipRect.height);
    this.cropContext.lineWidth = lineWidth
    this.cropContext.strokeStyle = '#ffff00'
    this.cropContext.beginPath()

    this.cropContext.moveTo(0, 20)
    this.cropContext.lineTo(0, 0);
    this.cropContext.lineTo(20, 0);

    this.cropContext.moveTo(clipRectW / 2 - 10, 0)
    this.cropContext.lineTo(clipRectW / 2 + 10, 0);

    this.cropContext.moveTo(clipRectW - 20, 0);
    this.cropContext.lineTo(clipRectW, 0);
    this.cropContext.lineTo(clipRectW, 20);

    this.cropContext.moveTo(clipRectW, clipRectH / 2 - 10)
    this.cropContext.lineTo(clipRectW, clipRectH / 2 + 10);

    this.cropContext.moveTo(0, clipRectH - 20);
    this.cropContext.lineTo(0, clipRectH);
    this.cropContext.lineTo(20, clipRectH);

    this.cropContext.moveTo(clipRectW / 2 - 10, clipRectH)
    this.cropContext.lineTo(clipRectW / 2 + 10, clipRectH);

    this.cropContext.moveTo(clipRectW - 20, clipRectH);
    this.cropContext.lineTo(clipRectW, clipRectH);
    this.cropContext.lineTo(clipRectW, clipRectH - 20);

    this.cropContext.moveTo(0, clipRectH / 2 - 10)
    this.cropContext.lineTo(0, clipRectH / 2 + 10);

    this.cropContext.stroke()

    this.cropContext.beginPath();
    this.cropContext.lineWidth = 0.55;
    let height = Math.round((this.clipRect.height!) / 3);
    for (let index = 0; index <= 3; index++) {
      let y = index === 3 ? (this.clipRect.height) : height * index;
      this.cropContext.moveTo(2, y! + 2);
      this.cropContext.lineTo(this.clipRect.width, y! + 2);
    }
    let width = Math.round((this.clipRect.width!) / 3);
    for (let index = 0; index <= 3; index++) {
      let x = index === 3 ? (this.clipRect.width) : width * index;
      this.cropContext.moveTo(x! + 2, 2);
      this.cropContext.lineTo(x! + 2, this.clipRect.height! + 2);
    }
    this.cropContext.stroke();
  }

  // 判断操作类型
  isMove(area: Area, touch: TouchObject) {
    let touchW = 20
    if (this.cropRatio === 0) {
      if (touch.x < touchW && touch.y < touchW) { // 左上角
        this.actionType = ActionType.topLeft
      } else if (touch.x < touchW && touch.y > (Number(area.height) - touchW)) { // 左下
        this.actionType = ActionType.bottomLeft
      } else if (touch.x > Number(area.width) - touchW && touch.y < touchW) { // 右上
        this.actionType = ActionType.topRight
      } else if (touch.x > Number(area.width) - touchW && touch.y > (Number(area.height) - touchW)) { // 右下
        this.actionType = ActionType.bottomRight
      } else if (touch.x > touchW && (touch.x < Number(area.width) - touchW) && touch.y < touchW) { //上面
        this.actionType = ActionType.top
      } else if (touch.x > touchW && (touch.x < Number(area.width) - touchW) &&
        touch.y > (Number(area.height) - touchW)) { //下面
        this.actionType = ActionType.bottom
      } else if (touch.x < touchW && (touch.y < Number(area.height) - touchW) && touch.y > touchW) { //左面
        this.actionType = ActionType.left
      } else if (touch.x > Number(area.width) - touchW && (touch.y < Number(area.height) - touchW) &&
        touch.y > touchW) { //右面
        this.actionType = ActionType.right
      } else {
        this.actionType = ActionType.move
      }
    } else {
      if (touch.x < (Number(area.width) / 2) && touch.y < touchW ||
        touch.x < touchW && touch.y < (Number(area.height) / 2)) { // 左上角
        this.actionType = ActionType.topLeft
      } else if (touch.x < (Number(area.width) / 2) && touch.y > (Number(area.height) - touchW) ||
        touch.x < touchW && touch.y > (Number(area.height) / 2)) { // 左下
        this.actionType = ActionType.bottomLeft
      } else if (touch.x > Number(area.width) / 2 && touch.y < touchW ||
        touch.x > Number(area.width) - touchW && touch.y < (Number(area.height) / 2)) { // 右上
        this.actionType = ActionType.topRight
      } else if (touch.x > Number(area.width) / 2 && touch.y > (Number(area.height) - touchW) ||
        touch.x > Number(area.width) - touchW && touch.y > (Number(area.height) / 2)) { // 右下
        this.actionType = ActionType.bottomRight
      } else {
        this.actionType = ActionType.move
      }
    }
    console.debug('判断移动类型=' + JSON.stringify(this.actionType))
  }

  // 自由裁剪框变换    初始位置为图片的初始坐标 移动的坐标
  moveClipCanvasFreeType(moveX: number, moveY: number) {
    let clipRect: MyPosition = {
      x: this.clipRect.x,
      y: this.clipRect.y,
      width: this.clipRect.width,
      height: this.clipRect.height
    }
    switch (this.actionType) {
      case ActionType.move:
        clipRect.x += moveX;
        clipRect.y += moveY;
        break;
      case ActionType.topLeft:
        clipRect.x += moveX;
        clipRect.y += moveY;
        clipRect.width! += -moveX;
        clipRect.height! += -moveY;
        break;
      case ActionType.topRight:
        clipRect.y += moveY;
        clipRect.width! += moveX;
        clipRect.height! += -moveY;
        break;
      case ActionType.bottomLeft:
        clipRect.x += moveX;
        clipRect.width! += -moveX;
        clipRect.height! += moveY;
        break;
      case ActionType.bottomRight:
        clipRect.width! += moveX;
        clipRect.height! += moveY;
        break;
      case ActionType.top:
        clipRect.y += moveY;
        clipRect.height! += -moveY;
        break;
      case ActionType.bottom:
        clipRect.height! += moveY;
        break;
      case ActionType.left:
        clipRect.x += moveX;
        clipRect.width! += -moveX;
        break;
      case ActionType.right:
        clipRect.width! += moveX;
        break;
      default:
        break;
    }

    // 偏移坐标小于初始位置
    if (clipRect.x < this.imageArea.x) {
      clipRect.x = this.imageArea.x;
    }

    if (clipRect.y < this.imageArea.y) {
      clipRect.y = this.imageArea.y;
    }

    // 横坐标限制位置
    if (clipRect.width! + clipRect.x > this.imageArea.width! + this.imageArea.x) {
      if (this.actionType === ActionType.move) {
        clipRect.x = this.imageArea.width! + this.imageArea.x - clipRect.width!;
      } else {
        clipRect.width = this.imageArea.width! + this.imageArea.x - clipRect.x;
      }
    }

    // 纵坐标限制
    if (clipRect.height! + clipRect.y > this.imageArea.height! + this.imageArea.y) {
      if (this.actionType === ActionType.move) {
        clipRect.y = this.imageArea.height! + this.imageArea.y - clipRect.height!;
      } else {

        clipRect.height = this.imageArea.height! + this.imageArea.y - clipRect.y;
      }
    }

    this.clipRect = {
      x: Math.round(clipRect.x),
      y: Math.round(clipRect.y),
      width: Math.round(clipRect.width!),
      height: Math.round(clipRect.height!)
    };
    console.debug('移动裁剪框=' + JSON.stringify(this.clipRect))
  }

  // 固定裁剪框位置和大小变化    初始位置为图片的初始坐标 移动的坐标
  moveClipCanvasRatioType(moveX: number, moveY: number) {
    let clipRect: MyPosition = {
      x: this.clipRect.x,
      y: this.clipRect.y,
      width: this.clipRect.width,
      height: this.clipRect.height
    }

    switch (this.actionType) {
      case ActionType.move:
        clipRect.x += moveX;
        clipRect.y += moveY;
        break;
      case ActionType.topLeft:
        if (moveX > (moveY / this.cropRatio)) {
          moveX = moveY / this.cropRatio
        } else {
          moveY = moveX * this.cropRatio
        }
        clipRect.x += moveX;
        clipRect.y += moveY;
        clipRect.width! += -moveX;
        clipRect.height! += -moveY;
        break;
      case ActionType.topRight:
        //moveX和moveY，一种正数，另外一个必然是复数
        if (moveX > 0) {
          if (moveX > -(moveY / this.cropRatio)) {
            moveX = -moveY / this.cropRatio
          } else {
            moveY = -moveX * this.cropRatio
          }
        } else {
          if (moveX < -(moveY / this.cropRatio)) {
            moveX = -moveY / this.cropRatio
          } else {
            moveY = -moveX * this.cropRatio
          }
        }

        clipRect.y += moveY;
        clipRect.width! += moveX;
        clipRect.height! += -moveY;
        break;
      case ActionType.bottomLeft:
        //moveX和moveY，一种正数，另外一个必然是复数
        if (moveX > 0) {
          if (moveX > -(moveY / this.cropRatio)) {
            moveX = -moveY / this.cropRatio
          } else {
            moveY = -moveX * this.cropRatio
          }
        } else {
          if (moveX < -(moveY / this.cropRatio)) {
            moveX = -moveY / this.cropRatio
          } else {
            moveY = -moveX * this.cropRatio
          }
        }
        clipRect.x += moveX;
        clipRect.width! += -moveX;
        clipRect.height! += moveY;
        break;
      case ActionType.bottomRight:
        if (moveX < (moveY / this.cropRatio)) {
          moveX = moveY / this.cropRatio
        } else {
          moveY = moveX * this.cropRatio
        }
        clipRect.width! += moveX;
        clipRect.height! += moveY;
        break;
      default:
        break;
    }

    // 偏移坐标小于初始位置
    if (clipRect.x < this.imageArea.x) {
      clipRect.x = this.imageArea.x;
    }

    if (clipRect.y < this.imageArea.y) {
      clipRect.y = this.imageArea.y;
    }

    // 横坐标限制位置
    if (clipRect.width! + clipRect.x > this.imageArea.width! + this.imageArea.x) {
      if (this.actionType === ActionType.move) {
        clipRect.x = this.imageArea.width! + this.imageArea.x - clipRect.width!;
      } else {
        clipRect.width = this.imageArea.width! + this.imageArea.x - clipRect.x;
      }
    }

    // 纵坐标限制
    if (clipRect.height! + clipRect.y > this.imageArea.height! + this.imageArea.y) {
      if (this.actionType === ActionType.move) {
        clipRect.y = this.imageArea.height! + this.imageArea.y - clipRect.height!;
      } else {
        clipRect.height = this.imageArea.height! + this.imageArea.y - clipRect.y;
      }
    }
    if (clipRect.height! > this.clipRectMaxH) {
      clipRect.height = this.clipRectMaxH
    }

    if (clipRect.width! > this.clipRectMaxW) {
      clipRect.width = this.clipRectMaxW
    }

    this.clipRect = {
      x: Math.round(clipRect.x),
      y: Math.round(clipRect.y),
      width: Math.round(clipRect.width!),
      height: Math.round(clipRect.height!)
    };
    //console.debug('移动裁剪框=' + JSON.stringify(this.clipRect))
  }

  deleteSticker: (id: string) => void = (id: string) => {
    this.stickerList = this.stickerList.filter(item => item.id !== id);
  }
  // 保存图片
  saveImage: () => void = () => {
    let pixelMapOrigin = componentSnapshot.getSync('ImageContent')
    let imageInfo = pixelMapOrigin.getImageInfoSync()
    let ratioX = imageInfo.size.width / this.imageArea.width!;
    let ratioY = imageInfo.size.height / this.imageArea.height!;
    let x = this.clipRect.x - this.imageArea.x;
    let y = this.clipRect.y - this.imageArea.y;
    let pixelMap = ImageProcessingUtil.getRectanglePixelMap(pixelMapOrigin as PixelMap, Math.round(x * ratioX),
      Math.round(y * ratioY), Math.round(this.clipRect.width! * ratioX), Math.round(this.clipRect.height! * ratioY))
    this.pushPixelMap(pixelMap)
    this.barIndex = -1
  }
  saveImageWithText: () => void = () => {
    this.saveText = true
  }
  // 旋转图片
  rotateImage: (rotate: number) => void = (rotate: number) => {
    let pixelMap = componentSnapshot.getSync('ImageContent')
    if (rotate === 360) {
      pixelMap?.flipSync(true, false);
    } else {
      pixelMap?.rotateSync(rotate)
    }
    this.currentPixelMap = pixelMap
  }

  getTitle(): string {
    switch (this.barIndex) {
      case 0:
        return '一键美颜'
      case 1:
        return '裁剪旋转'
      case 2:
        return '添加文字'
      case 3:
        return '添加滤镜'
      case 4:
        return '添加贴纸'
      default:
        return '美化图片'
    }
  }

  pushPixelMap(pixelMap: PixelMap) {
    this.currentPixelMap = pixelMap
    if (this.pixelMapList.length - 1 > this.currentPixelMapIndex) {
      this.pixelMapList = this.pixelMapList.slice(0, this.currentPixelMapIndex)
    }
    this.pixelMapList.push(pixelMap)
    this.totalPixelMapCount = this.pixelMapList.length
    this.currentPixelMapIndex = this.pixelMapList.length - 1
  }
}
