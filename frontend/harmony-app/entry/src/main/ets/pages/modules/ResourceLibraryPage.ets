import {
  RADIUS_LG,
  RADIUS_MD,
  RADIUS_PILL,
  SHADOW_CARD,
  SHADOW_PANEL,
  THEME_DANGER,
  THEME_PAGE_BG,
  THEME_PRIMARY,
  THEME_PRIMARY_SOFT,
  THEME_SUCCESS,
  THEME_SURFACE,
  THEME_SURFACE_MUTED,
  THEME_TEXT_PRIMARY,
  THEME_TEXT_SECONDARY,
  THEME_TEXT_TERTIARY
} from '../../common/ui/AppTheme'

type ResourceCategory = 'SCENIC' | 'ROUTE' | 'DINING' | 'SHOW'
type ResourceScreen = 'LIST' | 'FORM'

class ResourceCategoryOption {
  key: ResourceCategory
  title: string
  icon: string
  accentColor: string
  accentBg: string

  constructor(key: ResourceCategory, title: string, icon: string, accentColor: string, accentBg: string) {
    this.key = key
    this.title = title
    this.icon = icon
    this.accentColor = accentColor
    this.accentBg = accentBg
  }
}

class ResourceLibraryItem {
  id: string
  category: ResourceCategory
  title: string
  subtitle: string
  schedule: string
  description: string
  imageUrl: string
  online: boolean

  constructor(
    id: string,
    category: ResourceCategory,
    title: string,
    subtitle: string,
    schedule: string,
    description: string,
    imageUrl: string,
    online: boolean
  ) {
    this.id = id
    this.category = category
    this.title = title
    this.subtitle = subtitle
    this.schedule = schedule
    this.description = description
    this.imageUrl = imageUrl
    this.online = online
  }
}

@Component
export struct ResourceLibraryPage {
  @State private screen: ResourceScreen = 'LIST'
  @State private selectedCategory: ResourceCategory = 'SCENIC'
  @State private searchQuery: string = ''
  @State private editingId: string = ''
  @State private titleInput: string = ''
  @State private subtitleInput: string = ''
  @State private scheduleInput: string = ''
  @State private descriptionInput: string = ''
  @State private imageUrlInput: string = ''
  @State private onlineInput: boolean = true
  @State private actionMessage: string = ''

  private categoryOptions: ResourceCategoryOption[] = [
    new ResourceCategoryOption('SCENIC', '景区景点', '🗺', THEME_PRIMARY, THEME_PRIMARY_SOFT),
    new ResourceCategoryOption('ROUTE', '游览线路', '➤', THEME_SUCCESS, '#EAF8EF'),
    new ResourceCategoryOption('DINING', '餐饮娱乐', '🍴', '#EA580C', '#FFF4E6'),
    new ResourceCategoryOption('SHOW', '演出团体', '♪', '#7C3AED', '#F3E8FF')
  ]

  @State private items: ResourceLibraryItem[] = [
    new ResourceLibraryItem(
      'RES-001',
      'SCENIC',
      '北欧小木屋风情区',
      '景区北侧麦温带植物林',
      '08:00 - 18:00',
      '还原北欧森林木屋风情，适合拍照打卡，周边有驯鹿互动区。',
      'https://images.unsplash.com/photo-1510798831971-661eb04b3739?auto=format&fit=crop&w=600&q=80',
      true
    ),
    new ResourceLibraryItem(
      'RES-002',
      'ROUTE',
      '亲子一日游（东线）',
      '东大门 -> 湖畔 -> 游乐场 -> 美食城',
      '建议时长：6-8 小时',
      '专为带儿童的家庭设计，地势平缓，沿途洗手间及休息区密集。',
      'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?auto=format&fit=crop&w=600&q=80',
      true
    ),
    new ResourceLibraryItem(
      'RES-003',
      'DINING',
      '湖畔全景星空餐厅',
      '东区观景台旁',
      '11:00 - 22:00',
      '提供中西融合菜系，360 度全景玻璃房，目前正进行内部升级装修。',
      'https://images.unsplash.com/photo-1552566626-52f8b828add9?auto=format&fit=crop&w=600&q=80',
      false
    ),
    new ResourceLibraryItem(
      'RES-004',
      'SHOW',
      '大型实景剧《幻梦森林》',
      '中央水上剧场',
      '每日 19:30 - 21:00',
      '结合声光电的大型沉浸式实景演出，讲述森林精灵的传说。',
      'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?auto=format&fit=crop&w=600&q=80',
      true
    )
  ]

  private searchPlaceholder(): string {
    if (this.selectedCategory === 'ROUTE') {
      return '搜索游览线路名称...'
    }
    if (this.selectedCategory === 'DINING') {
      return '搜索餐饮娱乐名称...'
    }
    if (this.selectedCategory === 'SHOW') {
      return '搜索演出团体名称...'
    }
    return '搜索景区景点名称...'
  }

  private createButtonText(): string {
    if (this.selectedCategory === 'ROUTE') {
      return '+  新增游览线路'
    }
    if (this.selectedCategory === 'DINING') {
      return '+  新增餐饮娱乐'
    }
    if (this.selectedCategory === 'SHOW') {
      return '+  新增演出团体'
    }
    return '+  新增景区景点'
  }

  private saveButtonText(): string {
    return this.editingId.length > 0 ? '保存修改' : '新增资源'
  }

  private filteredItems(): ResourceLibraryItem[] {
    const keyword: string = this.searchQuery.trim().toLowerCase()
    return this.items.filter((item: ResourceLibraryItem) => {
      if (item.category !== this.selectedCategory) {
        return false
      }
      if (keyword.length === 0) {
        return true
      }
      return item.title.toLowerCase().includes(keyword)
        || item.subtitle.toLowerCase().includes(keyword)
        || item.description.toLowerCase().includes(keyword)
    })
  }

  private categoryScale(key: ResourceCategory): number {
    return this.selectedCategory === key ? 1 : 0.985
  }

  private categoryBg(key: ResourceCategory): string {
    return this.selectedCategory === key ? THEME_PRIMARY : THEME_SURFACE
  }

  private categoryTextColor(key: ResourceCategory): string {
    return this.selectedCategory === key ? '#FFFFFF' : THEME_TEXT_PRIMARY
  }

  private categoryIconBg(item: ResourceCategoryOption): string {
    return this.selectedCategory === item.key ? '#FFFFFF22' : item.accentBg
  }

  private categoryIconColor(item: ResourceCategoryOption): string {
    return this.selectedCategory === item.key ? '#FFFFFF' : item.accentColor
  }

  private locationLabel(): string {
    if (this.selectedCategory === 'ROUTE') {
      return '路线内容 / 途经点'
    }
    if (this.selectedCategory === 'DINING') {
      return '店铺位置'
    }
    if (this.selectedCategory === 'SHOW') {
      return '演出场地'
    }
    return '景点位置'
  }

  private scheduleLabel(): string {
    if (this.selectedCategory === 'ROUTE') {
      return '建议时长'
    }
    if (this.selectedCategory === 'SHOW') {
      return '演出时间'
    }
    return '开放时间'
  }

  private descriptionLabel(): string {
    if (this.selectedCategory === 'ROUTE') {
      return '线路亮点'
    }
    if (this.selectedCategory === 'DINING') {
      return '店铺简介'
    }
    if (this.selectedCategory === 'SHOW') {
      return '演出简介'
    }
    return '景点简介'
  }

  private imageHint(): string {
    if (this.imageUrlInput.trim().length > 0) {
      return '已填写封面图链接，可继续替换'
    }
    return '填写封面图链接，或后续接入图片上传接口'
  }

  private isFormValid(): boolean {
    return this.titleInput.trim().length > 0
      && this.subtitleInput.trim().length > 0
      && this.scheduleInput.trim().length > 0
      && this.descriptionInput.trim().length > 0
  }

  private switchCategory(key: ResourceCategory): void {
    this.selectedCategory = key
    this.searchQuery = ''
    this.actionMessage = ''
    if (this.screen === 'FORM' && this.editingId.length === 0) {
      this.selectedCategory = key
    }
  }

  private startCreate(): void {
    this.screen = 'FORM'
    this.editingId = ''
    this.titleInput = ''
    this.subtitleInput = ''
    this.scheduleInput = ''
    this.descriptionInput = ''
    this.imageUrlInput = ''
    this.onlineInput = true
    this.actionMessage = ''
  }

  private startEdit(id: string): void {
    const target: ResourceLibraryItem | null = this.findItemById(id)
    if (target === null) {
      return
    }
    this.selectedCategory = target.category
    this.screen = 'FORM'
    this.editingId = target.id
    this.titleInput = target.title
    this.subtitleInput = target.subtitle
    this.scheduleInput = target.schedule
    this.descriptionInput = target.description
    this.imageUrlInput = target.imageUrl
    this.onlineInput = target.online
    this.actionMessage = ''
  }

  private cancelForm(): void {
    this.screen = 'LIST'
    this.editingId = ''
    this.actionMessage = ''
  }

  private findItemById(id: string): ResourceLibraryItem | null {
    const target: ResourceLibraryItem | undefined = this.items.find((item: ResourceLibraryItem) => item.id === id)
    return target === undefined ? null : target
  }

  private nextId(): string {
    return `RES-${(this.items.length + 1).toString().padStart(3, '0')}`
  }

  private resolvedImageUrl(): string {
    if (this.imageUrlInput.trim().length > 0) {
      return this.imageUrlInput.trim()
    }
    if (this.selectedCategory === 'ROUTE') {
      return 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=600&q=80'
    }
    if (this.selectedCategory === 'DINING') {
      return 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80'
    }
    if (this.selectedCategory === 'SHOW') {
      return 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=600&q=80'
    }
    return 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=600&q=80'
  }

  private saveForm(): void {
    if (!this.isFormValid()) {
      this.actionMessage = '请先补全标题、位置、时间和简介信息'
      return
    }

    if (this.editingId.length > 0) {
      this.items = this.items.map((item: ResourceLibraryItem) => {
        if (item.id === this.editingId) {
          return new ResourceLibraryItem(
            item.id,
            this.selectedCategory,
            this.titleInput.trim(),
            this.subtitleInput.trim(),
            this.scheduleInput.trim(),
            this.descriptionInput.trim(),
            this.resolvedImageUrl(),
            this.onlineInput
          )
        }
        return item
      })
      this.actionMessage = '资源信息已更新'
    } else {
      this.items = [
        new ResourceLibraryItem(
          this.nextId(),
          this.selectedCategory,
          this.titleInput.trim(),
          this.subtitleInput.trim(),
          this.scheduleInput.trim(),
          this.descriptionInput.trim(),
          this.resolvedImageUrl(),
          this.onlineInput
        ),
        ...this.items
      ]
      this.actionMessage = '新资源已加入资源库'
    }

    this.screen = 'LIST'
    this.editingId = ''
  }

  private toggleOnline(id: string): void {
    this.items = this.items.map((item: ResourceLibraryItem) => {
      if (item.id === id) {
        return new ResourceLibraryItem(
          item.id,
          item.category,
          item.title,
          item.subtitle,
          item.schedule,
          item.description,
          item.imageUrl,
          !item.online
        )
      }
      return item
    })
    this.actionMessage = '资源展示状态已更新'
  }

  private deleteItem(id: string): void {
    this.items = this.items.filter((item: ResourceLibraryItem) => item.id !== id)
    this.actionMessage = '资源已移出当前资源库'
  }

  private onlineBadgeText(item: ResourceLibraryItem): string {
    return item.online ? '已上架' : '已下架'
  }

  private onlineBadgeBg(item: ResourceLibraryItem): string {
    return item.online ? THEME_SUCCESS : THEME_TEXT_TERTIARY
  }

  private actionButtonText(item: ResourceLibraryItem): string {
    return item.online ? '下架隐藏' : '重新上架'
  }

  private actionButtonColor(item: ResourceLibraryItem): string {
    return item.online ? '#EA580C' : THEME_SUCCESS
  }

  private actionButtonBg(item: ResourceLibraryItem): string {
    return item.online ? '#FFF4E6' : '#EAF8EF'
  }

  private cardBorderColor(item: ResourceLibraryItem): string {
    return item.online ? '#F0F3F9' : '#D9E0EB'
  }

  private cardImageOpacity(item: ResourceLibraryItem): number {
    return item.online ? 1 : 0.72
  }

  @Builder
  private CategorySwitcher(): void {
    Row({ space: 10 }) {
      ForEach(this.categoryOptions, (item: ResourceCategoryOption) => {
        Button() {
          Column({ space: 10 }) {
            Text(item.icon)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.categoryIconColor(item))
              .textAlign(TextAlign.Center)
              .width(38)
              .height(38)
              .backgroundColor(this.categoryIconBg(item))
              .borderRadius(RADIUS_PILL)
            Text(item.title)
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.categoryTextColor(item.key))
              .textAlign(TextAlign.Center)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .height(84)
        .padding({ left: 8, right: 8, top: 10, bottom: 10 })
        .borderRadius(22)
        .backgroundColor(this.categoryBg(item.key))
        .shadow(this.selectedCategory === item.key ? SHADOW_PANEL : SHADOW_CARD)
        .scale({ x: this.categoryScale(item.key), y: this.categoryScale(item.key) })
        .onClick(() => this.switchCategory(item.key))
      }, (item: ResourceCategoryOption) => item.key)
    }
    .width('100%')
  }

  @Builder
  private SearchBar(): void {
    Row({ space: 10 }) {
      Text('⌕')
        .fontSize(15)
        .fontColor(THEME_TEXT_TERTIARY)
      TextInput({ placeholder: this.searchPlaceholder(), text: this.searchQuery })
        .placeholderColor(THEME_TEXT_TERTIARY)
        .backgroundColor(Color.Transparent)
        .fontSize(14)
        .layoutWeight(1)
        .onChange((value: string) => {
          this.searchQuery = value
        })
    }
    .width('100%')
    .height(48)
    .padding({ left: 16, right: 16 })
    .backgroundColor(THEME_SURFACE)
    .borderRadius(22)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private ResourceCard(item: ResourceLibraryItem): void {
    Column({ space: 14 }) {
      Row({ space: 14 }) {
        Stack({ alignContent: Alignment.TopStart }) {
          Image(item.imageUrl)
            .width(100)
            .height(100)
            .borderRadius(22)
            .objectFit(ImageFit.Cover)
            .opacity(this.cardImageOpacity(item))
          Text(this.onlineBadgeText(item))
            .fontSize(10)
            .fontColor('#FFFFFF')
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .backgroundColor(this.onlineBadgeBg(item))
            .borderRadius(RADIUS_PILL)
            .margin({ left: 8, top: 8 })
        }

        Column({ space: 8 }) {
          Text(item.title)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(THEME_TEXT_PRIMARY)
            .width('100%')
            .maxLines(1)
          Row({ space: 8 }) {
            Text('📍')
              .fontSize(11)
            Text(item.subtitle)
              .fontSize(12)
              .fontColor(THEME_TEXT_SECONDARY)
              .layoutWeight(1)
              .maxLines(2)
          }
          .width('100%')
          Row({ space: 8 }) {
            Text('🕒')
              .fontSize(11)
            Text(item.schedule)
              .fontSize(12)
              .fontColor('#EA580C')
              .layoutWeight(1)
              .maxLines(2)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      Text(item.description)
        .fontSize(12)
        .fontColor(THEME_TEXT_SECONDARY)
        .lineHeight(19)
        .width('100%')

      Divider()
        .strokeWidth(1)
        .color('#EEF2F7')

      Row() {
        Text(item.id)
          .fontSize(11)
          .fontColor(THEME_TEXT_TERTIARY)
        Blank()
        Row({ space: 8 }) {
          Button(this.actionButtonText(item))
            .height(32)
            .padding({ left: 12, right: 12 })
            .borderRadius(RADIUS_PILL)
            .backgroundColor(this.actionButtonBg(item))
            .fontColor(this.actionButtonColor(item))
            .fontSize(11)
            .onClick(() => this.toggleOnline(item.id))
          Button('编辑')
            .height(32)
            .padding({ left: 12, right: 12 })
            .borderRadius(RADIUS_PILL)
            .backgroundColor(THEME_PRIMARY_SOFT)
            .fontColor(THEME_PRIMARY)
            .fontSize(11)
            .onClick(() => this.startEdit(item.id))
          Button('删除')
            .height(32)
            .padding({ left: 12, right: 12 })
            .borderRadius(RADIUS_PILL)
            .backgroundColor('#FFECEC')
            .fontColor(THEME_DANGER)
            .fontSize(11)
            .onClick(() => this.deleteItem(item.id))
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(15)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
    .border({ width: 1, color: this.cardBorderColor(item) })
    .opacity(item.online ? 1 : 0.94)
  }

  @Builder
  private EmptyState(): void {
    Column({ space: 8 }) {
      Text('暂无资源')
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(THEME_TEXT_PRIMARY)
      Text('当前分类下还没有匹配内容，可以直接新增并上架到游客端。')
        .fontSize(12)
        .fontColor(THEME_TEXT_SECONDARY)
        .lineHeight(19)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding({ left: 24, right: 24, top: 28, bottom: 28 })
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_LG)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private ListView(): void {
    Column() {
      Scroll() {
        Column({ space: 16 }) {
          this.CategorySwitcher()
          this.SearchBar()

          if (this.actionMessage.length > 0) {
            Text(this.actionMessage)
              .fontSize(11)
              .fontColor(THEME_SUCCESS)
              .width('100%')
          }

          if (this.filteredItems().length === 0) {
            this.EmptyState()
          } else {
            Column({ space: 14 }) {
              ForEach(this.filteredItems(), (item: ResourceLibraryItem) => {
                this.ResourceCard(item)
              }, (item: ResourceLibraryItem) => item.id)
            }
            .width('100%')
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 18, bottom: 112 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      Button(this.createButtonText())
        .width('100%')
        .height(50)
        .margin({ left: 20, right: 20, bottom: 16 })
        .borderRadius(22)
        .backgroundColor(THEME_PRIMARY)
        .fontColor('#FFFFFF')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .shadow(SHADOW_PANEL)
        .onClick(() => this.startCreate())
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private FormHeader(): void {
    Row() {
      Column({ space: 4 }) {
        Text(this.editingId.length > 0 ? '编辑资源内容' : '新增资源内容')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
        Text('平台端图文内容管理表单')
          .fontSize(11)
          .fontColor(THEME_TEXT_SECONDARY)
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      Button('返回列表')
        .height(32)
        .padding({ left: 12, right: 12 })
        .borderRadius(RADIUS_PILL)
        .backgroundColor(THEME_PRIMARY_SOFT)
        .fontColor(THEME_PRIMARY)
        .fontSize(11)
        .onClick(() => this.cancelForm())
    }
    .width('100%')
  }

  @Builder
  private FormCategorySelector(): void {
    Row({ space: 10 }) {
      ForEach(this.categoryOptions, (item: ResourceCategoryOption) => {
        Button(item.title)
          .layoutWeight(1)
          .height(38)
          .borderRadius(RADIUS_PILL)
          .backgroundColor(this.selectedCategory === item.key ? THEME_PRIMARY : THEME_SURFACE_MUTED)
          .fontColor(this.selectedCategory === item.key ? '#FFFFFF' : THEME_TEXT_SECONDARY)
          .fontSize(11)
          .onClick(() => this.switchCategory(item.key))
      }, (item: ResourceCategoryOption) => item.key)
    }
    .width('100%')
  }

  @Builder
  private FormField(label: string, placeholder: string, value: string, onChange: (value: string) => void): void {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(12)
        .fontColor(THEME_TEXT_SECONDARY)
        .width('100%')
      TextInput({ placeholder, text: value })
        .onChange(onChange)
        .height(44)
        .padding(12)
        .backgroundColor(THEME_SURFACE_MUTED)
        .borderRadius(RADIUS_PILL)
        .border({ width: 1, color: '#E7ECF3' })
    }
    .width('100%')
  }

  @Builder
  private FormTextArea(): void {
    Column({ space: 8 }) {
      Text(this.descriptionLabel())
        .fontSize(12)
        .fontColor(THEME_TEXT_SECONDARY)
        .width('100%')
      TextArea({ placeholder: '请输入资源简介与对游客端展示的说明文案', text: this.descriptionInput })
        .onChange((value: string) => {
          this.descriptionInput = value
        })
        .height(112)
        .padding(14)
        .backgroundColor(THEME_SURFACE_MUTED)
        .borderRadius(RADIUS_MD)
        .border({ width: 1, color: '#E7ECF3' })
    }
    .width('100%')
  }

  @Builder
  private CoverUploadCard(): void {
    Column({ space: 10 }) {
      Text('封面图')
        .fontSize(12)
        .fontColor(THEME_TEXT_SECONDARY)
        .width('100%')
      Column({ space: 8 }) {
        Text('上传 / 填写封面图链接')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
        Text(this.imageHint())
          .fontSize(11)
          .fontColor(THEME_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .lineHeight(18)
      }
      .width('100%')
      .height(144)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(THEME_SURFACE_MUTED)
      .borderRadius(RADIUS_LG)
      .border({ width: 1, color: '#E7ECF3' })

      TextInput({ placeholder: '封面图链接（可选）', text: this.imageUrlInput })
        .onChange((value: string) => {
          this.imageUrlInput = value
        })
        .height(44)
        .padding(12)
        .backgroundColor(THEME_SURFACE)
        .borderRadius(RADIUS_PILL)
        .border({ width: 1, color: '#E7ECF3' })
    }
    .width('100%')
  }

  @Builder
  private PublishSwitchCard(): void {
    Row() {
      Column({ space: 6 }) {
        Text('立即上架至游客端')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)
        Text('关闭后保留在资源库中，仅平台管理员可见')
          .fontSize(11)
          .fontColor(THEME_TEXT_SECONDARY)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Button(this.onlineInput ? '已上架' : '先存为下架')
        .height(34)
        .padding({ left: 12, right: 12 })
        .borderRadius(RADIUS_PILL)
        .backgroundColor(this.onlineInput ? THEME_PRIMARY : THEME_SURFACE_MUTED)
        .fontColor(this.onlineInput ? '#FFFFFF' : THEME_TEXT_SECONDARY)
        .fontSize(11)
        .onClick(() => {
          this.onlineInput = !this.onlineInput
        })
    }
    .width('100%')
    .padding(14)
    .backgroundColor(THEME_SURFACE)
    .borderRadius(RADIUS_MD)
    .shadow(SHADOW_CARD)
  }

  @Builder
  private FormActions(): void {
    Row({ space: 12 }) {
      Button('取消')
        .layoutWeight(1)
        .height(44)
        .borderRadius(RADIUS_PILL)
        .backgroundColor(THEME_SURFACE_MUTED)
        .fontColor(THEME_TEXT_SECONDARY)
        .fontSize(12)
        .onClick(() => this.cancelForm())
      Button(this.saveButtonText())
        .layoutWeight(1)
        .height(44)
        .borderRadius(RADIUS_PILL)
        .backgroundColor(THEME_PRIMARY)
        .fontColor('#FFFFFF')
        .fontSize(12)
        .enabled(this.isFormValid())
        .opacity(this.isFormValid() ? 1 : 0.6)
        .onClick(() => this.saveForm())
    }
    .width('100%')
  }

  @Builder
  private FormView(): void {
    Scroll() {
      Column({ space: 16 }) {
        this.FormHeader()
        this.CoverUploadCard()
        this.FormCategorySelector()
        this.FormField('标题名称', '请输入标题名称', this.titleInput, (value: string) => {
          this.titleInput = value
        })
        this.FormField(this.locationLabel(), '请输入位置 / 路线 / 场馆信息', this.subtitleInput, (value: string) => {
          this.subtitleInput = value
        })
        this.FormField(this.scheduleLabel(), '请输入开放时间 / 建议时长 / 演出时间', this.scheduleInput, (value: string) => {
          this.scheduleInput = value
        })
        this.FormTextArea()
        this.PublishSwitchCard()
        if (this.actionMessage.length > 0) {
          Text(this.actionMessage)
            .fontSize(11)
            .fontColor(this.actionMessage.startsWith('请') ? THEME_DANGER : THEME_SUCCESS)
            .width('100%')
        }
        this.FormActions()
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 18, bottom: 30 })
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
  }

  build() {
    Column() {
      if (this.screen === 'LIST') {
        this.ListView()
      } else {
        this.FormView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(THEME_PAGE_BG)
  }
}
