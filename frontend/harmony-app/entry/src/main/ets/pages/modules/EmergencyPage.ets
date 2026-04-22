import { EmergencyItem, EmergencyRequest, TrafficResponse } from '../../common/model/ApiModels'
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

export type EmergencyMode = 'visitor' | 'writer' | 'approver' | 'admin'
type AdminEmergencyTab = 'published' | 'pending' | 'draft'
type AdminEmergencyScreen = 'list' | 'form' | 'approve'

class EmergencyLocalStatus {
  id: number
  status: string

  constructor(id: number, status: string) {
    this.id = id
    this.status = status
  }
}

@Component
export struct EmergencyPage {
  @Prop mode: EmergencyMode = 'visitor'

  @State private items: EmergencyItem[] = []
  @State private trafficList: TrafficResponse[] = []
  @State private loading: boolean = false
  @State private errorMessage: string = ''
  @State private actionMessage: string = ''

  @State private selectedId: number = 0
  @State private titleInput: string = ''
  @State private contentInput: string = ''
  @State private validFromInput: string = ''
  @State private validUntilInput: string = ''
  @State private alertLevelInput: string = 'MEDIUM'
  @State private alertTypeInput: string = 'GENERAL'
  @State private selectedWindowPreset: string = 'today'

  @State private searchQuery: string = ''
  @State private adminTab: AdminEmergencyTab = 'published'
  @State private adminScreen: AdminEmergencyScreen = 'list'
  @State private localStatuses: EmergencyLocalStatus[] = []

  async aboutToAppear(): Promise<void> {
    await this.loadItems()
  }

  private canWrite(): boolean {
    return this.mode === 'admin' || this.mode === 'writer'
  }

  private canApprove(): boolean {
    return this.mode === 'approver'
  }

  private listApiPath(): string {
    if (this.mode === 'visitor') {
      return '/api/emergency'
    }
    return '/api/emergency/admin'
  }

  private async loadItems(preferredId?: number): Promise<void> {
    this.loading = true
    this.errorMessage = ''
    try {
      const list: EmergencyItem[] = await apiClient.get<EmergencyItem[]>(this.listApiPath())
      this.items = [...list]
      if (this.mode === 'visitor') {
        const traffic: TrafficResponse[] = await apiClient.get<TrafficResponse[]>('/api/query/traffic')
        this.trafficList = [...traffic]
      }
      this.syncSelection(preferredId)
    } catch (_error) {
      this.errorMessage = this.mode === 'visitor' ? '加载应急信息失败，请稍后重试' : '加载应急管理数据失败，请稍后重试'
    } finally {
      this.loading = false
    }
  }

  private syncSelection(preferredId?: number): void {
    if (this.items.length === 0) {
      this.selectedId = 0
      return
    }
    if (preferredId !== undefined) {
      const preferred: EmergencyItem | null = this.findItemById(preferredId)
      if (preferred !== null) {
        this.selectedId = preferred.id
        return
      }
    }
    if (this.selectedId > 0) {
      const selected: EmergencyItem | null = this.findItemById(this.selectedId)
      if (selected !== null) {
        this.selectedId = selected.id
        return
      }
    }
    this.selectedId = this.items[0].id
  }

  private findItemById(id: number): EmergencyItem | null {
    const target: EmergencyItem | undefined = this.items.find((item: EmergencyItem) => item.id === id)
    return target === undefined ? null : target
  }

  private currentItem(): EmergencyItem | null {
    if (this.selectedId <= 0) {
      return null
    }
    return this.findItemById(this.selectedId)
  }

  private setLocalStatus(id: number, status: string): void {
    const exists: boolean = this.localStatuses.some((item: EmergencyLocalStatus) => item.id === id)
    if (exists) {
      this.localStatuses = this.localStatuses.map((item: EmergencyLocalStatus) => {
        if (item.id === id) {
          return new EmergencyLocalStatus(id, status)
        }
        return item
      })
      return
    }
    this.localStatuses = [...this.localStatuses, new EmergencyLocalStatus(id, status)]
  }

  private clearLocalStatus(id: number): void {
    this.localStatuses = this.localStatuses.filter((item: EmergencyLocalStatus) => item.id !== id)
  }

  private effectiveStatus(item: EmergencyItem): string {
    const local: EmergencyLocalStatus | undefined = this.localStatuses.find((entry: EmergencyLocalStatus) => entry.id === item.id)
    if (local !== undefined) {
      return local.status
    }
    return item.status
  }

  private levelValue(value: string | undefined): string {
    if (value === undefined || value.length === 0) {
      return 'MEDIUM'
    }
    return value.toUpperCase()
  }

  private typeValue(value: string | undefined): string {
    if (value === undefined || value.length === 0) {
      return 'GENERAL'
    }
    return value.toUpperCase()
  }

  private levelBadgeText(level: string | undefined): string {
    const safe: string = this.levelValue(level)
    if (safe === 'HIGH') {
      return '红色预警'
    }
    if (safe === 'LOW') {
      return '蓝色预警'
    }
    return '橙色预警'
  }

  private levelBadgeColor(level: string | undefined): string {
    const safe: string = this.levelValue(level)
    if (safe === 'HIGH') {
      return THEME_DANGER
    }
    if (safe === 'LOW') {
      return THEME_PRIMARY
    }
    return '#EA580C'
  }

  private levelBadgeBg(level: string | undefined): string {
    const safe: string = this.levelValue(level)
    if (safe === 'HIGH') {
      return '#FFECEC'
    }
    if (safe === 'LOW') {
      return THEME_PRIMARY_SOFT
    }
    return '#FFF4E6'
  }

  private typeLabel(type: string | undefined): string {
    const safe: string = this.typeValue(type)
    if (safe === 'WEATHER') {
      return '天气预警'
    }
    if (safe === 'TRAFFIC') {
      return '路况交通'
    }
    return '客流预警'
  }

  private statusLabel(status: string): string {
    if (status === 'DRAFT') {
      return '草稿'
    }
    if (status === 'REJECTED') {
      return '驳回'
    }
    if (status === 'PENDING_APPROVAL') {
      return '待审批'
    }
    if (status === 'PUBLISHED') {
      return '展示中'
    }
    return status
  }

  private statusColor(status: string): string {
    if (status === 'PUBLISHED') {
      return THEME_SUCCESS
    }
    if (status === 'PENDING_APPROVAL') {
      return '#EA580C'
    }
    if (status === 'REJECTED') {
      return THEME_DANGER
    }
    return THEME_TEXT_SECONDARY
  }

  private formatDate(value: string | null, emptyText: string): string {
    if (value === null || value.length === 0) {
      return emptyText
    }
    return value.replace('T', ' ')
  }

  private displayWindowLine(prefix: string, value: string | null, emptyText: string): string {
    return `${prefix}：${this.formatDate(value, emptyText)}`
  }

  private buildRequest(): EmergencyRequest {
    const validFrom: string = this.validFromInput.trim()
    const validUntil: string = this.validUntilInput.trim()
    const level: string = this.levelValue(this.alertLevelInput)
    const type: string = this.typeValue(this.alertTypeInput)
    return {
      title: this.titleInput.trim(),
      content: this.contentInput.trim(),
      validFrom: validFrom.length > 0 ? validFrom : null,
      validUntil: validUntil.length > 0 ? validUntil : null,
      alertLevel: level,
      alertType: type
    }
  }

  private fillEditor(item: EmergencyItem): void {
    this.selectedId = item.id
    this.titleInput = item.title
    this.contentInput = item.content
    this.validFromInput = item.validFrom === null ? '' : item.validFrom
    this.validUntilInput = item.validUntil === null ? '' : item.validUntil
    this.alertLevelInput = this.levelValue(item.alertLevel)
    this.alertTypeInput = this.typeValue(item.alertType)
  }

  private clearEditor(): void {
    this.selectedId = 0
    this.titleInput = ''
    this.contentInput = ''
    this.alertLevelInput = 'MEDIUM'
    this.alertTypeInput = 'GENERAL'
    this.applyWindowPreset('today')
  }

  private openCreateForm(): void {
    this.clearEditor()
    this.adminScreen = 'form'
    this.actionMessage = ''
    this.errorMessage = ''
  }

  private openEditForm(item: EmergencyItem): void {
    this.fillEditor(item)
    this.adminScreen = 'form'
    this.actionMessage = ''
    this.errorMessage = ''
  }

  private openApproveView(item: EmergencyItem): void {
    this.fillEditor(item)
    this.adminScreen = 'approve'
    this.actionMessage = ''
    this.errorMessage = ''
  }

  private backToList(): void {
    this.adminScreen = 'list'
    this.errorMessage = ''
  }

  private async createDraft(): Promise<void> {
    if (!this.canWrite()) {
      return
    }
    if (this.titleInput.trim().length === 0 || this.contentInput.trim().length === 0) {
      this.errorMessage = '请先填写预警标题和内容'
      return
    }
    this.loading = true
    this.errorMessage = ''
    try {
      const created: EmergencyItem = await apiClient.post<EmergencyRequest, EmergencyItem>('/api/emergency/admin', this.buildRequest())
      this.clearLocalStatus(created.id)
      await this.loadItems(created.id)
      this.fillEditor(created)
      this.adminTab = 'draft'
      this.adminScreen = 'form'
      this.actionMessage = '草稿已保存，可继续修改或提交审批'
    } catch (_error) {
      this.errorMessage = '创建草稿失败，请稍后重试'
    } finally {
      this.loading = false
    }
  }

  private async updateDraft(): Promise<void> {
    if (!this.canWrite()) {
      return
    }
    if (this.selectedId <= 0) {
      this.errorMessage = '请先选择一条预警信息'
      return
    }
    this.loading = true
    this.errorMessage = ''
    try {
      const updated: EmergencyItem = await apiClient.put<EmergencyRequest, EmergencyItem>(`/api/emergency/admin/${this.selectedId}`, this.buildRequest())
      await this.loadItems(updated.id)
      this.fillEditor(updated)
      this.actionMessage = '修改已保存'
    } catch (_error) {
      this.errorMessage = '保存修改失败，请稍后重试'
    } finally {
      this.loading = false
    }
  }

  private async submitForApproval(): Promise<void> {
    if (!this.canWrite()) {
      return
    }
    if (this.selectedId <= 0) {
      this.errorMessage = '请先保存草稿后再提交审批'
      return
    }
    this.loading = true
    this.errorMessage = ''
    try {
      await apiClient.post<Record<string, string>, EmergencyItem>(`/api/emergency/admin/${this.selectedId}/submit`, {})
      this.clearLocalStatus(this.selectedId)
      await this.loadItems(this.selectedId)
      this.adminTab = 'pending'
      this.adminScreen = 'list'
      this.actionMessage = '已提交审批，等待平台管理员审核'
    } catch (_error) {
      this.errorMessage = '提交审批失败，请稍后重试'
    } finally {
      this.loading = false
    }
  }

  private async approvePublish(): Promise<void> {
    if (!this.canApprove()) {
      return
    }
    if (this.selectedId <= 0) {
      this.errorMessage = '请先选择一条待审批预警'
      return
    }
    this.loading = true
    this.errorMessage = ''
    try {
      await apiClient.post<Record<string, string>, EmergencyItem>(`/api/emergency/admin/${this.selectedId}/approve`, {})
      this.clearLocalStatus(this.selectedId)
      await this.loadItems(this.selectedId)
      this.adminTab = 'published'
      this.adminScreen = 'list'
      this.actionMessage = '已审核通过并发布到游客端'
    } catch (_error) {
      this.errorMessage = '审批发布失败，请稍后重试'
    } finally {
      this.loading = false
    }
  }

  private rejectForRevision(): void {
    if (this.selectedId <= 0) {
      return
    }
    this.setLocalStatus(this.selectedId, 'REJECTED')
    this.adminTab = 'draft'
    this.adminScreen = 'form'
    this.errorMessage = ''
    this.actionMessage = '已退回为修改状态。当前后端未提供驳回接口，本次先以前端演示态承载。'
  }

  private async deleteItem(id: number): Promise<void> {
    if (!this.canWrite()) {
      return
    }
    this.loading = true
    this.errorMessage = ''
    try {
      await apiClient.delete<void>(`/api/emergency/admin/${id}`)
      this.clearLocalStatus(id)
      if (this.selectedId === id) {
        this.clearEditor()
      }
      await this.loadItems()
      this.adminScreen = 'list'
      this.actionMessage = '已删除该条应急预警'
    } catch (_error) {
      this.errorMessage = '删除失败，请稍后重试'
    } finally {
      this.loading = false
    }
  }

  private matchesSearch(item: EmergencyItem): boolean {
    const query: string = this.searchQuery.trim().toLowerCase()
    if (query.length === 0) {
      return true
    }
    const title: string = item.title.toLowerCase()
    const content: string = item.content.toLowerCase()
    const type: string = this.typeLabel(item.alertType).toLowerCase()
    return title.indexOf(query) >= 0 || content.indexOf(query) >= 0 || type.indexOf(query) >= 0
  }

  private inCurrentTab(item: EmergencyItem): boolean {
    const status: string = this.effectiveStatus(item)
    if (this.adminTab === 'published') {
      return status === 'PUBLISHED'
    }
    if (this.adminTab === 'pending') {
      return status === 'PENDING_APPROVAL'
    }
    return status === 'DRAFT' || status === 'REJECTED'
  }

  private filteredAdminItems(): EmergencyItem[] {
    return this.items.filter((item: EmergencyItem) => this.inCurrentTab(item) && this.matchesSearch(item))
  }

  private adminTabCount(tab: AdminEmergencyTab): number {
    return this.items.filter((item: EmergencyItem) => {
      const status: string = this.effectiveStatus(item)
      if (tab === 'published') {
        return status === 'PUBLISHED'
      }
      if (tab === 'pending') {
        return status === 'PENDING_APPROVAL'
      }
      return status === 'DRAFT' || status === 'REJECTED'
    }).length
  }

  private tabTitle(tab: AdminEmergencyTab): string {
    if (tab === 'published') {
      return `展示中 (${this.adminTabCount('published')})`
    }
    if (tab === 'pending') {
      return `待审批 (${this.adminTabCount('pending')})`
    }
    return '草稿/驳回'
  }

  private tabSelected(tab: AdminEmergencyTab): boolean {
    return this.adminTab === tab
  }

  private trafficText(item: TrafficResponse): string {
    return `${item.status} · ${item.suggestRoute}`
  }

  private currentItemTitle(): string {
    const item: EmergencyItem | null = this.currentItem()
    return item === null ? '' : item.title
  }

  private currentItemContent(): string {
    const item: EmergencyItem | null = this.currentItem()
    return item === null ? '' : item.content
  }

  private currentItemLevel(): string | undefined {
    const item: EmergencyItem | null = this.currentItem()
    return item === null ? undefined : item.alertLevel
  }

  private currentItemType(): string | undefined {
    const item: EmergencyItem | null = this.currentItem()
    return item === null ? undefined : item.alertType
  }

  private currentItemValidFrom(): string | null {
    const item: EmergencyItem | null = this.currentItem()
    return item === null ? null : item.validFrom
  }

  private currentItemValidUntil(): string | null {
    const item: EmergencyItem | null = this.currentItem()
    return item === null ? null : item.validUntil
  }

  private currentItemCreatedBy(): string {
    const item: EmergencyItem | null = this.currentItem()
    return item === null ? '' : item.createdBy
  }

  private isSelectedOption(currentValue: string, optionValue: string): boolean {
    return currentValue === optionValue
  }

  private optionCardBackground(selected: boolean): string {
    return selected ? THEME_PRIMARY : THEME_SURFACE
  }

  private optionCardBorder(selected: boolean): string {
    return selected ? THEME_PRIMARY : '#DDE5F2'
  }

  private optionCardTextColor(selected: boolean): string {
    return selected ? '#FFFFFF' : THEME_TEXT_SECONDARY
  }

  private optionButtonText(label: string, selected: boolean): string {
    return selected ? `✓ ${label}` : label
  }

  private levelOptionSelected(value: string): boolean {
    return this.alertLevelInput === value
  }

  private typeOptionSelected(value: string): boolean {
    return this.alertTypeInput === value
  }

  private isWindowPresetSelected(preset: string): boolean {
    return this.selectedWindowPreset === preset
  }

  private padTime(value: number): string {
    return value < 10 ? `0${value}` : `${value}`
  }

  private formatIsoLike(date: Date): string {
    const year: number = date.getFullYear()
    const month: string = this.padTime(date.getMonth() + 1)
    const day: string = this.padTime(date.getDate())
    const hour: string = this.padTime(date.getHours())
    const minute: string = this.padTime(date.getMinutes())
    return `${year}-${month}-${day}T${hour}:${minute}:00`
  }

  private nowDate(): Date {
    return new Date()
  }

  private withTime(base: Date, hour: number, minute: number): Date {
    const next: Date = new Date(base.getTime())
    next.setHours(hour, minute, 0, 0)
    return next
  }

  private addHours(base: Date, hours: number): Date {
    const next: Date = new Date(base.getTime())
    next.setHours(next.getHours() + hours)
    return next
  }

  private applyWindowPreset(preset: string): void {
    const now: Date = this.nowDate()
    let start: Date = now
    let end: Date = this.addHours(now, 4)
    if (preset === 'commute') {
      start = this.withTime(now, 7, 30)
      end = this.withTime(now, 11, 30)
    } else if (preset === 'today') {
      start = this.withTime(now, 8, 0)
      end = this.withTime(now, 20, 0)
    } else if (preset === 'tomorrow') {
      const tomorrow: Date = this.addHours(this.withTime(now, 8, 0), 24)
      start = tomorrow
      end = this.addHours(tomorrow, 12)
    } else if (preset === 'custom') {
      this.selectedWindowPreset = preset
      return
    }
    this.selectedWindowPreset = preset
    this.validFromInput = this.formatIsoLike(start)
    this.validUntilInput = this.formatIsoLike(end)
  }

  private effectiveWindowSummary(): string {
    if (this.validFromInput.length === 0 && this.validUntilInput.length === 0) {
      return '未设置显示有效期'
    }
    return `${this.formatDate(this.validFromInput, '立即生效')} 至 ${this.formatDate(this.validUntilInput, '长期有效')}`
  }

  @Builder
  private VisitorHeader(): void {
    Row() {
      Row({ space: 12 }) {
        Text('警')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_PRIMARY)
          .textAlign(TextAlign.Center)
          .width(50)
          .height(50)
          .backgroundColor(THEME_PRIMARY_SOFT)
          .borderRadius(RADIUS_PILL)
        Column({ space: 3 }) {
          Text('应急信息')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(THEME_TEXT_PRIMARY)
          Text('实时预警与路况提醒')
            .fontSize(12)
            .fontColor(THEME_TEXT_TERTIARY)
        }
        .alignItems(HorizontalAlign.Start)
      }
      Blank()
      Text('游客端')
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
  private VisitorEmergencyList(): void {
    Column({ space: 8 }) {
      Text('应急列表')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(THEME_TEXT_PRIMARY)
      if (this.items.length === 0) {
        Text('暂无应急信息')
          .fontSize(12)
          .fontColor(THEME_TEXT_TERTIARY)
      } else {
        ForEach(this.items, (item: EmergencyItem) => {
          Column({ space: 8 }) {
            Row() {
              Text(item.title)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(THEME_TEXT_PRIMARY)
                .layoutWeight(1)
              Text(this.levelBadgeText(item.alertLevel))
                .fontSize(11)
                .fontColor(this.levelBadgeColor(item.alertLevel))
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .backgroundColor(this.levelBadgeBg(item.alertLevel))
                .borderRadius(RADIUS_PILL)
            }
            .width('100%')
            Text(item.content)
              .fontSize(12)
              .fontColor(THEME_TEXT_SECONDARY)
              .maxLines(3)
            Row({ space: 10 }) {
              Text(this.displayWindowLine('开始', item.validFrom, '立即生效'))
                .fontSize(11)
                .fontColor(THEME_TEXT_TERTIARY)
              Text(this.displayWindowLine('结束', item.validUntil, '长期有效'))
                .fontSize(11)
                .fontColor(THEME_TEXT_TERTIARY)
            }
            .width('100%')
          }
          .padding(12)
          .backgroundColor(THEME_SURFACE)
          .borderRadius(RADIUS_MD)
        }, (item: EmergencyItem) => `${item.id}`)
      }
    }
    .padding(12)
    .backgroundColor(THEME_SURFACE_MUTED)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private VisitorTrafficList(): void {
    Column({ space: 8 }) {
      Text('路况提醒')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(THEME_TEXT_PRIMARY)
      if (this.trafficList.length === 0) {
        Text('暂无路况信息')
          .fontSize(12)
          .fontColor(THEME_TEXT_TERTIARY)
      } else {
        ForEach(this.trafficList, (item: TrafficResponse, index: number) => {
          if (index < 3) {
            Column({ space: 4 }) {
              Text(`${item.fromLocation} → ${item.toLocation}`)
                .fontSize(13)
                .fontColor(THEME_TEXT_PRIMARY)
              Text(this.trafficText(item))
                .fontSize(11)
                .fontColor(THEME_TEXT_SECONDARY)
            }
            .padding(10)
            .backgroundColor(THEME_SURFACE)
            .borderRadius(RADIUS_MD)
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
        }, (_item: TrafficResponse, index: number) => `${index}`)
      }
    }
    .padding(12)
    .backgroundColor(THEME_SURFACE_MUTED)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private VisitorView(): void {
    Column({ space: 12 }) {
      this.VisitorHeader()

      if (this.errorMessage.length > 0) {
        Text(this.errorMessage)
          .fontSize(12)
          .fontColor(THEME_DANGER)
          .width('100%')
      }

      Scroll() {
        Column({ space: 12 }) {
          if (this.loading) {
            Text('应急信息加载中...')
              .fontSize(12)
              .fontColor(THEME_TEXT_SECONDARY)
          }
          this.VisitorEmergencyList()
          this.VisitorTrafficList()
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 0, right: 0, top: 0, bottom: 20 })
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
    }
    .height('100%')
    .width('100%')
    .padding({ left: 12, right: 12, top: 12, bottom: 20 })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .backgroundColor(THEME_PAGE_BG)
  }

  @Builder
  private AdminSearchBar(): void {
    TextInput({ placeholder: '查询预警标题或内容关键词', text: this.searchQuery })
      .onChange((value: string) => {
        this.searchQuery = value
      })
      .height(46)
      .padding(12)
      .backgroundColor(THEME_SURFACE)
      .borderRadius(RADIUS_LG)
  }

  @Builder
  private AdminTabs(): void {
    Row({ space: 10 }) {
      this.AdminTabButton('published')
      this.AdminTabButton('pending')
      this.AdminTabButton('draft')
    }
    .width('100%')
  }

  @Builder
  private AdminTabButton(tab: AdminEmergencyTab): void {
    Button(this.tabTitle(tab))
      .layoutWeight(1)
      .height(40)
      .fontSize(11)
      .fontWeight(this.tabSelected(tab) ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.tabSelected(tab) ? (tab === 'pending' ? '#EA580C' : THEME_PRIMARY) : THEME_TEXT_SECONDARY)
      .backgroundColor(this.tabSelected(tab) ? THEME_SURFACE : Color.Transparent)
      .borderRadius(RADIUS_PILL)
      .onClick(() => {
        this.adminTab = tab
        this.adminScreen = 'list'
        this.actionMessage = ''
        this.errorMessage = ''
      })
  }

  @Builder
  private AdminMessageBar(): void {
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
  }

  @Builder
  private EmergencyCard(item: EmergencyItem): void {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Text(this.levelBadgeText(item.alertLevel))
          .fontSize(11)
          .fontColor(this.levelBadgeColor(item.alertLevel))
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(this.levelBadgeBg(item.alertLevel))
          .borderRadius(RADIUS_PILL)
        Text(this.typeLabel(item.alertType))
          .fontSize(11)
          .fontColor(THEME_TEXT_SECONDARY)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(THEME_SURFACE_MUTED)
          .borderRadius(RADIUS_PILL)
        Blank()
        Text(this.statusLabel(this.effectiveStatus(item)))
          .fontSize(11)
          .fontColor(this.statusColor(this.effectiveStatus(item)))
      }
      .width('100%')

      Text(item.title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(THEME_TEXT_PRIMARY)
        .width('100%')

      Column({ space: 6 }) {
        Text(this.displayWindowLine('开始', item.validFrom, '立即生效'))
          .fontSize(12)
          .fontColor(THEME_TEXT_SECONDARY)
        Text(this.displayWindowLine('结束', item.validUntil, '长期有效'))
          .fontSize(12)
          .fontColor(THEME_TEXT_SECONDARY)
      }
      .width('100%')
      .padding(12)
      .backgroundColor(THEME_SURFACE_MUTED)
      .borderRadius(RADIUS_MD)
      .alignItems(HorizontalAlign.Start)

      Row() {
        Text(`提交：${item.createdBy}`)
          .fontSize(12)
          .fontColor(THEME_TEXT_TERTIARY)
        Blank()
        this.EmergencyCardActions(item)
      }
      .width('100%')
    }
    .padding(16)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(26)
    .shadow(SHADOW_CARD)
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private EmergencyCardActions(item: EmergencyItem): void {
    Row({ space: 8 }) {
      if (this.effectiveStatus(item) === 'PENDING_APPROVAL') {
        Button('去审批')
          .height(32)
          .padding({ left: 14, right: 14 })
          .borderRadius(RADIUS_PILL)
          .backgroundColor('#FFF4E6')
          .fontColor('#EA580C')
          .onClick(() => this.openApproveView(item))
      } else {
        Button('编辑')
          .height(32)
          .padding({ left: 12, right: 12 })
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_PRIMARY_SOFT)
          .fontColor(THEME_PRIMARY)
          .onClick(() => this.openEditForm(item))
        Button('删除')
          .height(32)
          .padding({ left: 12, right: 12 })
          .borderRadius(RADIUS_PILL)
          .backgroundColor('#F5F7FB')
          .fontColor(THEME_TEXT_SECONDARY)
          .onClick(() => this.deleteItem(item.id))
      }
    }
  }

  @Builder
  private AdminListView(): void {
    Column({ space: 16 }) {
      this.AdminSearchBar()
      this.AdminTabs()
      this.AdminMessageBar()

      Scroll() {
        Column({ space: 14 }) {
          if (this.loading) {
            Text('应急管理数据加载中...')
              .fontSize(12)
              .fontColor(THEME_TEXT_SECONDARY)
              .width('100%')
          } else if (this.filteredAdminItems().length === 0) {
            Column({ space: 8 }) {
              Text('暂无内容')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor(THEME_TEXT_PRIMARY)
              Text('当前筛选条件下没有应急信息')
                .fontSize(11)
                .fontColor(THEME_TEXT_TERTIARY)
            }
            .padding(20)
            .width('100%')
            .backgroundColor(THEME_SURFACE)
            .borderRadius(RADIUS_LG)
          } else {
            ForEach(this.filteredAdminItems(), (item: EmergencyItem) => {
              this.EmergencyCard(item)
            }, (item: EmergencyItem) => `${item.id}`)
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 0, right: 0, top: 0, bottom: 20 })
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)

      if (this.canWrite()) {
        Button('+ 发布新应急预警')
          .width('100%')
          .height(50)
          .borderRadius(22)
          .backgroundColor(THEME_PRIMARY)
          .fontColor(Color.White)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .onClick(() => this.openCreateForm())
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 12, right: 12, top: 12, bottom: 20 })
    .backgroundColor(THEME_PAGE_BG)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private FormHeader(): void {
    Row() {
      Column({ space: 4 }) {
        Text(this.selectedId > 0 ? '编辑应急预警' : '发布新应急预警')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
        Text('起草、编辑并设置显示有效期')
          .fontSize(11)
          .fontColor(THEME_TEXT_SECONDARY)
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      Button('返回列表')
        .height(34)
        .padding({ left: 14, right: 14 })
        .borderRadius(RADIUS_PILL)
        .backgroundColor(THEME_PRIMARY_SOFT)
        .fontColor(THEME_PRIMARY)
        .onClick(() => this.backToList())
    }
    .width('100%')
  }

  @Builder
  private LevelSelector(): void {
    Row({ space: 8 }) {
      Button(this.optionButtonText('蓝色预警', this.levelOptionSelected('LOW')))
        .layoutWeight(1)
        .height(40)
        .borderRadius(RADIUS_PILL)
        .backgroundColor(this.optionCardBackground(this.levelOptionSelected('LOW')))
        .border({
          width: 1,
          color: this.optionCardBorder(this.levelOptionSelected('LOW'))
        })
        .fontSize(12)
        .fontWeight(this.levelOptionSelected('LOW') ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.optionCardTextColor(this.levelOptionSelected('LOW')))
        .stateEffect(true)
        .onClick(() => {
          this.actionMessage = ''
          this.errorMessage = ''
          this.alertLevelInput = 'LOW'
        })
      Button(this.optionButtonText('橙色预警', this.levelOptionSelected('MEDIUM')))
        .layoutWeight(1)
        .height(40)
        .borderRadius(RADIUS_PILL)
        .backgroundColor(this.optionCardBackground(this.levelOptionSelected('MEDIUM')))
        .border({
          width: 1,
          color: this.optionCardBorder(this.levelOptionSelected('MEDIUM'))
        })
        .fontSize(12)
        .fontWeight(this.levelOptionSelected('MEDIUM') ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.optionCardTextColor(this.levelOptionSelected('MEDIUM')))
        .stateEffect(true)
        .onClick(() => {
          this.actionMessage = ''
          this.errorMessage = ''
          this.alertLevelInput = 'MEDIUM'
        })
      Button(this.optionButtonText('红色预警', this.levelOptionSelected('HIGH')))
        .layoutWeight(1)
        .height(40)
        .borderRadius(RADIUS_PILL)
        .backgroundColor(this.optionCardBackground(this.levelOptionSelected('HIGH')))
        .border({
          width: 1,
          color: this.optionCardBorder(this.levelOptionSelected('HIGH'))
        })
        .fontSize(12)
        .fontWeight(this.levelOptionSelected('HIGH') ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.optionCardTextColor(this.levelOptionSelected('HIGH')))
        .stateEffect(true)
        .onClick(() => {
          this.actionMessage = ''
          this.errorMessage = ''
          this.alertLevelInput = 'HIGH'
        })
    }
    .width('100%')
  }

  @Builder
  private TypeSelector(): void {
    Row({ space: 8 }) {
      Button(this.optionButtonText('天气预警', this.typeOptionSelected('WEATHER')))
        .layoutWeight(1)
        .height(40)
        .borderRadius(RADIUS_PILL)
        .backgroundColor(this.optionCardBackground(this.typeOptionSelected('WEATHER')))
        .border({
          width: 1,
          color: this.optionCardBorder(this.typeOptionSelected('WEATHER'))
        })
        .fontSize(12)
        .fontWeight(this.typeOptionSelected('WEATHER') ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.optionCardTextColor(this.typeOptionSelected('WEATHER')))
        .stateEffect(true)
        .onClick(() => {
          this.actionMessage = ''
          this.errorMessage = ''
          this.alertTypeInput = 'WEATHER'
        })
      Button(this.optionButtonText('路况交通', this.typeOptionSelected('TRAFFIC')))
        .layoutWeight(1)
        .height(40)
        .borderRadius(RADIUS_PILL)
        .backgroundColor(this.optionCardBackground(this.typeOptionSelected('TRAFFIC')))
        .border({
          width: 1,
          color: this.optionCardBorder(this.typeOptionSelected('TRAFFIC'))
        })
        .fontSize(12)
        .fontWeight(this.typeOptionSelected('TRAFFIC') ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.optionCardTextColor(this.typeOptionSelected('TRAFFIC')))
        .stateEffect(true)
        .onClick(() => {
          this.actionMessage = ''
          this.errorMessage = ''
          this.alertTypeInput = 'TRAFFIC'
        })
      Button(this.optionButtonText('客流公告', this.typeOptionSelected('GENERAL')))
        .layoutWeight(1)
        .height(40)
        .borderRadius(RADIUS_PILL)
        .backgroundColor(this.optionCardBackground(this.typeOptionSelected('GENERAL')))
        .border({
          width: 1,
          color: this.optionCardBorder(this.typeOptionSelected('GENERAL'))
        })
        .fontSize(12)
        .fontWeight(this.typeOptionSelected('GENERAL') ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.optionCardTextColor(this.typeOptionSelected('GENERAL')))
        .stateEffect(true)
        .onClick(() => {
          this.actionMessage = ''
          this.errorMessage = ''
          this.alertTypeInput = 'GENERAL'
        })
    }
    .width('100%')
  }

  @Builder
  private WindowPresetButton(label: string, preset: string): void {
    Button(this.optionButtonText(label, this.isWindowPresetSelected(preset)))
      .layoutWeight(1)
      .height(38)
      .borderRadius(RADIUS_PILL)
      .backgroundColor(this.optionCardBackground(this.isWindowPresetSelected(preset)))
      .border({
        width: 1,
        color: this.optionCardBorder(this.isWindowPresetSelected(preset))
      })
      .fontSize(11)
      .fontWeight(this.isWindowPresetSelected(preset) ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.optionCardTextColor(this.isWindowPresetSelected(preset)))
      .stateEffect(true)
      .onClick(() => this.applyWindowPreset(preset))
  }

  @Builder
  private AdminFormView(): void {
    Column({ space: 16 }) {
      this.FormHeader()
      this.AdminMessageBar()

      Scroll() {
        Column({ space: 14 }) {
          TextInput({ placeholder: '输入预警标题', text: this.titleInput })
            .onChange((value: string) => {
              this.titleInput = value
            })
            .height(46)
            .padding(12)
            .backgroundColor(THEME_SURFACE)
            .borderRadius(RADIUS_LG)

          TextArea({ placeholder: '填写预警内容与游客指引', text: this.contentInput })
            .onChange((value: string) => {
              this.contentInput = value
            })
            .height(120)
            .padding(12)
            .backgroundColor(THEME_SURFACE)
            .borderRadius(RADIUS_LG)

          Column({ space: 8 }) {
            Text('预警级别')
              .fontSize(13)
              .fontColor(THEME_TEXT_SECONDARY)
            this.LevelSelector()
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column({ space: 8 }) {
            Text('预警类型')
              .fontSize(13)
              .fontColor(THEME_TEXT_SECONDARY)
            this.TypeSelector()
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column({ space: 8 }) {
            Text('显示有效期')
              .fontSize(13)
              .fontColor(THEME_TEXT_SECONDARY)
            Row({ space: 8 }) {
              this.WindowPresetButton('今日有效', 'today')
              this.WindowPresetButton('通勤时段', 'commute')
            }
            .width('100%')
            Row({ space: 8 }) {
              this.WindowPresetButton('立即生效 4 小时', 'now')
              this.WindowPresetButton('明日白天', 'tomorrow')
            }
            .width('100%')
            Column({ space: 6 }) {
              Text('当前生效窗口')
                .fontSize(11)
                .fontColor(THEME_TEXT_TERTIARY)
              Text(this.effectiveWindowSummary())
                .fontSize(12)
                .fontColor(THEME_TEXT_PRIMARY)
                .lineHeight(20)
            }
            .width('100%')
            .padding(12)
            .backgroundColor(THEME_SURFACE)
            .borderRadius(RADIUS_LG)
            .alignItems(HorizontalAlign.Start)
            TextInput({ placeholder: '自定义开始时间（如 2026-04-21T08:00:00）', text: this.validFromInput })
              .onChange((value: string) => {
                this.selectedWindowPreset = 'custom'
                this.validFromInput = value
              })
              .height(46)
              .padding(12)
              .backgroundColor(THEME_SURFACE)
              .borderRadius(RADIUS_LG)
            TextInput({ placeholder: '自定义结束时间（如 2026-04-21T18:00:00）', text: this.validUntilInput })
              .onChange((value: string) => {
                this.selectedWindowPreset = 'custom'
                this.validUntilInput = value
              })
              .height(46)
              .padding(12)
              .backgroundColor(THEME_SURFACE)
              .borderRadius(RADIUS_LG)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 0, right: 0, top: 0, bottom: 20 })
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)

      Column({ space: 10 }) {
        if (this.selectedId <= 0) {
          Button('保存草稿')
            .width('100%')
            .height(50)
            .borderRadius(RADIUS_LG)
            .backgroundColor(THEME_PRIMARY)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .onClick(() => this.createDraft())
        } else {
          Row({ space: 10 }) {
            Button('保存修改')
              .layoutWeight(1)
              .height(46)
              .borderRadius(RADIUS_LG)
              .backgroundColor(THEME_PRIMARY_SOFT)
              .fontColor(THEME_PRIMARY)
              .onClick(() => this.updateDraft())
            Button('提交审批')
              .layoutWeight(1)
              .height(46)
              .borderRadius(RADIUS_LG)
              .backgroundColor(THEME_PRIMARY)
              .fontColor(Color.White)
              .onClick(() => this.submitForApproval())
          }
          .width('100%')

          Button('删除该预警')
            .width('100%')
            .height(46)
            .borderRadius(RADIUS_LG)
            .backgroundColor('#F5F7FB')
            .fontColor(THEME_TEXT_SECONDARY)
            .onClick(() => this.deleteItem(this.selectedId))
        }
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding({ left: 12, right: 12, top: 12, bottom: 20 })
    .backgroundColor(THEME_PAGE_BG)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private AdminApproveView(): void {
    Column({ space: 16 }) {
      Row() {
        Column({ space: 4 }) {
        Text('待审批预警')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(THEME_TEXT_PRIMARY)
          Text('审核内容、有效期与类型后决定是否发布')
            .fontSize(11)
            .fontColor(THEME_TEXT_SECONDARY)
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        Button('返回列表')
          .height(34)
          .padding({ left: 14, right: 14 })
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_PRIMARY_SOFT)
          .fontColor(THEME_PRIMARY)
          .onClick(() => this.backToList())
      }
      .width('100%')

      this.AdminMessageBar()

      if (this.currentItem() !== null) {
        Scroll() {
          Column({ space: 14 }) {
            Column({ space: 10 }) {
              Text('提交审批说明：请确认该预警内容真实、时效准确，再决定是否发布到游客端。')
                .fontSize(12)
                .lineHeight(20)
                .fontColor('#EA580C')
                .width('100%')
            }
            .padding(14)
            .width('100%')
            .backgroundColor('#FFF4E6')
            .borderRadius(RADIUS_LG)
            .alignItems(HorizontalAlign.Start)

            Column({ space: 12 }) {
              Row({ space: 8 }) {
                Text(this.levelBadgeText(this.currentItemLevel()))
                  .fontSize(11)
                  .fontColor(this.levelBadgeColor(this.currentItemLevel()))
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .backgroundColor(this.levelBadgeBg(this.currentItemLevel()))
                  .borderRadius(RADIUS_PILL)
                Text(this.typeLabel(this.currentItemType()))
                  .fontSize(11)
                  .fontColor(THEME_TEXT_SECONDARY)
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .backgroundColor(THEME_SURFACE_MUTED)
                  .borderRadius(RADIUS_PILL)
              }
              .width('100%')

              Text(this.currentItemTitle())
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(THEME_TEXT_PRIMARY)
                .width('100%')

              Text(this.currentItemContent())
                .fontSize(13)
                .lineHeight(22)
                .fontColor(THEME_TEXT_SECONDARY)
                .width('100%')

              Column({ space: 6 }) {
                Text(this.displayWindowLine('开始', this.currentItemValidFrom(), '立即生效'))
                  .fontSize(12)
                  .fontColor(THEME_TEXT_SECONDARY)
                Text(this.displayWindowLine('结束', this.currentItemValidUntil(), '长期有效'))
                  .fontSize(12)
                  .fontColor(THEME_TEXT_SECONDARY)
              }
              .width('100%')
              .padding(12)
              .backgroundColor(THEME_SURFACE_MUTED)
              .borderRadius(RADIUS_MD)
              .alignItems(HorizontalAlign.Start)

              Text(`提交人：${this.currentItemCreatedBy()}`)
                .fontSize(12)
                .fontColor(THEME_TEXT_TERTIARY)
                .width('100%')
            }
            .padding(18)
            .width('100%')
            .backgroundColor(THEME_SURFACE)
            .borderRadius(26)
            .shadow(SHADOW_CARD)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding({ left: 0, right: 0, top: 0, bottom: 20 })
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)

        Row({ space: 10 }) {
          Button('驳回修改')
            .layoutWeight(1)
            .height(48)
            .borderRadius(RADIUS_LG)
            .backgroundColor('#FFECEC')
            .fontColor(THEME_DANGER)
            .onClick(() => this.rejectForRevision())
          Button('同意并发布')
            .layoutWeight(1)
            .height(48)
            .borderRadius(RADIUS_LG)
            .backgroundColor(THEME_SUCCESS)
            .fontColor(Color.White)
            .onClick(() => this.approvePublish())
        }
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 12, right: 12, top: 12, bottom: 20 })
    .backgroundColor(THEME_PAGE_BG)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private AdminManagementView(): void {
    if (this.adminScreen === 'form') {
      this.AdminFormView()
    } else if (this.adminScreen === 'approve') {
      this.AdminApproveView()
    } else {
      this.AdminListView()
    }
  }

  build() {
    if (this.mode === 'visitor') {
      this.VisitorView()
    } else {
      this.AdminManagementView()
    }
  }
}
