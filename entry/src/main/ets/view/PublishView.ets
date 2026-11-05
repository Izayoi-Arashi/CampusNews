/**
 * PublishView —— 发布页
 * 学生态：浅蓝提示卡「学生身份暂不可发布」+「去切换身份」
 * 管理员态：页题/取消 + 身份条 + 表单（标题/正文/来源部门）+ 附加设置 + 底部发布 + 成功模态
 */
import promptAction from '@ohos.promptAction';
import { NewsDb } from '../db/NewsDb';
import { CATEGORIES, DEPTS } from '../model/NewsData';
import {
  COLOR_PRIMARY, COLOR_BG, COLOR_LIGHT_BLUE, COLOR_CARD_BORDER, COLOR_INPUT_BORDER,
  COLOR_DIVIDER, COLOR_TITLE, COLOR_BODY, COLOR_MUTED, COLOR_TERTIARY,
  COLOR_REQUIRED, COLOR_MASK, COLOR_CHIP_TEXT,
  FONT_PAGE, FONT_CARD_TITLE, FONT_SECTION, FONT_BODY, FONT_SUB, FONT_SMALL, FONT_TINY,
  RADIUS_CARD, RADIUS_CARD_SM, RADIUS_INPUT, RADIUS_CHIP, PAGE_PADDING, CARD_GAP
} from '../common/Theme';

// —— @Styles/@Extend 样式复用（仅本文件可用，ArkUI 限制） ——
// 白底圆角卡片容器：表单卡通用外观（仅通用属性）
@Styles function formCard() {
  .width('100%')
  .backgroundColor(Color.White)
  .borderRadius(RADIUS_CARD)
  .borderWidth(1)
  .borderColor(COLOR_CARD_BORDER)
  .padding(16)
  .margin({ bottom: CARD_GAP })
}

// 必填星号
@Extend(Text) function requiredMark() {
  .fontSize(FONT_SECTION)
  .fontWeight(FontWeight.Bold)
  .fontColor(COLOR_REQUIRED)
}

// 表单字段标签
@Extend(Text) function fieldLabel() {
  .fontSize(FONT_SECTION)
  .fontWeight(FontWeight.Medium)
  .fontColor(COLOR_BODY)
}

// 附加设置行说明文本
@Extend(Text) function settingText() {
  .fontSize(FONT_SUB)
  .fontColor(COLOR_BODY)
}

// 主操作胶囊按钮（高度/圆角/字号参数化）
@Extend(Button) function primaryBtn(h: number, r: number, fs: number) {
  .height(h)
  .borderRadius(r)
  .fontSize(fs)
  .fontColor(Color.White)
  .backgroundColor(COLOR_PRIMARY)
}

@Component
export struct PublishView {
  @StorageProp('role') role: string = 'student';
  @State publishing: boolean = false;
  @State title: string = '';
  @State bodyText: string = '';
  @State source: string = DEPTS[0];
  @State visibleToStudent: boolean = true;
  @State notifyPush: boolean = false;
  @State showSuccess: boolean = false;
  @State successDesc: string = '';

  aboutToAppear(): void {
    const draftTitle: string | undefined = AppStorage.get<string>('draftTitle');
    const draftBody: string | undefined = AppStorage.get<string>('draftBody');
    this.title = draftTitle === undefined ? '' : draftTitle;
    this.bodyText = draftBody === undefined ? '' : draftBody;
  }

  aboutToDisappear(): void {
    AppStorage.setOrCreate<number>('publishModal', 0);
  }

  build() {
    Stack() {
      Column() {
        if (this.role === 'admin') {
          this.adminHeader()
          Scroll() {
            Column() {
              this.identityBar()
              this.titleCard()
              this.bodyCard()
              this.deptCard()
              this.extraCard()
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding({ left: PAGE_PADDING, right: PAGE_PADDING, top: 16, bottom: 24 })
          }
          .width('100%')
          .layoutWeight(1)
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
          this.bottomBar()
        } else {
          this.studentHint()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(COLOR_BG)

      if (this.showSuccess) {
        this.successModal()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  adminHeader() {
    Row() {
      Text('发布资讯')
        .fontSize(FONT_PAGE)
        .fontWeight(FontWeight.Bold)
        .fontColor(COLOR_TITLE)
      Blank()
      Text('取消')
        .fontSize(FONT_SMALL)
        .fontWeight(FontWeight.Medium)
        .fontColor(COLOR_PRIMARY)
        .backgroundColor(COLOR_LIGHT_BLUE)
        .borderRadius(999)
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .onClick(() => {
          AppStorage.setOrCreate('currentTab', 0);
        })
    }
    .width('100%')
    .height(52)
    .padding({ left: PAGE_PADDING, right: PAGE_PADDING, top: 8, bottom: 4 })
    .backgroundColor(Color.White)
    .borderWidth({ bottom: 1 })
    .borderColor({ bottom: COLOR_CARD_BORDER })
  }

  @Builder
  identityBar() {
    Row({ space: 8 }) {
      SymbolGlyph($r('sys.symbol.person_shield_1')).fontSize(18).fontColor([COLOR_PRIMARY])
      Text('当前身份：管理员 · 可发布与删除')
        .fontSize(FONT_SMALL)
        .fontColor(COLOR_PRIMARY)
      Blank()
      Text('切换')
        .fontSize(FONT_TINY)
        .fontWeight(FontWeight.Medium)
        .fontColor(COLOR_CHIP_TEXT)
        .onClick(() => {
          AppStorage.setOrCreate('currentTab', 2);
        })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .backgroundColor(COLOR_LIGHT_BLUE)
    .borderRadius(RADIUS_CARD_SM)
    .padding({ left: 14, right: 12, top: 10, bottom: 10 })
    .margin({ bottom: CARD_GAP })
  }

  @Builder
  formLabel(name: string, counter: string) {
    Row({ space: 4 }) {
      Text('*')
        .requiredMark()
      Text(name)
        .fieldLabel()
      Blank()
      Text(counter)
        .fontSize(FONT_TINY)
        .fontColor(COLOR_TERTIARY)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: 8 })
  }

  @Builder
  titleCard() {
    Column() {
      this.formLabel('标题', `${this.title.length}/40`)
      TextInput({ text: this.title, placeholder: '请输入资讯标题' })
        .maxLength(40)
        .fontSize(FONT_BODY)
        .fontColor(COLOR_TITLE)
        .placeholderColor(COLOR_TERTIARY)
        .placeholderFont({ size: FONT_BODY })
        .height(46)
        .backgroundColor(COLOR_BG)
        .borderRadius(RADIUS_INPUT)
        .borderWidth(1)
        .borderColor(COLOR_INPUT_BORDER)
        .padding({ left: 14, right: 14 })
        .onChange((v: string) => {
          this.title = v;
          AppStorage.setOrCreate<string>('draftTitle', v);
        })
    }
    .alignItems(HorizontalAlign.Start)
    .formCard()
  }

  @Builder
  bodyCard() {
    Column() {
      this.formLabel('正文', `${this.bodyText.length}/500`)
      TextArea({ text: this.bodyText, placeholder: '请输入资讯正文内容' })
        .maxLength(500)
        .fontSize(FONT_SUB)
        .fontColor(COLOR_BODY)
        .placeholderColor(COLOR_TERTIARY)
        .placeholderFont({ size: FONT_SUB })
        .height(150)
        .backgroundColor(COLOR_BG)
        .borderRadius(RADIUS_INPUT)
        .borderWidth(1)
        .borderColor(COLOR_INPUT_BORDER)
        .padding({ left: 14, right: 14, top: 10, bottom: 10 })
        .onChange((v: string) => {
          this.bodyText = v;
          AppStorage.setOrCreate<string>('draftBody', v);
        })
    }
    .alignItems(HorizontalAlign.Start)
    .formCard()
  }

  @Builder
  deptCard() {
    Column() {
      Row({ space: 4 }) {
        Text('*')
          .requiredMark()
        Text('来源部门')
          .fieldLabel()
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 10 })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(DEPTS, (d: string) => {
          Text(d)
            .fontSize(FONT_SUB)
            .fontColor(this.source === d ? Color.White : COLOR_BODY)
            .backgroundColor(this.source === d ? COLOR_PRIMARY : COLOR_BG)
            .borderWidth(1)
            .borderColor(this.source === d ? COLOR_PRIMARY : COLOR_INPUT_BORDER)
            .borderRadius(RADIUS_CHIP)
            .padding({ left: 12, right: 12, top: 7, bottom: 7 })
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              this.source = d;
            })
        }, (d: string) => d)
      }
      .width('100%')
    }
    .alignItems(HorizontalAlign.Start)
    .formCard()
  }

  @Builder
  extraCard() {
    Column() {
      Row() {
        Text('发布后立即对学生可见')
          .settingText()
          .layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.visibleToStudent })
          .selectedColor(COLOR_PRIMARY)
          .onChange((on: boolean) => {
            this.visibleToStudent = on;
          })
      }
      .width('100%')
      .padding({ top: 12, bottom: 12 })

      Divider().strokeWidth(1).color(COLOR_DIVIDER)

      Row() {
        Text('同步推送至消息通知')
          .settingText()
          .layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.notifyPush })
          .selectedColor(COLOR_PRIMARY)
          .onChange((on: boolean) => {
            this.notifyPush = on;
          })
      }
      .width('100%')
      .padding({ top: 12, bottom: 12 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(RADIUS_CARD)
    .borderWidth(1)
    .borderColor(COLOR_CARD_BORDER)
    .padding({ left: 16, right: 16, top: 2, bottom: 2 })
  }

  @Builder
  bottomBar() {
    Column() {
      Button('发布')
        .width('100%')
        .primaryBtn(48, 24, FONT_CARD_TITLE)
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          this.doPublish();
        })
    }
    .width('100%')
    .padding({ left: PAGE_PADDING, right: PAGE_PADDING, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
    .borderWidth({ top: 1 })
    .borderColor({ top: COLOR_CARD_BORDER })
  }

  @Builder
  studentHint() {
    Column() {
      Column({ space: 16 }) {
        Text('学生身份暂不可发布')
          .fontSize(FONT_BODY)
          .fontWeight(FontWeight.Medium)
          .fontColor(COLOR_PRIMARY)
        Button('去切换身份')
          .primaryBtn(38, 19, FONT_SUB)
          .onClick(() => {
            AppStorage.setOrCreate('currentTab', 2);
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(COLOR_LIGHT_BLUE)
      .borderRadius(RADIUS_CARD)
      .padding(20)
      .margin({ top: 64 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: PAGE_PADDING, right: PAGE_PADDING })
  }

  @Builder
  successModal() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(COLOR_MASK)
        .opacity(0.45)
        .onClick(() => {
        })

      Column({ space: 8 }) {
        Stack() {
          Circle().width(56).height(56).fill(COLOR_PRIMARY)
          Text('✓')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }
        .width(56)
        .height(56)
        .margin({ bottom: 6 })

        Text('发布成功')
          .fontSize(FONT_CARD_TITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(COLOR_TITLE)

        Text(this.successDesc)
          .fontSize(FONT_SMALL)
          .fontColor(COLOR_MUTED)
          .textAlign(TextAlign.Center)
          .lineHeight(20)

        Row({ space: 10 }) {
          Button('继续编辑')
            .layoutWeight(1)
            .height(42)
            .fontSize(FONT_SUB)
            .fontColor(COLOR_BODY)
            .backgroundColor(COLOR_LIGHT_BLUE)
            .borderRadius(21)
            .onClick(() => {
              this.publishing = false;
              this.showSuccess = false;
              AppStorage.setOrCreate<number>('publishModal', 0);
              this.resetForm();
            })
          Button('返回列表')
            .layoutWeight(1)
            .primaryBtn(42, 21, FONT_SUB)
            .onClick(() => {
              this.publishing = false;
              this.showSuccess = false;
              AppStorage.setOrCreate<number>('publishModal', 0);
              this.resetForm();
              AppStorage.setOrCreate('currentTab', 0);
            })
        }
        .width('100%')
        .margin({ top: 14 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(Color.White)
      .borderRadius(22)
      .padding({ left: 24, right: 24, top: 26, bottom: 24 })
      .margin({ left: 32, right: 32 })
    }
    .width('100%')
    .height('100%')
  }

  private resetForm(): void {
    this.title = '';
    this.bodyText = '';
    AppStorage.setOrCreate<string>('draftTitle', '');
    AppStorage.setOrCreate<string>('draftBody', '');
    this.source = DEPTS[0];
    this.visibleToStudent = true;
    this.notifyPush = false;
  }

  private async doPublish(): Promise<void> {
    if (this.publishing) {
      return;
    }
    const t: string = this.title.trim();
    const b: string = this.bodyText.trim();
    if (t.length === 0) {
      promptAction.showToast({ message: '请输入资讯标题' });
      this.publishing = false;
      return;
    }
    if (b.length === 0) {
      promptAction.showToast({ message: '请输入资讯正文' });
      this.publishing = false;
      return;
    }
    this.publishing = true;
    try {
      const summary: string = b.length > 60 ? b.substring(0, 60) : b;
      await NewsDb.addNews({
        title: t,
        body: b,
        category: CATEGORIES[0],
        source: this.source,
        summary: summary,
        visibleToStudent: this.visibleToStudent
      });
      this.successDesc = `《${t}》已提交至${this.source}${this.visibleToStudent ? '，学生端即可查看' : ''}`;
      this.showSuccess = true;
      AppStorage.setOrCreate<number>('publishModal', 1);
    } catch (err) {
      console.error('PublishView', JSON.stringify(err));
    } finally {
      this.publishing = false;
    }
  }
}