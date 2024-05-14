# Module 04: Intro to Expo Modules, Config Plugins, and Native Fingerprint

### Goal

Let’s learn how config plugins modify native projects and let us tap into special native features by using one.

### Concepts

- How config plugins work with CNG to replace “manually update AndroidManifest.xml, entitlements, MainActivity, etc.” steps that are common when tapping into native capabilities that require more than just code.
- Meanwhile, Expo Modules API is a way to wrap native code and access it via JS. Modules are also integrated with CNG, but with autolinking.

### Tasks

- Add expo-quick-actions, setting a custom image in your quick action menu that works on iOS and Android
- Take a fingerprint at each step of the way to see how your native runtime changes.

### Resources

- [expo-quick-actions](https://github.com/EvanBacon/expo-quick-actions/blob/c9f54fb948026b75053082660695e0e78f7493b4/example/app.json#L54)

# Exercises

## Exercise 1. Expo Modules and Fingerprint

> Just pick one platform of your choice (iOS or Android) for this step

### Your first fingerprints

> Use `npm install` this time to avoid auto-configuring the `expo-quick-actions` config plugin so we can see the changes to the fingerprint.

1. Run `npx @expo/fingerprint@latest ./ > fingerprint.json` to generate your first fingerprint.
2. Run `npm install expo-quick-actions` to install the module.
3. Run `npx @expo/fingerprint@latest ./ fingerprint.json` to compare your project with your last fingerprint. Did it change?
4. Run `npx @expo/fingerprint@latest ./ > fingerprint.json` again and commit the file to save your newest fingerprint.

### Basic expo-quick-actions implementation

1. Add the following inside the component in your root **\_layout.tsx** file:

```tsx
useQuickActionRouting();

React.useEffect(() => {
  QuickActions.setItems<RouterAction>([
    {
      title: "Visit the museum",
      subtitle: "Plan your next trip",
      icon: Platform.OS === "android" ? undefined : "location",
      id: "0",
      params: { href: "/visit" },
    },
  ]);
}, []);
```

Add these imports (as well as `Platform` and `React` if they're not already there):

```tsx
import * as QuickActions from "expo-quick-actions";
import { useQuickActionRouting, RouterAction } from "expo-quick-actions/router";
```

2. Build your app (e.g., `npx expo run:ios` or `npx expo run:android`).

🏃**Try it.** Open the app, leave the app, long press on the icon. Do you get a quick action?

3. Run `npx @expo/fingerprint@latest ./ fingerprint.json`. Are there any changes?

## Exercise 2. More capabilities via config plugins

1. Copy the "fav" icons from [module 04 files](/files/04/) into your projects.
<!-- TODO: create these files -->
2. In **app.config.js**, add `expo-quick-action`'s associated config plugin. Update the paths as needed:

```json
"plugins": [
  [
     "expo-quick-actions",
     {
       "androidIcons": {
          "fav_icon": {
            "foregroundImage": "./assets/images/adaptive-icon-fav.png",
            "backgroundColor": "#29cfc1"
          }
        },
        "iosIcons": {
          "fav_icon": "./assets/images/fav.png",
        }
      }
   ]
]
```

3. Add a new quick action in root **\_layout.tsx** that uses your icon and goes to the favorites tab:

```diff
QuickActions.setItems<RouterAction>([
  {
    "title": "Visit the museum",
    "subtitle": "Plan your next trip",
    icon: Platform.OS === 'android' ? undefined : "location",
    id: "0",
    params: { href: "/visit" },
  },
+  {
+    "title": "Favorites",
+    "subtitle": "Your must-see exhibits",
+    icon: "fav_icon",
+    id: "1",
+    params: { href: "/two" },
+  },
]);
```

<details>
  <summary>Expand to just get just the added code for easy copying</summary>

  ```tsx
{
  "title": "Favorites",
  "subtitle": "Your must-see exhibits",
  icon: "fav_icon",
  id: "1",
  params: { href: "/two" },
},
  ```

</details>

🏃**Try it.** Build your app on your preferred platform and run it. Do you see the new action with the custom icon?

4. Run `npx @expo/fingerprint@latest ./ fingerprint.json`. What changed this time?

5. See if you can hunt down the changes in the native projects from the config plugin (if you have a lot of extra time, do the first bonus so you have even more changes to look for).

## Bonus

### 1. Static quick actions in iOS

The config plugin also supports adding static actions on iOS- quick actions that will show up before the app is run. Convert the "visit" quick action into a static action using the [example here](https://github.com/EvanBacon/expo-quick-actions?tab=readme-ov-file#config-plugin).

### 2. Implement quick actions for the two most recent favorited exhibits.

Quick actions can chnage all the time. Try it out!

## See the solution

Switch to branch: `04-intro-config-plugins-solution`
