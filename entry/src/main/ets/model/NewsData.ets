export class NewsItem {
  id: number = 0;
  title: string = '';
  body: string = '';
  category: string = '';
  source: string = '';
  publishTime: string = '';
  summary: string = '';
  readCount: number = 0;
  isPinned: boolean = false;
  isOwn: boolean = false;
  visibleToStudent: boolean = true;
}

export const CATEGORIES: string[] = ['重要通知', '志愿服务', '校园服务', '就业信息'];

export const DEPTS: string[] = ['学生工作处', '教务处', '校团委', '图书馆', '就业指导中心'];
