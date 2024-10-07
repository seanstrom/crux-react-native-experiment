import "fast-text-encoding"

import React, { useEffect, useRef, useState } from 'react';

import {
  Button,
  SafeAreaView,
  StyleSheet,
  Text,
  View,
} from 'react-native';

import {
  ViewModel,
  EventVariantReset,
  EventVariantIncrement,
  EventVariantDecrement,
} from "./shared_types/generated/typescript/types/shared_types";

import { update } from "./src/core";

function App() {
  const [view, setView] = useState(new ViewModel("0"));
  const onReset = () => update(new EventVariantReset(), setView)
  const onIncrement = () => update(new EventVariantIncrement(), setView)
  const onDecrement = () => update(new EventVariantDecrement(), setView)

  const initialized = useRef(false);
  useEffect(() => {
    if (!initialized.current) {
      initialized.current = true;

      update(new EventVariantIncrement(), setView);
    }
  }, []);

  return (
    <View style={styles.mainContainer}>
      <SafeAreaView>
        <Text>{view.count}</Text>
        <Button title="Increment" onPress={onIncrement}></Button>
        <Button title="Decrement" onPress={onDecrement}></Button>
        <Button title="Reset" onPress={onReset}></Button>
      </SafeAreaView>
    </View>
  );
}

const styles = StyleSheet.create({
  mainContainer: {
    flex: 1,
  },
});

export default App;
