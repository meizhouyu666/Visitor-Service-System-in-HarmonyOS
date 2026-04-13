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

        //用户名输入框
        TextInput({ placeholder: '请输入用户名', text: this.username })
          .onChange((value: string) => {
            this.username = value
          })
          .padding(12)
          .borderRadius(8)
          .backgroundColor('#F9FAFB')
          .border({ width: 1, color: '#E5E7EB' })
          .width('100%')

        //密码输入框
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

        //登录按钮
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

        //错误提示
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

      //让卡片垂直水平居中
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
      //顶部欢迎栏
      Row({ space: 12 }) {
        Row({ space: 8 }) {
          Image($r('app.media.layered_image'))
            .width(32)
            .height(32)
            .borderRadius(16)
            .backgroundColor(Color.White)
            .padding(4)

          Column({ space: 2 }) {
            Text('欢迎登陆')
              .fontSize(12)
              .fontColor('rgba(255, 255, 255, 0.85)')
              .fontWeight(FontWeight.Normal)

            Text(`${this.authStore.currentUser?.displayName ?? 'Guest'}`)
              .fontSize(16)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)
          }.alignItems(HorizontalAlign.Start)
        }

        Blank()

        Button('退出')
          .height(32)
          .padding({ left: 16, right: 16 })
          .backgroundColor('rgba(255, 255, 255, 0.2)')
          .fontColor(Color.White)
          .fontSize(14)
          .borderRadius(20)
          .onClick(() => this.authStore.logout())
      }
      .padding({ left: 20, right: 20, top: 12, bottom: 12 })
      .width('100%')
      .backgroundColor('#4A90E2')
      .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetY: 2 })

      //自定义 Tab 栏
      Scroll() {
        Row({ space: 0 }) {
          //使用TabBarBuilder构建每个选项
          this.TabBarBuilder('投诉', 0)
          this.TabBarBuilder('紧急求助', 1)
          this.TabBarBuilder('酒店信息', 2)
          this.TabBarBuilder('景点路线', 3)
          this.TabBarBuilder('餐饮演出', 4)
          this.TabBarBuilder('天气交通', 5)
        }
        .padding({ left: 8, right: 8 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .height(56)
      .backgroundColor(Color.White)

      //分割线
      Divider()
        .height(1)
        .color('#E0E0E0')
        .width('100%')

      //内容区域（根据选中的Tab显示不同页面）
      if (this.selectedTab === 0) {
        ComplaintPage()
      } else if (this.selectedTab === 1) {
        EmergencyPage()
      } else if (this.selectedTab === 2) {
        HotelPage()
      } else if (this.selectedTab === 3) {
        ScenicRoutePage()
      } else if (this.selectedTab === 4) {
        DiningShowPage()
      } else if (this.selectedTab === 5) {
        WeatherTrafficPage()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  //自定义 Tab 栏样式构建器
  @Builder
  TabBarBuilder(title: string, tabIndex: number): void {
    Column() {
      Text(title)
        .fontSize(14)
        .fontColor(tabIndex === this.selectedTab ? '#FFFFFF' : '#666666')
        .fontWeight(tabIndex === this.selectedTab ? FontWeight.Bold : FontWeight.Normal)
    }
    .padding({ top: 8, bottom: 8, left: 20, right: 20 })
    .width('auto')
    .justifyContent(FlexAlign.Center)
    .borderRadius(20)  //胶囊样式
    .backgroundColor(tabIndex === this.selectedTab ? '#4A90E2' : '#F5F5F5')
    .border({
      width: 1,
      color: tabIndex === this.selectedTab ? '#4A90E2' : '#E0E0E0',
      style: BorderStyle.Solid
    })
    .margin({ left: 6, right: 6 })
    .shadow({
      radius: tabIndex === this.selectedTab ? 4 : 0,  //选中态添加阴影
      color: 'rgba(74, 144, 226, 0.3)',
      offsetY: 2
    })
    .onClick(() => {
      this.selectedTab = tabIndex
    })
  }

  build() {
    if (this.authStore.currentUser === null) {
      this.LoginView()
    } else {
      this.HomeView()
    }
  }
}
