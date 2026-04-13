import { apiClient } from '../../common/network/ApiClient'

interface WeatherTrafficData {
  weather: string
  temperature: string
  traffic: string
}

@Component
export struct WeatherTrafficPage {
  @State private data: WeatherTrafficData = {
    weather: '',
    temperature: '',
    traffic: ''
  }

  aboutToAppear() {
    // 不要 async！不要 await！
    this.loadData()
  }

  async loadData(): Promise<void> {
    try {
      const result: WeatherTrafficData = await apiClient.get<WeatherTrafficData>('/api/query/weather-traffic')
      this.data = result; // 不要包 {}！！！
    } catch (err) {
      console.error("加载数据失败", err)
    }
  }

  build() {
    Column({ space: 10 }) {
      Text('Weather and Traffic').fontSize(20).fontWeight(FontWeight.Medium)
      Text(`Weather: ${this.data.weather}`).fontSize(14)
      Text(`Temperature: ${this.data.temperature}`).fontSize(14)
      Text(`Traffic: ${this.data.traffic}`).fontSize(14)
    }.alignItems(HorizontalAlign.Start).padding(12).width('100%').height('100%')
  }
}
