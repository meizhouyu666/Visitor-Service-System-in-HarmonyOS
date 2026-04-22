import {
  AuditLogPageResponse,
  AuditLogResponse,
  HotelResponse,
  SystemSettingResponse,
  SystemSettingUpdateRequest,
  SystemUserCreateRequest,
  SystemUserResetPasswordRequest,
  SystemUserResponse,
  SystemUserUpdateRequest,
  UserRole
} from '../../common/model/ApiModels'
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

type SystemAdminSection = 'home' | 'account' | 'logs' | 'rbac' | 'settings'
type ManagedRole = 'ADMIN' | 'APPROVER' | 'HOTEL_ADMIN' | 'COMPLAINT_HANDLER' | 'SYSTEM_ADMIN'

interface SystemModuleCardItem {
  key: SystemAdminSection
  title: string
  subtitle: string
  icon: string
  iconBg: string
}

interface PermissionMatrixItem {
  role: string
  title: string
  permissions: string[]
}

const SYSTEM_MODULE_ITEMS: SystemModuleCardItem[] = [
  { key: 'account', title: '\u8d26\u53f7\u4e0e\u6743\u9650', subtitle: '\u65b0\u589e\u8d26\u53f7\u4e0e\u9152\u5e97\u7ed1\u5b9a', icon: '👥', iconBg: THEME_PRIMARY_SOFT },
  { key: 'logs', title: '\u64cd\u4f5c\u65e5\u5fd7\u5ba1\u8ba1', subtitle: '\u5168\u5c40\u884c\u4e3a\u4e0e\u5f02\u5e38\u8ffd\u8e2a', icon: '🧾', iconBg: '#FFF4E6' },
  { key: 'rbac', title: 'RBAC \u89d2\u8272\u914d\u7f6e', subtitle: '\u56fa\u5b9a\u4e94\u89d2\u8272\u6743\u9650\u6620\u5c04', icon: '🛡', iconBg: '#F3E8FF' },
  { key: 'settings', title: '\u7cfb\u7edf\u53c2\u6570\u8bbe\u7f6e', subtitle: '\u7b56\u7565\u53c2\u6570\u4e0e\u9ed8\u8ba4\u89c4\u5219\u7ef4\u62a4', icon: '⚙', iconBg: THEME_SURFACE_MUTED }
]

const MANAGED_ROLES: ManagedRole[] = ['ADMIN', 'APPROVER', 'HOTEL_ADMIN', 'COMPLAINT_HANDLER', 'SYSTEM_ADMIN']

const PERMISSION_MATRIX: PermissionMatrixItem[] = [
  { role: 'VISITOR', title: '\u6e38\u5ba2', permissions: ['\u67e5\u8be2\u670d\u52a1\u4fe1\u606f', '\u67e5\u770b\u5e94\u6025\u4fe1\u606f', '\u63d0\u4ea4\u4e0e\u8bc4\u4ef7\u6295\u8bc9'] },
  { role: 'ADMIN', title: '\u5e73\u53f0\u7ba1\u7406\u5458', permissions: ['\u6295\u8bc9\u7ba1\u7406', '\u5e94\u6025\u53d1\u5e03', '\u5bfc\u6d41\u8425\u9500', '\u65c5\u6e38\u8d44\u6e90\u5e93'] },
  { role: 'APPROVER', title: '\u5e94\u6025\u5ba1\u6279\u5458', permissions: ['\u5e94\u6025\u5ba1\u6279', '\u9a73\u56de\u4e0e\u67e5\u8be2'] },
  { role: 'COMPLAINT_HANDLER', title: '\u6295\u8bc9\u5904\u7406\u5458', permissions: ['\u5904\u7406\u5206\u6d3e\u6295\u8bc9', '\u63d0\u4ea4\u5904\u7406\u7ed3\u679c'] },
  { role: 'HOTEL_ADMIN', title: '\u9152\u5e97\u7ba1\u7406\u5458', permissions: ['\u9152\u5e97\u8d44\u6599\u7ef4\u62a4', '\u623f\u6001\u540c\u6b65'] },
  { role: 'SYSTEM_ADMIN', title: '\u7cfb\u7edf\u7ba1\u7406\u5458', permissions: ['\u8d26\u53f7\u7ba1\u7406', '\u65e5\u5fd7\u5ba1\u8ba1', '\u7cfb\u7edf\u53c2\u6570\u7ef4\u62a4'] }
]

@Component
export struct SystemAdminPage {
  @State private section: SystemAdminSection = 'home'
  @State private pressedSection: string = ''
  @State private users: SystemUserResponse[] = []
  @State private hotels: HotelResponse[] = []
  @State private auditPage: AuditLogPageResponse = { items: [], total: 0, page: 0, size: 20 }
  @State private settings: SystemSettingResponse[] = []
  @State private homeLoading: boolean = false
  @State private homeError: string = ''
  @State private accountLoading: boolean = false
  @State private accountSaving: boolean = false
  @State private accountMessage: string = ''
  @State private logsLoading: boolean = false
  @State private logsMessage: string = ''
  @State private settingsLoading: boolean = false
  @State private settingsMessage: string = ''
  @State private selectedUserId: number = 0
  @State private roleInput: ManagedRole = 'ADMIN'
  @State private usernameInput: string = ''
  @State private displayNameInput: string = ''
  @State private passwordInput: string = '123456'
  @State private managedHotelIdInput: string = ''
  @State private resetPasswordInput: string = '123456'
  @State private logActorInput: string = ''
  @State private logModuleInput: string = ''
  @State private logActionInput: string = ''
  @State private editingSettingKey: string = ''
  @State private settingValueInput: string = ''
  @State private settingDescriptionInput: string = ''

  async aboutToAppear(): Promise<void> {
    await this.loadAllData()
  }

  private async loadAllData(): Promise<void> {
    await Promise.all([this.loadUsers(), this.loadHotels(), this.loadAuditLogs(), this.loadSettings()])
  }

  private async loadUsers(): Promise<void> {
    this.accountLoading = true
    try {
      this.users = await apiClient.get<SystemUserResponse[]>('/api/system/users')
      this.accountMessage = ''
    } catch (error) {
      this.accountMessage = this.resolveErrorMessage(error, '\u52a0\u8f7d\u7cfb\u7edf\u8d26\u53f7\u5931\u8d25\uff0c\u8bf7\u7a0d\u540e\u91cd\u8bd5')
    } finally {
      this.accountLoading = false
    }
  }

  private async loadHotels(): Promise<void> {
    try {
      this.hotels = await apiClient.get<HotelResponse[]>('/api/query/hotels')
    } catch (_error) {
      this.hotels = []
    }
  }

  private async loadAuditLogs(): Promise<void> {
    this.logsLoading = true
    try {
      this.auditPage = await apiClient.get<AuditLogPageResponse>(this.auditLogPath())
      this.logsMessage = ''
    } catch (error) {
      this.logsMessage = this.resolveErrorMessage(error, '\u52a0\u8f7d\u64cd\u4f5c\u65e5\u5fd7\u5931\u8d25\uff0c\u8bf7\u7a0d\u540e\u91cd\u8bd5')
      this.homeError = '\u7cfb\u7edf\u4e2d\u5fc3\u6458\u8981\u52a0\u8f7d\u4e0d\u5b8c\u6574\uff0c\u8bf7\u7a0d\u540e\u5237\u65b0'
    } finally {
      this.logsLoading = false
    }
  }

  private async loadSettings(): Promise<void> {
    this.settingsLoading = true
    try {
      this.settings = await apiClient.get<SystemSettingResponse[]>('/api/system/settings')
      this.settingsMessage = ''
    } catch (error) {
      this.settingsMessage = this.resolveErrorMessage(error, '\u52a0\u8f7d\u7cfb\u7edf\u53c2\u6570\u5931\u8d25\uff0c\u8bf7\u7a0d\u540e\u91cd\u8bd5')
      this.homeError = '\u7cfb\u7edf\u4e2d\u5fc3\u6458\u8981\u52a0\u8f7d\u4e0d\u5b8c\u6574\uff0c\u8bf7\u7a0d\u540e\u5237\u65b0'
    } finally {
      this.settingsLoading = false
    }
  }

  private buildActorQuery(): string {
    return this.buildQueryPart('actor', this.logActorInput)
  }

  private buildModuleQuery(): string {
    return this.buildQueryPart('module', this.logModuleInput)
  }

  private buildActionQuery(): string {
    return this.buildQueryPart('action', this.logActionInput)
  }

  private buildQueryPart(name: string, value: string): string {
    const trimmed: string = value.trim()
    if (trimmed.length === 0) {
      return ''
    }
    return `&${name}=${trimmed}`
  }

  private auditLogPath(): string {
    return `/api/system/audit-logs?page=0&size=20${this.buildActorQuery()}${this.buildModuleQuery()}${this.buildActionQuery()}`
  }

  private async refreshHome(): Promise<void> {
    this.homeLoading = true
    this.homeError = ''
    await this.loadAllData()
    this.homeLoading = false
  }

  private switchSection(section: SystemAdminSection): void {
    this.section = section
    this.pressedSection = ''
    if (section === 'home') {
      void this.refreshHome()
    }
  }

  private updatePressedSection(key: SystemAdminSection, pressed: boolean): void {
    this.pressedSection = pressed ? key : ''
  }

  private cardScale(key: SystemAdminSection): number {
    return this.pressedSection === key ? 0.97 : 1
  }

  private cardBg(key: SystemAdminSection): string {
    return this.pressedSection === key ? '#F8FBFF' : THEME_SURFACE
  }

  private totalUsersText(): string {
    return `${this.users.length}`
  }

  private activeUsersText(): string {
    return `${this.enabledUserCount()}`
  }

  private enabledUserCount(): number {
    let count: number = 0
    this.users.forEach((item: SystemUserResponse) => {
      if (item.enabled) {
        count += 1
      }
    })
    return count
  }

  private warningLogCount(): number {
    let count: number = 0
    this.auditPage.items.forEach((item: AuditLogResponse) => {
      if (this.isWarningLog(item)) {
        count += 1
      }
    })
    return count
  }

  private isWarningLog(item: AuditLogResponse): boolean {
    return item.action.includes('DISABLE') || item.detail.includes('\u8d8a\u6743') || item.detail.includes('\u5931\u8d25')
  }

  private statusLabel(): string {
    if (this.warningLogCount() > 0) {
      return '\u9700\u5173\u6ce8'
    }
    return '\u5b89\u5168'
  }

  private runningText(): string {
    if (this.settings.length > 0) {
      return '\u5df2\u63a5\u5165\u771f\u5b9e\u7cfb\u7edf\u53c2\u6570\u4e0e\u65e5\u5fd7\u6570\u636e'
    }
    return '\u6b63\u5728\u540c\u6b65\u7cfb\u7edf\u914d\u7f6e\u72b6\u6001'
  }

  private latestLogs(): AuditLogResponse[] {
    return this.auditPage.items.slice(0, 4)
  }

  private logDotColor(item: AuditLogResponse): string {
    if (this.isWarningLog(item)) {
      return THEME_DANGER
    }
    if (item.module === 'SYSTEM') {
      return THEME_PRIMARY
    }
    return THEME_SUCCESS
  }

  private logTitle(item: AuditLogResponse): string {
    return `${item.module} · ${item.action}`
  }

  private logSubtitle(item: AuditLogResponse): string {
    return `${item.actorUsername} · ${this.formatDateTime(item.createdAt)}`
  }

  private roleTitle(role: ManagedRole): string {
    if (role === 'APPROVER') {
      return '\u5e94\u6025\u5ba1\u6279\u5458'
    }
    if (role === 'HOTEL_ADMIN') {
      return '\u9152\u5e97\u7ba1\u7406\u5458'
    }
    if (role === 'COMPLAINT_HANDLER') {
      return '\u6295\u8bc9\u5904\u7406\u5458'
    }
    if (role === 'SYSTEM_ADMIN') {
      return '\u7cfb\u7edf\u7ba1\u7406\u5458'
    }
    return '\u5e73\u53f0\u7ba1\u7406\u5458'
  }

  private roleSubtitle(role: ManagedRole): string {
    if (role === 'APPROVER') {
      return '\u8d1f\u8d23\u5ba1\u6838\u4e0e\u9a73\u56de\u5e94\u6025\u9884\u8b66'
    }
    if (role === 'HOTEL_ADMIN') {
      return '\u8d1f\u8d23\u672c\u9152\u5e97\u8d44\u6599\u4e0e\u623f\u6001\u7ef4\u62a4'
    }
    if (role === 'COMPLAINT_HANDLER') {
      return '\u8d1f\u8d23\u5904\u7406\u73b0\u573a\u6216\u670d\u52a1\u6295\u8bc9'
    }
    if (role === 'SYSTEM_ADMIN') {
      return '\u8d1f\u8d23\u8d26\u53f7\u3001\u65e5\u5fd7\u4e0e\u53c2\u6570\u7ef4\u62a4'
    }
    return '\u8d1f\u8d23\u5e73\u53f0\u8fd0\u8425\u4e0e\u8d44\u6e90\u7ba1\u7406'
  }

  private roleButtonBg(role: ManagedRole): string {
    return this.roleInput === role ? THEME_PRIMARY : THEME_SURFACE_MUTED
  }

  private roleButtonColor(role: ManagedRole): string {
    return this.roleInput === role ? '#FFFFFF' : THEME_TEXT_SECONDARY
  }

  private roleValue(role: UserRole | string): ManagedRole {
    switch (role) {
      case 'APPROVER':
      case 'HOTEL_ADMIN':
      case 'COMPLAINT_HANDLER':
      case 'SYSTEM_ADMIN':
        return role
      default:
        return 'ADMIN'
    }
  }

  private resetForm(): void {
    this.selectedUserId = 0
    this.roleInput = 'ADMIN'
    this.usernameInput = ''
    this.displayNameInput = ''
    this.passwordInput = '123456'
    this.managedHotelIdInput = ''
    this.resetPasswordInput = '123456'
  }

  private selectUser(item: SystemUserResponse): void {
    this.selectedUserId = item.id
    this.roleInput = this.roleValue(item.role)
    this.usernameInput = item.username
    this.displayNameInput = item.displayName
    this.managedHotelIdInput = item.managedHotelId === null ? '' : item.managedHotelId
    this.accountMessage = `\u5df2\u8f7d\u5165\u8d26\u53f7 ${item.username}\uff0c\u53ef\u66f4\u65b0\u89d2\u8272\u4e0e\u5f52\u5c5e\u4fe1\u606f`
  }

  private requiresHotelBinding(): boolean {
    return this.roleInput === 'HOTEL_ADMIN'
  }

  private saveButtonText(): string {
    return this.selectedUserId > 0 ? '\u4fdd\u5b58\u8d26\u53f7\u4fee\u6539' : '\u521b\u5efa\u7cfb\u7edf\u8d26\u53f7'
  }

  private canSaveAccount(): boolean {
    if (this.usernameInput.trim().length === 0) {
      return false
    }
    if (this.displayNameInput.trim().length === 0) {
      return false
    }
    if (this.selectedUserId === 0 && this.passwordInput.trim().length < 6) {
      return false
    }
    if (this.requiresHotelBinding() && this.managedHotelIdInput.trim().length === 0) {
      return false
    }
    return true
  }

  private accountCardTitle(): string {
    return this.selectedUserId > 0 ? '\u7f16\u8f91\u7cfb\u7edf\u8d26\u53f7' : '\u5206\u914d\u65b0\u7cfb\u7edf\u8d26\u53f7'
  }

  private async saveAccount(): Promise<void> {
    if (!this.canSaveAccount()) {
      this.accountMessage = '\u8bf7\u5148\u8865\u9f50\u8d26\u53f7\u3001\u59d3\u540d\u3001\u5bc6\u7801\u6216\u9152\u5e97\u7ed1\u5b9a\u4fe1\u606f'
      return
    }
    this.accountSaving = true
    try {
      if (this.selectedUserId > 0) {
        const updateRequest: SystemUserUpdateRequest = {
          displayName: this.displayNameInput.trim(),
          role: this.roleInput,
          managedHotelId: this.requiresHotelBinding() ? this.managedHotelIdInput.trim() : ''
        }
        await apiClient.put<SystemUserUpdateRequest, SystemUserResponse>(`/api/system/users/${this.selectedUserId}`, updateRequest)
        this.accountMessage = '\u8d26\u53f7\u4fe1\u606f\u5df2\u66f4\u65b0'
      } else {
        const createRequest: SystemUserCreateRequest = {
          username: this.usernameInput.trim(),
          displayName: this.displayNameInput.trim(),
          role: this.roleInput,
          password: this.passwordInput.trim(),
          managedHotelId: this.requiresHotelBinding() ? this.managedHotelIdInput.trim() : ''
        }
        await apiClient.post<SystemUserCreateRequest, SystemUserResponse>('/api/system/users', createRequest)
        this.accountMessage = '\u65b0\u8d26\u53f7\u5df2\u521b\u5efa\u5e76\u540c\u6b65\u5230\u7cfb\u7edf'
      }
      this.resetForm()
      await this.loadUsers()
    } catch (error) {
      this.accountMessage = this.resolveErrorMessage(error, '\u8d26\u53f7\u4fdd\u5b58\u5931\u8d25\uff0c\u8bf7\u7a0d\u540e\u91cd\u8bd5')
    } finally {
      this.accountSaving = false
    }
  }

  private async toggleUser(item: SystemUserResponse): Promise<void> {
    this.accountSaving = true
    try {
      const path: string = item.enabled ? `/api/system/users/${item.id}/disable` : `/api/system/users/${item.id}/enable`
      await apiClient.post<Record<string, string>, SystemUserResponse>(path, {})
      this.accountMessage = item.enabled ? '\u8d26\u53f7\u5df2\u505c\u7528' : '\u8d26\u53f7\u5df2\u542f\u7528'
      await this.loadUsers()
    } catch (error) {
      this.accountMessage = this.resolveErrorMessage(error, '\u8d26\u53f7\u72b6\u6001\u66f4\u65b0\u5931\u8d25\uff0c\u8bf7\u7a0d\u540e\u91cd\u8bd5')
    } finally {
      this.accountSaving = false
    }
  }

  private async resetPassword(item: SystemUserResponse): Promise<void> {
    if (this.resetPasswordInput.trim().length < 6) {
      this.accountMessage = '\u91cd\u7f6e\u5bc6\u7801\u81f3\u5c11\u9700\u8981 6 \u4f4d'
      return
    }
    this.accountSaving = true
    try {
      const payload: SystemUserResetPasswordRequest = { newPassword: this.resetPasswordInput.trim() }
      await apiClient.post<SystemUserResetPasswordRequest, Record<string, string>>(`/api/system/users/${item.id}/reset-password`, payload)
      this.accountMessage = `\u5df2\u91cd\u7f6e ${item.username} \u7684\u767b\u5f55\u5bc6\u7801`
    } catch (error) {
      this.accountMessage = this.resolveErrorMessage(error, '\u5bc6\u7801\u91cd\u7f6e\u5931\u8d25\uff0c\u8bf7\u7a0d\u540e\u91cd\u8bd5')
    } finally {
      this.accountSaving = false
    }
  }

  private managedHotelName(): string {
    if (this.managedHotelIdInput.trim().length === 0) {
      return '\u672a\u9009\u62e9\u9152\u5e97'
    }
    const selected: HotelResponse | undefined = this.hotels.find((item: HotelResponse) => item.id === this.managedHotelIdInput.trim())
    if (selected === undefined) {
      return `\u5f53\u524d\u7ed1\u5b9a\uff1a${this.managedHotelIdInput.trim()}`
    }
    return `${selected.name} · ${selected.id}`
  }

  private selectHotelBinding(id: string): void {
    this.managedHotelIdInput = id
  }

  private async applyLogFilter(): Promise<void> {
    await this.loadAuditLogs()
  }

  private startEditSetting(item: SystemSettingResponse): void {
    this.editingSettingKey = item.key
    this.settingValueInput = item.value
    this.settingDescriptionInput = item.description
  }

  private cancelEditSetting(): void {
    this.editingSettingKey = ''
    this.settingValueInput = ''
    this.settingDescriptionInput = ''
  }

  private async saveSetting(): Promise<void> {
    if (this.editingSettingKey.length === 0 || this.settingValueInput.trim().length === 0) {
      this.settingsMessage = '\u8bf7\u5148\u9009\u62e9\u53c2\u6570\u5e76\u586b\u5199\u65b0\u7684\u503c'
      return
    }
    this.settingsLoading = true
    try {
      const payload: SystemSettingUpdateRequest = {
        value: this.settingValueInput.trim(),
        description: this.settingDescriptionInput.trim()
      }
      await apiClient.put<SystemSettingUpdateRequest, SystemSettingResponse>(`/api/system/settings/${this.editingSettingKey}`, payload)
      this.settingsMessage = '\u7cfb\u7edf\u53c2\u6570\u5df2\u66f4\u65b0'
      this.cancelEditSetting()
      await this.loadSettings()
    } catch (error) {
      this.settingsMessage = this.resolveErrorMessage(error, '\u7cfb\u7edf\u53c2\u6570\u4fdd\u5b58\u5931\u8d25\uff0c\u8bf7\u7a0d\u540e\u91cd\u8bd5')
    } finally {
      this.settingsLoading = false
    }
  }

  private resolveErrorMessage(error: Object, fallback: string): string {
    if (error instanceof Error && error.message.trim().length > 0) {
      return error.message
    }
    return fallback
  }

  private formatDateTime(value: string): string {
    if (value.length >= 16) {
      return value.substring(0, 16).replace('T', ' ')
    }
    return value
  }

  private userRoleLabel(item: SystemUserResponse): string {
    return this.roleTitle(this.roleValue(item.role))
  }

  private userStateText(item: SystemUserResponse): string {
    return item.enabled ? '\u542f\u7528\u4e2d' : '\u5df2\u505c\u7528'
  }

  private userStateBg(item: SystemUserResponse): string {
    return item.enabled ? '#EAF8EF' : '#FFECEC'
  }

  private userStateColor(item: SystemUserResponse): string {
    return item.enabled ? THEME_SUCCESS : THEME_DANGER
  }

  private settingUpdatedText(item: SystemSettingResponse): string {
    return `${item.updatedBy} · ${this.formatDateTime(item.updatedAt)}`
  }

  @Builder
  private SectionTitle(title: string, subtitle: string): void {
    Row() {
      Column({ space: 4 }) {
        Text(title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
        Text(subtitle)
          .fontSize(12)
          .fontColor(THEME_TEXT_SECONDARY)
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      if (this.section !== 'home') {
        Button('\u8fd4\u56de\u6982\u89c8')
          .height(34)
          .padding({ left: 14, right: 14 })
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_PRIMARY_SOFT)
          .fontColor(THEME_PRIMARY)
          .fontSize(12)
          .onClick(() => this.switchSection('home'))
      } else {
        Button(this.homeLoading ? '\u5237\u65b0\u4e2d' : '\u5237\u65b0\u6570\u636e')
          .height(34)
          .padding({ left: 14, right: 14 })
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_PRIMARY_SOFT)
          .fontColor(THEME_PRIMARY)
          .fontSize(12)
          .onClick(() => {
            this.refreshHome()
          })
      }
    }
    .width('100%')
  }

  @Builder
  private HomeSection(): void {
    Column({ space: 18 }) {
      this.SectionTitle('\u7cfb\u7edf\u7ba1\u7406\u4e2d\u5fc3', '\u8d26\u53f7\u3001\u65e5\u5fd7\u3001\u53c2\u6570\u7684\u771f\u5b9e\u7ba1\u63a7\u5165\u53e3')

      Column({ space: 18 }) {
        Row() {
          Column({ space: 8 }) {
            Text('\u7cfb\u7edf\u8fd0\u884c\u72b6\u6001')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Text(this.runningText())
              .fontSize(12)
              .fontColor('#EAF2FF')
          }
          .alignItems(HorizontalAlign.Start)
          Blank()
          Text(this.statusLabel())
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor('#4DA3FF')
            .borderRadius(RADIUS_PILL)
        }
        .width('100%')

        Row() {
          this.MetricCard('\u6ce8\u518c\u540e\u53f0\u8d26\u53f7\u603b\u6570', this.totalUsersText())
          Blank().width(1).height(42).backgroundColor('#52A7FF')
          this.MetricCard('\u4eca\u65e5\u6d3b\u8dc3\u8d26\u53f7', this.activeUsersText())
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#2F8DFF')
        .borderRadius(RADIUS_MD)
      }
      .width('100%')
      .padding(22)
      .backgroundColor(THEME_PRIMARY)
      .borderRadius(26)
      .shadow(SHADOW_PANEL)

      Column({ space: 14 }) {
        Text('\u6838\u5fc3\u7ba1\u7406\u57df')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
          .width('100%')
        Row({ space: 14 }) {
          this.ModuleCard(SYSTEM_MODULE_ITEMS[0])
          this.ModuleCard(SYSTEM_MODULE_ITEMS[1])
        }
        .width('100%')
        Row({ space: 14 }) {
          this.ModuleCard(SYSTEM_MODULE_ITEMS[2])
          this.ModuleCard(SYSTEM_MODULE_ITEMS[3])
        }
        .width('100%')
      }
      .width('100%')

      Column({ space: 12 }) {
        Row() {
          Text('\u5b9e\u65f6\u5b89\u5168\u9884\u8b66')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(THEME_TEXT_PRIMARY)
          Blank()
          Text('\u5b8c\u6574\u65e5\u5fd7')
            .fontSize(12)
            .fontColor(THEME_PRIMARY)
            .onClick(() => this.switchSection('logs'))
        }
        .width('100%')

        if (this.homeError.length > 0) {
          Text(this.homeError)
            .fontSize(12)
            .fontColor(THEME_DANGER)
            .width('100%')
        }

        if (this.latestLogs().length === 0) {
          this.EmptyCard('\u6682\u65e0\u5b89\u5168\u9884\u8b66', '\u5f53\u524d\u672a\u68c0\u6d4b\u5230\u5f02\u5e38\u64cd\u4f5c\u8bb0\u5f55')
        } else {
          Column() {
            ForEach(this.latestLogs(), (item: AuditLogResponse) => {
              this.LogRow(item)
            }, (item: AuditLogResponse) => `${item.id}`)
          }
          .width('100%')
          .backgroundColor(THEME_SURFACE)
          .borderRadius(RADIUS_LG)
          .shadow(SHADOW_CARD)
        }
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  private MetricCard(label: string, value: string): void {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(12)
        .fontColor('#DCEBFF')
      Text(value)
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private ModuleCard(item: SystemModuleCardItem): void {
    Column({ space: 18 }) {
      Text(item.icon)
        .fontSize(20)
        .textAlign(TextAlign.Center)
        .width(48)
        .height(48)
        .backgroundColor(item.iconBg)
        .borderRadius(RADIUS_PILL)
      Column({ space: 6 }) {
        Text(item.title)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
        Text(item.subtitle)
          .fontSize(12)
          .fontColor(THEME_TEXT_SECONDARY)
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .layoutWeight(1)
    .height(148)
    .padding(18)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.cardBg(item.key))
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
    .scale({ x: this.cardScale(item.key), y: this.cardScale(item.key) })
    .animation({ duration: 120, curve: Curve.EaseOut })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.updatePressedSection(item.key, true)
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.updatePressedSection(item.key, false)
      }
    })
    .onClick(() => this.switchSection(item.key))
  }

  @Builder
  private LogRow(item: AuditLogResponse): void {
    Row({ space: 12 }) {
      Text('')
        .width(8)
        .height(8)
        .backgroundColor(this.logDotColor(item))
        .borderRadius(RADIUS_PILL)
      Column({ space: 4 }) {
        Text(this.logTitle(item))
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(THEME_TEXT_PRIMARY)
        Text(this.logSubtitle(item))
          .fontSize(12)
          .fontColor(THEME_TEXT_TERTIARY)
        Text(item.detail)
          .fontSize(12)
          .fontColor(THEME_TEXT_SECONDARY)
          .maxLines(2)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 14, bottom: 14 })
  }

  @Builder
  private AccountRoleButton(role: ManagedRole): void {
    Button(`${this.roleTitle(role)}  ${this.roleSubtitle(role)}`)
      .height(42)
      .width('100%')
      .borderRadius(RADIUS_PILL)
      .backgroundColor(this.roleButtonBg(role))
      .fontColor(this.roleButtonColor(role))
      .fontSize(12)
      .onClick(() => {
        this.roleInput = role
      })
  }

  @Builder
  private AccountForm(): void {
    Column({ space: 14 }) {
      Text(this.accountCardTitle())
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(THEME_TEXT_PRIMARY)
        .width('100%')

      Column({ space: 10 }) {
        ForEach(MANAGED_ROLES, (role: ManagedRole) => {
          this.AccountRoleButton(role)
        }, (role: ManagedRole) => role)
      }
      .width('100%')

      TextInput({ placeholder: '\u767b\u5f55\u8d26\u53f7\uff0c\u5982\uff1aadmin_zhang', text: this.usernameInput })
        .onChange((value: string) => {
          this.usernameInput = value
        })
        .height(46)
        .padding(12)
        .backgroundColor(THEME_SURFACE_MUTED)
        .borderRadius(RADIUS_PILL)
        .enabled(this.selectedUserId === 0)

      TextInput({ placeholder: '\u663e\u793a\u59d3\u540d\uff0c\u5982\uff1a\u5e73\u53f0\u7ba1\u7406\u5458\u5f20\u4e09', text: this.displayNameInput })
        .onChange((value: string) => {
          this.displayNameInput = value
        })
        .height(46)
        .padding(12)
        .backgroundColor(THEME_SURFACE_MUTED)
        .borderRadius(RADIUS_PILL)

      if (this.selectedUserId === 0) {
        TextInput({ placeholder: '\u521d\u59cb\u5bc6\u7801\uff0c\u9ed8\u8ba4 123456', text: this.passwordInput })
          .type(InputType.Password)
          .onChange((value: string) => {
            this.passwordInput = value
          })
          .height(46)
          .padding(12)
          .backgroundColor(THEME_SURFACE_MUTED)
          .borderRadius(RADIUS_PILL)
      }

      if (this.requiresHotelBinding()) {
        Column({ space: 10 }) {
          Text(`\u7ed1\u5b9a\u9152\u5e97\uff1a${this.managedHotelName()}`)
            .fontSize(12)
            .fontColor(THEME_TEXT_SECONDARY)
            .width('100%')
          Scroll() {
            Row({ space: 8 }) {
              ForEach(this.hotels, (item: HotelResponse) => {
                Button(item.name)
                  .height(36)
                  .padding({ left: 14, right: 14 })
                  .borderRadius(RADIUS_PILL)
                  .backgroundColor(this.managedHotelIdInput === item.id ? THEME_PRIMARY : '#EEF3FA')
                  .fontColor(this.managedHotelIdInput === item.id ? '#FFFFFF' : THEME_TEXT_SECONDARY)
                  .fontSize(12)
                  .onClick(() => {
                    this.selectHotelBinding(item.id)
                  })
              }, (item: HotelResponse) => item.id)
            }
            .padding({ right: 12 })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')
          .height(42)
        }
        .width('100%')
      }

      Row({ space: 10 }) {
        Button(this.saveButtonText())
          .layoutWeight(1)
          .height(46)
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_PRIMARY)
          .fontColor('#FFFFFF')
          .enabled(!this.accountSaving)
          .onClick(() => {
            this.saveAccount()
          })
        Button('\u6e05\u7a7a')
          .height(46)
          .padding({ left: 18, right: 18 })
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_SURFACE_MUTED)
          .fontColor(THEME_TEXT_SECONDARY)
          .onClick(() => this.resetForm())
      }
      .width('100%')

      if (this.accountMessage.length > 0) {
        Text(this.accountMessage)
          .fontSize(12)
          .fontColor(this.accountMessage.includes('\u5931\u8d25') || this.accountMessage.includes('\u8bf7') ? THEME_DANGER : THEME_SUCCESS)
          .width('100%')
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private UserRow(item: SystemUserResponse): void {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 6 }) {
          Text(item.displayName)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(THEME_TEXT_PRIMARY)
          Text(`${item.username} · ${this.userRoleLabel(item)}`)
            .fontSize(12)
            .fontColor(THEME_TEXT_SECONDARY)
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        Text(this.userStateText(item))
          .fontSize(11)
          .fontColor(this.userStateColor(item))
          .backgroundColor(this.userStateBg(item))
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .borderRadius(RADIUS_PILL)
      }
      .width('100%')

      if (item.managedHotelId !== null && item.managedHotelId.length > 0) {
        Text(`\u7ed1\u5b9a\u9152\u5e97\uff1a${item.managedHotelId}`)
          .fontSize(12)
          .fontColor(THEME_TEXT_SECONDARY)
          .width('100%')
      }

      Text(`\u521b\u5efa\u65f6\u95f4\uff1a${this.formatDateTime(item.createdAt)}`)
        .fontSize(12)
        .fontColor(THEME_TEXT_TERTIARY)
        .width('100%')

      Row({ space: 8 }) {
        Button('\u7f16\u8f91')
          .height(34)
          .padding({ left: 14, right: 14 })
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_PRIMARY_SOFT)
          .fontColor(THEME_PRIMARY)
          .fontSize(12)
          .onClick(() => this.selectUser(item))
        Button(item.enabled ? '\u505c\u7528' : '\u542f\u7528')
          .height(34)
          .padding({ left: 14, right: 14 })
          .borderRadius(RADIUS_PILL)
          .backgroundColor(item.enabled ? '#FFECEC' : '#EAF8EF')
          .fontColor(item.enabled ? THEME_DANGER : THEME_SUCCESS)
          .fontSize(12)
          .onClick(() => {
            this.toggleUser(item)
          })
        Button('\u91cd\u7f6e\u5bc6\u7801')
          .height(34)
          .padding({ left: 14, right: 14 })
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_SURFACE_MUTED)
          .fontColor(THEME_TEXT_SECONDARY)
          .fontSize(12)
          .onClick(() => {
            this.resetPassword(item)
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(18)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private AccountSection(): void {
    Column({ space: 18 }) {
      this.SectionTitle('\u8d26\u53f7\u4e0e\u6743\u9650', '\u521b\u5efa\u8d26\u53f7\u3001\u4fee\u6539\u89d2\u8272\u3001\u7ed1\u5b9a\u9152\u5e97\u4e0e\u91cd\u7f6e\u5bc6\u7801')
      this.AccountForm()

      TextInput({ placeholder: '\u91cd\u7f6e\u5bc6\u7801\u65f6\u4f7f\u7528\u7684\u65b0\u5bc6\u7801\uff0c\u9ed8\u8ba4 123456', text: this.resetPasswordInput })
        .type(InputType.Password)
        .onChange((value: string) => {
          this.resetPasswordInput = value
        })
        .height(44)
        .padding(12)
        .backgroundColor(THEME_SURFACE)
        .borderRadius(RADIUS_PILL)

      if (this.accountLoading && this.users.length === 0) {
        this.EmptyCard('\u6b63\u5728\u52a0\u8f7d\u8d26\u53f7\u5217\u8868', '\u7cfb\u7edf\u8d26\u53f7\u6570\u636e\u540c\u6b65\u4e2d')
      } else {
        Column({ space: 12 }) {
          ForEach(this.users, (item: SystemUserResponse) => {
            this.UserRow(item)
          }, (item: SystemUserResponse) => `${item.id}`)
        }
        .width('100%')
      }
    }
    .width('100%')
  }

  @Builder
  private LogsFilterBar(): void {
    Column({ space: 10 }) {
      Row({ space: 10 }) {
        TextInput({ placeholder: '\u8d26\u53f7', text: this.logActorInput })
          .onChange((value: string) => {
            this.logActorInput = value
          })
          .layoutWeight(1)
          .height(44)
          .padding(12)
          .backgroundColor(THEME_SURFACE_MUTED)
          .borderRadius(RADIUS_PILL)
        TextInput({ placeholder: '\u6a21\u5757', text: this.logModuleInput })
          .onChange((value: string) => {
            this.logModuleInput = value
          })
          .layoutWeight(1)
          .height(44)
          .padding(12)
          .backgroundColor(THEME_SURFACE_MUTED)
          .borderRadius(RADIUS_PILL)
      }
      .width('100%')
      Row({ space: 10 }) {
        TextInput({ placeholder: '\u52a8\u4f5c', text: this.logActionInput })
          .onChange((value: string) => {
            this.logActionInput = value
          })
          .layoutWeight(1)
          .height(44)
          .padding(12)
          .backgroundColor(THEME_SURFACE_MUTED)
          .borderRadius(RADIUS_PILL)
        Button('\u67e5\u8be2\u65e5\u5fd7')
          .height(44)
          .padding({ left: 18, right: 18 })
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_PRIMARY)
          .fontColor('#FFFFFF')
          .onClick(() => {
            this.applyLogFilter()
          })
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  private LogsSection(): void {
    Column({ space: 18 }) {
      this.SectionTitle('\u64cd\u4f5c\u65e5\u5fd7\u5ba1\u8ba1', '\u6309\u8d26\u53f7\u3001\u6a21\u5757\u3001\u52a8\u4f5c\u7b5b\u9009\u7cfb\u7edf\u884c\u4e3a\u8bb0\u5f55')
      this.LogsFilterBar()
      if (this.logsMessage.length > 0) {
        Text(this.logsMessage)
          .fontSize(12)
          .fontColor(THEME_DANGER)
          .width('100%')
      }
      if (this.logsLoading && this.auditPage.items.length === 0) {
        this.EmptyCard('\u6b63\u5728\u52a0\u8f7d\u64cd\u4f5c\u65e5\u5fd7', '\u8bf7\u7a0d\u5019\uff0c\u6211\u4eec\u6b63\u5728\u540c\u6b65\u5ba1\u8ba1\u8bb0\u5f55')
      } else if (this.auditPage.items.length === 0) {
        this.EmptyCard('\u6682\u65e0\u65e5\u5fd7\u7ed3\u679c', '\u5f53\u524d\u7b5b\u9009\u6761\u4ef6\u4e0b\u6ca1\u6709\u5ba1\u8ba1\u8bb0\u5f55')
      } else {
        Column() {
          ForEach(this.auditPage.items, (item: AuditLogResponse) => {
            this.LogRow(item)
          }, (item: AuditLogResponse) => `${item.id}`)
        }
        .width('100%')
        .backgroundColor(THEME_SURFACE)
        .borderRadius(RADIUS_LG)
        .shadow(SHADOW_CARD)
      }
    }
    .width('100%')
  }

  @Builder
  private PermissionRow(item: PermissionMatrixItem): void {
    Column({ space: 10 }) {
      Row() {
        Text(item.title)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
        Blank()
        Text(item.role)
          .fontSize(11)
          .fontColor(THEME_PRIMARY)
          .backgroundColor(THEME_PRIMARY_SOFT)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .borderRadius(RADIUS_PILL)
      }
      .width('100%')
      Scroll() {
        Row({ space: 8 }) {
          ForEach(item.permissions, (permission: string) => {
            Text(permission)
              .fontSize(11)
              .fontColor(THEME_TEXT_SECONDARY)
              .backgroundColor(THEME_SURFACE_MUTED)
              .padding({ left: 10, right: 10, top: 5, bottom: 5 })
              .borderRadius(RADIUS_PILL)
          }, (permission: string) => permission)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .height(32)
    }
    .width('100%')
    .padding(18)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private RbacSection(): void {
    Column({ space: 18 }) {
      this.SectionTitle('RBAC \u89d2\u8272\u914d\u7f6e', '\u56fa\u5b9a\u4e94\u89d2\u8272\u6743\u9650\u6620\u5c04\uff0c\u4e0e\u540e\u7aef\u5b9e\u9645\u6743\u9650\u4fdd\u6301\u4e00\u81f4')
      Column({ space: 12 }) {
        ForEach(PERMISSION_MATRIX, (item: PermissionMatrixItem) => {
          this.PermissionRow(item)
        }, (item: PermissionMatrixItem) => item.role)
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  private SettingRow(item: SystemSettingResponse): void {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 4 }) {
          Text(item.key)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor(THEME_TEXT_PRIMARY)
          Text(item.description)
            .fontSize(12)
            .fontColor(THEME_TEXT_SECONDARY)
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        Button(this.editingSettingKey === item.key ? '\u7f16\u8f91\u4e2d' : '\u7f16\u8f91')
          .height(34)
          .padding({ left: 14, right: 14 })
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_PRIMARY_SOFT)
          .fontColor(THEME_PRIMARY)
          .fontSize(12)
          .onClick(() => this.startEditSetting(item))
      }
      .width('100%')

      Text(`\u5f53\u524d\u503c\uff1a${item.value}`)
        .fontSize(13)
        .fontColor(THEME_TEXT_PRIMARY)
        .width('100%')
      Text(`\u6700\u8fd1\u66f4\u65b0\uff1a${this.settingUpdatedText(item)}`)
        .fontSize(12)
        .fontColor(THEME_TEXT_TERTIARY)
        .width('100%')
    }
    .width('100%')
    .padding(18)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private SettingsEditor(): void {
    Column({ space: 12 }) {
      Text(this.editingSettingKey.length > 0 ? `\u7f16\u8f91\u53c2\u6570\uff1a${this.editingSettingKey}` : '\u9009\u62e9\u4e00\u4e2a\u53c2\u6570\u5f00\u59cb\u7f16\u8f91')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(THEME_TEXT_PRIMARY)
        .width('100%')
      TextInput({ placeholder: '\u65b0\u7684\u53c2\u6570\u503c', text: this.settingValueInput })
        .onChange((value: string) => {
          this.settingValueInput = value
        })
        .height(44)
        .padding(12)
        .backgroundColor(THEME_SURFACE_MUTED)
        .borderRadius(RADIUS_PILL)
      TextInput({ placeholder: '\u53c2\u6570\u8bf4\u660e\uff08\u53ef\u9009\uff09', text: this.settingDescriptionInput })
        .onChange((value: string) => {
          this.settingDescriptionInput = value
        })
        .height(44)
        .padding(12)
        .backgroundColor(THEME_SURFACE_MUTED)
        .borderRadius(RADIUS_PILL)
      Row({ space: 10 }) {
        Button('\u4fdd\u5b58\u53c2\u6570')
          .layoutWeight(1)
          .height(44)
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_PRIMARY)
          .fontColor('#FFFFFF')
          .enabled(this.editingSettingKey.length > 0 && !this.settingsLoading)
          .onClick(() => {
            this.saveSetting()
          })
        Button('\u53d6\u6d88')
          .height(44)
          .padding({ left: 18, right: 18 })
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_SURFACE_MUTED)
          .fontColor(THEME_TEXT_SECONDARY)
          .onClick(() => this.cancelEditSetting())
      }
      .width('100%')
      if (this.settingsMessage.length > 0) {
        Text(this.settingsMessage)
          .fontSize(12)
          .fontColor(this.settingsMessage.includes('\u5931\u8d25') || this.settingsMessage.includes('\u8bf7') ? THEME_DANGER : THEME_SUCCESS)
          .width('100%')
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private SettingsSection(): void {
    Column({ space: 18 }) {
      this.SectionTitle('\u7cfb\u7edf\u53c2\u6570\u8bbe\u7f6e', '\u7ef4\u62a4\u9a8c\u8bc1\u7801\u3001\u8d85\u65f6\u9608\u503c\u4e0e\u9ed8\u8ba4\u7b56\u7565')
      this.SettingsEditor()
      if (this.settingsLoading && this.settings.length === 0) {
        this.EmptyCard('\u6b63\u5728\u52a0\u8f7d\u7cfb\u7edf\u53c2\u6570', '\u7cfb\u7edf\u914d\u7f6e\u9879\u540c\u6b65\u4e2d')
      } else {
        Column({ space: 12 }) {
          ForEach(this.settings, (item: SystemSettingResponse) => {
            this.SettingRow(item)
          }, (item: SystemSettingResponse) => item.key)
        }
        .width('100%')
      }
    }
    .width('100%')
  }

  @Builder
  private EmptyCard(title: string, subtitle: string): void {
    Column({ space: 6 }) {
      Text(title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(THEME_TEXT_PRIMARY)
      Text(subtitle)
        .fontSize(12)
        .fontColor(THEME_TEXT_TERTIARY)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding({ top: 28, bottom: 28, left: 18, right: 18 })
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  build() {
    Scroll() {
      Column({ space: 20 }) {
        if (this.section === 'home') {
          this.HomeSection()
        } else if (this.section === 'account') {
          this.AccountSection()
        } else if (this.section === 'logs') {
          this.LogsSection()
        } else if (this.section === 'rbac') {
          this.RbacSection()
        } else {
          this.SettingsSection()
        }
      }
      .padding({ left: 20, right: 20, bottom: 30 })
      .width('100%')
    }
    .scrollBar(BarState.Off)
    .backgroundColor(THEME_PAGE_BG)
  }
}
