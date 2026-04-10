import { apiClient } from '../../common/network/ApiClient'
import { EmergencyItem } from '../../common/model/ApiModels'

@Component
export struct EmergencyPage {
  @State private items: EmergencyItem[] = []
  @State private loading: boolean = false

  async aboutToAppear(): Promise<void> {
    this.loading = true
    try {
      const result: EmergencyItem[] = await apiClient.get<EmergencyItem[]>('/api/emergency')
      this.items = [...result]
    } finally {
      this.loading = false
    }
  }

  build() {
    Column({ space: 8 }) {
      Text('Emergency Information').fontSize(20).fontWeight(FontWeight.Medium)
      if (this.loading) {
        Text('Loading...')
      }
      List() {
        ForEach(this.items, (item: EmergencyItem) => {
          ListItem() {
            Column({ space: 4 }) {
              Text(item.title).fontSize(16)
              Text(item.content).fontSize(13).maxLines(2)
              Text(item.status).fontSize(12)
            }.alignItems(HorizontalAlign.Start).padding(12)
          }
        }, (item: EmergencyItem) => `${item.id}`)
      }.height('85%')
    }.padding(12).width('100%').height('100%')
  }
}
