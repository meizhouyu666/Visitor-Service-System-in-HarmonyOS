import { AuthStore } from '../common/state/AuthStore'
import { ComplaintPage } from './modules/ComplaintPage'
import { EmergencyPage } from './modules/EmergencyPage'
import { HotelPage } from './modules/HotelPage'
import { ScenicRoutePage } from './modules/ScenicRoutePage'
import { DiningShowPage } from './modules/DiningShowPage'
import { WeatherTrafficPage } from './modules/WeatherTrafficPage'

@Entry
@Component
struct Index {
  @State private selectedTab: number = 0
  @State private username: string = 'visitor'
  @State private password: string = 'visitor123'
  @State private authStore: AuthStore = new AuthStore()

  private async doLogin(): Promise<void> {
    await this.authStore.login({
      username: this.username,
      password: this.password
    })
  }

  @Builder
  private LoginView(): void {
    Column({ space: 10 }) {
      Text('Visitor Service System').fontSize(24).fontWeight(FontWeight.Medium)
      TextInput({ placeholder: 'Username', text: this.username })
        .onChange((value: string) => {
          this.username = value
        })
      TextInput({ placeholder: 'Password', text: this.password })
        .type(InputType.Password)
        .onChange((value: string) => {
          this.password = value
        })
      Button(this.authStore.loading ? 'Signing in...' : 'Sign In')
        .enabled(!this.authStore.loading)
        .onClick(() => {
          this.doLogin()
        })
      if (this.authStore.errorMessage.length > 0) {
        Text(this.authStore.errorMessage).fontColor(Color.Red).fontSize(12)
      }
      Text('Demo account: visitor/visitor123 or admin/admin123').fontSize(12)
    }.padding(20).width('100%').height('100%')
  }

  @Builder
  private HomeView(): void {
    Column() {
      Row({ space: 8 }) {
        Text(`Welcome: ${this.authStore.currentUser?.displayName ?? ''}`).fontSize(14)
        Button('Logout').onClick(() => this.authStore.logout()).height(28)
      }.padding(8).justifyContent(FlexAlign.SpaceBetween).width('100%')

      Tabs({ barPosition: BarPosition.Start, index: this.selectedTab }) {
        TabContent() {
          ComplaintPage()
        }.tabBar('Complaint')

        TabContent() {
          EmergencyPage()
        }.tabBar('Emergency')

        TabContent() {
          HotelPage()
        }.tabBar('Hotels')

        TabContent() {
          ScenicRoutePage()
        }.tabBar('Scenic')

        TabContent() {
          DiningShowPage()
        }.tabBar('Dining')

        TabContent() {
          WeatherTrafficPage()
        }.tabBar('Weather')
      }.vertical(false).scrollable(true)
    }.width('100%').height('100%')
  }

  build() {
    if (this.authStore.currentUser === null) {
      this.LoginView()
    } else {
      this.HomeView()
    }
  }
}
