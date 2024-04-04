# Module 04: Intro to config plugins

### Goal
Let’s learn how config plugins modify native projects and let us tap into special native features by using one.

### Concepts
- How config plugins work with CNG to replace “manually update AndroidManifest.xml, entitlements, MainActivity, etc.” steps that are common when tapping into native capabilities that require more than just code.
- Meanwhile, Expo Modules API is a way to wrap native code and access it via JS. Modules are also integrated with CNG, but with autolinking.

### Tasks
- Add expo-quick-actions , setting a custom image in your quick action menu that works on iOS and Android

### Resources
- Link to any helpful docs

# Exercises
## Exercise 1. Add expo-quick-actions and setup an icon with the config plugin

Add the library, set the custom icon, see how the config plugin affects the native projects with npx expo prebuild --clean

## Exercise 2. Use the expo-quick-actions API

## Bonus?
- Static quick actions for iOS

## See the solution
Switch to branch: `04-intro-config-plugins-solution`