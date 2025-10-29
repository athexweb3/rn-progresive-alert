import * as React from 'react';

import { RnProgresiveAlertViewProps } from './RnProgresiveAlert.types';

export default function RnProgresiveAlertView(props: RnProgresiveAlertViewProps) {
  return (
    <div>
      <iframe
        style={{ flex: 1 }}
        src={props.url}
        onLoad={() => props.onLoad({ nativeEvent: { url: props.url } })}
      />
    </div>
  );
}
