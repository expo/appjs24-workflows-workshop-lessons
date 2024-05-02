# Module 02: Updates 101

### Goal

Let’s setup an internal testing workflow with EAS Update.

### Concepts

- Running an update in a development build.
- Automatically publishing updates for testers when committing code.

### Tasks

- Run an update in your development build.
- Publish a preview of your app as an EAS update on pull request.
- Develop a new feature (watermarks for the shared images) using this new workflow.

### Resources

- Link to any helpful docs

# Exercises

## Exercise 1. Publish an update and run it in a dev build

We can do one more nice thing with our development build: preview updates.

`npx eas update`

## Exercise 2. Add PR review workflow

## Exercise 3: Use PR review workflow to add watermarks

One more thing: let's add a watermark to the image. We can use the `react-native-image-marker` library for that.

We just need to add this part in the `crop()`:

```ts
const markedImage = await Marker.markText({
  backgroundImage: {
    src: image.path,
    scale: 1,
  },
  watermarkTexts: [
    {
      text: "#cma",
      position: {
        position: Position.bottomRight,
      },
      style: {
        color: "#fff",
        fontSize: 20,
        textBackgroundStyle: {
          type: TextBackgroundType.none,
          color: "#000",
          paddingX: 16,
          paddingY: 6,
        },
      },
    },
  ],
  quality: 100,
  filename: image.filename,
  saveFormat: ImageFormat.jpg,
});
```

# Bonus?

- Login to Expo with your development build and try browsing updates right in your development build

## See the solution

Switch to branch: `02-updates-101-solution`
