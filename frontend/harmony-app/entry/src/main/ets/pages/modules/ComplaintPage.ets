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

  @Builder
  private FilterPanel(): void {
    Column({ space: 8 }) {
      Text('筛选条件').fontSize(16).fontWeight(FontWeight.Medium)

      Row({ space: 8 }) {
        TextInput({ placeholder: '状态（如 SUBMITTED）', text: this.filters.status })
          .onChange((value: string) => {
            this.updateFilter('status', value)
          })
          .layoutWeight(1)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding(8)
        TextInput({ placeholder: '关键词（标题/内容）', text: this.filters.keyword })
          .onChange((value: string) => {
            this.updateFilter('keyword', value)
          })
          .layoutWeight(1)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding(8)
      }

      Row({ space: 8 }) {
        TextInput({ placeholder: '开始时间（ISO）', text: this.filters.from })
          .onChange((value: string) => {
            this.updateFilter('from', value)
          })
          .layoutWeight(1)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding(8)
        TextInput({ placeholder: '结束时间（ISO）', text: this.filters.to })
          .onChange((value: string) => {
            this.updateFilter('to', value)
          })
          .layoutWeight(1)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding(8)
      }

      if (this.showAdvancedFilters()) {
        Row({ space: 8 }) {
          TextInput({ placeholder: '提交人账号', text: this.filters.createdBy })
            .onChange((value: string) => {
              this.updateFilter('createdBy', value)
            })
            .layoutWeight(1)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .padding(8)
          TextInput({ placeholder: '处理人账号', text: this.filters.assignee })
            .onChange((value: string) => {
              this.updateFilter('assignee', value)
            })
            .layoutWeight(1)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .padding(8)
        }
      }

      Row({ space: 8 }) {
        Button('应用筛选').onClick(() => this.loadComplaints()).layoutWeight(1)
        Button('重置筛选').onClick(() => this.resetFilters()).layoutWeight(1)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding(12)
    .backgroundColor('#F3F4F6')
    .borderRadius(12)
  }

  @Builder
  private ActionPanel(): void {
    Column({ space: 8 }) {
      Text(this.modeTitle()).fontSize(20).fontWeight(FontWeight.Medium)

      if (this.isVisitorMode()) {
        TextInput({ placeholder: '投诉标题', text: this.titleInput })
          .onChange((value: string) => {
            this.titleInput = value
          })
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding(10)

        TextArea({ placeholder: '投诉内容', text: this.contentInput })
          .onChange((value: string) => {
            this.contentInput = value
          })
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .height(90)
          .padding(10)

        TextInput({ placeholder: '附件链接（可选）', text: this.attachmentInput })
          .onChange((value: string) => {
            this.attachmentInput = value
          })
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding(10)

        Button('提交投诉').onClick(() => this.submitComplaint())
      }

      if (this.isApproverMode() || this.isHandlerMode()) {
        TextInput({ placeholder: '处理意见', text: this.commentInput })
          .onChange((value: string) => {
            this.commentInput = value
          })
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding(10)
      }

      if (this.isApproverMode()) {
        TextInput({ placeholder: '分派处理人账号', text: this.assigneeInput })
          .onChange((value: string) => {
            this.assigneeInput = value
          })
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding(10)

        Row({ space: 8 }) {
          Button('审批通过').onClick(() => this.approveComplaint()).layoutWeight(1)
          Button('驳回').onClick(() => this.rejectComplaint()).layoutWeight(1)
          Button('分派').onClick(() => this.assignComplaint()).layoutWeight(1)
        }
      }

      if (this.isHandlerMode()) {
        Row({ space: 8 }) {
          Button('提交处理').onClick(() => this.processComplaint()).layoutWeight(1)
          Button('结案').onClick(() => this.closeComplaint()).layoutWeight(1)
        }
      }

      if (this.isVisitorMode()) {
        TextInput({ placeholder: '满意度（1-5）', text: this.ratingInput })
          .onChange((value: string) => {
            this.ratingInput = value
          })
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding(10)

        Button('提交评价').onClick(() => this.rateComplaint())
      }

      if (this.actionMessage.length > 0) {
        Text(this.actionMessage).fontColor('#059669').fontSize(12)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding(12)
    .backgroundColor('#F3F4F6')
    .borderRadius(12)
  }

  @Builder
  private ComplaintListPanel(): void {
    if (this.loading) {
      Column() {
        Text('加载中...').fontColor('#6B7280')
      }
      .width('100%')
      .padding(20)
      .alignItems(HorizontalAlign.Center)
    } else if (this.errorMessage.length > 0) {
      Column({ space: 8 }) {
        Text(this.errorMessage).fontColor(Color.Red).fontSize(12)
        Button('重试').onClick(() => this.loadComplaints())
      }
      .width('100%')
      .padding(20)
      .alignItems(HorizontalAlign.Center)
    } else if (this.items.length === 0) {
      Column() {
        Text('暂无投诉记录').fontColor('#6B7280')
      }
      .width('100%')
      .padding(20)
      .alignItems(HorizontalAlign.Center)
    } else {
      List({ space: 8 }) {
        ForEach(this.items, (item: ComplaintItem) => {
          ListItem() {
            Column({ space: 4 }) {
              Row() {
                Text(item.title).fontSize(15).fontWeight(FontWeight.Medium)
                Blank()
                Text(this.statusLabel(item.status)).fontSize(12).fontColor('#2563EB')
              }
              Text(item.content).fontSize(12).maxLines(2)
              Text(`提交人：${item.createdBy}`).fontSize(11).fontColor('#6B7280')
              Text(`处理人：${item.assignee ?? '-'}`).fontSize(11).fontColor('#6B7280')
              if (item.rejectionComment !== null && item.rejectionComment.length > 0) {
                Text(`驳回原因：${item.rejectionComment}`).fontSize(11).fontColor('#B91C1C').maxLines(2)
              }
              Text(`更新时间：${item.updatedAt}`).fontSize(10).fontColor('#9CA3AF')
            }
            .alignItems(HorizontalAlign.Start)
            .padding(10)
            .backgroundColor(this.selectedId === item.id ? '#DBEAFE' : '#FFFFFF')
            .borderRadius(10)
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
      Text('投诉时间线').fontSize(16).fontWeight(FontWeight.Medium)
      if (this.timelineLoading) {
        Text('时间线加载中...').fontSize(12).fontColor('#6B7280')
      } else if (this.timelines.length === 0) {
        Text('暂无时间线记录').fontSize(12).fontColor('#6B7280')
      } else {
        ForEach(this.timelines, (item: ComplaintTimelineItem) => {
          Column({ space: 2 }) {
            Text(`${this.actionLabel(item.action)} · ${item.actor ?? '-'}`).fontSize(12).fontWeight(FontWeight.Medium)
            if (item.comment !== null && item.comment.length > 0) {
              Text(item.comment).fontSize(11).maxLines(2)
            }
            Text(item.createdAt).fontSize(10).fontColor('#9CA3AF')
          }
          .alignItems(HorizontalAlign.Start)
          .padding(8)
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
        }, (item: ComplaintTimelineItem) => `${item.id}`)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding(12)
    .backgroundColor('#F3F4F6')
    .borderRadius(12)
  }

  build() {
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
    .backgroundColor('#F9FAFB')
  }
}
