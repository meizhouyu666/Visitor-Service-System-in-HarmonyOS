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
      Column({ space: 16 }) {
        Text('游客服务系统')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')
          .margin({ bottom: 12 })

        TextInput({ placeholder: '请输入用户名', text: this.username })
          .onChange((value: string) => {
            this.username = value
          })
          .padding(12)
          .borderRadius(8)
          .backgroundColor('#F9FAFB')
          .border({ width: 1, color: '#E5E7EB' })
          .width('100%')

        TextInput({ placeholder: '请输入密码', text: this.password })
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
          .fontWeight(FontWeight.Medium)
          .margin({ top: 8 })

        if (this.authStore.errorMessage.length > 0) {
          Text(this.authStore.errorMessage)
            .fontColor(Color.Red)
            .fontSize(12)
            .margin({ top: 4 })
        }

        Text('演示账号：visitor/visitor123 或 admin/admin123')
          .fontSize(12)
          .fontColor('#6B7280')
          .margin({ top: 12 })
      }
      .width('90%')
      .padding(28)
      .backgroundColor(Color.White)
      .borderRadius(16)
      .shadow({ radius: 12, color: '#00000010', offsetX: 0, offsetY: 4 })
    }
    .padding(20)
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F3F4F6')
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
