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
- Gitignore your ios and android folders to return to a CNG setup.
- Generate `eas.json` to set that variable based on a build profile.
- Create a “production” build using EAS build with `--local`
- Add a screen using the updates UI

### Resources

- [Install app variants on the same device](https://docs.expo.dev/build-reference/variants)
- [Run builds locally or on your own infrastructure](https://docs.expo.dev/build-reference/local-builds)

# Exercises

## Exercise 1. Get back to CNG and setup app variants

<!-- Gitignore native folders, delete native code, switch to dynamic config with app variants, test your app variants with `prebuild --clean` (use env variables inline with commands to simulate). -->

Run `eas build:configure`. It will create the `eas.json` file.

### .gitignore

From now on we will embrace the Continuous Native Generation (CNG) workflow. This means we will `.gitignore` the native folders and let EAS generate them for us.

```diff
storage/**

+/android
+/ios
```

### Dynamic config

We will also switch to dynamic app config. Let's rename `app.json` to `app.config.js`. If you are using VSCode, it's enough to add `export default` in the beginning of the file and it will get automatically transformed from JSON to a JS object on save.

Let;s differentiate between development and production builds by changing the app name.

```diff
+ const IS_DEV = process.env.APP_VARIANT === 'development';

export default {
+   name: IS_DEV ? "MyApp (Dev)" : "MyApp",
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

We can use `eas build --profile development --local` to generate a local build.

TIP: You can use [Orbit](https://expo.dev/orbit), our tool for running builds on simulators and devices.

![Orbit](/assets/03/orbit.png)

🏃 **Try it.** Build app locally and run on your device.

## Exercise 3: Update your app

Let's now add that production updates work. For that we need to build app with `--profile production`. We can then use Orbit to install it on the device. We will notice the ` (dev)` suffix is gone.

> NOTE: if you are running the build on your iOS, use `preview` profile which has is configured for internal distribution. Otherwise it won't work!

In `app/visit.tsx`, let's add code which will read update information:

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

And then we have to display it:

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

We can publish the update using:

```bash
eas update --branch preview --message "Testing preview"
```

We can restart the app and we should see the update information in the visit screen.

# Bonus?

- Add semantic versioning with `extra`
  - See https://github.com/expo/UpdatesAPIDemo for how these could be used to deliver critical updates
- Add automatic app versioning (https://docs.expo.dev/build-reference/app-versions/)

## See the solution

Switch to branch: `03-eas-build-and-prod-solution`
