// src/useProgressiveAlert.ts
import { useCallback, useEffect, useRef } from 'react';
import type { ProgressiveAlertConfig } from './RnProgresivealert.types';
import {
  show as nativeShow,
  update as nativeUpdate,
  dismiss as nativeDismiss,
  addListener as nativeAddListener,
} from './module';


export type HookProgressiveAlertEvent = 'onCancelled' | 'onCompleted';

export function useProgressiveAlert(onEvent?: (event: HookProgressiveAlertEvent) => void) {
  const visibleRef = useRef(false);

  useEffect(() => {
    if (!onEvent) return;


    const subCancel = nativeAddListener("onCancelled", () => {
      try { onEvent('onCancelled'); } catch { /* ignore listener errors */ }
      visibleRef.current = false;
    });

    const subComplete = nativeAddListener("onCompleted", () => {
      try { onEvent('onCompleted'); } catch { /* ignore listener errors */ }
      visibleRef.current = false;
    });

    return () => {
      subCancel.remove();
      subComplete.remove();
    };
  }, [onEvent]);

  const show = useCallback(async (config: ProgressiveAlertConfig) => {
    const result = await nativeShow(config);
    visibleRef.current = result.presented;
    return result;
  }, []);

  const update = useCallback(async (progress: number) => {
    if (!visibleRef.current) {
      console.warn('ProgressiveAlert is not visible. Call show() first.');
      return;
    }
    await nativeUpdate(progress);
  }, []);

  const dismiss = useCallback(async () => {
    const result = await nativeDismiss();
    visibleRef.current = !result.dismissed;
    return result;
  }, []);

  return {
    show,
    update,
    dismiss,
    isVisible: visibleRef.current,
  };
}
