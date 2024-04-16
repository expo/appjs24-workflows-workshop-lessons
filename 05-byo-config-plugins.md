# Module 05: Build your own config plugins

### Goal
Let’s learn how config plugins modify native projects and let us tap into special native features by using one.

### Concepts
- Establish a good foundation for working with native features by walking through their configuration just like how any native develope would do it
- Config plugins are just doing automatically what native guides tell you to do manually

### Tasks
- Pick one platform to start (if you get done early, you can do the second one)
- Run Prebuild to generate the native project and walk through the configuration manually so you understand it. Save that work to a branch.
- Build a config plugin to create a basic “hello world” widget.

### Resources
- Link to any helpful docs

# Exercises
## Exercise 1. Create an empty config plugin
> Before we break out into individual platforms, let's just make sure our plugin runs at all, even if it does nothing.

### Add the config plugin inside your project

1. Create a new top-level folder called **plugins**.

2. Add `withAndroidWidget.ts`:
```ts
import {
  ConfigPlugin,
  withDangerousMod,
} from "@expo/config-plugins";

const withAndroidWidget: ConfigPlugin = (config) => {
  return withDangerousMod(config, "android", dangerousConfig => {
    console.log("Android widget!")
  })
}

export default withAndroidWidget;
```

3. Add `withIosWidget.ts`:
```ts
import {
  ConfigPlugin,
  withDangerousMod,
} from "@expo/config-plugins";

const withIosWidget: ConfigPlugin = (config) => {
  return withDangerousMod(config, "ios", dangerousConfig => {
    console.log("iOS widget!")
  })
}

export default withAndroidWidget;
```

2. Add a file called **withWidget.ts** that combines the two:
```ts
import { ExpoConfig } from "expo/config";
import withAndroidWidget from "./withAndroidWidget";

const withWidget: ConfigPlugin = (config) => {
  config = withAndroidWidget(config);
  return withIosWidget(config);
}
```

### Call the config plugin from your Expo config

1. Install `ts-node` by running `npm install --dev ts-node`. This will allow us to use TypeScript when running our app config (or anywhere else in Node, as opposed to Metro, where TS already works).
2. Change your **app.config.js** to **app.config.ts**.
3. Update **app.config.ts**:
```diff
+import 'ts-node/register';
+import { ExpoConfig } from 'expo/config';
- module.exports = ({ config }) => {
+module.exports = ({ config } : { config: ExpoConfig }) => {
  return {
```
4. Add your custom plugin to the plugins array:
```ts
plugins: [
  // ...
  ["./plugins/withWidget.ts"],
]
```

**Try it.** Run `npx expo prebuild --clean`. Do you see your console logs?

## Exercise 2. Choose Your Own Widget Adventure
You will now implement the config plugin that sets up a widget for either an iOS or an Android app- your choice. If you finish one of the platforms, you can come back to the other. You might not get to both platforms, and that's OK. Either one will teach you a lot about constructing config plugins.

**Android** - A good variety of editing configurations and adding resource files. Other than file copies, this is all using established mods. A good all-around choice that isn't too difficult and exposes you to a variety of things.

**iOS** - Widgets are much more complicated on iOS. Almost all of this config plugin involves editing the **xcodeproj** file in a dangerous mod. Less variety, but you will feel a lot more familiar with a very complicated concept by the end. Make no mistake; this is hard mode!

For each platform, you will do the following:
1. Perform the setup of the widget manually in Android Studio or Xcode, so you can understand what steps you will need to automate.
2. Write a config plugin to create the basic "Hello World" widget, comparing what your config plugin outputs to how the native projects when you created the widget manually.

Once you've chosen your platform, proceed to the next exercises, ignoring the steps specific to the platform you're not working on.

## Exercise 3. Add a Hello World widget to your app manually

### Setup your working branch

> We'll temporarily stop using CNG on a branch so we can examine our native projects more closely.

1. Create a new branch of your code. Remove the `ios` and `android` entries from your **.gitignore**.
2. Run `npx expo prebuild --clean` to generate fresh native projects.
3. Commit the projects to your branch.

### Android

### iOS

### Exercise 4. Create the config plugin
> Check out the recommendations for [comparing your plugin output to the intended native output](/companions/05/diffing-techniques.md). Use these techniques or something similar to check your progress as you create your plugin.

### Android
[Follow the instructions here for creating an Android plugin](/companions/05/android-plugin.md).

### iOS
[Follow the instructions here for creating an iOS plugin](/companions/05/io-plugin.md).

## See the solution
Switch to branch: `05-byo-config-plugins-solution`