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
## Exercise 1 (all platforms) - Save data in a common place
Where's a spot that both app and widget can access, even if they're written in different languages? The file system!

We're going to write our most recent share to the app's file storage, so then the widget can read that when it updates.

1. Install `npm install @dr.pogodin/react-native-fs` (this has a special iOS feature we'll use later).

<!-- TODO: figure out what we actually need once demo app is ready -->
2. Let's make a little file access library that we'll use across our app. In **widgets/common**, add **widget-share.ts**:
```jsx
import * as RNFS from "@dr.pogodin/react-native-fs";

function getLatestShareFilePath() {
  return `${RNFS.DocumentDirectoryPath}/latest_share.jpg`;
}

export async function saveLatestShare(fileUri: string) {
  // copy to shared location
  const latestShareFilePath = getLatestShareFilePath();
  await RNFS.copyFile(fileUri, latestShareFilePath);
}

export async function readLatestShareAsBase64() {
  const latestShareFilePath = getLatestShareFilePath();
  const imageBase64 = await RNFS.readFile(latestSharePath, "base64");

  return "data:image/jpg;base64," + imageBase64;
}
```

3. Right before calling `shareAsync`, call your new library:
```tsx
import { saveLatestShare } from "@/widgets/common/widget-share";

// Later...
await saveLatestShare(file.uri);
```

## Exercises - Android

### Exercise 2(a). Switch to react-native-android-widget's provider
Android XML layouts aren't that fun to mess around with. Fortunately, you can create widgets in JSX with [react-native-android-widget](https://saleksovski.github.io/react-native-android-widget/docs/tutorial/register-widget). This library actually does provide a config plugin (though having gone through the whole setup, ours could be a bit more flexible for our use case), but we're just going to use its native code for generating widget views with our config plugin by adapting our config plugin using the [instructions here](https://saleksovski.github.io/react-native-android-widget/docs/tutorial/register-widget).

1. Install the package: `npm install react-native-android-widget`.

2. Update **HelloAppWidget.kt** to inherit from the package's widget provider:
```kt
package com.expo.appjsworkflowscode // or whatever your package is named

import com.reactnativeandroidwidget.RNWidgetProvider

class HelloAppWidget : RNWidgetProvider() {
}
```

3. Update the config plugin to add the service in **AndroidManifest.xml**

4. In **widgets/android**, create **HelloAppWidget.tsx**:
```jsx
import React from 'react';
import { FlexWidget, TextWidget } from 'react-native-android-widget';

export function HelloAppWidget() {
  return (
    <FlexWidget
      clickAction="OPEN_APP"
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

5. In **widgets/android**, create **widget-task-handler.tsx**:
```jsx
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

### Exercise 3(a). Read data into widget

1. Update **HelloAppWidget.tsx** to conditionally show an image if one is available:
```tsx
import React from "react";
import {
  FlexWidget,
  TextWidget,
  ImageWidget,
} from "react-native-android-widget";

interface HelloAppWidgetProps {
  widgetInfo: {
    width: number;
    height: number;
  };
  imageBase64: string | undefined;
}

export function HelloAppWidget({
  widgetInfo,
  imageBase64,
}: HelloAppWidgetProps) {
  return (
    <FlexWidget
      clickAction="OPEN_APP"
      style={{
        height: "match_parent",
        width: "match_parent",
        justifyContent: "center",
        alignItems: "center",
        backgroundColor: "#ffffff",
        borderRadius: 16,
      }}
    >
      {imageBase64 ? (
        <ImageWidget
          image={imageBase64 as `data:image${string}`}
          imageWidth={widgetInfo.width}
          imageHeight={widgetInfo.height}
        />
      ) : (
        <TextWidget
          text="Share your first image"
          style={{
            fontSize: 32,
            fontFamily: "Inter",
            color: "#000000",
          }}
        />
      )}
    </FlexWidget>
  );
}
```

Also note the `widgetInfo` prop. This is the only way to get the absolute width and height of the widget, and must be passed in.

So, let's update **widget-task-handler.tsx** to pass in `widgetInfo`, and it might as well read in the image at that point, as well:
```tsx
  // top
  import { readLatestShareAsBase64 } from "@/widgets/common/widget-share";

  // inside component
  const imageBase64 = await readLatestShareAsBase64();

  // replace renderWidget() call
  props.renderWidget(<HelloAppWidget widgetInfo={props.widgetInfo} imageBase64={imageBase64} />);
```

That'll handle if the widget refreshes itself or gets resized, but it will not update the widget instantly if a new image is shared. We'll need to request an update to do that.

2. In **widget-share.ts**, let's add an `updateWidget()` function:
```tsx
import { requestWidgetUpdate } from "react-native-android-widget";
// ...
async function updateWidget() {
  const latestShareBase64 = await readLatestShareAsBase64();
  requestWidgetUpdate({
    widgetName: "HelloAppWidget",
    renderWidget: (props) => <HelloAppWidget image={latestShareBase64} widgetInfo={props} />,
    widgetNotFound: () => {
      // Called if no widget is present on the home screen
    },
  });
}
```

3. Right before calling `shareAsync`, call `updateWidget()`:
```tsx
import { saveLatestShare, updateWidget } from "@/widgets/common/widget-share";

// Later...
await saveLatestShare(file.uri);
await updateWidget();
```

**Try it.** Run `npx expo run:android` and try sharing some images. Does your widget update? If you resize your widget, what happens to the image?

## Exercises - iOS

### Exercise 1.  Add an app group for sharing data

### Exercise 2. Save a file to the shared location

### Exercise 3. Read the file from the widget

## See the solution
Switch to branch: `05-widgets-part2-solution`