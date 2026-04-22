import { ResourceApiCategory, ResourceItemRequest, ResourceItemResponse } from '../../common/model/ApiModels'
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

type ResourceScreen = 'LIST' | 'FORM'

class ResourceCategoryOption {
  key: ResourceApiCategory
  title: string
  shortTitle: string
  icon: string
  accentColor: string
  accentBg: string

  constructor(
    key: ResourceApiCategory,
    title: string,
    shortTitle: string,
    icon: string,
    accentColor: string,
    accentBg: string
  ) {
    this.key = key
    this.title = title
    this.shortTitle = shortTitle
    this.icon = icon
    this.accentColor = accentColor
    this.accentBg = accentBg
  }
}

@Component
export struct ResourceLibraryPage {
  @State private screen: ResourceScreen = 'LIST'
  @State private selectedCategory: ResourceApiCategory = 'SCENIC_SPOTS'
  @State private items: ResourceItemResponse[] = []
  @State private loading: boolean = false
  @State private saving: boolean = false
  @State private searchQuery: string = ''
  @State private editingId: string = ''
  @State private errorMessage: string = ''
  @State private actionMessage: string = ''

  @State private titleInput: string = ''
  @State private descriptionInput: string = ''
  @State private coverImageUrlInput: string = ''
  @State private onlineInput: boolean = true

  @State private scenicAreaInput: string = ''
  @State private locationInput: string = ''
  @State private openTimeInput: string = ''
  @State private ticketPriceInput: string = ''
  @State private levelInput: string = ''
  @State private scenicTypeInput: string = ''
  @State private isFreeInput: boolean = false
  @State private crowdHeatInput: string = ''

  @State private durationHoursInput: string = ''
  @State private difficultyInput: string = ''
  @State private suitableForInput: string = ''
  @State private spotsInput: string = ''

  @State private diningTypeInput: string = ''
  @State private avgPriceInput: string = ''
  @State private businessHoursInput: string = ''
  @State private addressInput: string = ''
  @State private recommendFoodInput: string = ''
  @State private distanceMetersInput: string = ''
  @State private isOpenInput: boolean = true
  @State private navLatInput: string = ''
  @State private navLngInput: string = ''

  @State private showTimeInput: string = ''
  @State private priceInput: string = ''
  @State private teamInput: string = ''
  @State private venueInput: string = ''
  @State private showDateTimeInput: string = ''
  @State private remainingTicketsInput: string = ''
  @State private ticketStatusInput: string = 'AVAILABLE'

  private categoryOptions: ResourceCategoryOption[] = [
    new ResourceCategoryOption('SCENIC_SPOTS', '景区景点', '景点', '🗺', THEME_PRIMARY, THEME_PRIMARY_SOFT),
    new ResourceCategoryOption('ROUTES', '游览线路', '线路', '➤', THEME_SUCCESS, '#EAF8EF'),
    new ResourceCategoryOption('DINING', '餐饮娱乐', '餐饮', '#', '#EA580C', '#FFF4E6'),
    new ResourceCategoryOption('PERFORMANCES', '演出团体', '演出', '♪', '#7C3AED', '#F3E8FF')
  ]

  async aboutToAppear(): Promise<void> {
    await this.loadItems()
  }

  private categoryPath(category: ResourceApiCategory): string {
    if (category === 'ROUTES') {
      return 'routes'
    }
    if (category === 'DINING') {
      return 'dining'
    }
    if (category === 'PERFORMANCES') {
      return 'performances'
    }
    return 'scenic-spots'
  }

  private currentCategoryOption(): ResourceCategoryOption {
    const target: ResourceCategoryOption | undefined = this.categoryOptions.find((item: ResourceCategoryOption) => item.key === this.selectedCategory)
    if (target === undefined) {
      return this.categoryOptions[0]
    }
    return target
  }

  private categoryButtonScale(key: ResourceApiCategory): number {
    return this.selectedCategory === key ? 1 : 0.985
  }

  private categoryButtonBg(key: ResourceApiCategory): string {
    return this.selectedCategory === key ? THEME_PRIMARY : THEME_SURFACE
  }

  private categoryButtonTextColor(key: ResourceApiCategory): string {
    return this.selectedCategory === key ? '#FFFFFF' : THEME_TEXT_PRIMARY
  }

  private categoryIconBg(option: ResourceCategoryOption): string {
    return this.selectedCategory === option.key ? '#FFFFFF22' : option.accentBg
  }

  private categoryIconColor(option: ResourceCategoryOption): string {
    return this.selectedCategory === option.key ? '#FFFFFF' : option.accentColor
  }

  private searchPlaceholder(): string {
    if (this.selectedCategory === 'ROUTES') {
      return '搜索游览线路名称...'
    }
    if (this.selectedCategory === 'DINING') {
      return '搜索餐饮娱乐名称...'
    }
    if (this.selectedCategory === 'PERFORMANCES') {
      return '搜索演出团体名称...'
    }
    return '搜索景区景点名称...'
  }

  private createButtonText(): string {
    if (this.selectedCategory === 'ROUTES') {
      return '+  新增游览线路'
    }
    if (this.selectedCategory === 'DINING') {
      return '+  新增餐饮娱乐'
    }
    if (this.selectedCategory === 'PERFORMANCES') {
      return '+  新增演出团体'
    }
    return '+  新增景区景点'
  }

  private saveButtonText(): string {
    return this.editingId.length > 0 ? '保存修改' : '新增资源'
  }

  private parseInteger(value: string): number | undefined {
    const trimmed: string = value.trim()
    if (trimmed.length === 0) {
      return undefined
    }
    const parsed: number = Number(trimmed)
    if (!Number.isFinite(parsed)) {
      return undefined
    }
    return Math.trunc(parsed)
  }

  private parseDouble(value: string): number | undefined {
    const trimmed: string = value.trim()
    if (trimmed.length === 0) {
      return undefined
    }
    const parsed: number = Number(trimmed)
    if (!Number.isFinite(parsed)) {
      return undefined
    }
    return parsed
  }

  private emptyToUndefined(value: string): string | undefined {
    const trimmed: string = value.trim()
    return trimmed.length > 0 ? trimmed : undefined
  }

  private filteredItems(): ResourceItemResponse[] {
    const keyword: string = this.searchQuery.trim().toLowerCase()
    if (keyword.length === 0) {
      return this.items
    }
    return this.items.filter((item: ResourceItemResponse) => {
      const title: string = item.title.toLowerCase()
      const subtitle: string = item.subtitle === null ? '' : item.subtitle.toLowerCase()
      const location: string = item.location === null ? '' : item.location.toLowerCase()
      const description: string = item.description.toLowerCase()
      return title.includes(keyword) || subtitle.includes(keyword) || location.includes(keyword) || description.includes(keyword)
    })
  }

  private async loadItems(preferredId?: string): Promise<void> {
    this.loading = true
    this.errorMessage = ''
    try {
      const path: string = `/api/resources/${this.categoryPath(this.selectedCategory)}`
      const list: ResourceItemResponse[] = await apiClient.get<ResourceItemResponse[]>(path)
      this.items = [...list]
      if (preferredId !== undefined && preferredId.length > 0) {
        const exists: boolean = this.items.some((item: ResourceItemResponse) => item.id === preferredId)
        if (!exists) {
          this.editingId = ''
        }
      }
    } catch (_error) {
      this.errorMessage = '加载资源库数据失败，请稍后重试'
    } finally {
      this.loading = false
    }
  }

  private switchCategory(category: ResourceApiCategory): void {
    if (this.selectedCategory === category && this.screen === 'LIST') {
      return
    }
    this.selectedCategory = category
    this.searchQuery = ''
    this.actionMessage = ''
    this.errorMessage = ''
    if (this.screen === 'LIST') {
      this.loadItems()
      return
    }
    if (this.editingId.length === 0) {
      this.clearFormForCategory(category)
    }
  }

  private startCreate(): void {
    this.screen = 'FORM'
    this.editingId = ''
    this.actionMessage = ''
    this.errorMessage = ''
    this.clearFormForCategory(this.selectedCategory)
  }

  private startEdit(item: ResourceItemResponse): void {
    this.screen = 'FORM'
    this.selectedCategory = this.normalizeCategory(item.category)
    this.editingId = item.id
    this.fillForm(item)
    this.actionMessage = ''
    this.errorMessage = ''
  }

  private cancelForm(): void {
    this.screen = 'LIST'
    this.editingId = ''
    this.actionMessage = ''
    this.errorMessage = ''
  }

  private normalizeCategory(value: string): ResourceApiCategory {
    if (value === 'ROUTES') {
      return 'ROUTES'
    }
    if (value === 'DINING') {
      return 'DINING'
    }
    if (value === 'PERFORMANCES') {
      return 'PERFORMANCES'
    }
    return 'SCENIC_SPOTS'
  }

  private clearCommonForm(): void {
    this.titleInput = ''
    this.descriptionInput = ''
    this.coverImageUrlInput = ''
    this.onlineInput = true
  }

  private clearFormForCategory(category: ResourceApiCategory): void {
    this.clearCommonForm()
    this.scenicAreaInput = ''
    this.locationInput = ''
    this.openTimeInput = ''
    this.ticketPriceInput = ''
    this.levelInput = ''
    this.scenicTypeInput = ''
    this.isFreeInput = false
    this.crowdHeatInput = ''
    this.durationHoursInput = ''
    this.difficultyInput = ''
    this.suitableForInput = ''
    this.spotsInput = ''
    this.diningTypeInput = ''
    this.avgPriceInput = ''
    this.businessHoursInput = ''
    this.addressInput = ''
    this.recommendFoodInput = ''
    this.distanceMetersInput = ''
    this.isOpenInput = true
    this.navLatInput = ''
    this.navLngInput = ''
    this.showTimeInput = ''
    this.priceInput = ''
    this.teamInput = ''
    this.venueInput = ''
    this.showDateTimeInput = ''
    this.remainingTicketsInput = ''
    this.ticketStatusInput = 'AVAILABLE'
    if (category === 'SCENIC_SPOTS') {
      this.levelInput = 'AAAA'
    }
    if (category === 'ROUTES') {
      this.difficultyInput = 'MEDIUM'
    }
  }

  private fillForm(item: ResourceItemResponse): void {
    this.clearFormForCategory(this.normalizeCategory(item.category))
    this.titleInput = item.title
    this.descriptionInput = item.description
    this.coverImageUrlInput = item.coverImageUrl === null ? '' : item.coverImageUrl
    this.onlineInput = item.online
    this.scenicAreaInput = item.scenicArea === null ? '' : item.scenicArea
    this.locationInput = item.location === null ? '' : item.location
    this.openTimeInput = item.openTime === null ? '' : item.openTime
    this.ticketPriceInput = item.ticketPrice === null ? '' : `${item.ticketPrice}`
    this.levelInput = item.level === null ? '' : item.level
    this.scenicTypeInput = item.type === null ? '' : item.type
    this.isFreeInput = item.isFree === null ? false : item.isFree
    this.crowdHeatInput = item.crowdHeat === null ? '' : `${item.crowdHeat}`
    this.durationHoursInput = item.durationHours === null ? '' : `${item.durationHours}`
    this.difficultyInput = item.difficulty === null ? '' : item.difficulty
    this.suitableForInput = item.suitableFor === null ? '' : item.suitableFor
    this.spotsInput = item.spots === null ? '' : item.spots
    this.diningTypeInput = item.type === null ? '' : item.type
    this.avgPriceInput = item.avgPrice === null ? '' : `${item.avgPrice}`
    this.businessHoursInput = item.businessHours === null ? '' : item.businessHours
    this.addressInput = item.address === null ? '' : item.address
    this.recommendFoodInput = item.recommendFood === null ? '' : item.recommendFood
    this.distanceMetersInput = item.distanceMeters === null ? '' : `${item.distanceMeters}`
    this.isOpenInput = item.isOpen === null ? true : item.isOpen
    this.navLatInput = item.navLat === null ? '' : `${item.navLat}`
    this.navLngInput = item.navLng === null ? '' : `${item.navLng}`
    this.showTimeInput = item.showTime === null ? '' : item.showTime
    this.priceInput = item.price === null ? '' : `${item.price}`
    this.teamInput = item.team === null ? '' : item.team
    this.venueInput = item.venue === null ? '' : item.venue
    this.showDateTimeInput = item.showDateTime === null ? '' : item.showDateTime
    this.remainingTicketsInput = item.remainingTickets === null ? '' : `${item.remainingTickets}`
    this.ticketStatusInput = item.ticketStatus === null ? 'AVAILABLE' : item.ticketStatus
  }

  private validateCurrentForm(): string {
    if (this.titleInput.trim().length === 0) {
      return '请先填写资源标题'
    }
    if (this.descriptionInput.trim().length === 0) {
      return '请先填写资源简介'
    }
    if (this.selectedCategory === 'SCENIC_SPOTS') {
      if (this.scenicAreaInput.trim().length === 0 || this.locationInput.trim().length === 0 || this.openTimeInput.trim().length === 0) {
        return '景区景点请填写景区分区、位置和开放时间'
      }
      if (this.parseInteger(this.ticketPriceInput) === undefined) {
        return '景区景点请填写合法票价'
      }
      if (this.levelInput.trim().length === 0 || this.scenicTypeInput.trim().length === 0) {
        return '景区景点请填写等级和类型'
      }
    }
    if (this.selectedCategory === 'ROUTES') {
      if (this.parseInteger(this.durationHoursInput) === undefined) {
        return '游览线路请填写建议时长'
      }
      if (this.difficultyInput.trim().length === 0 || this.suitableForInput.trim().length === 0 || this.spotsInput.trim().length === 0) {
        return '游览线路请填写难度、适宜人群和线路内容'
      }
    }
    if (this.selectedCategory === 'DINING') {
      if (this.diningTypeInput.trim().length === 0 || this.businessHoursInput.trim().length === 0 || this.addressInput.trim().length === 0) {
        return '餐饮娱乐请填写分类、营业时间和地址'
      }
      if (this.parseInteger(this.avgPriceInput) === undefined) {
        return '餐饮娱乐请填写合法人均价格'
      }
    }
    if (this.selectedCategory === 'PERFORMANCES') {
      if (this.locationInput.trim().length === 0 || this.showTimeInput.trim().length === 0 || this.teamInput.trim().length === 0 || this.venueInput.trim().length === 0) {
        return '演出团体请填写位置、演出时间、团队和场地'
      }
      if (this.parseInteger(this.priceInput) === undefined) {
        return '演出团体请填写合法票价'
      }
    }
    return ''
  }

  private buildRequest(): ResourceItemRequest {
    const request: ResourceItemRequest = {
      title: this.titleInput.trim(),
      description: this.descriptionInput.trim(),
      coverImageUrl: this.emptyToUndefined(this.coverImageUrlInput),
      online: this.onlineInput
    }
    if (this.selectedCategory === 'SCENIC_SPOTS') {
      request.subtitle = this.emptyToUndefined(this.scenicAreaInput)
      request.location = this.emptyToUndefined(this.locationInput)
      request.schedule = this.emptyToUndefined(this.openTimeInput)
      request.scenicArea = this.emptyToUndefined(this.scenicAreaInput)
      request.openTime = this.emptyToUndefined(this.openTimeInput)
      request.ticketPrice = this.parseInteger(this.ticketPriceInput)
      request.level = this.emptyToUndefined(this.levelInput)
      request.type = this.emptyToUndefined(this.scenicTypeInput)
      request.isFree = this.isFreeInput
      request.crowdHeat = this.parseInteger(this.crowdHeatInput)
      return request
    }
    if (this.selectedCategory === 'ROUTES') {
      request.subtitle = this.emptyToUndefined(this.suitableForInput)
      request.location = this.emptyToUndefined(this.spotsInput)
      request.schedule = this.emptyToUndefined(this.durationHoursInput)
      request.durationHours = this.parseInteger(this.durationHoursInput)
      request.difficulty = this.emptyToUndefined(this.difficultyInput)
      request.suitableFor = this.emptyToUndefined(this.suitableForInput)
      request.spots = this.emptyToUndefined(this.spotsInput)
      return request
    }
    if (this.selectedCategory === 'DINING') {
      request.subtitle = this.emptyToUndefined(this.diningTypeInput)
      request.location = this.emptyToUndefined(this.addressInput)
      request.schedule = this.emptyToUndefined(this.businessHoursInput)
      request.type = this.emptyToUndefined(this.diningTypeInput)
      request.avgPrice = this.parseInteger(this.avgPriceInput)
      request.businessHours = this.emptyToUndefined(this.businessHoursInput)
      request.address = this.emptyToUndefined(this.addressInput)
      request.recommendFood = this.emptyToUndefined(this.recommendFoodInput)
      request.distanceMeters = this.parseInteger(this.distanceMetersInput)
      request.isOpen = this.isOpenInput
      request.navLat = this.parseDouble(this.navLatInput)
      request.navLng = this.parseDouble(this.navLngInput)
      return request
    }
    request.subtitle = this.emptyToUndefined(this.teamInput)
    request.location = this.emptyToUndefined(this.locationInput)
    request.schedule = this.emptyToUndefined(this.showTimeInput)
    request.showTime = this.emptyToUndefined(this.showTimeInput)
    request.price = this.parseInteger(this.priceInput)
    request.team = this.emptyToUndefined(this.teamInput)
    request.venue = this.emptyToUndefined(this.venueInput)
    request.showDateTime = this.emptyToUndefined(this.showDateTimeInput)
    request.remainingTickets = this.parseInteger(this.remainingTicketsInput)
    request.ticketStatus = this.emptyToUndefined(this.ticketStatusInput)
    request.distanceMeters = this.parseInteger(this.distanceMetersInput)
    request.navLat = this.parseDouble(this.navLatInput)
    request.navLng = this.parseDouble(this.navLngInput)
    return request
  }

  private async saveForm(): Promise<void> {
    const validationMessage: string = this.validateCurrentForm()
    if (validationMessage.length > 0) {
      this.actionMessage = validationMessage
      return
    }
    this.saving = true
    this.errorMessage = ''
    try {
      const request: ResourceItemRequest = this.buildRequest()
      const basePath: string = `/api/resources/${this.categoryPath(this.selectedCategory)}`
      let savedId: string = ''
      if (this.editingId.length > 0) {
        const updated: ResourceItemResponse = await apiClient.put<ResourceItemRequest, ResourceItemResponse>(`${basePath}/${this.editingId}`, request)
        savedId = updated.id
        this.actionMessage = '资源信息已更新'
      } else {
        const created: ResourceItemResponse = await apiClient.post<ResourceItemRequest, ResourceItemResponse>(basePath, request)
        savedId = created.id
        this.actionMessage = '新资源已加入资源库'
      }
      this.screen = 'LIST'
      this.editingId = ''
      await this.loadItems(savedId)
    } catch (error) {
      if (error instanceof Error) {
        this.errorMessage = error.message
      } else {
        this.errorMessage = '保存资源失败，请稍后重试'
      }
    } finally {
      this.saving = false
    }
  }

  private async toggleOnline(item: ResourceItemResponse): Promise<void> {
    this.errorMessage = ''
    try {
      const actionPath: string = item.online ? 'offline' : 'online'
      await apiClient.post<Record<string, string>, ResourceItemResponse>(`/api/resources/${this.categoryPath(this.normalizeCategory(item.category))}/${item.id}/${actionPath}`, {})
      this.actionMessage = item.online ? '资源已下架' : '资源已上架'
      await this.loadItems(item.id)
    } catch (error) {
      if (error instanceof Error) {
        this.errorMessage = error.message
      } else {
        this.errorMessage = '更新资源状态失败，请稍后重试'
      }
    }
  }

  private async deleteItem(item: ResourceItemResponse): Promise<void> {
    this.errorMessage = ''
    try {
      await apiClient.delete<void>(`/api/resources/${this.categoryPath(this.normalizeCategory(item.category))}/${item.id}`)
      this.actionMessage = '资源已删除'
      await this.loadItems()
    } catch (error) {
      if (error instanceof Error) {
        this.errorMessage = error.message
      } else {
        this.errorMessage = '删除资源失败，请稍后重试'
      }
    }
  }

  private onlineBadgeText(item: ResourceItemResponse): string {
    return item.online ? '已上架' : '已下架'
  }

  private onlineBadgeBg(item: ResourceItemResponse): string {
    return item.online ? THEME_SUCCESS : THEME_TEXT_TERTIARY
  }

  private actionButtonText(item: ResourceItemResponse): string {
    return item.online ? '下架隐藏' : '重新上架'
  }

  private actionButtonColor(item: ResourceItemResponse): string {
    return item.online ? '#EA580C' : THEME_SUCCESS
  }

  private actionButtonBg(item: ResourceItemResponse): string {
    return item.online ? '#FFF4E6' : '#EAF8EF'
  }

  private cardBorderColor(item: ResourceItemResponse): string {
    return item.online ? '#F0F3F9' : '#D9E0EB'
  }

  private cardImageOpacity(item: ResourceItemResponse): number {
    return item.online ? 1 : 0.72
  }

  private displaySubtitle(item: ResourceItemResponse): string {
    if (this.selectedCategory === 'ROUTES') {
      return item.spots === null ? '' : item.spots
    }
    if (this.selectedCategory === 'DINING') {
      return item.address === null ? '' : item.address
    }
    if (this.selectedCategory === 'PERFORMANCES') {
      return item.venue === null ? '' : item.venue
    }
    return item.scenicArea === null ? '' : item.scenicArea
  }

  private displaySchedule(item: ResourceItemResponse): string {
    if (this.selectedCategory === 'ROUTES') {
      return item.durationHours === null ? '' : `建议时长：${item.durationHours} 小时`
    }
    if (this.selectedCategory === 'DINING') {
      return item.businessHours === null ? '' : item.businessHours
    }
    if (this.selectedCategory === 'PERFORMANCES') {
      return item.showTime === null ? '' : item.showTime
    }
    return item.openTime === null ? '' : item.openTime
  }

  private renderImageLabel(): string {
    if (this.selectedCategory === 'ROUTES') {
      return '官方线路'
    }
    if (this.selectedCategory === 'DINING') {
      return '餐饮娱乐'
    }
    if (this.selectedCategory === 'PERFORMANCES') {
      return '演出现场'
    }
    return '景区景点'
  }

  private showScenicFields(): boolean {
    return this.selectedCategory === 'SCENIC_SPOTS'
  }

  private showRouteFields(): boolean {
    return this.selectedCategory === 'ROUTES'
  }

  private showDiningFields(): boolean {
    return this.selectedCategory === 'DINING'
  }

  private showPerformanceFields(): boolean {
    return this.selectedCategory === 'PERFORMANCES'
  }

  @Builder
  private CategorySwitcher(): void {
    Row({ space: 10 }) {
      ForEach(this.categoryOptions, (item: ResourceCategoryOption) => {
        Button() {
          Column({ space: 10 }) {
            Text(item.icon)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.categoryIconColor(item))
              .textAlign(TextAlign.Center)
              .width(38)
              .height(38)
              .backgroundColor(this.categoryIconBg(item))
              .borderRadius(RADIUS_PILL)
            Text(item.title)
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.categoryButtonTextColor(item.key))
              .textAlign(TextAlign.Center)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .height(84)
        .padding({ left: 8, right: 8, top: 10, bottom: 10 })
        .borderRadius(22)
        .backgroundColor(this.categoryButtonBg(item.key))
        .shadow(this.selectedCategory === item.key ? SHADOW_PANEL : SHADOW_CARD)
        .scale({ x: this.categoryButtonScale(item.key), y: this.categoryButtonScale(item.key) })
        .onClick(() => this.switchCategory(item.key))
      }, (item: ResourceCategoryOption) => item.key)
    }
    .width('100%')
  }

  @Builder
  private SearchBar(): void {
    Row({ space: 10 }) {
      Text('⌕')
        .fontSize(15)
        .fontColor(THEME_TEXT_TERTIARY)
      TextInput({ placeholder: this.searchPlaceholder(), text: this.searchQuery })
        .placeholderColor(THEME_TEXT_TERTIARY)
        .backgroundColor(Color.Transparent)
        .fontSize(14)
        .layoutWeight(1)
        .onChange((value: string) => {
          this.searchQuery = value
        })
    }
    .width('100%')
    .height(48)
    .padding({ left: 16, right: 16 })
    .backgroundColor(THEME_SURFACE)
    .borderRadius(22)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private CoverBlock(item: ResourceItemResponse): void {
    Stack({ alignContent: Alignment.BottomStart }) {
      if (item.coverImageUrl !== null && item.coverImageUrl.length > 0) {
        Image(item.coverImageUrl)
          .width(100)
          .height(100)
          .borderRadius(22)
          .objectFit(ImageFit.Cover)
          .opacity(this.cardImageOpacity(item))
      } else {
        Column() {
          Text(this.currentCategoryOption().icon)
            .fontSize(24)
            .fontColor(this.currentCategoryOption().accentColor)
        }
        .width(100)
        .height(100)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.currentCategoryOption().accentBg)
        .borderRadius(22)
      }
      Text(this.onlineBadgeText(item))
        .fontSize(10)
        .fontColor('#FFFFFF')
        .padding({ left: 10, right: 10, top: 5, bottom: 5 })
        .backgroundColor(this.onlineBadgeBg(item))
        .borderRadius(RADIUS_PILL)
        .margin({ left: 8, top: 8, bottom: 8 })
    }
  }

  @Builder
  private ResourceCard(item: ResourceItemResponse): void {
    Column({ space: 14 }) {
      Row({ space: 14 }) {
        this.CoverBlock(item)
        Column({ space: 8 }) {
          Text(item.title)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(THEME_TEXT_PRIMARY)
            .width('100%')
            .maxLines(1)
          Row({ space: 8 }) {
            Text('📍')
              .fontSize(11)
            Text(this.displaySubtitle(item))
              .fontSize(12)
              .fontColor(THEME_TEXT_SECONDARY)
              .layoutWeight(1)
              .maxLines(2)
          }
          .width('100%')
          Row({ space: 8 }) {
            Text('🕒')
              .fontSize(11)
            Text(this.displaySchedule(item))
              .fontSize(12)
              .fontColor('#EA580C')
              .layoutWeight(1)
              .maxLines(2)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      Text(item.description)
        .fontSize(12)
        .fontColor(THEME_TEXT_SECONDARY)
        .lineHeight(19)
        .width('100%')

      Divider()
        .strokeWidth(1)
        .color('#EEF2F7')

      Row() {
        Text(item.id)
          .fontSize(11)
          .fontColor(THEME_TEXT_TERTIARY)
        Blank()
        Row({ space: 8 }) {
          Button(this.actionButtonText(item))
            .height(32)
            .padding({ left: 12, right: 12 })
            .borderRadius(RADIUS_PILL)
            .backgroundColor(this.actionButtonBg(item))
            .fontColor(this.actionButtonColor(item))
            .fontSize(11)
            .onClick(() => {
              this.toggleOnline(item)
            })
          Button('编辑')
            .height(32)
            .padding({ left: 12, right: 12 })
            .borderRadius(RADIUS_PILL)
            .backgroundColor(THEME_PRIMARY_SOFT)
            .fontColor(THEME_PRIMARY)
            .fontSize(11)
            .onClick(() => this.startEdit(item))
          Button('删除')
            .height(32)
            .padding({ left: 12, right: 12 })
            .borderRadius(RADIUS_PILL)
            .backgroundColor('#FFECEC')
            .fontColor(THEME_DANGER)
            .fontSize(11)
            .onClick(() => {
              this.deleteItem(item)
            })
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(15)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
    .border({ width: 1, color: this.cardBorderColor(item) })
    .opacity(item.online ? 1 : 0.94)
  }

  @Builder
  private EmptyState(): void {
    Column({ space: 8 }) {
      Text('暂无资源')
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(THEME_TEXT_PRIMARY)
      Text('当前分类下还没有匹配内容，可以直接新增并上架到游客端。')
        .fontSize(12)
        .fontColor(THEME_TEXT_SECONDARY)
        .lineHeight(19)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding({ left: 24, right: 24, top: 28, bottom: 28 })
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private ListView(): void {
    Column() {
      Scroll() {
        Column({ space: 16 }) {
          this.CategorySwitcher()
          this.SearchBar()

          if (this.errorMessage.length > 0) {
            Text(this.errorMessage)
              .fontSize(11)
              .fontColor(THEME_DANGER)
              .width('100%')
          } else if (this.actionMessage.length > 0) {
            Text(this.actionMessage)
              .fontSize(11)
              .fontColor(THEME_SUCCESS)
              .width('100%')
          }

          if (this.loading) {
            this.EmptyState()
          } else if (this.filteredItems().length === 0) {
            this.EmptyState()
          } else {
            Column({ space: 14 }) {
              ForEach(this.filteredItems(), (item: ResourceItemResponse) => {
                this.ResourceCard(item)
              }, (item: ResourceItemResponse) => item.id)
            }
            .width('100%')
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 18, bottom: 112 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      Button(this.createButtonText())
        .width('100%')
        .height(50)
        .margin({ left: 20, right: 20, bottom: 16 })
        .borderRadius(22)
        .backgroundColor(THEME_PRIMARY)
        .fontColor('#FFFFFF')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .shadow(SHADOW_PANEL)
        .onClick(() => this.startCreate())
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private FormHeader(): void {
    Row() {
      Column({ space: 4 }) {
        Text(this.editingId.length > 0 ? '编辑资源内容' : '新增资源内容')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
        Text(`${this.currentCategoryOption().title} · 平台端图文内容管理表单`)
          .fontSize(11)
          .fontColor(THEME_TEXT_SECONDARY)
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      Button('返回列表')
        .height(32)
        .padding({ left: 12, right: 12 })
        .borderRadius(RADIUS_PILL)
        .backgroundColor(THEME_PRIMARY_SOFT)
        .fontColor(THEME_PRIMARY)
        .fontSize(11)
        .onClick(() => this.cancelForm())
    }
    .width('100%')
  }

  @Builder
  private FormCategorySelector(): void {
    Row({ space: 10 }) {
      ForEach(this.categoryOptions, (item: ResourceCategoryOption) => {
        Button(item.shortTitle)
          .layoutWeight(1)
          .height(38)
          .borderRadius(RADIUS_PILL)
          .backgroundColor(this.selectedCategory === item.key ? THEME_PRIMARY : THEME_SURFACE_MUTED)
          .fontColor(this.selectedCategory === item.key ? '#FFFFFF' : THEME_TEXT_SECONDARY)
          .fontSize(11)
          .enabled(this.editingId.length === 0)
          .opacity(this.editingId.length === 0 ? 1 : 0.75)
          .onClick(() => this.switchCategory(item.key))
      }, (item: ResourceCategoryOption) => item.key)
    }
    .width('100%')
  }

  @Builder
  private FormField(label: string, placeholder: string, value: string, onChange: (value: string) => void): void {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(12)
        .fontColor(THEME_TEXT_SECONDARY)
        .width('100%')
      TextInput({ placeholder, text: value })
        .onChange(onChange)
        .height(44)
        .padding(12)
        .backgroundColor(THEME_SURFACE_MUTED)
        .borderRadius(RADIUS_PILL)
        .border({ width: 1, color: '#E7ECF3' })
    }
    .width('100%')
  }

  @Builder
  private DoubleField(leftLabel: string, leftPlaceholder: string, leftValue: string, leftOnChange: (value: string) => void,
    rightLabel: string, rightPlaceholder: string, rightValue: string, rightOnChange: (value: string) => void): void {
    Row({ space: 12 }) {
      Column({ space: 8 }) {
        Text(leftLabel)
          .fontSize(12)
          .fontColor(THEME_TEXT_SECONDARY)
          .width('100%')
        TextInput({ placeholder: leftPlaceholder, text: leftValue })
          .onChange(leftOnChange)
          .height(44)
          .padding(12)
          .backgroundColor(THEME_SURFACE_MUTED)
          .borderRadius(RADIUS_PILL)
          .border({ width: 1, color: '#E7ECF3' })
      }
      .layoutWeight(1)
      Column({ space: 8 }) {
        Text(rightLabel)
          .fontSize(12)
          .fontColor(THEME_TEXT_SECONDARY)
          .width('100%')
        TextInput({ placeholder: rightPlaceholder, text: rightValue })
          .onChange(rightOnChange)
          .height(44)
          .padding(12)
          .backgroundColor(THEME_SURFACE_MUTED)
          .borderRadius(RADIUS_PILL)
          .border({ width: 1, color: '#E7ECF3' })
      }
      .layoutWeight(1)
    }
    .width('100%')
  }

  @Builder
  private BooleanToggle(label: string, value: boolean, trueText: string, falseText: string, onToggle: (value: boolean) => void): void {
    Row() {
      Column({ space: 4 }) {
        Text(label)
          .fontSize(12)
          .fontColor(THEME_TEXT_SECONDARY)
        Text(value ? trueText : falseText)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(THEME_TEXT_PRIMARY)
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      Button(value ? trueText : falseText)
        .height(34)
        .padding({ left: 12, right: 12 })
        .borderRadius(RADIUS_PILL)
        .backgroundColor(value ? THEME_PRIMARY : THEME_SURFACE_MUTED)
        .fontColor(value ? '#FFFFFF' : THEME_TEXT_SECONDARY)
        .fontSize(11)
        .onClick(() => onToggle(!value))
    }
    .width('100%')
    .padding(12)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_MD)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private FormTextArea(): void {
    Column({ space: 8 }) {
      Text('资源简介')
        .fontSize(12)
        .fontColor(THEME_TEXT_SECONDARY)
        .width('100%')
      TextArea({ placeholder: '请输入资源简介与对游客端展示的说明文案', text: this.descriptionInput })
        .onChange((value: string) => {
          this.descriptionInput = value
        })
        .height(112)
        .padding(14)
        .backgroundColor(THEME_SURFACE_MUTED)
        .borderRadius(RADIUS_MD)
        .border({ width: 1, color: '#E7ECF3' })
    }
    .width('100%')
  }

  @Builder
  private CoverUploadCard(): void {
    Column({ space: 10 }) {
      Text('封面图')
        .fontSize(12)
        .fontColor(THEME_TEXT_SECONDARY)
        .width('100%')
      Column({ space: 8 }) {
        Text('填写封面图链接')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
        Text('本轮先接图片链接，后续再扩展为上传接口。')
          .fontSize(11)
          .fontColor(THEME_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .lineHeight(18)
      }
      .width('100%')
      .height(120)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(THEME_SURFACE_MUTED)
      .borderRadius(RADIUS_LG)
      .border({ width: 1, color: '#E7ECF3' })

      TextInput({ placeholder: '封面图链接（可选）', text: this.coverImageUrlInput })
        .onChange((value: string) => {
          this.coverImageUrlInput = value
        })
        .height(44)
        .padding(12)
        .backgroundColor(THEME_SURFACE)
        .borderRadius(RADIUS_PILL)
        .border({ width: 1, color: '#E7ECF3' })
    }
    .width('100%')
  }

  @Builder
  private ScenicFields(): void {
    Column({ space: 12 }) {
      this.FormField('景区分区', '如：北侧森林区', this.scenicAreaInput, (value: string) => {
        this.scenicAreaInput = value
      })
      this.FormField('景点位置', '如：景区北侧观景步道', this.locationInput, (value: string) => {
        this.locationInput = value
      })
      this.DoubleField('开放时间', '如：08:00 - 18:00', this.openTimeInput, (value: string) => {
        this.openTimeInput = value
      }, '票价（元）', '如：60', this.ticketPriceInput, (value: string) => {
        this.ticketPriceInput = value
      })
      this.DoubleField('景区等级', '如：AAAA', this.levelInput, (value: string) => {
        this.levelInput = value
      }, '景点类型', '如：森林观光', this.scenicTypeInput, (value: string) => {
        this.scenicTypeInput = value
      })
      this.DoubleField('客流热度', '如：73', this.crowdHeatInput, (value: string) => {
        this.crowdHeatInput = value
      }, '前端副标题', '可选，默认复用景区分区', this.scenicAreaInput, (value: string) => {
        this.scenicAreaInput = value
      })
      this.BooleanToggle('是否免费', this.isFreeInput, '免费开放', '收费景点', (value: boolean) => {
        this.isFreeInput = value
      })
    }
    .width('100%')
  }

  @Builder
  private RouteFields(): void {
    Column({ space: 12 }) {
      this.DoubleField('建议时长（小时）', '如：6', this.durationHoursInput, (value: string) => {
        this.durationHoursInput = value
      }, '线路难度', '如：MEDIUM', this.difficultyInput, (value: string) => {
        this.difficultyInput = value
      })
      this.FormField('适宜人群', '如：亲子家庭', this.suitableForInput, (value: string) => {
        this.suitableForInput = value
      })
      this.FormField('线路内容', '如：东大门 -> 湖畔 -> 游乐场 -> 美食城', this.spotsInput, (value: string) => {
        this.spotsInput = value
      })
    }
    .width('100%')
  }

  @Builder
  private DiningFields(): void {
    Column({ space: 12 }) {
      this.DoubleField('餐饮分类', '如：景观餐厅', this.diningTypeInput, (value: string) => {
        this.diningTypeInput = value
      }, '人均价格', '如：128', this.avgPriceInput, (value: string) => {
        this.avgPriceInput = value
      })
      this.FormField('营业时间', '如：11:00 - 22:00', this.businessHoursInput, (value: string) => {
        this.businessHoursInput = value
      })
      this.FormField('店铺地址', '如：东区观景台旁', this.addressInput, (value: string) => {
        this.addressInput = value
      })
      this.FormField('推荐菜 / 卖点', '如：炭烤牛排、海鲜烩饭', this.recommendFoodInput, (value: string) => {
        this.recommendFoodInput = value
      })
      this.DoubleField('距离（米）', '如：320', this.distanceMetersInput, (value: string) => {
        this.distanceMetersInput = value
      }, '经纬度（纬度）', '如：30.5728', this.navLatInput, (value: string) => {
        this.navLatInput = value
      })
      this.FormField('经纬度（经度）', '如：104.0668', this.navLngInput, (value: string) => {
        this.navLngInput = value
      })
      this.BooleanToggle('营业状态', this.isOpenInput, '正在营业', '暂未营业', (value: boolean) => {
        this.isOpenInput = value
      })
    }
    .width('100%')
  }

  @Builder
  private PerformanceFields(): void {
    Column({ space: 12 }) {
      this.DoubleField('演出位置', '如：中央水上剧场', this.locationInput, (value: string) => {
        this.locationInput = value
      }, '演出时间', '如：每日 19:30 - 21:00', this.showTimeInput, (value: string) => {
        this.showTimeInput = value
      })
      this.DoubleField('票价', '如：199', this.priceInput, (value: string) => {
        this.priceInput = value
      }, '演出团队', '如：幻梦森林演艺团', this.teamInput, (value: string) => {
        this.teamInput = value
      })
      this.FormField('演出场地', '如：中央水上剧场', this.venueInput, (value: string) => {
        this.venueInput = value
      })
      this.DoubleField('场次时间', '如：2026-05-01T19:30:00', this.showDateTimeInput, (value: string) => {
        this.showDateTimeInput = value
      }, '余票数量', '如：86', this.remainingTicketsInput, (value: string) => {
        this.remainingTicketsInput = value
      })
      this.DoubleField('票务状态', '如：AVAILABLE', this.ticketStatusInput, (value: string) => {
        this.ticketStatusInput = value
      }, '距离（米）', '如：580', this.distanceMetersInput, (value: string) => {
        this.distanceMetersInput = value
      })
      this.DoubleField('纬度', '如：30.5732', this.navLatInput, (value: string) => {
        this.navLatInput = value
      }, '经度', '如：104.0681', this.navLngInput, (value: string) => {
        this.navLngInput = value
      })
    }
    .width('100%')
  }

  @Builder
  private PublishSwitchCard(): void {
    Row() {
      Column({ space: 6 }) {
        Text('立即上架至游客端')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
        Text('关闭后保留在资源库中，仅平台管理员可见')
          .fontSize(11)
          .fontColor(THEME_TEXT_SECONDARY)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Button(this.onlineInput ? '已上架' : '先存为下架')
        .height(34)
        .padding({ left: 12, right: 12 })
        .borderRadius(RADIUS_PILL)
        .backgroundColor(this.onlineInput ? THEME_PRIMARY : THEME_SURFACE_MUTED)
        .fontColor(this.onlineInput ? '#FFFFFF' : THEME_TEXT_SECONDARY)
        .fontSize(11)
        .onClick(() => {
          this.onlineInput = !this.onlineInput
        })
    }
    .width('100%')
    .padding(14)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_MD)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private FormActions(): void {
    Row({ space: 12 }) {
      Button('取消')
        .layoutWeight(1)
        .height(44)
        .borderRadius(RADIUS_PILL)
        .backgroundColor(THEME_SURFACE_MUTED)
        .fontColor(THEME_TEXT_SECONDARY)
        .fontSize(12)
        .onClick(() => this.cancelForm())
      Button(this.saving ? '保存中...' : this.saveButtonText())
        .layoutWeight(1)
        .height(44)
        .borderRadius(RADIUS_PILL)
        .backgroundColor(THEME_PRIMARY)
        .fontColor('#FFFFFF')
        .fontSize(12)
        .enabled(!this.saving)
        .opacity(this.saving ? 0.7 : 1)
        .onClick(() => {
          this.saveForm()
        })
    }
    .width('100%')
  }

  @Builder
  private FormView(): void {
    Scroll() {
      Column({ space: 16 }) {
        this.FormHeader()
        this.CoverUploadCard()
        this.FormCategorySelector()
        this.FormField('标题名称', '请输入资源标题', this.titleInput, (value: string) => {
          this.titleInput = value
        })
        if (this.showScenicFields()) {
          this.ScenicFields()
        } else if (this.showRouteFields()) {
          this.RouteFields()
        } else if (this.showDiningFields()) {
          this.DiningFields()
        } else {
          this.PerformanceFields()
        }
        this.FormTextArea()
        this.PublishSwitchCard()
        if (this.errorMessage.length > 0) {
          Text(this.errorMessage)
            .fontSize(11)
            .fontColor(THEME_DANGER)
            .width('100%')
        } else if (this.actionMessage.length > 0) {
          Text(this.actionMessage)
            .fontSize(11)
            .fontColor(THEME_SUCCESS)
            .width('100%')
        }
        this.FormActions()
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 18, bottom: 30 })
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
  }

  build() {
    Column() {
      if (this.screen === 'LIST') {
        this.ListView()
      } else {
        this.FormView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(THEME_PAGE_BG)
  }
}
