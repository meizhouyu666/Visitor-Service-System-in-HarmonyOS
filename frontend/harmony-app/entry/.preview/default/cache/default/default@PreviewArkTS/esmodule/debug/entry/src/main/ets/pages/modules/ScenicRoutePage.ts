if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface ScenicRoutePage_Params {
    scenicSpots?: SimpleItem[];
    routes?: SimpleItem[];
}
import { apiClient } from "@normalized:N&&&entry/src/main/ets/common/network/ApiClient&";
import type { SimpleItem } from '../../common/model/ApiModels';
export class ScenicRoutePage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__scenicSpots = new ObservedPropertyObjectPU([], this, "scenicSpots");
        this.__routes = new ObservedPropertyObjectPU([], this, "routes");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: ScenicRoutePage_Params) {
        if (params.scenicSpots !== undefined) {
            this.scenicSpots = params.scenicSpots;
        }
        if (params.routes !== undefined) {
            this.routes = params.routes;
        }
    }
    updateStateVars(params: ScenicRoutePage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__scenicSpots.purgeDependencyOnElmtId(rmElmtId);
        this.__routes.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__scenicSpots.aboutToBeDeleted();
        this.__routes.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __scenicSpots: ObservedPropertyObjectPU<SimpleItem[]>;
    get scenicSpots() {
        return this.__scenicSpots.get();
    }
    set scenicSpots(newValue: SimpleItem[]) {
        this.__scenicSpots.set(newValue);
    }
    private __routes: ObservedPropertyObjectPU<SimpleItem[]>;
    get routes() {
        return this.__routes.get();
    }
    set routes(newValue: SimpleItem[]) {
        this.__routes.set(newValue);
    }
    async aboutToAppear(): Promise<void> {
        const spots: SimpleItem[] = await apiClient.get<SimpleItem[]>('/api/query/scenic-spots');
        const routeList: SimpleItem[] = await apiClient.get<SimpleItem[]>('/api/query/routes');
        this.scenicSpots = [...spots];
        this.routes = [...routeList];
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Scroll.create();
            Scroll.debugLine("entry/src/main/ets/pages/modules/ScenicRoutePage.ets(17:5)", "entry");
            Scroll.height('100%');
        }, Scroll);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 12 });
            Column.debugLine("entry/src/main/ets/pages/modules/ScenicRoutePage.ets(18:7)", "entry");
            Column.alignItems(HorizontalAlign.Start);
            Column.padding(12);
            Column.width('100%');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Scenic Spot and Route Query');
            Text.debugLine("entry/src/main/ets/pages/modules/ScenicRoutePage.ets(19:9)", "entry");
            Text.fontSize(20);
            Text.fontWeight(FontWeight.Medium);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Scenic Spots');
            Text.debugLine("entry/src/main/ets/pages/modules/ScenicRoutePage.ets(20:9)", "entry");
            Text.fontSize(16);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = _item => {
                const item = _item;
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create(`${item.name} - ${item.description}`);
                    Text.debugLine("entry/src/main/ets/pages/modules/ScenicRoutePage.ets(22:11)", "entry");
                    Text.fontSize(13);
                }, Text);
                Text.pop();
            };
            this.forEachUpdateFunction(elmtId, this.scenicSpots, forEachItemGenFunction, (item: SimpleItem) => item.id, false, false);
        }, ForEach);
        ForEach.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Travel Routes');
            Text.debugLine("entry/src/main/ets/pages/modules/ScenicRoutePage.ets(24:9)", "entry");
            Text.fontSize(16);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = _item => {
                const item = _item;
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create(`${item.name} - ${item.description}`);
                    Text.debugLine("entry/src/main/ets/pages/modules/ScenicRoutePage.ets(26:11)", "entry");
                    Text.fontSize(13);
                }, Text);
                Text.pop();
            };
            this.forEachUpdateFunction(elmtId, this.routes, forEachItemGenFunction, (item: SimpleItem) => item.id, false, false);
        }, ForEach);
        ForEach.pop();
        Column.pop();
        Scroll.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
