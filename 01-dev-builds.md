# Module 01: Development Builds

### Goal

Transition from Expo Go to a Development Build so we can keep the same fast development workflow even after we add extra native modules.

### Concepts

- Running an Expo development environment both in Expo Go and a development build.
- Native updates are slow, JS updates are fast, so let’s do less of the former and more of the latter by making one development build that will last us a while.
- Development builds are just debug builds with some extra stuff.

### Tasks

- Run a basic project in Expo Go and add a feature (image sharing) that’s compatible with Expo Go.
- Make a development build, adding all the packages we’ll need for the rest of the morning.
- Add a feature (image cropping) that’s not compatible with Expo Go.

### Resources

- Link to any helpful docs

# Exercises

## Exercise 1. New Feature: Image Sharing

We've just joined our pretend project and it's time to add our first social feature: sharing an image with `expo-sharing`. A share button on each work of art will open a new screen for completing the share.

> When you run your app this time to start developing, run `npx expo start`. It'll default to a development build, but press `s` to switch to Expo Go and run it in there. It'll work because we're not **using** any dependencies that are not already built into in Expo Go.

1. Install `expo-sharing` with `npx expo install expo-sharing` (this gets the correct version for your SDK).

2. Add **share.tsx** to **app/works/[id]**. You can get the code for this file [from here](/files/01/share.tsx).

3. Add the share button to **app/works/[id]/index.tsx**, next to the favorite button:

```tsx
<Link push href={`/works/${id}/share`}>
  <Icon name="share-alt" color={colors.tint} size={28} />
</Link>
```

To space those two buttons out better, you can add `gap-3` to `className` of the view containing the two buttons.

<!-- TODO: nice place for an image of the share button -->

4. Import `expo-sharing` and add a share function to the component:

```tsx
import * as Sharing from "expo-sharing";

// ...

async function share() {
  await Sharing.shareAsync(work.images.web.url);
}
```

5. Call the `share()` function in the button's `onPress`.

🏃 **Try it.** See if you can share something!

## Exercise 2(a). New Feature: Crop the image, too

The social media department likes square images for sharing better. So, let's add image cropping.

1. Run `npm install react-native-image-crop-picker`.

2. Add the import:

```tsx
import ImagePicker from "react-native-image-crop-picker";
```

3. Let's quickly check if the cropping works. Add to the main function in the **app/works/[id]/share.tsx** file:

```tsx
async function crop() {
  const image = await ImagePicker.openCropper({
    path: work.images.web.url,
    width: 300,
    height: 300,
    mediaType: "photo",
  });
}
```

And a button calling `crop()` before the Share button:

```tsx
<RoundButton onPress={crop} title="Crop" />
```

🏃 **Try it.** Does cropping work? Or did you even get that far before facing an error?

![Error](/assets/01/error.png)

This is because Expo Go doesn't support any native dependencies that aren't already built into it. But there's an easy way to fix it. Let's switch to a development build.

4. Install the `expo-dev-client` package:

```sh
npx expo install expo-dev-client
```

5. And because we also heard the marketing department might want to later add hashtags to the image, let's add `react-native-image-marker`, as well, so we don't have to rebuild our development build later:

```sh
npx expo install react-native-image-marker
```

**TIP**: If Expo doesn't have a recommended version for a package, `expo install` will just install the latest with your project's package manager, so you can use `expo install` all the time.

6. This time, we need to actually build the app, so run `npx expo run:ios` or `npx expo run:android`. Eventually the app and the bundler will start after the build is complete.

7. Add the **android** and **ios** folders to **.gitignore** so you don't have to check them in (we'll explain this later).

```
/ios
/android
```

<!-- NOTE: we actually want them to set the gitignore in a later lesson -->
<!-- NOTE to the NOTE: actually, not setting gitignore now can mess up module 2 -->

## Exercise 2(b): Cropping image (for real this time, with the development build)

Let's try adding that image cropping functionality again.

1. Add a state variable to store the cropped image path and update `crop()` to save the image to the state variable:

```tsx
// update your import to get the type for the state variable
import ImagePicker from "react-native-image-crop-picker";

// ...

// Add state
const [editedImagePath, setEditedImagePath] = useState<string | undefined>(undefined);

// ...

// update crop
async function crop() {
  const image = await ImagePicker.openCropper({
    path: work.images.web.url,
    width: 300,
    height: 300,
    mediaType: "photo",
  });
  setEditedImagePath(image.path);
}
```

2. Update the image URI to switch between the original image and the cropped version:

```diff
<Image
-  source={{ uri: work && work.images.web.url }}
+  source={{ uri: editedImagePath ? editedImagePath : (work && work.images.web.url) }}
```

3. Let's also change our `share()` implementation to account for the changes we made:

```ts
async function share() {
  await Sharing.shareAsync(editedImagePath);
}
```

4. Disable the Share button in **share.tsx** to complete the effect:

```diff
<RoundButton
  title="Share"
  onPress={share}
+  disabled={!editedImagePath}
/>
```

🏃 **Try it.** You should see a crop screen like the one below and your shared image should reflect your crop.

![Crop](/assets/01/crop.png)

## One more thing

Even though `npx expo run:ios` or `npx expo run:android` both built and ran your development build in one command, now that you have your development build installed, you don't have to wait for the build anymore.

Try killing the bundler process, and running `npx expo start`. Press `a` or `i` to open the app on your Android or iOS emulator/simulator. The Expo CLI should open your development build this time.

## See the solution

Switch to branch: `01-dev-builds-solution`
