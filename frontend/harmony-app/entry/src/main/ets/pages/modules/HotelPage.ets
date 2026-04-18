import { HotelResponse } from '../../common/model/ApiModels'
import { apiClient } from '../../common/network/ApiClient'
import {
  RADIUS_LG,
  RADIUS_MD,
  SHADOW_CARD,
  THEME_BORDER_SOFT,
  THEME_PAGE_BG,
  THEME_PRIMARY,
  THEME_PRIMARY_SOFT,
  THEME_SURFACE,
  THEME_SURFACE_MUTED,
  THEME_TEXT_PRIMARY,
  THEME_TEXT_SECONDARY,
  THEME_TEXT_TERTIARY
} from '../../common/ui/AppTheme'

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

  private isSelected(id: string): boolean {
    if (this.selected === null) {
      return false
    }
    return this.selected.id === id
  }

  private hotelCover(index: number): string {
    if (index % 3 === 0) {
      return 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1200&q=80'
    }
    if (index % 3 === 1) {
      return 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?auto=format&fit=crop&w=1200&q=80'
    }
    return 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=1200&q=80'
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
      Text(this.title()).fontSize(20).fontWeight(FontWeight.Medium).fontColor(THEME_TEXT_PRIMARY)
      Row({ space: 8 }) {
        TextInput({ placeholder: '按酒店名或区域搜索', text: this.keyword })
          .onChange((value: string) => {
            this.keyword = value
          })
          .layoutWeight(1)
          .backgroundColor(THEME_SURFACE)
          .border({ width: 1, color: THEME_BORDER_SOFT })
          .borderRadius(RADIUS_MD)
          .padding(10)
        Button('查询')
          .onClick(() => this.loadHotels())
          .backgroundColor(THEME_PRIMARY)
          .fontColor(Color.White)
          .borderRadius(RADIUS_MD)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding(12)
    .backgroundColor(THEME_SURFACE_MUTED)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private Content(): void {
    if (this.loading) {
      Text('加载中...').fontColor(THEME_TEXT_SECONDARY).padding(20)
    } else if (this.errorMessage.length > 0) {
      Column({ space: 8 }) {
        Text(this.errorMessage).fontColor('#DC2626').fontSize(12)
        Button('重试')
          .onClick(() => this.loadHotels())
          .backgroundColor(THEME_PRIMARY)
          .fontColor(Color.White)
          .borderRadius(RADIUS_MD)
      }
      .padding(20)
    } else if (this.items.length === 0) {
      Text('暂无酒店数据').fontColor(THEME_TEXT_SECONDARY).padding(20)
    } else {
      Row({ space: 10 }) {
        List({ space: 8 }) {
          ForEach(this.items, (item: HotelResponse, index: number) => {
            ListItem() {
              Column({ space: 6 }) {
                Image(this.hotelCover(index))
                  .width('100%')
                  .height(100)
                  .borderRadius(RADIUS_MD)
                  .objectFit(ImageFit.Cover)

                Text(item.name).fontSize(15).fontWeight(FontWeight.Medium).fontColor(THEME_TEXT_PRIMARY)
                Text(`⭐ ${item.star} 星 · ¥${item.price}`).fontSize(12).fontColor(THEME_TEXT_SECONDARY)
                Text(item.address).fontSize(12).fontColor(THEME_TEXT_SECONDARY).maxLines(1)
              }
              .alignItems(HorizontalAlign.Start)
              .padding(10)
              .backgroundColor(this.isSelected(item.id) ? THEME_PRIMARY_SOFT : THEME_SURFACE)
              .borderRadius(RADIUS_MD)
              .shadow(SHADOW_CARD)
              .onClick(() => {
                this.selected = item
              })
            }
          }, (item: HotelResponse) => item.id)
        }
        .layoutWeight(1)

        if (this.selected !== null) {
          Column({ space: 8 }) {
            Image('https://images.unsplash.com/photo-1568084680786-a84f91d1153c?auto=format&fit=crop&w=1200&q=80')
              .width('100%')
              .height(140)
              .borderRadius(RADIUS_MD)
              .objectFit(ImageFit.Cover)
            Text(this.selected.name).fontSize(16).fontWeight(FontWeight.Bold).fontColor(THEME_TEXT_PRIMARY)
            Text(`📍 地址：${this.selected.address}`).fontSize(12).fontColor(THEME_TEXT_SECONDARY)
            Text(`☎ 联系电话：${this.selected.phone}`).fontSize(12).fontColor(THEME_TEXT_SECONDARY)
            Text(`⭐ 评分：${this.selected.score}`).fontSize(12).fontColor(THEME_TEXT_SECONDARY)
            Text(`🥐 早餐：${this.selected.hasBreakfast ? '含早' : '不含早'}`).fontSize(12).fontColor(THEME_TEXT_SECONDARY)
            Text(`🧩 设施：${this.selected.facility}`).fontSize(12).fontColor(THEME_TEXT_SECONDARY).maxLines(2)
            Text(this.selected.introduction).fontSize(12).fontColor(THEME_TEXT_TERTIARY).maxLines(5)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          .padding(12)
          .backgroundColor(THEME_SURFACE)
          .borderRadius(RADIUS_LG)
          .shadow(SHADOW_CARD)
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
    .backgroundColor(THEME_PAGE_BG)
  }
}
