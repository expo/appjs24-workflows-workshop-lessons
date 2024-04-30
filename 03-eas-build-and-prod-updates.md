# Module 03: EAS Build and Production Updates

### Goal

Let’s setup an EAS Build workflow that can install our development and production build side-by-side and update our app in production without a new build via EAS Update.

### Concepts

- How CNG generates our native projects just in time based on project configuration.
- Using eas.json and app.config.js to generate multiple app variants
- Simulating EAS cloud builds locally
- Checking for updates when your app is open using `useUpdates`

### Tasks

- Convert to a dynamic config to change your bundle ID based on an environment variable.
- Gitignore your ios and android folders to return to a CNG setup.
- Generate eas.json to set that variable based on a build profile.
- Create a “production” build using EAS build with `--local`
- Add a screen using the updates UI

### Resources

- Link to any helpful docs

# Exercises

## Exercise 1. Get back to CNG and setup app variants

Gitignore native folders, delete native code, switch to dynamic config with app variants, test your app variants with prebuild --clean (use env variables inline with commands to simulate

### Some subheading

1. step 1
2. step 2

**Try it.** Call out to remind people to test stuff

## Exercise 2. EAS local build

Configure EAS Build, EAS Update. eas.json should have custom profiles for “production-ish” builds. Run the local build

## Exercise 3: Update your app

Test updates to your “production-ish” app, use updates to add a “version info / about” screen that checks your app for updates and shows a refresh button.

# Bonus?

- Add semantic versioning with `extra`
  - See https://github.com/expo/UpdatesAPIDemo for how these could be used to deliver critical updates
- Add automatic app versioning (https://docs.expo.dev/build-reference/app-versions/)

## See the solution

Switch to branch: `03-eas-build-and-prod-solution`
