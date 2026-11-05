import { COLOR_DIVIDER, COLOR_PRIMARY, COLOR_TERTIARY, FONT_TINY } from '../common/Theme';

@Component
export struct TabBar {
  @Prop active: number = 0;
  onTabSelect: (idx: number) => void = (idx: number): void => {};
  @State pressedIdx: number = -1;
  private tabLabels: string[] = ['资讯', '发布', '我的'];
  private iconActive: Resource[] = [
    $r('sys.symbol.house_fill'),
    $r('sys.symbol.plus_circle_fill'),
    $r('sys.symbol.person_fill')
  ];
  private iconInactive: Resource[] = [
    $r('sys.symbol.house'),
    $r('sys.symbol.plus_circle'),
    $r('sys.symbol.person')
  ];

  build() {
    Row() {
      ForEach(this.tabLabels, (label: string, idx: number) => {
        Column({ space: 2 }) {
          SymbolGlyph(this.active === idx ? this.iconActive[idx] : this.iconInactive[idx])
            .fontSize(24)
            .fontColor([this.active === idx ? COLOR_PRIMARY : COLOR_TERTIARY])
          Text(label)
            .fontSize(FONT_TINY)
            .fontWeight(this.active === idx ? 600 : 400)
            .fontColor(this.active === idx ? COLOR_PRIMARY : COLOR_TERTIARY)
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .scale({
          x: this.pressedIdx === idx ? 0.95 : 1,
          y: this.pressedIdx === idx ? 0.95 : 1
        })
        .onClick(() => {
          this.onTabSelect(idx);
        })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.pressedIdx = idx;
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.pressedIdx = -1;
          }
        })
      }, (label: string) => label)
    }
    .width('100%')
    .height(60)
    .padding({ left: 8, right: 8, top: 8, bottom: 10 })
    .backgroundColor(Color.White)
    .border({ width: { top: 1 }, color: { top: COLOR_DIVIDER } })
  }
}
