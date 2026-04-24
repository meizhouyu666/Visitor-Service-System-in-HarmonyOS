import { MarketingDashboardResponse, MarketingHotelItemResponse, MarketingHotelUpdateRequest } from '../../common/model/ApiModels'
import { apiClient } from '../../common/network/ApiClient'
import {
  RADIUS_LG,
  RADIUS_MD,
  RADIUS_PILL,
  SHADOW_CARD,
  SHADOW_PANEL,
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

@Component
export struct MarketingPage {
  @State private dashboard: MarketingDashboardResponse = {
    currentVisitors: 0,
    eastHeatPercent: 0,
    westHeatPercent: 0,
    loadLabel: '\u5e73\u7a33',
    suggestion: '\u6b63\u5728\u52a0\u8f7d\u5bfc\u6d41\u8425\u9500\u5efa\u8bae',
    hotels: []
  }
  @State private loading: boolean = false
  @State private savingId: string = ''
  @State private errorMessage: string = ''
  @State private actionMessage: string = ''

  async aboutToAppear(): Promise<void> {
    await this.loadDashboard()
  }

  private async loadDashboard(): Promise<void> {
    this.loading = true
    this.errorMessage = ''
    try {
      const response: MarketingDashboardResponse =
        await apiClient.get<MarketingDashboardResponse>('/api/marketing/hotels')
      this.dashboard = this.normalizeDashboard(response)
    } catch (_error) {
      this.errorMessage =
        '\u52a0\u8f7d\u5bfc\u6d41\u8425\u9500\u6570\u636e\u5931\u8d25\uff0c\u8bf7\u7a0d\u540e\u91cd\u8bd5'
    } finally {
      this.loading = false
    }
  }

  private normalizeDashboard(response: MarketingDashboardResponse): MarketingDashboardResponse {
    return {
      currentVisitors: this.safeNumber(response.currentVisitors, 0),
      eastHeatPercent: this.safePercent(response.eastHeatPercent),
      westHeatPercent: this.safePercent(response.westHeatPercent),
      loadLabel: this.safeText(response.loadLabel, '\u5e73\u7a33'),
      suggestion: this.safeText(response.suggestion, '\u6682\u65e0\u5bfc\u6d41\u5efa\u8bae'),
      hotels: this.normalizeHotels(response.hotels)
    }
  }

  private normalizeHotels(items: MarketingHotelItemResponse[] | null | undefined): MarketingHotelItemResponse[] {
    if (items === undefined || items === null) {
      return []
    }
    return items.map((item: MarketingHotelItemResponse) => this.normalizeHotel(item))
  }

  private normalizeHotel(item: MarketingHotelItemResponse): MarketingHotelItemResponse {
    return {
      id: this.safeText(item.id, ''),
      name: this.safeText(item.name, '\u9152\u5e97\u4fe1\u606f\u5f85\u8865\u5168'),
      address: this.safeText(item.address, '\u5730\u5740\u5f85\u8865\u5168'),
      star: this.safeNumber(item.star, 0),
      price: this.safeNumber(item.price, 0),
      score: this.safeScore(item.score),
      hasBreakfast: this.safeBoolean(item.hasBreakfast, false),
      facility: this.safeText(item.facility, ''),
      introduction: this.safeText(item.introduction, ''),
      availabilityStatus: this.safeText(item.availabilityStatus, 'AVAILABLE'),
      coverImageUrl: this.safeOptionalText(item.coverImageUrl),
      totalRooms: item.totalRooms !== undefined && item.totalRooms !== null ? this.safeNumber(item.totalRooms, 0) :
        undefined,
      availableRooms: item.availableRooms !== undefined && item.availableRooms !== null ?
        this.safeNumber(item.availableRooms, 0) : undefined,
      recommended: this.safeBoolean(item.recommended, false),
      marketingTag: this.safeOptionalText(item.marketingTag),
      marketingPriority: this.safeNumber(item.marketingPriority, 0),
      marketingNote: this.safeOptionalText(item.marketingNote),
      areaLabel: this.safeText(item.areaLabel, '')
    }
  }

  private safeText(value: string | null | undefined, fallback: string): string {
    if (value === undefined || value === null || value.length === 0) {
      return fallback
    }
    return value
  }

  private safeOptionalText(value: string | null | undefined): string | undefined {
    if (value === undefined || value === null || value.length === 0) {
      return undefined
    }
    return value
  }

  private safeNumber(value: number | null | undefined, fallback: number): number {
    if (value === undefined || value === null || Number.isNaN(value)) {
      return fallback
    }
    return value
  }

  private safeScore(value: number | null | undefined): number {
    const score: number = this.safeNumber(value, 0)
    if (score < 0) {
      return 0
    }
    if (score > 5) {
      return 5
    }
    return score
  }

  private safeBoolean(value: boolean | null | undefined, fallback: boolean): boolean {
    if (value === undefined || value === null) {
      return fallback
    }
    return value
  }

  private safePercent(value: number | null | undefined): number {
    const percent: number = this.safeNumber(value, 0)
    if (percent < 0) {
      return 0
    }
    if (percent > 100) {
      return 100
    }
    return percent
  }

  private async toggleRecommendation(item: MarketingHotelItemResponse): Promise<void> {
    this.savingId = item.id;
    this.actionMessage = '';
    this.errorMessage = '';

    try {
      // 新的推荐状态
      const newRecommended = !item.recommended;

      const payload: MarketingHotelUpdateRequest = {
        recommended: newRecommended,
        marketingTag: newRecommended ? this.defaultTag(item) : '',
        marketingPriority: newRecommended ? this.defaultPriority(item) : 0,
        marketingNote: newRecommended ? this.defaultNote(item) : ''
      };

      const url = `/api/marketing/hotels/${item.id}`;

      await apiClient.put<MarketingHotelUpdateRequest, MarketingHotelItemResponse>(url, payload);

      // 提示
      this.actionMessage = newRecommended
        ? '已开启导流推荐'
        : '已关闭导流推荐';

      // 刷新数据
      await this.loadDashboard();

    } catch (error) {
      console.error('更新推荐状态失败', error);
      this.errorMessage = '更新失败，请重试';
    } finally {
      this.savingId = '';
    }
  }

  private defaultTag(item: MarketingHotelItemResponse): string {
    if (item.star >= 4) {
      return '\u5b98\u65b9\u529b\u63a8'
    }
    if (item.areaLabel === 'WEST') {
      return '\u4e61\u6751\u4f18\u9009'
    }
    return '\u5bfc\u6d41\u63a8\u8350'
  }

  private defaultPriority(item: MarketingHotelItemResponse): number {
    let priority: number = 50 + item.star * 8
    if (item.availabilityStatus === 'AVAILABLE') {
      priority += 20
    }
    if (item.areaLabel === 'WEST') {
      priority += 10
    }
    return priority
  }

  private defaultNote(item: MarketingHotelItemResponse): string {
    if (item.areaLabel === 'WEST') {
      return '\u91cd\u70b9\u627f\u63a5\u897f\u533a\u4f11\u95f2\u4f4f\u5bbf\u5ba2\u6d41'
    }
    return '\u9002\u5408\u627f\u63a5\u6838\u5fc3\u666f\u533a\u4f4f\u5bbf\u9700\u6c42'
  }

  private hotelItems(): MarketingHotelItemResponse[] {
    return this.dashboard.hotels
  }

  private marketingTagText(item: MarketingHotelItemResponse): string {
    if (item.marketingTag !== undefined && item.marketingTag.length > 0) {
      return item.marketingTag
    }
    return this.defaultTag(item)
  }

  private hotelAddressText(item: MarketingHotelItemResponse): string {
    return this.safeText(item.address, '\u5730\u5740\u5f85\u8865\u5168')
  }

  private dashboardSuggestionText(): string {
    return this.safeText(this.dashboard.suggestion, '\u6682\u65e0\u5bfc\u6d41\u5efa\u8bae')
  }

  private hotelTypeText(item: MarketingHotelItemResponse): string {
    if (item.star >= 4) {
      return '\u661f\u7ea7\u9152\u5e97'
    }
    if (item.star >= 3) {
      return '\u7279\u8272\u9152\u5e97'
    }
    return '\u4e61\u6751\u6c11\u5bbf'
  }

  private availabilityLabel(item: MarketingHotelItemResponse): string {
    if (item.availabilityStatus === 'FULL') {
      return '\u623f\u6001\uff1a\u6ee1\u623f'
    }
    if (item.availabilityStatus === 'BUSY') {
      return '\u623f\u6001\uff1a\u7d27\u5f20'
    }
    if (item.availabilityStatus === 'LIMITED') {
      return '\u623f\u6001\uff1a\u504f\u7d27'
    }
    return '\u623f\u6001\uff1a\u5145\u8db3'
  }

  private availabilityColor(item: MarketingHotelItemResponse): string {
    if (item.availabilityStatus === 'FULL') {
      return THEME_DANGER
    }
    if (item.availabilityStatus === 'BUSY' || item.availabilityStatus === 'LIMITED') {
      return THEME_WARNING
    }
    return THEME_SUCCESS
  }

  private recommendationStateText(item: MarketingHotelItemResponse): string {
    return item.recommended ? '\u5df2\u5f00\u542f\u4e3b\u9875\u63a8\u8350' : '\u672a\u5f00\u542f\u63a8\u8350'
  }

  private recommendationButtonText(item: MarketingHotelItemResponse): string {
    return item.recommended ? '\u5173\u95ed\u63a8\u8350' : '\u5f00\u542f\u63a8\u8350'
  }

  private roomInventoryText(item: MarketingHotelItemResponse): string {
    const totalRooms: number | undefined = item.totalRooms
    const availableRooms: number | undefined = item.availableRooms
    if (totalRooms !== undefined && availableRooms !== undefined && totalRooms > 0) {
      return `\u5269\u4f59 ${availableRooms} / ${totalRooms} \u95f4`
    }
    return '\u623f\u578b\u5e93\u5b58\u5f85\u540c\u6b65'
  }

  private loadPillBg(): string {
    if (this.dashboard.loadLabel === '\u9ad8\u5cf0') {
      return '#FFECEC'
    }
    if (this.dashboard.loadLabel === '\u8f83\u9ad8') {
      return '#FFF4E6'
    }
    return '#EAF8EF'
  }

  private loadPillColor(): string {
    if (this.dashboard.loadLabel === '\u9ad8\u5cf0') {
      return THEME_DANGER
    }
    if (this.dashboard.loadLabel === '\u8f83\u9ad8') {
      return THEME_WARNING
    }
    return THEME_SUCCESS
  }

  private visitorsText(): string {
    return `${this.dashboard.currentVisitors}`
  }

  private progressWidth(value: number): string {
    return `${value}%`
  }

  private hotelPriceText(item: MarketingHotelItemResponse): string {
    return `\u00A5${item.price}/\u665a\u8d77`
  }

  private scoreText(item: MarketingHotelItemResponse): string {
    return `\u8bc4\u5206 ${item.score.toFixed(1)}`
  }

  private loadTitle(): string {
    return '\u5b9e\u65f6\u5ba2\u6d41\u4e0e\u5bfc\u6d41\u5efa\u8bae'
  }

  private refreshButtonText(): string {
    return this.loading ? '\u5237\u65b0\u4e2d' : '\u5237\u65b0\u52a8\u6001'
  }

  @Builder
  private HeatProgress(label: string, value: number, color: string): void {
    Row({ space: 10 }) {
      Text(label)
        .fontSize(12)
        .fontColor(THEME_TEXT_SECONDARY)
        .width(98)
      Stack({ alignContent: Alignment.Start }) {
        Text('')
          .width('100%')
          .height(6)
          .backgroundColor(THEME_SURFACE_MUTED)
          .borderRadius(RADIUS_PILL)
        Text('')
          .width(this.progressWidth(value))
          .height(6)
          .backgroundColor(color)
          .borderRadius(RADIUS_PILL)
      }
      .layoutWeight(1)

      Text(this.progressWidth(value))
        .fontSize(11)
        .fontColor(color)
        .width(42)
        .textAlign(TextAlign.End)
    }
    .width('100%')
  }

  @Builder
  private HotelBadge(text: string, bg: string, color: string): void {
    Text(text)
      .fontSize(10)
      .fontColor(color)
      .backgroundColor(bg)
      .padding({
        left: 8,
        right: 8,
        top: 4,
        bottom: 4
      })
      .borderRadius(RADIUS_PILL)
  }

  @Builder
  private HotelCover(item: MarketingHotelItemResponse): void {
    Column({ space: 8 }) {
      Text(item.recommended ? '\\u8350' : '\\u5bbf')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
      Text(this.hotelTypeText(item))
        .fontSize(11)
        .fontColor('#EAF2FF')
        .textAlign(TextAlign.Center)
    }
    .justifyContent(FlexAlign.Center)
    .width(86)
    .height(86)
    .backgroundColor(item.recommended ? THEME_PRIMARY : '#4B5563')
    .borderRadius(22)
  }

  @Builder
  private HotelCard(item: MarketingHotelItemResponse): void {
    Row({ space: 14 }) {
      this.HotelCover(item)
      Column({ space: 10 }) {
        Row() {
          Column({ space: 4 }) {
            Text(item.name)
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor(THEME_TEXT_PRIMARY)
              .maxLines(1)
            Row({ space: 8 }) {
              Text(this.scoreText(item))
                .fontSize(11)
                .fontColor('#EA580C')
              Text(this.hotelPriceText(item))
                .fontSize(11)
                .fontColor(THEME_TEXT_SECONDARY)
            }
          }
          .alignItems(HorizontalAlign.Start)

          Blank()
          this.HotelBadge(this.marketingTagText(item), '#FFF4E6', '#EA580C')
        }
        .width('100%')

        Text(this.hotelAddressText(item))
          .fontSize(12)
          .fontColor(THEME_TEXT_SECONDARY)
          .maxLines(2)

        Text(this.roomInventoryText(item))
          .fontSize(12)
          .fontColor(THEME_TEXT_SECONDARY)
          .maxLines(1)

        Row({ space: 8 }) {
          this.HotelBadge(this.hotelTypeText(item), THEME_PRIMARY_SOFT, THEME_PRIMARY)
          if (item.hasBreakfast) {
            this.HotelBadge('\u542b\u65e9\u9910', '#F3E8FF', '#7C3AED')
          }
        }

        Row() {
          Text(this.availabilityLabel(item))
            .fontSize(11)
            .fontColor(this.availabilityColor(item))
            .backgroundColor('#FFF7ED')
            .padding({
              left: 10,
              right: 10,
              top: 5,
              bottom: 5
            })
            .borderRadius(RADIUS_PILL)
          Blank()
          Button(this.recommendationButtonText(item))
            .height(34)
            .padding({ left: 16, right: 16 })
            .borderRadius(RADIUS_PILL)
            .backgroundColor(item.recommended ? THEME_PRIMARY_SOFT : '#EEF3FA')
            .fontColor(item.recommended ? THEME_PRIMARY : THEME_TEXT_SECONDARY)
            .fontSize(12)
            .enabled(this.savingId.length === 0 || this.savingId === item.id)
            .onClick(() => {
              this.toggleRecommendation(item)
            })
        }
        .width('100%')

        Text(this.recommendationStateText(item))
          .fontSize(11)
          .fontColor(item.recommended ? THEME_PRIMARY : THEME_TEXT_TERTIARY)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private LoadingCard(title: string, subtitle: string): void {
    Column({ space: 6 }) {
      Text(title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(THEME_TEXT_PRIMARY)
      Text(subtitle)
        .fontSize(11)
        .fontColor(THEME_TEXT_TERTIARY)
    }
    .width('100%')
    .padding({ top: 24, bottom: 24 })
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  build() {
    Column() {
      // 非滚动部分：顶部客流卡片
      Column({ space: 14 }) {
        Row() {
          Text(this.loadTitle())
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(THEME_TEXT_PRIMARY)
          Blank()
          Text(this.dashboard.loadLabel)
            .fontSize(11)
            .fontColor(this.loadPillColor())
            .backgroundColor(this.loadPillBg())
            .padding({
              left: 10,
              right: 10,
              top: 6,
              bottom: 6
            })
            .borderRadius(RADIUS_PILL)
        }
        .width('100%')

        Column({ space: 14 }) {
          Text('\u5f53\u524d\u666f\u533a\u603b\u5ba2\u6d41')
            .fontSize(12)
            .fontColor(THEME_TEXT_SECONDARY)
            .width('100%')
          Text(this.visitorsText())
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(THEME_TEXT_PRIMARY)
          this.HeatProgress('\u4e1c\u533a\uff08\u6e56\u7554\u666f\u70b9\uff09', this.dashboard.eastHeatPercent,
            '#F97373')
          this.HeatProgress('\u897f\u533a\uff08\u4e61\u6751\u5468\u8fb9\uff09', this.dashboard.westHeatPercent,
            THEME_PRIMARY)
          Text(this.dashboardSuggestionText())
            .fontSize(12)
            .fontColor(THEME_TEXT_PRIMARY)
            .lineHeight(20)
            .width('100%')
        }
        .width('100%')
        .padding(18)
        .backgroundColor(THEME_SURFACE)
        .borderRadius(RADIUS_LG)
        .shadow(SHADOW_CARD)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 18 })

      // 可滚动部分：推荐营销配置和酒店列表
      Scroll() {
        Column({ space: 18 }) {
          Row() {
            Text('\u63a8\u8350\u8425\u9500\u914d\u7f6e')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(THEME_TEXT_PRIMARY)
            Blank()
            Button(this.refreshButtonText())
              .height(32)
              .padding({ left: 12, right: 12 })
              .borderRadius(RADIUS_PILL)
              .backgroundColor(THEME_PRIMARY_SOFT)
              .fontColor(THEME_PRIMARY)
              .fontSize(11)
              .enabled(!this.loading)
              .onClick(() => {
                this.loadDashboard()
              })
          }
          .width('100%')

          if (this.errorMessage.length > 0) {
            Text(this.errorMessage)
              .fontSize(12)
              .fontColor(THEME_DANGER)
              .width('100%')
          }
          if (this.actionMessage.length > 0) {
            Text(this.actionMessage)
              .fontSize(12)
              .fontColor(THEME_SUCCESS)
              .width('100%')
          }

          if (this.loading && this.hotelItems().length === 0) {
            this.LoadingCard('\u6b63\u5728\u52a0\u8f7d\u5bfc\u6d41\u914d\u7f6e',
              '\u6b63\u5728\u540c\u6b65\u9152\u5e97\u63a8\u8350\u4e0e\u623f\u6001\u6570\u636e')
          } else if (this.hotelItems().length === 0) {
            this.LoadingCard('\u6682\u65e0\u9152\u5e97\u6570\u636e',
              '\u8bf7\u5148\u5728\u9152\u5e97\u7ba1\u7406\u7aef\u7ef4\u62a4\u57fa\u7840\u9152\u5e97\u8d44\u6599')
          } else {
            Column({ space: 14 }) {
              ForEach(this.hotelItems(), (item: MarketingHotelItemResponse) => {
                this.HotelCard(item)
              }, (item: MarketingHotelItemResponse) => item.id)
            }
            .width('100%')
          }
        }
        .padding({ left: 20, right: 20, bottom: 28 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(THEME_PAGE_BG)
  }
}