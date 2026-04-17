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
  @State private selectedTab: number = 0
  @State private username: string = 'visitor'
  @State private password: string = 'visitor123'
  @State private authStore: AuthStore = new AuthStore()

  private async doLogin(): Promise<void> {
    const ok: boolean = await this.authStore.login({ username: this.username, password: this.password })
    if (ok) {
      this.selectedTab = 0
    }
  }

  private tabsForRole(role: UserRole): TabItem[] {
    switch (role) {
      case 'VISITOR':
        return [
          { key: 'complaint-visitor', title: 'Complaints' },
          { key: 'emergency-visitor', title: 'Emergency' },
          { key: 'hotel-visitor', title: 'Hotels' },
          { key: 'scenic', title: 'Scenic & Routes' },
          { key: 'dining', title: 'Dining & Shows' },
          { key: 'weather', title: 'Weather & Traffic' }
        ]
      case 'COMPLAINT_HANDLER':
        return [{ key: 'complaint-handler', title: 'Complaint Handling' }]
      case 'EMERGENCY_WRITER':
        return [{ key: 'emergency-writer', title: 'Emergency Drafting' }]
      case 'APPROVER':
        return [
          { key: 'complaint-approver', title: 'Complaint Approval' },
          { key: 'emergency-approver', title: 'Emergency Approval' }
        ]
      case 'HOTEL_MANAGER':
        return [{ key: 'hotel-manager', title: 'Hotel Management' }]
      case 'SYSTEM_ADMIN':
      case 'ADMIN':
        return [
          { key: 'complaint-admin', title: 'Complaint Admin' },
          { key: 'emergency-admin', title: 'Emergency Admin' },
          { key: 'hotel-admin', title: 'Hotel Admin' },
          { key: 'scenic', title: 'Scenic & Routes' },
          { key: 'dining', title: 'Dining & Shows' },
          { key: 'weather', title: 'Weather & Traffic' }
        ]
      default:
        return [{ key: 'complaint-visitor', title: 'Complaints' }]
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
    if (this.selectedTab < 0 || this.selectedTab >= tabs.length) {
      return tabs[0].key
    }
    return tabs[this.selectedTab].key
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
        Text('Visitor Service System')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')

        TextInput({ placeholder: 'Username', text: this.username })
          .onChange((value: string) => {
            this.username = value
          })
          .padding(12)
          .borderRadius(8)
          .backgroundColor('#F9FAFB')
          .border({ width: 1, color: '#E5E7EB' })
          .width('100%')

        TextInput({ placeholder: 'Password', text: this.password })
          .type(InputType.Password)
          .onChange((value: string) => {
            this.password = value
          })
          .padding(12)
          .borderRadius(8)
          .backgroundColor('#F9FAFB')
          .border({ width: 1, color: '#E5E7EB' })
          .width('100%')

        Button(this.authStore.loading ? 'Signing in...' : 'Sign in')
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

        Text('Demo users: visitor/admin/handler/writer/approver/hoteladmin/sysadmin')
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
          Text(`Welcome: ${this.authStore.currentUser?.displayName ?? ''}`).fontSize(16).fontWeight(FontWeight.Medium)
          Text(`Role: ${this.authStore.getRole()}`).fontSize(12).fontColor('#6B7280')
        }.alignItems(HorizontalAlign.Start)

        Blank()

        Button('Logout')
          .height(30)
          .onClick(() => this.authStore.logout())
      }
      .padding(12)
      .width('100%')

      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.getRoleTabs(), (tab: TabItem, index: number) => {
            Text(tab.title)
              .fontSize(14)
              .fontColor(index === this.selectedTab ? Color.White : '#4B5563')
              .backgroundColor(index === this.selectedTab ? '#2563EB' : '#F3F4F6')
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .borderRadius(16)
              .onClick(() => {
                this.selectedTab = index
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
