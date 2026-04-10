import { apiClient } from '../../common/network/ApiClient'
import { ComplaintItem } from '../../common/model/ApiModels'

@Component
export struct ComplaintPage {
  @State private items: ComplaintItem[] = []
  @State private loading: boolean = false
  @State private errorMessage: string = ''

  async aboutToAppear(): Promise<void> {
    await this.loadComplaints()
  }

  private async loadComplaints(): Promise<void> {
    this.loading = true
    this.errorMessage = ''
    try {
      const list: ComplaintItem[] = await apiClient.get<ComplaintItem[]>('/api/complaints')
      this.items = [...list]
    } catch (error) {
      this.errorMessage = `Load complaints failed: ${JSON.stringify(error)}`
    } finally {
      this.loading = false
    }
  }

  build() {
    Column({ space: 8 }) {
      Text('Complaint System').fontSize(20).fontWeight(FontWeight.Medium)
      if (this.loading) {
        Text('Loading...')
      }
      if (this.errorMessage.length > 0) {
        Text(this.errorMessage).fontColor(Color.Red).fontSize(12)
      }
      List() {
        ForEach(this.items, (item: ComplaintItem) => {
          ListItem() {
            Column({ space: 4 }) {
              Text(item.title).fontSize(16).fontWeight(FontWeight.Medium)
              Text(item.status).fontSize(12)
              Text(item.content).fontSize(13).maxLines(2)
            }.alignItems(HorizontalAlign.Start).padding(12)
          }
        }, (item: ComplaintItem) => `${item.id}`)
      }.height('85%')
    }.padding(12).width('100%').height('100%')
  }
}
