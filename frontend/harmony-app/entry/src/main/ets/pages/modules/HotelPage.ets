import { apiClient } from '../../common/network/ApiClient'
import { SimpleItem } from '../../common/model/ApiModels'

@Component
export struct HotelPage {
  @State private starHotels: SimpleItem[] = []
  @State private nonStarHotels: SimpleItem[] = []

  async aboutToAppear(): Promise<void> {
    const stars: SimpleItem[] = await apiClient.get<SimpleItem[]>('/api/query/hotels/star')
    const nonStars: SimpleItem[] = await apiClient.get<SimpleItem[]>('/api/query/hotels/non-star')
    this.starHotels = [...stars]
    this.nonStarHotels = [...nonStars]
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('Hotel Query and Marketing').fontSize(20).fontWeight(FontWeight.Medium)

        Text('Star Hotels').fontSize(16)
        ForEach(this.starHotels, (item: SimpleItem) => {
          Text(`${item.name} - ${item.description}`).fontSize(13)
        }, (item: SimpleItem) => item.id)

        Text('Non-Star / Rural Hotels').fontSize(16)
        ForEach(this.nonStarHotels, (item: SimpleItem) => {
          Text(`${item.name} - ${item.description}`).fontSize(13)
        }, (item: SimpleItem) => item.id)
      }.alignItems(HorizontalAlign.Start).padding(12).width('100%')
    }.height('100%')
  }
}
