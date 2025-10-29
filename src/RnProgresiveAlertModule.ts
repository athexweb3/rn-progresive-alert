import { NativeModule, requireNativeModule } from 'expo';

import { RnProgresiveAlertModuleEvents } from './RnProgresiveAlert.types';

declare class RnProgresiveAlertModule extends NativeModule<RnProgresiveAlertModuleEvents> {
  PI: number;
  hello(): string;
  setValueAsync(value: string): Promise<void>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<RnProgresiveAlertModule>('RnProgresiveAlert');
