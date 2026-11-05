import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import hilog from '@ohos.hilog';
import { NewsItem } from '../model/NewsData';

const TAG: string = 'NewsDb';
const DOMAIN: number = 0x0000;
const DB_NAME: string = 'CampusNews.db';

const SQL_CREATE_NEWS: string = 'CREATE TABLE IF NOT EXISTS news (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, body TEXT NOT NULL, category TEXT NOT NULL, source TEXT NOT NULL, publishTime TEXT NOT NULL, summary TEXT NOT NULL, readCount INTEGER NOT NULL DEFAULT 0, isPinned INTEGER NOT NULL DEFAULT 0, isOwn INTEGER NOT NULL DEFAULT 0, visibleToStudent INTEGER NOT NULL DEFAULT 1)';

const SQL_CREATE_FAVORITE: string = 'CREATE TABLE IF NOT EXISTS favorite (id INTEGER PRIMARY KEY AUTOINCREMENT, newsId INTEGER NOT NULL, createTime INTEGER NOT NULL)';

const SQL_CREATE_HISTORY: string = 'CREATE TABLE IF NOT EXISTS history (id INTEGER PRIMARY KEY AUTOINCREMENT, newsId INTEGER NOT NULL, viewTime INTEGER NOT NULL)';

const SQL_CREATE_META: string = 'CREATE TABLE IF NOT EXISTS meta (key TEXT PRIMARY KEY, value TEXT NOT NULL)';

const SQL_IDX_FAVORITE_UNIQUE: string = 'CREATE UNIQUE INDEX IF NOT EXISTS idx_favorite_news ON favorite(newsId)';

export interface NewsDraft {
  title: string;
  body: string;
  category: string;
  source: string;
  summary: string;
  visibleToStudent: boolean;
}

interface SeedRow {
  title: string;
  category: string;
  source: string;
  publishTime: string;
  summary: string;
  body: string;
  readCount: number;
  isPinned: boolean;
}

const SEED_NEWS: SeedRow[] = [
  {
    title: '关于期末考试安排的通知',
    category: '重要通知',
    source: '教务处',
    publishTime: '2026-03-15',
    readCount: 2418,
    isPinned: true,
    summary: '教务处发布本学期期末考试总体安排，请全体同学及时核对考试时间与考场信息并遵守考场纪律。',
    body: '各位同学：本学期期末考试定于2026年6月22日至6月28日统一进行，涉及全校87门课程。考试科目、具体时间与考场安排已在教务系统“考试安排”栏目公布，请同学们于6月10日前登录系统核对本人考试信息，如有课程冲突请及时向所在学院教学办反馈。\n\n考试期间须携带学生证与有效身份证件，提前15分钟到达考场，开考15分钟后不得入场。考场内禁止携带手机、智能手表等电子设备，一经发现按考试违纪处理。如因特殊情况无法参加考试，请于6月15日前向教务处考试中心提交缓考申请表，逾期不再受理。\n\n教务处考试中心\n办公地点：行政楼204室\n联系电话：0571-8888-6666（工作日8:30-17:00）'
  },
  {
    title: '校园志愿服务周招募启动',
    category: '志愿服务',
    source: '校团委',
    publishTime: '2026-03-12',
    readCount: 866,
    isPinned: false,
    summary: '校团委启动2026年校园志愿服务周，面向全校招募志愿者120名，报名截止3月20日。',
    body: '为弘扬奉献友爱互助进步的志愿精神，校团委定于2026年3月23日至3月29日举办校园志愿服务周，现面向全校招募志愿者120名，岗位涵盖图书馆整理、校园引导、社区助老与环保宣传四类，每人每周服务时长不少于8小时。\n\n服务期间统一配发志愿者马甲，服务时长按次录入平台，本学年累计满20小时可参评“优秀志愿者”。岗前培训会定于3月21日14:00在大学生活动中心报告厅举行，入选者请准时参加。\n\n报名方式：关注“校团委”公众号，点击菜单栏“志愿报名”填写信息，截止3月20日17:00。\n校团委青年志愿者协会\n联系电话：0571-8888-7777'
  },
  {
    title: '图书馆数据库试用与阅读推广活动',
    category: '校园服务',
    source: '图书馆',
    publishTime: '2026-03-10',
    readCount: 1532,
    isPinned: false,
    summary: '图书馆开通中国知网等五个数据库校园试用，并同步启动四月读书月系列阅读推广活动。',
    body: '为丰富校园学术资源，图书馆自2026年3月10日起开通中国知网、万方数据、超星期刊、Web of Science与EBSCO五个数据库的校园试用通道，试用截至6月30日，全校师生在校内IP范围内可免费检索与下载文献。\n\n同步启动的“四月读书月”活动包含名家读书分享会、经典诵读比赛与“21天共读打卡”三项内容，完成打卡可获得第二课堂学分，赛程与报名入口见图书馆主页“活动公告”栏目。\n\n试用账号与使用指南可在图书馆一楼服务台领取。\n图书馆信息技术部\n联系电话：0571-8888-8888\n邮箱：lib@example.edu.cn'
  },
  {
    title: '春季校园招聘会参会指南',
    category: '就业信息',
    source: '就业指导中心',
    publishTime: '2026-03-08',
    readCount: 987,
    isPinned: false,
    summary: '就业指导中心发布春季校园招聘会参会指南，含时间地点、企业清单与入场须知。',
    body: '2026年春季校园招聘会定于3月28日9:00至16:00在学校体育馆举行，已确认参会企业136家，覆盖信息技术、智能制造、金融商贸与教育培训等行业，提供岗位2100余个，企业清单已在就业信息网公布。\n\n应届毕业生凭校园卡与个人简历入场，建议准备不少于10份纸质简历并着正装参会；低年级同学可凭学生证于14:00后入场观摩。会场设简历门诊与政策咨询台，提供一对一简历诊断服务。\n\n参会企业清单与展位分布图可在就业信息网“招聘会专区”下载。\n就业指导中心\n办公地点：大学生活动中心117室\n联系电话：0571-8888-9999'
  }
];

export class NewsDb {
  private static store: relationalStore.RdbStore | null = null;
  private static ready: Promise<void> | null = null;

  static init(context: common.Context): Promise<void> {
    if (NewsDb.ready !== null) {
      return NewsDb.ready;
    }
    const config: relationalStore.StoreConfig = {
      name: DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };
    NewsDb.ready = relationalStore.getRdbStore(context, config)
      .then(async (store: relationalStore.RdbStore) => {
        NewsDb.store = store;
        await store.executeSql(SQL_CREATE_NEWS);
        await store.executeSql(SQL_CREATE_FAVORITE);
        await store.executeSql(SQL_CREATE_HISTORY);
        await store.executeSql(SQL_CREATE_META);
        await store.executeSql(SQL_IDX_FAVORITE_UNIQUE);
        await NewsDb.seedIfNeeded(store);
        hilog.info(DOMAIN, TAG, 'database ready');
      })
      .catch((err: BusinessError) => {
        NewsDb.ready = null;
        NewsDb.store = null;
        throw err as Error;
      });
    return NewsDb.ready;
  }

  static async listNews(keyword?: string, studentOnly?: boolean): Promise<NewsItem[]> {
    await NewsDb.ensureReady();
    const store: relationalStore.RdbStore = NewsDb.requireStore();
    let sql: string = 'SELECT * FROM news';
    const conditions: string[] = [];
    const args: relationalStore.ValueType[] = [];
    if (studentOnly === true) {
      conditions.push('visibleToStudent = 1');
    }
    if (keyword !== undefined && keyword.length > 0) {
      const escaped: string = keyword.replace(/\\/g, '\\\\').replace(/%/g, '\\%').replace(/_/g, '\\_');
      conditions.push("title LIKE ? ESCAPE '\\'");
      args.push('%' + escaped + '%');
    }
    if (conditions.length > 0) {
      sql += ' WHERE ' + conditions.join(' AND ');
    }
    sql += ' ORDER BY isPinned DESC, publishTime DESC, id DESC';
    const rs: relationalStore.ResultSet = await store.querySql(sql, args);
    return NewsDb.readAll(rs);
  }

  static async getNewsById(id: number): Promise<NewsItem | null> {
    await NewsDb.ensureReady();
    const store: relationalStore.RdbStore = NewsDb.requireStore();
    const rs: relationalStore.ResultSet = await store.querySql('SELECT * FROM news WHERE id = ?', [id]);
    let item: NewsItem | null = null;
    try {
      if (rs.goToFirstRow()) {
        item = NewsDb.rowToItem(rs);
      }
    } finally {
      rs.close();
    }
    return item;
  }

  static async addNews(n: NewsDraft): Promise<number> {
    await NewsDb.ensureReady();
    const store: relationalStore.RdbStore = NewsDb.requireStore();
    const bucket: relationalStore.ValuesBucket = {
      'title': n.title,
      'body': n.body,
      'category': n.category,
      'source': n.source,
      'publishTime': NewsDb.today(),
      'summary': n.summary,
      'readCount': 0,
      'isPinned': 0,
      'isOwn': 1,
      'visibleToStudent': n.visibleToStudent ? 1 : 0
    };
    const rowId: number = await store.insert('news', bucket);
    NewsDb.bumpDataVersion();
    hilog.info(DOMAIN, TAG, 'news added id=%{public}d', rowId);
    return rowId;
  }

  static async deleteNews(id: number): Promise<void> {
    await NewsDb.ensureReady();
    const store: relationalStore.RdbStore = NewsDb.requireStore();
    await store.executeSql('DELETE FROM favorite WHERE newsId = ?', [id]);
    await store.executeSql('DELETE FROM history WHERE newsId = ?', [id]);
    await store.executeSql('DELETE FROM news WHERE id = ?', [id]);
    NewsDb.bumpDataVersion();
  }

  static async addReadHistory(id: number): Promise<void> {
    await NewsDb.ensureReady();
    const store: relationalStore.RdbStore = NewsDb.requireStore();
    await store.executeSql('INSERT INTO history (newsId, viewTime) VALUES (?, ?)', [id, Date.now()]);
    await store.executeSql('UPDATE news SET readCount = readCount + 1 WHERE id = ?', [id]);
    await store.executeSql('DELETE FROM history WHERE id NOT IN (SELECT id FROM history ORDER BY viewTime DESC LIMIT 200)');
    NewsDb.bumpDataVersion();
  }

  static async listHistory(limit: number): Promise<NewsItem[]> {
    await NewsDb.ensureReady();
    const store: relationalStore.RdbStore = NewsDb.requireStore();
    const sql: string = 'SELECT news.* FROM news INNER JOIN history ON history.newsId = news.id GROUP BY news.id ORDER BY MAX(history.viewTime) DESC LIMIT ?';
    const rs: relationalStore.ResultSet = await store.querySql(sql, [limit]);
    return NewsDb.readAll(rs);
  }

  static async countHistory(): Promise<number> {
    await NewsDb.ensureReady();
    const store: relationalStore.RdbStore = NewsDb.requireStore();
    const rs: relationalStore.ResultSet = await store.querySql('SELECT COUNT(DISTINCT newsId) AS cnt FROM history');
    return NewsDb.readSingleCount(rs);
  }

  static async isFavorite(id: number): Promise<boolean> {
    await NewsDb.ensureReady();
    const store: relationalStore.RdbStore = NewsDb.requireStore();
    const rs: relationalStore.ResultSet = await store.querySql('SELECT COUNT(*) AS cnt FROM favorite WHERE newsId = ?', [id]);
    return NewsDb.readSingleCount(rs) > 0;
  }

  static async toggleFavorite(id: number): Promise<boolean> {
    await NewsDb.ensureReady();
    const store: relationalStore.RdbStore = NewsDb.requireStore();
    const before: boolean = await NewsDb.isFavorite(id);
    if (before) {
      await store.executeSql('DELETE FROM favorite WHERE newsId = ?', [id]);
      NewsDb.bumpDataVersion();
      return false;
    }
    try {
      await store.executeSql('INSERT INTO favorite (newsId, createTime) VALUES (?, ?)', [id, Date.now()]);
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      hilog.warn(DOMAIN, TAG, 'toggleFavorite insert conflict: %{public}s', JSON.stringify(e));
    }
    const after: boolean = await NewsDb.isFavorite(id);
    NewsDb.bumpDataVersion();
    return after;
  }

  static async countFavorites(): Promise<number> {
    await NewsDb.ensureReady();
    const store: relationalStore.RdbStore = NewsDb.requireStore();
    const rs: relationalStore.ResultSet = await store.querySql('SELECT COUNT(*) AS cnt FROM favorite');
    return NewsDb.readSingleCount(rs);
  }

  static async countOwnNews(): Promise<number> {
    await NewsDb.ensureReady();
    const store: relationalStore.RdbStore = NewsDb.requireStore();
    const rs: relationalStore.ResultSet = await store.querySql('SELECT COUNT(*) AS cnt FROM news WHERE isOwn = 1');
    return NewsDb.readSingleCount(rs);
  }

  private static async ensureReady(): Promise<void> {
    if (NewsDb.ready === null) {
      throw new Error('NewsDb not initialized: call NewsDb.init(context) first');
    }
    await NewsDb.ready;
  }

  private static requireStore(): relationalStore.RdbStore {
    if (NewsDb.store === null) {
      throw new Error('NewsDb store not ready');
    }
    return NewsDb.store;
  }

  private static async seedIfNeeded(store: relationalStore.RdbStore): Promise<void> {
    if (await NewsDb.hasMetaFlag(store, 'seeded')) {
      return;
    }
    const rs: relationalStore.ResultSet = await store.querySql('SELECT COUNT(*) AS cnt FROM news');
    const count: number = NewsDb.readSingleCount(rs);
    if (count === 0) {
      for (const seed of SEED_NEWS) {
        const bucket: relationalStore.ValuesBucket = {
          'title': seed.title,
          'body': seed.body,
          'category': seed.category,
          'source': seed.source,
          'publishTime': seed.publishTime,
          'summary': seed.summary,
          'readCount': seed.readCount,
          'isPinned': seed.isPinned ? 1 : 0,
          'isOwn': 0,
          'visibleToStudent': 1
        };
        await store.insert('news', bucket);
      }
      hilog.info(DOMAIN, TAG, 'seeded %{public}d prototype news', SEED_NEWS.length);
    }
    await store.executeSql("INSERT OR REPLACE INTO meta (key, value) VALUES ('seeded', '1')");
  }

  private static async hasMetaFlag(store: relationalStore.RdbStore, key: string): Promise<boolean> {
    const rs: relationalStore.ResultSet = await store.querySql('SELECT value FROM meta WHERE key = ?', [key]);
    try {
      return rs.goToFirstRow();
    } finally {
      rs.close();
    }
  }

  private static readAll(rs: relationalStore.ResultSet): NewsItem[] {
    const items: NewsItem[] = [];
    try {
      while (rs.goToNextRow()) {
        items.push(NewsDb.rowToItem(rs));
      }
    } finally {
      rs.close();
    }
    return items;
  }

  private static readSingleCount(rs: relationalStore.ResultSet): number {
    let count: number = 0;
    try {
      if (rs.goToFirstRow()) {
        count = rs.getLong(rs.getColumnIndex('cnt'));
      }
    } finally {
      rs.close();
    }
    return count;
  }

  private static rowToItem(rs: relationalStore.ResultSet): NewsItem {
    const item: NewsItem = new NewsItem();
    item.id = rs.getLong(rs.getColumnIndex('id'));
    item.title = rs.getString(rs.getColumnIndex('title'));
    item.body = rs.getString(rs.getColumnIndex('body'));
    item.category = rs.getString(rs.getColumnIndex('category'));
    item.source = rs.getString(rs.getColumnIndex('source'));
    item.publishTime = rs.getString(rs.getColumnIndex('publishTime'));
    item.summary = rs.getString(rs.getColumnIndex('summary'));
    item.readCount = rs.getLong(rs.getColumnIndex('readCount'));
    item.isPinned = rs.getLong(rs.getColumnIndex('isPinned')) === 1;
    item.isOwn = rs.getLong(rs.getColumnIndex('isOwn')) === 1;
    item.visibleToStudent = rs.getLong(rs.getColumnIndex('visibleToStudent')) === 1;
    return item;
  }

  private static bumpDataVersion(): void {
    const current: number | undefined = AppStorage.get<number>('dataVersion');
    const next: number = (current === undefined ? 0 : current) + 1;
    AppStorage.setOrCreate<number>('dataVersion', next);
  }

  private static today(): string {
    const d: Date = new Date();
    const month: number = d.getMonth() + 1;
    const day: number = d.getDate();
    const mm: string = month < 10 ? '0' + month : '' + month;
    const dd: string = day < 10 ? '0' + day : '' + day;
    return d.getFullYear() + '-' + mm + '-' + dd;
  }
}
