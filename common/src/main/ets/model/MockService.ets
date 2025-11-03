import { util } from '@kit.ArkTS';
import { preferences } from '@kit.ArkData';
import { image } from '@kit.ImageKit';
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { DraftModel } from './PageParams';
import { DateUtil } from './DateUtil';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { promptAction } from '@kit.ArkUI';

export class MockService {
  static draftList: DraftModel[] = []
  static dataPreferences: preferences.Preferences;

  static init() {
    MockService.dataPreferences = preferences.getPreferencesSync(getContext(), { name: 'myStore' })
    let draft = MockService.dataPreferences.getSync('draft', '');
    if (draft.toString().length > 0) {
      MockService.draftList = JSON.parse(draft.toString()) as DraftModel[];
    }
  }

  static async saveDraft(imagePixel: PixelMap) {
    // 将图片保存到沙箱
    // 先获取其应用沙箱路径
    let fileDir = getContext().getApplicationContext().filesDir;
    // 创建图片目录
    let fileSavePath = fileDir + 'image';
    let res = fileIo.accessSync(fileSavePath);
    if (res) {
      fileIo.mkdirSync(fileSavePath, true);
    }
    let packer = image.createImagePacker();
    let packOpts: image.PackingOption = {
      // 因为jpeg不支持透明通道，若使用带透明通道的数据编码jpeg格式，透明色将变为黑色。
      format: 'image/png',
      // JPEG编码中设定输出图片质量的参数，取值范围为0-100。0质量最低，100质量最高，质量越高生成图片所占空间越大。
      quality: 100
    }
    let targetFile = fileIo.openSync(fileSavePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
    let fd = targetFile.fd;
    await packer.packToFile(imagePixel, fd, packOpts);
    fileIo.closeSync(fd);
    let targetUri = fileUri.getUriFromPath(targetFile.path);
    let draft: DraftModel = {
      id: util.generateRandomUUID(),
      uri: targetUri,
      updateTime: DateUtil.formatDate(new Date(), undefined, undefined, 'short')
    }
    MockService.draftList.unshift(draft)
    MockService.dataPreferences.putSync('draft', JSON.stringify(MockService.draftList))
    MockService.dataPreferences.flush()
  }

  static async saveImage(pixelMap: PixelMap) {
    try {
      let helper = photoAccessHelper.getPhotoAccessHelper(getContext());
      let imageStyle: string | undefined = AppStorage.get('imageStyle')
      let imageQualityLevel: number | undefined = AppStorage.get('imageQualityLevel')
      if (imageStyle === undefined) {
        imageStyle = 'jpeg'
      }
      let quality = 100
      if (imageQualityLevel === 1) {
        quality = 60
      } else if (imageQualityLevel === 2) {
        quality = 30
      }
      let uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, imageStyle);
      let file = await fileIo.open(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      let imagePackerApi = image.createImagePacker();

      let packOpts: image.PackingOption = { format: 'image/' + imageStyle, quality: quality };

      imagePackerApi.packToData(pixelMap, packOpts)
        .then((data: ArrayBuffer) => {
          // 写入文件
          fileIo.write(file.fd, data);
          // 关闭文件
          fileIo.close(file.fd);
          promptAction.showToast({ message: '保存成功' })
        })
    } catch (error) {
      console.error('error is ' + JSON.stringify(error));
    }
  }
}
