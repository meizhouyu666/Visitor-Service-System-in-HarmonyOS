import { ScenicSpotResponse, TravelRouteResponse } from '../../common/model/ApiModels'
import { apiClient } from '../../common/network/ApiClient'
import {
  RADIUS_LG,
  RADIUS_MD,
  SHADOW_CARD,
  THEME_BORDER_SOFT,
  THEME_PAGE_BG,
  THEME_PRIMARY,
  THEME_SURFACE,
  THEME_SURFACE_MUTED,
  THEME_TEXT_PRIMARY,
  THEME_TEXT_SECONDARY
} from '../../common/ui/AppTheme'

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

  private scenicCover(index: number): string {
    if (index % 3 === 0) {
      return 'https://images.unsplash.com/photo-1501555088652-021faa106b9b?auto=format&fit=crop&w=1200&q=80'
    }
    if (index % 3 === 1) {
      return 'https://images.unsplash.com/photo-1528127269322-539801943592?auto=format&fit=crop&w=1200&q=80'
    }
    return 'https://images.unsplash.com/photo-1503220317375-aaad61436b1b?auto=format&fit=crop&w=1200&q=80'
  }

  private routeCover(index: number): string {
    if (index % 2 === 0) {
      return 'https://images.unsplash.com/photo-1464822759844-d150ad6d1d1c?auto=format&fit=crop&w=1200&q=80'
    }
    return 'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?auto=format&fit=crop&w=1200&q=80'
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
        Text('景区查询').fontSize(16).fontWeight(FontWeight.Medium).fontColor(THEME_TEXT_PRIMARY)
        Blank()
        TextInput({ placeholder: '景区关键词', text: this.scenicKeyword })
          .onChange((value: string) => {
            this.scenicKeyword = value
          })
          .width('45%')
          .backgroundColor(THEME_SURFACE)
          .border({ width: 1, color: THEME_BORDER_SOFT })
          .borderRadius(RADIUS_MD)
          .padding(8)
        Button('查询')
          .onClick(() => this.loadScenic())
          .backgroundColor(THEME_PRIMARY)
          .fontColor(Color.White)
          .borderRadius(RADIUS_MD)
      }

      if (this.scenicLoading) {
        Text('加载中...').fontColor(THEME_TEXT_SECONDARY)
      } else if (this.scenicList.length === 0) {
        Text('暂无景区数据').fontColor(THEME_TEXT_SECONDARY)
      } else {
        ForEach(this.scenicList, (item: ScenicSpotResponse, index: number) => {
          Column({ space: 6 }) {
            Image(this.scenicCover(index))
              .width('100%')
              .height(120)
              .objectFit(ImageFit.Cover)
              .borderRadius(RADIUS_MD)
            Text(item.name).fontSize(14).fontWeight(FontWeight.Medium).fontColor(THEME_TEXT_PRIMARY)
            Text(`📍 ${item.location} · ${item.level} · ¥${item.ticketPrice}`).fontSize(12).fontColor(THEME_TEXT_SECONDARY)
            Text(item.description).fontSize(12).fontColor(THEME_TEXT_SECONDARY).maxLines(2)
          }
          .alignItems(HorizontalAlign.Start)
          .padding(10)
          .width('100%')
          .backgroundColor(THEME_SURFACE)
          .borderRadius(RADIUS_MD)
          .shadow(SHADOW_CARD)
        }, (item: ScenicSpotResponse) => item.id)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding(12)
    .backgroundColor(THEME_SURFACE_MUTED)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private RouteSection(): void {
    Column({ space: 8 }) {
      Row({ space: 8 }) {
        Text('线路查询').fontSize(16).fontWeight(FontWeight.Medium).fontColor(THEME_TEXT_PRIMARY)
        Blank()
        TextInput({ placeholder: '线路关键词', text: this.routeKeyword })
          .onChange((value: string) => {
            this.routeKeyword = value
          })
          .width('45%')
          .backgroundColor(THEME_SURFACE)
          .border({ width: 1, color: THEME_BORDER_SOFT })
          .borderRadius(RADIUS_MD)
          .padding(8)
        Button('查询')
          .onClick(() => this.loadRoute())
          .backgroundColor(THEME_PRIMARY)
          .fontColor(Color.White)
          .borderRadius(RADIUS_MD)
      }

      if (this.routeLoading) {
        Text('加载中...').fontColor(THEME_TEXT_SECONDARY)
      } else if (this.routeList.length === 0) {
        Text('暂无线路数据').fontColor(THEME_TEXT_SECONDARY)
      } else {
        ForEach(this.routeList, (item: TravelRouteResponse, index: number) => {
          Column({ space: 6 }) {
            Image(this.routeCover(index))
              .width('100%')
              .height(120)
              .objectFit(ImageFit.Cover)
              .borderRadius(RADIUS_MD)
            Text(item.name).fontSize(14).fontWeight(FontWeight.Medium).fontColor(THEME_TEXT_PRIMARY)
            Text(`🕒 ${item.durationHours} 小时 · 难度 ${item.difficulty}`).fontSize(12).fontColor(THEME_TEXT_SECONDARY)
            Text(`📌 景点：${item.spots}`).fontSize(12).fontColor(THEME_TEXT_SECONDARY).maxLines(1)
            Text(item.detail).fontSize(12).fontColor(THEME_TEXT_SECONDARY).maxLines(2)
          }
          .alignItems(HorizontalAlign.Start)
          .padding(10)
          .width('100%')
          .backgroundColor(THEME_SURFACE)
          .borderRadius(RADIUS_MD)
          .shadow(SHADOW_CARD)
        }, (item: TravelRouteResponse) => item.id)
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
        Text('景区与线路').fontSize(20).fontWeight(FontWeight.Medium).fontColor(THEME_TEXT_PRIMARY)

        if (this.errorMessage.length > 0) {
          Text(this.errorMessage).fontColor('#DC2626').fontSize(12)
        }

        this.ScenicSection()
        this.RouteSection()
      }
      .alignItems(HorizontalAlign.Start)
      .padding(12)
      .width('100%')
    }
    .height('100%')
    .backgroundColor(THEME_PAGE_BG)
  }
}
