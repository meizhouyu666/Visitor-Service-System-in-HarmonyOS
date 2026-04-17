import { DiningResponse, EntertainmentResponse, PerformanceResponse } from '../../common/model/ApiModels'
import { apiClient } from '../../common/network/ApiClient'

@Component
export struct DiningShowPage {
  @State private diningList: DiningResponse[] = []
  @State private entertainmentList: EntertainmentResponse[] = []
  @State private performanceList: PerformanceResponse[] = []

  @State private loading: boolean = false
  @State private errorMessage: string = ''

  async aboutToAppear(): Promise<void> {
    await this.loadAll()
  }

  private async loadAll(): Promise<void> {
    this.loading = true
    this.errorMessage = ''
    try {
      const dining: DiningResponse[] = await apiClient.get<DiningResponse[]>('/api/query/dining')
      const entertainment: EntertainmentResponse[] = await apiClient.get<EntertainmentResponse[]>('/api/query/entertainment')
      const performances: PerformanceResponse[] = await apiClient.get<PerformanceResponse[]>('/api/query/performances')

      this.diningList = [...dining]
      this.entertainmentList = [...entertainment]
      this.performanceList = [...performances]
    } catch (_error) {
      this.errorMessage = '加载餐饮娱乐数据失败'
    } finally {
      this.loading = false
    }
  }

  @Builder
  private DiningSection(): void {
    Column({ space: 8 }) {
      Text('餐饮').fontSize(16).fontWeight(FontWeight.Medium)
      if (this.diningList.length === 0) {
        Text('暂无餐饮数据').fontColor('#6B7280')
      } else {
        ForEach(this.diningList, (item: DiningResponse) => {
          Column({ space: 4 }) {
            Text(item.name).fontSize(14).fontWeight(FontWeight.Medium)
            Text(`${item.type} · 人均 ¥${item.avgPrice}`).fontSize(12)
            Text(`推荐：${item.recommendFood}`).fontSize(12).maxLines(1)
            Text(item.detailDesc).fontSize(12).maxLines(2)
          }
          .alignItems(HorizontalAlign.Start)
          .padding(10)
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
        }, (item: DiningResponse) => item.id)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding(12)
    .backgroundColor('#F3F4F6')
    .borderRadius(12)
  }

  @Builder
  private EntertainmentSection(): void {
    Column({ space: 8 }) {
      Text('娱乐').fontSize(16).fontWeight(FontWeight.Medium)
      if (this.entertainmentList.length === 0) {
        Text('暂无娱乐数据').fontColor('#6B7280')
      } else {
        ForEach(this.entertainmentList, (item: EntertainmentResponse) => {
          Column({ space: 4 }) {
            Text(item.name).fontSize(14).fontWeight(FontWeight.Medium)
            Text(`${item.type} · ¥${item.price}`).fontSize(12)
            Text(`${item.location} · ${item.openTime}`).fontSize(12)
            Text(item.description).fontSize(12).maxLines(2)
          }
          .alignItems(HorizontalAlign.Start)
          .padding(10)
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
        }, (item: EntertainmentResponse) => item.id)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding(12)
    .backgroundColor('#F3F4F6')
    .borderRadius(12)
  }

  @Builder
  private PerformanceSection(): void {
    Column({ space: 8 }) {
      Text('演出').fontSize(16).fontWeight(FontWeight.Medium)
      if (this.performanceList.length === 0) {
        Text('暂无演出数据').fontColor('#6B7280')
      } else {
        ForEach(this.performanceList, (item: PerformanceResponse) => {
          Column({ space: 4 }) {
            Text(item.name).fontSize(14).fontWeight(FontWeight.Medium)
            Text(`${item.location} · ${item.showTime}`).fontSize(12)
            Text(`票价：¥${item.price} · 团队：${item.team}`).fontSize(12)
            Text(item.detail).fontSize(12).maxLines(2)
          }
          .alignItems(HorizontalAlign.Start)
          .padding(10)
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
        }, (item: PerformanceResponse) => item.id)
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
        Row({ space: 8 }) {
          Text('餐饮娱乐演出').fontSize(20).fontWeight(FontWeight.Medium)
          Blank()
          Button('刷新').onClick(() => this.loadAll())
        }
        .width('100%')

        if (this.loading) {
          Text('加载中...').fontColor('#6B7280')
        } else if (this.errorMessage.length > 0) {
          Text(this.errorMessage).fontColor(Color.Red).fontSize(12)
        } else {
          this.DiningSection()
          this.EntertainmentSection()
          this.PerformanceSection()
        }
      }
      .alignItems(HorizontalAlign.Start)
      .padding(12)
      .width('100%')
    }
    .height('100%')
    .backgroundColor('#F9FAFB')
  }
}
