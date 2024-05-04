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

## Exercise 1. Running an update in your development build
Besides your local development environment, a development build can run any JavaScript bundle compatible with your native runtime, including one from an EAS Update. Let's make our first update and run it in your development build.

1. Install the EAS CLI and `expo-updates` if you have not already:
```bash
npm install -g eas-cli

npm install expo-updates
```

2. Login to EAS with your Expo account, and initialize your project for EAS Update:

```bash
eas login

eas init

eas update:configure
```

Now you should have the EAS Update configuration you need in your app.json.

3. Rebuild your development build with `npx expo run:android` or `npx expo run:ios` to incorporate the EAS project ID.

4. Publish an update:
```bash
eas update --branch preview
```

5. Follow the link at the bottom of the update. You'll see a QR code to run the update. You could build to a real device and scan this, or you could login to Expo on the development build on your emulator/simulator and see the update in the "Extensions" tab, but let's do this the hard way and figure out what an updates URL is made of!

<!-- TODO: great place to show some pictures -->

6. Grab your `projectId` from your **app.json** and the `groupId` from the update website, or from `eas update:list`, and plug them into this URL:
```
exp+appjs24-workflows-workshop-code://expo-development-client/?url=https://u.expo.dev/{projectId}/group/{groupId}
```

This URL opens up an update "group" (combined Android/iOS bundle) in a development build.

🏃 **Try it.** Open the URL from the update in your emulator/simulator. If your development build automatically opens up in your app, use the shake gesture (android: COMMAND+M, ios: CTRL+COMMAND+Z) to go back to the app browser interface.

## Exercise 2. Publish EAS Updates with your pull requests

Let's set up a GitHub action that will publish a preview update and comment with a link under each pull request.

1. Create a new branch based on your own main.

> Make sure the branch isn't based on the upstream main (e.g., the repo you forked this from).

2. Create a new file **.github/workflows/eas-update.yml** with content [from here](/files/02/preview.yml).

3. Go to [https://expo.dev/accounts/keith-kurak/settings/access-tokens](https://expo.dev/accounts/keith-kurak/settings/access-tokens) and click **Create Token** to create a new access token.

4. Then go to the following URL, replacing `your-username` with your actual Github username:
```
https://github.com/your-username/appjs24-workflows-workshop-code/settings/secrets/actions
```

5. Under **Repository secrets**, click **New repository secret**.

6. Create a secret with the name `EXPO_TOKEN`, using the token from step 2.

7. Publish your branch, and create a PR merging your branch into __your__ main (not into the upstream main).

🏃**Try it.** Did the PR publish job run?

With the workflow file in place, we should see a check like this appear under our PR:

![GitHub checks](/assets/02/github-checks.png)

And if everything went right, in a couple minutes we will see a comment like this:

![GitHub comment](/assets/02/comment.png)

**OPTIONAL**: If you want to test your PR on a device, you can rebuild the app for your phone using `npx run:$PLATFORM --device`. If you'd rather run the update on your simulator, you can still use the method above for constructing the updates URI.

## Exercise 3: Use PR review workflow to add watermarks

We are not done with feature development: let's add a watermark to the image. We can use the `react-native-image-marker` library for that, which we have previously preinstalled.

1. Add the watermarking step to your `crop()` function:

```ts
const markedImagePath = await Marker.markText({
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

  setEditedImagePath(markedImagePath);
```

Also, here's your imports:
```tsx
import Marker, { Position, TextBackgroundType, ImageFormat } from "react-native-image-marker";import Marker, { Position, TextBackgroundType, ImageFormat } from "react-native-image-marker";
```

🏃**Try it.** Does your image have a watermark now?

2. Update your PR (the Github action will update your PR with a new QR code for the latest update, how cool!).

3. Merge your PR back into __your__ main.

# Bonus

- Login to Expo within your development build and try browsing updates right there.
- There's other formats for updates URL's. Try them out!

TODO: insert updates URL formats here.

## See the solution

Switch to branch: `02-updates-101-solution`
