import { apiClient } from '../../common/network/ApiClient'
import { SimpleItem } from '../../common/model/ApiModels'

@Component
export struct DiningShowPage {
  @State private diningItems: SimpleItem[] = []
  @State private performanceItems: SimpleItem[] = []

  async aboutToAppear(): Promise<void> {
    const dining: SimpleItem[] = await apiClient.get<SimpleItem[]>('/api/query/dining-entertainment')
    const performance: SimpleItem[] = await apiClient.get<SimpleItem[]>('/api/query/performances')
    this.diningItems = [...dining]
    this.performanceItems = [...performance]
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('Dining and Performance').fontSize(20).fontWeight(FontWeight.Medium)
        Text('Dining and Entertainment').fontSize(16)
        ForEach(this.diningItems, (item: SimpleItem) => {
          Text(`${item.name} - ${item.description}`).fontSize(13)
        }, (item: SimpleItem) => item.id)
        Text('Performance Groups').fontSize(16)
        ForEach(this.performanceItems, (item: SimpleItem) => {
          Text(`${item.name} - ${item.description}`).fontSize(13)
        }, (item: SimpleItem) => item.id)
      }.alignItems(HorizontalAlign.Start).padding(12).width('100%')
    }.height('100%')
  }
}
