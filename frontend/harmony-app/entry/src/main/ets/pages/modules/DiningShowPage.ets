import { DiningResponse, EntertainmentResponse, PerformanceResponse } from '../../common/model/ApiModels'
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
export struct DiningShowPage {
  @State private diningList: DiningResponse[] = []
  @State private entertainmentList: EntertainmentResponse[] = []
  @State private performanceList: PerformanceResponse[] = []

  @State private loading: boolean = false
  @State private errorMessage: string = ''

  async aboutToAppear(): Promise<void> {
    await this.loadAll()
  }

  private diningCover(index: number): string {
    if (index % 3 === 0) {
      return 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=1200&q=80'
    }
    if (index % 3 === 1) {
      return 'https://images.unsplash.com/photo-1481833761820-0509d3217039?auto=format&fit=crop&w=1200&q=80'
    }
    return 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=1200&q=80'
  }

  private entertainmentCover(index: number): string {
    if (index % 2 === 0) {
      return 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=1200&q=80'
    }
    return 'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?auto=format&fit=crop&w=1200&q=80'
  }

  private performanceCover(index: number): string {
    if (index % 2 === 0) {
      return 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?auto=format&fit=crop&w=1200&q=80'
    }
    return 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=1200&q=80'
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
      Text('餐饮').fontSize(16).fontWeight(FontWeight.Medium).fontColor(THEME_TEXT_PRIMARY)
      if (this.diningList.length === 0) {
        Text('暂无餐饮数据').fontColor(THEME_TEXT_SECONDARY)
      } else {
        ForEach(this.diningList, (item: DiningResponse, index: number) => {
          Column({ space: 6 }) {
            Image(this.diningCover(index))
              .width('100%')
              .height(120)
              .objectFit(ImageFit.Cover)
              .borderRadius(RADIUS_MD)
            Text(item.name).fontSize(14).fontWeight(FontWeight.Medium).fontColor(THEME_TEXT_PRIMARY)
            Text(`${item.type} · 人均 ¥${item.avgPrice}`).fontSize(12).fontColor(THEME_TEXT_SECONDARY)
            Text(`推荐：${item.recommendFood}`).fontSize(12).fontColor(THEME_TEXT_SECONDARY).maxLines(1)
            Text(item.detailDesc).fontSize(12).fontColor(THEME_TEXT_SECONDARY).maxLines(2)
          }
          .alignItems(HorizontalAlign.Start)
          .padding(10)
          .width('100%')
          .backgroundColor(THEME_SURFACE)
          .borderRadius(RADIUS_MD)
          .shadow(SHADOW_CARD)
        }, (item: DiningResponse) => item.id)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding(12)
    .backgroundColor(THEME_SURFACE_MUTED)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private EntertainmentSection(): void {
    Column({ space: 8 }) {
      Text('娱乐').fontSize(16).fontWeight(FontWeight.Medium).fontColor(THEME_TEXT_PRIMARY)
      if (this.entertainmentList.length === 0) {
        Text('暂无娱乐数据').fontColor(THEME_TEXT_SECONDARY)
      } else {
        ForEach(this.entertainmentList, (item: EntertainmentResponse, index: number) => {
          Column({ space: 6 }) {
            Image(this.entertainmentCover(index))
              .width('100%')
              .height(120)
              .objectFit(ImageFit.Cover)
              .borderRadius(RADIUS_MD)
            Text(item.name).fontSize(14).fontWeight(FontWeight.Medium).fontColor(THEME_TEXT_PRIMARY)
            Text(`${item.type} · ¥${item.price}`).fontSize(12).fontColor(THEME_TEXT_SECONDARY)
            Text(`${item.location} · ${item.openTime}`).fontSize(12).fontColor(THEME_TEXT_SECONDARY)
            Text(item.description).fontSize(12).fontColor(THEME_TEXT_SECONDARY).maxLines(2)
          }
          .alignItems(HorizontalAlign.Start)
          .padding(10)
          .width('100%')
          .backgroundColor(THEME_SURFACE)
          .borderRadius(RADIUS_MD)
          .shadow(SHADOW_CARD)
        }, (item: EntertainmentResponse) => item.id)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding(12)
    .backgroundColor(THEME_SURFACE_MUTED)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private PerformanceSection(): void {
    Column({ space: 8 }) {
      Text('演出').fontSize(16).fontWeight(FontWeight.Medium).fontColor(THEME_TEXT_PRIMARY)
      if (this.performanceList.length === 0) {
        Text('暂无演出数据').fontColor(THEME_TEXT_SECONDARY)
      } else {
        ForEach(this.performanceList, (item: PerformanceResponse, index: number) => {
          Column({ space: 6 }) {
            Image(this.performanceCover(index))
              .width('100%')
              .height(120)
              .objectFit(ImageFit.Cover)
              .borderRadius(RADIUS_MD)
            Text(item.name).fontSize(14).fontWeight(FontWeight.Medium).fontColor(THEME_TEXT_PRIMARY)
            Text(`${item.location} · ${item.showTime}`).fontSize(12).fontColor(THEME_TEXT_SECONDARY)
            Text(`票价：¥${item.price} · 团队：${item.team}`).fontSize(12).fontColor(THEME_TEXT_SECONDARY)
            Text(item.detail).fontSize(12).fontColor(THEME_TEXT_SECONDARY).maxLines(2)
          }
          .alignItems(HorizontalAlign.Start)
          .padding(10)
          .width('100%')
          .backgroundColor(THEME_SURFACE)
          .borderRadius(RADIUS_MD)
          .shadow(SHADOW_CARD)
        }, (item: PerformanceResponse) => item.id)
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
          Text('餐饮娱乐演出').fontSize(20).fontWeight(FontWeight.Medium).fontColor(THEME_TEXT_PRIMARY)
          Blank()
          Button('刷新')
            .onClick(() => this.loadAll())
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
    .backgroundColor(THEME_PAGE_BG)
  }
}
