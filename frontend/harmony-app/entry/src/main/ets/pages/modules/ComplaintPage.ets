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
  THEME_DANGER,
  THEME_PAGE_BG,
  THEME_PRIMARY,
  THEME_PRIMARY_SOFT,
  THEME_SUCCESS,
  THEME_SURFACE,
  THEME_SURFACE_MUTED,
  THEME_TEXT_PRIMARY,
  THEME_TEXT_SECONDARY,
  THEME_TEXT_TERTIARY
} from '../../common/ui/AppTheme'
import { EmptyStateCard, FloatingCard, PrimaryActionButton, SectionHeader, StatusBadge, TimelineNode } from '../../common/ui/UiKit'

export type ComplaintMode = 'visitor' | 'approver' | 'handler' | 'admin'

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
  @State private attachmentInput: string = ''

  @State private selectedId: number = 0
  @State private commentInput: string = ''
  @State private assigneeInput: string = ''
  @State private ratingInput: string = '5'

  @State private filters: ComplaintQueryFilter = {
    status: '',
    createdBy: '',
    assignee: '',
    keyword: '',
    from: '',
    to: ''
  }

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
        content: this.contentInput,
        attachmentUrls: this.attachmentInput
      }
      await apiClient.post<ComplaintCreateRequest, ComplaintItem>('/api/complaints', payload)
      this.titleInput = ''
      this.contentInput = ''
      this.attachmentInput = ''
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
    const payload: ComplaintActionRequest = {
      comment: this.commentInput.trim().length > 0 ? this.commentInput : '已处理投诉'
    }
    await this.runAction(`/api/complaints/admin/${this.selectedId}/process`, payload, '已提交处理结果')
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

  private statusTone(status: string): { icon: string; color: string; background: string } {
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

        TextInput({ placeholder: '附件链接（可选）', text: this.attachmentInput })
          .onChange((value: string) => {
            this.attachmentInput = value
          })
          .backgroundColor(THEME_SURFACE)
          .borderRadius(RADIUS_MD)
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
        SectionHeader({ title: '提交投诉', subtitle: '支持文字描述与附件留痕' })

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

        Row({ space: 8 }) {
          Text('上传证据（图片/视频）')
            .fontSize(12)
            .fontColor(THEME_TEXT_SECONDARY)
          Blank()
          Text('可选')
            .fontSize(11)
            .fontColor(THEME_TEXT_TERTIARY)
        }
        .width('100%')

        Row({ space: 10 }) {
          Column({ space: 6 }) {
            Text('+')
              .fontSize(26)
              .fontWeight(FontWeight.Medium)
              .fontColor(THEME_PRIMARY)
            Text('添加附件')
              .fontSize(11)
              .fontColor(THEME_TEXT_SECONDARY)
          }
          .width(88)
          .height(88)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .backgroundColor('#F0F5FF')
          .borderRadius(RADIUS_MD)
          .border({ width: 1, color: '#CAD9F7' })

          TextInput({ placeholder: '附件链接（可选）', text: this.attachmentInput })
            .onChange((value: string) => {
              this.attachmentInput = value
            })
            .layoutWeight(1)
            .backgroundColor('#F8FAFF')
            .borderRadius(RADIUS_MD)
            .padding(10)
        }
        .width('100%')

        PrimaryActionButton({
          label: this.loading ? '提交中...' : '提交投诉',
          disabled: this.loading,
          onPress: () => this.submitComplaint()
        })

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
    const latest: ComplaintItem | null = this.latestComplaint()
    const step: number = latest === null ? 1 : this.complaintStepIndex(latest.status)
    FloatingCard() {
      Column({ space: 10 }) {
        Row() {
          SectionHeader({ title: '投诉进度', subtitle: '全流程状态闭环跟踪' })
          Blank()
          if (latest !== null) {
            StatusBadge({ label: this.statusLabel(latest.status), tone: 'primary' })
          }
        }
        .width('100%')

        TimelineNode({ title: '已提交', detail: '投诉已进入系统', active: step === 1, completed: step > 1 })
        TimelineNode({ title: '审批中', detail: '等待审批员处理', active: step === 2, completed: step > 2 })
        TimelineNode({ title: '处理中', detail: '处理人正在跟进', active: step === 3, completed: step > 3 })
        TimelineNode({ title: '已结案', detail: '流程已闭环', active: step === 4, completed: step >= 4 })

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

  build() {
    if (this.isVisitorMode()) {
      this.VisitorView()
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
