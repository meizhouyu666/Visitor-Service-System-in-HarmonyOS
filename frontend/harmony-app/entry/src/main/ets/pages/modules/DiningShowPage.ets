import { DiningResponse, EntertainmentResponse, PerformanceResponse } from '../../common/model/ApiModels'
import { apiClient } from '../../common/network/ApiClient'
import {
  RADIUS_MD,
  RADIUS_PILL,
  THEME_DANGER,
  THEME_PAGE_BG,
  THEME_PRIMARY,
  THEME_SUCCESS,
  THEME_SURFACE_MUTED,
  THEME_TEXT_PRIMARY,
  THEME_TEXT_SECONDARY,
  THEME_TEXT_TERTIARY,
  THEME_WARNING
} from '../../common/ui/AppTheme'
import { EmptyStateCard, FilterChip, FloatingCard, SectionHeader, StatusBadge } from '../../common/ui/UiKit'

type DiningCategory = 'food' | 'fun' | 'show'
type AreaFilter = 'all' | '古城' | '滨江' | '景区'
type PriceFilter = 'all' | '0-100' | '100-300' | '300+'

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

  private parsePriceFilter(): { minPrice: number | undefined; maxPrice: number | undefined } {
    if (this.priceFilter === '0-100') {
      return { minPrice: 0, maxPrice: 100 }
    }
    if (this.priceFilter === '100-300') {
      return { minPrice: 100, maxPrice: 300 }
    }
    if (this.priceFilter === '300+') {
      return { minPrice: 300, maxPrice: undefined }
    }
    return { minPrice: undefined, maxPrice: undefined }
  }

  private currentArea(): string {
    if (this.areaFilter === 'all') {
      return ''
    }
    return this.areaFilter
  }

  private buildQuery(params: Record<string, string | number | undefined>): string {
    const pairs: string[] = []
    Object.keys(params).forEach((key: string) => {
      const value: string | number | undefined = params[key]
      if (value !== undefined && `${value}`.trim().length > 0) {
        pairs.push(`${key}=${encodeURIComponent(`${value}`)}`)
      }
    })
    return pairs.length > 0 ? `?${pairs.join('&')}` : ''
  }

  private async loadAll(): Promise<void> {
    this.loading = true
    this.errorMessage = ''
    try {
      const range: { minPrice: number | undefined; maxPrice: number | undefined } = this.parsePriceFilter()
      const area: string = this.currentArea()
      const diningPath: string = `/api/query/dining${this.buildQuery({
        area,
        minPrice: range.minPrice,
        maxPrice: range.maxPrice,
        sortBy: 'distance_asc',
        limit: 20
      })}`
      const entertainmentPath: string = `/api/query/entertainment${this.buildQuery({
        area,
        minPrice: range.minPrice,
        maxPrice: range.maxPrice,
        sortBy: 'distance_asc',
        limit: 20
      })}`
      const performancePath: string = `/api/query/performances${this.buildQuery({
        area,
        minPrice: range.minPrice,
        maxPrice: range.maxPrice,
        sortBy: 'time_asc',
        limit: 20
      })}`

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

  private isOpenTone(isOpen: boolean | undefined): 'success' | 'warning' {
    return isOpen === false ? 'warning' : 'success'
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

  private ticketTone(status: string | undefined): 'danger' | 'warning' | 'success' {
    if (status === 'SOLD_OUT') {
      return 'danger'
    }
    if (status === 'LOW_STOCK') {
      return 'warning'
    }
    return 'success'
  }

  private performanceDateText(showDateTime: string | undefined, showTime: string): string {
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

  @Builder
  private Header(): void {
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

    FloatingCard() {
      Column({ space: 10 }) {
        SectionHeader({ title: '分类导航', subtitle: '支持美食 / 娱乐 / 演出快速切换' })
        Row({ space: 8 }) {
          FilterChip({
            label: '特色美食',
            selected: this.category === 'food',
            onToggle: () => {
              this.category = 'food'
            }
          })
          FilterChip({
            label: '休闲娱乐',
            selected: this.category === 'fun',
            onToggle: () => {
              this.category = 'fun'
            }
          })
          FilterChip({
            label: '文艺演出',
            selected: this.category === 'show',
            onToggle: () => {
              this.category = 'show'
            }
          })
        }
        .width('100%')

        Row({ space: 8 }) {
          FilterChip({
            label: this.areaFilter === 'all' ? '区域: 全部' : `区域: ${this.areaFilter}`,
            selected: this.areaFilter !== 'all',
            onToggle: () => {
              this.areaFilter = this.areaFilter === 'all' ? '古城' : this.areaFilter === '古城' ? '滨江' : this.areaFilter === '滨江' ? '景区' : 'all'
              this.loadAll()
            }
          })
          FilterChip({
            label: this.priceFilter === 'all' ? '价格: 全部' : `价格: ${this.priceFilter}`,
            selected: this.priceFilter !== 'all',
            onToggle: () => {
              this.priceFilter = this.priceFilter === 'all' ? '0-100' : this.priceFilter === '0-100' ? '100-300' : this.priceFilter === '100-300' ? '300+' : 'all'
              this.loadAll()
            }
          })
          Blank()
          Button('应用')
            .onClick(() => this.loadAll())
            .height(34)
            .borderRadius(RADIUS_PILL)
            .backgroundColor(THEME_PRIMARY)
            .fontColor(Color.White)
        }
        .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  private DiningList(): void {
    if (this.diningList.length === 0) {
      EmptyStateCard({ message: '暂无餐饮数据' })
      return
    }
    ForEach(this.diningList, (item: DiningResponse) => {
      FloatingCard() {
        Column({ space: 8 }) {
          Row({ space: 10 }) {
            if (item.logoUrl !== undefined && item.logoUrl.length > 0) {
              Image(item.logoUrl)
                .width(48)
                .height(48)
                .objectFit(ImageFit.Cover)
                .borderRadius(RADIUS_PILL)
            } else {
              Text('🍜')
                .fontSize(20)
                .width(48)
                .height(48)
                .textAlign(TextAlign.Center)
                .lineHeight(48)
                .backgroundColor('#EAF2FF')
                .borderRadius(RADIUS_PILL)
            }
            Column({ space: 4 }) {
              Text(item.name)
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor(THEME_TEXT_PRIMARY)
              Text(`${item.type} · 人均 ¥${item.avgPrice}`)
                .fontSize(12)
                .fontColor(THEME_TEXT_SECONDARY)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            StatusBadge({ label: this.isOpenLabel(item.isOpen), tone: this.isOpenTone(item.isOpen) })
          }
          .width('100%')

          Text(`营业时间：${item.businessHours}`)
            .fontSize(12)
            .fontColor(THEME_TEXT_SECONDARY)
          Text(`推荐菜：${item.recommendFood}`)
            .fontSize(11)
            .fontColor(THEME_TEXT_SECONDARY)
            .maxLines(1)
          Text(item.detailDesc)
            .fontSize(11)
            .fontColor(THEME_TEXT_TERTIARY)
            .maxLines(2)

          Row({ space: 8 }) {
            Button('一键导航')
              .onClick(() => this.hintNavigation(item.address))
              .height(34)
              .borderRadius(RADIUS_PILL)
              .backgroundColor(THEME_PRIMARY)
              .fontColor(Color.White)
            Blank()
            Text(`📍 ${this.distanceText(item.distanceMeters)}`)
              .fontSize(11)
              .fontColor(THEME_PRIMARY)
          }
          .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
    }, (item: DiningResponse) => item.id)
  }

  @Builder
  private EntertainmentList(): void {
    if (this.entertainmentList.length === 0) {
      EmptyStateCard({ message: '暂无娱乐数据' })
      return
    }
    ForEach(this.entertainmentList, (item: EntertainmentResponse) => {
      FloatingCard() {
        Column({ space: 8 }) {
          Row({ space: 10 }) {
            if (item.logoUrl !== undefined && item.logoUrl.length > 0) {
              Image(item.logoUrl)
                .width(48)
                .height(48)
                .objectFit(ImageFit.Cover)
                .borderRadius(RADIUS_PILL)
            } else {
              Text('🎭')
                .fontSize(20)
                .width(48)
                .height(48)
                .textAlign(TextAlign.Center)
                .lineHeight(48)
                .backgroundColor('#EAF2FF')
                .borderRadius(RADIUS_PILL)
            }
            Column({ space: 4 }) {
              Text(item.name)
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor(THEME_TEXT_PRIMARY)
              Text(`${item.type} · ¥${item.price}`)
                .fontSize(12)
                .fontColor(THEME_TEXT_SECONDARY)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            StatusBadge({ label: this.isOpenLabel(item.isOpen), tone: this.isOpenTone(item.isOpen) })
          }
          .width('100%')

          Text(`营业时间：${item.openTime}`)
            .fontSize(12)
            .fontColor(THEME_TEXT_SECONDARY)
          Text(item.description)
            .fontSize(11)
            .fontColor(THEME_TEXT_TERTIARY)
            .maxLines(2)

          Row({ space: 8 }) {
            Button('一键导航')
              .onClick(() => this.hintNavigation(item.location))
              .height(34)
              .borderRadius(RADIUS_PILL)
              .backgroundColor(THEME_PRIMARY)
              .fontColor(Color.White)
            Blank()
            Text(`📍 ${this.distanceText(item.distanceMeters)}`)
              .fontSize(11)
              .fontColor(THEME_PRIMARY)
          }
          .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
    }, (item: EntertainmentResponse) => item.id)
  }

  @Builder
  private PerformanceList(): void {
    if (this.performanceList.length === 0) {
      EmptyStateCard({ message: '暂无演出数据' })
      return
    }
    ForEach(this.performanceList, (item: PerformanceResponse) => {
      FloatingCard() {
        Row({ space: 10 }) {
          Column({ space: 2 }) {
            Text('演出日历')
              .fontSize(10)
              .fontColor(THEME_TEXT_TERTIARY)
            Text(this.performanceDateText(item.showDateTime, item.showTime))
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor(THEME_PRIMARY)
              .maxLines(2)
          }
          .width(90)
          .padding(8)
          .backgroundColor('#EEF4FF')
          .borderRadius(RADIUS_MD)

          Column({ space: 6 }) {
            Row({ space: 8 }) {
              Text(item.name)
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor(THEME_TEXT_PRIMARY)
                .layoutWeight(1)
              StatusBadge({
                label: this.ticketLabel(item.ticketStatus, item.remainingTickets),
                tone: this.ticketTone(item.ticketStatus)
              })
            }
            .width('100%')

            Text(`场馆：${item.venue ?? item.location}`)
              .fontSize(12)
              .fontColor(THEME_TEXT_SECONDARY)
            Text(`票价：¥${item.price} · 团体：${item.team}`)
              .fontSize(11)
              .fontColor(THEME_TEXT_SECONDARY)

            Row({ space: 8 }) {
              Button('预订引导')
                .onClick(() => this.hintBooking(item.name))
                .height(34)
                .borderRadius(RADIUS_PILL)
                .backgroundColor(THEME_PRIMARY)
                .fontColor(Color.White)
              Blank()
              Text(`📍 ${this.distanceText(item.distanceMeters)}`)
                .fontSize(11)
                .fontColor(THEME_PRIMARY)
            }
            .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
    }, (item: PerformanceResponse) => item.id)
  }

  @Builder
  private CategoryContent(): void {
    if (this.loading) {
      EmptyStateCard({ message: '数据加载中...' })
      return
    }
    if (this.errorMessage.length > 0) {
      FloatingCard() {
        Column({ space: 8 }) {
          Text(this.errorMessage).fontColor(THEME_DANGER).fontSize(12)
          Button('重试')
            .onClick(() => this.loadAll())
            .backgroundColor(THEME_PRIMARY)
            .fontColor(Color.White)
            .borderRadius(RADIUS_PILL)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      return
    }

    if (this.category === 'food') {
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

        FloatingCard() {
          SectionHeader({
            title: this.categoryLabel(this.category),
            subtitle: this.category === 'show' ? '演出日历与票务状态' : '支持营业状态、导航和距离提示'
          })
        }

        this.CategoryContent()

        if (this.actionMessage.length > 0) {
          Text(this.actionMessage)
            .fontSize(12)
            .fontColor(this.actionMessage.includes('预订') ? THEME_SUCCESS : THEME_WARNING)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
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
