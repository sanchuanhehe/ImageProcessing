import { DirectTemplate, PosterCollagePart, PosterInfo } from 'picture_collage';

export class Constants {
  static templateList: PosterInfo[] = [
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
      false),
    new PosterInfo($r('app.media.poster3'),
      [
        new PosterCollagePart(0, 0, '50%', '100%', 0),
        new PosterCollagePart('50%', 0, '50%', '50%', 0),
        new PosterCollagePart('50%', '50%', '50%', '50%', 0),
      ],
      false),
    new PosterInfo($r('app.media.poster4'),
      [
        new PosterCollagePart(0, 0, '50%', '30%', 0),
        new PosterCollagePart('5%', '20%', '90%', '60%', 20),
        new PosterCollagePart('50%', '70%', '50%', '30%', 0),
      ],
      true)
  ]
  static posterList: PosterInfo[] = [
    new PosterInfo($r('app.media.poster5'),
      [
        new PosterCollagePart('28.3%', '27%', '21%', '54%', 0),
        new PosterCollagePart('53.8%', '27%', '21%', '54%', 0),
      ],
      false, $r('app.media.poster5_back')),
    new PosterInfo($r('app.media.poster6'),
      [
        new PosterCollagePart('20%', '18%', '60%', '60%', 0),
        new PosterCollagePart('73.3%', '32%', '15.5%', '53.5%', 0),
      ],
      false, $r('app.media.poster6_back')),

    new PosterInfo($r('app.media.poster7'),
      [
        new PosterCollagePart('7%', '32.5%', '25%', '55%', 0),
        new PosterCollagePart('37.5%', '13.4%', '25%', '55%', 0),
        new PosterCollagePart('67.7%', '32.5%', '25%', '55%', 0),
      ],
      false, $r('app.media.poster7_back')),
    new PosterInfo($r('app.media.poster8'),
      [
        new PosterCollagePart('0', '50%', '33.5%', '50%', 0),
        new PosterCollagePart('33.4%', '0', '33.5%', '50%', 0),
        new PosterCollagePart('66.7%', '50%', '33.4%', '50%', 0),
      ],
      false, $r('app.media.poster8_back')),
  ]
  static directTemplates: DirectTemplate[] = [
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
    },
    {
      rowsTemplate: '1fr 1fr',
      columnsTemplate: '1fr 1fr',
      imageResource: $r('app.media.direct5'),
      areas: [
        {
          id: 'top',
          rowStart: 0,
          rowEnd: 0,
          colStart: 0,
          colEnd: 1
        },
        {
          id: 'bottom',
          rowStart: 1,
          rowEnd: 1,
          colStart: 0,
          colEnd: 1
        }
      ]
    },
    {
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
      imageResource: $r('app.media.direct2'),
      areas: [
        {
          id: 'leftTop',
          rowStart: 0,
          rowEnd: 0,
          colStart: 0,
          colEnd: 0
        },
        {
          id: 'rightTop',
          rowStart: 0,
          rowEnd: 0,
          colStart: 1,
          colEnd: 1
        },
        {
          id: 'bottom',
          rowStart: 1,
          rowEnd: 1,
          colStart: 0,
          colEnd: 1
        }
      ]
    },
    {
      rowsTemplate: '1fr 1fr',
      columnsTemplate: '1fr 1fr',
      imageResource: $r('app.media.direct3'),
      areas: [
        {
          id: 'left',
          rowStart: 0,
          rowEnd: 1,
          colStart: 0,
          colEnd: 0
        },
        {
          id: 'rightTop',
          rowStart: 0,
          rowEnd: 0,
          colStart: 1,
          colEnd: 1
        },
        {
          id: 'rightBottom',
          rowStart: 1,
          rowEnd: 1,
          colStart: 1,
          colEnd: 1
        }
      ]
    }
  ];
}