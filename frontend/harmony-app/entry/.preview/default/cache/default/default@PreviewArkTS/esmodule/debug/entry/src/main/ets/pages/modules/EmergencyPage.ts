if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface EmergencyPage_Params {
    items?: EmergencyItem[];
    loading?: boolean;
}
import { apiClient } from "@normalized:N&&&entry/src/main/ets/common/network/ApiClient&";
import type { EmergencyItem } from '../../common/model/ApiModels';
export class EmergencyPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__items = new ObservedPropertyObjectPU([], this, "items");
        this.__loading = new ObservedPropertySimplePU(false, this, "loading");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: EmergencyPage_Params) {
        if (params.items !== undefined) {
            this.items = params.items;
        }
        if (params.loading !== undefined) {
            this.loading = params.loading;
        }
    }
    updateStateVars(params: EmergencyPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__items.purgeDependencyOnElmtId(rmElmtId);
        this.__loading.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__items.aboutToBeDeleted();
        this.__loading.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __items: ObservedPropertyObjectPU<EmergencyItem[]>;
    get items() {
        return this.__items.get();
    }
    set items(newValue: EmergencyItem[]) {
        this.__items.set(newValue);
    }
    private __loading: ObservedPropertySimplePU<boolean>;
    get loading() {
        return this.__loading.get();
    }
    set loading(newValue: boolean) {
        this.__loading.set(newValue);
    }
    async aboutToAppear(): Promise<void> {
        this.loading = true;
        try {
            const result: EmergencyItem[] = await apiClient.get<EmergencyItem[]>('/api/emergency');
            this.items = [...result];
        }
        finally {
            this.loading = false;
        }
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 8 });
            Column.debugLine("entry/src/main/ets/pages/modules/EmergencyPage.ets(20:5)", "entry");
            Column.padding(12);
            Column.width('100%');
            Column.height('100%');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Emergency Information');
            Text.debugLine("entry/src/main/ets/pages/modules/EmergencyPage.ets(21:7)", "entry");
            Text.fontSize(20);
            Text.fontWeight(FontWeight.Medium);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.loading) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('Loading...');
                        Text.debugLine("entry/src/main/ets/pages/modules/EmergencyPage.ets(23:9)", "entry");
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
            List.create();
            List.debugLine("entry/src/main/ets/pages/modules/EmergencyPage.ets(25:7)", "entry");
            List.height('85%');
        }, List);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = _item => {
                const item = _item;
                {
                    const itemCreation = (elmtId, isInitialRender) => {
                        ViewStackProcessor.StartGetAccessRecordingFor(elmtId);
                        ListItem.create(deepRenderFunction, true);
                        if (!isInitialRender) {
                            ListItem.pop();
                        }
                        ViewStackProcessor.StopGetAccessRecording();
                    };
                    const itemCreation2 = (elmtId, isInitialRender) => {
                        ListItem.create(deepRenderFunction, true);
                        ListItem.debugLine("entry/src/main/ets/pages/modules/EmergencyPage.ets(27:11)", "entry");
                    };
                    const deepRenderFunction = (elmtId, isInitialRender) => {
                        itemCreation(elmtId, isInitialRender);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Column.create({ space: 4 });
                            Column.debugLine("entry/src/main/ets/pages/modules/EmergencyPage.ets(28:13)", "entry");
                            Column.alignItems(HorizontalAlign.Start);
                            Column.padding(12);
                        }, Column);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(item.title);
                            Text.debugLine("entry/src/main/ets/pages/modules/EmergencyPage.ets(29:15)", "entry");
                            Text.fontSize(16);
                        }, Text);
                        Text.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(item.content);
                            Text.debugLine("entry/src/main/ets/pages/modules/EmergencyPage.ets(30:15)", "entry");
                            Text.fontSize(13);
                            Text.maxLines(2);
                        }, Text);
                        Text.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(item.status);
                            Text.debugLine("entry/src/main/ets/pages/modules/EmergencyPage.ets(31:15)", "entry");
                            Text.fontSize(12);
                        }, Text);
                        Text.pop();
                        Column.pop();
                        ListItem.pop();
                    };
                    this.observeComponentCreation2(itemCreation2, ListItem);
                    ListItem.pop();
                }
            };
            this.forEachUpdateFunction(elmtId, this.items, forEachItemGenFunction, (item: EmergencyItem) => `${item.id}`, false, false);
        }, ForEach);
        ForEach.pop();
        List.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
