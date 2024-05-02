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

To space those two buttons out better, you can add `gap-x-4` to `className` of the view containing the two buttons.

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

🏃 **Try it.** Does cropping work? Or is there an error?

![Error](/assets/01/error.png)

This is because Expo Go doesn't support any native dependencies that aren't already built into it. But there's an easy way to fix it. Let's switch to a development build.

4. Install the `expo-dev-client` package:

```sh
npx expo install expo-dev-client
```

5. This time, we need to actually build the app, so run `npx run:ios` or `npx run:android`. Eventually the app and the bundler will start after the build is complete.

<!-- NOTE: we actually want them to set the gitignore in a later lesson -->

## Exercise 2(b): Cropping image (for real this time, with the development build)

Let's finish up adding cropping.

1. Add a state variable to store the cropped image path and update `crop()` to save the image to the state variable:

```tsx
const [croppedImage, setCroppedImage] = useState<string | null>(null);

async function crop() {
  const image = await ImagePicker.openCropper({
    path: work.images.web.url,
    width: 300,
    height: 300,
    mediaType: "photo",
  });
  setCroppedImage(image);
}
```

2. Just before the component's return statement, set a `path` variable that we'll use for switching between the original image and the cropped version:

```ts
const imagePath = croppedImage
  ? Platform.OS === "android"
    ? `file:${croppedImage}`
    : croppedImage
  : work && work.images.web.url;
```

And change the `Image` source to that path:

```diff
<Image
-  source={{ uri: work && work.images.web.url }}
+  source={{ uri: imagePath }}
```

3. Let's also change our `share()` implementation to account for the changes we made:

```ts
async function share() {
  await Sharing.shareAsync(
    Platform.OS === "android" ? `file:${croppedImage}` : croppedImage
  );
}
```

4. Disable the Share button to complete the effect:

```diff
<RoundButton
  title="Share"
  onPress={share}
+  disabled={!croppedImage}
/>
```

🏃 **Try it.** You should see a crop screen like the one below and your shared image should reflect your crop.

![Crop](/assets/01/crop.png)

## One more thing

Even though `npx expo run:ios` or `npx expo run:android` both built and ran your development build in one command, now that you have your development build installed, you don't have to wait for the build anymore.

Try killing the bundler process, and running `npx expo start`. Press `a` or `i` to open the app on your Android or iOS emulator/simulator. The Expo CLI should open your development build this time.

## See the solution

Switch to branch: `01-dev-builds-solution`
