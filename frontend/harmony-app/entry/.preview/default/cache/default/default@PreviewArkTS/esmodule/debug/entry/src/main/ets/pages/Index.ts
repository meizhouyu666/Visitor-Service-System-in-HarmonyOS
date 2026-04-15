if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface Index_Params {
    selectedTab?: number;
    username?: string;
    password?: string;
    authStore?: AuthStore;
}
import { AuthStore } from "@normalized:N&&&entry/src/main/ets/common/state/AuthStore&";
import { ComplaintPage } from "@normalized:N&&&entry/src/main/ets/pages/modules/ComplaintPage&";
import { EmergencyPage } from "@normalized:N&&&entry/src/main/ets/pages/modules/EmergencyPage&";
import { HotelPage } from "@normalized:N&&&entry/src/main/ets/pages/modules/HotelPage&";
import { ScenicRoutePage } from "@normalized:N&&&entry/src/main/ets/pages/modules/ScenicRoutePage&";
import { DiningShowPage } from "@normalized:N&&&entry/src/main/ets/pages/modules/DiningShowPage&";
import { WeatherTrafficPage } from "@normalized:N&&&entry/src/main/ets/pages/modules/WeatherTrafficPage&";
class Index extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__selectedTab = new ObservedPropertySimplePU(0, this, "selectedTab");
        this.__username = new ObservedPropertySimplePU('visitor', this, "username");
        this.__password = new ObservedPropertySimplePU('visitor123', this, "password");
        this.__authStore = new ObservedPropertyObjectPU(new AuthStore(), this, "authStore");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: Index_Params) {
        if (params.selectedTab !== undefined) {
            this.selectedTab = params.selectedTab;
        }
        if (params.username !== undefined) {
            this.username = params.username;
        }
        if (params.password !== undefined) {
            this.password = params.password;
        }
        if (params.authStore !== undefined) {
            this.authStore = params.authStore;
        }
    }
    updateStateVars(params: Index_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__selectedTab.purgeDependencyOnElmtId(rmElmtId);
        this.__username.purgeDependencyOnElmtId(rmElmtId);
        this.__password.purgeDependencyOnElmtId(rmElmtId);
        this.__authStore.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__selectedTab.aboutToBeDeleted();
        this.__username.aboutToBeDeleted();
        this.__password.aboutToBeDeleted();
        this.__authStore.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __selectedTab: ObservedPropertySimplePU<number>;
    get selectedTab() {
        return this.__selectedTab.get();
    }
    set selectedTab(newValue: number) {
        this.__selectedTab.set(newValue);
    }
    private __username: ObservedPropertySimplePU<string>;
    get username() {
        return this.__username.get();
    }
    set username(newValue: string) {
        this.__username.set(newValue);
    }
    private __password: ObservedPropertySimplePU<string>;
    get password() {
        return this.__password.get();
    }
    set password(newValue: string) {
        this.__password.set(newValue);
    }
    private __authStore: ObservedPropertyObjectPU<AuthStore>;
    get authStore() {
        return this.__authStore.get();
    }
    set authStore(newValue: AuthStore) {
        this.__authStore.set(newValue);
    }
    private async doLogin(): Promise<void> {
        await this.authStore.login({
            username: this.username,
            password: this.password
        });
    }
    private LoginView(parent = null): void {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 10 });
            Column.debugLine("entry/src/main/ets/pages/Index.ets(26:5)", "entry");
            Column.padding(20);
            Column.width('100%');
            Column.height('100%');
            Column.justifyContent(FlexAlign.Center);
            Column.backgroundColor('#F3F4F6');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 16 });
            Column.debugLine("entry/src/main/ets/pages/Index.ets(27:7)", "entry");
            Column.width('90%');
            Column.padding(28);
            Column.backgroundColor(Color.White);
            Column.borderRadius(16);
            Column.shadow({ radius: 12, color: '#00000010', offsetX: 0, offsetY: 4 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('游客服务系统');
            Text.debugLine("entry/src/main/ets/pages/Index.ets(28:9)", "entry");
            Text.fontSize(26);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor('#1F2937');
            Text.margin({ bottom: 12 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            //用户名输入框
            TextInput.create({ placeholder: '请输入用户名', text: this.username });
            TextInput.debugLine("entry/src/main/ets/pages/Index.ets(35:9)", "entry");
            //用户名输入框
            TextInput.onChange((value: string) => {
                this.username = value;
            });
            //用户名输入框
            TextInput.padding(12);
            //用户名输入框
            TextInput.borderRadius(8);
            //用户名输入框
            TextInput.backgroundColor('#F9FAFB');
            //用户名输入框
            TextInput.border({ width: 1, color: '#E5E7EB' });
            //用户名输入框
            TextInput.width('100%');
        }, TextInput);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            //密码输入框
            TextInput.create({ placeholder: '请输入密码', text: this.password });
            TextInput.debugLine("entry/src/main/ets/pages/Index.ets(46:9)", "entry");
            //密码输入框
            TextInput.type(InputType.Password);
            //密码输入框
            TextInput.onChange((value: string) => {
                this.password = value;
            });
            //密码输入框
            TextInput.padding(12);
            //密码输入框
            TextInput.borderRadius(8);
            //密码输入框
            TextInput.backgroundColor('#F9FAFB');
            //密码输入框
            TextInput.border({ width: 1, color: '#E5E7EB' });
            //密码输入框
            TextInput.width('100%');
        }, TextInput);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            //登录按钮
            Button.createWithLabel(this.authStore.loading ? '登录中...' : '登录');
            Button.debugLine("entry/src/main/ets/pages/Index.ets(58:9)", "entry");
            //登录按钮
            Button.enabled(!this.authStore.loading);
            //登录按钮
            Button.onClick(() => {
                this.doLogin();
            });
            //登录按钮
            Button.width('100%');
            //登录按钮
            Button.padding(12);
            //登录按钮
            Button.borderRadius(8);
            //登录按钮
            Button.backgroundColor('#3B82F6');
            //登录按钮
            Button.fontColor(Color.White);
            //登录按钮
            Button.fontWeight(FontWeight.Medium);
            //登录按钮
            Button.margin({ top: 8 });
        }, Button);
        //登录按钮
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            //错误提示
            if (this.authStore.errorMessage.length > 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.authStore.errorMessage);
                        Text.debugLine("entry/src/main/ets/pages/Index.ets(73:11)", "entry");
                        Text.fontColor(Color.Red);
                        Text.fontSize(12);
                        Text.margin({ top: 4 });
                    }, Text);
                    Text.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('演示账号：visitor/visitor123 或 admin/admin123');
            Text.debugLine("entry/src/main/ets/pages/Index.ets(79:9)", "entry");
            Text.fontSize(12);
            Text.fontColor('#6B7280');
            Text.margin({ top: 12 });
        }, Text);
        Text.pop();
        Column.pop();
        Column.pop();
    }
    private HomeView(parent = null): void {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/Index.ets(101:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F5F5F5');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            //顶部欢迎栏
            Row.create({ space: 12 });
            Row.debugLine("entry/src/main/ets/pages/Index.ets(103:7)", "entry");
            //顶部欢迎栏
            Row.padding({ left: 20, right: 20, top: 12, bottom: 12 });
            //顶部欢迎栏
            Row.width('100%');
            //顶部欢迎栏
            Row.backgroundColor('#4A90E2');
            //顶部欢迎栏
            Row.shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetY: 2 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 8 });
            Row.debugLine("entry/src/main/ets/pages/Index.ets(104:9)", "entry");
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Image.create({ "id": 16777221, "type": 20000, params: [], "bundleName": "com.visitor.servicesystem", "moduleName": "entry" });
            Image.debugLine("entry/src/main/ets/pages/Index.ets(105:11)", "entry");
            Image.width(32);
            Image.height(32);
            Image.borderRadius(16);
            Image.backgroundColor(Color.White);
            Image.padding(4);
        }, Image);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 2 });
            Column.debugLine("entry/src/main/ets/pages/Index.ets(112:11)", "entry");
            Column.alignItems(HorizontalAlign.Start);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('欢迎登陆');
            Text.debugLine("entry/src/main/ets/pages/Index.ets(113:13)", "entry");
            Text.fontSize(12);
            Text.fontColor('rgba(255, 255, 255, 0.85)');
            Text.fontWeight(FontWeight.Normal);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`${this.authStore.currentUser?.displayName ?? 'Guest'}`);
            Text.debugLine("entry/src/main/ets/pages/Index.ets(118:13)", "entry");
            Text.fontSize(16);
            Text.fontColor(Color.White);
            Text.fontWeight(FontWeight.Medium);
        }, Text);
        Text.pop();
        Column.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
            Blank.debugLine("entry/src/main/ets/pages/Index.ets(125:9)", "entry");
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('退出');
            Button.debugLine("entry/src/main/ets/pages/Index.ets(127:9)", "entry");
            Button.height(32);
            Button.padding({ left: 16, right: 16 });
            Button.backgroundColor('rgba(255, 255, 255, 0.2)');
            Button.fontColor(Color.White);
            Button.fontSize(14);
            Button.borderRadius(20);
            Button.onClick(() => this.authStore.logout());
        }, Button);
        Button.pop();
        //顶部欢迎栏
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            //自定义 Tab 栏
            Scroll.create();
            Scroll.debugLine("entry/src/main/ets/pages/Index.ets(142:7)", "entry");
            //自定义 Tab 栏
            Scroll.scrollable(ScrollDirection.Horizontal);
            //自定义 Tab 栏
            Scroll.scrollBar(BarState.Off);
            //自定义 Tab 栏
            Scroll.width('100%');
            //自定义 Tab 栏
            Scroll.height(56);
            //自定义 Tab 栏
            Scroll.backgroundColor(Color.White);
        }, Scroll);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 0 });
            Row.debugLine("entry/src/main/ets/pages/Index.ets(143:9)", "entry");
            Row.padding({ left: 8, right: 8 });
        }, Row);
        //使用TabBarBuilder构建每个选项
        this.TabBarBuilder.bind(this)('投诉', 0);
        this.TabBarBuilder.bind(this)('紧急求助', 1);
        this.TabBarBuilder.bind(this)('酒店信息', 2);
        this.TabBarBuilder.bind(this)('景点路线', 3);
        this.TabBarBuilder.bind(this)('餐饮演出', 4);
        this.TabBarBuilder.bind(this)('天气交通', 5);
        Row.pop();
        //自定义 Tab 栏
        Scroll.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            //分割线
            Divider.create();
            Divider.debugLine("entry/src/main/ets/pages/Index.ets(161:7)", "entry");
            //分割线
            Divider.height(1);
            //分割线
            Divider.color('#E0E0E0');
            //分割线
            Divider.width('100%');
        }, Divider);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            //内容区域（根据选中的Tab显示不同页面）
            if (this.selectedTab === 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    {
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            if (isInitialRender) {
                                let componentCall = new ComplaintPage(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 168, col: 9 });
                                ViewPU.create(componentCall);
                                let paramsLambda = () => {
                                    return {};
                                };
                                componentCall.paramsGenerator_ = paramsLambda;
                            }
                            else {
                                this.updateStateVarsOfChildByElmtId(elmtId, {});
                            }
                        }, { name: "ComplaintPage" });
                    }
                });
            }
            else if (this.selectedTab === 1) {
                this.ifElseBranchUpdateFunction(1, () => {
                    {
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            if (isInitialRender) {
                                let componentCall = new EmergencyPage(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 170, col: 9 });
                                ViewPU.create(componentCall);
                                let paramsLambda = () => {
                                    return {};
                                };
                                componentCall.paramsGenerator_ = paramsLambda;
                            }
                            else {
                                this.updateStateVarsOfChildByElmtId(elmtId, {});
                            }
                        }, { name: "EmergencyPage" });
                    }
                });
            }
            else if (this.selectedTab === 2) {
                this.ifElseBranchUpdateFunction(2, () => {
                    {
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            if (isInitialRender) {
                                let componentCall = new HotelPage(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 172, col: 9 });
                                ViewPU.create(componentCall);
                                let paramsLambda = () => {
                                    return {};
                                };
                                componentCall.paramsGenerator_ = paramsLambda;
                            }
                            else {
                                this.updateStateVarsOfChildByElmtId(elmtId, {});
                            }
                        }, { name: "HotelPage" });
                    }
                });
            }
            else if (this.selectedTab === 3) {
                this.ifElseBranchUpdateFunction(3, () => {
                    {
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            if (isInitialRender) {
                                let componentCall = new ScenicRoutePage(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 174, col: 9 });
                                ViewPU.create(componentCall);
                                let paramsLambda = () => {
                                    return {};
                                };
                                componentCall.paramsGenerator_ = paramsLambda;
                            }
                            else {
                                this.updateStateVarsOfChildByElmtId(elmtId, {});
                            }
                        }, { name: "ScenicRoutePage" });
                    }
                });
            }
            else if (this.selectedTab === 4) {
                this.ifElseBranchUpdateFunction(4, () => {
                    {
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            if (isInitialRender) {
                                let componentCall = new DiningShowPage(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 176, col: 9 });
                                ViewPU.create(componentCall);
                                let paramsLambda = () => {
                                    return {};
                                };
                                componentCall.paramsGenerator_ = paramsLambda;
                            }
                            else {
                                this.updateStateVarsOfChildByElmtId(elmtId, {});
                            }
                        }, { name: "DiningShowPage" });
                    }
                });
            }
            else if (this.selectedTab === 5) {
                this.ifElseBranchUpdateFunction(5, () => {
                    {
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            if (isInitialRender) {
                                let componentCall = new WeatherTrafficPage(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 178, col: 9 });
                                ViewPU.create(componentCall);
                                let paramsLambda = () => {
                                    return {};
                                };
                                componentCall.paramsGenerator_ = paramsLambda;
                            }
                            else {
                                this.updateStateVarsOfChildByElmtId(elmtId, {});
                            }
                        }, { name: "WeatherTrafficPage" });
                    }
                });
            }
            else {
                this.ifElseBranchUpdateFunction(6, () => {
                });
            }
        }, If);
        If.pop();
        Column.pop();
    }
    private AdminView(parent = null): void {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/Index.ets(188:7)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F5F5F5');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            //顶部欢迎栏
            Row.create({ space: 12 });
            Row.debugLine("entry/src/main/ets/pages/Index.ets(190:9)", "entry");
            //顶部欢迎栏
            Row.padding({ left: 20, right: 20, top: 12, bottom: 12 });
            //顶部欢迎栏
            Row.width('100%');
            //顶部欢迎栏
            Row.backgroundColor('#4A90E2');
            //顶部欢迎栏
            Row.shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetY: 2 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 8 });
            Row.debugLine("entry/src/main/ets/pages/Index.ets(191:11)", "entry");
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Image.create({ "id": 16777221, "type": 20000, params: [], "bundleName": "com.visitor.servicesystem", "moduleName": "entry" });
            Image.debugLine("entry/src/main/ets/pages/Index.ets(192:13)", "entry");
            Image.width(32);
            Image.height(32);
            Image.borderRadius(16);
            Image.backgroundColor(Color.White);
            Image.padding(4);
        }, Image);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 2 });
            Column.debugLine("entry/src/main/ets/pages/Index.ets(199:13)", "entry");
            Column.alignItems(HorizontalAlign.Start);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('管理员中心');
            Text.debugLine("entry/src/main/ets/pages/Index.ets(200:15)", "entry");
            Text.fontSize(12);
            Text.fontColor('rgba(255, 255, 255, 0.85)');
            Text.fontWeight(FontWeight.Normal);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`${this.authStore.currentUser?.displayName ?? 'Admin'}`);
            Text.debugLine("entry/src/main/ets/pages/Index.ets(205:15)", "entry");
            Text.fontSize(16);
            Text.fontColor(Color.White);
            Text.fontWeight(FontWeight.Medium);
        }, Text);
        Text.pop();
        Column.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
            Blank.debugLine("entry/src/main/ets/pages/Index.ets(212:11)", "entry");
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('退出');
            Button.debugLine("entry/src/main/ets/pages/Index.ets(214:11)", "entry");
            Button.height(32);
            Button.padding({ left: 16, right: 16 });
            Button.backgroundColor('rgba(255, 255, 255, 0.2)');
            Button.fontColor(Color.White);
            Button.fontSize(14);
            Button.borderRadius(20);
            Button.onClick(() => this.authStore.logout());
        }, Button);
        Button.pop();
        //顶部欢迎栏
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            //自定义 Tab 栏
            Scroll.create();
            Scroll.debugLine("entry/src/main/ets/pages/Index.ets(229:9)", "entry");
            //自定义 Tab 栏
            Scroll.scrollable(ScrollDirection.Horizontal);
            //自定义 Tab 栏
            Scroll.scrollBar(BarState.Off);
            //自定义 Tab 栏
            Scroll.width('100%');
            //自定义 Tab 栏
            Scroll.height(56);
            //自定义 Tab 栏
            Scroll.backgroundColor(Color.White);
        }, Scroll);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 0 });
            Row.debugLine("entry/src/main/ets/pages/Index.ets(230:11)", "entry");
            Row.padding({ left: 8, right: 8 });
        }, Row);
        //使用TabBarBuilder构建每个选项
        this.TabBarBuilder.bind(this)('投诉管理', 0);
        this.TabBarBuilder.bind(this)('紧急求助管理', 1);
        this.TabBarBuilder.bind(this)('酒店信息管理', 2);
        this.TabBarBuilder.bind(this)('景点路线管理', 3);
        this.TabBarBuilder.bind(this)('餐饮演出管理', 4);
        Row.pop();
        //自定义 Tab 栏
        Scroll.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            //分割线
            Divider.create();
            Divider.debugLine("entry/src/main/ets/pages/Index.ets(247:9)", "entry");
            //分割线
            Divider.height(1);
            //分割线
            Divider.color('#E0E0E0');
            //分割线
            Divider.width('100%');
        }, Divider);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            //内容区域（根据选中的Tab显示不同页面）
            if (this.selectedTab === 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    {
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            if (isInitialRender) {
                                let componentCall = new ComplaintPage(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 254, col: 11 });
                                ViewPU.create(componentCall);
                                let paramsLambda = () => {
                                    return {};
                                };
                                componentCall.paramsGenerator_ = paramsLambda;
                            }
                            else {
                                this.updateStateVarsOfChildByElmtId(elmtId, {});
                            }
                        }, { name: "ComplaintPage" });
                    }
                });
            }
            else if (this.selectedTab === 1) {
                this.ifElseBranchUpdateFunction(1, () => {
                    {
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            if (isInitialRender) {
                                let componentCall = new EmergencyPage(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 256, col: 11 });
                                ViewPU.create(componentCall);
                                let paramsLambda = () => {
                                    return {};
                                };
                                componentCall.paramsGenerator_ = paramsLambda;
                            }
                            else {
                                this.updateStateVarsOfChildByElmtId(elmtId, {});
                            }
                        }, { name: "EmergencyPage" });
                    }
                });
            }
            else if (this.selectedTab === 2) {
                this.ifElseBranchUpdateFunction(2, () => {
                    {
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            if (isInitialRender) {
                                let componentCall = new HotelPage(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 258, col: 11 });
                                ViewPU.create(componentCall);
                                let paramsLambda = () => {
                                    return {};
                                };
                                componentCall.paramsGenerator_ = paramsLambda;
                            }
                            else {
                                this.updateStateVarsOfChildByElmtId(elmtId, {});
                            }
                        }, { name: "HotelPage" });
                    }
                });
            }
            else if (this.selectedTab === 3) {
                this.ifElseBranchUpdateFunction(3, () => {
                    {
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            if (isInitialRender) {
                                let componentCall = new ScenicRoutePage(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 260, col: 11 });
                                ViewPU.create(componentCall);
                                let paramsLambda = () => {
                                    return {};
                                };
                                componentCall.paramsGenerator_ = paramsLambda;
                            }
                            else {
                                this.updateStateVarsOfChildByElmtId(elmtId, {});
                            }
                        }, { name: "ScenicRoutePage" });
                    }
                });
            }
            else if (this.selectedTab === 4) {
                this.ifElseBranchUpdateFunction(4, () => {
                    {
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            if (isInitialRender) {
                                let componentCall = new DiningShowPage(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 262, col: 11 });
                                ViewPU.create(componentCall);
                                let paramsLambda = () => {
                                    return {};
                                };
                                componentCall.paramsGenerator_ = paramsLambda;
                            }
                            else {
                                this.updateStateVarsOfChildByElmtId(elmtId, {});
                            }
                        }, { name: "DiningShowPage" });
                    }
                });
            }
            else {
                this.ifElseBranchUpdateFunction(5, () => {
                });
            }
        }, If);
        If.pop();
        Column.pop();
    }
    //自定义 Tab 栏样式构建器
    TabBarBuilder(title: string, tabIndex: number, parent = null): void {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/Index.ets(273:5)", "entry");
            Column.padding({ top: 8, bottom: 8, left: 20, right: 20 });
            Column.width('auto');
            Column.justifyContent(FlexAlign.Center);
            Column.borderRadius(20);
            Column.backgroundColor(tabIndex === this.selectedTab ? '#4A90E2' : '#F5F5F5');
            Column.border({
                width: 1,
                color: tabIndex === this.selectedTab ? '#4A90E2' : '#E0E0E0',
                style: BorderStyle.Solid
            });
            Column.margin({ left: 6, right: 6 });
            Column.shadow({
                radius: tabIndex === this.selectedTab ? 4 : 0,
                color: 'rgba(74, 144, 226, 0.3)',
                offsetY: 2
            });
            Column.onClick(() => {
                this.selectedTab = tabIndex;
            });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(title);
            Text.debugLine("entry/src/main/ets/pages/Index.ets(274:7)", "entry");
            Text.fontSize(14);
            Text.fontColor(tabIndex === this.selectedTab ? '#FFFFFF' : '#666666');
            Text.fontWeight(tabIndex === this.selectedTab ? FontWeight.Bold : FontWeight.Normal);
        }, Text);
        Text.pop();
        Column.pop();
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.authStore.currentUser === null) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.LoginView.bind(this)();
                });
            }
            else if (this.authStore.hasRole('ADMIN')) {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.AdminView.bind(this)();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(2, () => {
                    this.HomeView.bind(this)();
                });
            }
        }, If);
        If.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "Index";
    }
}
registerNamedRoute(() => new Index(undefined, {}), "", { bundleName: "com.visitor.servicesystem", moduleName: "entry", pagePath: "pages/Index", pageFullPath: "entry/src/main/ets/pages/Index", integratedHsp: "false", moduleType: "followWithHap" });
