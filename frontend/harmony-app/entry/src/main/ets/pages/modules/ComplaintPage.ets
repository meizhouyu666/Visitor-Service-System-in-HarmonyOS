import {
  ComplaintActionRequest,
  ComplaintAssignRequest,
  ComplaintCreateRequest,
  ComplaintItem,
  ComplaintQueryFilter,
  ComplaintRatingRequest,
  ComplaintTimelineItem
} from '../../common/model/ApiModels'
import { apiClient } from '../../common/network/ApiClient'
import {
  complaintStatusTone,
  RADIUS_LG,
  RADIUS_MD,
  RADIUS_PILL,
  SHADOW_CARD,
  StatusTone,
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
import { EmptyStateCard, FloatingCard, SectionHeader, StatusBadge, TimelineNode } from '../../common/ui/UiKit'

export type ComplaintMode = 'visitor' | 'approver' | 'handler' | 'admin'
type HandlerTab = 'pending' | 'confirming' | 'closed'
type AdminWorkflowTab = 'dispatch' | 'processing' | 'closing' | 'archived'

interface AdminAssigneeOption {
  username: string
  title: string
  subtitle: string
}

@Component
export struct ComplaintPage {
  @Prop mode: ComplaintMode = 'visitor'

  @State private items: ComplaintItem[] = []
  @State private timelines: ComplaintTimelineItem[] = []

  @State private loading: boolean = false
  @State private timelineLoading: boolean = false
  @State private errorMessage: string = ''
  @State private actionMessage: string = ''

  @State private titleInput: string = ''
  @State private contentInput: string = ''

  @State private selectedId: number = 0
  @State private commentInput: string = ''
  @State private assigneeInput: string = ''
  @State private ratingInput: string = '5'
  @State private handlerTab: HandlerTab = 'pending'
  @State private handlerFormVisible: boolean = false
  @State private adminWorkflowTab: AdminWorkflowTab = 'dispatch'
  @State private adminApprovalVisible: boolean = false

  @State private filters: ComplaintQueryFilter = {
    status: '',
    createdBy: '',
    assignee: '',
    keyword: '',
    from: '',
    to: ''
  }

  private adminAssigneeOptions: AdminAssigneeOption[] = [
    { username: 'handler', title: '安保与秩序组（王师傅）', subtitle: '现场设施、秩序与安全处置' },
    { username: 'writer', title: '票务与客服中心（刘专员）', subtitle: '票务退款、服务咨询与客服协调' },
    { username: 'approver', title: '餐饮卫生监督组（张主管）', subtitle: '餐饮卫生、商户服务与巡查' },
    { username: 'hoteladmin', title: '酒店服务协同组（陈经理）', subtitle: '酒店住宿、客房设施与入住争议' }
  ]

  async aboutToAppear(): Promise<void> {
    await this.loadComplaints()
  }

  private isVisitorMode(): boolean {
    return this.mode === 'visitor'
  }

  private isApproverMode(): boolean {
    return this.mode === 'approver' || this.mode === 'admin'
  }

  private isHandlerMode(): boolean {
    return this.mode === 'handler' || this.mode === 'admin'
  }

  private showAdvancedFilters(): boolean {
    return this.isApproverMode() || this.isHandlerMode()
  }

  private modeTitle(): string {
    if (this.mode === 'visitor') {
      return '游客投诉'
    }
    if (this.mode === 'approver') {
      return '投诉审批'
    }
    if (this.mode === 'handler') {
      return '投诉处理'
    }
    return '投诉管理（管理员）'
  }

  private parseRating(): number {
    const value: number = Number(this.ratingInput)
    if (Number.isNaN(value)) {
      return 5
    }
    if (value < 1) {
      return 1
    }
    if (value > 5) {
      return 5
    }
    return Math.floor(value)
  }

  private hasSelectedComplaint(): boolean {
    return this.selectedId > 0
  }

  private ensureSelected(): void {
    if (this.items.length === 0) {
      this.selectedId = 0
      return
    }
    const exists: boolean = this.items.some((item: ComplaintItem) => item.id === this.selectedId)
    if (!exists) {
      this.selectedId = this.items[0].id
    }
  }

  private selectComplaint(id: number): void {
    this.selectedId = id
    this.loadTimeline()
  }

  private selectedComplaint(): ComplaintItem | undefined {
    return this.items.find((item: ComplaintItem) => item.id === this.selectedId)
  }

  private selectedComplaintTitle(): string {
    const item: ComplaintItem | undefined = this.selectedComplaint()
    return item === undefined ? '未选择工单' : item.title
  }

  private selectedComplaintContent(): string {
    const item: ComplaintItem | undefined = this.selectedComplaint()
    return item === undefined ? '请先选择一条投诉工单。' : item.content
  }

  private selectedComplaintCreator(): string {
    const item: ComplaintItem | undefined = this.selectedComplaint()
    return item === undefined ? '待确认' : item.createdBy
  }

  private selectedComplaintCode(): string {
    const item: ComplaintItem | undefined = this.selectedComplaint()
    if (item === undefined) {
      return 'TS-000000'
    }
    return this.complaintCode(item)
  }

  private selectedComplaintLocation(): string {
    const item: ComplaintItem | undefined = this.selectedComplaint()
    return item === undefined ? '位置待确认' : this.handlerLocationText(item)
  }

  private selectedComplaintTypeLabel(): string {
    const item: ComplaintItem | undefined = this.selectedComplaint()
    return item === undefined ? '综合投诉' : this.handlerTypeLabel(item)
  }

  private selectedComplaintTypeColor(): string {
    const item: ComplaintItem | undefined = this.selectedComplaint()
    return item === undefined ? THEME_PRIMARY : this.handlerTypeColor(item)
  }

  private selectedComplaintTypeBg(): string {
    const item: ComplaintItem | undefined = this.selectedComplaint()
    return item === undefined ? THEME_PRIMARY_SOFT : this.handlerTypeBg(item)
  }

  private isHandlerPending(item: ComplaintItem): boolean {
    return item.status !== 'RESOLVED' && item.status !== 'CLOSED'
  }

  private isHandlerConfirming(item: ComplaintItem): boolean {
    return item.status === 'RESOLVED'
  }

  private isHandlerClosed(item: ComplaintItem): boolean {
    return item.status === 'CLOSED'
  }

  private handlerPendingItems(): ComplaintItem[] {
    return this.items.filter((item: ComplaintItem) => this.isHandlerPending(item))
  }

  private handlerConfirmingItems(): ComplaintItem[] {
    return this.items.filter((item: ComplaintItem) => this.isHandlerConfirming(item))
  }

  private handlerClosedItems(): ComplaintItem[] {
    return this.items.filter((item: ComplaintItem) => this.isHandlerClosed(item))
  }

  private handlerVisibleItems(): ComplaintItem[] {
    if (this.handlerTab === 'confirming') {
      return this.handlerConfirmingItems()
    }
    if (this.handlerTab === 'closed') {
      return this.handlerClosedItems()
    }
    return this.handlerPendingItems()
  }

  private switchHandlerTab(tab: HandlerTab): void {
    if (this.handlerTab === tab) {
      return
    }
    this.handlerTab = tab
    this.handlerFormVisible = false
    const visibleItems: ComplaintItem[] = this.handlerVisibleItems()
    this.selectedId = visibleItems.length > 0 ? visibleItems[0].id : 0
    this.loadTimeline()
  }

  private openHandlerForm(item: ComplaintItem): void {
    this.selectedId = item.id
    this.commentInput = ''
    this.actionMessage = ''
    this.errorMessage = ''
    this.handlerFormVisible = true
    this.loadTimeline()
  }

  private closeHandlerForm(): void {
    this.handlerFormVisible = false
    this.commentInput = ''
    this.actionMessage = ''
  }

  private isAdminDispatchItem(item: ComplaintItem): boolean {
    return item.status === 'SUBMITTED'
  }

  private isAdminProcessingItem(item: ComplaintItem): boolean {
    return item.status === 'APPROVED' || item.status === 'IN_PROGRESS'
  }

  private isAdminClosingItem(item: ComplaintItem): boolean {
    return item.status === 'RESOLVED'
  }

  private isAdminArchivedItem(item: ComplaintItem): boolean {
    return item.status === 'CLOSED' || item.status === 'REJECTED'
  }

  private adminDispatchItems(): ComplaintItem[] {
    return this.items.filter((item: ComplaintItem) => this.isAdminDispatchItem(item))
  }

  private adminProcessingItems(): ComplaintItem[] {
    return this.items.filter((item: ComplaintItem) => this.isAdminProcessingItem(item))
  }

  private adminClosingItems(): ComplaintItem[] {
    return this.items.filter((item: ComplaintItem) => this.isAdminClosingItem(item))
  }

  private adminArchivedItems(): ComplaintItem[] {
    return this.items.filter((item: ComplaintItem) => this.isAdminArchivedItem(item))
  }

  private adminVisibleItems(): ComplaintItem[] {
    if (this.adminWorkflowTab === 'processing') {
      return this.adminProcessingItems()
    }
    if (this.adminWorkflowTab === 'closing') {
      return this.adminClosingItems()
    }
    if (this.adminWorkflowTab === 'archived') {
      return this.adminArchivedItems()
    }
    return this.adminDispatchItems()
  }

  private switchAdminWorkflowTab(tab: AdminWorkflowTab): void {
    if (this.adminWorkflowTab === tab && !this.adminApprovalVisible) {
      return
    }
    this.adminWorkflowTab = tab
    this.adminApprovalVisible = false
    this.commentInput = ''
    this.assigneeInput = ''
    this.actionMessage = ''
    this.errorMessage = ''
    const visibleItems: ComplaintItem[] = this.adminVisibleItems()
    this.selectedId = visibleItems.length > 0 ? visibleItems[0].id : 0
    this.loadTimeline()
  }

  private openAdminApprovalDetail(item: ComplaintItem): void {
    this.selectedId = item.id
    this.adminApprovalVisible = true
    this.commentInput = ''
    this.assigneeInput = item.assignee ?? ''
    this.actionMessage = ''
    this.errorMessage = ''
    this.loadTimeline()
  }

  private closeAdminApprovalDetail(): void {
    this.adminApprovalVisible = false
    this.commentInput = ''
    this.assigneeInput = ''
    this.actionMessage = ''
    this.errorMessage = ''
  }

  private selectAdminAssignee(username: string): void {
    this.assigneeInput = username
  }

  private isAdminAssigneeSelected(username: string): boolean {
    return this.assigneeInput === username
  }

  private adminAssigneeTitle(username: string): string {
    const option: AdminAssigneeOption | undefined = this.adminAssigneeOptions.find((item: AdminAssigneeOption) => item.username === username)
    return option === undefined ? '待分派' : option.title
  }

  private adminAssigneeSubtitle(username: string): string {
    const option: AdminAssigneeOption | undefined = this.adminAssigneeOptions.find((item: AdminAssigneeOption) => item.username === username)
    return option === undefined ? '请选择责任部门与处理人' : option.subtitle
  }

  private complaintCode(item: ComplaintItem): string {
    return `TS-${item.id.toString().padStart(6, '0')}`
  }

  private adminCardTimeLabel(item: ComplaintItem): string {
    if (item.updatedAt.length >= 16) {
      return item.updatedAt.slice(5, 16).replace('T', ' ')
    }
    return item.updatedAt
  }

  private adminProcessingSummary(item: ComplaintItem): string {
    if (item.processedBy !== null && item.processedBy.length > 0) {
      return `${this.adminAssigneeTitle(item.processedBy)} 处理中`
    }
    if (item.assignee !== null && item.assignee.length > 0) {
      return `${this.adminAssigneeTitle(item.assignee)} 已接单`
    }
    return '已审批通过，等待责任人反馈'
  }

  private adminArchiveSummary(item: ComplaintItem): string {
    if (item.status === 'REJECTED') {
      return item.rejectionComment !== null && item.rejectionComment.length > 0 ? item.rejectionComment : '已驳回并归档'
    }
    if (item.rating !== null) {
      return `游客评分：${item.rating} 分`
    }
    return '流程已完成归档'
  }

  private async approveAndAssignComplaint(): Promise<void> {
    if (!this.hasSelectedComplaint()) {
      this.actionMessage = '请先选择一条待审批工单'
      return
    }
    if (this.assigneeInput.trim().length === 0) {
      this.actionMessage = '请先选择责任部门与处理人'
      return
    }

    this.loading = true
    this.errorMessage = ''
    this.actionMessage = ''
    try {
      const approvePayload: ComplaintActionRequest = {
        comment: this.commentInput.trim().length > 0 ? this.commentInput : '投诉有效，进入派单处置流程'
      }
      const assignPayload: ComplaintAssignRequest = {
        assigneeUsername: this.assigneeInput,
        comment: this.commentInput.trim().length > 0 ? this.commentInput : '请尽快核实情况并回传处理结果'
      }
      await apiClient.post<ComplaintActionRequest, ComplaintItem>(`/api/complaints/admin/${this.selectedId}/approve`, approvePayload)
      await apiClient.post<ComplaintAssignRequest, ComplaintItem>(`/api/complaints/admin/${this.selectedId}/assign`, assignPayload)
      this.actionMessage = '已完成审批并派发工单'
      await this.loadComplaints()
      if (this.errorMessage.length === 0) {
        this.adminApprovalVisible = false
        this.adminWorkflowTab = 'processing'
      }
    } catch (_error) {
      this.errorMessage = '审批派单失败，请稍后重试'
    } finally {
      this.loading = false
    }
  }

  private async rejectFromAdmin(): Promise<void> {
    await this.rejectComplaint()
    if (this.errorMessage.length === 0) {
      this.adminApprovalVisible = false
      this.adminWorkflowTab = 'archived'
    }
  }

  private async closeFromAdmin(item: ComplaintItem): Promise<void> {
    this.selectedId = item.id
    this.commentInput = '已完成复核，工单正式归档'
    await this.closeComplaint()
    if (this.errorMessage.length === 0) {
      this.adminWorkflowTab = 'archived'
    }
  }

  private handlerTypeLabel(item: ComplaintItem): string {
    const text: string = `${item.title} ${item.content}`
    if (text.indexOf('退款') >= 0 || text.indexOf('票') >= 0 || text.indexOf('费用') >= 0 || text.indexOf('价格') >= 0) {
      return '票务退款'
    }
    if (text.indexOf('餐') >= 0 || text.indexOf('菜') >= 0 || text.indexOf('卫生') >= 0 || text.indexOf('食品') >= 0) {
      return '餐饮卫生'
    }
    if (text.indexOf('酒店') >= 0 || text.indexOf('空调') >= 0 || text.indexOf('房') >= 0) {
      return '酒店服务'
    }
    if (text.indexOf('坏') >= 0 || text.indexOf('维修') >= 0 || text.indexOf('设施') >= 0 || text.indexOf('护栏') >= 0) {
      return '设施维修'
    }
    return '服务纠纷'
  }

  private handlerTypeColor(item: ComplaintItem): string {
    const label: string = this.handlerTypeLabel(item)
    if (label === '餐饮卫生') {
      return '#EA580C'
    }
    if (label === '票务退款') {
      return '#7C3AED'
    }
    if (label === '设施维修') {
      return THEME_PRIMARY
    }
    if (label === '酒店服务') {
      return THEME_SUCCESS
    }
    return THEME_PRIMARY
  }

  private handlerTypeBg(item: ComplaintItem): string {
    const label: string = this.handlerTypeLabel(item)
    if (label === '餐饮卫生') {
      return '#FFF4E6'
    }
    if (label === '票务退款') {
      return '#F3E8FF'
    }
    if (label === '设施维修') {
      return THEME_PRIMARY_SOFT
    }
    if (label === '酒店服务') {
      return '#EAF8EF'
    }
    return THEME_PRIMARY_SOFT
  }

  private handlerUrgencyLabel(item: ComplaintItem): string {
    if (item.title.indexOf('急') >= 0 || item.content.indexOf('急') >= 0 || item.content.indexOf('严重') >= 0) {
      return '紧急'
    }
    return '常规'
  }

  private handlerUrgencyColor(item: ComplaintItem): string {
    return this.handlerUrgencyLabel(item) === '紧急' ? THEME_DANGER : THEME_TEXT_TERTIARY
  }

  private handlerUrgencyBg(item: ComplaintItem): string {
    return this.handlerUrgencyLabel(item) === '紧急' ? '#FFECEC' : THEME_SURFACE_MUTED
  }

  private handlerLocationText(item: ComplaintItem): string {
    const content: string = item.content.trim()
    if (content.length === 0) {
      return '位置待确认'
    }
    const markerIndex: number = content.indexOf('地点')
    if (markerIndex >= 0) {
      const afterMarker: string = content.slice(markerIndex + 2).replace('：', '').replace(':', '').trim()
      const stopIndex: number = afterMarker.indexOf('，')
      if (stopIndex > 0) {
        return afterMarker.slice(0, stopIndex)
      }
      return afterMarker.length > 0 ? afterMarker : '位置待确认'
    }
    const commaIndex: number = content.indexOf('，')
    if (commaIndex > 0 && commaIndex <= 18) {
      return content.slice(0, commaIndex)
    }
    return '服务发生地点待补充'
  }

  private handlerTimeLabel(item: ComplaintItem): string {
    if (item.updatedAt.length >= 16) {
      return item.updatedAt.slice(11, 16)
    }
    return '刚刚'
  }

  private recordPhoneCall(item: ComplaintItem): void {
    this.selectedId = item.id
    this.actionMessage = '已记录电话沟通动作，可继续补充处理意见'
  }

  private applyHandlerPlan(plan: string): void {
    this.commentInput = plan
    this.actionMessage = '已填入快速处理方案，可继续补充细节'
  }

  private buildListPath(): string {
    const params: string[] = []

    if (this.filters.status.trim().length > 0) {
      params.push(`status=${encodeURIComponent(this.filters.status.trim())}`)
    }
    if (this.filters.createdBy.trim().length > 0) {
      params.push(`createdBy=${encodeURIComponent(this.filters.createdBy.trim())}`)
    }
    if (this.filters.assignee.trim().length > 0) {
      params.push(`assignee=${encodeURIComponent(this.filters.assignee.trim())}`)
    }
    if (this.filters.keyword.trim().length > 0) {
      params.push(`keyword=${encodeURIComponent(this.filters.keyword.trim())}`)
    }
    if (this.filters.from.trim().length > 0) {
      params.push(`from=${encodeURIComponent(this.filters.from.trim())}`)
    }
    if (this.filters.to.trim().length > 0) {
      params.push(`to=${encodeURIComponent(this.filters.to.trim())}`)
    }

    if (params.length === 0) {
      return '/api/complaints'
    }
    return `/api/complaints?${params.join('&')}`
  }

  private async loadComplaints(): Promise<void> {
    this.loading = true
    this.errorMessage = ''
    try {
      const list: ComplaintItem[] = await apiClient.get<ComplaintItem[]>(this.buildListPath())
      this.items = [...list]
      this.ensureSelected()
      await this.loadTimeline()
    } catch (_error) {
      this.errorMessage = '加载投诉列表失败，请稍后重试'
    } finally {
      this.loading = false
    }
  }

  private async loadTimeline(): Promise<void> {
    if (!this.hasSelectedComplaint()) {
      this.timelines = []
      return
    }
    this.timelineLoading = true
    try {
      const list: ComplaintTimelineItem[] = await apiClient.get<ComplaintTimelineItem[]>(`/api/complaints/${this.selectedId}/timeline`)
      this.timelines = [...list]
    } catch (_error) {
      this.timelines = []
    } finally {
      this.timelineLoading = false
    }
  }

  private resetFilters(): void {
    this.filters = {
      status: '',
      createdBy: '',
      assignee: '',
      keyword: '',
      from: '',
      to: ''
    }
    this.loadComplaints()
  }

  private updateFilter(field: string, value: string): void {
    const next: ComplaintQueryFilter = {
      status: this.filters.status,
      createdBy: this.filters.createdBy,
      assignee: this.filters.assignee,
      keyword: this.filters.keyword,
      from: this.filters.from,
      to: this.filters.to
    }

    if (field === 'status') {
      next.status = value
    } else if (field === 'createdBy') {
      next.createdBy = value
    } else if (field === 'assignee') {
      next.assignee = value
    } else if (field === 'keyword') {
      next.keyword = value
    } else if (field === 'from') {
      next.from = value
    } else if (field === 'to') {
      next.to = value
    }

    this.filters = next
  }

  private async submitComplaint(): Promise<void> {
    if (this.titleInput.trim().length === 0 || this.contentInput.trim().length === 0) {
      this.actionMessage = '请先填写标题和内容'
      return
    }

    this.loading = true
    this.errorMessage = ''
    this.actionMessage = ''
    try {
      const payload: ComplaintCreateRequest = {
        title: this.titleInput,
        content: this.contentInput
      }
      await apiClient.post<ComplaintCreateRequest, ComplaintItem>('/api/complaints', payload)
      this.titleInput = ''
      this.contentInput = ''
      this.actionMessage = '投诉已提交'
      await this.loadComplaints()
    } catch (_error) {
      this.errorMessage = '提交投诉失败'
    } finally {
      this.loading = false
    }
  }

  private async approveComplaint(): Promise<void> {
    if (!this.hasSelectedComplaint()) {
      this.actionMessage = '请先选择一条投诉'
      return
    }
    const payload: ComplaintActionRequest = {
      comment: this.commentInput.trim().length > 0 ? this.commentInput : '审批通过'
    }
    await this.runAction(`/api/complaints/admin/${this.selectedId}/approve`, payload, '已审批通过')
  }

  private async rejectComplaint(): Promise<void> {
    if (!this.hasSelectedComplaint()) {
      this.actionMessage = '请先选择一条投诉'
      return
    }
    const payload: ComplaintActionRequest = {
      comment: this.commentInput.trim().length > 0 ? this.commentInput : '审批驳回'
    }
    await this.runAction(`/api/complaints/admin/${this.selectedId}/reject`, payload, '已驳回投诉')
  }

  private async assignComplaint(): Promise<void> {
    if (!this.hasSelectedComplaint()) {
      this.actionMessage = '请先选择一条投诉'
      return
    }
    if (this.assigneeInput.trim().length === 0) {
      this.actionMessage = '请输入处理人账号'
      return
    }

    this.loading = true
    this.errorMessage = ''
    this.actionMessage = ''
    try {
      const payload: ComplaintAssignRequest = {
        assigneeUsername: this.assigneeInput,
        comment: this.commentInput
      }
      await apiClient.post<ComplaintAssignRequest, ComplaintItem>(`/api/complaints/admin/${this.selectedId}/assign`, payload)
      this.commentInput = ''
      this.actionMessage = '已完成分派'
      await this.loadComplaints()
    } catch (_error) {
      this.errorMessage = '分派失败'
    } finally {
      this.loading = false
    }
  }

  private async processComplaint(): Promise<void> {
    if (!this.hasSelectedComplaint()) {
      this.actionMessage = '请先选择一条投诉'
      return
    }
    if (this.mode === 'handler' && this.commentInput.trim().length === 0) {
      this.actionMessage = '请先填写处理意见或选择快速处理方案'
      return
    }
    const payload: ComplaintActionRequest = {
      comment: this.commentInput.trim().length > 0 ? this.commentInput : '已处理投诉'
    }
    await this.runAction(`/api/complaints/admin/${this.selectedId}/process`, payload, '已提交处理结果')
    if (this.mode === 'handler' && this.errorMessage.length === 0) {
      this.handlerFormVisible = false
      this.handlerTab = 'confirming'
    }
  }

  private async closeComplaint(): Promise<void> {
    if (!this.hasSelectedComplaint()) {
      this.actionMessage = '请先选择一条投诉'
      return
    }
    const payload: ComplaintActionRequest = {
      comment: this.commentInput.trim().length > 0 ? this.commentInput : '已结案'
    }
    await this.runAction(`/api/complaints/admin/${this.selectedId}/close`, payload, '投诉已结案')
  }

  private async rateComplaint(): Promise<void> {
    if (!this.hasSelectedComplaint()) {
      this.actionMessage = '请先选择一条投诉'
      return
    }

    this.loading = true
    this.errorMessage = ''
    this.actionMessage = ''
    try {
      const payload: ComplaintRatingRequest = { rating: this.parseRating() }
      await apiClient.post<ComplaintRatingRequest, ComplaintItem>(`/api/complaints/${this.selectedId}/rating`, payload)
      this.actionMessage = '评价已提交'
      await this.loadComplaints()
    } catch (_error) {
      this.errorMessage = '评价失败：仅可对已结案投诉评价'
    } finally {
      this.loading = false
    }
  }

  private async runAction(path: string, payload: ComplaintActionRequest, successMessage: string): Promise<void> {
    this.loading = true
    this.errorMessage = ''
    this.actionMessage = ''
    try {
      await apiClient.post<ComplaintActionRequest, ComplaintItem>(path, payload)
      this.commentInput = ''
      this.actionMessage = successMessage
      await this.loadComplaints()
    } catch (_error) {
      this.errorMessage = '操作失败，请稍后重试'
    } finally {
      this.loading = false
    }
  }

  private statusLabel(status: string): string {
    if (status === 'SUBMITTED') {
      return '待审批'
    }
    if (status === 'REJECTED') {
      return '已驳回'
    }
    if (status === 'APPROVED') {
      return '已审批'
    }
    if (status === 'IN_PROGRESS') {
      return '处理中'
    }
    if (status === 'RESOLVED') {
      return '待结案'
    }
    if (status === 'CLOSED') {
      return '已结案'
    }
    return status
  }

  private statusTone(status: string): StatusTone {
    return complaintStatusTone(status)
  }

  private actionLabel(action: string): string {
    if (action === 'CREATE') {
      return '提交投诉'
    }
    if (action === 'APPROVE') {
      return '审批通过'
    }
    if (action === 'REJECT') {
      return '审批驳回'
    }
    if (action === 'ASSIGN') {
      return '分派处理人'
    }
    if (action === 'PROCESS') {
      return '提交处理'
    }
    if (action === 'CLOSE') {
      return '结案'
    }
    if (action === 'RATE') {
      return '提交评价'
    }
    return action
  }

  private latestComplaint(): ComplaintItem | null {
    if (this.items.length === 0) {
      return null
    }
    return this.items[0]
  }

  private complaintStepIndex(status: string): number {
    if (status === 'SUBMITTED') {
      return 1
    }
    if (status === 'APPROVED' || status === 'REJECTED') {
      return 2
    }
    if (status === 'IN_PROGRESS' || status === 'RESOLVED') {
      return 3
    }
    if (status === 'CLOSED') {
      return 4
    }
    return 1
  }

  private hasLatestComplaint(): boolean {
    return this.latestComplaint() !== null
  }

  private latestComplaintStatusLabel(): string {
    const latest: ComplaintItem | null = this.latestComplaint()
    if (latest === null) {
      return '待提交'
    }
    return this.statusLabel(latest.status)
  }

  private visitorProgressStep(): number {
    const latest: ComplaintItem | null = this.latestComplaint()
    if (latest === null) {
      return 1
    }
    return this.complaintStepIndex(latest.status)
  }

  @Builder
  private FilterPanel(): void {
    Column({ space: 8 }) {
      Text('筛选条件').fontSize(16).fontWeight(FontWeight.Medium).fontColor(THEME_TEXT_PRIMARY)

      Row({ space: 8 }) {
        TextInput({ placeholder: '状态（如 SUBMITTED）', text: this.filters.status })
          .onChange((value: string) => {
            this.updateFilter('status', value)
          })
          .layoutWeight(1)
          .backgroundColor(THEME_SURFACE)
          .borderRadius(RADIUS_MD)
          .padding(8)
        TextInput({ placeholder: '关键词（标题/内容）', text: this.filters.keyword })
          .onChange((value: string) => {
            this.updateFilter('keyword', value)
          })
          .layoutWeight(1)
          .backgroundColor(THEME_SURFACE)
          .borderRadius(RADIUS_MD)
          .padding(8)
      }

      Row({ space: 8 }) {
        TextInput({ placeholder: '开始时间（ISO）', text: this.filters.from })
          .onChange((value: string) => {
            this.updateFilter('from', value)
          })
          .layoutWeight(1)
          .backgroundColor(THEME_SURFACE)
          .borderRadius(RADIUS_MD)
          .padding(8)
        TextInput({ placeholder: '结束时间（ISO）', text: this.filters.to })
          .onChange((value: string) => {
            this.updateFilter('to', value)
          })
          .layoutWeight(1)
          .backgroundColor(THEME_SURFACE)
          .borderRadius(RADIUS_MD)
          .padding(8)
      }

      if (this.showAdvancedFilters()) {
        Row({ space: 8 }) {
          TextInput({ placeholder: '提交人账号', text: this.filters.createdBy })
            .onChange((value: string) => {
              this.updateFilter('createdBy', value)
            })
            .layoutWeight(1)
            .backgroundColor(THEME_SURFACE)
            .borderRadius(RADIUS_MD)
            .padding(8)
          TextInput({ placeholder: '处理人账号', text: this.filters.assignee })
            .onChange((value: string) => {
              this.updateFilter('assignee', value)
            })
            .layoutWeight(1)
            .backgroundColor(THEME_SURFACE)
            .borderRadius(RADIUS_MD)
            .padding(8)
        }
      }

      Row({ space: 8 }) {
        Button('应用筛选')
          .onClick(() => this.loadComplaints())
          .layoutWeight(1)
          .backgroundColor(THEME_PRIMARY)
          .fontColor(Color.White)
          .borderRadius(RADIUS_MD)
        Button('重置筛选')
          .onClick(() => this.resetFilters())
          .layoutWeight(1)
          .backgroundColor(THEME_SURFACE)
          .fontColor(THEME_TEXT_SECONDARY)
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
  private ActionPanel(): void {
    Column({ space: 8 }) {
      Text(this.modeTitle()).fontSize(20).fontWeight(FontWeight.Medium).fontColor(THEME_TEXT_PRIMARY)

      if (this.isVisitorMode()) {
        TextInput({ placeholder: '投诉标题', text: this.titleInput })
          .onChange((value: string) => {
            this.titleInput = value
          })
          .backgroundColor(THEME_SURFACE)
          .borderRadius(RADIUS_MD)
          .padding(10)

        TextArea({ placeholder: '投诉内容', text: this.contentInput })
          .onChange((value: string) => {
            this.contentInput = value
          })
          .backgroundColor(THEME_SURFACE)
          .borderRadius(RADIUS_MD)
          .height(90)
          .padding(10)

        Button('提交投诉')
          .onClick(() => this.submitComplaint())
          .backgroundColor(THEME_PRIMARY)
          .fontColor(Color.White)
          .borderRadius(RADIUS_MD)
      }

      if (this.isApproverMode() || this.isHandlerMode()) {
        TextInput({ placeholder: '处理意见', text: this.commentInput })
          .onChange((value: string) => {
            this.commentInput = value
          })
          .backgroundColor(THEME_SURFACE)
          .borderRadius(RADIUS_MD)
          .padding(10)
      }

      if (this.isApproverMode()) {
        TextInput({ placeholder: '分派处理人账号', text: this.assigneeInput })
          .onChange((value: string) => {
            this.assigneeInput = value
          })
          .backgroundColor(THEME_SURFACE)
          .borderRadius(RADIUS_MD)
          .padding(10)

        Row({ space: 8 }) {
          Button('审批通过')
            .onClick(() => this.approveComplaint())
            .layoutWeight(1)
            .backgroundColor(THEME_PRIMARY)
            .fontColor(Color.White)
            .borderRadius(RADIUS_MD)
          Button('驳回')
            .onClick(() => this.rejectComplaint())
            .layoutWeight(1)
            .backgroundColor(THEME_DANGER)
            .fontColor(Color.White)
            .borderRadius(RADIUS_MD)
          Button('分派')
            .onClick(() => this.assignComplaint())
            .layoutWeight(1)
            .backgroundColor(THEME_SURFACE)
            .fontColor(THEME_TEXT_SECONDARY)
            .borderRadius(RADIUS_MD)
        }
      }

      if (this.isHandlerMode()) {
        Row({ space: 8 }) {
          Button('提交处理')
            .onClick(() => this.processComplaint())
            .layoutWeight(1)
            .backgroundColor(THEME_PRIMARY)
            .fontColor(Color.White)
            .borderRadius(RADIUS_MD)
          Button('结案')
            .onClick(() => this.closeComplaint())
            .layoutWeight(1)
            .backgroundColor(THEME_SURFACE)
            .fontColor(THEME_TEXT_SECONDARY)
            .borderRadius(RADIUS_MD)
        }
      }

      if (this.isVisitorMode()) {
        TextInput({ placeholder: '满意度（1-5）', text: this.ratingInput })
          .onChange((value: string) => {
            this.ratingInput = value
          })
          .backgroundColor(THEME_SURFACE)
          .borderRadius(RADIUS_MD)
          .padding(10)

        Button('提交评价')
          .onClick(() => this.rateComplaint())
          .backgroundColor(THEME_PRIMARY)
          .fontColor(Color.White)
          .borderRadius(RADIUS_MD)
      }

      if (this.actionMessage.length > 0) {
        Text(this.actionMessage).fontColor(THEME_SUCCESS).fontSize(12)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding(12)
    .backgroundColor(THEME_SURFACE_MUTED)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private ComplaintListPanel(): void {
    if (this.loading) {
      Column() {
        Text('加载中...').fontColor(THEME_TEXT_SECONDARY)
      }
      .width('100%')
      .padding(20)
      .alignItems(HorizontalAlign.Center)
    } else if (this.errorMessage.length > 0) {
      Column({ space: 8 }) {
        Text(this.errorMessage).fontColor(THEME_DANGER).fontSize(12)
        Button('重试')
          .onClick(() => this.loadComplaints())
          .backgroundColor(THEME_PRIMARY)
          .fontColor(Color.White)
          .borderRadius(RADIUS_MD)
      }
      .width('100%')
      .padding(20)
      .alignItems(HorizontalAlign.Center)
    } else if (this.items.length === 0) {
      Column() {
        Text('暂无投诉记录').fontColor(THEME_TEXT_SECONDARY)
      }
      .width('100%')
      .padding(20)
      .alignItems(HorizontalAlign.Center)
    } else {
      List({ space: 8 }) {
        ForEach(this.items, (item: ComplaintItem) => {
          ListItem() {
            Column({ space: 6 }) {
              Row({ space: 6 }) {
                Text(item.title).fontSize(15).fontWeight(FontWeight.Medium).fontColor(THEME_TEXT_PRIMARY)
                Blank()
                Text(`${this.statusTone(item.status).icon} ${this.statusLabel(item.status)}`)
                  .fontSize(11)
                  .fontColor(this.statusTone(item.status).color)
                  .backgroundColor(this.statusTone(item.status).background)
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .borderRadius(RADIUS_MD)
              }
              Text(item.content).fontSize(12).maxLines(2).fontColor(THEME_TEXT_PRIMARY)
              Text(`提交人：${item.createdBy}`).fontSize(11).fontColor(THEME_TEXT_SECONDARY)
              Text(`处理人：${item.assignee ?? '-'}`).fontSize(11).fontColor(THEME_TEXT_SECONDARY)
              if (item.rejectionComment !== null && item.rejectionComment.length > 0) {
                Text(`驳回原因：${item.rejectionComment}`).fontSize(11).fontColor(THEME_DANGER).maxLines(2)
              }
              Text(`更新时间：${item.updatedAt}`).fontSize(10).fontColor(THEME_TEXT_TERTIARY)
            }
            .alignItems(HorizontalAlign.Start)
            .padding(10)
            .backgroundColor(this.selectedId === item.id ? THEME_PRIMARY_SOFT : THEME_SURFACE)
            .borderRadius(RADIUS_MD)
            .shadow(SHADOW_CARD)
            .onClick(() => this.selectComplaint(item.id))
          }
        }, (item: ComplaintItem) => `${item.id}`)
      }
      .layoutWeight(1)
      .width('100%')
    }
  }

  @Builder
  private TimelinePanel(): void {
    Column({ space: 6 }) {
      Text('投诉时间线').fontSize(16).fontWeight(FontWeight.Medium).fontColor(THEME_TEXT_PRIMARY)
      if (this.timelineLoading) {
        Text('时间线加载中...').fontSize(12).fontColor(THEME_TEXT_SECONDARY)
      } else if (this.timelines.length === 0) {
        Text('暂无时间线记录').fontSize(12).fontColor(THEME_TEXT_SECONDARY)
      } else {
        ForEach(this.timelines, (item: ComplaintTimelineItem) => {
          Column({ space: 2 }) {
            Text(`${this.actionLabel(item.action)} · ${item.actor ?? '-'}`).fontSize(12).fontWeight(FontWeight.Medium).fontColor(THEME_TEXT_PRIMARY)
            if (item.comment !== null && item.comment.length > 0) {
              Text(item.comment).fontSize(11).maxLines(2).fontColor(THEME_TEXT_SECONDARY)
            }
            Text(item.createdAt).fontSize(10).fontColor(THEME_TEXT_TERTIARY)
          }
          .alignItems(HorizontalAlign.Start)
          .padding(8)
          .width('100%')
          .backgroundColor(THEME_SURFACE)
          .borderRadius(RADIUS_MD)
          .shadow(SHADOW_CARD)
        }, (item: ComplaintTimelineItem) => `${item.id}`)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding(12)
    .backgroundColor(THEME_SURFACE_MUTED)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private VisitorCreatePanel(): void {
    FloatingCard() {
      Column({ space: 10 }) {
        SectionHeader({ title: '提交投诉', subtitle: '支持文字描述与流程留痕' })

        TextInput({ placeholder: '投诉标题', text: this.titleInput })
          .onChange((value: string) => {
            this.titleInput = value
          })
          .backgroundColor('#F8FAFF')
          .borderRadius(RADIUS_MD)
          .padding(10)

        TextArea({ placeholder: '请简要描述问题发生的时间、地点与经过', text: this.contentInput })
          .onChange((value: string) => {
            this.contentInput = value
          })
          .backgroundColor('#F8FAFF')
          .borderRadius(RADIUS_MD)
          .height(96)
          .padding(10)

        Button(this.loading ? '提交中...' : '提交投诉')
          .enabled(!this.loading)
          .onClick(() => this.submitComplaint())
          .width('100%')
          .height(44)
          .borderRadius(RADIUS_PILL)
          .backgroundColor(this.loading ? '#B8CCE8' : THEME_PRIMARY)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .shadow(SHADOW_CARD)

        if (this.actionMessage.length > 0) {
          Text(this.actionMessage)
            .fontColor(THEME_SUCCESS)
            .fontSize(12)
        }
        if (this.errorMessage.length > 0) {
          Text(this.errorMessage)
            .fontColor(THEME_DANGER)
            .fontSize(12)
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  private VisitorProgressPanel(): void {
    FloatingCard() {
      Column({ space: 10 }) {
        Row() {
          SectionHeader({ title: '投诉进度', subtitle: '全流程状态闭环跟踪' })
          Blank()
          if (this.hasLatestComplaint()) {
            StatusBadge({ label: this.latestComplaintStatusLabel(), tone: 'primary' })
          }
        }
        .width('100%')

        TimelineNode({
          title: '已提交',
          detail: '投诉已进入系统',
          active: this.visitorProgressStep() === 1,
          completed: this.visitorProgressStep() > 1
        })
        TimelineNode({
          title: '审批中',
          detail: '等待审批员处理',
          active: this.visitorProgressStep() === 2,
          completed: this.visitorProgressStep() > 2
        })
        TimelineNode({
          title: '处理中',
          detail: '处理人正在跟进',
          active: this.visitorProgressStep() === 3,
          completed: this.visitorProgressStep() > 3
        })
        TimelineNode({
          title: '已结案',
          detail: '流程已闭环',
          active: this.visitorProgressStep() === 4,
          completed: this.visitorProgressStep() >= 4
        })

        Row({ space: 8 }) {
          TextInput({ placeholder: '满意度（1-5）', text: this.ratingInput })
            .onChange((value: string) => {
              this.ratingInput = value
            })
            .layoutWeight(1)
            .backgroundColor('#F8FAFF')
            .borderRadius(RADIUS_MD)
            .padding(10)
          Button('提交评价')
            .onClick(() => this.rateComplaint())
            .height(40)
            .borderRadius(RADIUS_PILL)
            .backgroundColor(THEME_PRIMARY)
            .fontColor(Color.White)
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  private VisitorHistoryPanel(): void {
    FloatingCard() {
      Column({ space: 10 }) {
        SectionHeader({ title: '历史投诉', subtitle: '按时间倒序展示最近记录' })
        if (this.loading) {
          EmptyStateCard({ message: '投诉记录加载中...' })
        } else if (this.items.length === 0) {
          EmptyStateCard({ message: '你还没有提交过投诉记录。' })
        } else {
          ForEach(this.items, (item: ComplaintItem) => {
            Column({ space: 6 }) {
              Row() {
                Text(item.title)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(THEME_TEXT_PRIMARY)
                  .layoutWeight(1)
                StatusBadge({ label: this.statusLabel(item.status), tone: 'primary' })
              }
              .width('100%')
              Text(item.content)
                .fontSize(12)
                .fontColor(THEME_TEXT_SECONDARY)
                .maxLines(2)
              Text(`更新时间：${item.updatedAt}`)
                .fontSize(10)
                .fontColor(THEME_TEXT_TERTIARY)
            }
            .width('100%')
            .padding(10)
            .backgroundColor(this.selectedId === item.id ? '#EEF4FF' : '#F8FAFF')
            .borderRadius(RADIUS_MD)
            .onClick(() => this.selectComplaint(item.id))
          }, (item: ComplaintItem) => `${item.id}`)
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  private VisitorView(): void {
    Scroll() {
      Column({ space: 12 }) {
        this.VisitorCreatePanel()
        this.VisitorProgressPanel()
        this.VisitorHistoryPanel()
      }
      .padding({ left: 12, right: 12, top: 12, bottom: 96 })
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .height('100%')
    .backgroundColor(THEME_PAGE_BG)
  }

  @Builder
  private HandlerHeader(): void {
    Row() {
      Row({ space: 12 }) {
        Text('单')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_PRIMARY)
          .textAlign(TextAlign.Center)
          .width(42)
          .height(42)
          .backgroundColor(THEME_PRIMARY_SOFT)
          .borderRadius(RADIUS_PILL)
        Column({ space: 3 }) {
          Text('工单处理中心')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(THEME_TEXT_PRIMARY)
          Text('多场景综合处理平台')
            .fontSize(12)
            .fontColor(THEME_TEXT_TERTIARY)
        }
        .alignItems(HorizontalAlign.Start)
      }
      Blank()
      Text('处理端')
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
  private HandlerTabSwitch(): void {
    Row({ space: 8 }) {
      this.HandlerTabButton('pending', `待处理（${this.handlerPendingItems().length}）`)
      this.HandlerTabButton('confirming', `待确认（${this.handlerConfirmingItems().length}）`)
      this.HandlerTabButton('closed', '已结案')
    }
    .padding(6)
    .backgroundColor(THEME_SURFACE_MUTED)
    .borderRadius(RADIUS_PILL)
  }

  @Builder
  private HandlerTabButton(tab: HandlerTab, label: string): void {
    Button(label)
      .layoutWeight(1)
      .height(44)
      .borderRadius(RADIUS_PILL)
      .backgroundColor(this.handlerTab === tab ? THEME_SURFACE : THEME_SURFACE_MUTED)
      .fontColor(this.handlerTab === tab ? THEME_PRIMARY : THEME_TEXT_SECONDARY)
      .fontWeight(this.handlerTab === tab ? FontWeight.Bold : FontWeight.Medium)
      .onClick(() => this.switchHandlerTab(tab))
  }

  @Builder
  private HandlerWorkList(): void {
    if (this.loading) {
      EmptyStateCard({ message: '工单加载中...' })
    } else if (this.errorMessage.length > 0) {
      Column({ space: 10 }) {
        Text(this.errorMessage)
          .fontSize(13)
          .fontColor(THEME_DANGER)
        Button('重试')
          .height(40)
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_PRIMARY)
          .fontColor(Color.White)
          .onClick(() => this.loadComplaints())
      }
      .width('100%')
      .padding(20)
      .backgroundColor(THEME_SURFACE)
      .borderRadius(RADIUS_LG)
      .shadow(SHADOW_CARD)
    } else if (this.handlerVisibleItems().length === 0) {
      EmptyStateCard({ message: this.handlerTab === 'pending' ? '暂无待处理工单' : '当前分组暂无工单' })
    } else {
      ForEach(this.handlerVisibleItems(), (item: ComplaintItem) => {
        this.HandlerWorkCard(item)
      }, (item: ComplaintItem) => `${item.id}`)
    }
  }

  @Builder
  private HandlerWorkCard(item: ComplaintItem): void {
    Column({ space: 14 }) {
      Row() {
        Text(this.handlerTypeLabel(item))
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.handlerTypeColor(item))
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor(this.handlerTypeBg(item))
          .borderRadius(RADIUS_MD)
        Text(this.handlerUrgencyLabel(item))
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.handlerUrgencyColor(item))
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor(this.handlerUrgencyBg(item))
          .borderRadius(RADIUS_MD)
          .margin({ left: 8 })
        Blank()
        Text(this.handlerTimeLabel(item))
          .fontSize(12)
          .fontColor(THEME_TEXT_TERTIARY)
      }
      .width('100%')

      Text(item.title)
        .fontSize(19)
        .fontWeight(FontWeight.Bold)
        .fontColor(THEME_TEXT_PRIMARY)
        .maxLines(2)
        .width('100%')

      Column({ space: 10 }) {
        Row({ space: 8 }) {
          Text('位')
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor(THEME_PRIMARY)
          Text(this.handlerLocationText(item))
            .fontSize(14)
            .fontColor(THEME_TEXT_SECONDARY)
            .maxLines(1)
        }
        .width('100%')
        Row() {
          Text(`游客：${item.createdBy}`)
            .fontSize(13)
            .fontColor(THEME_TEXT_SECONDARY)
          Blank()
          Button('打电话')
            .height(30)
            .borderRadius(RADIUS_PILL)
            .backgroundColor(THEME_PRIMARY_SOFT)
            .fontColor(THEME_PRIMARY)
            .onClick(() => this.recordPhoneCall(item))
        }
        .width('100%')
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#F8FAFF')
      .borderRadius(RADIUS_MD)

      if (this.handlerTab === 'pending') {
        Button('开始处理此投诉')
          .width('100%')
          .height(48)
          .borderRadius(RADIUS_MD)
          .backgroundColor(THEME_PRIMARY_SOFT)
          .fontColor(THEME_PRIMARY)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .onClick(() => this.openHandlerForm(item))
      } else if (this.handlerTab === 'confirming') {
        Text('处理结果已提交，等待游客确认或管理员结案。')
          .fontSize(13)
          .fontColor(THEME_WARNING)
          .padding({ left: 12, right: 12, top: 10, bottom: 10 })
          .backgroundColor('#FFF4E6')
          .borderRadius(RADIUS_MD)
      } else {
        StatusBadge({ label: this.statusLabel(item.status), tone: 'success' })
      }
    }
    .width('100%')
    .padding(18)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private HandlerProcessForm(): void {
    Column({ space: 14 }) {
      Row() {
        Text('处理工单')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
        Blank()
        Button('返回')
          .height(34)
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_SURFACE_MUTED)
          .fontColor(THEME_TEXT_SECONDARY)
          .onClick(() => this.closeHandlerForm())
      }
      .width('100%')

      Column({ space: 8 }) {
        Row({ space: 8 }) {
          Text(this.selectedComplaintTypeLabel())
            .fontSize(12)
            .fontColor(this.selectedComplaintTypeColor())
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .backgroundColor(this.selectedComplaintTypeBg())
            .borderRadius(RADIUS_MD)
          Text('原投诉内容')
            .fontSize(12)
            .fontColor(THEME_TEXT_TERTIARY)
        }
        Text(this.selectedComplaintTitle())
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
        Text(this.selectedComplaintContent())
          .fontSize(13)
          .lineHeight(20)
          .fontColor(THEME_TEXT_SECONDARY)
          .maxLines(4)
        Text(`发生地点：${this.selectedComplaintLocation()}`)
          .fontSize(13)
          .fontColor(THEME_PRIMARY)
          .padding({ left: 10, right: 10, top: 7, bottom: 7 })
          .backgroundColor(THEME_PRIMARY_SOFT)
          .borderRadius(RADIUS_MD)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding(14)
      .backgroundColor('#F8FAFF')
      .borderRadius(RADIUS_MD)

      Row({ space: 8 }) {
        Button('致歉沟通')
          .layoutWeight(1)
          .height(36)
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_SURFACE_MUTED)
          .fontColor(THEME_TEXT_SECONDARY)
          .onClick(() => this.applyHandlerPlan('已与游客沟通并致歉，说明原因并给出后续跟进方案。'))
        Button('协调退赔')
          .layoutWeight(1)
          .height(36)
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_SURFACE_MUTED)
          .fontColor(THEME_TEXT_SECONDARY)
          .onClick(() => this.applyHandlerPlan('已协调相关部门核实费用争议，拟按规则退赔或补偿。'))
        Button('安排整改')
          .layoutWeight(1)
          .height(36)
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_SURFACE_MUTED)
          .fontColor(THEME_TEXT_SECONDARY)
          .onClick(() => this.applyHandlerPlan('已安排责任部门整改，并记录复查时间。'))
      }
      .width('100%')

      TextArea({ placeholder: '请输入处理意见、沟通结果、退赔方案或整改说明', text: this.commentInput })
        .onChange((value: string) => {
          this.commentInput = value
        })
        .width('100%')
        .height(132)
        .backgroundColor(THEME_SURFACE_MUTED)
        .borderRadius(RADIUS_MD)
        .padding(12)

      Button('补充凭证（图片/视频/录音）')
        .width('100%')
        .height(48)
        .borderRadius(RADIUS_MD)
        .backgroundColor(THEME_SURFACE_MUTED)
        .fontColor(THEME_PRIMARY)
        .fontWeight(FontWeight.Medium)

      Button('提交处理结果，等待游客确认')
        .width('100%')
        .height(52)
        .borderRadius(RADIUS_MD)
        .backgroundColor(THEME_PRIMARY)
        .fontColor(Color.White)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .onClick(() => this.processComplaint())

      if (this.actionMessage.length > 0) {
        Text(this.actionMessage)
          .fontSize(12)
          .fontColor(this.actionMessage.indexOf('请先') >= 0 ? THEME_DANGER : THEME_SUCCESS)
      }
      if (this.errorMessage.length > 0) {
        Text(this.errorMessage)
          .fontSize(12)
          .fontColor(THEME_DANGER)
      }
    }
    .width('100%')
    .padding(18)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private AdminHeader(): void {
    Row() {
      Column({ space: 3 }) {
        Text('投诉审批与结案')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
        Text('管理端 / 工单中枢')
          .fontSize(12)
          .fontColor(THEME_TEXT_TERTIARY)
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      Text('管理端')
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
  private AdminWorkflowTabs(): void {
    Row({ space: 8 }) {
      this.AdminWorkflowTabButton('dispatch', '待审批派单')
      this.AdminWorkflowTabButton('processing', '处理确认中')
      this.AdminWorkflowTabButton('closing', '待审核结案')
      this.AdminWorkflowTabButton('archived', '已归档')
    }
    .padding(6)
    .backgroundColor(THEME_SURFACE_MUTED)
    .borderRadius(RADIUS_PILL)
  }

  @Builder
  private AdminWorkflowTabButton(tab: AdminWorkflowTab, label: string): void {
    Button(label)
      .layoutWeight(1)
      .height(42)
      .borderRadius(RADIUS_PILL)
      .backgroundColor(this.adminWorkflowTab === tab ? THEME_SURFACE : THEME_SURFACE_MUTED)
      .fontColor(this.adminWorkflowTab === tab ? THEME_PRIMARY : THEME_TEXT_SECONDARY)
      .fontWeight(this.adminWorkflowTab === tab ? FontWeight.Bold : FontWeight.Medium)
      .fontSize(11)
      .onClick(() => this.switchAdminWorkflowTab(tab))
  }

  @Builder
  private AdminWorkflowList(): void {
    if (this.loading) {
      EmptyStateCard({ message: '投诉工单加载中...' })
    } else if (this.errorMessage.length > 0) {
      Column({ space: 10 }) {
        Text(this.errorMessage)
          .fontSize(13)
          .fontColor(THEME_DANGER)
        Button('重试')
          .height(40)
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_PRIMARY)
          .fontColor(Color.White)
          .onClick(() => this.loadComplaints())
      }
      .width('100%')
      .padding(20)
      .backgroundColor(THEME_SURFACE)
      .borderRadius(RADIUS_LG)
      .shadow(SHADOW_CARD)
    } else if (this.adminVisibleItems().length === 0) {
      EmptyStateCard({ message: '当前分组暂无投诉工单' })
    } else {
      ForEach(this.adminVisibleItems(), (item: ComplaintItem) => {
        this.AdminWorkflowCard(item)
      }, (item: ComplaintItem) => `${item.id}`)
    }
  }

  @Builder
  private AdminWorkflowCard(item: ComplaintItem): void {
    Column({ space: 14 }) {
      Row() {
        Row({ space: 8 }) {
          Text(`编号 ${this.complaintCode(item)}`)
            .fontSize(12)
            .fontColor(THEME_TEXT_TERTIARY)
          Text(this.handlerUrgencyLabel(item))
            .fontSize(11)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.handlerUrgencyColor(item))
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(this.handlerUrgencyBg(item))
            .borderRadius(RADIUS_MD)
        }
        Blank()
        Text(this.adminCardTimeLabel(item))
          .fontSize(12)
          .fontColor(THEME_TEXT_TERTIARY)
      }
      .width('100%')

      Text(item.title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(THEME_TEXT_PRIMARY)
        .width('100%')
        .maxLines(2)

      Row({ space: 8 }) {
        Text('位')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_PRIMARY)
        Text(this.handlerLocationText(item))
          .fontSize(14)
          .fontColor(THEME_TEXT_SECONDARY)
          .maxLines(1)
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#F8FAFF')
      .borderRadius(RADIUS_MD)

      Row() {
        Text(`游客：${item.createdBy}`)
          .fontSize(13)
          .fontColor(THEME_TEXT_SECONDARY)
        Blank()
        if (this.adminWorkflowTab === 'dispatch') {
          Button('去审批派单')
            .height(34)
            .borderRadius(RADIUS_PILL)
            .backgroundColor(THEME_PRIMARY_SOFT)
            .fontColor(THEME_PRIMARY)
            .fontWeight(FontWeight.Bold)
            .onClick(() => this.openAdminApprovalDetail(item))
        } else if (this.adminWorkflowTab === 'processing') {
          Text(this.adminProcessingSummary(item))
            .fontSize(13)
            .fontColor('#F97316')
            .fontWeight(FontWeight.Medium)
        } else if (this.adminWorkflowTab === 'closing') {
          Button('审阅并结案')
            .height(34)
            .borderRadius(RADIUS_PILL)
            .backgroundColor('#EAF8EF')
            .fontColor(THEME_SUCCESS)
            .fontWeight(FontWeight.Bold)
            .onClick(() => this.closeFromAdmin(item))
        } else {
          Text(this.adminArchiveSummary(item))
            .fontSize(13)
            .fontColor(THEME_TEXT_TERTIARY)
        }
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
  private AdminComplaintContentCard(): void {
    Column({ space: 12 }) {
      Row() {
        Text('游客诉求内容')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
        Blank()
        Text(this.selectedComplaintTypeLabel())
          .fontSize(12)
          .fontColor(this.selectedComplaintTypeColor())
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor(this.selectedComplaintTypeBg())
          .borderRadius(RADIUS_MD)
      }
      .width('100%')

      Row() {
        Text(`游客：${this.selectedComplaintCreator()}`)
          .fontSize(13)
          .fontColor(THEME_TEXT_SECONDARY)
        Blank()
        Text(this.selectedComplaintCode())
          .fontSize(12)
          .fontColor(THEME_TEXT_TERTIARY)
      }
      .width('100%')

      Text(this.selectedComplaintContent())
        .fontSize(15)
        .lineHeight(24)
        .fontColor(THEME_TEXT_PRIMARY)
        .padding(14)
        .width('100%')
        .backgroundColor('#F8FAFF')
        .borderRadius(RADIUS_MD)

      Column({ space: 8 }) {
        Text('游客凭证')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(THEME_TEXT_PRIMARY)
        Column({ space: 6 }) {
          Text('现场附件占位区')
            .fontSize(13)
            .fontColor(THEME_TEXT_SECONDARY)
          Text('本轮先展示为证据留痕卡片，后续接真实图片/视频。')
            .fontSize(12)
            .fontColor(THEME_TEXT_TERTIARY)
        }
        .width('100%')
        .height(112)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#F8FAFF')
        .borderRadius(RADIUS_MD)
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
  private AdminDispatchPanel(): void {
    Column({ space: 12 }) {
      Text('审批并派发工单')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(THEME_TEXT_PRIMARY)
      Text('经审核投诉有效，请指派具体责任部门 / 人员进行现场或业务处置。')
        .fontSize(13)
        .lineHeight(20)
        .fontColor(THEME_TEXT_SECONDARY)

      TextArea({ placeholder: '审批意见（可选）', text: this.commentInput })
        .onChange((value: string) => {
          this.commentInput = value
        })
        .width('100%')
        .height(96)
        .backgroundColor('#F8FAFF')
        .borderRadius(RADIUS_MD)
        .padding(12)

      ForEach(this.adminAssigneeOptions, (item: AdminAssigneeOption) => {
        Row({ space: 12 }) {
          Column({ space: 4 }) {
            Text(item.title)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(THEME_TEXT_PRIMARY)
            Text(item.subtitle)
              .fontSize(12)
              .fontColor(THEME_TEXT_TERTIARY)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          Text(this.isAdminAssigneeSelected(item.username) ? '已选' : '选择')
            .fontSize(12)
            .fontColor(this.isAdminAssigneeSelected(item.username) ? THEME_PRIMARY : THEME_TEXT_TERTIARY)
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .backgroundColor(this.isAdminAssigneeSelected(item.username) ? THEME_PRIMARY_SOFT : THEME_SURFACE_MUTED)
            .borderRadius(RADIUS_PILL)
        }
        .width('100%')
        .padding(14)
        .backgroundColor(this.isAdminAssigneeSelected(item.username) ? '#EEF4FF' : '#F8FAFF')
        .borderRadius(RADIUS_MD)
        .border({
          width: this.isAdminAssigneeSelected(item.username) ? 1 : 0,
          color: this.isAdminAssigneeSelected(item.username) ? THEME_PRIMARY : 'transparent'
        })
        .onClick(() => this.selectAdminAssignee(item.username))
      }, (item: AdminAssigneeOption) => item.username)

      Button(this.loading ? '审批派单中...' : '确认审批并派发工单')
        .enabled(!this.loading)
        .width('100%')
        .height(52)
        .borderRadius(RADIUS_PILL)
        .backgroundColor(this.loading ? '#B8CCE8' : THEME_PRIMARY)
        .fontColor(Color.White)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .onClick(() => this.approveAndAssignComplaint())

      Button('驳回此投诉')
        .width('100%')
        .height(46)
        .borderRadius(RADIUS_PILL)
        .backgroundColor('#FFECEC')
        .fontColor(THEME_DANGER)
        .fontWeight(FontWeight.Bold)
        .onClick(() => this.rejectFromAdmin())

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
    }
    .width('100%')
    .padding(18)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private AdminApprovalDetailView(): void {
    Scroll() {
      Column({ space: 16 }) {
        Row() {
          Button('返回列表')
            .height(34)
            .borderRadius(RADIUS_PILL)
            .backgroundColor(THEME_SURFACE)
            .fontColor(THEME_TEXT_SECONDARY)
            .onClick(() => this.closeAdminApprovalDetail())
          Blank()
          Text('审批工单详情')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(THEME_TEXT_PRIMARY)
        }
        .width('100%')

        this.AdminComplaintContentCard()
        this.AdminDispatchPanel()
      }
      .width('100%')
      .padding({ left: 2, right: 2, top: 2, bottom: 16 })
      .alignItems(HorizontalAlign.Start)
    }
    .layoutWeight(1)
    .width('100%')
    .scrollBar(BarState.Off)
  }

  @Builder
  private AdminView(): void {
    Column({ space: 18 }) {
      this.AdminWorkflowTabs()

      if (this.adminApprovalVisible) {
        this.AdminApprovalDetailView()
      } else {
        Scroll() {
          Column({ space: 14 }) {
            this.AdminWorkflowList()
          }
          .width('100%')
          .padding({ left: 2, right: 2, top: 2, bottom: 16 })
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 28 })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .backgroundColor(THEME_PAGE_BG)
  }

  @Builder
  private HandlerView(): void {
    Column({ space: 18 }) {
      this.HandlerHeader()

      if (this.handlerFormVisible) {
        Scroll() {
          this.HandlerProcessForm()
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)
      } else {
        this.HandlerTabSwitch()
        Column() {
          this.HandlerWorkList()
        }
        .layoutWeight(1)
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 28 })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .backgroundColor(THEME_PAGE_BG)
  }

  build() {
    if (this.isVisitorMode()) {
      this.VisitorView()
    } else if (this.mode === 'handler') {
      this.HandlerView()
    } else if (this.mode === 'admin') {
      this.AdminView()
    } else {
      Scroll() {
        Column({ space: 10 }) {
          this.ActionPanel()
          this.FilterPanel()
          this.ComplaintListPanel()
          this.TimelinePanel()
        }
        .padding(12)
        .width('100%')
      }
      .height('100%')
      .backgroundColor(THEME_PAGE_BG)
    }
  }
}
