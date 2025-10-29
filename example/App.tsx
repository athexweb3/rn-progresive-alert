// App.tsx
import React, { useState } from 'react';
import { SafeAreaView, ScrollView, Text, View, Button } from 'react-native';
import { useProgressiveAlert } from 'rn-progresive-alert';

export default function App() {
  const [progress, setProgress] = useState(0);

  // useProgressiveAlert handles events automatically
  const { show, update, dismiss } = useProgressiveAlert(event => {
    if (event === 'onCancelled') {
      console.log('Alert cancelled');
      setProgress(0);
    }
    if (event === 'onCompleted') {
      console.log('Alert completed');
      setProgress(1);
    }
  });

  const startAlert = async () => {
    const { presented } = await show({
      title: 'Uploading...',
      message: 'Please wait while we upload your file.',
      tint: 'blue',
      initialProgress: 0,
      cancelTitle: 'Cancel',
      completeAutoDismiss: false,
    });

    if (!presented) return;

    // Simulate progress
    let p = 0;
    const interval = setInterval(async () => {
      p += 0.1;
      if (p >= 1) {
        clearInterval(interval);
        await dismiss(); // dismiss when done
      } else {
        setProgress(p);
        await update(p);
      }
    }, 500);
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.scroll}>
        <Text style={styles.header}>Progressive Alert Demo</Text>

        <View style={styles.group}>
          <Button title="Show Alert" onPress={startAlert} />
          <Text style={{ marginTop: 10 }}>
            Progress: {(progress * 100).toFixed(0)}%
          </Text>
        </View>

        <View style={styles.group}>
          <Button title="Dismiss Alert" onPress={() => dismiss()} />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = {
  container: { flex: 1, backgroundColor: '#eee' },
  scroll: { padding: 20 },
  header: { fontSize: 30, marginBottom: 20 },
  group: {
    marginVertical: 20,
    padding: 20,
    backgroundColor: '#fff',
    borderRadius: 10,
  },
};
