import { DiningResponse, EntertainmentResponse, PerformanceResponse } from '../../common/model/ApiModels'
import { apiClient } from '../../common/network/ApiClient'
import {
  RADIUS_LG,
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

type DiningCategory = 'recommend' | 'food' | 'fun' | 'show'
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

class QuickActionItem {
  id: string
  icon: string
  label: string
  targetCategory: DiningCategory

  constructor(id: string, icon: string, label: string, targetCategory: DiningCategory) {
    this.id = id
    this.icon = icon
    this.label = label
    this.targetCategory = targetCategory
  }
}

class ServiceCardModel {
  id: string
  title: string
  imageUrl: string
  ratingText: string
  priceText: string
  primaryTag: string
  secondaryTag: string
  locationText: string
  timeText: string
  statusText: string
  statusColor: string
  statusBg: string
  actionText: string
  actionBg: string
  actionColor: string
  actionDisabled: boolean
  caption: string
  orderHint: string

  constructor(
    id: string,
    title: string,
    imageUrl: string,
    ratingText: string,
    priceText: string,
    primaryTag: string,
    secondaryTag: string,
    locationText: string,
    timeText: string,
    statusText: string,
    statusColor: string,
    statusBg: string,
    actionText: string,
    actionBg: string,
    actionColor: string,
    actionDisabled: boolean,
    caption: string,
    orderHint: string
  ) {
    this.id = id
    this.title = title
    this.imageUrl = imageUrl
    this.ratingText = ratingText
    this.priceText = priceText
    this.primaryTag = primaryTag
    this.secondaryTag = secondaryTag
    this.locationText = locationText
    this.timeText = timeText
    this.statusText = statusText
    this.statusColor = statusColor
    this.statusBg = statusBg
    this.actionText = actionText
    this.actionBg = actionBg
    this.actionColor = actionColor
    this.actionDisabled = actionDisabled
    this.caption = caption
    this.orderHint = orderHint
  }
}

class PromoCardModel {
  id: string
  imageUrl: string
  badge: string
  title: string
  ratingText: string
  priceText: string

  constructor(id: string, imageUrl: string, badge: string, title: string, ratingText: string, priceText: string) {
    this.id = id
    this.imageUrl = imageUrl
    this.badge = badge
    this.title = title
    this.ratingText = ratingText
    this.priceText = priceText
  }
}

@Component
export struct DiningShowPage {
  @Prop embedded: boolean = false

  @State private category: DiningCategory = 'recommend'
  @State private areaFilter: AreaFilter = 'all'
  @State private priceFilter: PriceFilter = 'all'
  @State private searchKeyword: string = ''
  @State private filterPanelVisible: boolean = false

  @State private diningList: DiningResponse[] = []
  @State private entertainmentList: EntertainmentResponse[] = []
  @State private performanceList: PerformanceResponse[] = []

  @State private loading: boolean = false
  @State private errorMessage: string = ''
  @State private actionMessage: string = ''
  @State private contentOpacity: number = 1
  @State private contentOffsetY: number = 0
  @State private contentSwitching: boolean = false

  private readonly quickActions: QuickActionItem[] = [
    new QuickActionItem('tea', '☕', '下午茶', 'food'),
    new QuickActionItem('food', '✦', '地方名吃', 'food'),
    new QuickActionItem('show', '⌘', '演出日历', 'show'),
    new QuickActionItem('bar', '♪', '酒吧夜生活', 'fun')
  ]

  async aboutToAppear(): Promise<void> {
    await this.loadAll()
  }

  private runContentSwitch(onSwitched: () => void): void {
    if (this.contentSwitching) {
      onSwitched()
      return
    }
    this.contentSwitching = true
    this.contentOpacity = 0
    this.contentOffsetY = 8
    onSwitched()
    animateTo({ duration: 170, curve: Curve.EaseInOut }, () => {
      this.contentOpacity = 1
      this.contentOffsetY = 0
    })
    setTimeout(() => {
      this.contentSwitching = false
    }, 170)
  }

  private switchCategory(nextCategory: DiningCategory): void {
    if (this.category === nextCategory) {
      return
    }
    this.runContentSwitch(() => {
      this.category = nextCategory
      this.actionMessage = ''
    })
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
      this.errorMessage = '加载餐饮娱乐演出数据失败，请稍后重试'
    } finally {
      this.loading = false
    }
  }

  private containsKeyword(value: string): boolean {
    const keyword: string = this.searchKeyword.trim().toLowerCase()
    if (keyword.length === 0) {
      return true
    }
    return value.toLowerCase().includes(keyword)
  }

  private filterDining(item: DiningResponse): boolean {
    return this.containsKeyword(`${item.name} ${item.type} ${item.address} ${item.recommendFood} ${item.detailDesc}`)
  }

  private filterEntertainment(item: EntertainmentResponse): boolean {
    return this.containsKeyword(`${item.name} ${item.type} ${item.location} ${item.description}`)
  }

  private filterPerformance(item: PerformanceResponse): boolean {
    return this.containsKeyword(`${item.name} ${item.team} ${item.location} ${item.detail}`)
  }

  private visibleDiningList(): DiningResponse[] {
    return this.diningList.filter((item: DiningResponse) => this.filterDining(item))
  }

  private visibleEntertainmentList(): EntertainmentResponse[] {
    return this.entertainmentList.filter((item: EntertainmentResponse) => this.filterEntertainment(item))
  }

  private visiblePerformanceList(): PerformanceResponse[] {
    return this.performanceList.filter((item: PerformanceResponse) => this.filterPerformance(item))
  }

  private displayAreaLabel(): string {
    return this.areaFilter === 'all' ? '全部区域' : this.areaFilter
  }

  private displayPriceLabel(): string {
    if (this.priceFilter === '0-100') {
      return '¥0-100'
    }
    if (this.priceFilter === '100-300') {
      return '¥100-300'
    }
    if (this.priceFilter === '300+') {
      return '¥300+'
    }
    return '全部价位'
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

  private resetFilters(): void {
    this.areaFilter = 'all'
    this.priceFilter = 'all'
    this.searchKeyword = ''
    this.loadAll()
  }

  private isOpenLabel(isOpen: boolean | undefined): string {
    return isOpen === false ? '已打烊' : '正在营业'
  }

  private isOpenColor(isOpen: boolean | undefined): string {
    return isOpen === false ? THEME_TEXT_TERTIARY : THEME_SUCCESS
  }

  private isOpenBg(isOpen: boolean | undefined): string {
    return isOpen === false ? '#EFF2F7' : '#EAF8EF'
  }

  private ticketLabel(status: string | undefined, remaining: number | undefined): string {
    if (status === 'SOLD_OUT') {
      return '已售罄'
    }
    if (status === 'LOW_STOCK') {
      return `余票紧张 ${remaining ?? 0}`
    }
    return '售票中'
  }

  private ticketColor(status: string | undefined): string {
    if (status === 'SOLD_OUT') {
      return THEME_TEXT_TERTIARY
    }
    if (status === 'LOW_STOCK') {
      return THEME_WARNING
    }
    return THEME_SUCCESS
  }

  private ticketBg(status: string | undefined): string {
    if (status === 'SOLD_OUT') {
      return '#EFF2F7'
    }
    if (status === 'LOW_STOCK') {
      return '#FFF4E6'
    }
    return '#EAF8EF'
  }

  private distanceText(distanceMeters: number | undefined): string {
    if (distanceMeters === undefined || distanceMeters <= 0) {
      return '景区内可达'
    }
    if (distanceMeters >= 1000) {
      const km: number = Math.round((distanceMeters / 1000) * 10) / 10
      return `距你 ${km}km`
    }
    return `距你 ${distanceMeters}m`
  }

  private foodPrimaryTag(item: DiningResponse): string {
    return item.type.length > 0 ? item.type : '特色餐饮'
  }

  private foodSecondaryTag(item: DiningResponse): string {
    return item.recommendFood.length > 0 ? item.recommendFood.split('、')[0] : '情调约会'
  }

  private entertainmentPrimaryTag(item: EntertainmentResponse): string {
    return item.type.length > 0 ? item.type : '休闲娱乐'
  }

  private entertainmentSecondaryTag(item: EntertainmentResponse): string {
    return item.description.length > 0 ? item.description.substring(0, 4) : '亲子互动'
  }

  private performancePrimaryTag(item: PerformanceResponse): string {
    return item.team.length > 0 ? item.team : '演艺大秀'
  }

  private performanceSecondaryTag(item: PerformanceResponse): string {
    return item.location.length > 0 ? item.location : '声光电沉浸'
  }

  private resolveDiningImage(item: DiningResponse, index: number): string {
    if (item.logoUrl !== undefined && item.logoUrl.length > 0) {
      return item.logoUrl
    }
    if (index % 2 === 0) {
      return 'https://images.unsplash.com/photo-1552566626-52f8b828add9?auto=format&fit=crop&w=600&q=80'
    }
    return 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80'
  }

  private resolveEntertainmentImage(item: EntertainmentResponse, index: number): string {
    if (item.logoUrl !== undefined && item.logoUrl.length > 0) {
      return item.logoUrl
    }
    if (index % 2 === 0) {
      return 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=600&q=80'
    }
    return 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=600&q=80'
  }

  private resolvePerformanceImage(index: number): string {
    if (index % 2 === 0) {
      return 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?auto=format&fit=crop&w=600&q=80'
    }
    return 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=600&q=80'
  }

  private navigateHint(place: string): void {
    this.actionMessage = `已为你打开前往“${place}”的导航引导`
  }

  private bookingHint(name: string): void {
    this.actionMessage = `已为你发起“${name}”的预订/购票引导`
  }

  private recommendCards(): PromoCardModel[] {
    const cards: PromoCardModel[] = []
    const dining: DiningResponse[] = this.visibleDiningList()
    const entertainment: EntertainmentResponse[] = this.visibleEntertainmentList()
    const shows: PerformanceResponse[] = this.visiblePerformanceList()

    if (dining.length > 0) {
      cards.push(new PromoCardModel(
        `promo-${dining[0].id}`,
        this.resolveDiningImage(dining[0], 0),
        '官方力荐',
        dining[0].name,
        `★ ${dining[0].avgPrice > 0 ? '4.8' : '4.6'}`,
        `¥${dining[0].avgPrice}/人`
      ))
    }
    if (shows.length > 0) {
      cards.push(new PromoCardModel(
        `promo-${shows[0].id}`,
        this.resolvePerformanceImage(0),
        '演出热卖',
        shows[0].name,
        '★ 4.9',
        `¥${shows[0].price}起`
      ))
    }
    if (entertainment.length > 0) {
      cards.push(new PromoCardModel(
        `promo-${entertainment[0].id}`,
        this.resolveEntertainmentImage(entertainment[0], 0),
        '夜游精选',
        entertainment[0].name,
        '★ 4.7',
        `¥${entertainment[0].price}/人`
      ))
    }
    if (dining.length > 1) {
      cards.push(new PromoCardModel(
        `promo-${dining[1].id}`,
        this.resolveDiningImage(dining[1], 1),
        '地方名吃',
        dining[1].name,
        '★ 4.8',
        `¥${dining[1].avgPrice}/人`
      ))
    }
    return cards
  }

  private diningCard(item: DiningResponse, index: number): ServiceCardModel {
    const isOpen: boolean = item.isOpen !== false
    return new ServiceCardModel(
      item.id,
      item.name,
      this.resolveDiningImage(item, index),
      '4.8 (2150)',
      `¥${item.avgPrice}/人`,
      this.foodPrimaryTag(item),
      this.foodSecondaryTag(item),
      `${item.address}（${this.distanceText(item.distanceMeters)}）`,
      item.businessHours,
      this.isOpenLabel(item.isOpen),
      this.isOpenColor(item.isOpen),
      this.isOpenBg(item.isOpen),
      isOpen ? '去排队' : '已打烊',
      isOpen ? '#FF8A1F' : '#EFF2F7',
      isOpen ? '#FFFFFF' : THEME_TEXT_TERTIARY,
      !isOpen,
      '特色餐饮',
      '按距离及热度排序'
    )
  }

  private entertainmentCard(item: EntertainmentResponse, index: number): ServiceCardModel {
    const isOpen: boolean = item.isOpen !== false
    return new ServiceCardModel(
      item.id,
      item.name,
      this.resolveEntertainmentImage(item, index),
      '4.7 (890)',
      `¥${item.price}/人`,
      this.entertainmentPrimaryTag(item),
      this.entertainmentSecondaryTag(item),
      `${item.location}（${this.distanceText(item.distanceMeters)}）`,
      item.openTime,
      this.isOpenLabel(item.isOpen),
      this.isOpenColor(item.isOpen),
      this.isOpenBg(item.isOpen),
      isOpen ? '查看详情' : '已打烊',
      isOpen ? '#FFF2E8' : '#EFF2F7',
      isOpen ? '#FF8A1F' : THEME_TEXT_TERTIARY,
      !isOpen,
      '休闲娱乐',
      '沉浸放松'
    )
  }

  private performanceCard(item: PerformanceResponse, index: number): ServiceCardModel {
    const soldOut: boolean = item.ticketStatus === 'SOLD_OUT'
    return new ServiceCardModel(
      item.id,
      item.name,
      this.resolvePerformanceImage(index),
      '4.9 (5328)',
      `¥${item.price}起`,
      this.performancePrimaryTag(item),
      this.performanceSecondaryTag(item),
      `${item.location}（${this.distanceText(item.distanceMeters)}）`,
      item.showDateTime !== undefined && item.showDateTime.length > 0 ? item.showDateTime : item.showTime,
      this.ticketLabel(item.ticketStatus, item.remainingTickets),
      this.ticketColor(item.ticketStatus),
      this.ticketBg(item.ticketStatus),
      soldOut ? '已售罄' : '选座购票',
      soldOut ? '#EFF2F7' : THEME_PRIMARY,
      soldOut ? THEME_TEXT_TERTIARY : '#FFFFFF',
      soldOut,
      '营业性演出',
      '场次推荐'
    )
  }

  private foodCards(): ServiceCardModel[] {
    return this.visibleDiningList().map((item: DiningResponse, index: number) => this.diningCard(item, index))
  }

  private funCards(): ServiceCardModel[] {
    return this.visibleEntertainmentList().map((item: EntertainmentResponse, index: number) => this.entertainmentCard(item, index))
  }

  private showCards(): ServiceCardModel[] {
    return this.visiblePerformanceList().map((item: PerformanceResponse, index: number) => this.performanceCard(item, index))
  }

  private mixedCards(): ServiceCardModel[] {
    const cards: ServiceCardModel[] = []
    this.foodCards().slice(0, 2).forEach((item: ServiceCardModel) => cards.push(item))
    this.showCards().slice(0, 1).forEach((item: ServiceCardModel) => cards.push(item))
    this.funCards().slice(0, 1).forEach((item: ServiceCardModel) => cards.push(item))
    return cards
  }

  private currentCards(): ServiceCardModel[] {
    if (this.category === 'food') {
      return this.foodCards()
    }
    if (this.category === 'fun') {
      return this.funCards()
    }
    if (this.category === 'show') {
      return this.showCards()
    }
    return this.mixedCards()
  }

  private emptyText(): string {
    if (this.category === 'food') {
      return '暂无餐饮数据'
    }
    if (this.category === 'fun') {
      return '暂无娱乐数据'
    }
    if (this.category === 'show') {
      return '暂无演出数据'
    }
    return '暂无推荐内容'
  }

  private cardAction(card: ServiceCardModel): void {
    if (card.actionDisabled) {
      return
    }
    if (card.actionText === '选座购票') {
      this.bookingHint(card.title)
      return
    }
    if (card.actionText === '去排队') {
      this.bookingHint(card.title)
      return
    }
    this.navigateHint(card.title)
  }

  @Builder
  private TopBar(): void {
    Column({ space: 12 }) {
      if (!this.embedded) {
        Column({ space: 4 }) {
          Text('餐饮娱乐与演出')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(THEME_TEXT_PRIMARY)
          Text('吃喝玩乐一站式推荐')
            .fontSize(12)
            .fontColor(THEME_TEXT_TERTIARY)
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
      }

      Row({ space: 10 }) {
        Row({ space: 8 }) {
          Text('⌕')
            .fontSize(14)
            .fontColor('#94A3B8')
          TextInput({ placeholder: '搜索餐厅、游乐项目或演出名称...', text: this.searchKeyword })
            .onChange((value: string) => {
              this.searchKeyword = value
            })
            .layoutWeight(1)
            .backgroundColor(Color.Transparent)
            .borderRadius(RADIUS_PILL)
            .fontSize(14)
        }
        .layoutWeight(1)
        .height(48)
        .padding({ left: 14, right: 14 })
        .backgroundColor(THEME_SURFACE)
        .borderRadius(RADIUS_MD)

        Button('筛选')
          .height(48)
          .padding({ left: 16, right: 16 })
          .borderRadius(RADIUS_MD)
          .backgroundColor(THEME_SURFACE)
          .fontColor(THEME_TEXT_SECONDARY)
          .fontSize(14)
          .onClick(() => {
            this.filterPanelVisible = !this.filterPanelVisible
          })
      }
      .width('100%')

      Row({ space: 10 }) {
        this.CategoryTabButton('推荐', 'recommend')
        this.CategoryTabButton('餐饮', 'food')
        this.CategoryTabButton('娱乐', 'fun')
        this.CategoryTabButton('演出', 'show')
      }
      .width('100%')
      .padding(6)
      .backgroundColor(THEME_SURFACE)
      .borderRadius(RADIUS_MD)

      if (this.filterPanelVisible) {
        Row({ space: 8 }) {
          this.FilterChip(`区域：${this.displayAreaLabel()}`, () => this.cycleAreaFilter())
          this.FilterChip(`价格：${this.displayPriceLabel()}`, () => this.cyclePriceFilter())
          Button('重置')
            .height(34)
            .padding({ left: 14, right: 14 })
            .borderRadius(RADIUS_PILL)
            .backgroundColor('#EEF3FA')
            .fontColor(THEME_TEXT_SECONDARY)
            .fontSize(12)
            .onClick(() => this.resetFilters())
        }
        .width('100%')
      }
    }
    .width('100%')
  }

  @Builder
  private CategoryTabButton(label: string, value: DiningCategory): void {
    Button(label)
      .layoutWeight(1)
      .height(36)
      .borderRadius(RADIUS_PILL)
      .backgroundColor(this.category === value ? THEME_PRIMARY_SOFT : Color.Transparent)
      .fontColor(this.category === value ? THEME_PRIMARY : THEME_TEXT_SECONDARY)
      .fontSize(14)
      .fontWeight(this.category === value ? FontWeight.Medium : FontWeight.Regular)
      .onClick(() => this.switchCategory(value))
  }

  @Builder
  private FilterChip(label: string, action: () => void): void {
    Button(label)
      .height(34)
      .padding({ left: 14, right: 14 })
      .borderRadius(RADIUS_PILL)
      .backgroundColor('#EEF3FA')
      .fontColor(THEME_TEXT_SECONDARY)
      .fontSize(12)
      .onClick(() => action())
  }

  @Builder
  private QuickActionSection(): void {
    if (this.category === 'recommend') {
      Column({ space: 12 }) {
        Row({ space: 14 }) {
          ForEach(this.quickActions, (item: QuickActionItem) => {
            Column({ space: 8 }) {
              Text(item.icon)
                .fontSize(22)
                .textAlign(TextAlign.Center)
                .width(54)
                .height(54)
                .padding({ top: 13 })
                .backgroundColor(this.quickActionBg(item.id))
                .borderRadius(RADIUS_PILL)
              Text(item.label)
                .fontSize(12)
                .fontColor(THEME_TEXT_PRIMARY)
            }
            .width('23%')
            .alignItems(HorizontalAlign.Center)
            .onClick(() => this.switchCategory(item.targetCategory))
          }, (item: QuickActionItem) => item.id)
        }
        .width('100%')

        Column({ space: 10 }) {
          Row() {
            Text('附近推荐与热门')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(THEME_TEXT_PRIMARY)
            Blank()
            Text('按距离及热度排序')
              .fontSize(12)
              .fontColor(THEME_TEXT_TERTIARY)
          }
          .width('100%')

          Scroll() {
            Row({ space: 12 }) {
              ForEach(this.recommendCards(), (item: PromoCardModel) => {
                this.PromoCard(item)
              }, (item: PromoCardModel) => item.id)
            }
            .padding({ right: 12 })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')
        }
        .width('100%')
      }
      .width('100%')
    }
  }

  private quickActionBg(id: string): string {
    if (id === 'tea') {
      return '#FFF0D9'
    }
    if (id === 'food') {
      return '#FFE7E6'
    }
    if (id === 'show') {
      return '#F2E6FF'
    }
    return '#E5F0FF'
  }

  @Builder
  private PromoCard(item: PromoCardModel): void {
    Column({ space: 10 }) {
      Stack({ alignContent: Alignment.TopStart }) {
        Image(item.imageUrl)
          .width(176)
          .height(136)
          .borderRadius(RADIUS_MD)
          .objectFit(ImageFit.Cover)
        Text(item.badge)
          .fontSize(11)
          .fontColor(Color.White)
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .backgroundColor('#FF7A2F')
          .borderRadius(RADIUS_PILL)
          .margin({ left: 10, top: 10 })
      }
      .width(176)

      Column({ space: 6 }) {
        Text(item.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(THEME_TEXT_PRIMARY)
          .maxLines(1)
        Row({ space: 8 }) {
          Text(item.ratingText)
            .fontSize(12)
            .fontColor('#FF8A1F')
          Text(item.priceText)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor(THEME_PRIMARY)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .width(176)
    .padding(12)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private ResultSection(): void {
    Column({ space: 12 }) {
      if (this.loading) {
        this.EmptyCard('正在加载内容...', '请稍候片刻')
      } else if (this.errorMessage.length > 0) {
        Column({ space: 8 }) {
          Text(this.errorMessage)
            .fontSize(12)
            .fontColor(THEME_DANGER)
          Button('重试')
            .height(34)
            .padding({ left: 16, right: 16 })
            .borderRadius(RADIUS_PILL)
            .backgroundColor(THEME_PRIMARY)
            .fontColor(Color.White)
            .onClick(() => this.loadAll())
        }
        .width('100%')
        .padding(14)
        .backgroundColor(THEME_SURFACE)
        .borderRadius(RADIUS_MD)
        .alignItems(HorizontalAlign.Start)
      } else if (this.currentCards().length === 0) {
        this.EmptyCard(this.emptyText(), '换个关键词或筛选条件试试')
      } else {
        ForEach(this.currentCards(), (item: ServiceCardModel) => {
          this.ServiceCard(item)
        }, (item: ServiceCardModel) => item.id)
      }

      if (this.actionMessage.length > 0) {
        Text(this.actionMessage)
          .fontSize(12)
          .fontColor(THEME_TEXT_SECONDARY)
          .padding(12)
          .width('100%')
          .backgroundColor(THEME_SURFACE_MUTED)
          .borderRadius(RADIUS_MD)
      }
    }
    .width('100%')
    .opacity(this.contentOpacity)
    .translate({ x: 0, y: this.contentOffsetY })
  }

  @Builder
  private EmptyCard(title: string, detail: string): void {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(THEME_TEXT_PRIMARY)
      Text(detail)
        .fontSize(12)
        .fontColor(THEME_TEXT_TERTIARY)
    }
    .width('100%')
    .padding(18)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_LG)
  }

  @Builder
  private ServiceCard(item: ServiceCardModel): void {
    Column({ space: 14 }) {
      Row({ space: 14 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(item.imageUrl)
            .width(106)
            .height(106)
            .borderRadius(RADIUS_MD)
            .objectFit(ImageFit.Cover)
          Text(item.caption)
            .fontSize(11)
            .fontColor(Color.White)
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor('rgba(17,24,39,0.58)')
            .borderRadius(RADIUS_PILL)
            .margin({ left: 8, bottom: 8 })
        }

        Column({ space: 8 }) {
          Row() {
            Text(item.title)
              .layoutWeight(1)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(THEME_TEXT_PRIMARY)
            Text(item.priceText)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(THEME_TEXT_PRIMARY)
          }
          .width('100%')

          Row({ space: 8 }) {
            Text(item.ratingText)
              .fontSize(12)
              .fontColor('#FF8A1F')
            Text(item.primaryTag)
              .fontSize(11)
              .fontColor('#5B8FF9')
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .backgroundColor('#EAF2FF')
              .borderRadius(RADIUS_PILL)
            Text(item.secondaryTag)
              .fontSize(11)
              .fontColor('#9D65F9')
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .backgroundColor('#F3EAFF')
              .borderRadius(RADIUS_PILL)
          }
          .width('100%')

          Text(item.locationText)
            .fontSize(12)
            .fontColor(THEME_TEXT_SECONDARY)
            .maxLines(1)
          Text(item.timeText)
            .fontSize(12)
            .fontColor(THEME_TEXT_SECONDARY)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }

      Blank()
        .height(1)
        .width('100%')
        .backgroundColor('#EFF2F7')

      Row() {
        Text(item.statusText)
          .fontSize(12)
          .fontColor(item.statusColor)
          .padding({ left: 12, right: 12, top: 5, bottom: 5 })
          .backgroundColor(item.statusBg)
          .borderRadius(RADIUS_PILL)
        Blank()
        Button(item.actionText)
          .enabled(!item.actionDisabled)
          .height(36)
          .padding({ left: 16, right: 16 })
          .borderRadius(RADIUS_PILL)
          .backgroundColor(item.actionBg)
          .fontColor(item.actionColor)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .onClick(() => this.cardAction(item))
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  build() {
    Column({ space: 14 }) {
      this.TopBar()

      Scroll() {
        Column({ space: 16 }) {
          this.QuickActionSection()
          this.ResultSection()
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ bottom: this.embedded ? 84 : 24 })
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .padding(this.embedded ? { left: 0, right: 0, top: 0, bottom: 0 } : { left: 12, right: 12, top: 12, bottom: 20 })
    .width('100%')
    .height('100%')
    .backgroundColor(this.embedded ? Color.Transparent : THEME_PAGE_BG)
  }
}
