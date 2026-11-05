/**
 * ProfileView —— 我的页
 * 深蓝用户卡（含真实统计）+ 身份切换（持久化）+ 权限说明 + 资讯搜索 + 最近浏览 + 快捷入口
 */
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { BusinessError } from '@ohos.base';
import { NewsItem } from '../model/NewsData';
import { NewsDb } from '../db/NewsDb';
import { Prefs } from '../common/Prefs';
import common from '@ohos.app.ability.common';
import Want from '@ohos.app.ability.Want';
import pasteboard from '@ohos.pasteboard';
import {
  COLOR_PRIMARY, COLOR_BG, COLOR_LIGHT_BLUE, COLOR_CARD_BORDER, COLOR_INPUT_BORDER,
  COLOR_DIVIDER, COLOR_TITLE, COLOR_BODY, COLOR_SECONDARY, COLOR_MUTED, COLOR_WEAK,
  COLOR_TERTIARY, COLOR_CHIP_BG, COLOR_CHIP_TEXT,
  FONT_PAGE, FONT_BAR, FONT_CARD_TITLE, FONT_SECTION, FONT_SUB, FONT_SMALL, FONT_TINY,
  RADIUS_CARD, RADIUS_CARD_SM, RADIUS_INPUT, RADIUS_CHIP, PAGE_PADDING, CARD_GAP
} from '../common/Theme';

// —— @Styles/@Extend 样式复用（仅本文件可用，ArkUI 限制） ——
// 白底圆角卡片容器：卡片通用外观（仅通用属性）
@Styles function formCard() {
  .width('100%')
  .backgroundColor(Color.White)
  .borderRadius(RADIUS_CARD)
  .borderWidth(1)
  .borderColor(COLOR_CARD_BORDER)
  .padding(16)
  .margin({ top: CARD_GAP })
}

// 列表行外观：上下留白 + 底部分隔线
@Extend(Row) function listRow() {
  .width('100%')
  .alignItems(VerticalAlign.Center)
  .padding({ top: 8, bottom: 8 })
  .borderWidth({ bottom: 0.5 })
  .borderColor({ bottom: COLOR_DIVIDER })
}

// 列表行标题：单行截断
@Extend(Text) function rowTitle() {
  .fontSize(FONT_SUB)
  .fontColor(COLOR_BODY)
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .layoutWeight(1)
}

// 列表行时间戳
@Extend(Text) function rowTime() {
  .fontSize(FONT_TINY)
  .fontColor(COLOR_TERTIARY)
}

// 细分隔线
@Extend(Divider) function dividerThin() {
  .strokeWidth(1)
  .color(COLOR_DIVIDER)
}

class NewsRouteParam {
  public id: number = 0;
  constructor(id: number) {
    this.id = id;
  }
}

@Component
export struct ProfileView {
  @StorageProp('role') role: string = 'student';
  @StorageLink('dataVersion') @Watch('onDataChanged') dataVersion: number = 0;
  @State publishCount: number = 0;
  @State favoriteCount: number = 0;
  @State historyCount: number = 0;
  @State historyList: NewsItem[] = [];
  @State searchKw: string = '';
  @State searched: boolean = false;
  @State lastKw: string = '';
  @State searchResults: NewsItem[] = [];

  aboutToAppear(): void {
    this.refreshData();
  }

  onDataChanged(propName: string): void {
    this.refreshData();
  }

  build() {
    Column() {
      this.headerBar()
      Scroll() {
        Column() {
          this.userCard()
          this.roleCard()
          this.permCard()
          this.searchCard()
          this.historyCard()
          this.quickCard()
          this.aboutCard()
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: PAGE_PADDING, right: PAGE_PADDING, top: 16, bottom: 24 })
      }
      .width('100%')
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLOR_BG)
  }

  @Builder
  headerBar() {
    Row() {
      Text('我的')
        .fontSize(FONT_PAGE)
        .fontWeight(FontWeight.Bold)
        .fontColor(COLOR_TITLE)
      Blank()
    }
    .width('100%')
    .height(52)
    .padding({ left: PAGE_PADDING, right: PAGE_PADDING, top: 8, bottom: 4 })
    .backgroundColor(Color.White)
    .borderWidth({ bottom: 1 })
    .borderColor({ bottom: COLOR_CARD_BORDER })
  }

  @Builder
  userCard() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column() {
        Row({ space: 14 }) {
          Text('同')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(COLOR_PRIMARY)
            .width(52)
            .height(52)
            .textAlign(TextAlign.Center)
            .backgroundColor(COLOR_CHIP_BG)
            .borderRadius(26)
            .border({ width: 3, color: '#33FFFFFF' })

          Column({ space: 5 }) {
            Text('同学，你好')
              .fontSize(FONT_BAR)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
            Row({ space: 8 }) {
              Text(this.role === 'admin' ? '管理员' : '学生')
                .fontSize(FONT_TINY)
                .fontWeight(FontWeight.Medium)
                .fontColor(COLOR_PRIMARY)
                .backgroundColor('#BFDBFE')
                .borderRadius(RADIUS_CHIP)
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              Text('学生工作处')
                .fontSize(FONT_TINY)
                .fontColor('#BFDBFE')
            }
            .alignItems(VerticalAlign.Center)
            Text('校园资讯管理系统 · 2025 级')
              .fontSize(FONT_TINY)
              .fontColor('#9DB6E4')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Row() {
            SymbolGlyph($r('sys.symbol.arrow_right')).fontSize(16).fontColor([Color.White])
          }
          .width(32)
          .height(32)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .backgroundColor('#1AFFFFFF')
          .borderRadius(16)
          .onClick(() => {
            AppStorage.setOrCreate('currentTab', 0);
          })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Row() {
          this.statCol(this.publishCount, '已发布')
          Divider().vertical(true).height(22).color('#26FFFFFF')
          this.statCol(this.favoriteCount, '收藏')
          Divider().vertical(true).height(22).color('#26FFFFFF')
          this.statCol(this.historyCount, '浏览记录')
        }
        .width('100%')
        .backgroundColor('#1AFFFFFF')
        .borderRadius(RADIUS_CARD_SM)
        .padding({ top: 10, bottom: 10 })
        .margin({ top: 14 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding(16)

      Circle().width(128).height(128).fill('#1AFFFFFF').offset({ x: 30, y: -44 })
      Circle().width(80).height(80).fill('#0DFFFFFF').offset({ x: -6, y: 56 })
    }
    .width('100%')
    .backgroundColor(COLOR_PRIMARY)
    .borderRadius(20)
    .padding(16)
    .clip(true)
  }

  @Builder
  statCol(v: number, label: string) {
    Column({ space: 3 }) {
      Text(`${v}`)
        .fontSize(FONT_CARD_TITLE)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
      Text(label)
        .fontSize(FONT_TINY)
        .fontColor('#BFDBFE')
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  sectionTitle(t: string) {
    Row({ space: 6 }) {
      Row().width(3).height(14).borderRadius(2).backgroundColor(COLOR_PRIMARY)
      Text(t)
        .fontSize(FONT_SECTION)
        .fontWeight(FontWeight.Medium)
        .fontColor(COLOR_TITLE)
    }
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  roleSeg(label: string, target: 'admin' | 'student', tap: () => void) {
    Text(label)
      .fontSize(FONT_SECTION)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.role === target ? COLOR_PRIMARY : COLOR_SECONDARY)
      .backgroundColor(this.role === target ? Color.White : Color.Transparent)
      .borderRadius(RADIUS_INPUT)
      .height(40)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .onClick(() => {
        tap();
      })
  }

  @Builder
  roleCard() {
    Column() {
      Row() {
        this.sectionTitle('身份切换')
        Blank()
        Text(`当前：${this.role === 'admin' ? '管理员' : '学生'}`)
          .fontSize(FONT_TINY)
          .fontColor(COLOR_WEAK)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 12 })
      Row({ space: 6 }) {
        this.roleSeg('管理员', 'admin', (): void => {
          this.switchRole('admin');
        })
        this.roleSeg('学生', 'student', (): void => {
          this.switchRole('student');
        })
      }
      .width('100%')
      .backgroundColor(COLOR_LIGHT_BLUE)
      .borderRadius(RADIUS_CARD_SM)
      .padding(4)
    }
    .alignItems(HorizontalAlign.Start)
    .formCard()
  }

  @Builder
  permCard() {
    Column() {
      this.sectionTitle('身份权限说明')
      Row() {
        Text('管理员·可发布与删除')
          .fontSize(FONT_SUB)
          .fontColor(COLOR_BODY)
      }
      .width('100%')
      .padding({ top: 10, bottom: 10 })
      Divider().dividerThin()
      Row() {
        Text('学生·仅浏览与搜索')
          .fontSize(FONT_SUB)
          .fontColor(COLOR_BODY)
      }
      .width('100%')
      .padding({ top: 10, bottom: 10 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Color.White)
    .borderRadius(RADIUS_CARD)
    .borderWidth(1)
    .borderColor(COLOR_CARD_BORDER)
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .margin({ top: CARD_GAP })
  }

  @Builder
  searchCard() {
    Column() {
      this.sectionTitle('资讯搜索')
      Row({ space: 8 }) {
        SymbolGlyph($r('sys.symbol.magnifyingglass')).fontSize(20).fontColor([COLOR_MUTED])
        TextInput({ text: this.searchKw, placeholder: '按标题关键字搜索' })
          .layoutWeight(1)
          .height(38)
          .fontSize(FONT_SUB)
          .fontColor(COLOR_TITLE)
          .placeholderColor(COLOR_TERTIARY)
          .placeholderFont({ size: FONT_SUB })
          .backgroundColor(Color.Transparent)
          .borderRadius(0)
          .padding(0)
          .onChange((v: string) => {
            this.searchKw = v;
          })
        Text('搜索')
          .fontSize(FONT_SMALL)
          .fontWeight(FontWeight.Medium)
          .fontColor(COLOR_CHIP_TEXT)
          .backgroundColor(COLOR_LIGHT_BLUE)
          .borderRadius(RADIUS_CHIP)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .onClick(() => {
            this.doSearch();
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .backgroundColor(COLOR_BG)
      .borderRadius(RADIUS_INPUT)
      .borderWidth(1)
      .borderColor(COLOR_INPUT_BORDER)
      .padding({ left: 12, right: 8, top: 4, bottom: 4 })

      if (this.searched) {
        Column() {
          Text(this.searchResults.length > 0
            ? `找到 ${this.searchResults.length} 条：与「${this.lastKw}」相关的资讯`
            : `未找到与「${this.lastKw}」相关的资讯`)
            .fontSize(FONT_SMALL)
            .fontColor(COLOR_CHIP_TEXT)
            .width('100%')
            .backgroundColor(COLOR_LIGHT_BLUE)
            .borderRadius(RADIUS_INPUT)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          ForEach(this.searchResults, (item: NewsItem) => {
            Row({ space: 8 }) {
              Text(item.title)
                .rowTitle()
              Text(item.publishTime)
                .rowTime()
            }
            .listRow()
            .onClick(() => {
              this.openDetail(item.id);
            })
          }, (item: NewsItem) => `s${item.id}`)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ top: 8 })
      }
    }
    .alignItems(HorizontalAlign.Start)
    .formCard()
  }

  @Builder
  historyCard() {
    Column() {
      this.sectionTitle('最近浏览')
      if (this.historyList.length === 0) {
        Text('暂无浏览记录')
          .fontSize(FONT_SMALL)
          .fontColor(COLOR_MUTED)
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ top: 14, bottom: 14 })
      } else {
        Column() {
          ForEach(this.historyList, (item: NewsItem) => {
            Row({ space: 8 }) {
              SymbolGlyph($r('sys.symbol.clock')).fontSize(16).fontColor([COLOR_MUTED])
              Text(item.title)
                .rowTitle()
              Text(item.publishTime)
                .rowTime()
            }
            .listRow()
            .onClick(() => {
              this.openDetail(item.id);
            })
          }, (item: NewsItem) => `h${item.id}`)
        }
        .width('100%')
        .margin({ top: 4 })
      }
    }
    .alignItems(HorizontalAlign.Start)
    .formCard()
  }

  @Builder
  quickRow(res: Resource, label: string, studentOnly: boolean, tap: () => void) {
    Row({ space: 12 }) {
      Column() {
        SymbolGlyph(res).fontSize(18).fontColor([COLOR_PRIMARY])
      }
      .width(32)
      .height(32)
      .borderRadius(10)
      .backgroundColor(COLOR_LIGHT_BLUE)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)

      Text(label)
        .fontSize(FONT_SUB)
        .fontColor(COLOR_BODY)
        .layoutWeight(1)

      Text('›')
        .fontSize(20)
        .fontColor(COLOR_TERTIARY)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .opacity(studentOnly && this.role === 'student' ? 0.5 : 1)
    .onClick(() => {
      if (studentOnly && this.role === 'student') {
        promptAction.showToast({ message: '学生身份暂不可发布' });
        return;
      }
      tap();
    })
  }

  @Builder
  quickCard() {
    Column() {
      this.quickRow($r('sys.symbol.house'), '浏览校园资讯', false, (): void => {
        AppStorage.setOrCreate('currentTab', 0);
      })
      Divider().dividerThin()
      this.quickRow($r('sys.symbol.plus_circle'), '发布新资讯', true, (): void => {
        AppStorage.setOrCreate('currentTab', 1);
      })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(RADIUS_CARD)
    .borderWidth(1)
    .borderColor(COLOR_CARD_BORDER)
    .clip(true)
    .margin({ top: CARD_GAP })
  }

  @Builder
  aboutCard() {
    Column() {
      this.sectionTitle('关于项目')
      Row() {
        Text('作者主页')
          .fontSize(FONT_SUB)
          .fontColor(COLOR_BODY)
        Blank()
        Text('rain-sealedletter.top')
          .fontSize(FONT_SMALL)
          .fontColor(COLOR_PRIMARY)
        Text(' ›')
          .fontSize(FONT_SMALL)
          .fontColor(COLOR_TERTIARY)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .padding({ top: 10, bottom: 10 })
      .onClick(() => {
        this.openExternal('https://rain-sealedletter.top/');
      })

      Divider().dividerThin()

      Row() {
        Text('开源地址')
          .fontSize(FONT_SUB)
          .fontColor(COLOR_BODY)
        Blank()
        Text('github.com/Izayoi-Arashi/CampusNews')
          .fontSize(FONT_SMALL)
          .fontColor(COLOR_PRIMARY)
        Text(' ›')
          .fontSize(FONT_SMALL)
          .fontColor(COLOR_TERTIARY)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .padding({ top: 10, bottom: 10 })
      .onClick(() => {
        this.openExternal('https://github.com/Izayoi-Arashi/CampusNews');
      })

      Text('CampusNews v1.0 · HarmonyOS API 12 · MIT License')
        .fontSize(FONT_TINY)
        .fontColor(COLOR_TERTIARY)
        .width('100%')
        .textAlign(TextAlign.Center)
        .padding({ top: 8 })
    }
    .formCard()
  }

  private openExternal(url: string): void {
    const context = getContext(this) as common.UIAbilityContext;
    const want: Want = {
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: url
    };
    context.startAbility(want).then((): void => {
      // 已尝试拉起浏览器
    }).catch((err: BusinessError): void => {
      console.error('ProfileView', JSON.stringify(err));
      this.copyLink(url);
    });
  }

  private copyLink(url: string): void {
    const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, url);
    pasteboard.getSystemPasteboard().setData(data).then((): void => {
      promptAction.showToast({ message: '已复制链接：' + url });
    }).catch((err: BusinessError): void => {
      console.error('ProfileView', JSON.stringify(err));
      promptAction.showToast({ message: url });
    });
  }

  private refreshData(): void {
    NewsDb.countOwnNews().then((n: number): void => {
      this.publishCount = n;
    }).catch((err: BusinessError): void => {
      console.error('ProfileView', JSON.stringify(err));
    });
    NewsDb.countFavorites().then((n: number): void => {
      this.favoriteCount = n;
    }).catch((err: BusinessError): void => {
      console.error('ProfileView', JSON.stringify(err));
    });
    NewsDb.countHistory().then((n: number): void => {
      this.historyCount = n;
    }).catch((err: BusinessError): void => {
      console.error('ProfileView', JSON.stringify(err));
    });
    NewsDb.listHistory(5).then((list: NewsItem[]): void => {
      this.historyList = list;
    }).catch((err: BusinessError): void => {
      console.error('ProfileView', JSON.stringify(err));
    });
  }

  private switchRole(r: 'admin' | 'student'): void {
    if (r === this.role) {
      return;
    }
    Prefs.setRole(r).then((): void => {
      AppStorage.setOrCreate('role', r);
    }).catch((err: BusinessError): void => {
      console.error('ProfileView', JSON.stringify(err));
      promptAction.showToast({ message: '身份切换失败，请重试' });
    });
  }

  private doSearch(): void {
    const kw: string = this.searchKw.trim();
    if (kw.length === 0) {
      promptAction.showToast({ message: '请输入标题关键字后再搜索，例如「考试」' });
      return;
    }
    NewsDb.listNews(kw, this.role !== 'admin').then((list: NewsItem[]): void => {
      this.lastKw = kw;
      this.searchResults = list;
      this.searched = true;
    }).catch((err: BusinessError): void => {
      console.error('ProfileView', JSON.stringify(err));
    });
  }

  private openDetail(id: number): void {
    router.pushUrl({ url: 'pages/NewsDetail', params: new NewsRouteParam(id) });
  }
}