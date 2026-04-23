import { ComplaintItem, PerformanceResponse, WeatherResponse } from '../../common/model/ApiModels'
import { apiClient } from '../../common/network/ApiClient'
import {
  RADIUS_MD,
  RADIUS_PILL,
  SHADOW_CARD,
  THEME_PAGE_BG,
  THEME_PRIMARY,
  THEME_SURFACE,
  THEME_TEXT_PRIMARY,
  THEME_TEXT_SECONDARY,
  THEME_TEXT_TERTIARY
} from '../../common/ui/AppTheme'
import { EmptyStateCard, FloatingCard, SectionHeader, StatusBadge } from '../../common/ui/UiKit'
import { VisitorServiceTab } from './VisitorServicesPage'

interface QuickServiceItem {
  key: VisitorNav
  icon: string
  title: string
  serviceTab?: VisitorServiceTab
}

type VisitorNav = 'home' | 'services' | 'complaint' | 'emergency'

@Component
export struct VisitorHomePage {
  @Prop displayName: string = '游客'
  @Link navKey: VisitorNav
  @Link serviceTab: VisitorServiceTab

  @State private weatherToday: WeatherResponse | null = null
  @State private complaintList: ComplaintItem[] = []
  @State private topPerformance: PerformanceResponse | null = null
  @State private loading: boolean = false
  @State private errorMessage: string = ''

  private quickServices: QuickServiceItem[] = [
    { key: 'complaint', icon: '💬', title: '投诉建议' },
    { key: 'emergency', icon: '🚨', title: '应急信息' },
    { key: 'services', icon: '🏨', title: '酒店查询', serviceTab: 'routes' },
    { key: 'services', icon: '🍜', title: '餐饮娱乐', serviceTab: 'dining' }
  ]

  async aboutToAppear(): Promise<void> {
    await this.loadData()
  }

  private async loadData(): Promise<void> {
    this.loading = true
    this.errorMessage = ''
    try {
      const weather: WeatherResponse[] = await apiClient.get<WeatherResponse[]>('/api/query/weather')
      const complaints: ComplaintItem[] = await apiClient.get<ComplaintItem[]>('/api/complaints')
      const performances: PerformanceResponse[] = await apiClient.get<PerformanceResponse[]>('/api/query/performances?sortBy=time_asc&limit=1')
      this.weatherToday = weather.length > 0 ? weather[0] : null
      this.complaintList = [...complaints]
      this.topPerformance = performances.length > 0 ? performances[0] : null
    } catch (_error) {
      this.errorMessage = '首页数据加载失败，请稍后重试'
    } finally {
      this.loading = false
    }
  }

  private latestComplaint(): ComplaintItem | null {
    return this.complaintList.length > 0 ? this.complaintList[0] : null
  }

  private hasLatestComplaint(): boolean {
    return this.latestComplaint() !== null
  }

  private latestComplaintTitle(): string {
    const latest: ComplaintItem | null = this.latestComplaint()
    if (latest === null) {
      return ''
    }
    return latest.title
  }

  private latestComplaintStatus(): string {
    const latest: ComplaintItem | null = this.latestComplaint()
    if (latest === null) {
      return ''
    }
    return latest.status
  }

  private latestComplaintContent(): string {
    const latest: ComplaintItem | null = this.latestComplaint()
    if (latest === null) {
      return ''
    }
    return latest.content
  }

  private latestComplaintUpdatedAt(): string {
    const latest: ComplaintItem | null = this.latestComplaint()
    if (latest === null) {
      return ''
    }
    return latest.updatedAt
  }

  private weatherSummaryText(): string {
    if (this.weatherToday === null) {
      return '天气数据准备中'
    }
    return `${this.weatherToday.weather} · ${this.weatherToday.temperature} · ${this.weatherToday.wind}`
  }

  private navigateTo(target: VisitorNav, tab: VisitorServiceTab = 'routes'): void {
    if (target === 'services') {
      this.serviceTab = tab
    }
    if (this.navKey === target) {
      return
    }
    animateTo({ duration: 220, curve: Curve.EaseInOut }, () => {
      this.navKey = target
    })
  }

  @Builder
  private HeaderCard(): void {
    FloatingCard() {
      Column({ space: 10 }) {
        Row() {
          Column({ space: 4 }) {
            Text(`你好，${this.displayName}`)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(THEME_TEXT_PRIMARY)
            Text('欢迎来到游客服务系统')
              .fontSize(12)
              .fontColor(THEME_TEXT_SECONDARY)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Column({ space: 4 }) {
            StatusBadge({ label: '今日天气', tone: 'primary' })
            Text(this.weatherSummaryText())
              .fontSize(11)
              .fontColor(THEME_TEXT_TERTIARY)
              .maxLines(2)
              .textAlign(TextAlign.End)
          }
          .alignItems(HorizontalAlign.End)
        }

        Button('开始新旅程')
          .onClick(() => {
            this.navigateTo('services', 'routes')
          })
          .width('100%')
          .height(44)
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_PRIMARY)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .shadow(SHADOW_CARD)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  private QuickServiceGrid(): void {
    FloatingCard() {
      Column({ space: 10 }) {
        SectionHeader({ title: '核心服务', subtitle: '点击进入高频功能' })

        GridRow({ columns: 4, gutter: { x: 10, y: 10 } }) {
          ForEach(this.quickServices, (item: QuickServiceItem) => {
            GridCol({ span: 1 }) {
              Column({ space: 8 }) {
                Text(item.icon)
                  .fontSize(18)
                  .width(42)
                  .height(42)
                  .textAlign(TextAlign.Center)
                  .lineHeight(42)
                  .backgroundColor('#EAF2FF')
                  .borderRadius(RADIUS_PILL)
                Text(item.title)
                  .fontSize(11)
                  .fontColor(THEME_TEXT_SECONDARY)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center)
              .padding({ top: 8, bottom: 8 })
              .borderRadius(RADIUS_MD)
              .backgroundColor(THEME_SURFACE)
              .onClick(() => {
                this.navigateTo(item.key, item.serviceTab ?? 'routes')
              })
            }
          }, (item: QuickServiceItem) => `${item.title}-${item.icon}`)
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  private RecommendCard(): void {
    FloatingCard() {
      Column({ space: 8 }) {
        SectionHeader({
          title: this.topPerformance === null ? '今日推荐景点' : '热门演出预告',
          subtitle: this.topPerformance === null ? '高质量风景卡片（本地资源）' : '点击服务页可查看更多场次'
        })

        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.home_recommend'))
            .width('100%')
            .height(180)
            .objectFit(ImageFit.Cover)
            .borderRadius(RADIUS_MD)

          Column({ space: 4 }) {
            if (this.topPerformance === null) {
              Text('北屿湖湾')
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
              Text('日落摄影热门景点，建议 17:30 前到达')
                .fontSize(11)
                .fontColor('#E8F0FF')
            } else {
              Text(this.topPerformance.name)
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
              Text(`场馆 ${this.topPerformance.venue ?? this.topPerformance.location} · ${this.topPerformance.showDateTime ?? this.topPerformance.showTime}`)
                .fontSize(11)
                .fontColor('#E8F0FF')
            }
          }
          .padding(12)
          .width('100%')
          .backgroundColor('#7A0F172A')
          .borderRadius(RADIUS_MD)
        }
      }
      .width('100%')
    }
  }

  @Builder
  private ComplaintSummaryCard(): void {
    FloatingCard() {
      Column({ space: 8 }) {
        Row() {
          SectionHeader({ title: '投诉进度摘要', subtitle: '最近记录与状态一目了然' })
            .layoutWeight(1) // 核心：占满剩余空间，不挤压按钮

          Button('查看全部')
            .onClick(() => {
              this.navigateTo('complaint')
            })
            .height(30)
            .fontSize(12)
            .borderRadius(RADIUS_PILL)
            .backgroundColor('#ECF3FF')
            .fontColor(THEME_PRIMARY)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)

        if (!this.hasLatestComplaint()) {
          EmptyStateCard({ message: '还没有投诉记录，祝你旅途愉快。' })
        } else {
          Column({ space: 6 }) {
            Row() {
              Text(this.latestComplaintTitle())
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(THEME_TEXT_PRIMARY)
                .layoutWeight(1)
              StatusBadge({ label: this.latestComplaintStatus(), tone: 'primary' })
            }
            .width('100%')

            Text(this.latestComplaintContent())
              .fontSize(12)
              .fontColor(THEME_TEXT_SECONDARY)
              .maxLines(2)
            Text(`更新时间：${this.latestComplaintUpdatedAt()}`)
              .fontSize(10)
              .fontColor(THEME_TEXT_TERTIARY)
          }
          .padding(12)
          .width('100%')
          .backgroundColor('#F8FAFF')
          .borderRadius(RADIUS_MD)
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        if (this.loading) {
          Column() {
            Text('正在准备首页内容...')
              .fontSize(13)
              .fontColor(THEME_TEXT_SECONDARY)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(THEME_SURFACE)
          .borderRadius(RADIUS_MD)
          .shadow(SHADOW_CARD)
        }

        if (this.errorMessage.length > 0) {
          Column({ space: 8 }) {
            Text(this.errorMessage)
              .fontSize(12)
              .fontColor('#B42318')
            Button('重试')
              .onClick(() => this.loadData())
              .height(34)
              .borderRadius(RADIUS_PILL)
              .backgroundColor('#FEE4E2')
              .fontColor('#B42318')
          }
          .width('100%')
          .padding(14)
          .backgroundColor(THEME_SURFACE)
          .borderRadius(RADIUS_MD)
        }

        this.HeaderCard()
        this.QuickServiceGrid()
        this.RecommendCard()
        this.ComplaintSummaryCard()
      }
      .padding({ left: 12, right: 12, top: 12, bottom: 98 })
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .height('100%')
    .backgroundColor(THEME_PAGE_BG)
  }
}

