import { ScenicSpotResponse, TravelRouteResponse } from '../../common/model/ApiModels'
import { apiClient } from '../../common/network/ApiClient'

@Component
export struct ScenicRoutePage {
  @State private scenicKeyword: string = ''
  @State private routeKeyword: string = ''

  @State private scenicList: ScenicSpotResponse[] = []
  @State private routeList: TravelRouteResponse[] = []

  @State private scenicLoading: boolean = false
  @State private routeLoading: boolean = false
  @State private errorMessage: string = ''

  async aboutToAppear(): Promise<void> {
    await this.loadAll()
  }

  private async loadAll(): Promise<void> {
    await Promise.all([this.loadScenic(), this.loadRoute()])
  }

  private async loadScenic(): Promise<void> {
    this.scenicLoading = true
    this.errorMessage = ''
    try {
      const encoded: string = encodeURIComponent(this.scenicKeyword.trim())
      const path: string = encoded.length > 0 ? `/api/query/scenic-spots?keyword=${encoded}` : '/api/query/scenic-spots'
      const list: ScenicSpotResponse[] = await apiClient.get<ScenicSpotResponse[]>(path)
      this.scenicList = [...list]
    } catch (_error) {
      this.errorMessage = '景区数据加载失败'
    } finally {
      this.scenicLoading = false
    }
  }

  private async loadRoute(): Promise<void> {
    this.routeLoading = true
    this.errorMessage = ''
    try {
      const encoded: string = encodeURIComponent(this.routeKeyword.trim())
      const path: string = encoded.length > 0 ? `/api/query/routes?keyword=${encoded}` : '/api/query/routes'
      const list: TravelRouteResponse[] = await apiClient.get<TravelRouteResponse[]>(path)
      this.routeList = [...list]
    } catch (_error) {
      this.errorMessage = '线路数据加载失败'
    } finally {
      this.routeLoading = false
    }
  }

  @Builder
  private ScenicSection(): void {
    Column({ space: 8 }) {
      Row({ space: 8 }) {
        Text('景区查询').fontSize(16).fontWeight(FontWeight.Medium)
        Blank()
        TextInput({ placeholder: '景区关键字', text: this.scenicKeyword })
          .onChange((value: string) => {
            this.scenicKeyword = value
          })
          .width('45%')
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding(8)
        Button('查询').onClick(() => this.loadScenic())
      }

      if (this.scenicLoading) {
        Text('加载中...').fontColor('#6B7280')
      } else if (this.scenicList.length === 0) {
        Text('暂无景区数据').fontColor('#6B7280')
      } else {
        ForEach(this.scenicList, (item: ScenicSpotResponse) => {
          Column({ space: 4 }) {
            Text(item.name).fontSize(14).fontWeight(FontWeight.Medium)
            Text(`${item.location} · ${item.level} · ¥${item.ticketPrice}`).fontSize(12)
            Text(item.description).fontSize(12).maxLines(2)
          }
          .alignItems(HorizontalAlign.Start)
          .padding(10)
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
        }, (item: ScenicSpotResponse) => item.id)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding(12)
    .backgroundColor('#F3F4F6')
    .borderRadius(12)
  }

  @Builder
  private RouteSection(): void {
    Column({ space: 8 }) {
      Row({ space: 8 }) {
        Text('线路查询').fontSize(16).fontWeight(FontWeight.Medium)
        Blank()
        TextInput({ placeholder: '线路关键字', text: this.routeKeyword })
          .onChange((value: string) => {
            this.routeKeyword = value
          })
          .width('45%')
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding(8)
        Button('查询').onClick(() => this.loadRoute())
      }

      if (this.routeLoading) {
        Text('加载中...').fontColor('#6B7280')
      } else if (this.routeList.length === 0) {
        Text('暂无线路数据').fontColor('#6B7280')
      } else {
        ForEach(this.routeList, (item: TravelRouteResponse) => {
          Column({ space: 4 }) {
            Text(item.name).fontSize(14).fontWeight(FontWeight.Medium)
            Text(`${item.durationHours} 小时 · 难度 ${item.difficulty}`).fontSize(12)
            Text(`景点：${item.spots}`).fontSize(12).maxLines(1)
            Text(item.detail).fontSize(12).maxLines(2)
          }
          .alignItems(HorizontalAlign.Start)
          .padding(10)
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
        }, (item: TravelRouteResponse) => item.id)
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
        Text('景区与线路').fontSize(20).fontWeight(FontWeight.Medium)

        if (this.errorMessage.length > 0) {
          Text(this.errorMessage).fontColor(Color.Red).fontSize(12)
        }

        this.ScenicSection()
        this.RouteSection()
      }
      .alignItems(HorizontalAlign.Start)
      .padding(12)
      .width('100%')
    }
    .height('100%')
    .backgroundColor('#F9FAFB')
  }
}
