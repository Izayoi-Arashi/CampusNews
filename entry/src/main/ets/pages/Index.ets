import { COLOR_BG } from '../common/Theme';
import { NewsListView } from '../view/NewsListView';
import { PublishView } from '../view/PublishView';
import { ProfileView } from '../view/ProfileView';
import { TabBar } from '../view/TabBar';

@Entry
@Component
struct Index {
  @StorageLink('currentTab') tab: number = 0;
  @StorageProp('publishModal') publishModal: number = 0;

  build() {
    Column() {
      Column() {
        if (this.tab === 0) {
          NewsListView()
        } else if (this.tab === 1) {
          PublishView()
        } else {
          ProfileView()
        }
      }
      .width('100%')
      .layoutWeight(1)

      TabBar({
        active: this.tab,
        onTabSelect: (i: number): void => {
          this.tab = i;
          AppStorage.setOrCreate('currentTab', i);
        }
      })
      .opacity(this.publishModal === 1 ? 0.35 : 1)
      .enabled(this.publishModal !== 1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLOR_BG)
  }
}
