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

- [Publish previews on pull requests](https://docs.expo.dev/eas-update/github-actions/#publish-previews-on-pull-requests)

# Exercises

## Exercise 1. Publish an update and run it in a dev build

We can do one more nice thing with our development build: preview updates.

We need to first initialize EAS project:

```bash
npx eas init
```

Then we can see if we can publish an update:

```bash
npx eas update
```

## Exercise 2. Add PR review workflow

Let's set up a GitHub action that will publish a preview update and comment with a link under each pull request.

Let's create a new file `.github/workflows/eas-update.yml` with content [from here](/files/02/preview.yml).

🏃 **Try it.** Make a small change, create a new git branch, commit it and open a Pull Request on GitHub.

With the workflow file in place, we should see a check like this appear under our PR:

![GitHub checks](/assets/02/github-checks.png)

And if everything went right, in a couple minutes we will see a comment like this:

![GitHub comment](/assets/02/comment.png)

To test it, we just need to scan this QR code on our device that has development build installed.

> Note: if until now you have used simulator, you can re-build the app for your phone using `npx run:$PLATFORM --device`, which will allow you to pick a different device.

## Exercise 3: Use PR review workflow to add watermarks

We are not done with feature development: let's add a watermark to the image. We can use the `react-native-image-marker` library for that, which we have previously preinstalled.

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

# Bonus

- Login to Expo within your development build and try browsing updates right there.

## See the solution

Switch to branch: `02-updates-101-solution`
