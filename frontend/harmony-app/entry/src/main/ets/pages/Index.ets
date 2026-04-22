import { AuthStore } from '../common/state/AuthStore'
import { ComplaintItem, EmergencyItem, ResourceItemResponse, UserRole } from '../common/model/ApiModels'
import { apiClient } from '../common/network/ApiClient'
import { ComplaintMode, ComplaintPage } from './modules/ComplaintPage'
import { EmergencyMode, EmergencyPage } from './modules/EmergencyPage'
import { HotelMode, HotelPage } from './modules/HotelPage'
import { ScenicRoutePage } from './modules/ScenicRoutePage'
import { DiningShowPage } from './modules/DiningShowPage'
import { WeatherTrafficPage } from './modules/WeatherTrafficPage'
import { VisitorHomePage } from './modules/VisitorHomePage'
import { VisitorServiceTab, VisitorServicesPage } from './modules/VisitorServicesPage'
import { ResourceLibraryPage } from './modules/ResourceLibraryPage'
import { MarketingPage } from './modules/MarketingPage'
import { SystemAdminPage } from './modules/SystemAdminPage'
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
} from '../common/ui/AppTheme'

type AuthMode = 'login' | 'register' | 'reset'
type VisitorNav = 'home' | 'services' | 'complaint' | 'emergency'
type AdminSection = 'home' | 'complaints' | 'emergency' | 'marketing' | 'resources' | 'system'
type SystemAdminSection = 'home' | 'account' | 'logs' | 'rbac' | 'settings'
type SystemAccountRole = 'ADMIN' | 'APPROVER' | 'HOTEL_ADMIN' | 'COMPLAINT_HANDLER'

interface TabItem {
  key: string
  title: string
}

interface VisitorNavItem {
  key: VisitorNav
  icon: string
  title: string
}

interface AdminTodoItem {
  icon: string
  title: string
  subtitle: string
  iconColor: string
  iconBg: string
  section: AdminSection
  sortTime: number
}

interface MarketingHotelItem {
  id: string
  name: string
  category: string
  area: string
  price: string
  score: string
  roomStatus: string
  statusColor: string
  imageUrl: string
  recommended: boolean
}

interface SystemManageItem {
  key: SystemAdminSection
  icon: string
  title: string
  subtitle: string
  iconColor: string
  iconBg: string
}

interface SystemLogItem {
  dotColor: string
  title: string
  subtitle: string
}

interface SystemAccountRoleOption {
  key: SystemAccountRole
  title: string
  subtitle: string
}

@Entry
@Component
struct Index {
  @State private selectedTabKey: string = ''
  @State private authMode: AuthMode = 'login'
  @State private visitorNav: VisitorNav = 'home'
  @State private visitorServiceTab: VisitorServiceTab = 'routes'
  @State private adminSection: AdminSection = 'home'
  @State private systemAdminSection: SystemAdminSection = 'home'
  @State private pressedAdminSection: string = ''
  @State private pressedSystemSection: string = ''
  @State private marketingMessage: string = ''
  @State private systemRoleInput: SystemAccountRole = 'ADMIN'
  @State private systemUsernameInput: string = ''
  @State private systemDisplayNameInput: string = ''
  @State private systemRemarkInput: string = ''
  @State private systemMessage: string = ''
  @State private dashboardComplaintPendingCount: number = 0
  @State private dashboardPublishedEmergencyCount: number = 0
  @State private dashboardPendingEmergencyApprovalCount: number = 0
  @State private dashboardCrowdLabel: string = '平稳'
  @State private dashboardTodoItems: AdminTodoItem[] = []
  @State private dashboardErrorMessage: string = ''
  @State private dashboardLoading: boolean = false
  @State private dashboardLoaded: boolean = false
  @State private pageOpacity: number = 1
  @State private pageOffsetY: number = 0
  @State private switching: boolean = false

  @State private username: string = 'visitor'
  @State private password: string = 'visitor123'
  @State private displayName: string = ''
  @State private resetCode: string = ''
  @State private newPassword: string = ''

  @State private authStore: AuthStore = new AuthStore()

  private visitorNavItems: VisitorNavItem[] = [
    { key: 'home', icon: '🏠', title: '首页' },
    { key: 'services', icon: '🧭', title: '服务' },
    { key: 'complaint', icon: '💬', title: '投诉' },
    { key: 'emergency', icon: '🚨', title: '应急' }
  ]

  private adminTodos: AdminTodoItem[] = []

  private systemManageItems: SystemManageItem[] = [
    { key: 'account', icon: '👥', title: '账号与权限', subtitle: '新增酒店 / 平台人员', iconColor: THEME_PRIMARY, iconBg: THEME_PRIMARY_SOFT },
    { key: 'logs', icon: '🧾', title: '操作日志审计', subtitle: '全局行为追踪', iconColor: '#EA580C', iconBg: '#FFF4E6' },
    { key: 'rbac', icon: '🛡', title: 'RBAC 角色配置', subtitle: '系统级权限映射', iconColor: '#7C3AED', iconBg: '#F3E8FF' },
    { key: 'settings', icon: '⚙', title: '系统参数设置', subtitle: '接口 / 缓存 / 字典维护', iconColor: THEME_TEXT_SECONDARY, iconBg: THEME_SURFACE_MUTED }
  ]

  private systemLogs: SystemLogItem[] = [
    { dotColor: THEME_DANGER, title: '拦截一次越权访问', subtitle: '账号 hoteladmin 尝试访问投诉管理  10:42:18' },
    { dotColor: THEME_PRIMARY, title: '修改了票务退款处理权限', subtitle: '操作者：admin_wang  内网终端  10:23:45' },
    { dotColor: THEME_SUCCESS, title: '同步了酒店管理员账号', subtitle: '操作者：ht_yunduan  IP: 10.0.0.5  09:15:22' }
  ]

  private systemAccountRoles: SystemAccountRoleOption[] = [
    { key: 'ADMIN', title: '平台管理员', subtitle: '投诉 / 应急 / 营销运营' },
    { key: 'APPROVER', title: '应急审批员', subtitle: '审核、驳回与发布应急预警' },
    { key: 'HOTEL_ADMIN', title: '酒店管理员', subtitle: '房态与酒店资料维护' },
    { key: 'COMPLAINT_HANDLER', title: '投诉处理员', subtitle: '工单处理与结果反馈' }
  ]

  @State private marketingItems: MarketingHotelItem[] = [
    {
      id: 'star-1',
      name: '云端国际大酒店',
      category: '星级酒店',
      area: '东区',
      price: '¥599/晚起',
      score: '4.8',
      roomStatus: '房态：充足',
      statusColor: THEME_SUCCESS,
      imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=400&q=80',
      recommended: true
    },
    {
      id: 'rural-1',
      name: '绿野星空乡村民宿',
      category: '乡村酒店',
      area: '西区',
      price: '¥299/晚起',
      score: '4.9',
      roomStatus: '房态：紧张',
      statusColor: THEME_DANGER,
      imageUrl: 'https://images.unsplash.com/photo-1449158743715-0a90ebb6d2d8?auto=format&fit=crop&w=400&q=80',
      recommended: false
    },
    {
      id: 'normal-1',
      name: '湖畔假日酒店',
      category: '非星级酒店',
      area: '西区',
      price: '¥450/晚起',
      score: '4.5',
      roomStatus: '房态：满房',
      statusColor: THEME_TEXT_TERTIARY,
      imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=400&q=80',
      recommended: false
    }
  ]

  aboutToAppear(): void {
    if (this.authStore.currentUser !== null && !this.isVisitor()) {
      this.resetRoleTabSelection()
      if (this.isAdminDashboardRole()) {
        void this.loadAdminDashboard()
      }
    }
  }

  private runPageSwitch(onSwitched: () => void): void {
    if (this.switching) {
      onSwitched()
      return
    }
    this.switching = true
    this.pageOpacity = 0
    this.pageOffsetY = 12
    onSwitched()
    animateTo({ duration: 200, curve: Curve.EaseInOut }, () => {
      this.pageOpacity = 1
      this.pageOffsetY = 0
    })
    setTimeout(() => {
      this.switching = false
    }, 200)
  }

  private switchAuthMode(mode: AuthMode): void {
    if (this.authMode === mode) {
      return
    }
    this.runPageSwitch(() => {
      this.authMode = mode
      this.authStore.errorMessage = ''
      this.authStore.infoMessage = ''
      this.resetCode = ''
      this.newPassword = ''
    })
  }

  private doLogout(): void {
    this.runPageSwitch(() => {
      this.authStore.logout()
      this.authMode = 'login'
      this.username = 'visitor'
      this.password = 'visitor123'
      this.selectedTabKey = ''
      this.adminSection = 'home'
      this.marketingMessage = ''
      this.dashboardLoaded = false
      this.dashboardTodoItems = []
      this.dashboardErrorMessage = ''
    })
  }

  private async doLogin(): Promise<void> {
    const ok: boolean = await this.authStore.login({ username: this.username, password: this.password })
    if (ok) {
      this.runPageSwitch(() => {
        this.resetRoleTabSelection()
        this.visitorNav = 'home'
        this.visitorServiceTab = 'routes'
        this.adminSection = 'home'
        this.marketingMessage = ''
      })
      if (this.isAdminDashboardRole()) {
        void this.loadAdminDashboard()
      }
    }
  }

  private async doRegister(): Promise<void> {
    const ok: boolean = await this.authStore.register({
      username: this.username,
      password: this.password,
      displayName: this.displayName.trim().length > 0 ? this.displayName : this.username
    })
    if (ok) {
      this.switchAuthMode('login')
    }
  }

  private async requestCode(): Promise<void> {
    await this.authStore.requestResetCode({ username: this.username })
  }

  private async doResetPassword(): Promise<void> {
    const ok: boolean = await this.authStore.resetPassword({
      username: this.username,
      code: this.resetCode,
      newPassword: this.newPassword
    })
    if (ok) {
      this.password = this.newPassword
      this.switchAuthMode('login')
    }
  }

  private isVisitor(): boolean {
    return this.authStore.getRole() === 'VISITOR'
  }

  private isAdmin(): boolean {
    return this.authStore.getRole() === 'ADMIN'
  }

  private isApprover(): boolean {
    return this.authStore.getRole() === 'APPROVER'
  }

  private isSystemAdmin(): boolean {
    return this.authStore.getRole() === 'SYSTEM_ADMIN'
  }

  private isAdminDashboardRole(): boolean {
    return this.isAdmin() || this.isApprover()
  }

  private isComplaintHandler(): boolean {
    return this.authStore.getRole() === 'COMPLAINT_HANDLER'
  }

  private isHotelAdmin(): boolean {
    return this.authStore.getRole() === 'HOTEL_ADMIN'
  }

  private currentDisplayName(fallback: string): string {
    if (this.authStore.currentUser === undefined || this.authStore.currentUser === null) {
      return fallback
    }
    if (this.authStore.currentUser.displayName.length === 0) {
      return fallback
    }
    return this.authStore.currentUser.displayName
  }

  private switchAdminSection(section: AdminSection): void {
    this.adminSection = section
    this.pressedAdminSection = ''
    this.marketingMessage = ''
    if (section === 'home' && this.isAdminDashboardRole()) {
      void this.loadAdminDashboard()
    }
  }

  private adminCardScale(key: AdminSection): number {
    return this.pressedAdminSection === key ? 0.97 : 1
  }

  private adminCardBg(key: AdminSection): string {
    return this.pressedAdminSection === key ? '#F8FBFF' : THEME_SURFACE
  }

  private updatePressedAdminSection(key: AdminSection, pressed: boolean): void {
    this.pressedAdminSection = pressed ? key : ''
  }

  private switchSystemAdminSection(section: SystemAdminSection): void {
    this.systemAdminSection = section
    this.systemMessage = ''
    this.pressedSystemSection = ''
  }

  private systemCardScale(key: SystemAdminSection): number {
    return this.pressedSystemSection === key ? 0.97 : 1
  }

  private systemCardBg(key: SystemAdminSection): string {
    return this.pressedSystemSection === key ? '#F8FBFF' : THEME_SURFACE
  }

  private updatePressedSystemSection(key: SystemAdminSection, pressed: boolean): void {
    this.pressedSystemSection = pressed ? key : ''
  }

  private selectSystemRole(role: SystemAccountRole): void {
    this.systemRoleInput = role
    this.systemMessage = ''
  }

  private systemRoleTitle(role: SystemAccountRole): string {
    if (role === 'APPROVER') {
      return '应急审批员'
    }
    if (role === 'HOTEL_ADMIN') {
      return '酒店管理员'
    }
    if (role === 'COMPLAINT_HANDLER') {
      return '投诉处理员'
    }
    return '平台管理员'
  }

  private systemRoleInputHint(): string {
    if (this.systemRoleInput === 'APPROVER') {
      return '人员姓名，如：应急审批员王五'
    }
    if (this.systemRoleInput === 'HOTEL_ADMIN') {
      return '归属对象，如：假日星空酒店'
    }
    if (this.systemRoleInput === 'COMPLAINT_HANDLER') {
      return '人员姓名，如：投诉处理员王师傅'
    }
    return '人员姓名，如：平台运营人员张三'
  }

  private systemUsernameHint(): string {
    if (this.systemRoleInput === 'APPROVER') {
      return '登录账号，如：approver_wang'
    }
    if (this.systemRoleInput === 'HOTEL_ADMIN') {
      return '登录账号，如：hotel_holiday'
    }
    if (this.systemRoleInput === 'COMPLAINT_HANDLER') {
      return '登录账号，如：handler_wang'
    }
    return '登录账号，如：admin_zhang'
  }

  private systemRoleButtonBg(role: SystemAccountRole): string {
    return this.systemRoleInput === role ? THEME_PRIMARY : THEME_SURFACE_MUTED
  }

  private systemRoleButtonColor(role: SystemAccountRole): string {
    return this.systemRoleInput === role ? '#FFFFFF' : THEME_TEXT_SECONDARY
  }

  private createSystemAccount(): void {
    if (this.systemUsernameInput.trim().length === 0 || this.systemDisplayNameInput.trim().length === 0) {
      this.systemMessage = '请先填写账号与归属信息'
      return
    }
    this.systemMessage = `已生成${this.systemRoleTitle(this.systemRoleInput)}账号：${this.systemUsernameInput.trim()}，待接入后端用户管理接口后可正式落库。`
  }

  private adminSectionTitle(): string {
    if (this.adminSection === 'complaints') {
      return '投诉管理'
    }
    if (this.adminSection === 'emergency') {
      return '应急信息'
    }
    if (this.adminSection === 'marketing') {
      return '导流营销'
    }
    if (this.adminSection === 'system') {
      return '系统管理'
    }
    if (this.adminSection === 'resources') {
      return '旅游资源库'
    }
    return '工作台'
  }

  private platformHeaderRoleText(): string {
    if (this.isApprover()) {
      return '应急审批员'
    }
    return '平台管理员'
  }

  private canUseAdminEmergencyWrite(): boolean {
    return this.authStore.hasPermission('EMERGENCY_WRITE')
  }

  private canUseAdminEmergencyApprove(): boolean {
    return this.authStore.hasPermission('EMERGENCY_APPROVE')
  }

  private canSeeEmergencyModule(): boolean {
    return this.authStore.hasPermission('EMERGENCY_VIEW') || this.canUseAdminEmergencyWrite() || this.canUseAdminEmergencyApprove()
  }

  private canSeeComplaintModule(): boolean {
    return this.authStore.hasPermission('COMPLAINT_MANAGE')
  }

  private canSeeMarketingModule(): boolean {
    return this.authStore.hasPermission('MARKETING_MANAGE')
  }

  private canSeeResourceModule(): boolean {
    return this.authStore.hasPermission('RESOURCE_MANAGE')
  }

  private adminEmergencyMode(): EmergencyMode {
    if (this.isApprover()) {
      return 'approver'
    }
    return 'admin'
  }

  private async loadAdminDashboard(): Promise<void> {
    if (!this.isAdminDashboardRole() || this.dashboardLoading) {
      return
    }
    this.dashboardLoading = true
    this.dashboardErrorMessage = ''
    try {
      let complaints: ComplaintItem[] = []
      let emergencies: EmergencyItem[] = []
      let scenicResources: ResourceItemResponse[] = []

      if (this.canSeeComplaintModule()) {
        complaints = await apiClient.get<ComplaintItem[]>('/api/complaints')
      }
      if (this.canSeeEmergencyModule()) {
        emergencies = await apiClient.get<EmergencyItem[]>('/api/emergency/admin')
      }
      if (this.canSeeResourceModule()) {
        scenicResources = await apiClient.get<ResourceItemResponse[]>('/api/resources/scenic-spots')
      }

      this.dashboardComplaintPendingCount = complaints.filter((item: ComplaintItem) => item.status === 'SUBMITTED').length
      this.dashboardPublishedEmergencyCount = emergencies.filter((item: EmergencyItem) => item.status === 'PUBLISHED').length
      this.dashboardPendingEmergencyApprovalCount =
        emergencies.filter((item: EmergencyItem) => item.status === 'PENDING_APPROVAL').length
      this.dashboardCrowdLabel = this.resolveCrowdLabel(scenicResources)
      this.dashboardTodoItems = this.buildDashboardTodos(complaints, emergencies)
      this.dashboardLoaded = true
    } catch (_error) {
      this.dashboardErrorMessage = '首页摘要加载失败，请稍后重试'
    } finally {
      this.dashboardLoading = false
    }
  }

  private resolveCrowdLabel(items: ResourceItemResponse[]): string {
    let total: number = 0
    let count: number = 0
    items.forEach((item: ResourceItemResponse) => {
      if (item.online && item.crowdHeat !== null) {
        total += item.crowdHeat
        count += 1
      }
    })
    if (count === 0) {
      return this.isApprover() ? '待审' : '平稳'
    }
    const average: number = total / count
    if (average >= 80) {
      return '高峰'
    }
    if (average >= 60) {
      return '较高'
    }
    if (average >= 35) {
      return '平稳'
    }
    return '舒适'
  }

  private buildDashboardTodos(complaints: ComplaintItem[], emergencies: EmergencyItem[]): AdminTodoItem[] {
    let items: AdminTodoItem[] = []
    if (this.canSeeComplaintModule()) {
      const pendingComplaints: ComplaintItem[] = complaints.filter((item: ComplaintItem) => item.status === 'SUBMITTED')
      const resolvedComplaints: ComplaintItem[] = complaints.filter((item: ComplaintItem) => item.status === 'RESOLVED')
      items = items.concat(pendingComplaints.map((item: ComplaintItem) => this.mapPendingComplaintTodo(item)))
      items = items.concat(resolvedComplaints.map((item: ComplaintItem) => this.mapResolvedComplaintTodo(item)))
    }
    if (this.canUseAdminEmergencyApprove()) {
      const pendingEmergencies: EmergencyItem[] = emergencies.filter((item: EmergencyItem) => item.status === 'PENDING_APPROVAL')
      items = items.concat(pendingEmergencies.map((item: EmergencyItem) => this.mapApprovalEmergencyTodo(item)))
    } else if (this.canUseAdminEmergencyWrite()) {
      const rejectedEmergencies: EmergencyItem[] = emergencies.filter((item: EmergencyItem) => item.status === 'REJECTED')
      const draftEmergencies: EmergencyItem[] = emergencies.filter((item: EmergencyItem) => item.status === 'DRAFT')
      items = items.concat(rejectedEmergencies.map((item: EmergencyItem) => this.mapRejectedEmergencyTodo(item)))
      items = items.concat(draftEmergencies.map((item: EmergencyItem) => this.mapDraftEmergencyTodo(item)))
    }
    return items
      .sort((left: AdminTodoItem, right: AdminTodoItem) => right.sortTime - left.sortTime)
      .slice(0, 5)
  }

  private mapPendingComplaintTodo(item: ComplaintItem): AdminTodoItem {
    return {
      icon: '诉',
      title: `投诉待审批：${item.title}`,
      subtitle: `${this.relativeTimeText(item.createdAt)} · 需管理员审批`,
      iconColor: THEME_DANGER,
      iconBg: '#FFECEC',
      section: 'complaints',
      sortTime: this.toTimestamp(item.createdAt)
    }
  }

  private mapResolvedComplaintTodo(item: ComplaintItem): AdminTodoItem {
    return {
      icon: '结',
      title: `投诉待结案：${item.title}`,
      subtitle: `${this.relativeTimeText(item.updatedAt)} · 需复核后结案`,
      iconColor: THEME_SUCCESS,
      iconBg: '#EAF8EF',
      section: 'complaints',
      sortTime: this.toTimestamp(item.updatedAt)
    }
  }

  private mapApprovalEmergencyTodo(item: EmergencyItem): AdminTodoItem {
    return {
      icon: '警',
      title: `预警待审批：${item.title}`,
      subtitle: `${this.relativeTimeText(item.updatedAt)} · 需确认发布`,
      iconColor: THEME_WARNING,
      iconBg: '#FFF4E6',
      section: 'emergency',
      sortTime: this.toTimestamp(item.updatedAt)
    }
  }

  private mapRejectedEmergencyTodo(item: EmergencyItem): AdminTodoItem {
    return {
      icon: '改',
      title: `预警待修改：${item.title}`,
      subtitle: `${this.relativeTimeText(item.updatedAt)} · 已驳回待重新提交`,
      iconColor: THEME_WARNING,
      iconBg: '#FFF4E6',
      section: 'emergency',
      sortTime: this.toTimestamp(item.updatedAt)
    }
  }

  private mapDraftEmergencyTodo(item: EmergencyItem): AdminTodoItem {
    return {
      icon: '稿',
      title: `预警草稿：${item.title}`,
      subtitle: `${this.relativeTimeText(item.updatedAt)} · 待提交审批`,
      iconColor: THEME_PRIMARY,
      iconBg: THEME_PRIMARY_SOFT,
      section: 'emergency',
      sortTime: this.toTimestamp(item.updatedAt)
    }
  }

  private toTimestamp(raw: string): number {
    const parsed: number = Date.parse(raw)
    if (Number.isNaN(parsed)) {
      return 0
    }
    return parsed
  }

  private relativeTimeText(raw: string): string {
    const timestamp: number = this.toTimestamp(raw)
    if (timestamp <= 0) {
      return '刚刚'
    }
    const diffMs: number = Math.max(0, Date.now() - timestamp)
    const minutes: number = Math.floor(diffMs / 60000)
    if (minutes < 1) {
      return '刚刚'
    }
    if (minutes < 60) {
      return `${minutes} 分钟前`
    }
    const hours: number = Math.floor(minutes / 60)
    if (hours < 24) {
      return `${hours} 小时前`
    }
    const days: number = Math.floor(hours / 24)
    return `${days} 天前`
  }

  private overviewMetricOneValue(): string {
    if (this.canSeeComplaintModule()) {
      return `${this.dashboardComplaintPendingCount}`
    }
    return `${this.dashboardPendingEmergencyApprovalCount}`
  }

  private overviewMetricOneLabel(): string {
    if (this.canSeeComplaintModule()) {
      return '待审批投诉'
    }
    return '待审批预警'
  }

  private overviewMetricTwoValue(): string {
    return `${this.dashboardPublishedEmergencyCount}`
  }

  private overviewMetricTwoLabel(): string {
    return '生效应急预警'
  }

  private overviewMetricThreeValue(): string {
    return this.dashboardCrowdLabel
  }

  private overviewMetricThreeLabel(): string {
    if (this.canSeeResourceModule()) {
      return '当前客流'
    }
    return '审批负载'
  }

  private openAdminTodoSection(section: AdminSection): void {
    this.switchAdminSection(section)
  }

  private openAllAdminTodos(): void {
    if (this.canSeeComplaintModule() && this.dashboardComplaintPendingCount > 0) {
      this.openAdminTodoSection('complaints')
      return
    }
    if (this.canSeeEmergencyModule()) {
      this.openAdminTodoSection('emergency')
      return
    }
    if (this.canSeeResourceModule()) {
      this.openAdminTodoSection('resources')
      return
    }
    if (this.canSeeMarketingModule()) {
      this.openAdminTodoSection('marketing')
    }
  }

  private progressWidth(value: number): string {
    return `${value}%`
  }

  private marketingStatusText(item: MarketingHotelItem): string {
    return item.recommended ? '已开启主页推荐' : '未开启推荐'
  }

  private marketingButtonText(item: MarketingHotelItem): string {
    return item.recommended ? '关闭推荐' : '开启推荐'
  }

  private marketingButtonBg(item: MarketingHotelItem): string {
    return item.recommended ? THEME_PRIMARY_SOFT : THEME_SURFACE_MUTED
  }

  private marketingButtonColor(item: MarketingHotelItem): string {
    return item.recommended ? THEME_PRIMARY : THEME_TEXT_TERTIARY
  }

  private recommendedCount(): number {
    return this.marketingItems.filter((item: MarketingHotelItem) => item.recommended).length
  }

  private toggleMarketing(id: string): void {
    this.marketingItems = this.marketingItems.map((item: MarketingHotelItem) => {
      if (item.id === id) {
        return {
          id: item.id,
          name: item.name,
          category: item.category,
          area: item.area,
          price: item.price,
          score: item.score,
          roomStatus: item.roomStatus,
          statusColor: item.statusColor,
          imageUrl: item.imageUrl,
          recommended: !item.recommended
        }
      }
      return item
    })
    this.marketingMessage = '推荐配置已更新，待下发到游客端'
  }

  private publishMarketingPlan(): void {
    this.marketingMessage = `已生成导流营销策略，当前推荐 ${this.recommendedCount()} 家酒店`
  }

  private tabsForRole(role: UserRole): TabItem[] {
    switch (role) {
      case 'VISITOR':
        return [
          { key: 'complaint-visitor', title: '鎴戠殑鎶曡瘔' },
          { key: 'emergency-visitor', title: '应急信息' },
          { key: 'hotel-visitor', title: '閰掑簵鏌ヨ' },
          { key: 'scenic', title: '景区与线路' },
          { key: 'dining', title: '椁愰ギ濞变箰婕斿嚭' },
          { key: 'weather', title: '天气与路况' }
        ]
      case 'COMPLAINT_HANDLER':
        return [{ key: 'complaint-handler', title: '鎶曡瘔澶勭悊' }]
      case 'APPROVER':
        return [{ key: 'emergency-approver', title: '应急审批' }]
      case 'HOTEL_ADMIN':
        return [{ key: 'hotel-manager', title: '閰掑簵绠＄悊' }]
      case 'SYSTEM_ADMIN':
        return [{ key: 'system-admin', title: '系统管理' }]
      case 'ADMIN':
        return [
          { key: 'complaint-admin', title: '鎶曡瘔绠＄悊' },
          { key: 'emergency-admin', title: '应急管理' },
          { key: 'scenic', title: '景区与线路' },
          { key: 'dining', title: '椁愰ギ濞变箰婕斿嚭' },
          { key: 'weather', title: '天气与路况' }
        ]
      default:
        return [{ key: 'complaint-visitor', title: '鎴戠殑鎶曡瘔' }]
    }
  }

  private getRoleTabs(): TabItem[] {
    return this.tabsForRole(this.authStore.getRole())
  }

  private hasMultipleRoleTabs(): boolean {
    return this.getRoleTabs().length > 1
  }

  private resetRoleTabSelection(): void {
    const tabs: TabItem[] = this.getRoleTabs()
    if (tabs.length === 0) {
      this.selectedTabKey = ''
      return
    }
    const exists: boolean = tabs.some((tab: TabItem) => tab.key === this.selectedTabKey)
    if (!exists) {
      this.selectedTabKey = tabs[0].key
    }
  }

  private isTabSelected(key: string): boolean {
    return this.selectedTabKey === key
  }

  private isVisitorNavSelected(key: VisitorNav): boolean {
    return this.visitorNav === key
  }

  private switchTab(key: string): void {
    if (this.selectedTabKey === key) {
      return
    }
    this.selectedTabKey = key
  }

  private switchVisitorNav(key: VisitorNav): void {
    if (this.visitorNav === key) {
      return
    }
    this.runPageSwitch(() => {
      this.visitorNav = key
    })
  }

  private complaintModeByKey(key: string): ComplaintMode {
    if (key === 'complaint-handler') {
      return 'handler'
    }
    if (key === 'complaint-approver') {
      return 'approver'
    }
    if (key === 'complaint-admin') {
      return 'admin'
    }
    return 'visitor'
  }

  private emergencyModeByKey(key: string): EmergencyMode {
    if (key === 'emergency-writer') {
      return 'writer'
    }
    if (key === 'emergency-approver') {
      return 'approver'
    }
    if (key === 'emergency-admin') {
      return 'admin'
    }
    return 'visitor'
  }

  private hotelModeByKey(key: string): HotelMode {
    if (key === 'hotel-manager') {
      return 'manager'
    }
    return 'visitor'
  }

  @Builder
  private AuthModeSwitch(): void {
    Row({ space: 8 }) {
      Button('登录')
        .onClick(() => this.switchAuthMode('login'))
        .backgroundColor(this.authMode === 'login' ? THEME_PRIMARY : '#EAF2FF')
        .fontColor(this.authMode === 'login' ? Color.White : THEME_TEXT_SECONDARY)
        .borderRadius(RADIUS_PILL)
        .layoutWeight(1)
      Button('注册')
        .onClick(() => this.switchAuthMode('register'))
        .backgroundColor(this.authMode === 'register' ? THEME_PRIMARY : '#EAF2FF')
        .fontColor(this.authMode === 'register' ? Color.White : THEME_TEXT_SECONDARY)
        .borderRadius(RADIUS_PILL)
        .layoutWeight(1)
      Button('找回密码')
        .onClick(() => this.switchAuthMode('reset'))
        .backgroundColor(this.authMode === 'reset' ? THEME_PRIMARY : '#EAF2FF')
        .fontColor(this.authMode === 'reset' ? Color.White : THEME_TEXT_SECONDARY)
        .borderRadius(RADIUS_PILL)
        .layoutWeight(1)
    }
    .padding(4)
    .backgroundColor('#F4F7FD')
    .borderRadius(RADIUS_PILL)
  }

  @Builder
  private LoginView(): void {
    Column({ space: 10 }) {
      Column({ space: 16 }) {
        Text('游客服务系统')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)

        Text('极简、清晰、可信赖的旅途服务平台')
          .fontSize(12)
          .fontColor(THEME_TEXT_TERTIARY)

        this.AuthModeSwitch()

        TextInput({ placeholder: '账号', text: this.username })
          .onChange((value: string) => {
            this.username = value
          })
          .padding(12)
          .borderRadius(RADIUS_MD)
          .backgroundColor(THEME_SURFACE)
          .border({ width: 1, color: THEME_BORDER_SOFT })
          .width('100%')

        if (this.authMode === 'register') {
          TextInput({ placeholder: '昵称（可选）', text: this.displayName })
            .onChange((value: string) => {
              this.displayName = value
            })
            .padding(12)
            .borderRadius(RADIUS_MD)
            .backgroundColor(THEME_SURFACE)
            .border({ width: 1, color: THEME_BORDER_SOFT })
            .width('100%')
        }

        if (this.authMode !== 'reset') {
          TextInput({ placeholder: '密码', text: this.password })
            .type(InputType.Password)
            .onChange((value: string) => {
              this.password = value
            })
            .padding(12)
            .borderRadius(RADIUS_MD)
            .backgroundColor(THEME_SURFACE)
            .border({ width: 1, color: THEME_BORDER_SOFT })
            .width('100%')
        }

        if (this.authMode === 'reset') {
          Row({ space: 8 }) {
            Button('获取验证码')
              .enabled(!this.authStore.loading)
              .onClick(() => {
                this.requestCode()
              })
              .layoutWeight(1)
              .height(42)
              .borderRadius(RADIUS_PILL)
              .backgroundColor('#EAF2FF')
              .fontColor(THEME_PRIMARY)
          }

          TextInput({ placeholder: '验证码（6位）', text: this.resetCode })
            .onChange((value: string) => {
              this.resetCode = value
            })
            .padding(12)
            .borderRadius(RADIUS_MD)
            .backgroundColor(THEME_SURFACE)
            .border({ width: 1, color: THEME_BORDER_SOFT })
            .width('100%')

          TextInput({ placeholder: '新密码', text: this.newPassword })
            .type(InputType.Password)
            .onChange((value: string) => {
              this.newPassword = value
            })
            .padding(12)
            .borderRadius(RADIUS_MD)
            .backgroundColor(THEME_SURFACE)
            .border({ width: 1, color: THEME_BORDER_SOFT })
            .width('100%')
        }

        Button(this.authStore.loading ? '处理中...' : this.authMode === 'login' ? '登录' : this.authMode === 'register' ? '注册' : '重置密码')
          .enabled(!this.authStore.loading)
          .onClick(() => {
            if (this.authMode === 'login') {
              this.doLogin()
            } else if (this.authMode === 'register') {
              this.doRegister()
            } else {
              this.doResetPassword()
            }
          })
          .width('100%')
          .height(44)
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_PRIMARY)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .shadow(SHADOW_CARD)

        if (this.authStore.errorMessage.length > 0) {
          Text(this.authStore.errorMessage).fontColor('#B42318').fontSize(12)
        }
        if (this.authStore.infoMessage.length > 0) {
          Text(this.authStore.infoMessage).fontColor('#0F8A43').fontSize(12)
        }

        Text('演示账号：visitor / admin / approver / handler / hoteladmin / sysadmin')
          .fontSize(11)
          .fontColor(THEME_TEXT_TERTIARY)
      }
      .width('90%')
      .padding(26)
      .backgroundColor(THEME_SURFACE)
      .borderRadius(RADIUS_LG)
      .shadow(SHADOW_PANEL)
    }
    .padding(20)
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(THEME_PAGE_BG)
  }

  @Builder
  private VisitorShellView(): void {
    Column({ space: 10 }) {
      Row() {
        Column({ space: 2 }) {
          Text(`欢迎你，${this.currentDisplayName('游客')}`)
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor(THEME_TEXT_PRIMARY)
          Text('游客模式')
            .fontSize(12)
            .fontColor(THEME_TEXT_SECONDARY)
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Button('退出登录')
          .height(34)
          .padding({ left: 14, right: 14 })
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_PRIMARY_SOFT)
          .fontColor(THEME_PRIMARY)
          .onClick(() => this.doLogout())
      }
      .padding(12)
      .margin({ left: 12, right: 12, top: 12 })
      .backgroundColor(THEME_SURFACE)
      .borderRadius(RADIUS_LG)
      .shadow(SHADOW_CARD)

      Column() {
        this.renderVisitorTab()
      }
      .layoutWeight(1)
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)

      Row({ space: 8 }) {
        ForEach(this.visitorNavItems, (item: VisitorNavItem) => {
          Button(`${item.icon} ${item.title}`)
            .layoutWeight(1)
            .height(40)
            .fontSize(12)
            .fontWeight(this.isVisitorNavSelected(item.key) ? FontWeight.Medium : FontWeight.Normal)
            .fontColor(this.isVisitorNavSelected(item.key) ? Color.White : THEME_TEXT_SECONDARY)
            .backgroundColor(this.isVisitorNavSelected(item.key) ? THEME_PRIMARY : '#EEF3FA')
            .borderRadius(RADIUS_PILL)
            .onClick(() => this.switchVisitorNav(item.key))
        }, (item: VisitorNavItem) => item.key)
      }
      .padding(10)
      .margin({ left: 12, right: 12, bottom: 12 })
      .backgroundColor(THEME_SURFACE)
      .borderRadius(RADIUS_LG)
      .shadow(SHADOW_CARD)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(THEME_PAGE_BG)
  }

  @Builder
  private AdminHeader(): void {
    Row() {
      Column({ space: 3 }) {
        Text(this.adminSectionTitle())
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
        Text(`欢迎回来，${this.platformHeaderRoleText()}（${this.currentDisplayName('Admin')}）`)
          .fontSize(11)
          .fontColor(THEME_TEXT_SECONDARY)
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Button(this.adminSection === 'home' ? '退出登录' : '回工作台')
        .height(34)
        .padding({ left: 11, right: 11 })
        .borderRadius(RADIUS_PILL)
        .backgroundColor(THEME_PRIMARY_SOFT)
        .fontColor(THEME_PRIMARY)
        .fontSize(12)
        .onClick(() => {
          if (this.adminSection === 'home') {
            this.doLogout()
          } else {
            this.switchAdminSection('home')
          }
        })
    }
    .padding({ left: 18, right: 18, top: 16, bottom: 12 })
    .backgroundColor(THEME_SURFACE)
    .borderRadius(28)
    .shadow(SHADOW_CARD)
    .margin({ left: 16, right: 16, top: 10, bottom: 8 })
  }

  @Builder
  private AdminShellView(): void {
    Column() {
      this.AdminHeader()
      this.AdminMainContent()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(THEME_PAGE_BG)
  }

  @Builder
  private AdminMainContent(): void {
    if (this.adminSection === 'home') {
      Scroll() {
        this.AdminHomeView()
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    } else if (this.adminSection === 'complaints') {
      Column({ space: 8 }) {
        ComplaintPage({ mode: 'admin' })
      }
      .layoutWeight(1)
      .width('100%')
    } else if (this.adminSection === 'emergency') {
      Column({ space: 8 }) {
        EmergencyPage({ mode: this.adminEmergencyMode() })
      }
      .layoutWeight(1)
      .width('100%')
    } else if (this.adminSection === 'marketing') {
      Column({ space: 8 }) {
        MarketingPage()
      }
      .layoutWeight(1)
      .width('100%')
    } else if (this.adminSection === 'resources') {
      Column({ space: 8 }) {
        ResourceLibraryPage()
      }
      .layoutWeight(1)
      .width('100%')
    } else {
      Scroll() {
        this.AdminSystemPlaceholder()
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
  }

  @Builder
  private AdminSubHeader(title: string, subtitle: string): void {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(THEME_TEXT_PRIMARY)
      Text(subtitle)
        .fontSize(11)
        .fontColor(THEME_TEXT_SECONDARY)
    }
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 20, right: 20, top: 4, bottom: 4 })
  }

  @Builder
  private AdminHomeView(): void {
    Column({ space: 20 }) {
      this.AdminOverviewCard()

      Column({ space: 14 }) {
        Text('功能模块')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
          .width('100%')

        if (this.canSeeComplaintModule() || this.canSeeEmergencyModule()) {
          Row({ space: 18 }) {
            if (this.canSeeComplaintModule()) {
              this.AdminModuleCard('complaints', '📝', '投诉管理', '审批 / 结案 / 分派', THEME_PRIMARY, THEME_PRIMARY_SOFT)
            }
            if (this.canSeeEmergencyModule()) {
              this.AdminModuleCard(
                'emergency',
                '🚨',
                '应急信息',
                this.canUseAdminEmergencyApprove() ? '审批 / 驳回预警' : '发布 / 修改 / 删除',
                THEME_WARNING,
                '#FFF4E6'
              )
            }
          }
          .width('100%')
        }

        if (this.canSeeMarketingModule() || this.canSeeResourceModule()) {
          Row({ space: 18 }) {
            if (this.canSeeMarketingModule()) {
              this.AdminModuleCard('marketing', '📈', '导流营销', '酒店推荐配置', THEME_SUCCESS, '#EAF8EF')
            }
            if (this.canSeeResourceModule()) {
              this.AdminModuleCard('resources', '🗺', '旅游资源库', '景点 / 餐饮维护', THEME_PRIMARY, THEME_PRIMARY_SOFT)
            }
          }
          .width('100%')
        }
      }
      .width('100%')

      this.AdminTodoList()
    }
    .padding({ left: 20, right: 20, bottom: 28 })
  }

  @Builder
  private AdminOverviewCard(): void {
    Column({ space: 14 }) {
      Text('今日待办与系统状态')
        .fontSize(14)
        .fontColor(Color.White)
        .width('100%')

      Row() {
        this.AdminMetric(this.overviewMetricOneValue(), this.overviewMetricOneLabel())
        Blank().width(1).height(42).backgroundColor('#52A7FF')
        this.AdminMetric(this.overviewMetricTwoValue(), this.overviewMetricTwoLabel())
        Blank().width(1).height(42).backgroundColor('#52A7FF')
        this.AdminMetric(this.overviewMetricThreeValue(), this.overviewMetricThreeLabel())
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      if (this.dashboardErrorMessage.length > 0) {
        Text(this.dashboardErrorMessage)
          .fontSize(11)
          .fontColor('#EAF2FF')
          .width('100%')
      }
    }
    .padding(18)
    .backgroundColor(THEME_PRIMARY)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_PANEL)
  }

  @Builder
  private AdminMetric(value: string, label: string): void {
    Column({ space: 6 }) {
      Text(value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
      Text(label)
        .fontSize(11)
        .fontColor('#EAF2FF')
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private AdminModuleCard(key: AdminSection, icon: string, title: string, subtitle: string, iconColor: string, iconBg: string): void {
    Column({ space: 14 }) {
      Text(icon)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(iconColor)
        .textAlign(TextAlign.Center)
        .width(42)
        .height(42)
        .backgroundColor(iconBg)
        .borderRadius(RADIUS_PILL)

      Column({ space: 6 }) {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
        Text(subtitle)
          .fontSize(11)
          .fontColor(THEME_TEXT_SECONDARY)
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
    .height(144)
    .padding(16)
    .backgroundColor(this.adminCardBg(key))
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
    .scale({ x: this.adminCardScale(key), y: this.adminCardScale(key) })
    .animation({ duration: 120, curve: Curve.EaseOut })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.updatePressedAdminSection(key, true)
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.updatePressedAdminSection(key, false)
      }
    })
    .onClick(() => this.switchAdminSection(key))
  }

  @Builder
  private AdminTodoList(): void {
    Column({ space: 12 }) {
      Row() {
        Text('最新待办')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
        Blank()
        Text('查看全部')
          .fontSize(11)
          .fontColor(THEME_PRIMARY)
          .onClick(() => this.openAllAdminTodos())
      }
      .width('100%')

      if (this.dashboardTodoItems.length === 0) {
        Column({ space: 6 }) {
          Text(this.dashboardLoading && !this.dashboardLoaded ? '正在加载待办' : '暂无待办')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(THEME_TEXT_PRIMARY)
          Text(this.dashboardLoading && !this.dashboardLoaded ? '正在汇总投诉、应急与资源数据' : '当前没有需要你处理的后台任务')
            .fontSize(11)
            .fontColor(THEME_TEXT_TERTIARY)
        }
        .width('100%')
        .padding({ top: 24, bottom: 24 })
        .backgroundColor(THEME_SURFACE)
        .borderRadius(RADIUS_LG)
        .shadow(SHADOW_CARD)
      } else {
        Column() {
          ForEach(this.dashboardTodoItems, (item: AdminTodoItem) => {
            Row({ space: 12 }) {
              Text(item.icon)
                .fontSize(13)
                .fontWeight(FontWeight.Bold)
                .fontColor(item.iconColor)
                .textAlign(TextAlign.Center)
                .width(34)
                .height(34)
                .backgroundColor(item.iconBg)
                .borderRadius(RADIUS_PILL)
              Column({ space: 4 }) {
                Text(item.title)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(THEME_TEXT_PRIMARY)
                  .maxLines(1)
                Text(item.subtitle)
                  .fontSize(11)
                  .fontColor(THEME_TEXT_TERTIARY)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              Text('>')
                .fontSize(22)
                .fontColor(THEME_TEXT_TERTIARY)
            }
            .padding({ left: 18, right: 18, top: 14, bottom: 14 })
            .onClick(() => this.openAdminTodoSection(item.section))
          }, (item: AdminTodoItem) => `${item.section}-${item.title}-${item.sortTime}`)
        }
        .backgroundColor(THEME_SURFACE)
        .borderRadius(RADIUS_LG)
        .shadow(SHADOW_CARD)
      }
    }
    .width('100%')
  }

  @Builder
  private TrafficProgress(label: string, value: number, color: string): void {
    Row({ space: 10 }) {
      Text(label)
        .fontSize(12)
        .fontColor(THEME_TEXT_SECONDARY)
        .width(92)
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
        .width(38)
        .textAlign(TextAlign.End)
    }
    .width('100%')
  }

  @Builder
  private AdminMarketingView(): void {
    Column({ space: 18 }) {
      Column({ space: 14 }) {
        Text('实时流量建议')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
          .width('100%')

        Column({ space: 14 }) {
          Row() {
            Column({ space: 4 }) {
              Text('当前景区总客流')
                .fontSize(11)
                .fontColor(THEME_TEXT_SECONDARY)
              Row({ space: 4 }) {
                Text('12,450')
                  .fontSize(26)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(THEME_TEXT_PRIMARY)
                Text('人')
                  .fontSize(12)
                  .fontColor(THEME_TEXT_SECONDARY)
              }
            }
            .alignItems(HorizontalAlign.Start)
            Blank()
            Text('拥挤')
              .fontSize(11)
              .fontColor(THEME_DANGER)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor('#FFECEC')
              .borderRadius(RADIUS_PILL)
          }
          .width('100%')

          this.TrafficProgress('东区（湖畔景点）', 85, '#F0677B')
          this.TrafficProgress('西区（乡村周边）', 30, THEME_PRIMARY)

          Text('导流建议：东区目前处于客流高峰，建议减少东区酒店推荐，重点引导至西区乡村民宿，帮助游客分流。')
            .fontSize(12)
            .lineHeight(18)
            .fontColor(THEME_TEXT_PRIMARY)
        }
        .padding(18)
        .backgroundColor(THEME_SURFACE)
        .borderRadius(RADIUS_LG)
        .shadow(SHADOW_CARD)
      }
      .width('100%')

      Column({ space: 12 }) {
        Row() {
          Text('推荐营销配置')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(THEME_TEXT_PRIMARY)
          Blank()
          Text('下拉刷新动态')
            .fontSize(11)
            .fontColor(THEME_TEXT_TERTIARY)
        }
        .width('100%')

        ForEach(this.marketingItems, (item: MarketingHotelItem) => {
          this.MarketingHotelCard(item)
        }, (item: MarketingHotelItem) => item.id)
      }
      .width('100%')

      Button('下发营销策略至游客端')
        .width('100%')
        .height(52)
        .borderRadius(RADIUS_MD)
        .backgroundColor(THEME_PRIMARY)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
        .onClick(() => this.publishMarketingPlan())

      if (this.marketingMessage.length > 0) {
        Text(this.marketingMessage)
          .fontSize(12)
          .fontColor(THEME_SUCCESS)
          .width('100%')
          .textAlign(TextAlign.Center)
      }
    }
    .padding({ left: 20, right: 20, bottom: 30 })
  }

  @Builder
  private MarketingHotelCard(item: MarketingHotelItem): void {
    Row({ space: 12 }) {
      Image(item.imageUrl)
        .width(92)
        .height(92)
        .borderRadius(RADIUS_MD)
        .objectFit(ImageFit.Cover)

      Column({ space: 8 }) {
        Row() {
          Text(item.name)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(THEME_TEXT_PRIMARY)
            .maxLines(1)
            .layoutWeight(1)
          Text(`⭐ ${item.score}`)
            .fontSize(11)
            .fontColor(THEME_WARNING)
        }
        .width('100%')

        Row({ space: 8 }) {
          Text(item.category)
            .fontSize(10)
            .fontColor(THEME_TEXT_SECONDARY)
          Text(item.roomStatus)
            .fontSize(10)
            .fontColor(item.statusColor)
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .backgroundColor(THEME_SURFACE_MUTED)
            .borderRadius(RADIUS_PILL)
        }
        .width('100%')

        Row() {
          Text(item.price)
            .fontSize(11)
            .fontColor(THEME_TEXT_SECONDARY)
          Blank()
          Text(this.marketingStatusText(item))
            .fontSize(11)
            .fontColor(item.recommended ? THEME_PRIMARY : THEME_TEXT_TERTIARY)
        }
        .width('100%')

        Button(this.marketingButtonText(item))
          .height(30)
          .borderRadius(RADIUS_PILL)
          .backgroundColor(this.marketingButtonBg(item))
          .fontColor(this.marketingButtonColor(item))
          .onClick(() => this.toggleMarketing(item.id))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .padding(14)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private AdminSystemPlaceholder(): void {
    Column({ space: 16 }) {
      Text('系统管理')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(THEME_TEXT_PRIMARY)
      Text('角色 / 权限配置后续完善')
        .fontSize(14)
        .fontColor(THEME_TEXT_SECONDARY)
      Text('本轮先完成平台管理工作台和酒店导流营销，系统管理仅保留入口。')
        .fontSize(12)
        .fontColor(THEME_TEXT_TERTIARY)
        .lineHeight(20)
        .textAlign(TextAlign.Center)
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .height(260)
    .margin({ left: 20, right: 20, bottom: 30 })
    .padding(24)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private SystemAdminDashboardView(): void {
    Column({ space: 22 }) {
      this.SystemCenterHeader()
      this.SystemStatusCard()

      Column({ space: 14 }) {
        Text('核心管理域')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
          .width('100%')

        Row({ space: 16 }) {
          this.SystemModuleCard(this.systemManageItems[0])
          this.SystemModuleCard(this.systemManageItems[1])
        }
        .width('100%')

        Row({ space: 16 }) {
          this.SystemModuleCard(this.systemManageItems[2])
          this.SystemModuleCard(this.systemManageItems[3])
        }
        .width('100%')
      }
      .width('100%')

      this.SystemSecurityLogsPreview()
    }
    .padding({ left: 20, right: 20, bottom: 30 })
  }

  @Builder
  private SystemCenterHeader(): void {
    Row() {
      Row({ space: 12 }) {
        Text('盾')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_PRIMARY)
          .textAlign(TextAlign.Center)
          .width(50)
          .height(50)
          .backgroundColor(THEME_PRIMARY_SOFT)
          .borderRadius(RADIUS_PILL)
        Column({ space: 3 }) {
          Text('系统管理中心')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(THEME_TEXT_PRIMARY)
          Text('账号权限与安全运维')
            .fontSize(12)
            .fontColor(THEME_TEXT_TERTIARY)
        }
        .alignItems(HorizontalAlign.Start)
      }
      Blank()
      Text('运维端')
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
  private SystemStatusCard(): void {
    Column({ space: 22 }) {
      Row() {
        Column({ space: 8 }) {
          Text('系统运行状态')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
          Text('已稳定运行 128 天 14 小时')
            .fontSize(13)
            .fontColor('#EAF2FF')
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        Text('安全')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .padding({ left: 14, right: 14, top: 7, bottom: 7 })
          .backgroundColor('#4DA3FF')
          .borderRadius(RADIUS_PILL)
      }
      .width('100%')

      Row() {
        this.SystemStatusMetric('245', '注册后台账号总数')
        Blank().width(1).height(42).backgroundColor('#52A7FF')
        this.SystemStatusMetric('42', '今日活跃账号')
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#2F8DFF')
      .borderRadius(RADIUS_MD)
    }
    .width('100%')
    .padding(24)
    .backgroundColor(THEME_PRIMARY)
    .borderRadius(26)
    .shadow(SHADOW_PANEL)
  }

  @Builder
  private SystemStatusMetric(value: string, label: string): void {
    Column({ space: 7 }) {
      Text(label)
        .fontSize(12)
        .fontColor('#DCEBFF')
      Text(value)
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private SystemModuleCard(item: SystemManageItem): void {
    Column({ space: 18 }) {
      Text(item.icon)
        .fontSize(19)
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
    .backgroundColor(this.systemCardBg(item.key))
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
    .scale({ x: this.systemCardScale(item.key), y: this.systemCardScale(item.key) })
    .animation({ duration: 120, curve: Curve.EaseOut })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.updatePressedSystemSection(item.key, true)
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.updatePressedSystemSection(item.key, false)
      }
    })
    .onClick(() => this.switchSystemAdminSection(item.key))
  }

  @Builder
  private SystemSecurityLogsPreview(): void {
    Column({ space: 12 }) {
      Row() {
        Text('实时安全预警')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
        Blank()
        Text('完整日志')
          .fontSize(12)
          .fontColor(THEME_PRIMARY)
          .onClick(() => this.switchSystemAdminSection('logs'))
      }
      .width('100%')

      Column() {
        ForEach(this.systemLogs, (item: SystemLogItem) => {
          this.SystemLogRow(item)
        }, (item: SystemLogItem) => item.title)
      }
      .width('100%')
      .backgroundColor(THEME_SURFACE)
      .borderRadius(RADIUS_LG)
      .shadow(SHADOW_CARD)
    }
    .width('100%')
  }

  @Builder
  private SystemLogRow(item: SystemLogItem): void {
    Row({ space: 12 }) {
      Text('')
        .width(8)
        .height(8)
        .backgroundColor(item.dotColor)
        .borderRadius(RADIUS_PILL)
      Column({ space: 4 }) {
        Text(item.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(THEME_TEXT_PRIMARY)
        Text(item.subtitle)
          .fontSize(12)
          .fontColor(THEME_TEXT_TERTIARY)
          .maxLines(1)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 14, bottom: 14 })
  }

  @Builder
  private SystemSectionTitle(title: string, subtitle: string): void {
    Row() {
      Column({ space: 5 }) {
        Text(title)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
        Text(subtitle)
          .fontSize(12)
          .fontColor(THEME_TEXT_SECONDARY)
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      Button('返回')
        .height(34)
        .padding({ left: 14, right: 14 })
        .borderRadius(RADIUS_PILL)
        .backgroundColor(THEME_PRIMARY_SOFT)
        .fontColor(THEME_PRIMARY)
        .onClick(() => this.switchSystemAdminSection('home'))
    }
    .width('100%')
  }

  @Builder
  private SystemAccountView(): void {
    Column({ space: 18 }) {
      this.SystemSectionTitle('账号与权限', '为新员工或新入驻商户分配系统账号')

      Column({ space: 16 }) {
        Text('分配新系统账号')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
          .width('100%')

        Text('选择账号角色')
          .fontSize(12)
          .fontColor(THEME_TEXT_SECONDARY)
          .width('100%')

        Column({ space: 10 }) {
          ForEach(this.systemAccountRoles, (item: SystemAccountRoleOption) => {
            Button(`${item.title}  ${item.subtitle}`)
              .height(42)
              .width('100%')
              .borderRadius(RADIUS_PILL)
              .backgroundColor(this.systemRoleButtonBg(item.key))
              .fontColor(this.systemRoleButtonColor(item.key))
              .onClick(() => this.selectSystemRole(item.key))
          }, (item: SystemAccountRoleOption) => item.key)
        }
        .width('100%')

        TextInput({ placeholder: this.systemUsernameHint(), text: this.systemUsernameInput })
          .onChange((value: string) => {
            this.systemUsernameInput = value
          })
          .height(46)
          .padding(12)
          .backgroundColor(THEME_SURFACE_MUTED)
          .borderRadius(RADIUS_PILL)

        TextInput({ placeholder: this.systemRoleInputHint(), text: this.systemDisplayNameInput })
          .onChange((value: string) => {
            this.systemDisplayNameInput = value
          })
          .height(46)
          .padding(12)
          .backgroundColor(THEME_SURFACE_MUTED)
          .borderRadius(RADIUS_PILL)

        TextInput({ placeholder: '备注，如：入职部门 / 商户联系人 / 权限说明', text: this.systemRemarkInput })
          .onChange((value: string) => {
            this.systemRemarkInput = value
          })
          .height(46)
          .padding(12)
          .backgroundColor(THEME_SURFACE_MUTED)
          .borderRadius(RADIUS_PILL)

        Button('分配新系统账号')
          .height(48)
          .width('100%')
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_PRIMARY)
          .fontColor(Color.White)
          .onClick(() => this.createSystemAccount())

        if (this.systemMessage.length > 0) {
          Text(this.systemMessage)
            .fontSize(12)
            .fontColor(this.systemMessage.startsWith('请') ? THEME_DANGER : THEME_SUCCESS)
            .lineHeight(18)
            .width('100%')
        }
      }
      .width('100%')
      .padding(20)
      .backgroundColor(THEME_SURFACE)
      .borderRadius(RADIUS_LG)
      .shadow(SHADOW_CARD)
    }
    .padding({ left: 20, right: 20, bottom: 30 })
  }

  @Builder
  private SystemLogsView(): void {
    Column({ space: 18 }) {
      this.SystemSectionTitle('操作日志审计', '记录账号、权限、参数变更与异常访问')
      Column() {
        ForEach(this.systemLogs, (item: SystemLogItem) => {
          this.SystemLogRow(item)
        }, (item: SystemLogItem) => item.title)
      }
      .width('100%')
      .backgroundColor(THEME_SURFACE)
      .borderRadius(RADIUS_LG)
      .shadow(SHADOW_CARD)
    }
    .padding({ left: 20, right: 20, bottom: 30 })
  }

  @Builder
  private SystemRbacView(): void {
    Column({ space: 18 }) {
      this.SystemSectionTitle('RBAC 角色配置', '系统级权限映射后续接入真实配置')
      Column({ space: 12 }) {
        Text('当前版本采用“角色派生权限”方案')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
        Text('正式角色已收敛为：平台管理员、酒店管理员、投诉处理员、游客、系统管理员。后续可在这里接入权限矩阵、菜单授权和接口审计。')
          .fontSize(13)
          .fontColor(THEME_TEXT_SECONDARY)
          .lineHeight(22)
      }
      .width('100%')
      .padding(22)
      .backgroundColor(THEME_SURFACE)
      .borderRadius(RADIUS_LG)
      .shadow(SHADOW_CARD)
    }
    .padding({ left: 20, right: 20, bottom: 30 })
  }

  @Builder
  private SystemSettingsView(): void {
    Column({ space: 18 }) {
      this.SystemSectionTitle('系统参数设置', '接口、缓存、字典与安全策略维护')
      Column({ space: 12 }) {
        Text('参数维护入口')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
        Text('本轮先提供入口占位，后续可扩展登录策略、验证码有效期、投诉超时规则、应急信息有效期默认值等系统参数。')
          .fontSize(13)
          .fontColor(THEME_TEXT_SECONDARY)
          .lineHeight(22)
      }
      .width('100%')
      .padding(22)
      .backgroundColor(THEME_SURFACE)
      .borderRadius(RADIUS_LG)
      .shadow(SHADOW_CARD)
    }
    .padding({ left: 20, right: 20, bottom: 30 })
  }

  @Builder
  private SystemAdminShellView(): void {
    Column() {
      this.SingleRoleHeader()
      Column() {
        SystemAdminPage()
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(THEME_PAGE_BG)
  }

  @Builder
  private SingleRoleHeader(): void {
    Row({ space: 8 }) {
      Column({ space: 2 }) {
        Text(`欢迎你：${this.currentDisplayName('游客')}`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(THEME_TEXT_PRIMARY)
        Text(`当前角色：${this.authStore.getRoleLabel()}`)
          .fontSize(12)
          .fontColor(THEME_TEXT_SECONDARY)
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Button('退出登录')
        .height(34)
        .padding({ left: 14, right: 14 })
        .borderRadius(RADIUS_PILL)
        .backgroundColor(THEME_PRIMARY_SOFT)
        .fontColor(THEME_PRIMARY)
        .onClick(() => this.doLogout())
    }
    .padding(12)
    .margin({ left: 12, right: 12, top: 12, bottom: 8 })
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
    .width('100%')
  }

  @Builder
  private ComplaintHandlerShellView(): void {
    Column() {
      this.SingleRoleHeader()
      Column() {
        ComplaintPage({ mode: 'handler' })
      }
      .layoutWeight(1)
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(THEME_PAGE_BG)
  }

  @Builder
  private HotelAdminShellView(): void {
    Column() {
      this.SingleRoleHeader()
      Column() {
        HotelPage({ mode: 'manager' })
      }
      .layoutWeight(1)
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(THEME_PAGE_BG)
  }

  @Builder
  private RoleHomeView(): void {
    Column() {
      Row({ space: 8 }) {
        Column({ space: 2 }) {
          Text(`欢迎你：${this.currentDisplayName('游客')}`)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(THEME_TEXT_PRIMARY)
          Text(`当前角色：${this.authStore.getRoleLabel()}`)
            .fontSize(12)
            .fontColor(THEME_TEXT_SECONDARY)
        }.alignItems(HorizontalAlign.Start)

        Blank()

        Button('退出登录')
          .height(34)
          .padding({ left: 14, right: 14 })
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_PRIMARY_SOFT)
          .fontColor(THEME_PRIMARY)
          .onClick(() => this.doLogout())
      }
      .padding(12)
      .margin({ left: 12, right: 12, top: 12, bottom: 8 })
      .backgroundColor(THEME_SURFACE)
      .borderRadius(RADIUS_LG)
      .shadow(SHADOW_CARD)
      .width('100%')

      if (this.hasMultipleRoleTabs()) {
        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.getRoleTabs(), (tab: TabItem) => {
              Button(tab.title)
                .fontSize(14)
                .fontWeight(this.isTabSelected(tab.key) ? FontWeight.Medium : FontWeight.Normal)
                .fontColor(this.isTabSelected(tab.key) ? Color.White : THEME_TEXT_SECONDARY)
                .backgroundColor(this.isTabSelected(tab.key) ? THEME_PRIMARY : '#EEF3FA')
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .borderRadius(RADIUS_PILL)
                .height(40)
                .stateEffect(true)
                .onClick(() => this.switchTab(tab.key))
            }, (tab: TabItem) => tab.key)
          }
          .padding({ right: 12 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
        .height(48)
        .padding({ left: 12, right: 12, top: 6, bottom: 8 })
        .margin({ left: 12, right: 12, bottom: 8 })
        .backgroundColor(THEME_SURFACE)
        .borderRadius(RADIUS_LG)
        .shadow(SHADOW_CARD)
      }

      if (this.hasMultipleRoleTabs()) {
        Column() {
          if (this.selectedTabKey.length > 0) {
            this.renderRoleTab()
          }
        }
        .layoutWeight(1)
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
      } else if (this.selectedTabKey.length > 0) {
        this.renderRoleTab()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(THEME_PAGE_BG)
  }

  @Builder
  private renderVisitorTab(): void {
    if (this.visitorNav === 'home') {
      VisitorHomePage({
        displayName: this.currentDisplayName('游客'),
        navKey: this.visitorNav,
        serviceTab: this.visitorServiceTab
      })
    } else if (this.visitorNav === 'services') {
      VisitorServicesPage({ mainTab: this.visitorServiceTab })
    } else if (this.visitorNav === 'complaint') {
      ComplaintPage({ mode: 'visitor' })
    } else {
      EmergencyPage({ mode: 'visitor' })
    }
  }

  @Builder
  private renderRoleTab(): void {
    if (this.selectedTabKey.startsWith('complaint')) {
      ComplaintPage({ mode: this.complaintModeByKey(this.selectedTabKey) })
    } else if (this.selectedTabKey.startsWith('emergency')) {
      EmergencyPage({ mode: this.emergencyModeByKey(this.selectedTabKey) })
    } else if (this.selectedTabKey.startsWith('hotel')) {
      HotelPage({ mode: this.hotelModeByKey(this.selectedTabKey) })
    } else if (this.selectedTabKey === 'scenic') {
      ScenicRoutePage()
    } else if (this.selectedTabKey === 'dining') {
      DiningShowPage()
    } else if (this.selectedTabKey === 'weather') {
      WeatherTrafficPage()
    }
  }

  build() {
    Column() {
      if (this.authStore.currentUser === null) {
        this.LoginView()
      } else if (this.isVisitor()) {
        this.VisitorShellView()
      } else if (this.isAdmin() || this.isApprover()) {
        this.AdminShellView()
      } else if (this.isSystemAdmin()) {
        this.SystemAdminShellView()
      } else if (this.isComplaintHandler()) {
        this.ComplaintHandlerShellView()
      } else if (this.isHotelAdmin()) {
        this.HotelAdminShellView()
      } else {
        this.RoleHomeView()
      }
    }
    .width('100%')
    .height('100%')
    .opacity(this.pageOpacity)
    .translate({ x: 0, y: this.pageOffsetY })
  }
}
