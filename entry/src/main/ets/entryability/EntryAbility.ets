import UIAbility from '@ohos.app.ability.UIAbility';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import Want from '@ohos.app.ability.Want';
import window from '@ohos.window';
import hilog from '@ohos.hilog';
import { BusinessError } from '@ohos.base';
import { NewsDb } from '../db/NewsDb';
import { Prefs } from '../common/Prefs';

const TAG: string = 'CampusNews';
const DOMAIN: number = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, 'EntryAbility onCreate');
    AppStorage.setOrCreate<number>('currentTab', 0);
    AppStorage.setOrCreate<number>('dataVersion', 0);
    Prefs.init(this.context);
    NewsDb.init(this.context)
      .then(() => {
        hilog.info(DOMAIN, TAG, 'NewsDb ready');
      })
      .catch((err: BusinessError) => {
        hilog.error(DOMAIN, TAG, 'NewsDb init failed: %{public}s', JSON.stringify(err));
      });
    Prefs.getRole()
      .then((role: 'admin' | 'student') => {
        AppStorage.setOrCreate<string>('role', role);
        hilog.info(DOMAIN, TAG, 'role loaded: %{public}s', role);
      })
      .catch((err: BusinessError) => {
        AppStorage.setOrCreate<string>('role', 'admin');
        hilog.warn(DOMAIN, TAG, 'role load failed, fallback admin: %{public}s', JSON.stringify(err));
      });
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, 'EntryAbility onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, TAG, 'onWindowStageCreate');
    windowStage.loadContent('pages/Index', (err: BusinessError) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, TAG, 'loadContent pages/Index ok');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, TAG, 'onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, TAG, 'onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, TAG, 'onBackground');
  }
}
