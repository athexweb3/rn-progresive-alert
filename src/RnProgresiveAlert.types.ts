// RnProgresivealert.types.ts
export type ProgressiveAlertTint =
  | 'blue'
  | 'red'
  | 'green'
  | 'orange'
  | 'purple'
  | 'gray'
  | string;

export interface ProgressiveAlertConfig {
  title: string;
  message: string;
  tint?: ProgressiveAlertTint;
  initialProgress?: number;
  replaceIfPresented?: boolean;
  cancelTitle?: string | null;
  completeAutoDismiss?: boolean;
}

export interface ProgressiveAlertShowResult {
  presented: boolean;
}

export interface ProgressiveAlertDismissResult {
  dismissed: boolean;
}

export type ProgressiveAlertEvent = 'onCancelled' | 'onCompleted';
