import {
  ComplaintActionRequest,
  ComplaintCreateRequest,
  ComplaintItem,
  ComplaintRatingRequest
} from '../../common/model/ApiModels'
import { apiClient } from '../../common/network/ApiClient'

export type ComplaintMode = 'visitor' | 'approver' | 'handler' | 'admin'

@Component
export struct ComplaintPage {
  @Prop mode: ComplaintMode = 'visitor'

  @State private items: ComplaintItem[] = []
  @State private loading: boolean = false
  @State private errorMessage: string = ''
  @State private actionMessage: string = ''

  @State private titleInput: string = ''
  @State private contentInput: string = ''
  @State private attachmentInput: string = ''

  @State private selectedId: number = 0
  @State private commentInput: string = ''
  @State private ratingInput: string = '5'

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

  private refreshSelection(): void {
    if (this.items.length === 0) {
      this.selectedId = 0
      return
    }
    const exists: boolean = this.items.some((item: ComplaintItem) => item.id === this.selectedId)
    if (!exists) {
      this.selectedId = this.items[0].id
    }
  }

  private async loadComplaints(): Promise<void> {
    this.loading = true
    this.errorMessage = ''
    try {
      const list: ComplaintItem[] = await apiClient.get<ComplaintItem[]>('/api/complaints')
      this.items = [...list]
      this.refreshSelection()
    } catch (_error) {
      this.errorMessage = '加载投诉列表失败，请稍后重试'
    } finally {
      this.loading = false
    }
  }

  private async submitComplaint(): Promise<void> {
    if (this.titleInput.trim().length === 0 || this.contentInput.trim().length === 0) {
      this.actionMessage = '请填写投诉标题与内容'
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
      this.errorMessage = '提交投诉失败，请稍后重试'
    } finally {
      this.loading = false
    }
  }

  private async approveComplaint(): Promise<void> {
    if (this.selectedId <= 0) {
      this.actionMessage = '请先选择一条投诉'
      return
    }
    const payload: ComplaintActionRequest = { comment: this.commentInput.trim().length > 0 ? this.commentInput : '审批通过' }
    await this.runAdminAction(`/api/complaints/admin/${this.selectedId}/approve`, payload, '已完成审批')
  }

  private async processComplaint(): Promise<void> {
    if (this.selectedId <= 0) {
      this.actionMessage = '请先选择一条投诉'
      return
    }
    const payload: ComplaintActionRequest = { comment: this.commentInput.trim().length > 0 ? this.commentInput : '已处理并反馈结果' }
    await this.runAdminAction(`/api/complaints/admin/${this.selectedId}/process`, payload, '已提交处理结果')
  }

  private async closeComplaint(): Promise<void> {
    if (this.selectedId <= 0) {
      this.actionMessage = '请先选择一条投诉'
      return
    }
    const payload: ComplaintActionRequest = { comment: this.commentInput.trim().length > 0 ? this.commentInput : '问题关闭' }
    await this.runAdminAction(`/api/complaints/admin/${this.selectedId}/close`, payload, '已结案')
  }

  private async rateComplaint(): Promise<void> {
    if (this.selectedId <= 0) {
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
      this.errorMessage = '提交评价失败，需在结案后评价'
    } finally {
      this.loading = false
    }
  }

  private async runAdminAction(path: string, payload: ComplaintActionRequest, successMessage: string): Promise<void> {
    this.loading = true
    this.errorMessage = ''
    this.actionMessage = ''
    try {
      await apiClient.post<ComplaintActionRequest, ComplaintItem>(path, payload)
      this.commentInput = ''
      this.actionMessage = successMessage
      await this.loadComplaints()
    } catch (_error) {
      this.errorMessage = '操作失败，请确认权限或当前状态'
    } finally {
      this.loading = false
    }
  }

  private statusLabel(status: string): string {
    if (status === 'SUBMITTED') {
      return '待审批'
    }
    if (status === 'APPROVED') {
      return '已审批'
    }
    if (status === 'IN_PROGRESS') {
      return '处理中'
    }
    if (status === 'RESOLVED') {
      return '已处理'
    }
    if (status === 'CLOSED') {
      return '已结案'
    }
    return status
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

        TextInput({ placeholder: '附件地址（占位）', text: this.attachmentInput })
          .onChange((value: string) => {
            this.attachmentInput = value
          })
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding(10)

        Button('提交投诉').onClick(() => this.submitComplaint())
      }

      if (this.isApproverMode() || this.isHandlerMode()) {
        TextInput({ placeholder: '处理意见 / 审批意见', text: this.commentInput })
          .onChange((value: string) => {
            this.commentInput = value
          })
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding(10)
      }

      if (this.isApproverMode()) {
        Button('审批通过').onClick(() => this.approveComplaint())
      }

      if (this.isHandlerMode()) {
        Row({ space: 10 }) {
          Button('提交处理').onClick(() => this.processComplaint()).layoutWeight(1)
          Button('执行结案').onClick(() => this.closeComplaint()).layoutWeight(1)
        }
      }

      if (this.isVisitorMode()) {
        TextInput({ placeholder: '评分（1-5）', text: this.ratingInput })
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
  private ListPanel(): void {
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
        Text('暂无投诉数据').fontColor('#6B7280')
      }
      .width('100%')
      .padding(20)
      .alignItems(HorizontalAlign.Center)
    } else {
      List({ space: 8 }) {
        ForEach(this.items, (item: ComplaintItem) => {
          ListItem() {
            Column({ space: 6 }) {
              Row() {
                Text(item.title).fontSize(16).fontWeight(FontWeight.Medium)
                Blank()
                Text(this.statusLabel(item.status)).fontSize(12).fontColor('#2563EB')
              }
              Text(item.content).fontSize(13).maxLines(2)
              Text(`投诉人：${item.createdBy}`).fontSize(12).fontColor('#6B7280')
              Text(`更新时间：${item.updatedAt}`).fontSize(11).fontColor('#9CA3AF')
              if (item.rating !== null) {
                Text(`评分：${item.rating}`).fontSize(12).fontColor('#059669')
              }
            }
            .alignItems(HorizontalAlign.Start)
            .padding(12)
            .backgroundColor(this.selectedId === item.id ? '#DBEAFE' : '#FFFFFF')
            .borderRadius(10)
            .onClick(() => {
              this.selectedId = item.id
            })
          }
        }, (item: ComplaintItem) => `${item.id}`)
      }
      .width('100%')
      .layoutWeight(1)
    }
  }

  build() {
    Column({ space: 10 }) {
      this.ActionPanel()
      this.ListPanel()
    }
    .padding(12)
    .width('100%')
    .height('100%')
    .backgroundColor('#F9FAFB')
  }
}
