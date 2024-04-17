# Module 06: Widgets Part 2

### Goal
Let’s expand on our widget to make something more realistic that actually shares data with our app.

### Concepts
- Adding native code to your app with a local Expo module
- Understanding how existing React Native libraries for widgets work, and why you may or may not want to use them.
- Sharing data with native features outside of your app
- Accepting parameters in config plugins

### Tasks
- Write data from your app to a file so the widget can read it
- Pick one platform to start (if you get done early, you can do the second one), and
    - Extend the config plugin as needed to support the added features
    - Style your widget
    - Read data into the widget

### Resources
- Link to any helpful docs

# Exercises
## Exercises - Android

### Exercise 1. Switch to react-native-android-widget's provider
Android XML layouts aren't that fun to mess around with. Fortunately, you can create widgets in JSX with [react-native-android-widget](https://saleksovski.github.io/react-native-android-widget/docs/tutorial/register-widget). This library actually does provide a config plugin (though having gone through the whole setup, ours could be a bit more flexible for our use case), but we're just going to use its native code for generating widget views with our config plugin by adapting our config plugin using the [instructions here](https://saleksovski.github.io/react-native-android-widget/docs/tutorial/register-widget).

1. Install the package: `npm install react-native-android-widget`.

2. Update **HelloAppWidget.kt** to inherit from the package's widget provider:
```kt
package com.expo.appjsworkflowscode

import com.reactnativeandroidwidget.RNWidgetProvider

class HelloAppWidget : RNWidgetProvider() {
}
```

3. Update the config plugin to add the service in **AndroidManifest.xml**

4. In **widgets/android**, create **HelloAppWidget.jsx**:
```jsx
import React from 'react';
import { FlexWidget, TextWidget } from 'react-native-android-widget';

export function HelloWidget() {
  return (
    <FlexWidget
      style={{
        height: 'match_parent',
        width: 'match_parent',
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#ffffff',
        borderRadius: 16,
      }}
    >
      <TextWidget
        text="Hello"
        style={{
          fontSize: 32,
          fontFamily: 'Inter',
          color: '#000000',
        }}
      />
    </FlexWidget>
  );
}
```

5. In **widgets/android**, create **widget-task-handler.ts**:
```
import React from 'react';
import type { WidgetTaskHandlerProps } from 'react-native-android-widget';
import { HelloAppWidget } from '@/widgets/android/HelloAppWidget';

export async function widgetTaskHandler(props: WidgetTaskHandlerProps) {
  switch (props.widgetAction) {
    case 'WIDGET_ADDED':
    case 'WIDGET_UPDATE':
    case 'WIDGET_RESIZED':
      props.renderWidget(<HelloAppWidget />);
      break;
    case 'WIDGET_CLICK':
      // TODO make this work
      break;

    default:
      break;
  }
}
```

6. Register the Widget task handler
[There's better ways to do this](https://saleksovski.github.io/react-native-android-widget/docs/tutorial/register-task-handler#register-widget-task-handler-expo), but this simple method will work for now. Add this to the top of the root **_layout.tsx**:

```tsx
import { registerWidgetTaskHandler } from 'react-native-android-widget';
import { widgetTaskHandler } from '@/widgets/android/widget-task-handler';

registerWidgetTaskHandler(widgetTaskHandler);
```

**Try it.** Run `npx expo prebuild --clean --platform android && npx expo run:android`, and you should be able to add your new JSX-based widget.

### Exercise 2. Read data into widget

### Exercise 3. Make the widget resizable

## Exercises - iOS

### Exercise 1.  Add an app group for sharing data

### Exercise 2. Save a file to the shared location

### Exercise 3. Read the file from the widget

## See the solution
Switch to branch: `05-widgets-part2-solution`