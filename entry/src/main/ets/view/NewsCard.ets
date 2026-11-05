import { NewsItem } from '../model/NewsData';
import {
  CARD_PADDING,
  COLOR_CARD_BORDER,
  COLOR_CHIP_BG,
  COLOR_CHIP_TEXT,
  COLOR_MUTED,
  COLOR_PRIMARY,
  COLOR_TITLE,
  COLOR_WEAK,
  FONT_CARD_TITLE,
  FONT_SMALL,
  FONT_TINY,
  RADIUS_CARD,
  RADIUS_CHIP
} from '../common/Theme';

// —— @Extend 样式复用（仅本文件可用，ArkUI 限制） ——
// 两行截断（标题/摘要共用）
@Extend(Text) function lines2() {
  .maxLines(2)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}

// 底部元信息文本（颜色随置顶态参数化）
@Extend(Text) function metaText(color: string) {
  .fontSize(FONT_TINY)
  .fontColor(color)
}

@Component
export struct NewsCard {
  item: NewsItem = new NewsItem();
  canDelete: boolean = false;
  onOpen: (id: number) => void = (id: number): void => {};
  onDelete?: (id: number) => void;

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column() {
        Row() {
          Text(this.item.category)
            .fontSize(FONT_TINY)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.item.isPinned ? '#BFDBFE' : COLOR_CHIP_TEXT)
            .backgroundColor(this.item.isPinned ? '#26FFFFFF' : COLOR_CHIP_BG)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(RADIUS_CHIP)
          Blank()
          if (this.item.isPinned) {
            Text('置顶')
              .fontSize(FONT_TINY)
              .fontColor('#BFDBFE')
              .margin({ right: this.canDelete ? 28 : 0 })
          }
        }
        .width('100%')

        Text(this.item.title)
          .fontSize(FONT_CARD_TITLE)
          .fontWeight(600)
          .fontColor(this.item.isPinned ? Color.White : COLOR_TITLE)
          .lines2()
          .margin({ top: 8 })
          .width('100%')

        Text(this.item.summary)
          .fontSize(FONT_SMALL)
          .fontColor(this.item.isPinned ? '#C7D7F5' : COLOR_MUTED)
          .lines2()
          .margin({ top: 6 })
          .width('100%')

        Row({ space: 8 }) {
          Text(this.item.publishTime)
            .metaText(this.item.isPinned ? '#9DB6E4' : COLOR_WEAK)
          Text('|')
            .fontSize(FONT_TINY)
            .fontColor(this.item.isPinned ? '#40FFFFFF' : '#D5DEEC')
          Text(this.item.source)
            .metaText(this.item.isPinned ? '#9DB6E4' : COLOR_WEAK)
        }
        .margin({ top: 10 })
        .width('100%')
      }
      .width('100%')
      .padding(CARD_PADDING)
      .borderRadius(RADIUS_CARD)
      .backgroundColor(this.item.isPinned ? COLOR_PRIMARY : Color.White)
      .border({ width: 1, color: this.item.isPinned ? Color.Transparent : COLOR_CARD_BORDER })
      .shadow({
        radius: this.item.isPinned ? 24 : 18,
        color: this.item.isPinned ? 'rgba(30,58,138,0.28)' : 'rgba(30,58,138,0.08)',
        offsetX: 0,
        offsetY: this.item.isPinned ? 10 : 6
      })
      .onClick(() => {
        this.onOpen(this.item.id);
      })

      if (this.canDelete) {
        SymbolGlyph($r('sys.symbol.trash'))
          .fontSize(17)
          .fontColor(['#E04B4B'])
          .margin({ top: 8, right: 8 })
          .onClick(() => {
            if (this.onDelete !== undefined) {
              this.onDelete(this.item.id);
            }
          })
      }
    }
    .width('100%')
  }
}
