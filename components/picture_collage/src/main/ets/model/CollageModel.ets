@Observed
export class PosterInfo {
  showImage: Resource;
  isVip?: boolean
  collageParts: PosterCollagePart[];
  posterImage?: Resource;

  constructor(showImage: Resource, collageParts: PosterCollagePart[], isVip?: boolean, posterImage?: Resource) {
    this.showImage = showImage;
    this.collageParts = collageParts;
    this.isVip = isVip
    this.posterImage = posterImage
  }
}

@Observed
export class PosterCollagePart {
  collagePositionX: Length;
  collagePositionY: Length;
  collageWidth: Length;
  collageHeight: Length;
  borderRadius: Length

  constructor(collagePositionX: Length, collagePositionY: Length, collageWidth: Length, collageHeight: Length,
    borderRadius: Length) {
    this.collagePositionX = collagePositionX;
    this.collagePositionY = collagePositionY;
    this.collageWidth = collageWidth;
    this.collageHeight = collageHeight;
    this.borderRadius = borderRadius;
  }
}

export class CollagePartSize {
  @Track offsetX: number
  @Track offsetY: number
  @Track scale: number
  @Track offsetStartX: number
  @Track offsetStartY: number
  @Track scaleStart: number

  constructor(offsetX: number, offsetY: number, scale: number, offsetStartX: number, offsetStartY: number,
    scaleStart: number) {
    this.offsetX = offsetX;
    this.offsetY = offsetY;
    this.scale = scale;
    this.offsetStartX = offsetStartX;
    this.offsetStartY = offsetStartY;
    this.scaleStart = scaleStart;
  }
}

export interface AreaConfig {
  id: string;
  rowStart: number;
  rowEnd: number;
  colStart: number;
  colEnd: number;
}


export interface DirectTemplate {
  imageResource: Resource;
  rowsTemplate: string;
  columnsTemplate: string;
  areas: AreaConfig[];
}