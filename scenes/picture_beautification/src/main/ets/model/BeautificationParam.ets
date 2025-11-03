import { ImageShowModel } from 'common';

export enum ActionType {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  left,
  right,
  top,
  bottom,
  move
}

export interface FilterModel extends ImageShowModel {
  filterOptions: FilterOptions
}

export interface FilterOptions {
  blur: number,
  invert: boolean,
  colorMatrix: Array<number>,
  brightness: number,
  grayscale: boolean
}

@Observed
export class StickerModel {
  id: string = ''
  positionX: number = 0
  positionY: number = 0
  img: ResourceStr = ''
}

@Observed
export class CanvasTextItem {
  @Track currentColor: string
  @Track fontSize: number
  @Track opacity: number
  @Track isBold: boolean
  @Track isItalics: boolean
  @Track isUnderline: boolean
  @Track font: string = 'HarmonyOS Sans Condensed';
  @Track text: string
  @Track dx: number
  @Track dy: number

  constructor(currentColor: string, fontSize: number, opacity: number, isBold: boolean, isItalics: boolean,
    isUnderline: boolean, font: string, text: string, dx: number, dy: number) {
    this.currentColor = currentColor
    this.fontSize = fontSize
    this.opacity = opacity
    this.isBold = isBold
    this.isItalics = isItalics
    this.isUnderline = isUnderline
    this.font = font
    this.text = text
    this.dx = dx
    this.dy = dy
  }

  clone(): CanvasTextItem {
    return new CanvasTextItem(this.currentColor, this.fontSize, this.opacity, this.isBold, this.isItalics,
      this.isUnderline, this.font, this.text, this.dx, this.dy)
  }
}
