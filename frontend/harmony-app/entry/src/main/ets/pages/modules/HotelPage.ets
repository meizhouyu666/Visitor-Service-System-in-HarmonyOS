import { HotelAdminRequest, HotelResponse } from '../../common/model/ApiModels'
import { apiClient } from '../../common/network/ApiClient'
import {
  RADIUS_LG,
  RADIUS_MD,
  RADIUS_PILL,
  SHADOW_CARD,
  SHADOW_PANEL,
  THEME_BORDER_SOFT,
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

export type HotelMode = 'visitor' | 'manager' | 'admin'

interface HotelRoomItem {
  id: string
  name: string
  totalRooms: number
  availableRooms: number
  price: number
  imageUrl: string
}

@Component
export struct HotelPage {
  @Prop mode: HotelMode = 'visitor'

  @State private keyword: string = ''
  @State private items: HotelResponse[] = []
  @State private selectedId: string = ''
  @State private selectedSnapshot: HotelResponse = {
    id: '',
    name: '',
    address: '',
    star: 0,
    price: 0,
    phone: '',
    score: 0,
    hasBreakfast: false,
    facility: '',
    introduction: '',
    availabilityStatus: 'AVAILABLE',
    coverImageUrl: ''
  }

  @State private loading: boolean = false
  @State private errorMessage: string = ''
  @State private actionMessage: string = ''
  @State private syncingRooms: boolean = false

  @State private formName: string = ''
  @State private formAddress: string = ''
  @State private formStar: string = '4'
  @State private formPrice: string = '399'
  @State private formPhone: string = ''
  @State private formScore: string = '4.5'
  @State private formHasBreakfast: boolean = true
  @State private formFacility: string = ''
  @State private formIntroduction: string = ''
  @State private formAvailability: string = 'AVAILABLE'
  @State private formCoverImageUrl: string = ''
  @State private roomItems: HotelRoomItem[] = [
    {
      id: 'deluxe-king',
      name: '豪华大床房',
      totalRooms: 50,
      availableRooms: 12,
      price: 599,
      imageUrl: 'https://images.unsplash.com/photo-1590490359683-658d3d23f972?auto=format&fit=crop&w=400&q=80'
    },
    {
      id: 'standard-twin',
      name: '双人标准间',
      totalRooms: 80,
      availableRooms: 5,
      price: 450,
      imageUrl: 'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?auto=format&fit=crop&w=400&q=80'
    },
    {
      id: 'family-suite',
      name: '全景家庭套房',
      totalRooms: 15,
      availableRooms: 0,
      price: 1299,
      imageUrl: 'https://images.unsplash.com/photo-1591088398332-8a7791972843?auto=format&fit=crop&w=400&q=80'
    }
  ]

  async aboutToAppear(): Promise<void> {
    await this.loadHotels()
  }

  private title(): string {
    if (this.mode === 'manager') {
      return '酒店管理视图'
    }
    if (this.mode === 'admin') {
      return '酒店管理（管理员）'
    }
    return '酒店查询'
  }

  private canManage(): boolean {
    return this.mode === 'manager' || this.mode === 'admin'
  }

  private resolveListPath(): string {
    const encodedKeyword: string = encodeURIComponent(this.keyword.trim())
    const query: string = encodedKeyword.length > 0 ? `?keyword=${encodedKeyword}` : ''
    if (this.canManage()) {
      return `/api/hotels/admin${query}`
    }
    return `/api/query/hotels${query}`
  }

  private async loadHotels(preferredId?: string): Promise<void> {
    this.loading = true
    this.errorMessage = ''
    try {
      const list: HotelResponse[] = await apiClient.get<HotelResponse[]>(this.resolveListPath())
      this.items = [...list]
      this.syncSelection(preferredId)
      this.actionMessage = ''
    } catch (_error) {
      this.errorMessage = '加载酒店数据失败，请稍后重试'
    } finally {
      this.loading = false
    }
  }

  private syncSelection(preferredId?: string): void {
    if (this.items.length === 0) {
      this.selectedId = ''
      this.selectedSnapshot = {
        id: '',
        name: '',
        address: '',
        star: 0,
        price: 0,
        phone: '',
        score: 0,
        hasBreakfast: false,
        facility: '',
        introduction: '',
        availabilityStatus: 'AVAILABLE',
        coverImageUrl: ''
      }
      this.clearForm()
      return
    }

    const candidate: string = preferredId !== undefined && preferredId.length > 0 ? preferredId : this.selectedId
    const target: HotelResponse | undefined = this.items.find((item: HotelResponse) => item.id === candidate)

    if (target !== undefined) {
      this.selectedId = target.id
      this.fillForm(target)
      return
    }

    this.selectedId = this.items[0].id
    this.fillForm(this.items[0])
  }

  private fillForm(item: HotelResponse): void {
    this.selectedSnapshot = {
      id: item.id,
      name: item.name,
      address: item.address,
      star: item.star,
      price: item.price,
      phone: item.phone,
      score: item.score,
      hasBreakfast: item.hasBreakfast,
      facility: item.facility,
      introduction: item.introduction,
      availabilityStatus: item.availabilityStatus,
      coverImageUrl: item.coverImageUrl
    }
    this.formName = item.name
    this.formAddress = item.address
    this.formStar = `${item.star}`
    this.formPrice = `${item.price}`
    this.formPhone = item.phone
    this.formScore = `${item.score}`
    this.formHasBreakfast = item.hasBreakfast
    this.formFacility = item.facility
    this.formIntroduction = item.introduction
    this.formAvailability = item.availabilityStatus ?? 'AVAILABLE'
    this.formCoverImageUrl = item.coverImageUrl ?? ''
  }

  private clearForm(): void {
    this.formName = ''
    this.formAddress = ''
    this.formStar = '4'
    this.formPrice = '399'
    this.formPhone = ''
    this.formScore = '4.5'
    this.formHasBreakfast = true
    this.formFacility = ''
    this.formIntroduction = ''
    this.formAvailability = 'AVAILABLE'
    this.formCoverImageUrl = ''
  }

  private onSelect(item: HotelResponse): void {
    this.selectedId = item.id
    this.fillForm(item)
    this.actionMessage = ''
  }

  private parseInteger(value: string, fallback: number): number {
    const parsed: number = Number(value)
    if (Number.isFinite(parsed)) {
      return Math.trunc(parsed)
    }
    return fallback
  }

  private parseDecimal(value: string, fallback: number): number {
    const parsed: number = Number(value)
    if (Number.isFinite(parsed)) {
      return parsed
    }
    return fallback
  }

  private buildRequest(): HotelAdminRequest | null {
    const name: string = this.formName.trim()
    const address: string = this.formAddress.trim()
    const phone: string = this.formPhone.trim()
    const facility: string = this.formFacility.trim()
    const introduction: string = this.formIntroduction.trim()

    if (name.length === 0 || address.length === 0 || phone.length === 0 || facility.length === 0 || introduction.length === 0) {
      this.errorMessage = '请完整填写酒店基础信息'
      return null
    }

    const star: number = this.parseInteger(this.formStar, -1)
    const price: number = this.parseInteger(this.formPrice, -1)
    const score: number = this.parseDecimal(this.formScore, -1)

    if (star < 1 || star > 5) {
      this.errorMessage = '酒店星级必须在 1-5 之间'
      return null
    }
    if (price < 0) {
      this.errorMessage = '酒店价格不能小于 0'
      return null
    }
    if (score < 0 || score > 5) {
      this.errorMessage = '酒店评分必须在 0-5 之间'
      return null
    }

    const availability: string = this.formAvailability.trim().toUpperCase()
    if (availability.length > 0 && availability !== 'AVAILABLE' && availability !== 'LIMITED' && availability !== 'BUSY' && availability !== 'FULL') {
      this.errorMessage = '房态仅支持 AVAILABLE / LIMITED / BUSY / FULL'
      return null
    }

    const coverImageUrl: string = this.formCoverImageUrl.trim()

    return {
      name,
      address,
      star,
      price,
      phone,
      score,
      hasBreakfast: this.formHasBreakfast,
      facility,
      introduction,
      availabilityStatus: availability.length > 0 ? availability : 'AVAILABLE',
      coverImageUrl: coverImageUrl.length > 0 ? coverImageUrl : undefined
    }
  }

  private async createHotel(): Promise<void> {
    if (!this.canManage()) {
      return
    }
    const payload: HotelAdminRequest | null = this.buildRequest()
    if (payload === null) {
      return
    }

    this.loading = true
    this.errorMessage = ''
    this.actionMessage = ''
    try {
      const created: HotelResponse = await apiClient.post<HotelAdminRequest, HotelResponse>('/api/hotels/admin', payload)
      this.actionMessage = '新增酒店成功'
      await this.loadHotels(created.id)
    } catch (_error) {
      this.errorMessage = '新增酒店失败，请稍后重试'
    } finally {
      this.loading = false
    }
  }

  private async updateHotel(): Promise<void> {
    if (!this.canManage()) {
      return
    }
    if (this.selectedId.length === 0) {
      this.errorMessage = '请先选择要编辑的酒店'
      return
    }

    const payload: HotelAdminRequest | null = this.buildRequest()
    if (payload === null) {
      return
    }

    this.loading = true
    this.errorMessage = ''
    this.actionMessage = ''
    try {
      await apiClient.put<HotelAdminRequest, HotelResponse>(`/api/hotels/admin/${this.selectedId}`, payload)
      this.actionMessage = '酒店信息已更新'
      await this.loadHotels(this.selectedId)
    } catch (_error) {
      this.errorMessage = '更新酒店失败，请稍后重试'
    } finally {
      this.loading = false
    }
  }

  private async deleteHotel(): Promise<void> {
    if (!this.canManage()) {
      return
    }
    if (this.selectedId.length === 0) {
      this.errorMessage = '请先选择要删除的酒店'
      return
    }

    this.loading = true
    this.errorMessage = ''
    this.actionMessage = ''
    try {
      await apiClient.delete<Record<string, string>>(`/api/hotels/admin/${this.selectedId}`)
      this.actionMessage = '酒店已删除'
      await this.loadHotels()
    } catch (_error) {
      this.errorMessage = '删除酒店失败，请稍后重试'
    } finally {
      this.loading = false
    }
  }

  private resolveCoverImage(url: string | undefined, index: number): string {
    if (url !== undefined && url.length > 0 && (url.startsWith('http://') || url.startsWith('https://'))) {
      return url
    }

    if (url === 'hotel_cover_a') {
      return 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1200&q=80'
    }
    if (url === 'hotel_cover_b') {
      return 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?auto=format&fit=crop&w=1200&q=80'
    }

    if (index % 3 === 0) {
      return 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1200&q=80'
    }
    if (index % 3 === 1) {
      return 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?auto=format&fit=crop&w=1200&q=80'
    }
    return 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=1200&q=80'
  }

  private selectedCoverImage(): string {
    if (this.selectedId.length === 0) {
      return this.resolveCoverImage(undefined, 0)
    }
    const index: number = this.items.findIndex((item: HotelResponse) => item.id === this.selectedId)
    const safeIndex: number = index < 0 ? 0 : index
    return this.resolveCoverImage(this.selectedSnapshot.coverImageUrl, safeIndex)
  }

  private availabilityLabel(status: string | undefined): string {
    const safe: string = (status ?? 'AVAILABLE').toUpperCase()
    if (safe === 'BUSY') {
      return '房态：紧张'
    }
    if (safe === 'LIMITED') {
      return '房态：有限'
    }
    if (safe === 'FULL') {
      return '房态：满房'
    }
    return '房态：可预订'
  }

  private workspaceHotelName(): string {
    return this.selectedSnapshot.name.length > 0 ? this.selectedSnapshot.name : '云端国际大酒店'
  }

  private workspaceStarText(): string {
    const score: number = this.selectedSnapshot.score > 0 ? this.selectedSnapshot.score : 4.8
    return `星级酒店    星级：${score}`
  }

  private totalAvailableRooms(): number {
    let total: number = 0
    this.roomItems.forEach((item: HotelRoomItem) => {
      total += item.availableRooms
    })
    return total
  }

  private totalRoomCount(): number {
    let total: number = 0
    this.roomItems.forEach((item: HotelRoomItem) => {
      total += item.totalRooms
    })
    return total
  }

  private roomStatusLabel(item: HotelRoomItem): string {
    if (item.availableRooms <= 0) {
      return '满房'
    }
    if (item.availableRooms <= Math.ceil(item.totalRooms * 0.2)) {
      return '紧张'
    }
    return '充足'
  }

  private roomStatusColor(item: HotelRoomItem): string {
    const label: string = this.roomStatusLabel(item)
    if (label === '满房') {
      return THEME_TEXT_TERTIARY
    }
    if (label === '紧张') {
      return THEME_WARNING
    }
    return THEME_SUCCESS
  }

  private roomStatusBg(item: HotelRoomItem): string {
    const label: string = this.roomStatusLabel(item)
    if (label === '满房') {
      return THEME_SURFACE_MUTED
    }
    if (label === '紧张') {
      return '#FFF4E6'
    }
    return '#EAF8EF'
  }

  private deriveHotelAvailability(): string {
    const available: number = this.totalAvailableRooms()
    const total: number = this.totalRoomCount()
    if (available <= 0) {
      return 'FULL'
    }
    if (available <= Math.ceil(total * 0.2)) {
      return 'BUSY'
    }
    return 'AVAILABLE'
  }

  private changeRoomAvailable(id: string, delta: number): void {
    this.roomItems = this.roomItems.map((item: HotelRoomItem) => {
      if (item.id !== id) {
        return item
      }
      const nextValue: number = Math.max(0, Math.min(item.totalRooms, item.availableRooms + delta))
      const nextItem: HotelRoomItem = {
        id: item.id,
        name: item.name,
        totalRooms: item.totalRooms,
        availableRooms: nextValue,
        price: item.price,
        imageUrl: item.imageUrl
      }
      return nextItem
    })
    this.actionMessage = ''
  }

  private buildRoomSyncRequest(): HotelAdminRequest | null {
    if (this.selectedId.length === 0) {
      this.errorMessage = '未找到当前酒店，请先确认酒店账号已绑定酒店'
      return null
    }
    return {
      name: this.selectedSnapshot.name,
      address: this.selectedSnapshot.address,
      star: this.selectedSnapshot.star,
      price: this.selectedSnapshot.price,
      phone: this.selectedSnapshot.phone,
      score: this.selectedSnapshot.score,
      hasBreakfast: this.selectedSnapshot.hasBreakfast,
      facility: this.selectedSnapshot.facility,
      introduction: this.selectedSnapshot.introduction,
      availabilityStatus: this.deriveHotelAvailability(),
      coverImageUrl: this.selectedSnapshot.coverImageUrl
    }
  }

  private async syncRoomStatus(): Promise<void> {
    const payload: HotelAdminRequest | null = this.buildRoomSyncRequest()
    if (payload === null) {
      return
    }
    this.syncingRooms = true
    this.errorMessage = ''
    this.actionMessage = ''
    try {
      await apiClient.put<HotelAdminRequest, HotelResponse>(`/api/hotels/admin/${this.selectedId}`, payload)
      this.formAvailability = payload.availabilityStatus ?? 'AVAILABLE'
      await this.loadHotels(this.selectedId)
      this.actionMessage = '实时房态已同步至平台'
    } catch (_error) {
      this.errorMessage = '同步房态失败，请稍后重试'
    } finally {
      this.syncingRooms = false
    }
  }

  @Builder
  private HotelManagerWorkspace(): void {
    Column() {
      Scroll() {
        Column({ space: 18 }) {
          this.ManagerHeader()
          this.ManagerHeroCard()
          this.ManagerTipCard()
          this.RoomEntrySection()
        }
        .padding({ left: 16, right: 16, top: 16, bottom: 96 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      Column({ space: 8 }) {
        if (this.actionMessage.length > 0) {
          Text(this.actionMessage)
            .fontSize(12)
            .fontColor(THEME_SUCCESS)
        }
        if (this.errorMessage.length > 0) {
          Text(this.errorMessage)
            .fontSize(12)
            .fontColor(THEME_DANGER)
        }
        Button(this.syncingRooms ? '同步中...' : '一键同步实时房态至平台')
          .enabled(!this.syncingRooms && this.selectedId.length > 0)
          .height(56)
          .width('100%')
          .borderRadius(RADIUS_MD)
          .backgroundColor(THEME_PRIMARY)
          .fontColor(Color.White)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .onClick(() => this.syncRoomStatus())
      }
      .padding({ left: 16, right: 16, top: 12, bottom: 20 })
      .backgroundColor(THEME_PAGE_BG)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(THEME_PAGE_BG)
  }

  @Builder
  private ManagerHeader(): void {
    Row() {
      Row({ space: 12 }) {
        Text('店')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_PRIMARY)
          .textAlign(TextAlign.Center)
          .width(42)
          .height(42)
          .backgroundColor(THEME_PRIMARY_SOFT)
          .borderRadius(RADIUS_PILL)
        Column({ space: 3 }) {
          Text('酒店管理中心')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(THEME_TEXT_PRIMARY)
          Text('本酒店房态同步平台')
            .fontSize(12)
            .fontColor(THEME_TEXT_TERTIARY)
        }
        .alignItems(HorizontalAlign.Start)
      }
      Blank()
      Text('商户端')
        .fontSize(12)
        .fontColor(THEME_PRIMARY)
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor(THEME_PRIMARY_SOFT)
        .borderRadius(RADIUS_PILL)
    }
    .width('100%')
    .padding(18)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private ManagerHeroCard(): void {
    Column({ space: 22 }) {
      Row() {
        Column({ space: 8 }) {
          Text(this.workspaceHotelName())
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
          Text(this.workspaceStarText())
            .fontSize(12)
            .fontColor('#DCEBFF')
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        Text('房态')
          .fontSize(12)
          .fontColor('#DCEBFF')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor('#248BFF')
          .borderRadius(RADIUS_PILL)
      }
      .width('100%')

      Row() {
        Column({ space: 6 }) {
          Text('当前总剩余可用客房')
            .fontSize(12)
            .fontColor('#DCEBFF')
          Row({ space: 6 }) {
            Text(`${this.totalAvailableRooms()}`)
              .fontSize(34)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
            Text(`/ ${this.totalRoomCount()} 间`)
              .fontSize(15)
              .fontColor('#DCEBFF')
          }
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        Column({ space: 6 }) {
          Text('上次同步平台')
            .fontSize(12)
            .fontColor('#DCEBFF')
          Text('10:30 AM')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#248BFF')
      .borderRadius(RADIUS_MD)
    }
    .padding(22)
    .backgroundColor(THEME_PRIMARY)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_PANEL)
  }

  @Builder
  private ManagerTipCard(): void {
    Text('请及时更新各房型剩余数量，您的房态数据将直接影响平台对游客的导流推荐策略。')
      .fontSize(12)
      .lineHeight(20)
      .fontColor(THEME_PRIMARY)
      .padding(16)
      .width('100%')
      .backgroundColor('#EAF2FF')
      .borderRadius(RADIUS_MD)
  }

  @Builder
  private RoomEntrySection(): void {
    Column({ space: 14 }) {
      Column({ space: 4 }) {
        Text('房态实时录入')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
        Text('只维护本酒店房型数据，不展示其他酒店信息')
          .fontSize(12)
          .fontColor(THEME_TEXT_TERTIARY)
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')

      ForEach(this.roomItems, (item: HotelRoomItem) => {
        this.RoomTypeCard(item)
      }, (item: HotelRoomItem) => item.id)
    }
    .width('100%')
  }

  @Builder
  private RoomTypeCard(item: HotelRoomItem): void {
    Column({ space: 16 }) {
      Row({ space: 14 }) {
        Image(item.imageUrl)
          .width(82)
          .height(82)
          .borderRadius(RADIUS_MD)
          .objectFit(ImageFit.Cover)

        Column({ space: 12 }) {
          Row() {
            Text(item.name)
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor(THEME_TEXT_PRIMARY)
              .layoutWeight(1)
            Text(`¥${item.price}/晚`)
              .fontSize(12)
              .fontColor(THEME_TEXT_SECONDARY)
          }
          .width('100%')

          Row({ space: 8 }) {
            Text(this.roomStatusLabel(item))
              .fontSize(11)
              .fontColor(this.roomStatusColor(item))
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor(this.roomStatusBg(item))
              .borderRadius(RADIUS_PILL)
            Text(`总房量 ${item.totalRooms} 间`)
              .fontSize(12)
              .fontColor(THEME_TEXT_TERTIARY)
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }

      Blank()
        .height(1)
        .width('100%')
        .backgroundColor(THEME_SURFACE_MUTED)

      Row() {
        Text('调整剩余空房数')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(THEME_TEXT_PRIMARY)
        Blank()
        this.StepperButton('－', item.id, -1, item.availableRooms <= 0)
        Text(`${item.availableRooms}`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
          .textAlign(TextAlign.Center)
          .width(42)
        this.StepperButton('＋', item.id, 1, item.availableRooms >= item.totalRooms)
      }
      .width('100%')
    }
    .padding(16)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private StepperButton(label: string, roomId: string, delta: number, disabled: boolean): void {
    Button(label)
      .enabled(!disabled)
      .width(36)
      .height(36)
      .borderRadius(RADIUS_PILL)
      .backgroundColor(disabled ? THEME_SURFACE_MUTED : THEME_PRIMARY_SOFT)
      .fontColor(disabled ? THEME_TEXT_TERTIARY : THEME_PRIMARY)
      .fontSize(18)
      .onClick(() => this.changeRoomAvailable(roomId, delta))
  }

  @Builder
  private Header(): void {
    Column({ space: 8 }) {
      Text(this.title()).fontSize(20).fontWeight(FontWeight.Medium).fontColor(THEME_TEXT_PRIMARY)
      Row({ space: 8 }) {
        TextInput({ placeholder: '按酒店名或区域搜索', text: this.keyword })
          .onChange((value: string) => {
            this.keyword = value
          })
          .layoutWeight(1)
          .backgroundColor(THEME_SURFACE)
          .border({ width: 1, color: THEME_BORDER_SOFT })
          .borderRadius(RADIUS_MD)
          .padding(10)
        Button('查询')
          .enabled(!this.loading)
          .onClick(() => this.loadHotels())
          .backgroundColor(THEME_PRIMARY)
          .fontColor(Color.White)
          .borderRadius(RADIUS_MD)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding(12)
    .backgroundColor(THEME_SURFACE_MUTED)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private ManagerPanel(): void {
    if (this.canManage()) {
      Column({ space: 8 }) {
        Text('酒店管理操作').fontSize(16).fontWeight(FontWeight.Medium).fontColor(THEME_TEXT_PRIMARY)

        Row({ space: 8 }) {
          TextInput({ placeholder: '酒店名称', text: this.formName })
            .onChange((value: string) => {
              this.formName = value
            })
            .layoutWeight(1)
            .backgroundColor(THEME_SURFACE)
            .border({ width: 1, color: THEME_BORDER_SOFT })
            .borderRadius(RADIUS_MD)
            .padding(10)
          TextInput({ placeholder: '酒店地址', text: this.formAddress })
            .onChange((value: string) => {
              this.formAddress = value
            })
            .layoutWeight(1)
            .backgroundColor(THEME_SURFACE)
            .border({ width: 1, color: THEME_BORDER_SOFT })
            .borderRadius(RADIUS_MD)
            .padding(10)
        }

        Row({ space: 8 }) {
          TextInput({ placeholder: '星级 1-5', text: this.formStar })
            .onChange((value: string) => {
              this.formStar = value
            })
            .layoutWeight(1)
            .backgroundColor(THEME_SURFACE)
            .border({ width: 1, color: THEME_BORDER_SOFT })
            .borderRadius(RADIUS_MD)
            .padding(10)
          TextInput({ placeholder: '价格', text: this.formPrice })
            .onChange((value: string) => {
              this.formPrice = value
            })
            .layoutWeight(1)
            .backgroundColor(THEME_SURFACE)
            .border({ width: 1, color: THEME_BORDER_SOFT })
            .borderRadius(RADIUS_MD)
            .padding(10)
          TextInput({ placeholder: '评分 0-5', text: this.formScore })
            .onChange((value: string) => {
              this.formScore = value
            })
            .layoutWeight(1)
            .backgroundColor(THEME_SURFACE)
            .border({ width: 1, color: THEME_BORDER_SOFT })
            .borderRadius(RADIUS_MD)
            .padding(10)
        }

        Row({ space: 8 }) {
          TextInput({ placeholder: '联系电话', text: this.formPhone })
            .onChange((value: string) => {
              this.formPhone = value
            })
            .layoutWeight(1)
            .backgroundColor(THEME_SURFACE)
            .border({ width: 1, color: THEME_BORDER_SOFT })
            .borderRadius(RADIUS_MD)
            .padding(10)
          TextInput({ placeholder: '房态 AVAILABLE/LIMITED/BUSY/FULL', text: this.formAvailability })
            .onChange((value: string) => {
              this.formAvailability = value
            })
            .layoutWeight(1)
            .backgroundColor(THEME_SURFACE)
            .border({ width: 1, color: THEME_BORDER_SOFT })
            .borderRadius(RADIUS_MD)
            .padding(10)
        }

        TextInput({ placeholder: '封面图 URL（可选）', text: this.formCoverImageUrl })
          .onChange((value: string) => {
            this.formCoverImageUrl = value
          })
          .backgroundColor(THEME_SURFACE)
          .border({ width: 1, color: THEME_BORDER_SOFT })
          .borderRadius(RADIUS_MD)
          .padding(10)

        Row({ space: 8 }) {
          Text('早餐')
            .fontSize(12)
            .fontColor(THEME_TEXT_SECONDARY)
            .padding({ left: 8 })
          Button(this.formHasBreakfast ? '含早' : '不含早')
            .onClick(() => {
              this.formHasBreakfast = !this.formHasBreakfast
            })
            .height(32)
            .borderRadius(RADIUS_PILL)
            .backgroundColor(this.formHasBreakfast ? THEME_PRIMARY_SOFT : '#EEF3FA')
            .fontColor(this.formHasBreakfast ? THEME_PRIMARY : THEME_TEXT_SECONDARY)
        }

        TextArea({ placeholder: '酒店设施描述', text: this.formFacility })
          .onChange((value: string) => {
            this.formFacility = value
          })
          .height(70)
          .backgroundColor(THEME_SURFACE)
          .border({ width: 1, color: THEME_BORDER_SOFT })
          .borderRadius(RADIUS_MD)
          .padding(10)

        TextArea({ placeholder: '酒店简介', text: this.formIntroduction })
          .onChange((value: string) => {
            this.formIntroduction = value
          })
          .height(90)
          .backgroundColor(THEME_SURFACE)
          .border({ width: 1, color: THEME_BORDER_SOFT })
          .borderRadius(RADIUS_MD)
          .padding(10)

        Row({ space: 8 }) {
          Button('新增')
            .enabled(!this.loading)
            .onClick(() => this.createHotel())
            .layoutWeight(1)
            .height(40)
            .borderRadius(RADIUS_PILL)
            .backgroundColor(THEME_PRIMARY)
            .fontColor(Color.White)

          Button('保存修改')
            .enabled(!this.loading && this.selectedId.length > 0)
            .onClick(() => this.updateHotel())
            .layoutWeight(1)
            .height(40)
            .borderRadius(RADIUS_PILL)
            .backgroundColor(THEME_PRIMARY_SOFT)
            .fontColor(THEME_PRIMARY)

          Button('删除')
            .enabled(!this.loading && this.selectedId.length > 0)
            .onClick(() => this.deleteHotel())
            .layoutWeight(1)
            .height(40)
            .borderRadius(RADIUS_PILL)
            .backgroundColor('#FEE4E2')
            .fontColor(THEME_DANGER)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .padding(12)
      .backgroundColor(THEME_SURFACE_MUTED)
      .borderRadius(RADIUS_LG)
      .shadow(SHADOW_CARD)
    }
  }

  @Builder
  private HotelListAndDetail(): void {
    if (this.loading) {
      Text('加载中...').fontColor(THEME_TEXT_SECONDARY).padding(20)
    } else if (this.errorMessage.length > 0) {
      Column({ space: 8 }) {
        Text(this.errorMessage).fontColor(THEME_DANGER).fontSize(12)
        Button('重试')
          .onClick(() => this.loadHotels())
          .backgroundColor(THEME_PRIMARY)
          .fontColor(Color.White)
          .borderRadius(RADIUS_MD)
      }
      .padding(20)
    } else if (this.items.length === 0) {
      Text('暂无酒店数据').fontColor(THEME_TEXT_SECONDARY).padding(20)
    } else {
      Row({ space: 10 }) {
        List({ space: 8 }) {
          ForEach(this.items, (item: HotelResponse, index: number) => {
            ListItem() {
              Column({ space: 6 }) {
                Image(this.resolveCoverImage(item.coverImageUrl, index))
                  .width('100%')
                  .height(100)
                  .borderRadius(RADIUS_MD)
                  .objectFit(ImageFit.Cover)

                Text(item.name).fontSize(15).fontWeight(FontWeight.Medium).fontColor(THEME_TEXT_PRIMARY)
                Text(`★ ${item.star} 星 · ¥${item.price}`).fontSize(12).fontColor(THEME_TEXT_SECONDARY)
                Text(item.address).fontSize(12).fontColor(THEME_TEXT_SECONDARY).maxLines(1)
              }
              .alignItems(HorizontalAlign.Start)
              .padding(10)
              .backgroundColor(this.selectedId === item.id ? THEME_PRIMARY_SOFT : THEME_SURFACE)
              .borderRadius(RADIUS_MD)
              .shadow(SHADOW_CARD)
              .onClick(() => this.onSelect(item))
            }
          }, (item: HotelResponse) => item.id)
        }
        .layoutWeight(1)

        if (this.selectedId.length > 0) {
          Column({ space: 8 }) {
            Image(this.selectedCoverImage())
              .width('100%')
              .height(140)
              .borderRadius(RADIUS_MD)
              .objectFit(ImageFit.Cover)

            Text(this.selectedSnapshot.name).fontSize(16).fontWeight(FontWeight.Bold).fontColor(THEME_TEXT_PRIMARY)
            Text(this.availabilityLabel(this.selectedSnapshot.availabilityStatus)).fontSize(12).fontColor(THEME_SUCCESS)
            Text(`地址：${this.selectedSnapshot.address}`).fontSize(12).fontColor(THEME_TEXT_SECONDARY)
            Text(`联系电话：${this.selectedSnapshot.phone}`).fontSize(12).fontColor(THEME_TEXT_SECONDARY)
            Text(`评分：${this.selectedSnapshot.score}`).fontSize(12).fontColor(THEME_TEXT_SECONDARY)
            Text(`早餐：${this.selectedSnapshot.hasBreakfast ? '含早' : '不含早'}`).fontSize(12).fontColor(THEME_TEXT_SECONDARY)
            Text(`设施：${this.selectedSnapshot.facility}`).fontSize(12).fontColor(THEME_TEXT_SECONDARY).maxLines(2)
            Text(this.selectedSnapshot.introduction).fontSize(12).fontColor(THEME_TEXT_TERTIARY).maxLines(5)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          .padding(12)
          .backgroundColor(THEME_SURFACE)
          .borderRadius(RADIUS_LG)
          .shadow(SHADOW_CARD)
        }
      }
      .layoutWeight(1)
      .width('100%')
    }
  }

  build() {
    if (this.mode === 'manager') {
      this.HotelManagerWorkspace()
    } else {
      Column({ space: 10 }) {
        this.Header()

        if (this.actionMessage.length > 0) {
          Text(this.actionMessage)
            .fontSize(12)
            .fontColor(THEME_SUCCESS)
            .padding({ left: 6 })
        }

        this.ManagerPanel()
        this.HotelListAndDetail()
      }
      .padding(12)
      .width('100%')
      .height('100%')
      .backgroundColor(THEME_PAGE_BG)
    }
  }
}
