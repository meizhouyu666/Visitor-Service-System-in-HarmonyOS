import { UIAbility, Want } from '@kit.AbilityKit'
import { window } from '@kit.ArkUI'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want): void {
    console.info(`EntryAbility onCreate: ${JSON.stringify(want)}`)
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        console.error(`Failed to load page, code=${err.code}, message=${err.message}`)
      }
    })
  }
}
