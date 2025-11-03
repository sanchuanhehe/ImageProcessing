export interface BeautyParam {
  uris: string[]
  barIndex: number;
}

export interface ImageShowModel {
  imageSource: Resource
  text: string
  isVip?: boolean
  needDownload?: boolean
}

export interface DraftModel {
  id:string
  uri: string
  updateTime: string
}

export interface StickerShowModel extends ImageShowModel {
  tag: string[]
}

export interface MyPosition {
  x: number;
  y: number;
  width?: number;
  height?: number;
}