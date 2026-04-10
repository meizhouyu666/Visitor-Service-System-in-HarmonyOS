import { apiClient } from '../../common/network/ApiClient'
import { SimpleItem } from '../../common/model/ApiModels'

@Component
export struct ScenicRoutePage {
  @State private scenicSpots: SimpleItem[] = []
  @State private routes: SimpleItem[] = []

  async aboutToAppear(): Promise<void> {
    const spots: SimpleItem[] = await apiClient.get<SimpleItem[]>('/api/query/scenic-spots')
    const routeList: SimpleItem[] = await apiClient.get<SimpleItem[]>('/api/query/routes')
    this.scenicSpots = [...spots]
    this.routes = [...routeList]
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('Scenic Spot and Route Query').fontSize(20).fontWeight(FontWeight.Medium)
        Text('Scenic Spots').fontSize(16)
        ForEach(this.scenicSpots, (item: SimpleItem) => {
          Text(`${item.name} - ${item.description}`).fontSize(13)
        }, (item: SimpleItem) => item.id)
        Text('Travel Routes').fontSize(16)
        ForEach(this.routes, (item: SimpleItem) => {
          Text(`${item.name} - ${item.description}`).fontSize(13)
        }, (item: SimpleItem) => item.id)
      }.alignItems(HorizontalAlign.Start).padding(12).width('100%')
    }.height('100%')
  }
}
