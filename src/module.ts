// src/nativeModule.ts
import { Platform, NativeEventEmitter } from 'react-native';
import { requireNativeModule, EventEmitter } from 'expo-modules-core';
import type {
  ProgressiveAlertConfig,
  ProgressiveAlertDismissResult,
  ProgressiveAlertEvent,
  ProgressiveAlertShowResult,
} from './RnProgresivealert.types';


type NativeModuleType = {
  showAsync(config: ProgressiveAlertConfig): Promise<ProgressiveAlertShowResult>;
  updateAsync(progress: number): Promise<void>;
  dismissAsync(): Promise<ProgressiveAlertDismissResult>;
};


type EmitterSubscriptionLike = { remove(): void };
type EmitterLike = {
  addListener(eventName: string, listener: (...args: any[]) => void): EmitterSubscriptionLike;
};


const NativeModule: NativeModuleType =
  Platform.OS === 'ios'
    ? requireNativeModule<NativeModuleType>('ProgressiveAlert')
    : {
        async showAsync() {
          return { presented: false };
        },
        async updateAsync() {
          // no-op on Android by default
        },
        async dismissAsync() {
          return { dismissed: false };
        },
      };


const emitter: EmitterLike =
  Platform.OS === 'ios'
    ? (new EventEmitter(NativeModule as any) as unknown as EmitterLike)
    : (new NativeEventEmitter() as unknown as EmitterLike);


const clamp01 = (v: number) => Math.max(0, Math.min(1, Number.isFinite(v) ? v : 0));


export function addListener(event: ProgressiveAlertEvent, listener: () => void) {
  return emitter.addListener(event, listener);
}

export async function show(config: ProgressiveAlertConfig): Promise<ProgressiveAlertShowResult> {
  const initial = clamp01(config.initialProgress ?? 0);
  const payload: ProgressiveAlertConfig = { ...config, initialProgress: initial };
  return NativeModule.showAsync(payload);
}

export async function update(progress: number): Promise<void> {
  const clamped = clamp01(progress);
  return NativeModule.updateAsync(clamped);
}

export async function dismiss(): Promise<ProgressiveAlertDismissResult> {
  return NativeModule.dismissAsync();
}
