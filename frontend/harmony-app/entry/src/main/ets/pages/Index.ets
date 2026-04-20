import { AuthStore } from '../common/state/AuthStore'
import { UserRole } from '../common/model/ApiModels'
import { ComplaintPage, ComplaintMode } from './modules/ComplaintPage'
import { EmergencyPage, EmergencyMode } from './modules/EmergencyPage'
import { HotelPage, HotelMode } from './modules/HotelPage'
import { ScenicRoutePage } from './modules/ScenicRoutePage'
import { DiningShowPage } from './modules/DiningShowPage'
import { WeatherTrafficPage } from './modules/WeatherTrafficPage'
import { VisitorHomePage } from './modules/VisitorHomePage'
import { VisitorServiceTab, VisitorServicesPage } from './modules/VisitorServicesPage'
import {
  RADIUS_LG,
  RADIUS_MD,
  RADIUS_PILL,
  SHADOW_CARD,
  SHADOW_PANEL,
  THEME_BORDER_SOFT,
  THEME_PAGE_BG,
  THEME_PRIMARY,
  THEME_PRIMARY_SOFT,
  THEME_SURFACE,
  THEME_SURFACE_MUTED,
  THEME_TEXT_PRIMARY,
  THEME_TEXT_SECONDARY,
  THEME_TEXT_TERTIARY
} from '../common/ui/AppTheme'

type AuthMode = 'login' | 'register' | 'reset'
type VisitorNav = 'home' | 'services' | 'complaint' | 'emergency'

interface TabItem {
  key: string
  title: string
}

interface VisitorNavItem {
  key: VisitorNav
  icon: string
  title: string
}

@Entry
@Component
struct Index {
  @State private selectedTabKey: string = ''
  @State private authMode: AuthMode = 'login'
  @State private visitorNav: VisitorNav = 'home'
  @State private visitorServiceTab: VisitorServiceTab = 'routes'

  @State private username: string = 'visitor'
  @State private password: string = 'visitor123'
  @State private displayName: string = ''
  @State private resetCode: string = ''
  @State private newPassword: string = ''

  @State private authStore: AuthStore = new AuthStore()

  private visitorNavItems: VisitorNavItem[] = [
    { key: 'home', icon: '🏠', title: '首页' },
    { key: 'services', icon: '🧭', title: '服务' },
    { key: 'complaint', icon: '💬', title: '投诉' },
    { key: 'emergency', icon: '🚨', title: '应急' }
  ]

  private switchAuthMode(mode: AuthMode): void {
    this.authMode = mode
    this.authStore.errorMessage = ''
    this.authStore.infoMessage = ''
    this.resetCode = ''
    this.newPassword = ''
  }

  private async doLogin(): Promise<void> {
    const ok: boolean = await this.authStore.login({ username: this.username, password: this.password })
    if (ok) {
      const tabs: TabItem[] = this.getRoleTabs()
      this.selectedTabKey = tabs.length > 0 ? tabs[0].key : ''
      this.visitorNav = 'home'
      this.visitorServiceTab = 'routes'
    }
  }

  private async doRegister(): Promise<void> {
    const ok: boolean = await this.authStore.register({
      username: this.username,
      password: this.password,
      displayName: this.displayName.trim().length > 0 ? this.displayName : this.username
    })
    if (ok) {
      this.switchAuthMode('login')
    }
  }

  private async requestCode(): Promise<void> {
    await this.authStore.requestResetCode({ username: this.username })
  }

  private async doResetPassword(): Promise<void> {
    const ok: boolean = await this.authStore.resetPassword({
      username: this.username,
      code: this.resetCode,
      newPassword: this.newPassword
    })
    if (ok) {
      this.password = this.newPassword
      this.switchAuthMode('login')
    }
  }

  private isVisitor(): boolean {
    return this.authStore.getRole() === 'VISITOR'
  }

  private tabsForRole(role: UserRole): TabItem[] {
    switch (role) {
      case 'VISITOR':
        return [
          { key: 'complaint-visitor', title: '我的投诉' },
          { key: 'emergency-visitor', title: '应急信息' },
          { key: 'hotel-visitor', title: '酒店查询' },
          { key: 'scenic', title: '景区与线路' },
          { key: 'dining', title: '餐饮娱乐演出' },
          { key: 'weather', title: '天气与路况' }
        ]
      case 'COMPLAINT_HANDLER':
        return [{ key: 'complaint-handler', title: '投诉处理' }]
      case 'EMERGENCY_WRITER':
        return [{ key: 'emergency-writer', title: '应急发布' }]
      case 'APPROVER':
        return [
          { key: 'complaint-approver', title: '投诉审批' },
          { key: 'emergency-approver', title: '应急审批' }
        ]
      case 'HOTEL_MANAGER':
        return [{ key: 'hotel-manager', title: '酒店管理' }]
      case 'SYSTEM_ADMIN':
      case 'ADMIN':
        return [
          { key: 'complaint-admin', title: '投诉管理' },
          { key: 'emergency-admin', title: '应急管理' },
          { key: 'hotel-admin', title: '酒店管理' },
          { key: 'scenic', title: '景区与线路' },
          { key: 'dining', title: '餐饮娱乐演出' },
          { key: 'weather', title: '天气与路况' }
        ]
      default:
        return [{ key: 'complaint-visitor', title: '我的投诉' }]
    }
  }

  private getRoleTabs(): TabItem[] {
    return this.tabsForRole(this.authStore.getRole())
  }

  private getSafeSelectedTabKey(): string {
    const tabs: TabItem[] = this.getRoleTabs()
    if (tabs.length === 0) {
      return ''
    }
    const exists: boolean = tabs.some((tab: TabItem) => tab.key === this.selectedTabKey)
    if (!exists) {
      return tabs[0].key
    }
    return this.selectedTabKey
  }

  private isTabSelected(key: string): boolean {
    return this.getSafeSelectedTabKey() === key
  }

  private isVisitorNavSelected(key: VisitorNav): boolean {
    return this.visitorNav === key
  }

  private switchTab(key: string): void {
    if (this.selectedTabKey === key) {
      return
    }
    animateTo({ duration: 220, curve: Curve.EaseInOut }, () => {
      this.selectedTabKey = key
    })
  }

  private switchVisitorNav(key: VisitorNav): void {
    if (this.visitorNav === key) {
      return
    }
    animateTo({ duration: 220, curve: Curve.EaseInOut }, () => {
      this.visitorNav = key
    })
  }

  private complaintModeByKey(key: string): ComplaintMode {
    if (key === 'complaint-handler') {
      return 'handler'
    }
    if (key === 'complaint-approver') {
      return 'approver'
    }
    if (key === 'complaint-admin') {
      return 'admin'
    }
    return 'visitor'
  }

  private emergencyModeByKey(key: string): EmergencyMode {
    if (key === 'emergency-writer') {
      return 'writer'
    }
    if (key === 'emergency-approver') {
      return 'approver'
    }
    if (key === 'emergency-admin') {
      return 'admin'
    }
    return 'visitor'
  }

  private hotelModeByKey(key: string): HotelMode {
    if (key === 'hotel-manager') {
      return 'manager'
    }
    if (key === 'hotel-admin') {
      return 'admin'
    }
    return 'visitor'
  }

  @Builder
  private AuthModeSwitch(): void {
    Row({ space: 8 }) {
      Button('登录')
        .onClick(() => this.switchAuthMode('login'))
        .backgroundColor(this.authMode === 'login' ? THEME_PRIMARY : '#EAF2FF')
        .fontColor(this.authMode === 'login' ? Color.White : THEME_TEXT_SECONDARY)
        .borderRadius(RADIUS_PILL)
        .layoutWeight(1)
      Button('注册')
        .onClick(() => this.switchAuthMode('register'))
        .backgroundColor(this.authMode === 'register' ? THEME_PRIMARY : '#EAF2FF')
        .fontColor(this.authMode === 'register' ? Color.White : THEME_TEXT_SECONDARY)
        .borderRadius(RADIUS_PILL)
        .layoutWeight(1)
      Button('找回密码')
        .onClick(() => this.switchAuthMode('reset'))
        .backgroundColor(this.authMode === 'reset' ? THEME_PRIMARY : '#EAF2FF')
        .fontColor(this.authMode === 'reset' ? Color.White : THEME_TEXT_SECONDARY)
        .borderRadius(RADIUS_PILL)
        .layoutWeight(1)
    }
    .padding(4)
    .backgroundColor('#F4F7FD')
    .borderRadius(RADIUS_PILL)
  }

  @Builder
  private LoginView(): void {
    Column({ space: 10 }) {
      Column({ space: 16 }) {
        Text('游客服务系统')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor(THEME_TEXT_PRIMARY)

        Text('极简、清晰、可信赖的旅途服务平台')
          .fontSize(12)
          .fontColor(THEME_TEXT_TERTIARY)

        this.AuthModeSwitch()

        TextInput({ placeholder: '账号', text: this.username })
          .onChange((value: string) => {
            this.username = value
          })
          .padding(12)
          .borderRadius(RADIUS_MD)
          .backgroundColor(THEME_SURFACE)
          .border({ width: 1, color: THEME_BORDER_SOFT })
          .width('100%')

        if (this.authMode === 'register') {
          TextInput({ placeholder: '昵称（可选）', text: this.displayName })
            .onChange((value: string) => {
              this.displayName = value
            })
            .padding(12)
            .borderRadius(RADIUS_MD)
            .backgroundColor(THEME_SURFACE)
            .border({ width: 1, color: THEME_BORDER_SOFT })
            .width('100%')
        }

        if (this.authMode !== 'reset') {
          TextInput({ placeholder: '密码', text: this.password })
            .type(InputType.Password)
            .onChange((value: string) => {
              this.password = value
            })
            .padding(12)
            .borderRadius(RADIUS_MD)
            .backgroundColor(THEME_SURFACE)
            .border({ width: 1, color: THEME_BORDER_SOFT })
            .width('100%')
        }

        if (this.authMode === 'reset') {
          Row({ space: 8 }) {
            Button('获取验证码')
              .enabled(!this.authStore.loading)
              .onClick(() => {
                this.requestCode()
              })
              .layoutWeight(1)
              .height(42)
              .borderRadius(RADIUS_PILL)
              .backgroundColor('#EAF2FF')
              .fontColor(THEME_PRIMARY)
          }

          TextInput({ placeholder: '验证码（6位）', text: this.resetCode })
            .onChange((value: string) => {
              this.resetCode = value
            })
            .padding(12)
            .borderRadius(RADIUS_MD)
            .backgroundColor(THEME_SURFACE)
            .border({ width: 1, color: THEME_BORDER_SOFT })
            .width('100%')

          TextInput({ placeholder: '新密码', text: this.newPassword })
            .type(InputType.Password)
            .onChange((value: string) => {
              this.newPassword = value
            })
            .padding(12)
            .borderRadius(RADIUS_MD)
            .backgroundColor(THEME_SURFACE)
            .border({ width: 1, color: THEME_BORDER_SOFT })
            .width('100%')
        }

        Button(this.authStore.loading ? '处理中...' : this.authMode === 'login' ? '登录' : this.authMode === 'register' ? '注册' : '重置密码')
          .enabled(!this.authStore.loading)
          .onClick(() => {
            if (this.authMode === 'login') {
              this.doLogin()
            } else if (this.authMode === 'register') {
              this.doRegister()
            } else {
              this.doResetPassword()
            }
          })
          .width('100%')
          .height(44)
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_PRIMARY)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .shadow(SHADOW_CARD)

        if (this.authStore.errorMessage.length > 0) {
          Text(this.authStore.errorMessage).fontColor('#B42318').fontSize(12)
        }
        if (this.authStore.infoMessage.length > 0) {
          Text(this.authStore.infoMessage).fontColor('#0F8A43').fontSize(12)
        }

        Text('演示账号：visitor/admin/handler/writer/approver/hoteladmin/sysadmin')
          .fontSize(11)
          .fontColor(THEME_TEXT_TERTIARY)
      }
      .width('90%')
      .padding(26)
      .backgroundColor(THEME_SURFACE)
      .borderRadius(RADIUS_LG)
      .shadow(SHADOW_PANEL)
    }
    .padding(20)
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(THEME_PAGE_BG)
  }

  @Builder
  private VisitorShellView(): void {
    Column({ space: 10 }) {
      Row() {
        Column({ space: 2 }) {
          Text(`欢迎你，${this.authStore.currentUser?.displayName ?? '游客'}`)
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor(THEME_TEXT_PRIMARY)
          Text('游客模式')
            .fontSize(12)
            .fontColor(THEME_TEXT_SECONDARY)
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Button('退出登录')
          .height(34)
          .padding({ left: 14, right: 14 })
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_PRIMARY_SOFT)
          .fontColor(THEME_PRIMARY)
          .onClick(() => this.authStore.logout())
      }
      .padding(12)
      .margin({ left: 12, right: 12, top: 12 })
      .backgroundColor(THEME_SURFACE)
      .borderRadius(RADIUS_LG)
      .shadow(SHADOW_CARD)

      Column() {
        this.renderVisitorTab()
      }
      .layoutWeight(1)
      .width('100%')

      Row({ space: 8 }) {
        ForEach(this.visitorNavItems, (item: VisitorNavItem) => {
          Button(`${item.icon} ${item.title}`)
            .layoutWeight(1)
            .height(40)
            .fontSize(12)
            .fontWeight(this.isVisitorNavSelected(item.key) ? FontWeight.Medium : FontWeight.Normal)
            .fontColor(this.isVisitorNavSelected(item.key) ? Color.White : THEME_TEXT_SECONDARY)
            .backgroundColor(this.isVisitorNavSelected(item.key) ? THEME_PRIMARY : '#EEF3FA')
            .borderRadius(RADIUS_PILL)
            .onClick(() => this.switchVisitorNav(item.key))
        }, (item: VisitorNavItem) => item.key)
      }
      .padding(10)
      .margin({ left: 12, right: 12, bottom: 12 })
      .backgroundColor(THEME_SURFACE)
      .borderRadius(RADIUS_LG)
      .shadow(SHADOW_CARD)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(THEME_PAGE_BG)
  }

  @Builder
  private RoleHomeView(): void {
    Column() {
      Row({ space: 8 }) {
        Column({ space: 2 }) {
          Text(`欢迎你：${this.authStore.currentUser?.displayName ?? ''}`)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(THEME_TEXT_PRIMARY)
          Text(`当前角色：${this.authStore.getRoleLabel()}`)
            .fontSize(12)
            .fontColor(THEME_TEXT_SECONDARY)
        }.alignItems(HorizontalAlign.Start)

        Blank()

        Button('退出登录')
          .height(34)
          .padding({ left: 14, right: 14 })
          .borderRadius(RADIUS_PILL)
          .backgroundColor(THEME_PRIMARY_SOFT)
          .fontColor(THEME_PRIMARY)
          .onClick(() => this.authStore.logout())
      }
      .padding(12)
      .margin({ left: 12, right: 12, top: 12, bottom: 8 })
      .backgroundColor(THEME_SURFACE)
      .borderRadius(RADIUS_LG)
      .shadow(SHADOW_CARD)
      .width('100%')

      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.getRoleTabs(), (tab: TabItem) => {
            Button(tab.title)
              .fontSize(14)
              .fontWeight(this.isTabSelected(tab.key) ? FontWeight.Medium : FontWeight.Normal)
              .fontColor(this.isTabSelected(tab.key) ? Color.White : THEME_TEXT_SECONDARY)
              .backgroundColor(this.isTabSelected(tab.key) ? THEME_PRIMARY : '#EEF3FA')
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .borderRadius(RADIUS_PILL)
              .height(40)
              .stateEffect(true)
              .onClick(() => {
                this.switchTab(tab.key)
              })
          }, (tab: TabItem) => tab.key)
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 8 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .height(64)
      .margin({ left: 12, right: 12, bottom: 8 })
      .backgroundColor(THEME_SURFACE)
      .borderRadius(RADIUS_LG)
      .shadow(SHADOW_CARD)

      Column() {
        if (this.getRoleTabs().length > 0) {
          this.renderRoleTab(this.getSafeSelectedTabKey())
        }
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(THEME_PAGE_BG)
  }

  @Builder
  private renderVisitorTab(): void {
    if (this.visitorNav === 'home') {
      VisitorHomePage({
        displayName: this.authStore.currentUser?.displayName ?? '游客',
        navKey: this.visitorNav,
        serviceTab: this.visitorServiceTab
      })
    } else if (this.visitorNav === 'services') {
      VisitorServicesPage({ mainTab: this.visitorServiceTab })
    } else if (this.visitorNav === 'complaint') {
      ComplaintPage({ mode: 'visitor' })
    } else {
      EmergencyPage({ mode: 'visitor' })
    }
  }

  @Builder
  private renderRoleTab(key: string): void {
    if (key.startsWith('complaint')) {
      ComplaintPage({ mode: this.complaintModeByKey(key) })
    } else if (key.startsWith('emergency')) {
      EmergencyPage({ mode: this.emergencyModeByKey(key) })
    } else if (key.startsWith('hotel')) {
      HotelPage({ mode: this.hotelModeByKey(key) })
    } else if (key === 'scenic') {
      ScenicRoutePage()
    } else if (key === 'dining') {
      DiningShowPage()
    } else if (key === 'weather') {
      WeatherTrafficPage()
    }
  }

  build() {
    if (this.authStore.currentUser === null) {
      this.LoginView()
    } else if (this.isVisitor()) {
      this.VisitorShellView()
    } else {
      this.RoleHomeView()
    }
  }
}
