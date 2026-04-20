import { HotelResponse, ScenicSpotResponse, TravelRouteResponse } from '../../common/model/ApiModels'
import { apiClient } from '../../common/network/ApiClient'
import {
  RADIUS_MD,
  RADIUS_PILL,
  THEME_DANGER,
  THEME_PAGE_BG,
  THEME_PRIMARY,
  THEME_SURFACE,
  THEME_TEXT_PRIMARY,
  THEME_TEXT_SECONDARY,
  THEME_TEXT_TERTIARY
} from '../../common/ui/AppTheme'
import { DiningShowPage } from './DiningShowPage'

export type VisitorServiceTab = 'routes' | 'dining'
type ServiceFilter = 'all' | 'hotel' | 'scenic' | 'route'
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

@Component
export struct VisitorServicesPage {
  @Link mainTab: VisitorServiceTab

  @State private filter: ServiceFilter = 'all'
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
    animateTo({ duration: 110, curve: Curve.EaseOut }, () => {
      this.contentOpacity = 0
      this.contentOffsetY = 10
    })
    setTimeout(() => {
      onSwitched()
      animateTo({ duration: 180, curve: Curve.EaseInOut }, () => {
        this.contentOpacity = 1
        this.contentOffsetY = 0
      })
      setTimeout(() => {
        this.contentSwitching = false
      }, 180)
    }, 110)
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

  private cycleLevelFilter(): void {
    if (this.levelFilter === 'all') {
      this.levelFilter = 'high'
    } else if (this.levelFilter === 'high') {
      this.levelFilter = 'normal'
    } else {
      this.levelFilter = 'all'
    }
    this.loadRouteData()
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
    this.loadRouteData()
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
    this.loadRouteData()
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

        Row({ space: 8 }) {
          Button(this.levelFilter === 'all' ? '等级：全部' : this.levelFilter === 'high' ? '等级：高等级' : '等级：标准')
            .height(34)
            .borderRadius(RADIUS_PILL)
            .backgroundColor('#EEF3FA')
            .fontColor(THEME_TEXT_SECONDARY)
            .onClick(() => this.cycleLevelFilter())

          Button(this.areaFilter === 'all' ? '区域：全部' : `区域：${this.areaFilter}`)
            .height(34)
            .borderRadius(RADIUS_PILL)
            .backgroundColor('#EEF3FA')
            .fontColor(THEME_TEXT_SECONDARY)
            .onClick(() => this.cycleAreaFilter())

          Button(this.priceFilter === 'all' ? '价格：全部' : `价格：${this.priceFilter}`)
            .height(34)
            .borderRadius(RADIUS_PILL)
            .backgroundColor('#EEF3FA')
            .fontColor(THEME_TEXT_SECONDARY)
            .onClick(() => this.cyclePriceFilter())

          Blank()
          Button('刷新')
            .height(34)
            .borderRadius(RADIUS_PILL)
            .backgroundColor(THEME_PRIMARY)
            .fontColor(Color.White)
            .onClick(() => this.loadRouteData())
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
  private HotelSection(): void {
    if (this.hotels.length === 0) {
      Text('暂无酒店数据')
        .fontSize(12)
        .fontColor(THEME_TEXT_SECONDARY)
        .width('100%')
        .padding(12)
        .backgroundColor(THEME_SURFACE)
        .borderRadius(RADIUS_MD)
    } else {
      ForEach(this.hotels, (item: HotelResponse) => {
        Column({ space: 6 }) {
          Text(item.name)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(THEME_TEXT_PRIMARY)
          Text(`${item.star}星 · 评分 ${item.score} · ¥${item.price} 起`)
            .fontSize(12)
            .fontColor(THEME_TEXT_SECONDARY)
          Text(item.address)
            .fontSize(11)
            .fontColor(THEME_TEXT_TERTIARY)
            .maxLines(1)
        }
        .width('100%')
        .padding(12)
        .backgroundColor(THEME_SURFACE)
        .borderRadius(RADIUS_MD)
      }, (item: HotelResponse) => item.id)
    }
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
    if (this.loading) {
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
      Scroll() {
        Column({ space: 12 }) {
          this.FilterPanel()
          Column() {
            DiningShowPage({ embedded: true })
          }
          .opacity(this.contentOpacity)
          .translate({ x: 0, y: this.contentOffsetY })
        }
        .padding({ left: 12, right: 12, top: 12, bottom: 0 })
        .width('100%')
      }
      .height('100%')
      .backgroundColor(THEME_PAGE_BG)
    } else {
      Scroll() {
        Column({ space: 12 }) {
          this.FilterPanel()
          Column() {
            this.RouteModeContent()
          }
          .opacity(this.contentOpacity)
          .translate({ x: 0, y: this.contentOffsetY })
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
