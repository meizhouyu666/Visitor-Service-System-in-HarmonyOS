import {
  RADIUS_LG,
  RADIUS_MD,
  RADIUS_PILL,
  SHADOW_CARD,
  THEME_BORDER_SOFT,
  THEME_DANGER,
  THEME_PRIMARY,
  THEME_SUCCESS,
  THEME_SURFACE,
  THEME_TEXT_PRIMARY,
  THEME_TEXT_SECONDARY,
  THEME_WARNING
} from './AppTheme'

export type BadgeTone = 'primary' | 'success' | 'warning' | 'danger' | 'neutral'

@Builder
function EmptyBuilder(): void {}

function EmptyAction(): void {}

function toneTextColor(tone: BadgeTone): string {
  if (tone === 'primary') {
    return THEME_PRIMARY
  }
  if (tone === 'success') {
    return THEME_SUCCESS
  }
  if (tone === 'warning') {
    return THEME_WARNING
  }
  if (tone === 'danger') {
    return THEME_DANGER
  }
  return THEME_TEXT_SECONDARY
}

function toneBackgroundColor(tone: BadgeTone): string {
  if (tone === 'primary') {
    return '#EAF2FF'
  }
  if (tone === 'success') {
    return '#EAF8EF'
  }
  if (tone === 'warning') {
    return '#FFF6E6'
  }
  if (tone === 'danger') {
    return '#FFECEC'
  }
  return '#EFF3F8'
}

@Component
export struct FloatingCard {
  @BuilderParam content: () => void = EmptyBuilder

  build() {
    Column() {
      this.content()
    }
    .padding(14)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
export struct SectionHeader {
  @Prop title: string = ''
  @Prop subtitle: string = ''

  build() {
    Column({ space: 4 }) {
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(THEME_TEXT_PRIMARY)
      if (this.subtitle.length > 0) {
        Text(this.subtitle)
          .fontSize(12)
          .fontColor(THEME_TEXT_SECONDARY)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }
}

@Component
export struct PrimaryActionButton {
  @Prop label: string = '确认'
  @Prop disabled: boolean = false
  onPress: () => void = EmptyAction

  build() {
    Button(this.label)
      .enabled(!this.disabled)
      .onClick(() => this.onPress())
      .width('100%')
      .height(44)
      .borderRadius(RADIUS_PILL)
      .backgroundColor(this.disabled ? '#B8CCE8' : THEME_PRIMARY)
      .fontColor(Color.White)
      .fontWeight(FontWeight.Medium)
      .shadow(SHADOW_CARD)
  }
}

@Component
export struct StatusBadge {
  @Prop label: string = ''
  @Prop tone: BadgeTone = 'neutral'

  build() {
    Text(this.label)
      .fontSize(11)
      .fontWeight(FontWeight.Medium)
      .fontColor(toneTextColor(this.tone))
      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
      .backgroundColor(toneBackgroundColor(this.tone))
      .borderRadius(RADIUS_PILL)
  }
}

@Component
export struct EmptyStateCard {
  @Prop message: string = '暂无数据'

  build() {
    Column({ space: 6 }) {
      Text('暂无内容')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(THEME_TEXT_PRIMARY)
      Text(this.message)
        .fontSize(12)
        .fontColor(THEME_TEXT_SECONDARY)
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .padding(20)
    .width('100%')
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_LG)
    .border({ width: 1, color: THEME_BORDER_SOFT })
  }
}

@Component
export struct TimelineNode {
  @Prop title: string = ''
  @Prop detail: string = ''
  @Prop timeText: string = ''
  @Prop active: boolean = false
  @Prop completed: boolean = false

  private dotColor(): string {
    if (this.completed) {
      return THEME_PRIMARY
    }
    if (this.active) {
      return '#5C8CFF'
    }
    return '#D0D9E8'
  }

  build() {
    Row({ space: 10 }) {
      Column({ space: 2 }) {
        Row()
          .width(12)
          .height(12)
          .backgroundColor(this.dotColor())
          .borderRadius(RADIUS_PILL)
        if (!this.completed && !this.active) {
          Column()
            .width(2)
            .height(28)
            .backgroundColor('#DCE4F2')
        } else {
          Column()
            .width(2)
            .height(28)
            .backgroundColor('#A6C3F8')
        }
      }
      .alignItems(HorizontalAlign.Center)

      Column({ space: 2 }) {
        Text(this.title)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(THEME_TEXT_PRIMARY)
        if (this.detail.length > 0) {
          Text(this.detail)
            .fontSize(11)
            .fontColor(THEME_TEXT_SECONDARY)
            .maxLines(2)
        }
        if (this.timeText.length > 0) {
          Text(this.timeText)
            .fontSize(10)
            .fontColor('#9AA7BD')
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
  }
}

@Component
export struct FilterChip {
  @Prop label: string = ''
  @Prop selected: boolean = false
  onToggle: () => void = EmptyAction

  build() {
    Button(this.label)
      .onClick(() => this.onToggle())
      .height(34)
      .padding({ left: 14, right: 14 })
      .borderRadius(RADIUS_PILL)
      .fontSize(12)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.selected ? Color.White : THEME_TEXT_SECONDARY)
      .backgroundColor(this.selected ? THEME_PRIMARY : '#EEF3FA')
  }
}
