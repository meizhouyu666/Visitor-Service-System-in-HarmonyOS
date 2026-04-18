import { AuthStore } from '../common/state/AuthStore'
import { UserRole } from '../common/model/ApiModels'
import { ComplaintPage, ComplaintMode } from './modules/ComplaintPage'
import { EmergencyPage, EmergencyMode } from './modules/EmergencyPage'
import { HotelPage, HotelMode } from './modules/HotelPage'
import { ScenicRoutePage } from './modules/ScenicRoutePage'
import { DiningShowPage } from './modules/DiningShowPage'
import { WeatherTrafficPage } from './modules/WeatherTrafficPage'

interface TabItem {
  key: string
  title: string
}

@Entry
@Component
struct Index {
  @State private selectedTabKey: string = ''
  @State private username: string = 'visitor'
  @State private password: string = 'visitor123'
  @State private authStore: AuthStore = new AuthStore()

  private async doLogin(): Promise<void> {
    const ok: boolean = await this.authStore.login({ username: this.username, password: this.password })
    if (ok) {
      const tabs: TabItem[] = this.getRoleTabs()
      this.selectedTabKey = tabs.length > 0 ? tabs[0].key : ''
    }
  }

  private tabsForRole(role: UserRole): TabItem[] {
    switch (role) {
      case 'VISITOR':
        return [
          { key: 'complaint-visitor', title: '我的投诉' },
          { key: 'emergency-visitor', title: '应急信息' },
          { key: 'hotel-visitor', title: '酒店查询' },
          { key: 'scenic', title: '景区与线路' },
          { key: 'dining', title: '餐饮娱乐与演出' },
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
          { key: 'dining', title: '餐饮娱乐与演出' },
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
  private LoginView(): void {
    Column({ space: 10 }) {
      Column({ space: 16 }) {
        Text('游客服务系统')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')

        TextInput({ placeholder: '账号', text: this.username })
          .onChange((value: string) => {
            this.username = value
          })
          .padding(12)
          .borderRadius(8)
          .backgroundColor('#F9FAFB')
          .border({ width: 1, color: '#E5E7EB' })
          .width('100%')

        TextInput({ placeholder: '密码', text: this.password })
          .type(InputType.Password)
          .onChange((value: string) => {
            this.password = value
          })
          .padding(12)
          .borderRadius(8)
          .backgroundColor('#F9FAFB')
          .border({ width: 1, color: '#E5E7EB' })
          .width('100%')

        Button(this.authStore.loading ? '登录中...' : '登录')
          .enabled(!this.authStore.loading)
          .onClick(() => {
            this.doLogin()
          })
          .width('100%')
          .padding(12)
          .borderRadius(8)
          .backgroundColor('#3B82F6')
          .fontColor(Color.White)

        if (this.authStore.errorMessage.length > 0) {
          Text(this.authStore.errorMessage).fontColor(Color.Red).fontSize(12)
        }

        Text('演示账号：visitor/admin/handler/writer/approver/hoteladmin/sysadmin')
          .fontSize(12)
          .fontColor('#6B7280')
      }
      .width('90%')
      .padding(24)
      .backgroundColor(Color.White)
      .borderRadius(16)
    }
    .padding(20)
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F3F4F6')
  }

  @Builder
  private RoleHomeView(): void {
    Column() {
      Row({ space: 8 }) {
        Column({ space: 2 }) {
          Text(`欢迎你：${this.authStore.currentUser?.displayName ?? ''}`).fontSize(16).fontWeight(FontWeight.Medium)
          Text(`当前角色：${this.authStore.getRoleLabel()}`).fontSize(12).fontColor('#6B7280')
        }.alignItems(HorizontalAlign.Start)

        Blank()

        Button('退出登录')
          .height(30)
          .onClick(() => this.authStore.logout())
      }
      .padding(12)
      .width('100%')

      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.getRoleTabs(), (tab: TabItem) => {
            Text(tab.title)
              .fontSize(14)
              .fontColor(this.isTabSelected(tab.key) ? Color.White : '#4B5563')
              .backgroundColor(this.isTabSelected(tab.key) ? '#2563EB' : '#F3F4F6')
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .borderRadius(16)
              .onClick(() => {
                this.selectedTabKey = tab.key
              })
          }, (tab: TabItem) => tab.key)
        }
        .padding({ left: 12, right: 12, bottom: 8 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .height(52)

      Divider().height(1).color('#E5E7EB').width('100%')

      if (this.getRoleTabs().length > 0) {
        this.renderTab(this.getSafeSelectedTabKey())
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F9FAFB')
  }

  @Builder
  private renderTab(key: string): void {
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
    } else {
      this.RoleHomeView()
    }
  }
}
