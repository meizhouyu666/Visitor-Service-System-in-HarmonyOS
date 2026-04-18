import { TrafficResponse, WeatherResponse } from '../../common/model/ApiModels'
import { apiClient } from '../../common/network/ApiClient'
import {
  RADIUS_LG,
  RADIUS_MD,
  SHADOW_CARD,
  THEME_DANGER,
  THEME_PAGE_BG,
  THEME_PRIMARY,
  THEME_SURFACE,
  THEME_SURFACE_MUTED,
  THEME_TEXT_PRIMARY,
  THEME_TEXT_SECONDARY
} from '../../common/ui/AppTheme'

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

  private trafficIcon(status: string): string {
    if (status.indexOf('畅通') >= 0) {
      return '🟢'
    }
    if (status.indexOf('拥堵') >= 0) {
      return '🔴'
    }
    return '🟡'
  }

  @Builder
  private WeatherSection(): void {
    Column({ space: 8 }) {
      Text('天气').fontSize(16).fontWeight(FontWeight.Medium).fontColor(THEME_TEXT_PRIMARY)
      if (this.weatherList.length === 0) {
        Text('暂无天气数据').fontColor(THEME_TEXT_SECONDARY)
      } else {
        ForEach(this.weatherList, (item: WeatherResponse) => {
          Row() {
            Text(`☁ ${item.date}  ${item.weather}  ${item.temperature}`)
              .fontSize(12)
              .fontColor(THEME_TEXT_PRIMARY)
              .layoutWeight(1)
            Text(`🌬 ${item.wind}`).fontSize(12).fontColor(THEME_TEXT_SECONDARY)
          }
          .padding(10)
          .width('100%')
          .backgroundColor(THEME_SURFACE)
          .borderRadius(RADIUS_MD)
          .shadow(SHADOW_CARD)
        }, (item: WeatherResponse) => item.date)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding(12)
    .backgroundColor(THEME_SURFACE_MUTED)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private TrafficSection(): void {
    Column({ space: 8 }) {
      Text('路况').fontSize(16).fontWeight(FontWeight.Medium).fontColor(THEME_TEXT_PRIMARY)
      if (this.trafficList.length === 0) {
        Text('暂无路况数据').fontColor(THEME_TEXT_SECONDARY)
      } else {
        ForEach(this.trafficList, (item: TrafficResponse, index: number) => {
          Column({ space: 4 }) {
            Text(`${this.trafficIcon(item.status)} ${item.fromLocation} → ${item.toLocation}`)
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor(THEME_TEXT_PRIMARY)
            Text(`状态：${item.status} · 耗时：${item.takeTime}`).fontSize(12).fontColor(THEME_TEXT_SECONDARY)
            Text(`建议路线：${item.suggestRoute}`).fontSize(12).fontColor(THEME_TEXT_SECONDARY).maxLines(2)
          }
          .alignItems(HorizontalAlign.Start)
          .padding(10)
          .width('100%')
          .backgroundColor(THEME_SURFACE)
          .borderRadius(RADIUS_MD)
          .shadow(SHADOW_CARD)
        }, (_item: TrafficResponse, index: number) => `${index}`)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding(12)
    .backgroundColor(THEME_SURFACE_MUTED)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  build() {
    Scroll() {
      Column({ space: 10 }) {
        Row({ space: 8 }) {
          Text('天气与路况').fontSize(20).fontWeight(FontWeight.Medium).fontColor(THEME_TEXT_PRIMARY)
          Blank()
          Button('刷新')
            .onClick(() => this.loadData())
            .backgroundColor(THEME_PRIMARY)
            .fontColor(Color.White)
            .borderRadius(RADIUS_MD)
        }
        .width('100%')

        if (this.loading) {
          Text('加载中...').fontColor(THEME_TEXT_SECONDARY)
        } else if (this.errorMessage.length > 0) {
          Text(this.errorMessage).fontColor(THEME_DANGER).fontSize(12)
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
    .backgroundColor(THEME_PAGE_BG)
  }
}
