import { requireNativeView } from 'expo';
import * as React from 'react';

import { RnProgresiveAlertViewProps } from './RnProgresiveAlert.types';

const NativeView: React.ComponentType<RnProgresiveAlertViewProps> =
  requireNativeView('RnProgresiveAlert');

export default function RnProgresiveAlertView(props: RnProgresiveAlertViewProps) {
  return <NativeView {...props} />;
}
