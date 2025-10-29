import { registerWebModule, NativeModule } from 'expo';

import { RnProgresiveAlertModuleEvents } from './RnProgresiveAlert.types';

class RnProgresiveAlertModule extends NativeModule<RnProgresiveAlertModuleEvents> {
  PI = Math.PI;
  async setValueAsync(value: string): Promise<void> {
    this.emit('onChange', { value });
  }
  hello() {
    return 'Hello world! 👋';
  }
}

export default registerWebModule(RnProgresiveAlertModule, 'RnProgresiveAlertModule');
