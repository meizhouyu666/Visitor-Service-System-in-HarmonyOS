if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface WeatherTrafficPage_Params {
    data?: WeatherTrafficData;
}
import { apiClient } from "@normalized:N&&&entry/src/main/ets/common/network/ApiClient&";
interface WeatherTrafficData {
    weather: string;
    temperature: string;
    traffic: string;
}
export class WeatherTrafficPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__data = new ObservedPropertyObjectPU({
            weather: '',
            temperature: '',
            traffic: ''
        }, this, "data");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: WeatherTrafficPage_Params) {
        if (params.data !== undefined) {
            this.data = params.data;
        }
    }
    updateStateVars(params: WeatherTrafficPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__data.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__data.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __data: ObservedPropertyObjectPU<WeatherTrafficData>;
    get data() {
        return this.__data.get();
    }
    set data(newValue: WeatherTrafficData) {
        this.__data.set(newValue);
    }
    aboutToAppear() {
        // 不要 async！不要 await！
        this.loadData();
    }
    async loadData(): Promise<void> {
        try {
            const result: WeatherTrafficData = await apiClient.get<WeatherTrafficData>('/api/query/weather-traffic');
            this.data = result; // 不要包 {}！！！
        }
        catch (err) {
            console.error("加载数据失败", err);
        }
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 10 });
            Column.debugLine("entry/src/main/ets/pages/modules/WeatherTrafficPage.ets(32:5)", "entry");
            Column.alignItems(HorizontalAlign.Start);
            Column.padding(12);
            Column.width('100%');
            Column.height('100%');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Weather and Traffic');
            Text.debugLine("entry/src/main/ets/pages/modules/WeatherTrafficPage.ets(33:7)", "entry");
            Text.fontSize(20);
            Text.fontWeight(FontWeight.Medium);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`Weather: ${this.data.weather}`);
            Text.debugLine("entry/src/main/ets/pages/modules/WeatherTrafficPage.ets(34:7)", "entry");
            Text.fontSize(14);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`Temperature: ${this.data.temperature}`);
            Text.debugLine("entry/src/main/ets/pages/modules/WeatherTrafficPage.ets(35:7)", "entry");
            Text.fontSize(14);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`Traffic: ${this.data.traffic}`);
            Text.debugLine("entry/src/main/ets/pages/modules/WeatherTrafficPage.ets(36:7)", "entry");
            Text.fontSize(14);
        }, Text);
        Text.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
