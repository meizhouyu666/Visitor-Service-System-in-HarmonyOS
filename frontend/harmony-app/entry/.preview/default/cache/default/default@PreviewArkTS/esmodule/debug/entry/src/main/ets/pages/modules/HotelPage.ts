if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface HotelPage_Params {
    starHotels?: SimpleItem[];
    nonStarHotels?: SimpleItem[];
}
import { apiClient } from "@normalized:N&&&entry/src/main/ets/common/network/ApiClient&";
import type { SimpleItem } from '../../common/model/ApiModels';
export class HotelPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__starHotels = new ObservedPropertyObjectPU([], this, "starHotels");
        this.__nonStarHotels = new ObservedPropertyObjectPU([], this, "nonStarHotels");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: HotelPage_Params) {
        if (params.starHotels !== undefined) {
            this.starHotels = params.starHotels;
        }
        if (params.nonStarHotels !== undefined) {
            this.nonStarHotels = params.nonStarHotels;
        }
    }
    updateStateVars(params: HotelPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__starHotels.purgeDependencyOnElmtId(rmElmtId);
        this.__nonStarHotels.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__starHotels.aboutToBeDeleted();
        this.__nonStarHotels.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __starHotels: ObservedPropertyObjectPU<SimpleItem[]>;
    get starHotels() {
        return this.__starHotels.get();
    }
    set starHotels(newValue: SimpleItem[]) {
        this.__starHotels.set(newValue);
    }
    private __nonStarHotels: ObservedPropertyObjectPU<SimpleItem[]>;
    get nonStarHotels() {
        return this.__nonStarHotels.get();
    }
    set nonStarHotels(newValue: SimpleItem[]) {
        this.__nonStarHotels.set(newValue);
    }
    async aboutToAppear(): Promise<void> {
        const stars: SimpleItem[] = await apiClient.get<SimpleItem[]>('/api/query/hotels/star');
        const nonStars: SimpleItem[] = await apiClient.get<SimpleItem[]>('/api/query/hotels/non-star');
        this.starHotels = [...stars];
        this.nonStarHotels = [...nonStars];
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Scroll.create();
            Scroll.debugLine("entry/src/main/ets/pages/modules/HotelPage.ets(17:5)", "entry");
            Scroll.height('100%');
        }, Scroll);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 12 });
            Column.debugLine("entry/src/main/ets/pages/modules/HotelPage.ets(18:7)", "entry");
            Column.alignItems(HorizontalAlign.Start);
            Column.padding(12);
            Column.width('100%');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Hotel Query and Marketing');
            Text.debugLine("entry/src/main/ets/pages/modules/HotelPage.ets(19:9)", "entry");
            Text.fontSize(20);
            Text.fontWeight(FontWeight.Medium);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Star Hotels');
            Text.debugLine("entry/src/main/ets/pages/modules/HotelPage.ets(21:9)", "entry");
            Text.fontSize(16);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = _item => {
                const item = _item;
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create(`${item.name} - ${item.description}`);
                    Text.debugLine("entry/src/main/ets/pages/modules/HotelPage.ets(23:11)", "entry");
                    Text.fontSize(13);
                }, Text);
                Text.pop();
            };
            this.forEachUpdateFunction(elmtId, this.starHotels, forEachItemGenFunction, (item: SimpleItem) => item.id, false, false);
        }, ForEach);
        ForEach.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Non-Star / Rural Hotels');
            Text.debugLine("entry/src/main/ets/pages/modules/HotelPage.ets(26:9)", "entry");
            Text.fontSize(16);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = _item => {
                const item = _item;
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create(`${item.name} - ${item.description}`);
                    Text.debugLine("entry/src/main/ets/pages/modules/HotelPage.ets(28:11)", "entry");
                    Text.fontSize(13);
                }, Text);
                Text.pop();
            };
            this.forEachUpdateFunction(elmtId, this.nonStarHotels, forEachItemGenFunction, (item: SimpleItem) => item.id, false, false);
        }, ForEach);
        ForEach.pop();
        Column.pop();
        Scroll.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
