import { HotelResponse, ScenicSpotResponse, TravelRouteResponse } from '../../common/model/ApiModels'
import { apiClient } from '../../common/network/ApiClient'
import {
  RADIUS_MD,
  RADIUS_PILL,
  SHADOW_CARD,
  THEME_DANGER,
  THEME_PAGE_BG,
  THEME_PRIMARY,
  THEME_PRIMARY_SOFT,
  THEME_SUCCESS,
  THEME_SURFACE,
  THEME_SURFACE_MUTED,
  THEME_TEXT_PRIMARY,
  THEME_TEXT_SECONDARY,
  THEME_TEXT_TERTIARY,
  THEME_WARNING
} from '../../common/ui/AppTheme'
import { DiningShowPage } from './DiningShowPage'

export type VisitorServiceTab = 'routes' | 'dining'
type ServiceFilter = 'all' | 'hotel' | 'scenic' | 'route'
type HotelStayFilter = 'all' | 'star' | 'bnb'
type LevelFilter = 'all' | 'high' | 'normal'
type AreaFilter = 'all' | '古城' | '滨江' | '景区'
type PriceFilter = 'all' | '0-100' | '100-300' | '300-600' | '600+'

class PriceRangeModel {
  minPrice: number | undefined
  maxPrice: number | undefined

  constructor(minPrice: number | undefined, maxPrice: number | undefined) {
    this.minPrice = minPrice
    this.maxPrice = maxPrice
  }
}

class QueryParam {
  key: string
  value: string | number | undefined

  constructor(key: string, value: string | number | undefined) {
    this.key = key
    this.value = value
  }
}

class HotelPromoCard {
  id: string
  title: string
  imageUrl: string
  badge: string
  ratingText: string
  priceText: string

  constructor(id: string, title: string, imageUrl: string, badge: string, ratingText: string, priceText: string) {
    this.id = id
    this.title = title
    this.imageUrl = imageUrl
    this.badge = badge
    this.ratingText = ratingText
    this.priceText = priceText
  }
}

@Component
export struct VisitorServicesPage {
  @Link mainTab: VisitorServiceTab

  @State private filter: ServiceFilter = 'all'
  @State private hotelStayFilter: HotelStayFilter = 'all'
  @State private levelFilter: LevelFilter = 'all'
  @State private areaFilter: AreaFilter = 'all'
  @State private priceFilter: PriceFilter = 'all'

  @State private loading: boolean = false
  @State private errorMessage: string = ''
  @State private contentOpacity: number = 1
  @State private contentOffsetY: number = 0
  @State private contentSwitching: boolean = false

  @State private hotels: HotelResponse[] = []
  @State private scenicList: ScenicSpotResponse[] = []
  @State private routes: TravelRouteResponse[] = []

  async aboutToAppear(): Promise<void> {
    await this.loadRouteData()
  }

  private runContentSwitch(onSwitched: () => void): void {
    if (this.contentSwitching) {
      onSwitched()
      return
    }
    this.contentSwitching = true
    this.contentOpacity = 0
    this.contentOffsetY = 10
    onSwitched()
    animateTo({ duration: 180, curve: Curve.EaseInOut }, () => {
      this.contentOpacity = 1
      this.contentOffsetY = 0
    })
    setTimeout(() => {
      this.contentSwitching = false
    }, 180)
  }

  private switchMainTab(tab: VisitorServiceTab): void {
    if (this.mainTab === tab) {
      return
    }
    this.runContentSwitch(() => {
      this.mainTab = tab
      if (tab === 'routes') {
        this.loadRouteData()
      }
    })
  }

  private parsePriceFilter(): PriceRangeModel {
    if (this.priceFilter === '0-100') {
      return new PriceRangeModel(0, 100)
    }
    if (this.priceFilter === '100-300') {
      return new PriceRangeModel(100, 300)
    }
    if (this.priceFilter === '300-600') {
      return new PriceRangeModel(300, 600)
    }
    if (this.priceFilter === '600+') {
      return new PriceRangeModel(600, undefined)
    }
    return new PriceRangeModel(undefined, undefined)
  }

  private areaParam(): string {
    if (this.areaFilter === 'all') {
      return ''
    }
    return this.areaFilter
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

  private buildQuery(params: QueryParam[]): string {
    const pairs: string[] = []
    params.forEach((item: QueryParam) => {
      const value: string | number | undefined = item.value
      if (value !== undefined && `${value}`.trim().length > 0) {
        pairs.push(`${item.key}=${encodeURIComponent(`${value}`)}`)
      }
    })
    return pairs.length > 0 ? `?${pairs.join('&')}` : ''
  }

  private async loadRouteData(): Promise<void> {
    this.loading = true
    this.errorMessage = ''
    try {
      const range: PriceRangeModel = this.parsePriceFilter()
      const hotelsPath: string = `/api/query/hotels${this.buildQuery([
        new QueryParam('area', this.areaParam()),
        new QueryParam('minPrice', range.minPrice),
        new QueryParam('maxPrice', range.maxPrice),
        new QueryParam('minStar', this.hotelMinStarParam())
      ])}`
      const scenicPath: string = `/api/query/scenic-spots${this.buildQuery([
        new QueryParam('area', this.areaParam()),
        new QueryParam('level', this.scenicLevelParam()),
        new QueryParam('minPrice', range.minPrice),
        new QueryParam('maxPrice', range.maxPrice)
      ])}`

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

  private hasVisibleRouteContent(): boolean {
    if (this.filter === 'hotel') {
      return this.visibleHotels().length > 0
    }
    if (this.filter === 'scenic') {
      return this.scenicList.length > 0
    }
    if (this.filter === 'route') {
      return this.routes.length > 0
    }
    return this.visibleHotels().length > 0 || this.scenicList.length > 0 || this.routes.length > 0
  }

  private refreshRouteData(): void {
    this.loadRouteData()
  }

  private cycleLevelFilter(): void {
    if (this.levelFilter === 'all') {
      this.levelFilter = 'high'
    } else if (this.levelFilter === 'high') {
      this.levelFilter = 'normal'
    } else {
      this.levelFilter = 'all'
    }
    this.refreshRouteData()
  }

  private cycleAreaFilter(): void {
    if (this.areaFilter === 'all') {
      this.areaFilter = '古城'
    } else if (this.areaFilter === '古城') {
      this.areaFilter = '滨江'
    } else if (this.areaFilter === '滨江') {
      this.areaFilter = '景区'
    } else {
      this.areaFilter = 'all'
    }
    this.refreshRouteData()
  }

  private cyclePriceFilter(): void {
    if (this.priceFilter === 'all') {
      this.priceFilter = '0-100'
    } else if (this.priceFilter === '0-100') {
      this.priceFilter = '100-300'
    } else if (this.priceFilter === '100-300') {
      this.priceFilter = '300-600'
    } else if (this.priceFilter === '300-600') {
      this.priceFilter = '600+'
    } else {
      this.priceFilter = 'all'
    }
    this.refreshRouteData()
  }

  private levelFilterLabel(): string {
    if (this.levelFilter === 'high') {
      return '等级：高等级'
    }
    if (this.levelFilter === 'normal') {
      return '等级：标准'
    }
    return '等级：全部'
  }

  private areaFilterLabel(): string {
    return this.areaFilter === 'all' ? '区域：全部' : `区域：${this.areaFilter}`
  }

  private priceFilterLabel(): string {
    return this.priceFilter === 'all' ? '价格：全部' : `价格：${this.priceFilter}`
  }

  private isStarHotel(item: HotelResponse): boolean {
    return item.star >= 4
  }

  private isBnbHotel(item: HotelResponse): boolean {
    return !this.isStarHotel(item)
  }

  private visibleHotels(): HotelResponse[] {
    if (this.hotelStayFilter === 'star') {
      return this.hotels.filter((item: HotelResponse) => this.isStarHotel(item))
    }
    if (this.hotelStayFilter === 'bnb') {
      return this.hotels.filter((item: HotelResponse) => this.isBnbHotel(item))
    }
    return this.hotels
  }

  private recommendedHotels(): HotelResponse[] {
    const list: HotelResponse[] = [...this.visibleHotels()]
    list.sort((left: HotelResponse, right: HotelResponse) => {
      const rightScore: number = right.score + right.star * 0.15
      const leftScore: number = left.score + left.star * 0.15
      return rightScore - leftScore
    })
    return list.slice(0, 4)
  }

  private hasRecommendedHotels(): boolean {
    return this.recommendedHotels().length > 0
  }

  private hasVisibleHotels(): boolean {
    return this.visibleHotels().length > 0
  }

  private resolveHotelCover(item: HotelResponse, index: number): string {
    if (item.coverImageUrl !== undefined && item.coverImageUrl.length > 0) {
      return item.coverImageUrl
    }
    if (this.isBnbHotel(item)) {
      if (index % 2 === 0) {
        return 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=900&q=80'
      }
      return 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=900&q=80'
    }
    if (index % 2 === 0) {
      return 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=900&q=80'
    }
    return 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?auto=format&fit=crop&w=900&q=80'
  }

  private hotelBadge(item: HotelResponse): string {
    return this.isStarHotel(item) ? `${item.star}星级` : '乡村民宿'
  }

  private hotelCoverTone(item: HotelResponse, index: number): string {
    if (this.isBnbHotel(item)) {
      return index % 2 === 0 ? '#3A6B52' : '#5B7C5A'
    }
    return index % 2 === 0 ? '#405F8F' : '#6B4E8F'
  }

  private hotelCoverCaption(item: HotelResponse): string {
    return this.isStarHotel(item) ? '品质酒店' : '特色民宿'
  }

  @Builder
  private HotelCoverBlock(item: HotelResponse, index: number, width: number, height: number): void {
    Column({ space: 8 }) {
      Row() {
        Text(this.hotelBadge(item))
          .fontSize(10)
          .fontColor(Color.White)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('rgba(17,24,39,0.38)')
          .borderRadius(RADIUS_PILL)
      }
      .width('100%')

      Blank()

      Text(this.hotelCoverCaption(item))
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
    }
    .width(width)
    .height(height)
    .padding(12)
    .borderRadius(RADIUS_MD)
    .backgroundColor(this.hotelCoverTone(item, index))
    .alignItems(HorizontalAlign.Start)
  }

  private hotelTagOne(item: HotelResponse): string {
    return this.isStarHotel(item) ? '品质住宿' : '在地体验'
  }

  private hotelTagTwo(item: HotelResponse): string {
    if (item.hasBreakfast) {
      return '含早餐'
    }
    return this.isStarHotel(item) ? '高评分' : '民宿推荐'
  }

  private hotelLocationHint(item: HotelResponse): string {
    return `${item.address}（距景区景点500m）`
  }

  private hotelAvailabilityText(item: HotelResponse): string {
    const status: string = (item.availabilityStatus ?? 'AVAILABLE').toUpperCase()
    if (status === 'FULL') {
      return '房态：满房'
    }
    if (status === 'BUSY' || status === 'LIMITED') {
      return '房态：紧张'
    }
    return '房态：充足'
  }

  private hotelAvailabilityColor(item: HotelResponse): string {
    const status: string = (item.availabilityStatus ?? 'AVAILABLE').toUpperCase()
    if (status === 'FULL') {
      return THEME_TEXT_TERTIARY
    }
    if (status === 'BUSY' || status === 'LIMITED') {
      return THEME_WARNING
    }
    return THEME_SUCCESS
  }

  private hotelAvailabilityBg(item: HotelResponse): string {
    const status: string = (item.availabilityStatus ?? 'AVAILABLE').toUpperCase()
    if (status === 'FULL') {
      return '#EFF2F7'
    }
    if (status === 'BUSY' || status === 'LIMITED') {
      return '#FFF4E6'
    }
    return '#EAF8EF'
  }

  private hotelButtonText(item: HotelResponse): string {
    const status: string = (item.availabilityStatus ?? 'AVAILABLE').toUpperCase()
    return status === 'FULL' ? '已售罄' : '预订'
  }

  private hotelButtonBg(item: HotelResponse): string {
    const status: string = (item.availabilityStatus ?? 'AVAILABLE').toUpperCase()
    return status === 'FULL' ? '#EFF2F7' : THEME_PRIMARY
  }

  private hotelButtonColor(item: HotelResponse): string {
    const status: string = (item.availabilityStatus ?? 'AVAILABLE').toUpperCase()
    return status === 'FULL' ? THEME_TEXT_TERTIARY : '#FFFFFF'
  }

  private hotelButtonDisabled(item: HotelResponse): boolean {
    const status: string = (item.availabilityStatus ?? 'AVAILABLE').toUpperCase()
    return status === 'FULL'
  }

  @Builder
  private MainTabs(): void {
    Row({ space: 8 }) {
      Button('酒店景区线路')
        .layoutWeight(1)
        .height(38)
        .borderRadius(RADIUS_PILL)
        .fontColor(this.mainTab === 'routes' ? Color.White : THEME_TEXT_SECONDARY)
        .backgroundColor(this.mainTab === 'routes' ? THEME_PRIMARY : '#EEF3FA')
        .onClick(() => this.switchMainTab('routes'))
      Button('餐饮娱乐演出')
        .layoutWeight(1)
        .height(38)
        .borderRadius(RADIUS_PILL)
        .fontColor(this.mainTab === 'dining' ? Color.White : THEME_TEXT_SECONDARY)
        .backgroundColor(this.mainTab === 'dining' ? THEME_PRIMARY : '#EEF3FA')
        .onClick(() => this.switchMainTab('dining'))
    }
    .width('100%')
  }

  @Builder
  private FilterPanel(): void {
    Column({ space: 8 }) {
      this.MainTabs()

      if (this.mainTab === 'routes') {
        Row({ space: 8 }) {
          Button('全部')
            .height(34)
            .borderRadius(RADIUS_PILL)
            .fontColor(this.filter === 'all' ? Color.White : THEME_TEXT_SECONDARY)
            .backgroundColor(this.filter === 'all' ? THEME_PRIMARY : '#EEF3FA')
            .onClick(() => {
              this.filter = 'all'
            })
          Button('酒店')
            .height(34)
            .borderRadius(RADIUS_PILL)
            .fontColor(this.filter === 'hotel' ? Color.White : THEME_TEXT_SECONDARY)
            .backgroundColor(this.filter === 'hotel' ? THEME_PRIMARY : '#EEF3FA')
            .onClick(() => {
              this.filter = 'hotel'
            })
          Button('景区')
            .height(34)
            .borderRadius(RADIUS_PILL)
            .fontColor(this.filter === 'scenic' ? Color.White : THEME_TEXT_SECONDARY)
            .backgroundColor(this.filter === 'scenic' ? THEME_PRIMARY : '#EEF3FA')
            .onClick(() => {
              this.filter = 'scenic'
            })
          Button('线路')
            .height(34)
            .borderRadius(RADIUS_PILL)
            .fontColor(this.filter === 'route' ? Color.White : THEME_TEXT_SECONDARY)
            .backgroundColor(this.filter === 'route' ? THEME_PRIMARY : '#EEF3FA')
            .onClick(() => {
              this.filter = 'route'
            })
        }
        .width('100%')

        if (this.filter === 'all' || this.filter === 'hotel') {
          Row({ space: 6 }) {
            this.HotelStayChip('全部', 'all')
            this.HotelStayChip('星级', 'star')
            this.HotelStayChip('民宿', 'bnb')
          }
          .width('100%')
          .padding(4)
          .backgroundColor('#EEF3FA')
          .borderRadius(RADIUS_PILL)
        }

        Row({ space: 8 }) {
          Button(this.levelFilterLabel())
            .height(34)
            .layoutWeight(1)
            .borderRadius(RADIUS_PILL)
            .backgroundColor('#EEF3FA')
            .fontColor(THEME_TEXT_SECONDARY)
            .fontSize(12)
            .onClick(() => this.cycleLevelFilter())

          Button(this.areaFilterLabel())
            .height(34)
            .layoutWeight(1)
            .borderRadius(RADIUS_PILL)
            .backgroundColor('#EEF3FA')
            .fontColor(THEME_TEXT_SECONDARY)
            .fontSize(12)
            .onClick(() => this.cycleAreaFilter())
        }
        .width('100%')

        Row({ space: 8 }) {
          Button(this.priceFilterLabel())
            .height(34)
            .layoutWeight(1)
            .borderRadius(RADIUS_PILL)
            .backgroundColor('#EEF3FA')
            .fontColor(THEME_TEXT_SECONDARY)
            .fontSize(12)
            .onClick(() => this.cyclePriceFilter())

          Button('刷新结果')
            .height(34)
            .layoutWeight(1)
            .borderRadius(RADIUS_PILL)
            .backgroundColor(THEME_PRIMARY)
            .fontColor(Color.White)
            .fontSize(12)
            .onClick(() => this.refreshRouteData())
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_MD)
  }

  @Builder
  private HotelStayChip(label: string, value: HotelStayFilter): void {
    Button(label)
      .layoutWeight(1)
      .height(32)
      .borderRadius(RADIUS_PILL)
      .backgroundColor(this.hotelStayFilter === value ? THEME_SURFACE : Color.Transparent)
      .fontColor(this.hotelStayFilter === value ? THEME_PRIMARY : THEME_TEXT_SECONDARY)
      .fontSize(13)
      .fontWeight(this.hotelStayFilter === value ? FontWeight.Medium : FontWeight.Regular)
      .onClick(() => {
        this.hotelStayFilter = value
      })
  }

  @Builder
  private HotelPromoSection(): void {
    if (this.hasRecommendedHotels()) {
      Column({ space: 10 }) {
        Row() {
          Text('官方导流特惠推荐')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(THEME_TEXT_PRIMARY)
          Blank()
          Text('优先推荐高评分房源')
            .fontSize(11)
            .fontColor(THEME_TEXT_TERTIARY)
        }
        .width('100%')

        Scroll() {
          Row({ space: 12 }) {
            ForEach(this.recommendedHotels(), (item: HotelResponse, index: number) => {
              this.HotelPromoCard(item, index)
            }, (item: HotelResponse) => item.id)
          }
          .padding({ right: 12 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
      }
      .width('100%')
    }
  }

  @Builder
  private HotelPromoCard(item: HotelResponse, index: number): void {
    Column({ space: 10 }) {
      this.HotelCoverBlock(item, index, 170, 128)

      Column({ space: 6 }) {
        Text(item.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(THEME_TEXT_PRIMARY)
          .maxLines(1)
        Row({ space: 8 }) {
          Text(`★ ${item.score}`)
            .fontSize(12)
            .fontColor('#FF8A1F')
          Text(`¥${item.price}/晚起`)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor(THEME_PRIMARY)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .width(170)
    .padding(12)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_MD)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private HotelSection(): void {
    if (!this.hasVisibleHotels()) {
      Text('暂无酒店数据')
        .fontSize(12)
        .fontColor(THEME_TEXT_SECONDARY)
        .width('100%')
        .padding(12)
        .backgroundColor(THEME_SURFACE)
        .borderRadius(RADIUS_MD)
    } else {
      Column({ space: 12 }) {
        this.HotelPromoSection()

        Column({ space: 10 }) {
          Text('全部房源')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(THEME_TEXT_PRIMARY)
          ForEach(this.visibleHotels(), (item: HotelResponse, index: number) => {
            this.HotelStayCard(item, index)
          }, (item: HotelResponse) => item.id)
        }
        .width('100%')
      }
      .width('100%')
    }
  }

  @Builder
  private HotelStayCard(item: HotelResponse, index: number): void {
    Row({ space: 14 }) {
      this.HotelCoverBlock(item, index, 108, 108)

      Column({ space: 8 }) {
        Row() {
          Text(item.name)
            .layoutWeight(1)
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor(THEME_TEXT_PRIMARY)
            .maxLines(1)
          Text(`¥${item.price}`)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(THEME_TEXT_PRIMARY)
        }
        .width('100%')

        Row({ space: 8 }) {
          Text(`★ ${item.score}`)
            .fontSize(12)
            .fontColor('#FF8A1F')
          Text(this.hotelTagOne(item))
            .fontSize(11)
            .fontColor('#5B8FF9')
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .backgroundColor('#EAF2FF')
            .borderRadius(RADIUS_PILL)
          Text(this.hotelTagTwo(item))
            .fontSize(11)
            .fontColor('#9D65F9')
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .backgroundColor('#F3EAFF')
            .borderRadius(RADIUS_PILL)
        }
        .width('100%')

        Text(this.hotelLocationHint(item))
          .fontSize(12)
          .fontColor(THEME_TEXT_SECONDARY)
          .maxLines(1)

        Row() {
          Text(this.hotelAvailabilityText(item))
            .fontSize(12)
            .fontColor(this.hotelAvailabilityColor(item))
            .padding({ left: 12, right: 12, top: 5, bottom: 5 })
            .backgroundColor(this.hotelAvailabilityBg(item))
            .borderRadius(RADIUS_PILL)
          Blank()
          Button(this.hotelButtonText(item))
            .enabled(!this.hotelButtonDisabled(item))
            .height(34)
            .padding({ left: 14, right: 14 })
            .borderRadius(RADIUS_PILL)
            .backgroundColor(this.hotelButtonBg(item))
            .fontColor(this.hotelButtonColor(item))
            .fontSize(13)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_MD)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private ScenicSection(): void {
    if (this.scenicList.length === 0) {
      Text('暂无景区数据')
        .fontSize(12)
        .fontColor(THEME_TEXT_SECONDARY)
        .width('100%')
        .padding(12)
        .backgroundColor(THEME_SURFACE)
        .borderRadius(RADIUS_MD)
    } else {
      ForEach(this.scenicList, (item: ScenicSpotResponse) => {
        Column({ space: 6 }) {
          Text(item.name)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(THEME_TEXT_PRIMARY)
          Text(`${item.level} · 门票 ¥${item.ticketPrice}`)
            .fontSize(12)
            .fontColor(THEME_TEXT_SECONDARY)
          Text(item.location)
            .fontSize(11)
            .fontColor(THEME_TEXT_TERTIARY)
            .maxLines(1)
        }
        .width('100%')
        .padding(12)
        .backgroundColor(THEME_SURFACE)
        .borderRadius(RADIUS_MD)
      }, (item: ScenicSpotResponse) => item.id)
    }
  }

  @Builder
  private RouteSection(): void {
    if (this.routes.length === 0) {
      Text('暂无线路数据')
        .fontSize(12)
        .fontColor(THEME_TEXT_SECONDARY)
        .width('100%')
        .padding(12)
        .backgroundColor(THEME_SURFACE)
        .borderRadius(RADIUS_MD)
    } else {
      ForEach(this.routes, (item: TravelRouteResponse) => {
        Column({ space: 6 }) {
          Text(item.name)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(THEME_TEXT_PRIMARY)
          Text(`时长 ${item.durationHours} 小时 · 难度 ${item.difficulty}`)
            .fontSize(12)
            .fontColor(THEME_TEXT_SECONDARY)
          Text(`适合：${item.suitableFor}`)
            .fontSize(11)
            .fontColor(THEME_TEXT_TERTIARY)
            .maxLines(1)
        }
        .width('100%')
        .padding(12)
        .backgroundColor(THEME_SURFACE)
        .borderRadius(RADIUS_MD)
      }, (item: TravelRouteResponse) => item.id)
    }
  }

  @Builder
  private RouteModeContent(): void {
    if (this.loading && !this.hasVisibleRouteContent()) {
      Text('正在加载服务数据...')
        .fontSize(12)
        .fontColor(THEME_TEXT_SECONDARY)
        .width('100%')
        .padding(12)
        .backgroundColor(THEME_SURFACE)
        .borderRadius(RADIUS_MD)
    } else if (this.errorMessage.length > 0) {
      Column({ space: 8 }) {
        Text(this.errorMessage)
          .fontSize(12)
          .fontColor(THEME_DANGER)
        Button('重试')
          .height(34)
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_PRIMARY)
          .fontColor(Color.White)
          .onClick(() => this.loadRouteData())
      }
      .width('100%')
      .padding(12)
      .backgroundColor(THEME_SURFACE)
      .borderRadius(RADIUS_MD)
      .alignItems(HorizontalAlign.Start)
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
        this.FilterPanel()
        Column() {
          DiningShowPage({ embedded: true })
        }
        .layoutWeight(1)
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .opacity(this.contentOpacity)
        .translate({ x: 0, y: this.contentOffsetY })
      }
      .height('100%')
      .width('100%')
      .padding({ left: 12, right: 12, top: 12, bottom: 0 })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .backgroundColor(THEME_PAGE_BG)
    } else {
      Column({ space: 12 }) {
        this.FilterPanel()
        Scroll() {
          Column({ space: 12 }) {
            this.RouteModeContent()
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)
        .opacity(this.contentOpacity)
        .translate({ x: 0, y: this.contentOffsetY })
      }
      .height('100%')
      .width('100%')
      .padding({ left: 12, right: 12, top: 12, bottom: 98 })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .backgroundColor(THEME_PAGE_BG)
    }
  }
}
