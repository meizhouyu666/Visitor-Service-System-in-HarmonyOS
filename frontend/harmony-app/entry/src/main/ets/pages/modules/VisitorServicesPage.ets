import { HotelResponse, ScenicSpotResponse, TravelRouteResponse } from '../../common/model/ApiModels'
import { apiClient } from '../../common/network/ApiClient'
import {
  RADIUS_MD,
  THEME_PAGE_BG,
  THEME_PRIMARY,
  THEME_TEXT_PRIMARY,
  THEME_TEXT_SECONDARY,
  THEME_TEXT_TERTIARY
} from '../../common/ui/AppTheme'
import { EmptyStateCard, FilterChip, FloatingCard, SectionHeader, StatusBadge } from '../../common/ui/UiKit'
import { DiningShowPage } from './DiningShowPage'

export type VisitorServiceTab = 'routes' | 'dining'
type ServiceFilter = 'all' | 'hotel' | 'scenic' | 'route'
type LevelFilter = 'all' | 'high' | 'normal'
type AreaFilter = 'all' | '古城' | '滨江' | '景区'
type PriceFilter = 'all' | '0-100' | '100-300' | '300-600' | '600+'

@Component
export struct VisitorServicesPage {
  @Link mainTab: VisitorServiceTab

  @State private filter: ServiceFilter = 'all'
  @State private levelFilter: LevelFilter = 'all'
  @State private areaFilter: AreaFilter = 'all'
  @State private priceFilter: PriceFilter = 'all'

  @State private loading: boolean = false
  @State private errorMessage: string = ''

  @State private hotels: HotelResponse[] = []
  @State private scenicList: ScenicSpotResponse[] = []
  @State private routes: TravelRouteResponse[] = []

  async aboutToAppear(): Promise<void> {
    await this.loadRouteData()
  }

  private parsePriceFilter(): { minPrice: number | undefined; maxPrice: number | undefined } {
    if (this.priceFilter === '0-100') {
      return { minPrice: 0, maxPrice: 100 }
    }
    if (this.priceFilter === '100-300') {
      return { minPrice: 100, maxPrice: 300 }
    }
    if (this.priceFilter === '300-600') {
      return { minPrice: 300, maxPrice: 600 }
    }
    if (this.priceFilter === '600+') {
      return { minPrice: 600, maxPrice: undefined }
    }
    return { minPrice: undefined, maxPrice: undefined }
  }

  private areaParam(): string {
    if (this.areaFilter === 'all') {
      return ''
    }
    return this.areaFilter
  }

  private buildQuery(params: Record<string, string | number | undefined>): string {
    const query: string[] = []
    Object.keys(params).forEach((key: string) => {
      const value: string | number | undefined = params[key]
      if (value !== undefined && `${value}`.trim().length > 0) {
        query.push(`${key}=${encodeURIComponent(`${value}`)}`)
      }
    })
    return query.length > 0 ? `?${query.join('&')}` : ''
  }

  private scenicLevelParam(): string {
    if (this.levelFilter === 'high') {
      return 'AAAA'
    }
    if (this.levelFilter === 'normal') {
      return 'AAA'
    }
    return ''
  }

  private hotelMinStarParam(): number | undefined {
    if (this.levelFilter === 'high') {
      return 4
    }
    if (this.levelFilter === 'normal') {
      return 3
    }
    return undefined
  }

  private async loadRouteData(): Promise<void> {
    this.loading = true
    this.errorMessage = ''
    try {
      const priceRange: { minPrice: number | undefined; maxPrice: number | undefined } = this.parsePriceFilter()
      const hotelsPath: string = `/api/query/hotels${this.buildQuery({
        area: this.areaParam(),
        minPrice: priceRange.minPrice,
        maxPrice: priceRange.maxPrice,
        minStar: this.hotelMinStarParam()
      })}`
      const scenicPath: string = `/api/query/scenic-spots${this.buildQuery({
        area: this.areaParam(),
        level: this.scenicLevelParam(),
        minPrice: priceRange.minPrice,
        maxPrice: priceRange.maxPrice
      })}`

      const hotelList: HotelResponse[] = await apiClient.get<HotelResponse[]>(hotelsPath)
      const scenicData: ScenicSpotResponse[] = await apiClient.get<ScenicSpotResponse[]>(scenicPath)
      const routeData: TravelRouteResponse[] = await apiClient.get<TravelRouteResponse[]>('/api/query/routes')

      this.hotels = [...hotelList]
      this.scenicList = [...scenicData]
      this.routes = [...routeData]
    } catch (_error) {
      this.errorMessage = '服务与线路数据加载失败，请稍后重试'
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

  private availabilityTone(status: string | undefined): 'success' | 'warning' | 'neutral' {
    if (status === 'AVAILABLE') {
      return 'success'
    }
    if (status === 'LIMITED') {
      return 'warning'
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
  private MainTabs(): void {
    Row({ space: 8 }) {
      Button('酒店景区线路')
        .layoutWeight(1)
        .height(38)
        .borderRadius(999)
        .fontColor(this.mainTab === 'routes' ? Color.White : THEME_TEXT_SECONDARY)
        .backgroundColor(this.mainTab === 'routes' ? THEME_PRIMARY : '#EEF3FA')
        .onClick(() => {
          this.mainTab = 'routes'
          this.loadRouteData()
        })
      Button('餐饮娱乐演出')
        .layoutWeight(1)
        .height(38)
        .borderRadius(999)
        .fontColor(this.mainTab === 'dining' ? Color.White : THEME_TEXT_SECONDARY)
        .backgroundColor(this.mainTab === 'dining' ? THEME_PRIMARY : '#EEF3FA')
        .onClick(() => {
          this.mainTab = 'dining'
        })
    }
    .width('100%')
  }

  @Builder
  private FloatingFilterBar(): void {
    FloatingCard() {
      Column({ space: 10 }) {
        SectionHeader({ title: '服务与线路', subtitle: '等级 / 区域 / 价格 快速筛选' })
        this.MainTabs()

        if (this.mainTab === 'routes') {
          Row({ space: 8 }) {
            FilterChip({
              label: '全部',
              selected: this.filter === 'all',
              onToggle: () => {
                this.filter = 'all'
              }
            })
            FilterChip({
              label: '酒店',
              selected: this.filter === 'hotel',
              onToggle: () => {
                this.filter = 'hotel'
              }
            })
            FilterChip({
              label: '景区',
              selected: this.filter === 'scenic',
              onToggle: () => {
                this.filter = 'scenic'
              }
            })
            FilterChip({
              label: '线路',
              selected: this.filter === 'route',
              onToggle: () => {
                this.filter = 'route'
              }
            })
          }
          .width('100%')

          Row({ space: 8 }) {
            FilterChip({
              label: this.levelFilter === 'all' ? '等级: 全部' : this.levelFilter === 'high' ? '等级: 高等级' : '等级: 标准',
              selected: this.levelFilter !== 'all',
              onToggle: () => {
                this.levelFilter = this.levelFilter === 'all' ? 'high' : this.levelFilter === 'high' ? 'normal' : 'all'
                this.loadRouteData()
              }
            })
            FilterChip({
              label: this.areaFilter === 'all' ? '区域: 全部' : `区域: ${this.areaFilter}`,
              selected: this.areaFilter !== 'all',
              onToggle: () => {
                this.areaFilter = this.areaFilter === 'all' ? '古城' : this.areaFilter === '古城' ? '滨江' : this.areaFilter === '滨江' ? '景区' : 'all'
                this.loadRouteData()
              }
            })
            FilterChip({
              label: this.priceFilter === 'all' ? '价格: 全部' : `价格: ${this.priceFilter}`,
              selected: this.priceFilter !== 'all',
              onToggle: () => {
                this.priceFilter = this.priceFilter === 'all' ? '0-100' : this.priceFilter === '0-100' ? '100-300' : this.priceFilter === '100-300' ? '300-600' : this.priceFilter === '300-600' ? '600+' : 'all'
                this.loadRouteData()
              }
            })
            Blank()
            Button('刷新')
              .onClick(() => this.loadRouteData())
              .height(34)
              .borderRadius(999)
              .backgroundColor('#EAF2FF')
              .fontColor(THEME_PRIMARY)
          }
          .width('100%')
        }
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
                  .color(THEME_PRIMARY)
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
  private RouteModeContent(): void {
    if (this.loading) {
      FloatingCard() {
        Text('正在加载服务数据...')
          .fontSize(12)
          .fontColor(THEME_TEXT_SECONDARY)
      }
    } else if (this.errorMessage.length > 0) {
      FloatingCard() {
        Column({ space: 8 }) {
          Text(this.errorMessage).fontSize(12).fontColor('#B42318')
          Button('重试')
            .onClick(() => this.loadRouteData())
            .height(34)
            .borderRadius(999)
            .backgroundColor('#FEE4E2')
            .fontColor('#B42318')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
    } else {
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
  }

  build() {
    if (this.mainTab === 'dining') {
      Column({ space: 12 }) {
        this.FloatingFilterBar()
        DiningShowPage({ embedded: true })
      }
      .padding({ left: 12, right: 12, top: 12, bottom: 0 })
      .width('100%')
      .height('100%')
      .backgroundColor(THEME_PAGE_BG)
    } else {
      Scroll() {
        Column({ space: 12 }) {
          this.FloatingFilterBar()
          this.RouteModeContent()
        }
        .padding({ left: 12, right: 12, top: 12, bottom: 98 })
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .height('100%')
      .backgroundColor(THEME_PAGE_BG)
    }
  }
}
