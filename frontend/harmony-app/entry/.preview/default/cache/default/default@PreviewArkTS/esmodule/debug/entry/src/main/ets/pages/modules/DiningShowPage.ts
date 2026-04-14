if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface DiningShowPage_Params {
    diningItems?: SimpleItem[];
    performanceItems?: SimpleItem[];
}
import { apiClient } from "@normalized:N&&&entry/src/main/ets/common/network/ApiClient&";
import type { SimpleItem } from '../../common/model/ApiModels';
export class DiningShowPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__diningItems = new ObservedPropertyObjectPU([], this, "diningItems");
        this.__performanceItems = new ObservedPropertyObjectPU([], this, "performanceItems");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: DiningShowPage_Params) {
        if (params.diningItems !== undefined) {
            this.diningItems = params.diningItems;
        }
        if (params.performanceItems !== undefined) {
            this.performanceItems = params.performanceItems;
        }
    }
    updateStateVars(params: DiningShowPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__diningItems.purgeDependencyOnElmtId(rmElmtId);
        this.__performanceItems.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__diningItems.aboutToBeDeleted();
        this.__performanceItems.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __diningItems: ObservedPropertyObjectPU<SimpleItem[]>;
    get diningItems() {
        return this.__diningItems.get();
    }
    set diningItems(newValue: SimpleItem[]) {
        this.__diningItems.set(newValue);
    }
    private __performanceItems: ObservedPropertyObjectPU<SimpleItem[]>;
    get performanceItems() {
        return this.__performanceItems.get();
    }
    set performanceItems(newValue: SimpleItem[]) {
        this.__performanceItems.set(newValue);
    }
    async aboutToAppear(): Promise<void> {
        const dining: SimpleItem[] = await apiClient.get<SimpleItem[]>('/api/query/dining-entertainment');
        const performance: SimpleItem[] = await apiClient.get<SimpleItem[]>('/api/query/performances');
        this.diningItems = [...dining];
        this.performanceItems = [...performance];
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Scroll.create();
            Scroll.debugLine("entry/src/main/ets/pages/modules/DiningShowPage.ets(17:5)", "entry");
            Scroll.height('100%');
        }, Scroll);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 12 });
            Column.debugLine("entry/src/main/ets/pages/modules/DiningShowPage.ets(18:7)", "entry");
            Column.alignItems(HorizontalAlign.Start);
            Column.padding(12);
            Column.width('100%');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Dining and Performance');
            Text.debugLine("entry/src/main/ets/pages/modules/DiningShowPage.ets(19:9)", "entry");
            Text.fontSize(20);
            Text.fontWeight(FontWeight.Medium);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Dining and Entertainment');
            Text.debugLine("entry/src/main/ets/pages/modules/DiningShowPage.ets(20:9)", "entry");
            Text.fontSize(16);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = _item => {
                const item = _item;
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create(`${item.name} - ${item.description}`);
                    Text.debugLine("entry/src/main/ets/pages/modules/DiningShowPage.ets(22:11)", "entry");
                    Text.fontSize(13);
                }, Text);
                Text.pop();
            };
            this.forEachUpdateFunction(elmtId, this.diningItems, forEachItemGenFunction, (item: SimpleItem) => item.id, false, false);
        }, ForEach);
        ForEach.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Performance Groups');
            Text.debugLine("entry/src/main/ets/pages/modules/DiningShowPage.ets(24:9)", "entry");
            Text.fontSize(16);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = _item => {
                const item = _item;
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create(`${item.name} - ${item.description}`);
                    Text.debugLine("entry/src/main/ets/pages/modules/DiningShowPage.ets(26:11)", "entry");
                    Text.fontSize(13);
                }, Text);
                Text.pop();
            };
            this.forEachUpdateFunction(elmtId, this.performanceItems, forEachItemGenFunction, (item: SimpleItem) => item.id, false, false);
        }, ForEach);
        ForEach.pop();
        Column.pop();
        Scroll.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
