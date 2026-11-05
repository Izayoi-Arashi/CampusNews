import router from '@ohos.router';
import { BusinessError } from '@ohos.base';
import { NewsItem } from '../model/NewsData';
import { NewsDb } from '../db/NewsDb';
import {
  CARD_GAP,
  COLOR_BG,
  COLOR_INPUT_BORDER,
  COLOR_LIGHT_BLUE,
  COLOR_MUTED,
  COLOR_PRIMARY,
  COLOR_REQUIRED,
  COLOR_TITLE,
  COLOR_WEAK,
  FONT_BODY,
  FONT_PAGE,
  FONT_SMALL,
  FONT_SUB,
  FONT_TINY,
  PAGE_PADDING,
  RADIUS_INPUT
} from '../common/Theme';
import { NewsCard } from './NewsCard';

// —— @Extend 样式复用（仅本文件可用，ArkUI 限制） ——
// 圆形图标徽标容器（尺寸/圆角参数化）
@Extend(Column) function roundBadge(size: number, radius: number) {
  .width(size)
  .height(size)
  .borderRadius(radius)
  .backgroundColor(COLOR_LIGHT_BLUE)
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
}

const WEEK_NAMES: string[] = ['日', '一', '二', '三', '四', '五', '六'];

@Component
export struct NewsListView {
  @StorageProp('role') role: string = 'student';
  @StorageLink('dataVersion') @Watch('onDataVersionChange') dataVersion: number = 0;
  @State keyword: string = '';
  @State showSearch: boolean = false;
  @State newsList: NewsItem[] = [];
  @State todayText: string = '';
  @State loaded: boolean = false;

  aboutToAppear(): void {
    const now: Date = new Date();
    this.todayText = `${now.getFullYear()}年${now.getMonth() + 1}月${now.getDate()}日 · 周${WEEK_NAMES[now.getDay()]}`;
    this.loadNews();
  }

  onDataVersionChange(): void {
    this.loadNews();
  }

  loadNews(): void {
    const kw: string = this.keyword;
    const studentOnly: boolean = this.role !== 'admin';
    NewsDb.listNews(kw, studentOnly).then((items: NewsItem[]): void => {
      this.loaded = true;
      if (kw === this.keyword) {
        this.newsList = items;
      }
    }).catch((err: BusinessError): void => {
      this.loaded = true;
      console.error('NewsListView', JSON.stringify(err));
    });
  }

  toggleSearch(): void {
    if (this.showSearch) {
      this.showSearch = false;
      if (this.keyword !== '') {
        this.keyword = '';
        this.loadNews();
      }
    } else {
      this.showSearch = true;
    }
  }

  openDetail(id: number): void {
    router.pushUrl({ url: 'pages/NewsDetail', params: { id: id } });
  }

  confirmDelete(id: number): void {
    AlertDialog.show({
      title: '删除资讯',
      message: '删除后不可恢复，确定要删除这条资讯吗？',
      autoCancel: true,
      primaryButton: {
        value: '取消',
        fontColor: COLOR_MUTED,
        action: () => {}
      },
      secondaryButton: {
        value: '删除',
        fontColor: COLOR_REQUIRED,
        action: () => {
          NewsDb.deleteNews(id).then((): void => {
            this.dataVersion = this.dataVersion + 1;
          }).catch((err: BusinessError): void => {
            console.error('NewsListView', JSON.stringify(err));
          });
        }
      }
    });
  }

  build() {
    Column() {
      Row() {
        Text('校园资讯')
          .fontSize(FONT_PAGE)
          .fontWeight(FontWeight.Bold)
          .fontColor(COLOR_TITLE)
        Blank()
        Column() {
          SymbolGlyph($r('sys.symbol.magnifyingglass'))
            .fontSize(22)
            .fontColor([COLOR_PRIMARY])
        }
        .roundBadge(36, 18)
        .onClick(() => {
          this.toggleSearch();
        })
      }
      .width('100%')
      .padding({ left: PAGE_PADDING, right: PAGE_PADDING, top: 16, bottom: 12 })

      if (this.showSearch) {
        Row({ space: 8 }) {
          SymbolGlyph($r('sys.symbol.magnifyingglass'))
            .fontSize(18)
            .fontColor([COLOR_MUTED])
          TextInput({ text: this.keyword, placeholder: '搜索标题关键词' })
            .layoutWeight(1)
            .height('100%')
            .fontSize(FONT_SUB)
            .placeholderFont({ size: FONT_SUB })
            .fontColor(COLOR_TITLE)
            .placeholderColor(COLOR_WEAK)
            .backgroundColor(Color.Transparent)
            .onChange((value: string) => {
              this.keyword = value;
              this.loadNews();
            })
        }
        .width('100%')
        .height(40)
        .padding({ left: 12, right: 12 })
        .backgroundColor(COLOR_LIGHT_BLUE)
        .borderRadius(RADIUS_INPUT)
        .border({ width: 1, color: COLOR_INPUT_BORDER })
        .margin({ left: PAGE_PADDING, right: PAGE_PADDING })
      }

      Row() {
        Text(this.todayText)
          .fontSize(FONT_SMALL)
          .fontColor(COLOR_MUTED)
        Blank()
        Text(`共 ${this.newsList.length} 条资讯`)
          .fontSize(FONT_TINY)
          .fontWeight(FontWeight.Medium)
          .fontColor(COLOR_PRIMARY)
          .backgroundColor(COLOR_LIGHT_BLUE)
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .borderRadius(999)
      }
      .width('100%')
      .padding({ left: PAGE_PADDING, right: PAGE_PADDING })
      .margin({ top: 4 })

      Scroll() {
        Column({ space: CARD_GAP }) {
          if (this.loaded && this.newsList.length === 0) {
            Column({ space: 12 }) {
              Column() {
                SymbolGlyph($r('sys.symbol.magnifyingglass'))
                  .fontSize(32)
                  .fontColor([COLOR_MUTED])
              }
              .roundBadge(64, 16)
              Text('没有找到相关资讯')
                .fontSize(FONT_BODY)
                .fontWeight(FontWeight.Medium)
                .fontColor(COLOR_TITLE)
              Text('试试更换关键字，例如「考试」')
                .fontSize(FONT_SMALL)
                .fontColor(COLOR_WEAK)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
            .margin({ top: 64 })
          } else {
            ForEach(this.newsList, (item: NewsItem) => {
              NewsCard({
                item: item,
                canDelete: this.role === 'admin' && item.isOwn,
                onOpen: (id: number): void => {
                  this.openDetail(id);
                },
                onDelete: (id: number): void => {
                  this.confirmDelete(id);
                }
              })
            }, (item: NewsItem) => item.id.toString() + '-' + this.role)
          }
        }
        .width('100%')
        .padding({ left: PAGE_PADDING, right: PAGE_PADDING, top: 12, bottom: 24 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLOR_BG)
  }
}
