# CampusNews（校园资讯）

基于 **HarmonyOS（API 12 · Stage 模型 · ArkTS / ArkUI）** 的校园资讯移动应用：
资讯浏览 / 搜索 / 详情互动 / 发布管理，学生与管理员双角色权限，本地 RDB + 偏好存储，
全套自绘线性图标，**零三方依赖**。

- **作者主页**：<https://rain-sealedletter.top/>
- **开源地址**：<https://github.com/Izayoi-Arashi/CampusNews>
- 软件内「我的 → 关于项目」亦可查看并跳转这两个地址。

## 功能特性

- 资讯列表：卡片流 + 日期头 + 条数统计，置顶资讯反色高亮，空态引导
- 关键词搜索：输入即查本地 RDB，标题匹配实时刷新
- 资讯详情：正文分段渲染、收藏切换、阅读计数、相关资讯推荐、浏览历史自动记录
- 发布管理（管理员）：表单字数校验、草稿持久化、成功模态、删除二次确认
- 双角色权限：学生 / 管理员，身份经 Preferences 持久化，界面能力按角色自动裁剪
- 工程亮点：@Styles / @Extend 样式装饰器复用（15 个装饰器 · 37 处复用）、Theme 设计常量统一视觉

## 技术栈

| 项 | 说明 |
| --- | --- |
| 系统 | HarmonyOS 5.0.0(12)，Stage 模型 |
| 语言 / UI | ArkTS + ArkUI 声明式开发 |
| 存储 | 关系型数据库 RDB（资讯/收藏/历史）+ Preferences（身份/草稿） |
| 状态管理 | AppStorage + @StorageLink / @StorageProp / @Watch 跨页联动 |
| 三方依赖 | 无（全部系统 API） |

## 快速开始

1. DevEco Studio 5.0.0 及以上（含 HarmonyOS SDK API 12）打开本目录，等待 hvigor Sync 完成。
2. 菜单 File → Project Structure → Signing Configs，勾选 Automatically generate signature。
3. 选择 Phone 模拟器或真机，Run 'entry' 即可。

> 工程不携带任何签名配置与构建产物，克隆后即为干净源码。

## 工程结构

    AppScope/                  应用级配置
    entry/src/main/ets/
      entryability/            应用入口
      pages/                   页面（Index / NewsDetail）
      view/                    业务视图（列表 / 发布 / 我的 / 卡片 / 底栏）
      db/                      RDB 封装（NewsDb）
      common/                  主题常量（Theme）与偏好（Prefs）
      model/                   数据模型（NewsItem）
      resources/               图标与媒体资源

## 许可证

[MIT](./LICENSE) © 2026 Izayoi-Arashi · [rain-sealedletter.top](https://rain-sealedletter.top/)
