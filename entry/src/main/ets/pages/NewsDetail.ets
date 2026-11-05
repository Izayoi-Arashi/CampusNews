import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { BusinessError } from '@ohos.base';
import { NewsItem } from '../model/NewsData';
import { NewsDb } from '../db/NewsDb';
import { TabBar } from '../view/TabBar';
import {
  COLOR_PRIMARY,
  COLOR_LIGHT_BLUE,
  COLOR_CHIP_BG,
  COLOR_CHIP_TEXT,
  COLOR_CARD_BORDER,
  COLOR_DIVIDER,
  COLOR_TITLE,
  COLOR_BODY,
  COLOR_MUTED,
  COLOR_WEAK,
  COLOR_TERTIARY,
  COLOR_SECONDARY,
  FONT_BAR,
  FONT_DETAIL_TITLE,
  FONT_BODY,
  FONT_SUB,
  FONT_SMALL,
  FONT_TINY,
  RADIUS_CARD_SM,
  RADIUS_CHIP,
  PAGE_PADDING,
  CARD_PADDING,
  CARD_GAP
} from '../common/Theme';

// —— @Styles/@Extend 样式复用（仅本文件可用，ArkUI 限制） ——
// 圆形图标按钮（尺寸/圆角参数化）
@Extend(Row) function roundBtn(size: number, radius: number) {
  .width(size)
  .height(size)
  .borderRadius(radius)
  .justifyContent(FlexAlign.Center)
}

// 正文区块小标题
@Extend(Text) function labelText() {
  .fontSize(FONT_SUB)
  .fontWeight(FontWeight.Medium)
  .fontColor(COLOR_TITLE)
}

// 弱化小字说明
@Extend(Text) function tinyWeak() {
  .fontSize(FONT_TINY)
  .fontColor(COLOR_WEAK)
}

interface DetailRouteParams {
  id: number;
}

@Entry
@Component
struct NewsDetail {
  @StorageLink('dataVersion') dataVersion: number = 0;
  @StorageProp('role') role: string = 'student';
  @State category: string = '';
  @State title: string = '';
  @State publishTime: string = '';
  @State source: string = '';
  @State readCount: number = 0;
  @State paragraphs: string[] = [];
  @State isFav: boolean = false;
  @State related: NewsItem[] = [];
  private newsId: number = -1;

  aboutToAppear(): void {
    const pid: number | undefined = (router.getParams() as DetailRouteParams)?.id;
    if (typeof pid !== 'number') {
      this.showMissing();
      return;
    }
    this.newsId = pid;
    this.loadData(pid);
  }

  private showMissing(): void {
    promptAction.showToast({ message: '资讯不存在' });
    router.back();
  }

  private loadData(id: number): void {
    this.fetchDetail(id).catch(() => {
      this.showMissing();
    });
  }

  private async fetchDetail(id: number): Promise<void> {
    let item: NewsItem | null = null;
    try {
      item = await NewsDb.getNewsById(id);
    } catch (err) {
      console.error('NewsDetail', JSON.stringify(err));
    }
    if (item === null || (this.role !== 'admin' && item.visibleToStudent === false)) {
      this.showMissing();
      return;
    }
    this.category = item.category;
    this.title = item.title;
    this.publishTime = item.publishTime;
    this.source = item.source;
    this.paragraphs = item.body.split('\n\n').filter((p: string): boolean => p.length > 0);
    this.readCount = item.readCount + 1;
    try {
      await NewsDb.addReadHistory(id);
    } catch (err) {
      console.error('NewsDetail', JSON.stringify(err));
    }
    try {
      this.isFav = await NewsDb.isFavorite(id);
    } catch (err) {
      console.error('NewsDetail', JSON.stringify(err));
    }
    try {
      const all: NewsItem[] = await NewsDb.listNews('', this.role !== 'admin');
      this.related = all.filter((n: NewsItem): boolean => n.id !== id).slice(0, 2);
    } catch (err) {
      console.error('NewsDetail', JSON.stringify(err));
    }
  }

  private toggleFavorite(): void {
    if (this.newsId < 0) {
      return;
    }
    NewsDb.toggleFavorite(this.newsId).then((v: boolean): void => {
      this.isFav = v;
      this.dataVersion = this.dataVersion + 1;
    }).catch((err: BusinessError): void => {
      console.error('NewsDetail', JSON.stringify(err));
    });
  }

  private openRelated(targetId: number): void {
    const next: DetailRouteParams = { id: targetId };
    router.replaceUrl({ url: 'pages/NewsDetail', params: next }).catch(() => {
    });
  }

  private handleTabSelect(idx: number): void {
    if (idx === 0) {
      router.back();
      return;
    }
    AppStorage.setOrCreate<number>('currentTab', idx);
    router.back();
  }

  build() {
    Column() {
      Row() {
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(24)
            .fontColor(['#111E3A'])
        }
          .roundBtn(36, 18)
          .onClick(() => {
            router.back();
          })

        Text('资讯详情')
          .fontSize(FONT_BAR)
          .fontWeight(FontWeight.Medium)
          .fontColor(COLOR_TITLE)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)

        Row() {
          SymbolGlyph(this.isFav ? $r('sys.symbol.bookmark_fill') : $r('sys.symbol.bookmark'))
            .fontSize(22)
            .fontColor([this.isFav ? '#1E3A8A' : '#64748B'])
        }
          .roundBtn(36, 18)
          .onClick(() => {
            this.toggleFavorite();
          })
      }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .border({ width: { bottom: 1 }, color: COLOR_DIVIDER })

      Scroll() {
        Column() {
          Text(this.category)
            .fontSize(FONT_TINY)
            .fontWeight(FontWeight.Medium)
            .fontColor(COLOR_CHIP_TEXT)
            .backgroundColor(COLOR_CHIP_BG)
            .borderRadius(RADIUS_CHIP)
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })

          Text(this.title)
            .fontSize(FONT_DETAIL_TITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(COLOR_TITLE)
            .lineHeight(31)
            .margin({ top: 12 })

          Row() {
            Text('发布时间：' + this.publishTime + '｜来源：' + this.source)
              .fontSize(FONT_SMALL)
              .fontColor(COLOR_MUTED)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)

            Text('阅读 ' + this.readCount.toString())
              .fontSize(FONT_TINY)
              .fontColor(COLOR_TERTIARY)
              .margin({ left: 12 })
          }
            .width('100%')
            .margin({ top: 14 })
            .padding({ bottom: 16 })
            .border({ width: { bottom: 1 }, color: COLOR_DIVIDER })

          Column() {
            ForEach(this.paragraphs, (p: string) => {
              Text(p)
                .fontSize(FONT_BODY)
                .lineHeight(26)
                .fontColor(COLOR_BODY)
                .margin({ bottom: 16 })
            }, (p: string): string => p)
          }
            .width('100%')
            .margin({ top: 16 })
            .alignItems(HorizontalAlign.Start)

          Column() {
            Stack({ alignContent: Alignment.BottomStart }) {
              Text('示意图 · ' + this.source + '制')
                .fontSize(FONT_TINY)
                .fontColor(COLOR_PRIMARY)
                .backgroundColor('#CCFFFFFF')
                .borderRadius(RADIUS_CHIP)
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .margin({ left: 12, bottom: 12 })
            }
              .width('100%')
              .height(168)
              .borderRadius(RADIUS_CARD_SM)
              .clip(true)
              .linearGradient({
                angle: 135,
                colors: [[COLOR_LIGHT_BLUE, 0.0], ['#C7DAF7', 1.0]]
              })

            Text('示意图 · 仅供演示')
              .tinyWeak()
              .textAlign(TextAlign.Center)
              .width('100%')
              .margin({ top: 8 })
          }
            .width('100%')
            .margin({ top: 20 })

          Column({ space: 6 }) {
            Text('来源部门：' + this.source)
              .labelText()

            Text('电话：0000-0000｜邮箱：' + this.source + '@campus.edu.cn')
              .fontSize(FONT_SMALL)
              .fontColor(COLOR_SECONDARY)
          }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            .padding(CARD_PADDING)
            .backgroundColor(COLOR_LIGHT_BLUE)
            .borderRadius(RADIUS_CARD_SM)
            .margin({ top: 20 })

          Row({ space: CARD_GAP }) {
            Button('返回资讯列表')
              .type(ButtonType.Capsule)
              .layoutWeight(1)
              .height(44)
              .fontSize(FONT_BODY)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
              .backgroundColor(COLOR_PRIMARY)
              .onClick(() => {
                router.back();
              })

            if (this.role === 'admin') {
              Row() {
                SymbolGlyph($r('sys.symbol.plus_circle'))
                  .fontSize(24)
                  .fontColor(['#1E3A8A'])
              }
                .roundBtn(44, 22)
                .backgroundColor(COLOR_LIGHT_BLUE)
                .onClick(() => {
                  AppStorage.setOrCreate<number>('currentTab', 1);
                  router.back();
                })
            }
          }
            .width('100%')
            .margin({ top: 24 })

          Row({ space: 6 }) {
            Row()
              .width(4)
              .height(14)
              .borderRadius(2)
              .backgroundColor(COLOR_PRIMARY)

            Text('相关资讯')
              .labelText()
          }
            .alignItems(VerticalAlign.Center)
            .margin({ top: 28, bottom: 12 })

          Column({ space: CARD_GAP }) {
            ForEach(this.related, (n: NewsItem) => {
              Column({ space: 4 }) {
                Text(n.title)
                  .labelText()
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                Text(n.publishTime + ' ' + n.source)
                  .tinyWeak()
              }
                .alignItems(HorizontalAlign.Start)
                .width('100%')
                .padding(CARD_GAP)
                .backgroundColor(Color.White)
                .borderRadius(RADIUS_CARD_SM)
                .border({ width: 1, color: COLOR_CARD_BORDER })
                .onClick(() => {
                  this.openRelated(n.id);
                })
            }, (n: NewsItem): string => n.id.toString())
          }
            .width('100%')
        }
          .width('100%')
          .padding({
            left: PAGE_PADDING,
            right: PAGE_PADDING,
            top: PAGE_PADDING,
            bottom: 32
          })
          .alignItems(HorizontalAlign.Start)
      }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)

      TabBar({
        active: 0,
        onTabSelect: (idx: number): void => {
          this.handleTabSelect(idx);
        }
      })
    }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.White)
  }
}
