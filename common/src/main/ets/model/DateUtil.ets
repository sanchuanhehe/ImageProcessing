import { intl } from '@kit.LocalizationKit';

export class DateUtil {
  static formatDate(date: Date, split?: string, myWeekday?: string, myTimeStyle?: string): string {
    let options: DateTimeOptions = {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    };
    let dateFormatter: intl.DateTimeFormat = new intl.DateTimeFormat('zh-CN', options);
    let formattedDate = dateFormatter.format(date);
    if (split) {
      formattedDate = formattedDate.replace(/\//g, split)
    }
    if (myWeekday) {
      let weekdayOptions: DateTimeOptions = { weekday: myWeekday };
      let weekdayFormatter: intl.DateTimeFormat = new intl.DateTimeFormat('zh-CN', weekdayOptions);
      let formattedWeekday = weekdayFormatter.format(date);
      formattedDate = formattedDate + ' ' + formattedWeekday
    }
    if (myTimeStyle) {
      let timeOptions: DateTimeOptions = { timeStyle: myTimeStyle, hourCycle: 'h24' };
      let timeFormatter: intl.DateTimeFormat = new intl.DateTimeFormat('zh-CN', timeOptions);
      let formattedTime = timeFormatter.format(date);
      formattedDate = formattedDate + ' ' + formattedTime
    }
    return formattedDate
  }

  static parseDateString(dateTimeStr: string): Date {
    const timeStrs:string[] = dateTimeStr.split(' ')
    const dateNumbers: number[] = timeStrs[0].split('-').map(Number);
    let date: Date = new Date(dateNumbers[0], dateNumbers[1] - 1, dateNumbers[2]);
    if (timeStrs.length > 1) {
      const timeNumbers: number[] = timeStrs[1].split(':').map(Number);
      date.setHours(timeNumbers[0], timeNumbers[1]);
      if (timeNumbers.length > 2) {
        date.setSeconds(timeNumbers[2])
      }
    }
    return date
  }
}