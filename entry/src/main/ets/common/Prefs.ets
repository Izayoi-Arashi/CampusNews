import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import hilog from '@ohos.hilog';
import { BusinessError } from '@ohos.base';

const TAG: string = 'Prefs';
const DOMAIN: number = 0x0000;
const PREF_NAME: string = 'campus_prefs';
const KEY_ROLE: string = 'role';

export class Prefs {
  private static context: common.Context | null = null;

  static init(context: common.Context): void {
    Prefs.context = context;
  }

  private static async getStore(): Promise<preferences.Preferences> {
    if (Prefs.context === null) {
      throw new Error('Prefs not initialized: call Prefs.init(context) first');
    }
    const options: preferences.Options = { name: PREF_NAME };
    return preferences.getPreferences(Prefs.context, options);
  }

  static async getRole(): Promise<'admin' | 'student'> {
    try {
      const store: preferences.Preferences = await Prefs.getStore();
      const value: preferences.ValueType = await store.get(KEY_ROLE, 'admin');
      return value === 'student' ? 'student' : 'admin';
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      hilog.warn(DOMAIN, TAG, 'getRole failed: %{public}s', e.message);
      return 'admin';
    }
  }

  static async setRole(role: 'admin' | 'student'): Promise<void> {
    const store: preferences.Preferences = await Prefs.getStore();
    await store.put(KEY_ROLE, role);
    await store.flush();
    hilog.info(DOMAIN, TAG, 'role saved: %{public}s', role);
  }
}
