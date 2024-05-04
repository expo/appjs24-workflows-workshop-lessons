# Module 03: EAS Build and Production Updates

### Goal

Let’s setup an EAS Build workflow that can install our development and production build side-by-side and update our app in production without a new build via EAS Update.

### Concepts

- How CNG generates our native projects just in time based on project configuration.
- Using `eas.json` and `app.config.js` to generate multiple app variants
- Simulating EAS cloud builds locally
- Checking for updates when your app is open using `useUpdates`

### Tasks

- Convert to a dynamic config to change your bundle ID based on an environment variable.
- Generate `eas.json` to set that variable based on a build profile.
- Create a “production” build using EAS build with `--local`
- Add a screen using the updates UI

### Resources

- [Install app variants on the same device](https://docs.expo.dev/build-reference/variants)
- [Run builds locally or on your own infrastructure](https://docs.expo.dev/build-reference/local-builds)

# Exercises

## Exercise 1. Setup app variants

1. Run `eas build:configure`. It will create the **eas.json** file.

### FYI: Gitignoring native projects

Remember how we added the **android** and **ios** native projects to **.gitignore**? We did that just for convenience before, so you didn't have to push a lot of files and risk a messy merge. But, now it really matters! We're going to be regenerating native projects in ways that can be quite different from run to run. Therefore, it's important to start fresh. Gitignoring your natiive projects tells EAS Build to generate a fresh copy each time from its template, your **package.json**, **app.json**, etc.

### Dynamic config

We will also switch to dynamic app config, which will let us change its values based on environment variables, thus creating different variatios of our build

1. Rename **app.json** to **app.config.js**.

2. Add `export default` in front of the JSON of the file. Right-click and choose "Format Document", and that JSON should turn into a JS object.

3. Let's differentiate between development and production builds by changing the app name.

```diff
+ const IS_DEV = process.env.APP_VARIANT === 'development';

export default {
+   name: IS_DEV ? "Art Museum (Dev)" : "Art Museum",
```

Let's also update the `packageName` (Android) and/or `bundleIdentifier` (iOS) to change based on whether its a development build:

```diff
ios: {
      supportsTablet: true,
-      bundleIdentifier: "com.[username].appjs24-workflows-workshop-code",
+      bundleIdentifier: "com.[username].appjs24-workflows-workshop-code" + IS_DEV ? "-dev" : "",
    },
    android: {
      adaptiveIcon: {
        foregroundImage: "./assets/images/adaptive-icon.png",
        backgroundColor: "#ffffff",
      },
-      package: "com.[username].appjs24workflowsworkshopcode",
+      package: "com.[username].appjs24workflowsworkshopcode" + IS_DEV ? "dev" : "",
    },
```

We should also update `eas.json` file to use the `APP_VARIANT` environment variable.

```diff
{
  "build": {
    "development": {
+       "env": {
+         "APP_VARIANT": "development"
+       }
```

## Exercise 2. EAS local build

1. Run `eas build --profile development --platform android --local` (or use `--platform ios` instead) to generate a local build.

**TIP**: You can use [Orbit](https://expo.dev/orbit), our tool for running builds on simulators and devices.

![Orbit](/assets/03/orbit.png)

🏃**Try it.** Build app locally and run on your device. It'll install alongside your old build (due to the bundle ID change).

**TIP**: You can start on the next part while you wait for your build to finish.

### Interlude: A little cleanup

We will keep using `npx expo run:android` or `npx expo run:ios` later to run local development builds. We want to make sure those still use the correct dynamic config.

Update `scripts` in **package.json** to add this variable when they're used:

```json
"scripts": {
    "start": "APP_VARIANT=development expo start",
    "android": "APP_VARIANT=development expo run:android",
    "ios": "APP_VARIANT=development expo run:ios",
```

Now you can run `npm run android` or `npm run ios` to get the exact same build.

## Exercise 3: Checking for updates
We are ramping up to the point where we publish updates in production. Normally, an update starts downloading after an app cold start, and then is applied on the next cold start after that. However, we can make this faster with the `expo-updates` JS API for update checking and downloading on-demand.

How you check and prompt for updates in your app is up to you, but a nice lightweight way to sneak this API into your app is to take an existing "About" page, add some version info, and indicate near that info if an update is available, and provide a reload button. Let's do that with the **Visit** screen.

1. In `app/visit.tsx`, let's add code which will read update information:

```diff
export default function VisitScreen() {
  const { isLarge } = useMediaQuery();

+   const updateInfo = Updates.useUpdates();
+
+   useEffect(() => {
+     (async function runAsync() {
+       const status = await Updates.checkForUpdateAsync();
+       if (status.isAvailable) {
+         await Updates.fetchUpdateAsync();
+       }
+     })();
+   }, []);
```

2. And then we have to display it:

```tsx
return (
  <View>
    {/* Existing code */}
    <View className="row-y-2 items-center my-10 mx-10">
      <Text className="text-l font-bold">Version</Text>
      <Text className="text-l">
        {Application.nativeApplicationVersion}-{Application.nativeBuildVersion}
      </Text>
      <Text className="text-l">{Updates.updateId || "n/a"}</Text>
      {updateInfo.isChecking || updateInfo.isDownloading ? (
        <ActivityIndicator size="small" />
      ) : null}
      {updateInfo.isUpdateAvailable && updateInfo.isUpdatePending ? (
        <Pressable
          onPress={() => {
            Updates.reloadAsync();
          }}
        >
          <Text className="text-xl my-2 text-tint">Update your app</Text>
        </Pressable>
      ) : null}
      {updateInfo.downloadError ? (
        <>
          <Text className="text-l my-2 text-center">
            There's an update available for your app, but the download failed.
          </Text>
          <Text className="text-l my-2 text-center">
            {updateInfo.downloadError?.message}
          </Text>
        </>
      ) : null}
    </View>
    {/* ... */}
  </View>
);
```

🏃**Try it.** You should see the version info, though updates do not run in development mode, so you will not see the Update ID.

## Exercise 4: Production-ish app variant

Since we're building on simulators, we can't precisely replicate production, but we can get pretty close. Let's make a "production-ish" profile, that simulates a production environment on an emulator/simulator.

1. Add this profile to **eas.json**:

```json
"production:pretend" : {
  "channel": "production",
  "ios": {
    "simulator": true
  },
  "android": {
    "buildType": "apk"
  }
}
```

2. Run `eas build --profile production:pretend --platform android --local` (or use `--platform ios` instead). Install the build on your simulator.

## Exercise 5: Update your "production-ish" variant

1. Make a tiny change. Something you'd notice.

2. Publish an update using:

```bash
eas update --branch production --message "Testing preview"
```

🏃**Try it.** Open and close the Visit page until you see the update show up, and then reload the app.

# Bonus?

- Add semantic versioning with `extra`
  - See https://github.com/expo/UpdatesAPIDemo for how these could be used to deliver critical updates
- Add automatic app versioning (https://docs.expo.dev/build-reference/app-versions/)

## See the solution

Switch to branch: `03-eas-build-and-prod-solution`
