import { DiningResponse, EntertainmentResponse, PerformanceResponse } from '../../common/model/ApiModels'
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
  THEME_TEXT_PRIMARY,
  THEME_TEXT_SECONDARY,
  THEME_TEXT_TERTIARY,
  THEME_WARNING
} from '../../common/ui/AppTheme'

type DiningCategory = 'recommend' | 'food' | 'fun' | 'show'
type AreaFilter = 'all' | '古城' | '滨江' | '景区'
type PriceFilter = 'all' | '0-100' | '100-300' | '300+'

enum ServiceCardKind {
  FOOD = 'FOOD',
  FUN = 'FUN',
  SHOW = 'SHOW'
}

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

class PromoCardModel {
  id: string
  badge: string
  title: string
  subtitle: string
  ratingText: string
  priceText: string
  targetCategory: DiningCategory

  constructor(
    id: string,
    badge: string,
    title: string,
    subtitle: string,
    ratingText: string,
    priceText: string,
    targetCategory: DiningCategory
  ) {
    this.id = id
    this.badge = badge
    this.title = title
    this.subtitle = subtitle
    this.ratingText = ratingText
    this.priceText = priceText
    this.targetCategory = targetCategory
  }
}

class ServiceCardModel {
  id: string
  kind: ServiceCardKind
  title: string
  caption: string
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
  coverTone: string
  coverLabel: string
  orderHint: string

  constructor(
    id: string,
    kind: ServiceCardKind,
    title: string,
    caption: string,
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
    coverTone: string,
    coverLabel: string,
    orderHint: string
  ) {
    this.id = id
    this.kind = kind
    this.title = title
    this.caption = caption
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
    this.coverTone = coverTone
    this.coverLabel = coverLabel
    this.orderHint = orderHint
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
    new QuickActionItem('food', '🍜', '地方名吃', 'food'),
    new QuickActionItem('show', '🎭', '演出日历', 'show'),
    new QuickActionItem('bar', '🎵', '酒吧夜生活', 'fun')
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
      return '0-100'
    }
    if (this.priceFilter === '100-300') {
      return '100-300'
    }
    if (this.priceFilter === '300+') {
      return '300+'
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

  private openStatusText(isOpen: boolean | undefined): string {
    return isOpen === false ? '已打烊' : '正在营业'
  }

  private openStatusColor(isOpen: boolean | undefined): string {
    return isOpen === false ? THEME_TEXT_TERTIARY : THEME_SUCCESS
  }

  private openStatusBg(isOpen: boolean | undefined): string {
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
    if (item.recommendFood.length > 0) {
      const parts: string[] = item.recommendFood.split(/[、,，]/)
      return parts[0].trim().length > 0 ? parts[0].trim() : '情调约会'
    }
    return '情调约会'
  }

  private entertainmentPrimaryTag(item: EntertainmentResponse): string {
    return item.type.length > 0 ? item.type : '休闲娱乐'
  }

  private entertainmentSecondaryTag(item: EntertainmentResponse): string {
    return item.description.length >= 4 ? item.description.substring(0, 4) : '亲子互动'
  }

  private performancePrimaryTag(item: PerformanceResponse): string {
    return item.team !== undefined && item.team.length > 0 ? item.team : '演艺大秀'
  }

  private performanceSecondaryTag(item: PerformanceResponse): string {
    if (item.venue !== undefined && item.venue.length > 0) {
      return item.venue
    }
    return '声光电沉浸'
  }

  private diningCoverTone(index: number): string {
    return index % 2 === 0 ? '#FFB566' : '#FF8A1F'
  }

  private entertainmentCoverTone(index: number): string {
    return index % 2 === 0 ? '#F59E0B' : '#FB7185'
  }

  private performanceCoverTone(index: number): string {
    return index % 2 === 0 ? '#8B5CF6' : '#3B82F6'
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
        `promo-dining-${dining[0].id}`,
        '官方推荐',
        dining[0].name,
        dining[0].address,
        '★ 4.8',
        `¥${dining[0].avgPrice}/人`,
        'food'
      ))
    }
    if (shows.length > 0) {
      cards.push(new PromoCardModel(
        `promo-show-${shows[0].id}`,
        '演出热卖',
        shows[0].name,
        shows[0].location,
        '★ 4.9',
        `¥${shows[0].price}起`,
        'show'
      ))
    }
    if (entertainment.length > 0) {
      cards.push(new PromoCardModel(
        `promo-fun-${entertainment[0].id}`,
        '夜游精选',
        entertainment[0].name,
        entertainment[0].location,
        '★ 4.7',
        `¥${entertainment[0].price}/人`,
        'fun'
      ))
    }
    if (dining.length > 1) {
      cards.push(new PromoCardModel(
        `promo-dining-${dining[1].id}`,
        '地方名吃',
        dining[1].name,
        dining[1].address,
        '★ 4.7',
        `¥${dining[1].avgPrice}/人`,
        'food'
      ))
    }
    return cards
  }

  private diningCard(item: DiningResponse, index: number): ServiceCardModel {
    const isOpen: boolean = item.isOpen !== false
    return new ServiceCardModel(
      item.id,
      ServiceCardKind.FOOD,
      item.name,
      '特色餐饮',
      '4.8 (2150)',
      `¥${item.avgPrice}/人`,
      this.foodPrimaryTag(item),
      this.foodSecondaryTag(item),
      `${item.address}（${this.distanceText(item.distanceMeters)}）`,
      item.businessHours,
      this.openStatusText(item.isOpen),
      this.openStatusColor(item.isOpen),
      this.openStatusBg(item.isOpen),
      isOpen ? '去排队' : '已打烊',
      isOpen ? '#FF8A1F' : '#EFF2F7',
      isOpen ? '#FFFFFF' : THEME_TEXT_TERTIARY,
      !isOpen,
      this.diningCoverTone(index),
      '特色餐饮',
      '按距离及热度排序'
    )
  }

  private entertainmentCard(item: EntertainmentResponse, index: number): ServiceCardModel {
    const isOpen: boolean = item.isOpen !== false
    return new ServiceCardModel(
      item.id,
      ServiceCardKind.FUN,
      item.name,
      '休闲娱乐',
      '4.7 (890)',
      `¥${item.price}/人`,
      this.entertainmentPrimaryTag(item),
      this.entertainmentSecondaryTag(item),
      `${item.location}（${this.distanceText(item.distanceMeters)}）`,
      item.openTime,
      this.openStatusText(item.isOpen),
      this.openStatusColor(item.isOpen),
      this.openStatusBg(item.isOpen),
      isOpen ? '查看详情' : '已打烊',
      isOpen ? '#FFF2E8' : '#EFF2F7',
      isOpen ? '#FF8A1F' : THEME_TEXT_TERTIARY,
      !isOpen,
      this.entertainmentCoverTone(index),
      '休闲娱乐',
      '沉浸放松'
    )
  }

  private performanceCard(item: PerformanceResponse, index: number): ServiceCardModel {
    const soldOut: boolean = item.ticketStatus === 'SOLD_OUT'
    const showTime: string = item.showDateTime !== undefined && item.showDateTime.length > 0 ? item.showDateTime : item.showTime
    return new ServiceCardModel(
      item.id,
      ServiceCardKind.SHOW,
      item.name,
      '营业性演出',
      '4.9 (5328)',
      `¥${item.price}起`,
      this.performancePrimaryTag(item),
      this.performanceSecondaryTag(item),
      `${item.location}（${this.distanceText(item.distanceMeters)}）`,
      showTime,
      this.ticketLabel(item.ticketStatus, item.remainingTickets),
      this.ticketColor(item.ticketStatus),
      this.ticketBg(item.ticketStatus),
      soldOut ? '已售罄' : '选座购票',
      soldOut ? '#EFF2F7' : THEME_PRIMARY,
      soldOut ? THEME_TEXT_TERTIARY : '#FFFFFF',
      soldOut,
      this.performanceCoverTone(index),
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

  private hasCurrentCards(): boolean {
    return this.currentCards().length > 0
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

  private jumpToQuickAction(item: QuickActionItem): void {
    this.switchCategory(item.targetCategory)
  }

  private jumpFromPromo(item: PromoCardModel): void {
    this.switchCategory(item.targetCategory)
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
          Text('🔍')
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
                .fontSize(24)
                .width(52)
                .height(52)
                .textAlign(TextAlign.Center)
                .padding({ top: 10 })
                .backgroundColor('#FFF7ED')
                .borderRadius(RADIUS_PILL)
              Text(item.label)
                .fontSize(12)
                .fontColor(THEME_TEXT_SECONDARY)
            }
            .width(72)
            .onClick(() => this.jumpToQuickAction(item))
          }, (item: QuickActionItem) => item.id)
        }
        .width('100%')
      }
      .width('100%')
    }
  }

  @Builder
  private PromoSection(): void {
    if (this.category === 'recommend' && this.recommendCards().length > 0) {
      Column({ space: 12 }) {
        Row() {
          Text('附近推荐与热门')
            .fontSize(18)
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
            ForEach(this.recommendCards(), (item: PromoCardModel, index: number) => {
              this.PromoCard(item, index)
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
  }

  @Builder
  private PromoCard(item: PromoCardModel, index: number): void {
    Column({ space: 8 }) {
      Column({ space: 6 }) {
        Text(item.badge)
          .fontSize(10)
          .fontColor('#FF7A1A')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('#FFF1E8')
          .borderRadius(RADIUS_PILL)

        Blank()

        Text(item.title)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .maxLines(2)
      }
      .width(168)
      .height(132)
      .padding(12)
      .borderRadius(RADIUS_MD)
      .backgroundColor(index % 2 === 0 ? '#1E40AF' : '#7C3AED')
      .alignItems(HorizontalAlign.Start)

      Text(item.subtitle)
        .fontSize(12)
        .fontColor(THEME_TEXT_SECONDARY)
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
    .width(168)
    .padding(12)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_MD)
    .shadow(SHADOW_CARD)
    .onClick(() => this.jumpFromPromo(item))
  }

  @Builder
  private ServiceCard(card: ServiceCardModel): void {
    Row({ space: 14 }) {
      Column({ space: 8 }) {
        Text(card.caption)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor('rgba(15,23,42,0.32)')
          .borderRadius(RADIUS_PILL)
        Blank()
        Text(card.coverLabel)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
      }
      .width(100)
      .height(100)
      .padding(12)
      .backgroundColor(card.coverTone)
      .borderRadius(RADIUS_MD)
      .alignItems(HorizontalAlign.Start)

      Column({ space: 8 }) {
        Row() {
          Text(card.title)
            .layoutWeight(1)
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor(THEME_TEXT_PRIMARY)
            .maxLines(1)
          Text(card.priceText)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(THEME_TEXT_PRIMARY)
        }
        .width('100%')

        Row({ space: 8 }) {
          Text(card.ratingText)
            .fontSize(12)
            .fontColor('#FF8A1F')
          Text(card.primaryTag)
            .fontSize(11)
            .fontColor('#FF8A1F')
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .backgroundColor('#FFF2E8')
            .borderRadius(RADIUS_PILL)
          Text(card.secondaryTag)
            .fontSize(11)
            .fontColor('#8B5CF6')
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .backgroundColor('#F4ECFF')
            .borderRadius(RADIUS_PILL)
        }
        .width('100%')

        Text(card.locationText)
          .fontSize(12)
          .fontColor(THEME_TEXT_SECONDARY)
          .maxLines(1)

        Text(card.timeText)
          .fontSize(12)
          .fontColor(THEME_TEXT_SECONDARY)
          .maxLines(1)

        Row() {
          Text(card.statusText)
            .fontSize(12)
            .fontColor(card.statusColor)
            .padding({ left: 12, right: 12, top: 5, bottom: 5 })
            .backgroundColor(card.statusBg)
            .borderRadius(RADIUS_PILL)
          Blank()
          Button(card.actionText)
            .enabled(!card.actionDisabled)
            .height(34)
            .padding({ left: 14, right: 14 })
            .borderRadius(RADIUS_PILL)
            .backgroundColor(card.actionBg)
            .fontColor(card.actionColor)
            .fontSize(13)
            .onClick(() => this.cardAction(card))
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
  private ContentSection(): void {
    if (this.loading && !this.hasCurrentCards()) {
      Text('正在加载餐饮娱乐演出数据...')
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
          .fontColor('#FFFFFF')
          .onClick(() => this.loadAll())
      }
      .width('100%')
      .padding(12)
      .backgroundColor(THEME_SURFACE)
      .borderRadius(RADIUS_MD)
      .alignItems(HorizontalAlign.Start)
    } else if (!this.hasCurrentCards()) {
      Text(this.emptyText())
        .fontSize(12)
        .fontColor(THEME_TEXT_SECONDARY)
        .width('100%')
        .padding(12)
        .backgroundColor(THEME_SURFACE)
        .borderRadius(RADIUS_MD)
    } else {
      Column({ space: 12 }) {
        this.QuickActionSection()
        this.PromoSection()
        if (this.actionMessage.length > 0) {
          Text(this.actionMessage)
            .fontSize(12)
            .fontColor(THEME_PRIMARY)
            .width('100%')
            .padding({ left: 4, right: 4 })
        }
        ForEach(this.currentCards(), (card: ServiceCardModel) => {
          this.ServiceCard(card)
        }, (card: ServiceCardModel) => card.id)
      }
      .width('100%')
    }
  }

  build() {
    Column({ space: 12 }) {
      this.TopBar()
      Scroll() {
        Column({ space: 12 }) {
          this.ContentSection()
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
    .padding({ left: 12, right: 12, top: 12, bottom: this.embedded ? 0 : 98 })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .backgroundColor(THEME_PAGE_BG)
  }
}
