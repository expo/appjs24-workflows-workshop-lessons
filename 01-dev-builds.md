# Module 01: Development Builds

### Goal

Transition from Expo Go to a Development Build so we can keep the same fast development workflow even after we add extra native modules.

### Concepts

- Running an Expo development environment both in Expo Go and a development build
- Native updates are slow, JS updates are fast, so let’s do less of the former and more of the latter by making one development build that will last us a while.
- Development builds are just debug builds with some extra stuff

### Tasks

- Run a basic project in Expo Go and add a feature (image sharing) that’s compatible with Expo Go
- Make a development build, adding all the packages we’ll need for the rest of the morning
- Add a feature (image cropping) that’s not compatible with Expo Go

### Resources

- Link to any helpful docs

# Exercises

## Exercise 1. Add image sharing with Expo Go

### Some subheading

1. step 1
2. step 2

Add this to **file.tsx**

```ts
<Blah>
  <Whatev />
</Blah>
```

Change **otherfile.tsx**:

```diff
- <Llama />
+ <Alpaca />
```

**Try it.** Call out to remind people to test stuff

## Exercise 2. Make a development build with a native runtime that works with all our upcoming features

Install libraries like... react-native-image-marker, expo-sharing, react-native-image-crop-picker, expo-updates, expo-sharing, expo-application

## Exercise 3: Add image cropping with your Development Build

## See the solution

Switch to branch: `01-dev-builds-solution`
