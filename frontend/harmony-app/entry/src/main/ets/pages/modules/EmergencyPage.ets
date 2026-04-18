import { EmergencyItem, EmergencyRequest, TrafficResponse } from '../../common/model/ApiModels'
import { apiClient } from '../../common/network/ApiClient'
import {
  emergencyStatusTone,
  RADIUS_LG,
  RADIUS_MD,
  RADIUS_PILL,
  SHADOW_CARD,
  StatusTone,
  THEME_DANGER,
  THEME_PAGE_BG,
  THEME_PRIMARY,
  THEME_SUCCESS,
  THEME_SURFACE,
  THEME_SURFACE_MUTED,
  THEME_TEXT_PRIMARY,
  THEME_TEXT_SECONDARY,
  THEME_TEXT_TERTIARY,
  THEME_WARNING
} from '../../common/ui/AppTheme'
import { EmptyStateCard, FloatingCard, PrimaryActionButton, SectionHeader, StatusBadge } from '../../common/ui/UiKit'

export type EmergencyMode = 'visitor' | 'writer' | 'approver' | 'admin'

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
      this.fillEditor(this.items[0])
    }
  }

  private async loadItems(): Promise<void> {
    this.loading = true
    this.errorMessage = ''
    try {
      const list: EmergencyItem[] = await apiClient.get<EmergencyItem[]>(this.listApiPath())
      this.items = [...list]
      if (this.mode === 'visitor') {
        const traffic: TrafficResponse[] = await apiClient.get<TrafficResponse[]>('/api/query/traffic')
        this.trafficList = [...traffic]
      }
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
      validUntil: this.validUntilInput.length > 0 ? this.validUntilInput : null,
      alertLevel: this.alertLevelInput,
      alertType: this.alertTypeInput
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
      this.actionMessage = '草稿已更新'
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
    this.alertLevelInput = item.alertLevel ?? 'MEDIUM'
    this.alertTypeInput = item.alertType ?? 'GENERAL'
  }

  private clearEditor(): void {
    this.titleInput = ''
    this.contentInput = ''
    this.validFromInput = ''
    this.validUntilInput = ''
    this.alertLevelInput = 'MEDIUM'
    this.alertTypeInput = 'GENERAL'
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

  private statusTone(status: string): StatusTone {
    return emergencyStatusTone(status)
  }

  private levelLabel(level: string | undefined): string {
    if (level === 'HIGH') {
      return '高风险'
    }
    if (level === 'LOW') {
      return '低风险'
    }
    return '中风险'
  }

  private levelTone(level: string | undefined): 'danger' | 'warning' | 'primary' | 'neutral' {
    if (level === 'HIGH') {
      return 'danger'
    }
    if (level === 'LOW') {
      return 'primary'
    }
    return 'warning'
  }

  private severityIcon(level: string | undefined): string {
    if (level === 'HIGH') {
      return '🔴'
    }
    if (level === 'LOW') {
      return '🟢'
    }
    return '🟡'
  }

  @Builder
  private VisitorAlertCards(): void {
    FloatingCard() {
      Column({ space: 10 }) {
        SectionHeader({ title: '实时预警', subtitle: '按等级区分事件优先级' })

        if (this.loading) {
          EmptyStateCard({ message: '应急预警加载中...' })
        } else if (this.items.length === 0) {
          EmptyStateCard({ message: '当前暂无应急预警。' })
        } else {
          ForEach(this.items, (item: EmergencyItem) => {
            Row({ space: 10 }) {
              Text(this.severityIcon(item.alertLevel))
                .fontSize(16)
              Column({ space: 4 }) {
                Row({ space: 8 }) {
                  Text(item.title)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(THEME_TEXT_PRIMARY)
                    .layoutWeight(1)
                  StatusBadge({ label: this.levelLabel(item.alertLevel), tone: this.levelTone(item.alertLevel) })
                }
                .width('100%')
                Text(item.content)
                  .fontSize(12)
                  .fontColor(THEME_TEXT_SECONDARY)
                  .maxLines(2)
                Text(`类型：${item.alertType ?? 'GENERAL'}  · 生效：${item.validFrom ?? '-'}`)
                  .fontSize(10)
                  .fontColor(THEME_TEXT_TERTIARY)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .padding(10)
            .backgroundColor('#F8FAFF')
            .borderRadius(RADIUS_MD)
          }, (item: EmergencyItem) => `${item.id}`)
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  private VisitorMapCard(): void {
    FloatingCard() {
      Column({ space: 10 }) {
        SectionHeader({ title: '路况示意', subtitle: '静态地图卡（本期方案）' })

        Image($r('app.media.map_mock'))
          .width('100%')
          .height(150)
          .borderRadius(RADIUS_MD)
          .objectFit(ImageFit.Cover)

        if (this.trafficList.length === 0) {
          EmptyStateCard({ message: '暂无路况数据' })
        } else {
          ForEach(this.trafficList, (item: TrafficResponse, index: number) => {
            if (index < 2) {
              Row() {
                Text(this.severityIcon(item.severityLevel))
                  .fontSize(14)
                Text(`${item.fromLocation} → ${item.toLocation}`)
                  .fontSize(12)
                  .fontColor(THEME_TEXT_PRIMARY)
                  .layoutWeight(1)
                Text(item.status)
                  .fontSize(11)
                  .fontColor(item.severityLevel === 'HIGH' ? THEME_DANGER : item.severityLevel === 'LOW' ? THEME_SUCCESS : THEME_WARNING)
              }
              .padding(10)
              .width('100%')
              .backgroundColor('#F8FAFF')
              .borderRadius(RADIUS_MD)
            }
          }, (_item: TrafficResponse, index: number) => `${index}`)
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  private VisitorRealtimeList(): void {
    FloatingCard() {
      Column({ space: 10 }) {
        SectionHeader({ title: '提醒列表', subtitle: '按时间倒序展示应急消息' })

        if (this.items.length === 0) {
          EmptyStateCard({ message: '暂无提醒数据' })
        } else {
          ForEach(this.items, (item: EmergencyItem) => {
            Row({ space: 8 }) {
              Text(this.severityIcon(item.alertLevel))
                .fontSize(14)
              Column({ space: 2 }) {
                Text(item.title)
                  .fontSize(13)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(THEME_TEXT_PRIMARY)
                Text(item.content)
                  .fontSize(11)
                  .fontColor(THEME_TEXT_SECONDARY)
                  .maxLines(2)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .padding(10)
            .backgroundColor('#F8FAFF')
            .borderRadius(RADIUS_MD)
          }, (item: EmergencyItem) => `${item.id}`)
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
        if (this.errorMessage.length > 0) {
          Column({ space: 8 }) {
            Text(this.errorMessage)
              .fontSize(12)
              .fontColor(THEME_DANGER)
            Button('重试')
              .onClick(() => this.loadItems())
              .height(34)
              .borderRadius(RADIUS_PILL)
              .backgroundColor('#FEE4E2')
              .fontColor(THEME_DANGER)
          }
          .padding(12)
          .width('100%')
          .backgroundColor(THEME_SURFACE)
          .borderRadius(RADIUS_MD)
        }

        this.VisitorAlertCards()
        this.VisitorMapCard()
        this.VisitorRealtimeList()
      }
      .padding({ left: 12, right: 12, top: 12, bottom: 96 })
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .height('100%')
    .backgroundColor(THEME_PAGE_BG)
  }

  @Builder
  private ActionPanel(): void {
    FloatingCard() {
      Column({ space: 8 }) {
        SectionHeader({ title: this.modeTitle(), subtitle: '发布、审批与状态追踪' })

        if (this.canWrite()) {
          TextInput({ placeholder: '标题', text: this.titleInput })
            .onChange((value: string) => {
              this.titleInput = value
            })
            .backgroundColor('#F8FAFF')
            .borderRadius(RADIUS_MD)
            .padding(10)

          TextArea({ placeholder: '内容', text: this.contentInput })
            .onChange((value: string) => {
              this.contentInput = value
            })
            .height(90)
            .backgroundColor('#F8FAFF')
            .borderRadius(RADIUS_MD)
            .padding(10)

          Row({ space: 8 }) {
            TextInput({ placeholder: '预警等级（HIGH/MEDIUM/LOW）', text: this.alertLevelInput })
              .onChange((value: string) => {
                this.alertLevelInput = value
              })
              .layoutWeight(1)
              .backgroundColor('#F8FAFF')
              .borderRadius(RADIUS_MD)
              .padding(10)

            TextInput({ placeholder: '预警类型（如 WEATHER/TRAFFIC）', text: this.alertTypeInput })
              .onChange((value: string) => {
                this.alertTypeInput = value
              })
              .layoutWeight(1)
              .backgroundColor('#F8FAFF')
              .borderRadius(RADIUS_MD)
              .padding(10)
          }
          .width('100%')

          TextInput({ placeholder: '生效时间（如 2026-04-18T08:00:00）', text: this.validFromInput })
            .onChange((value: string) => {
              this.validFromInput = value
            })
            .backgroundColor('#F8FAFF')
            .borderRadius(RADIUS_MD)
            .padding(10)

          TextInput({ placeholder: '失效时间（如 2026-04-18T20:00:00）', text: this.validUntilInput })
            .onChange((value: string) => {
              this.validUntilInput = value
            })
            .backgroundColor('#F8FAFF')
            .borderRadius(RADIUS_MD)
            .padding(10)

          Row({ space: 8 }) {
            Button('建草稿')
              .onClick(() => this.createDraft())
              .layoutWeight(1)
              .height(40)
              .backgroundColor(THEME_PRIMARY)
              .fontColor(Color.White)
              .borderRadius(RADIUS_PILL)
            Button('保存修改')
              .onClick(() => this.updateDraft())
              .layoutWeight(1)
              .height(40)
              .backgroundColor('#EAF2FF')
              .fontColor(THEME_PRIMARY)
              .borderRadius(RADIUS_PILL)
            Button('提交审批')
              .onClick(() => this.submitForApproval())
              .layoutWeight(1)
              .height(40)
              .backgroundColor('#EEF3FA')
              .fontColor(THEME_TEXT_SECONDARY)
              .borderRadius(RADIUS_PILL)
          }
          .width('100%')
        }

        if (this.canApprove()) {
          PrimaryActionButton({ label: '审批发布', onPress: () => this.approvePublish() })
        }

        if (this.actionMessage.length > 0) {
          Text(this.actionMessage).fontColor(THEME_SUCCESS).fontSize(12)
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  private ListPanel(): void {
    FloatingCard() {
      Column({ space: 8 }) {
        SectionHeader({ title: '应急列表', subtitle: '选择后可回填编辑器' })

        if (this.loading) {
          EmptyStateCard({ message: '应急列表加载中...' })
        } else if (this.errorMessage.length > 0) {
          Column({ space: 8 }) {
            Text(this.errorMessage).fontColor(THEME_DANGER).fontSize(12)
            Button('重试')
              .onClick(() => this.loadItems())
              .height(34)
              .backgroundColor('#FEE4E2')
              .fontColor(THEME_DANGER)
              .borderRadius(RADIUS_PILL)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        } else if (this.items.length === 0) {
          EmptyStateCard({ message: '暂无应急信息' })
        } else {
          ForEach(this.items, (item: EmergencyItem) => {
            Column({ space: 6 }) {
              Row() {
                Text(item.title).fontSize(15).fontWeight(FontWeight.Medium).fontColor(THEME_TEXT_PRIMARY).layoutWeight(1)
                StatusBadge({ label: this.statusLabel(item.status), tone: 'primary' })
              }
              .width('100%')
              Text(item.content).fontSize(12).maxLines(2).fontColor(THEME_TEXT_SECONDARY)
              Row({ space: 8 }) {
                StatusBadge({ label: this.levelLabel(item.alertLevel), tone: this.levelTone(item.alertLevel) })
                Text(`类型：${item.alertType ?? 'GENERAL'}`).fontSize(11).fontColor(THEME_TEXT_TERTIARY)
              }
              .width('100%')
              Text(`更新时间：${item.updatedAt}`).fontSize(10).fontColor(THEME_TEXT_TERTIARY)
            }
            .alignItems(HorizontalAlign.Start)
            .padding(10)
            .backgroundColor(this.selectedId === item.id ? THEME_SURFACE_MUTED : '#F8FAFF')
            .borderRadius(RADIUS_MD)
            .onClick(() => this.fillEditor(item))
          }, (item: EmergencyItem) => `${item.id}`)
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  build() {
    if (this.mode === 'visitor') {
      this.VisitorView()
    } else {
      Scroll() {
        Column({ space: 12 }) {
          this.ActionPanel()
          this.ListPanel()
        }
        .padding({ left: 12, right: 12, top: 12, bottom: 20 })
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .height('100%')
      .backgroundColor(THEME_PAGE_BG)
    }
  }
}
