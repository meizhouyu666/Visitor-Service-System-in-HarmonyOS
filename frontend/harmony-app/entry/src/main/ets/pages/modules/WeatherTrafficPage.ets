import { TrafficResponse, WeatherResponse } from '../../common/model/ApiModels'
import { apiClient } from '../../common/network/ApiClient'

@Component
export struct WeatherTrafficPage {
  @State private weatherList: WeatherResponse[] = []
  @State private trafficList: TrafficResponse[] = []
  @State private loading: boolean = false
  @State private errorMessage: string = ''

  async aboutToAppear(): Promise<void> {
    await this.loadData()
  }

  private async loadData(): Promise<void> {
    this.loading = true
    this.errorMessage = ''
    try {
      const weather: WeatherResponse[] = await apiClient.get<WeatherResponse[]>('/api/query/weather')
      const traffic: TrafficResponse[] = await apiClient.get<TrafficResponse[]>('/api/query/traffic')
      this.weatherList = [...weather]
      this.trafficList = [...traffic]
    } catch (_error) {
      this.errorMessage = '加载天气路况失败'
    } finally {
      this.loading = false
    }
  }

  @Builder
  private WeatherSection(): void {
    Column({ space: 8 }) {
      Text('天气').fontSize(16).fontWeight(FontWeight.Medium)
      if (this.weatherList.length === 0) {
        Text('暂无天气数据').fontColor('#6B7280')
      } else {
        ForEach(this.weatherList, (item: WeatherResponse) => {
          Row() {
            Text(`${item.date} ${item.weather} ${item.temperature}`)
              .fontSize(12)
              .layoutWeight(1)
            Text(item.wind).fontSize(12)
          }
          .padding(10)
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
        }, (item: WeatherResponse) => item.date)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding(12)
    .backgroundColor('#F3F4F6')
    .borderRadius(12)
  }

  @Builder
  private TrafficSection(): void {
    Column({ space: 8 }) {
      Text('路况').fontSize(16).fontWeight(FontWeight.Medium)
      if (this.trafficList.length === 0) {
        Text('暂无路况数据').fontColor('#6B7280')
      } else {
        ForEach(this.trafficList, (item: TrafficResponse, index: number) => {
          Column({ space: 4 }) {
            Text(`${item.fromLocation} → ${item.toLocation}`).fontSize(13).fontWeight(FontWeight.Medium)
            Text(`状态：${item.status} · 耗时：${item.takeTime}`).fontSize(12)
            Text(`建议路线：${item.suggestRoute}`).fontSize(12).maxLines(2)
          }
          .alignItems(HorizontalAlign.Start)
          .padding(10)
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
        }, (_item: TrafficResponse, index: number) => `${index}`)
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
          Text('天气与路况').fontSize(20).fontWeight(FontWeight.Medium)
          Blank()
          Button('刷新').onClick(() => this.loadData())
        }
        .width('100%')

        if (this.loading) {
          Text('加载中...').fontColor('#6B7280')
        } else if (this.errorMessage.length > 0) {
          Text(this.errorMessage).fontColor(Color.Red).fontSize(12)
        } else {
          this.WeatherSection()
          this.TrafficSection()
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
