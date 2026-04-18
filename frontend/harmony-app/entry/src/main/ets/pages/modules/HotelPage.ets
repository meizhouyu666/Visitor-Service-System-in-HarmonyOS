import { HotelResponse } from '../../common/model/ApiModels'
import { apiClient } from '../../common/network/ApiClient'

export type HotelMode = 'visitor' | 'manager' | 'admin'

@Component
export struct HotelPage {
  @Prop mode: HotelMode = 'visitor'

  @State private keyword: string = ''
  @State private items: HotelResponse[] = []
  @State private loading: boolean = false
  @State private errorMessage: string = ''
  @State private selected: HotelResponse | null = null

  async aboutToAppear(): Promise<void> {
    await this.loadHotels()
  }

  private title(): string {
    if (this.mode === 'manager') {
      return '酒店管理视图'
    }
    if (this.mode === 'admin') {
      return '酒店管理（管理员）'
    }
    return '酒店查询'
  }

  private async loadHotels(): Promise<void> {
    this.loading = true
    this.errorMessage = ''
    try {
      const encoded: string = encodeURIComponent(this.keyword.trim())
      const path: string = encoded.length > 0 ? `/api/query/hotels?keyword=${encoded}` : '/api/query/hotels'
      const list: HotelResponse[] = await apiClient.get<HotelResponse[]>(path)
      this.items = [...list]
      this.selected = this.items.length > 0 ? this.items[0] : null
    } catch (_error) {
      this.errorMessage = '加载酒店数据失败'
    } finally {
      this.loading = false
    }
  }

  @Builder
  private Header(): void {
    Column({ space: 8 }) {
      Text(this.title()).fontSize(20).fontWeight(FontWeight.Medium)
      Row({ space: 8 }) {
        TextInput({ placeholder: '按酒店名或区域搜索', text: this.keyword })
          .onChange((value: string) => {
            this.keyword = value
          })
          .layoutWeight(1)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding(10)
        Button('查询').onClick(() => this.loadHotels())
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding(12)
    .backgroundColor('#F3F4F6')
    .borderRadius(12)
  }

  @Builder
  private Content(): void {
    if (this.loading) {
      Text('加载中...').fontColor('#6B7280').padding(20)
    } else if (this.errorMessage.length > 0) {
      Column({ space: 8 }) {
        Text(this.errorMessage).fontColor(Color.Red).fontSize(12)
        Button('重试').onClick(() => this.loadHotels())
      }
      .padding(20)
    } else if (this.items.length === 0) {
      Text('暂无酒店数据').fontColor('#6B7280').padding(20)
    } else {
      Row({ space: 10 }) {
        List({ space: 8 }) {
          ForEach(this.items, (item: HotelResponse) => {
            ListItem() {
              Column({ space: 4 }) {
                Text(item.name).fontSize(15).fontWeight(FontWeight.Medium)
                Text(`${item.star} 星 · ¥${item.price}`).fontSize(12).fontColor('#6B7280')
                Text(item.address).fontSize(12).maxLines(1)
              }
              .alignItems(HorizontalAlign.Start)
              .padding(10)
              .backgroundColor(this.selected?.id === item.id ? '#DBEAFE' : '#FFFFFF')
              .borderRadius(10)
              .onClick(() => {
                this.selected = item
              })
            }
          }, (item: HotelResponse) => item.id)
        }
        .layoutWeight(1)

        if (this.selected !== null) {
          Column({ space: 6 }) {
            Text(this.selected.name).fontSize(16).fontWeight(FontWeight.Bold)
            Text(`地址：${this.selected.address}`).fontSize(12)
            Text(`联系电话：${this.selected.phone}`).fontSize(12)
            Text(`评分：${this.selected.score}`).fontSize(12)
            Text(`早餐：${this.selected.hasBreakfast ? '含早' : '不含早'}`).fontSize(12)
            Text(`设施：${this.selected.facility}`).fontSize(12).maxLines(2)
            Text(this.selected.introduction).fontSize(12).maxLines(5)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          .padding(10)
          .backgroundColor('#FFFFFF')
          .borderRadius(10)
        }
      }
      .layoutWeight(1)
      .width('100%')
    }
  }

  build() {
    Column({ space: 10 }) {
      this.Header()
      this.Content()
    }
    .padding(12)
    .width('100%')
    .height('100%')
    .backgroundColor('#F9FAFB')
  }
}
