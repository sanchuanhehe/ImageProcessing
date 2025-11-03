import { ImageShowModel, StickerShowModel } from 'common'
import { FilterModel } from './BeautificationParam'

export class Constants {
  static barList: ImageShowModel[] = [{
    imageSource: $r('app.media.beauty'),
    text: '美颜'
  }, {
    imageSource: $r('app.media.cropping'),
    text: '裁剪'
  }, {
    imageSource: $r('app.media.text'),
    text: '文字'
  }, {
    imageSource: $r('app.media.filters'),
    text: '滤镜'
  }, {
    imageSource: $r('app.media.sticker'),
    text: '贴纸'
  }]
  static beautyList: FilterModel[] = [{
    imageSource: $r('app.media.beauty_face'),
    text: '原生',
    isVip: false,
    filterOptions: {
      blur: 0,
      invert: false,
      colorMatrix: [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0],
      brightness: 0,
      grayscale: false
    }
  }, {
    imageSource: $r('app.media.beauty_face'),
    text: '黑白',
    isVip: true,
    filterOptions: {
      blur: 0,
      invert: false,
      colorMatrix: [
        1.3, -0.3, -0.3, 0, 0,
        -0.2, 1.2, -0.2, 0, 0,
        -0.1, -0.1, 0.8, 0, 0,
        0, 0, 0, 1, 0
      ],
      brightness: 0.15,
      grayscale: true
    }
  }, {
    imageSource: $r('app.media.beauty_face'),
    text: '粉色',
    isVip: false,
    filterOptions: {
      blur: 0,
      invert: false,
      colorMatrix: [
        1.08, 0.25, 0.35, 0, 0,
        0.22, 0.92, 0.22, 0, 0,
        0.35, 0.25, 0.95, 0, 0,
        0, 0, 0, 1, 0
      ],
      brightness: 0.12,
      grayscale: false
    }
  }, {
    imageSource: $r('app.media.beauty_face'),
    text: '蓝调',
    isVip: true,
    filterOptions: {
      blur: 0,
      invert: false,
      colorMatrix: [
        0.85, 0, 0, 0, -4,
        0, 0.85, -0.05, 0, 0,
        -0.15, 0.1, 1.3, 0, 0,
        0, 0, 0, 1, 0
      ],
      brightness: 0,
      grayscale: false
    }

  }]
  static cutList: ImageShowModel[] = [{
    imageSource: $r('app.media.cut_free'),
    text: '自由'
  }, {
    imageSource: $r('app.media.cut_back'),
    text: '壁纸'
  }, {
    imageSource: $r('app.media.cut_9_16'),
    text: '9:16'
  }, {
    imageSource: $r('app.media.cut_16_9'),
    text: '16:9'
  }, {
    imageSource: $r('app.media.cut_1_1'),
    text: '1:1'
  }, {
    imageSource: $r('app.media.cut_3_2'),
    text: '3:2'
  }, {
    imageSource: $r('app.media.cut_4_3'),
    text: '4:3'
  }]
  static carouseList: ImageShowModel[] = [{
    imageSource: $r('app.media.carouse_left'),
    text: '向左90°'
  }, {
    imageSource: $r('app.media.carouse_right'),
    text: '向右90°'
  }, {
    imageSource: $r('app.media.carouse_vertical'),
    text: '垂直'
  }, {
    imageSource: $r('app.media.carouse_level'),
    text: '水平'
  }]
  static filterTagList: string[] = ['最新', '热门', '基础', '质感']
  static filterList: FilterModel[] = [{
    imageSource: $r('app.media.filter1'),
    text: '原生',
    isVip: false,
    filterOptions: {
      blur: 0,
      invert: false,
      colorMatrix: [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0],
      brightness: 0,
      grayscale: false
    }
  }, {
    imageSource: $r('app.media.filter2'),
    text: '夏日夜景',
    isVip: true,
    filterOptions: {
      blur: 5,
      invert: false,
      colorMatrix: [0.7, 0.1, 0, 0, 0, 0, 0.6, 0.3, 0, 0, 0.2, 0.1, 1.2, 0, 0, 0, 0, 0, 1, 0],
      brightness: 0,
      grayscale: false
    }
  }, {
    imageSource: $r('app.media.filter3'),
    text: '秋日秋菊',
    isVip: true,
    filterOptions: {
      blur: 0,
      invert: false,
      colorMatrix: [1.5, 0.2, 0, 0, 0, 0.3, 1.3, 0, 0, 0, 0, 0, 0.8, 0, 0, 0, 0, 0, 1, 0],
      brightness: 0,
      grayscale: false
    }
  }, {
    imageSource: $r('app.media.filter4'),
    text: '夏日野营',
    isVip: false,
    filterOptions: {
      blur: 3,
      invert: false,
      colorMatrix: [0.9, 0.1, 0, 0, 0, 0, 1.3, 0, 0, 0, 0, 0.1, 0.8, 0, 0, 0, 0, 0, 1, 0],
      brightness: 0,
      grayscale: false
    }
  }, {
    imageSource: $r('app.media.filter1'),
    text: '粉肌',
    isVip: false,
    filterOptions: {
      blur: 4,
      invert: false,
      colorMatrix: [1.4, 0.2, 0.3, 0, 0, 0.1, 1.1, 0.2, 0, 0, 0.1, 0.1, 0.9, 0, 0, 0, 0, 0, 1, 0],
      brightness: 0,
      grayscale: false
    }
  }, {
    imageSource: $r('app.media.filter2'),
    text: '素白',
    isVip: false,
    filterOptions: {
      blur: 2,
      invert: false,
      colorMatrix: [1.2, 0, 0, 0, 0, 0, 1.2, 0, 0, 0, 0, 0, 1.2, 0, 0, 0, 0, 0, 1, 0],
      brightness: 0,
      grayscale: true
    }
  }, {
    imageSource: $r('app.media.filter4'),
    text: '透亮',
    isVip: true,
    filterOptions: {
      blur: 0,
      invert: false,
      colorMatrix: [1.1, 0, 0, 0, 0, 0, 1.1, 0, 0, 0, 0, 0, 1.1, 0, 0, 0, 0, 0, 1, 0],
      brightness: 0.2,
      grayscale: false
    }
  }, {
    imageSource: $r('app.media.filter4'),
    text: '蓝调增色',
    isVip: true,
    filterOptions: {
      blur: 0,
      invert: false,
      colorMatrix: [0.6, 0, 0.5, 0, 0, 0, 0.7, 0.8, 0, 0, 1.2, 0.3, 2.5, 0, 0, 0, 0, 0, 1, 0],
      brightness: 0,
      grayscale: false
    }
  }, {
    imageSource: $r('app.media.filter1'),
    text: '鲜花增色',
    isVip: true,
    filterOptions: {
      blur: 0,
      invert: false,
      colorMatrix: [1.4, 0.3, 0.2, 0, 0, 0.1, 1.3, 0.1, 0, 0, 0.1, 0.2, 1.0, 0, 0, 0, 0, 0, 1, 0],
      brightness: 0,
      grayscale: false
    }
  }, {
    imageSource: $r('app.media.filter2'),
    text: '蓝色烟花',
    isVip: true,
    filterOptions: {
      blur: 15,
      invert: false,
      colorMatrix: [0.5, 0, 0.8, 0, 0, 0, 0.6, 1.2, 0, 0, 0.3, 0, 1.5, 0, 0, 0, 0, 0, 1, 0],
      brightness: 0,
      grayscale: false
    }
  }, {
    imageSource: $r('app.media.filter3'),
    text: '粉色烟花',
    isVip: true,
    filterOptions: {
      blur: 15,
      invert: false,
      colorMatrix: [1.5, 0.2, 0.3, 0, 0, 0.1, 0.8, 0.4, 0, 0, 0.2, 0.1, 1.0, 0, 0, 0, 0, 0, 1, 0],
      brightness: 0,
      grayscale: false
    }
  }, {
    imageSource: $r('app.media.filter4'),
    text: '白茶',
    isVip: true,
    filterOptions: {
      blur: 2,
      invert: false,
      colorMatrix: [0.9, 0.1, 0, 0, 0, 0.2, 0.8, 0.1, 0, 0, 0.3, 0.2, 0.7, 0, 0, 0, 0, 0, 1, 0],
      brightness: 0,
      grayscale: false
    }
  }, {
    imageSource: $r('app.media.filter2'),
    text: '奶霜',
    isVip: true,
    filterOptions: {
      blur: 8,
      invert: false,
      colorMatrix: [1.3, 0.1, 0.1, 0, 0, 0.1, 1.3, 0.1, 0, 0, 0.1, 0.1, 1.3, 0, 0, 0, 0, 0, 1, 0],
      brightness: 0,
      grayscale: false
    }
  }]
  static fontColorList: string[] =
    ['#000000', '#FFFFFF', '#E52424', '#E56224', '#F6C800', '#63B959', '#48ADDD', '#5445EF', '#A946F1']
  static fontFamilyList: string[] =
    ['HarmonyOS Sans', 'HarmonyOS Sans Condensed', 'HarmonyOS Sans Digit', 'Noto Serif', 'Noto Sans Mono', '宋体']
  static recommendTextList: string[] = [
    '嗨👋，6月你好～',
    '👌，6月好心情持续营业～',
    '把6月好运一键生成给你',
    '今日份营业结束～',
    '每天多睡一分钟，早八路上练轻工',
    '练得身型似鹤形，不怕宫女勒脖颈'
  ]
  static stickerTagList: string[] = ['最新', '热门', '主题']
  static stickerList: StickerShowModel[] = [
    {
      imageSource: $r('app.media.sticker1'),
      isVip: false,
      text: '警告',
      tag: ['最新', '热门']
    },
    {
      imageSource: $r('app.media.sticker2'),
      isVip: false,
      text: '温度计',
      tag: ['最新', '热门']
    },
    {
      imageSource: $r('app.media.sticker3'),
      isVip: true,
      text: '电池',
      tag: ['最新', '热门']
    },
    {
      imageSource: $r('app.media.sticker4'),
      isVip: true,
      text: '铃',
      tag: ['最新', '热门']
    },
    {
      imageSource: $r('app.media.sticker5'),
      isVip: true,
      text: '放大镜',
      tag: ['最新', '主题']
    },
    {
      imageSource: $r('app.media.sticker6'),
      isVip: true,
      text: '日历',
      tag: ['最新', '主题']
    },
    {
      imageSource: $r('app.media.sticker7'),
      isVip: true,
      text: '指示',
      tag: ['最新', '主题']
    },
    {
      imageSource: $r('app.media.sticker8'),
      isVip: true,
      text: '页签',
      tag: ['最新', '主题']
    }
  ]
}

