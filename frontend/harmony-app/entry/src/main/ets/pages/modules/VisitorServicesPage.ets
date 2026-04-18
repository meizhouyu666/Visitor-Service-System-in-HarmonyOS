import { HotelResponse, ScenicSpotResponse, TravelRouteResponse } from '../../common/model/ApiModels'
import { apiClient } from '../../common/network/ApiClient'
import {
  RADIUS_MD,
  SHADOW_CARD,
  THEME_PAGE_BG,
  THEME_SURFACE,
  THEME_TEXT_PRIMARY,
  THEME_TEXT_SECONDARY,
  THEME_TEXT_TERTIARY
} from '../../common/ui/AppTheme'
import { EmptyStateCard, FilterChip, FloatingCard, SectionHeader, StatusBadge } from '../../common/ui/UiKit'

type ServiceFilter = 'all' | 'hotel' | 'scenic' | 'route'

@Component
export struct VisitorServicesPage {
  @State private filter: ServiceFilter = 'all'
  @State private loading: boolean = false
  @State private errorMessage: string = ''

  @State private hotels: HotelResponse[] = []
  @State private scenicList: ScenicSpotResponse[] = []
  @State private routes: TravelRouteResponse[] = []

  async aboutToAppear(): Promise<void> {
    await this.loadData()
  }

  private async loadData(): Promise<void> {
    this.loading = true
    this.errorMessage = ''
    try {
      const hotelList: HotelResponse[] = await apiClient.get<HotelResponse[]>('/api/query/hotels')
      const scenicData: ScenicSpotResponse[] = await apiClient.get<ScenicSpotResponse[]>('/api/query/scenic-spots')
      const routeData: TravelRouteResponse[] = await apiClient.get<TravelRouteResponse[]>('/api/query/routes')

      this.hotels = [...hotelList]
      this.scenicList = [...scenicData]
      this.routes = [...routeData]
    } catch (_error) {
      this.errorMessage = '服务数据加载失败，请稍后重试'
    } finally {
      this.loading = false
    }
  }

  private hotelCover(index: number): ResourceStr {
    return index % 2 === 0 ? $r('app.media.hotel_cover_a') : $r('app.media.hotel_cover_b')
  }

  private scenicCover(index: number): ResourceStr {
    return index % 2 === 0 ? $r('app.media.scenic_cover_a') : $r('app.media.scenic_cover_b')
  }

  private routeCover(index: number): ResourceStr {
    return index % 2 === 0 ? $r('app.media.route_cover_a') : $r('app.media.route_cover_b')
  }

  private availabilityTone(status: string | undefined): 'primary' | 'success' | 'warning' | 'danger' | 'neutral' {
    if (status === 'AVAILABLE') {
      return 'success'
    }
    if (status === 'LIMITED') {
      return 'warning'
    }
    if (status === 'BUSY' || status === 'FULL') {
      return 'neutral'
    }
    return 'neutral'
  }

  private availabilityLabel(status: string | undefined): string {
    if (status === 'AVAILABLE') {
      return '有房'
    }
    if (status === 'LIMITED') {
      return '余量紧张'
    }
    if (status === 'BUSY' || status === 'FULL') {
      return '客满'
    }
    return '待确认'
  }

  private crowdHeatValue(item: ScenicSpotResponse): number {
    if (item.crowdHeat === undefined || item.crowdHeat < 0) {
      return 0
    }
    if (item.crowdHeat > 100) {
      return 100
    }
    return item.crowdHeat
  }

  @Builder
  private FilterBar(): void {
    FloatingCard() {
      Column({ space: 10 }) {
        SectionHeader({ title: '服务与线路', subtitle: '酒店、景区和线路统一筛选视图' })

        Row({ space: 8 }) {
          FilterChip({ label: '全部', selected: this.filter === 'all', onToggle: () => this.filter = 'all' })
          FilterChip({ label: '酒店', selected: this.filter === 'hotel', onToggle: () => this.filter = 'hotel' })
          FilterChip({ label: '景区', selected: this.filter === 'scenic', onToggle: () => this.filter = 'scenic' })
          FilterChip({ label: '线路', selected: this.filter === 'route', onToggle: () => this.filter = 'route' })
          Blank()
          Button('刷新')
            .onClick(() => this.loadData())
            .height(34)
            .fontSize(12)
            .borderRadius(999)
            .backgroundColor('#EAF2FF')
            .fontColor('#007AFF')
        }
        .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  private HotelSection(): void {
    FloatingCard() {
      Column({ space: 10 }) {
        SectionHeader({ title: '酒店推荐', subtitle: '房态、评分、价格清晰展示' })
        if (this.hotels.length === 0) {
          EmptyStateCard({ message: '暂无酒店数据' })
        } else {
          ForEach(this.hotels, (item: HotelResponse, index: number) => {
            Column({ space: 8 }) {
              Image(this.hotelCover(index))
                .width('100%')
                .height(138)
                .objectFit(ImageFit.Cover)
                .borderRadius(RADIUS_MD)

              Row() {
                Text(item.name)
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(THEME_TEXT_PRIMARY)
                  .layoutWeight(1)
                StatusBadge({
                  label: this.availabilityLabel(item.availabilityStatus),
                  tone: this.availabilityTone(item.availabilityStatus)
                })
              }
              .width('100%')

              Text(`${item.star} 星 · 评分 ${item.score} · ¥${item.price} 起`)
                .fontSize(12)
                .fontColor(THEME_TEXT_SECONDARY)
              Text(item.address)
                .fontSize(11)
                .fontColor(THEME_TEXT_TERTIARY)
                .maxLines(1)
            }
            .width('100%')
            .padding(10)
            .borderRadius(RADIUS_MD)
            .backgroundColor('#F8FAFF')
          }, (item: HotelResponse) => item.id)
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  private ScenicSection(): void {
    FloatingCard() {
      Column({ space: 10 }) {
        SectionHeader({ title: '景区导览', subtitle: '客流热度辅助避峰出行' })
        if (this.scenicList.length === 0) {
          EmptyStateCard({ message: '暂无景区数据' })
        } else {
          ForEach(this.scenicList, (item: ScenicSpotResponse, index: number) => {
            Column({ space: 8 }) {
              Image(this.scenicCover(index))
                .width('100%')
                .height(138)
                .objectFit(ImageFit.Cover)
                .borderRadius(RADIUS_MD)

              Text(item.name)
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor(THEME_TEXT_PRIMARY)
              Text(`${item.level} · ${item.location} · ¥${item.ticketPrice}`)
                .fontSize(12)
                .fontColor(THEME_TEXT_SECONDARY)

              Row({ space: 8 }) {
                Text('客流热度')
                  .fontSize(11)
                  .fontColor(THEME_TEXT_SECONDARY)
                Progress({ total: 100, value: this.crowdHeatValue(item), type: ProgressType.Linear })
                  .layoutWeight(1)
                  .color('#007AFF')
                  .style({ strokeWidth: 6 })
                Text(`${this.crowdHeatValue(item)}%`)
                  .fontSize(10)
                  .fontColor(THEME_TEXT_TERTIARY)
              }
              .width('100%')
            }
            .width('100%')
            .padding(10)
            .borderRadius(RADIUS_MD)
            .backgroundColor('#F8FAFF')
          }, (item: ScenicSpotResponse) => item.id)
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  private RouteSection(): void {
    FloatingCard() {
      Column({ space: 10 }) {
        SectionHeader({ title: '线路推荐', subtitle: '难度、时长、适合人群一屏可见' })
        if (this.routes.length === 0) {
          EmptyStateCard({ message: '暂无线路数据' })
        } else {
          ForEach(this.routes, (item: TravelRouteResponse, index: number) => {
            Column({ space: 8 }) {
              Image(this.routeCover(index))
                .width('100%')
                .height(138)
                .objectFit(ImageFit.Cover)
                .borderRadius(RADIUS_MD)

              Text(item.name)
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor(THEME_TEXT_PRIMARY)
              Text(`时长 ${item.durationHours} 小时 · 难度 ${item.difficulty}`)
                .fontSize(12)
                .fontColor(THEME_TEXT_SECONDARY)
              Text(`适合：${item.suitableFor}`)
                .fontSize(11)
                .fontColor(THEME_TEXT_SECONDARY)
              Text(`覆盖景点：${item.spots}`)
                .fontSize(11)
                .fontColor(THEME_TEXT_TERTIARY)
                .maxLines(1)
            }
            .width('100%')
            .padding(10)
            .borderRadius(RADIUS_MD)
            .backgroundColor('#F8FAFF')
          }, (item: TravelRouteResponse) => item.id)
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  private MainContent(): void {
    if (this.loading) {
      Column() {
        Text('正在加载服务数据...')
          .fontSize(12)
          .fontColor(THEME_TEXT_SECONDARY)
      }
      .width('100%')
      .padding(14)
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
          .borderRadius(999)
          .backgroundColor('#FEE4E2')
          .fontColor('#B42318')
      }
      .width('100%')
      .padding(12)
      .backgroundColor(THEME_SURFACE)
      .borderRadius(RADIUS_MD)
    }

    if (this.filter === 'all' || this.filter === 'hotel') {
      this.HotelSection()
    }
    if (this.filter === 'all' || this.filter === 'scenic') {
      this.ScenicSection()
    }
    if (this.filter === 'all' || this.filter === 'route') {
      this.RouteSection()
    }
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        this.FilterBar()
        this.MainContent()
      }
      .padding({ left: 12, right: 12, top: 12, bottom: 98 })
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .height('100%')
    .backgroundColor(THEME_PAGE_BG)
  }
}
