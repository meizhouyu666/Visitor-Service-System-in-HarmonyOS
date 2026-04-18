import { ComplaintItem, WeatherResponse } from '../../common/model/ApiModels'
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
import { EmptyStateCard, FloatingCard, PrimaryActionButton, SectionHeader, StatusBadge } from '../../common/ui/UiKit'

interface QuickServiceItem {
  key: string
  icon: string
  title: string
}

@Component
export struct VisitorHomePage {
  @Prop displayName: string = '游客'
  @Prop onNavigate: (target: string) => void = () => {}

  @State private weatherToday: WeatherResponse | null = null
  @State private complaintList: ComplaintItem[] = []
  @State private loading: boolean = false
  @State private errorMessage: string = ''

  private quickServices: QuickServiceItem[] = [
    { key: 'complaint', icon: '💬', title: '投诉建议' },
    { key: 'emergency', icon: '🚨', title: '应急信息' },
    { key: 'services', icon: '🏨', title: '酒店查询' },
    { key: 'services', icon: '🗺', title: '景区导览' }
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
      this.weatherToday = weather.length > 0 ? weather[0] : null
      this.complaintList = [...complaints]
    } catch (_error) {
      this.errorMessage = '首页数据加载失败，请稍后重试'
    } finally {
      this.loading = false
    }
  }

  private latestComplaint(): ComplaintItem | null {
    return this.complaintList.length > 0 ? this.complaintList[0] : null
  }

  private weatherSummaryText(): string {
    if (this.weatherToday === null) {
      return '天气数据准备中'
    }
    return `${this.weatherToday.weather} · ${this.weatherToday.temperature} · ${this.weatherToday.wind}`
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

        PrimaryActionButton({
          label: '开始新的出行计划',
          onPress: () => this.onNavigate('services')
        })
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
                this.onNavigate(item.key)
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
        SectionHeader({ title: '今日推荐景点', subtitle: '高质量风景卡片（本地资源）' })

        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.home_recommend'))
            .width('100%')
            .height(180)
            .objectFit(ImageFit.Cover)
            .borderRadius(RADIUS_MD)

          Column({ space: 4 }) {
            Text('北屿湖湾')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
            Text('日落摄影热门景点，建议 17:30 前到达')
              .fontSize(11)
              .fontColor('#E8F0FF')
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
    const latest: ComplaintItem | null = this.latestComplaint()
    FloatingCard() {
      Column({ space: 8 }) {
        Row() {
          SectionHeader({ title: '投诉进度摘要', subtitle: '最近记录与状态一目了然' })
          Blank()
          Button('查看全部')
            .onClick(() => this.onNavigate('complaint'))
            .height(30)
            .fontSize(12)
            .borderRadius(RADIUS_PILL)
            .backgroundColor('#ECF3FF')
            .fontColor(THEME_PRIMARY)
        }
        .width('100%')

        if (latest === null) {
          EmptyStateCard({ message: '还没有投诉记录，祝你旅途愉快。' })
        } else {
          Column({ space: 6 }) {
            Row() {
              Text(latest.title)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(THEME_TEXT_PRIMARY)
                .layoutWeight(1)
              StatusBadge({ label: latest.status, tone: 'primary' })
            }
            .width('100%')

            Text(latest.content)
              .fontSize(12)
              .fontColor(THEME_TEXT_SECONDARY)
              .maxLines(2)
            Text(`更新时间：${latest.updatedAt}`)
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
