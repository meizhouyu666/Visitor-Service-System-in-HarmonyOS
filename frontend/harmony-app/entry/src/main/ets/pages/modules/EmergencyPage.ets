import { EmergencyItem, EmergencyRequest } from '../../common/model/ApiModels'
import { apiClient } from '../../common/network/ApiClient'

export type EmergencyMode = 'visitor' | 'writer' | 'approver' | 'admin'

@Component
export struct EmergencyPage {
  @Prop mode: EmergencyMode = 'visitor'

  @State private items: EmergencyItem[] = []
  @State private loading: boolean = false
  @State private errorMessage: string = ''
  @State private actionMessage: string = ''

  @State private selectedId: number = 0
  @State private titleInput: string = ''
  @State private contentInput: string = ''
  @State private validFromInput: string = ''
  @State private validUntilInput: string = ''

  async aboutToAppear(): Promise<void> {
    await this.loadItems()
  }

  private modeTitle(): string {
    if (this.mode === 'visitor') {
      return '应急公告'
    }
    if (this.mode === 'writer') {
      return '应急发布'
    }
    if (this.mode === 'approver') {
      return '应急审批'
    }
    return '应急管理（管理员）'
  }

  private canWrite(): boolean {
    return this.mode === 'writer' || this.mode === 'admin'
  }

  private canApprove(): boolean {
    return this.mode === 'approver' || this.mode === 'admin'
  }

  private listApiPath(): string {
    if (this.mode === 'visitor') {
      return '/api/emergency'
    }
    return '/api/emergency/admin'
  }

  private refreshSelection(): void {
    if (this.items.length === 0) {
      this.selectedId = 0
      return
    }
    const exists: boolean = this.items.some((item: EmergencyItem) => item.id === this.selectedId)
    if (!exists) {
      this.selectedId = this.items[0].id
    }
  }

  private async loadItems(): Promise<void> {
    this.loading = true
    this.errorMessage = ''
    try {
      const list: EmergencyItem[] = await apiClient.get<EmergencyItem[]>(this.listApiPath())
      this.items = [...list]
      this.refreshSelection()
    } catch (_error) {
      this.errorMessage = '加载应急信息失败，请稍后重试'
    } finally {
      this.loading = false
    }
  }

  private buildRequest(): EmergencyRequest {
    return {
      title: this.titleInput,
      content: this.contentInput,
      validFrom: this.validFromInput.length > 0 ? this.validFromInput : null,
      validUntil: this.validUntilInput.length > 0 ? this.validUntilInput : null
    }
  }

  private async createDraft(): Promise<void> {
    if (this.titleInput.trim().length === 0 || this.contentInput.trim().length === 0) {
      this.actionMessage = '请填写标题和内容'
      return
    }
    this.loading = true
    this.errorMessage = ''
    this.actionMessage = ''
    try {
      const payload: EmergencyRequest = this.buildRequest()
      await apiClient.post<EmergencyRequest, EmergencyItem>('/api/emergency/admin', payload)
      this.actionMessage = '草稿已创建'
      this.clearEditor()
      await this.loadItems()
    } catch (_error) {
      this.errorMessage = '创建草稿失败'
    } finally {
      this.loading = false
    }
  }

  private async updateDraft(): Promise<void> {
    if (this.selectedId <= 0) {
      this.actionMessage = '请先选择一条应急信息'
      return
    }
    this.loading = true
    this.errorMessage = ''
    this.actionMessage = ''
    try {
      const payload: EmergencyRequest = this.buildRequest()
      await apiClient.put<EmergencyRequest, EmergencyItem>(`/api/emergency/admin/${this.selectedId}`, payload)
      this.actionMessage = '已更新草稿'
      await this.loadItems()
    } catch (_error) {
      this.errorMessage = '更新草稿失败'
    } finally {
      this.loading = false
    }
  }

  private async submitForApproval(): Promise<void> {
    if (this.selectedId <= 0) {
      this.actionMessage = '请先选择一条应急信息'
      return
    }
    this.loading = true
    this.errorMessage = ''
    this.actionMessage = ''
    try {
      await apiClient.post<Record<string, string>, EmergencyItem>(`/api/emergency/admin/${this.selectedId}/submit`, {})
      this.actionMessage = '已提交审批'
      await this.loadItems()
    } catch (_error) {
      this.errorMessage = '提交审批失败'
    } finally {
      this.loading = false
    }
  }

  private async approvePublish(): Promise<void> {
    if (this.selectedId <= 0) {
      this.actionMessage = '请先选择一条应急信息'
      return
    }
    this.loading = true
    this.errorMessage = ''
    this.actionMessage = ''
    try {
      await apiClient.post<Record<string, string>, EmergencyItem>(`/api/emergency/admin/${this.selectedId}/approve`, {})
      this.actionMessage = '已审批并发布'
      await this.loadItems()
    } catch (_error) {
      this.errorMessage = '审批失败'
    } finally {
      this.loading = false
    }
  }

  private fillEditor(item: EmergencyItem): void {
    this.selectedId = item.id
    this.titleInput = item.title
    this.contentInput = item.content
    this.validFromInput = item.validFrom ?? ''
    this.validUntilInput = item.validUntil ?? ''
  }

  private clearEditor(): void {
    this.titleInput = ''
    this.contentInput = ''
    this.validFromInput = ''
    this.validUntilInput = ''
  }

  private statusLabel(status: string): string {
    if (status === 'DRAFT') {
      return '草稿'
    }
    if (status === 'PENDING_APPROVAL') {
      return '待审批'
    }
    if (status === 'PUBLISHED') {
      return '已发布'
    }
    return status
  }

  @Builder
  private ActionPanel(): void {
    Column({ space: 8 }) {
      Text(this.modeTitle()).fontSize(20).fontWeight(FontWeight.Medium)

      if (this.canWrite()) {
        TextInput({ placeholder: '标题', text: this.titleInput })
          .onChange((value: string) => {
            this.titleInput = value
          })
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding(10)

        TextArea({ placeholder: '内容', text: this.contentInput })
          .onChange((value: string) => {
            this.contentInput = value
          })
          .height(90)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding(10)

        TextInput({ placeholder: '生效时间（如 2026-04-18T08:00:00）', text: this.validFromInput })
          .onChange((value: string) => {
            this.validFromInput = value
          })
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding(10)

        TextInput({ placeholder: '失效时间（如 2026-04-18T20:00:00）', text: this.validUntilInput })
          .onChange((value: string) => {
            this.validUntilInput = value
          })
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding(10)

        Row({ space: 10 }) {
          Button('建草稿').onClick(() => this.createDraft()).layoutWeight(1)
          Button('保存修改').onClick(() => this.updateDraft()).layoutWeight(1)
          Button('提交审批').onClick(() => this.submitForApproval()).layoutWeight(1)
        }
      }

      if (this.canApprove()) {
        Button('审批发布').onClick(() => this.approvePublish())
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
        Button('重试').onClick(() => this.loadItems())
      }
      .width('100%')
      .padding(20)
      .alignItems(HorizontalAlign.Center)
    } else if (this.items.length === 0) {
      Column() {
        Text('暂无应急信息').fontColor('#6B7280')
      }
      .width('100%')
      .padding(20)
      .alignItems(HorizontalAlign.Center)
    } else {
      List({ space: 8 }) {
        ForEach(this.items, (item: EmergencyItem) => {
          ListItem() {
            Column({ space: 6 }) {
              Row() {
                Text(item.title).fontSize(16).fontWeight(FontWeight.Medium)
                Blank()
                Text(this.statusLabel(item.status)).fontSize(12).fontColor('#2563EB')
              }
              Text(item.content).fontSize(13).maxLines(2)
              Text(`生效：${item.validFrom ?? '-'}  失效：${item.validUntil ?? '-'}`).fontSize(11).fontColor('#6B7280')
            }
            .alignItems(HorizontalAlign.Start)
            .padding(12)
            .backgroundColor(this.selectedId === item.id ? '#DBEAFE' : '#FFFFFF')
            .borderRadius(10)
            .onClick(() => {
              this.fillEditor(item)
            })
          }
        }, (item: EmergencyItem) => `${item.id}`)
      }
      .layoutWeight(1)
      .width('100%')
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
