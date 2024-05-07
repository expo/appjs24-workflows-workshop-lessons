# Module 06: Widgets Part 2

### Goal

Let’s expand on our widget to make something more realistic that actually shares data with our app.

### Concepts

- Adding native code to your app with a local Expo module.
- Understanding how existing React Native libraries for widgets work, and why you may or may not want to use them.
- Sharing data with native features outside of your app.
- Accepting parameters in config plugins.

### Tasks

- Write data from your app to a file so the widget can read it.
- Pick one platform to start (if you get done early, you can do the second one), and
  - Extend the config plugin as needed to support the added features
  - Style your widget
  - Read data into the widget.

### Resources

- Link to any helpful docs.

# Exercises

## Exercise 1 (all platforms) - Save data in a common place

Where's a spot that both app and widget can access, even if they're written in different languages? The file system!

We're going to write our most recent share to the app's file storage, so then the widget can read that when it updates.

1. Install `npm install @dr.pogodin/react-native-fs` (this has a special iOS feature we'll use later).

<!-- TODO: figure out what we actually need once demo app is ready -->

2. Let's make a little file access library that we'll use across our app. In **widgets/common**, add **widget-share.tsx**:

```jsx
import * as RNFS from "@dr.pogodin/react-native-fs";

// you'll find out why this is async later
async function getLatestShareFilePath() {
  return `${RNFS.DocumentDirectoryPath}/latest_share.jpg`;
}

export async function saveLatestShare(fileUri: string) {
  // copy to shared location
  const latestShareFilePath = await getLatestShareFilePath();
  await RNFS.copyFile(fileUri, latestShareFilePath);
}

export async function readLatestShareAsBase64() {
  const latestShareFilePath = await getLatestShareFilePath();
  const imageBase64 = await RNFS.readFile(latestShareFilePath, "base64");

  return "data:image/jpg;base64," + imageBase64;
}

export async function updateWidget() {
  // TODO
}
```

3. Right before calling `shareAsync`, call your new library:

```tsx
import { saveLatestShare, updateWidget } from "@/widgets/common/widget-share";

// Later...
async function share() {
  await saveLatestShare(editedImagePath);
  await updateWidget();
  await Sharing.shareAsync(editedImagePath!);
}
```

## Exercises - Android

### Exercise 2(a). Switch to react-native-android-widget's provider

Android XML layouts aren't that fun to mess around with. Fortunately, you can create widgets in JSX with [react-native-android-widget](https://saleksovski.github.io/react-native-android-widget/docs/tutorial/register-widget). This library actually does provide a config plugin (though having gone through the whole setup, ours could be a bit more flexible for our use case), but we're just going to use its native code for generating widget views with our config plugin by adapting our config plugin using the [instructions here](https://saleksovski.github.io/react-native-android-widget/docs/tutorial/register-widget).

1. Install the package: `npm install react-native-android-widget`.

2. Update **HelloAppWidget.kt** to inherit from the package's widget provider:

```kotlin
package com.expo.appjs24workflowsworkshopcode

import com.reactnativeandroidwidget.RNWidgetProvider

class HelloAppWidget : RNWidgetProvider() {
}
```

3. Update the config plugin to add the service in **AndroidManifest.xml**. Add this function to **plugins/withAndroidWidget.ts**:

```ts
function withAndroidManifestReceiver(
  config: ExpoConfig,
  widgetName: string
) {
  return withAndroidManifest(config, async (androidManifestConfig) => {
    const mainApplication = AndroidConfig.Manifest.getMainApplicationOrThrow(
      androidManifestConfig.modResults
    );
    mainApplication.receiver = mainApplication.receiver ?? [];

    mainApplication.receiver?.push({
      $: {
        "android:name": `.${widgetName}`,
        "android:exported": "false",
      } as any,
      "intent-filter": [
        {
          action: [
            {
              $: {
                "android:name": "android.appwidget.action.APPWIDGET_UPDATE",
              },
            },
            {
              $: {
                "android:name": `${androidManifestConfig.android?.package}.WIDGET_CLICK`,
              },
            },
          ],
        },
      ],
      "meta-data": {
        $: {
          "android:name": "android.appwidget.provider",
          "android:resource": `@xml/${camelToSnakeCase(widgetName)}_info`,
        },
      },
    } as any);
    return androidManifestConfig;
  });
}
```

Then call it right before returning the config in `withAndroidWidget()`:

```ts
config = withAndroidManifestReceiver(config, widgetName);
```


4. In **widgets/android**, create **HelloAppWidget.tsx**:

```jsx
import { FlexWidget, TextWidget } from "react-native-android-widget";

export function HelloAppWidget() {
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
      <TextWidget
        text="Hello"
        style={{
          fontSize: 32,
          fontFamily: "Inter",
          color: "#000000",
        }}
      />
    </FlexWidget>
  );
}
```

5. In **widgets/android**, create **widget-task-handler.tsx**:

```jsx
import type { WidgetTaskHandlerProps } from "react-native-android-widget";
import { HelloAppWidget } from "@/widgets/android/HelloAppWidget";

export async function widgetTaskHandler(props: WidgetTaskHandlerProps) {
  switch (props.widgetAction) {
    case "WIDGET_ADDED":
    case "WIDGET_UPDATE":
    case "WIDGET_RESIZED":
      props.renderWidget(<HelloAppWidget />);
      break;
    default:
      break;
  }
}
```

6. Register the Widget task handler
   [There's better ways to do this](https://saleksovski.github.io/react-native-android-widget/docs/tutorial/register-task-handler#register-widget-task-handler-expo), but this simple method will work for now. Add this to the top of the root **\_layout.tsx**:

```tsx
import { registerWidgetTaskHandler } from "react-native-android-widget";
import { widgetTaskHandler } from "@/widgets/android/widget-task-handler";

registerWidgetTaskHandler(widgetTaskHandler);
```

🏃**Try it.** Run `npx expo prebuild --clean --platform android && npx expo run:android`, and you should be able to add your new JSX-based widget.

### Exercise 3(a). Read data into widget

1. Update **HelloAppWidget.tsx** to conditionally show an image if one is available:

```tsx
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
props.renderWidget(
  <HelloAppWidget widgetInfo={props.widgetInfo} imageBase64={imageBase64} />
);
```

That'll handle if the widget refreshes itself or gets resized, but it will not update the widget instantly if a new image is shared. We'll need to request an update to do that.

2. In **widget-share.tsx**, fill in the `updateWidget()` function:

```tsx
import { requestWidgetUpdate } from "react-native-android-widget";
import { HelloAppWidget } from "@/widgets/android/HelloAppWidget";
// ...
export async function updateWidget() {
  const latestShareBase64 = await readLatestShareAsBase64();
  requestWidgetUpdate({
    widgetName: "HelloAppWidget",
    renderWidget: (props) => (
      <HelloAppWidget imageBase64={latestShareBase64} widgetInfo={props} />
    ),
    widgetNotFound: () => {
      // Called if no widget is present on the home screen
    },
  });
}
```

🏃**Try it.** Run `npx expo run:android` and try sharing some images. Does your widget update? If you resize your widget, what happens to the image?

## Exercises - iOS

### Exercise 2(i). Add an app group for sharing data

Because your main app and its widget extension are technically separate apps with their own bundle ID's, they can't just automatically share data. Instead, they need to be part of an "app group", a sort of shared bundle ID that lets apps share data with each other. A common convention is to prefix your main app's bundle ID with `group.`.

<!-- Didn't adjust this for app variants because we're copying this too many places just to make it work -->

1. Add the needed entitlement for your main app in **app.config.ts**:

```json
"entitlements": {
  "com.apple.security.application-groups": ["group.appjs24-workflows-workshop-code"]
}
```

2. Your app config generates the native entitlements file during prebuild, but the extension will need its own entitlements file plist. Create **widget.entitlements** in **widgets/ios**:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
  <dict>
    <key>com.apple.security.application-groups</key>
    <array>
      <string>group.appjs24-workflows-workshop-code</string>
    </array>
  </dict>
</plist>
```

3. Of course, just adding that file will not be enough. We now need to tell your iOS config plugin code to add the file to the **project.pbxproj** file. Add the following to **withIosWidget.ts**, prior to associating the widget target with the main app target.

Where you call `PBXProject.group()`, add a reference to the entitlements file:

```ts
// @ts-expect-error
PBXFileReference.create(project, {
  path: "widget.entitlements",
  sourceTree: "<group>",
}),
```

Where you setup the `widgetTarget`, add a statement to associate the entitlements file with the build config:

```ts
widgetTarget.setBuildSetting(
  "CODE_SIGN_ENTITLEMENTS",
  path.join(widgetFolderRelativeToIosProject, "widget.entitlements")
);
```

### Exercise 3(i). Save a file to the shared location

1. Update our little file read/write library in **widget-share.tsx** to use the path for the app group for iOS:

```jsx
// add import
import { Platform } from "react-native";

// update this function
async function getLatestShareFilePath() {
  if (Platform.OS === "ios") {
    return await RNFS.pathForGroup("group.appjs24-workflows-workshop-code");
  }
  return `${RNFS.DocumentDirectoryPath}/latest_share.jpg`;
}
```

### Exercise 4(i). Read the file from the widget

Now that we're saving the file to the group path, let's read the same file from the widget. Let's make some updates to **HelloWidget.swift**.

1. Update the **HelloWidget.swift** to display the image. You can copy over the [new HelloWidget.swift](/files/06/HelloWidget.swift).

#### What are we doing here?
This isn't really a SwiftUI workshop, so we're not going into too many details. But, in brief, we are updating the data structure to support image data:

```swift
struct SimpleEntry: TimelineEntry {
    let date: Date
    let imageData: Data?
}
```

And we're updating the timeline function to read the image data from the share filed

```swift
guard let groupDir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.appjs24-workflows-workshop-code") else {
  fatalError("could not get shared app group directory.")
}

let fileUrl = groupDir.appendingPathComponent("latest_share.jpg")
  do {
      let imageData = try Data(contentsOf: fileUrl)
      let entry = SimpleEntry(date: Date(), imageData: imageData)
      // Some other stuff to make the widget update...
      let timeline = Timeline(entries: [entry], policy: .atEnd)
      completion(timeline)
  } catch {
      let entry = SimpleEntry(date: Date(), imageData: nil)
      let timeline = Timeline(entries: [entry], policy: .atEnd)
      completion(timeline)
  }
```

🏃**Try it.** The updates may not show up right away in your widget (see directly below), but hopefully all this code runs!

### Exercise 5(i). The smallest Expo Module ever: refresh the widget on-demand

Everything here should technically work and would update your widget... at some point. We really want the image in the widget to change immediately when an image is shared. We're going to create a very small Expo Module to let us access this native command.

1. Create the local Expo Module by running:

```bash
npx create-expo-module@latest --local
```

2. This is an iOS-only module, so let's a delete a bunch of files we don't need. When you're done, these should be the **only** files:

- **index.ts**
- **expo-module.config.json**
- **ios**:
  - **IosWidgetRefreshModule.swift**
  - **IosWidgetRefresh.podspec**

3. For iOS, the function signature can be automatically inferred from native code, so we're going update **index.ts** to do just that:

```ts
import { requireOptionalNativeModule } from "expo-modules-core";

export default requireOptionalNativeModule("IosWidgetRefresh");
```

4. Update **IosWidgetRefreshModule.swift**:

```swift
import ExpoModulesCore
import WidgetKit

public class IosWidgetRefreshModule: Module {
  public func definition() -> ModuleDefinition {
    Name("IosWidgetRefresh")

    Constants([:])

    Function("reloadWidget") { () in
      if #available(iOS 14.0, *) {
          WidgetCenter.shared.reloadAllTimelines()
      }
    }
  }
}
```

5. Remove the `android` entry from **expo-module.config.json**.

> If you're not sure if you made all these changes, you can copy the [local module folder over to your project](/files/06/modules).

6. In **widget-share.tsx**, let's add (or update if it's already there) the `updateWidget()` function:

```tsx
import IosWidgetRefresh from "@/modules/ios-widget-refresh";
import { Platform } from "react-native";
// ...
export async function updateWidget() {
  // leave android code alone
  if (Platform.OS === "ios") {
    IosWidgetRefresh.reloadWidget();
  }
}
```

🏃**Try it.** Does the widget update as soon as you share a file?

## See the solution

Switch to branch: `05-widgets-part2-solution`

## Notes about building signed versions for iOS

We're using simulators and ignoring Apple teams and provisioning profiles fow now to keep things simple, focusing on the feature itself. However, for an actual production version (or even an ad-hoc testing version), you'll need real Apple signing stuff for both your main app and the app extension.

You'll notice we skipped on setting the "development team" in the iOS plugin code. If you set that, it'll assign the correct development team for the extension.

EAS Build will automatically apply your credentials for your main app, but doesn't automatically know to do that for your app extension. However, there is a secret property that can help with this. Set this in the `extra` in your app config:

```json
"eas": {
  "build": {
    "experimental": {
      "ios": {
        "appExtensions": [
          {
            "bundleIdentifier": "com.expo.appjs24-workflows-workshop",
            "targetName": "HelloWidget",
            "entitlements": {
              "com.apple.security.application-groups": ["group.appjs24-workflows-workshop"]
            }
          }
        ]
      }
    }
  }
}
```
