# Creating the Android config plugin

## Background

This plugin's job is to copy the widget-specific files over to the Android project folder, and modify the files (especially **AndroidManifest.xml**) that incorporate the widget into the rest of the app.

## Setting up top level variables

There's a few things that will be referred to a lot within the config plugin. Things like:

- project root (e.g., the top-level folder)
- native project root (**android**)

So, let's put those in **withAndroidWidget.ts**. Remove the reference to `withDangerousMod`, return the `config`, and add the variables right at the top of the function:

```diff
const withAndroidWidget: ConfigPlugin = (config) => {
-  return withDangerousMod(config, [
-    "android",
-    (dangerousConfig) => {
-      console.log("Android widget!");
-      return dangerousConfig;
-    },
-  ]);
+  const widgetName = "HelloAppWidget";
+  const widgetPath = "widgets/android";
+
+  // .. rest of plugin code goes here
+
+  return config;
};

```

<details>
  <summary>Expand to just get the whole file's new code for easy copying</summary>

  ```ts
import { ConfigPlugin } from "@expo/config-plugins";

const withAndroidWidget: ConfigPlugin = (config) => {
  const widgetName = "HelloAppWidget";
  const widgetPath = "widgets/android";

  // .. rest of plugin code goes here

  return config;
};

export default withAndroidWidget;
  ```

</details>

Also, add a function somewhere in the file to let us use the one widget name to derive other file names:

```ts
const camelToSnakeCase = (str: string) =>
  str.replace(/([a-zA-Z])(?=[A-Z])/g, "$1_").toLowerCase();
```

## Copy widget files

Create a new function called `withWidgetFiles`, passing the `widgetName` and `widgetPath` to it:

```ts
function withWidgetFiles(
  config: ExpoConfig,
  widgetName: string,
  widgetPath: string
) {
  return withDangerousMod(config, [
    "android",
    (dangerousConfig) => {
      const widgetFilesRoot = path.join(
        dangerousConfig.modRequest.projectRoot,
        widgetPath
      );

      const appPackageFolder = path.join(
        dangerousConfig.modRequest.platformProjectRoot,
        "app/src/main/java/" + config.android?.package?.split(".").join("/")
      );
      fs.copyFileSync(
        path.join(widgetFilesRoot, "HelloAppWidget.kt"),
        path.join(appPackageFolder, `${widgetName}.kt`)
      );

      const resFolder = path.join(
        dangerousConfig.modRequest.platformProjectRoot,
        "app/src/main/res"
      );

      fs.mkdirSync(path.join(resFolder, "xml"), { recursive: true });
      const widgetInfoFilename = `${camelToSnakeCase(widgetName)}_info.xml`;
      fs.copyFileSync(
        path.join(widgetFilesRoot, widgetInfoFilename),
        path.join(resFolder, "xml", widgetInfoFilename)
      );

      fs.mkdirSync(path.join(resFolder, "layout"), { recursive: true });
      const widgetLayoutFilename = `${camelToSnakeCase(widgetName)}.xml`;
      fs.copyFileSync(
        path.join(widgetFilesRoot, widgetLayoutFilename),
        path.join(resFolder, "layout", widgetLayoutFilename)
      );

      return dangerousConfig;
    },
  ]);
}
```

> **That's a lot of code! What's it doing?** It's just copying the files that you copied to the **widgets/android** folder earlier.

Add this to `withAndroidWidget`, prior to returning the config:

```ts
config = withWidgetFiles(config, widgetName, widgetPath);
```

You'll probably have some missing references, so let's update them with everything we need:

```ts
import {
  ConfigPlugin,
  withAndroidManifest,
  AndroidConfig,
  withDangerousMod,
  withStringsXml,
} from "expo/config-plugins";
import { ExpoConfig } from "expo/config";
import fs from "fs";
import path from "path";
```

🏃**Try it.** Run `npx expo prebuild --clean --platform android`. Inspect your files and see if it applied the changes you made to the config plugin.

## Set string resources

Add a function to set our lone string resource. We'll use the `withStringsXml` default mod to help with this. You can set your changes on `modResults` and it'll automatically write the changes to the **strings.xml** file at the end of the plugin execution:

```ts
function withWidgetDescription(config: ExpoConfig) {
  return withStringsXml(config, (stringsXml) => {
    stringsXml.modResults = AndroidConfig.Strings.setStringItem(
      [
        {
          $: {
            name: `app_widget_description`,
            translatable: "false",
          },
          _: "a widget that says hello",
        },
      ],
      stringsXml.modResults
    );
    return stringsXml;
  });
}
```

Add this to the mod chain in `withAndroidWidget`:

```ts
config = withWidgetDescription(config);
```

## Modify Android Manifest

Add a function to register the widget receiver and layout in **AndroidManifest.xml**. This will use the `withAndroidManifest` default mod:

```ts
function withAndroidManifestReceiver(config: ExpoConfig, widgetName: string) {
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

Add this to the mod chain in `withAndroidWidget`:

```ts
config = withAndroidManifestReceiver(config, widgetName);
```

🏃**Try it.** Run `npx expo prebuild --clean --platform android`. Does it apply the configuration correctly? Can you run it and see the widget with `npx expo run:android`?
