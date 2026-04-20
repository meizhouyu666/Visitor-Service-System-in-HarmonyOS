import { DiningResponse, EntertainmentResponse, PerformanceResponse } from '../../common/model/ApiModels'
import { apiClient } from '../../common/network/ApiClient'
import {
  RADIUS_MD,
  RADIUS_PILL,
  THEME_DANGER,
  THEME_PAGE_BG,
  THEME_PRIMARY,
  THEME_SUCCESS,
  THEME_SURFACE,
  THEME_SURFACE_MUTED,
  THEME_TEXT_PRIMARY,
  THEME_TEXT_SECONDARY,
  THEME_WARNING
} from '../../common/ui/AppTheme'

type DiningCategory = 'food' | 'fun' | 'show'
type AreaFilter = 'all' | '古城' | '滨江' | '景区'
type PriceFilter = 'all' | '0-100' | '100-300' | '300+'

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
export struct DiningShowPage {
  @Prop embedded: boolean = false

  @State private category: DiningCategory = 'food'
  @State private areaFilter: AreaFilter = 'all'
  @State private priceFilter: PriceFilter = 'all'

  @State private diningList: DiningResponse[] = []
  @State private entertainmentList: EntertainmentResponse[] = []
  @State private performanceList: PerformanceResponse[] = []

  @State private loading: boolean = false
  @State private errorMessage: string = ''
  @State private actionMessage: string = ''

  async aboutToAppear(): Promise<void> {
    await this.loadAll()
  }

  private categoryLabel(item: DiningCategory): string {
    if (item === 'food') {
      return '特色美食'
    }
    if (item === 'fun') {
      return '休闲娱乐'
    }
    return '文艺演出'
  }

  private parsePriceFilter(): PriceRangeModel {
    if (this.priceFilter === '0-100') {
      return new PriceRangeModel(0, 100)
    }
    if (this.priceFilter === '100-300') {
      return new PriceRangeModel(100, 300)
    }
    if (this.priceFilter === '300+') {
      return new PriceRangeModel(300, undefined)
    }
    return new PriceRangeModel(undefined, undefined)
  }

  private currentArea(): string {
    if (this.areaFilter === 'all') {
      return ''
    }
    return this.areaFilter
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

  private async loadAll(): Promise<void> {
    this.loading = true
    this.errorMessage = ''
    try {
      const range: PriceRangeModel = this.parsePriceFilter()
      const area: string = this.currentArea()
      const diningPath: string = `/api/query/dining${this.buildQuery([
        new QueryParam('area', area),
        new QueryParam('minPrice', range.minPrice),
        new QueryParam('maxPrice', range.maxPrice),
        new QueryParam('sortBy', 'distance_asc'),
        new QueryParam('limit', 20)
      ])}`
      const entertainmentPath: string = `/api/query/entertainment${this.buildQuery([
        new QueryParam('area', area),
        new QueryParam('minPrice', range.minPrice),
        new QueryParam('maxPrice', range.maxPrice),
        new QueryParam('sortBy', 'distance_asc'),
        new QueryParam('limit', 20)
      ])}`
      const performancePath: string = `/api/query/performances${this.buildQuery([
        new QueryParam('area', area),
        new QueryParam('minPrice', range.minPrice),
        new QueryParam('maxPrice', range.maxPrice),
        new QueryParam('sortBy', 'time_asc'),
        new QueryParam('limit', 20)
      ])}`

      const dining: DiningResponse[] = await apiClient.get<DiningResponse[]>(diningPath)
      const entertainment: EntertainmentResponse[] = await apiClient.get<EntertainmentResponse[]>(entertainmentPath)
      const performances: PerformanceResponse[] = await apiClient.get<PerformanceResponse[]>(performancePath)

      this.diningList = [...dining]
      this.entertainmentList = [...entertainment]
      this.performanceList = [...performances]
    } catch (_error) {
      this.errorMessage = '加载餐饮娱乐演出数据失败'
    } finally {
      this.loading = false
    }
  }

  private isOpenLabel(isOpen: boolean | undefined): string {
    return isOpen === false ? '暂未营业' : '正在营业'
  }

  private isOpenColor(isOpen: boolean | undefined): string {
    return isOpen === false ? THEME_WARNING : THEME_SUCCESS
  }

  private distanceText(distanceMeters: number | undefined): string {
    if (distanceMeters === undefined || distanceMeters <= 0) {
      return '距离未知'
    }
    if (distanceMeters >= 1000) {
      const km: number = Math.round((distanceMeters / 1000) * 10) / 10
      return `距离 ${km}km`
    }
    return `距离 ${distanceMeters}m`
  }

  private ticketLabel(status: string | undefined, remaining: number | undefined): string {
    if (status === 'SOLD_OUT') {
      return '已售罄'
    }
    if (status === 'LOW_STOCK') {
      return `余票紧张(${remaining ?? 0})`
    }
    return `有票(${remaining ?? 0})`
  }

  private ticketColor(status: string | undefined): string {
    if (status === 'SOLD_OUT') {
      return THEME_DANGER
    }
    if (status === 'LOW_STOCK') {
      return THEME_WARNING
    }
    return THEME_SUCCESS
  }

  private performanceTime(showDateTime: string | undefined, showTime: string): string {
    if (showDateTime === undefined || showDateTime.length === 0) {
      return showTime
    }
    return showDateTime
  }

  private hintNavigation(place: string): void {
    this.actionMessage = `请在地图中导航到：${place}`
  }

  private hintBooking(name: string): void {
    this.actionMessage = `已触发“${name}”预订引导，请继续完成下单`
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
    this.loadAll()
  }

  private cyclePriceFilter(): void {
    if (this.priceFilter === 'all') {
      this.priceFilter = '0-100'
    } else if (this.priceFilter === '0-100') {
      this.priceFilter = '100-300'
    } else if (this.priceFilter === '100-300') {
      this.priceFilter = '300+'
    } else {
      this.priceFilter = 'all'
    }
    this.loadAll()
  }

  @Builder
  private Header(): void {
    Column({ space: 10 }) {
      if (!this.embedded) {
        Row({ space: 8 }) {
          Text('餐饮娱乐与演出')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor(THEME_TEXT_PRIMARY)
          Blank()
          Button('刷新')
            .onClick(() => this.loadAll())
            .backgroundColor(THEME_PRIMARY)
            .fontColor(Color.White)
            .borderRadius(RADIUS_MD)
        }
        .width('100%')
      }

      Row({ space: 8 }) {
        Button(this.category === 'food' ? '美食' : '美食')
          .height(34)
          .borderRadius(RADIUS_PILL)
          .fontColor(this.category === 'food' ? Color.White : THEME_TEXT_SECONDARY)
          .backgroundColor(this.category === 'food' ? THEME_PRIMARY : '#EEF3FA')
          .onClick(() => {
            this.category = 'food'
          })
        Button('娱乐')
          .height(34)
          .borderRadius(RADIUS_PILL)
          .fontColor(this.category === 'fun' ? Color.White : THEME_TEXT_SECONDARY)
          .backgroundColor(this.category === 'fun' ? THEME_PRIMARY : '#EEF3FA')
          .onClick(() => {
            this.category = 'fun'
          })
        Button('演出')
          .height(34)
          .borderRadius(RADIUS_PILL)
          .fontColor(this.category === 'show' ? Color.White : THEME_TEXT_SECONDARY)
          .backgroundColor(this.category === 'show' ? THEME_PRIMARY : '#EEF3FA')
          .onClick(() => {
            this.category = 'show'
          })
      }
      .width('100%')

      Row({ space: 8 }) {
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
        Button('应用')
          .height(34)
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_PRIMARY)
          .fontColor(Color.White)
          .onClick(() => this.loadAll())
      }
      .width('100%')
    }
    .width('100%')
    .padding(12)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_MD)
  }

  @Builder
  private DiningList(): void {
    if (this.diningList.length === 0) {
      Text('暂无餐饮数据')
        .fontSize(12)
        .fontColor(THEME_TEXT_SECONDARY)
        .width('100%')
        .padding(12)
        .backgroundColor(THEME_SURFACE)
        .borderRadius(RADIUS_MD)
    } else {
      ForEach(this.diningList, (item: DiningResponse) => {
        Column({ space: 8 }) {
          Row({ space: 8 }) {
            Text(item.name)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(THEME_TEXT_PRIMARY)
              .layoutWeight(1)
            Text(this.isOpenLabel(item.isOpen))
              .fontSize(11)
              .fontColor(this.isOpenColor(item.isOpen))
          }
          .width('100%')

          Text(`${item.type} · 人均 ¥${item.avgPrice}`)
            .fontSize(12)
            .fontColor(THEME_TEXT_SECONDARY)
          Text(item.recommendFood)
            .fontSize(11)
            .fontColor(THEME_TEXT_SECONDARY)
            .maxLines(1)
          Text(this.distanceText(item.distanceMeters))
            .fontSize(11)
            .fontColor(THEME_PRIMARY)

          Row({ space: 8 }) {
            Button('导航')
              .height(34)
              .borderRadius(RADIUS_PILL)
              .backgroundColor(THEME_PRIMARY)
              .fontColor(Color.White)
              .onClick(() => this.hintNavigation(item.address))
            Blank()
          }
          .width('100%')
        }
        .width('100%')
        .padding(12)
        .backgroundColor(THEME_SURFACE)
        .borderRadius(RADIUS_MD)
      }, (item: DiningResponse) => item.id)
    }
  }

  @Builder
  private EntertainmentList(): void {
    if (this.entertainmentList.length === 0) {
      Text('暂无娱乐数据')
        .fontSize(12)
        .fontColor(THEME_TEXT_SECONDARY)
        .width('100%')
        .padding(12)
        .backgroundColor(THEME_SURFACE)
        .borderRadius(RADIUS_MD)
    } else {
      ForEach(this.entertainmentList, (item: EntertainmentResponse) => {
        Column({ space: 8 }) {
          Row({ space: 8 }) {
            Text(item.name)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(THEME_TEXT_PRIMARY)
              .layoutWeight(1)
            Text(this.isOpenLabel(item.isOpen))
              .fontSize(11)
              .fontColor(this.isOpenColor(item.isOpen))
          }
          .width('100%')

          Text(`${item.type} · 参考价 ¥${item.price}`)
            .fontSize(12)
            .fontColor(THEME_TEXT_SECONDARY)
          Text(item.description)
            .fontSize(11)
            .fontColor(THEME_TEXT_SECONDARY)
            .maxLines(2)
          Text(this.distanceText(item.distanceMeters))
            .fontSize(11)
            .fontColor(THEME_PRIMARY)

          Row({ space: 8 }) {
            Button('导航')
              .height(34)
              .borderRadius(RADIUS_PILL)
              .backgroundColor(THEME_PRIMARY)
              .fontColor(Color.White)
              .onClick(() => this.hintNavigation(item.location))
            Blank()
          }
          .width('100%')
        }
        .width('100%')
        .padding(12)
        .backgroundColor(THEME_SURFACE)
        .borderRadius(RADIUS_MD)
      }, (item: EntertainmentResponse) => item.id)
    }
  }

  @Builder
  private PerformanceList(): void {
    if (this.performanceList.length === 0) {
      Text('暂无演出数据')
        .fontSize(12)
        .fontColor(THEME_TEXT_SECONDARY)
        .width('100%')
        .padding(12)
        .backgroundColor(THEME_SURFACE)
        .borderRadius(RADIUS_MD)
    } else {
      ForEach(this.performanceList, (item: PerformanceResponse) => {
        Row({ space: 10 }) {
          Column({ space: 4 }) {
            Text(item.name)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(THEME_TEXT_PRIMARY)
            Text(this.performanceTime(item.showDateTime, item.showTime))
              .fontSize(12)
              .fontColor(THEME_TEXT_SECONDARY)
            Text(`票务：${this.ticketLabel(item.ticketStatus, item.remainingTickets)}`)
              .fontSize(11)
              .fontColor(this.ticketColor(item.ticketStatus))
            Text(this.distanceText(item.distanceMeters))
              .fontSize(11)
              .fontColor(THEME_PRIMARY)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Button('预订')
            .height(34)
            .borderRadius(RADIUS_PILL)
            .backgroundColor(THEME_PRIMARY)
            .fontColor(Color.White)
            .onClick(() => this.hintBooking(item.name))
        }
        .width('100%')
        .padding(12)
        .backgroundColor(THEME_SURFACE)
        .borderRadius(RADIUS_MD)
        .alignItems(VerticalAlign.Top)
      }, (item: PerformanceResponse) => item.id)
    }
  }

  @Builder
  private CategoryContent(): void {
    if (this.loading) {
      Text('数据加载中...')
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
          .onClick(() => this.loadAll())
      }
      .width('100%')
      .padding(12)
      .backgroundColor(THEME_SURFACE)
      .borderRadius(RADIUS_MD)
      .alignItems(HorizontalAlign.Start)
    } else if (this.category === 'food') {
      this.DiningList()
    } else if (this.category === 'fun') {
      this.EntertainmentList()
    } else {
      this.PerformanceList()
    }
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        this.Header()

        Text(this.categoryLabel(this.category))
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(THEME_TEXT_PRIMARY)
          .padding({ left: 4 })

        this.CategoryContent()

        if (this.actionMessage.length > 0) {
          Text(this.actionMessage)
            .fontSize(12)
            .fontColor(THEME_TEXT_SECONDARY)
            .padding(10)
            .width('100%')
            .backgroundColor(THEME_SURFACE_MUTED)
            .borderRadius(RADIUS_MD)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .padding(this.embedded ? { left: 0, right: 0, top: 0, bottom: 80 } : { left: 12, right: 12, top: 12, bottom: 20 })
      .width('100%')
    }
    .height('100%')
    .backgroundColor(this.embedded ? Color.Transparent : THEME_PAGE_BG)
  }
}
