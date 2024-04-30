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

We have three pieces here.

An import statement:

```ts
import * as Sharing from "expo-sharing";
```

A share function (put this inside the `ShareWork` screen):

```ts
async function share() {
  await Sharing.shareAsync(work.images.web.url);
}
```

And finally a button to trigger it:

```tsx
<Button onPress={share} title="Share" />
```

## Exercise 2. Make a development build with a native runtime that works with all our upcoming features

Let's try to add cropping to our project. First we need to import some libraries that we had pre-installed in the project:

```ts
import ImagePicker from "react-native-image-crop-picker";
import Marker, {
  ImageFormat,
  Position,
  TextBackgroundType,
} from "react-native-image-marker";
```

Now let's quickly check if the cropping works. Let's add this to the main function in the `app/works/[id]/share.tsx` file:

```ts
async function crop() {
  const image = await ImagePicker.openCropper({
    path: work.images.web.url,
    width: 300,
    height: 300,
    mediaType: "photo",
  });
}
```

And this in the `return` block so that we are able to call it:

```tsx
<Button onPress={crop} title="Crop" />
```

What happened? We got an error:

![Error](/assets/01/error.png)

This is because Expo Go doesn't support arbitrary native dependencies. But there's an easy way to fix it. Let's switch to a development build.

We just need to install the package:

```sh
npx expo install expo-dev-client
```

Now when we restart the `npx expo start`, we will see an error that we are missing `bundleIndentifier`.

Let's build the iOS app `npx expo run:ios` and we will be prompted to fill in the details so that our standalone iOS and Android apps can be built.

This is how we know that we succeeded in making a development build:

![Development Build](/assets/01/dev-build.png)

We can now add `/ios` and `/android` to our `.gitignore` file.

```
/ios
/android
```

### Cropping image

We can now proceed to add image cropping.

```ts
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

We need to adjust the logic for finding the proper image path:

```ts
const path = croppedImage
  ? Platform.OS === "android"
    ? `file:${croppedImage}`
    : croppedImage
  : work && work.images.web.url;
```

```diff
<Image
-  source={{ uri: work && work.images.web.url }}
+  source={{ uri: path }}
```

We should be able to see this screen when we press the button:

![Crop](/assets/01/crop.png)

Let's also change our `share()` implementation to account for the changes we made:

```ts
async function share() {
  if (!croppedImage) {
    return;
  }

  await Sharing.shareAsync(
    Platform.OS === "android" ? `file:${croppedImage}` : croppedImage
  );
}
```

And some changes are required to the button too:

```tsx
<Button
  onPress={croppedImage ? share : undefined}
  disabled={croppedImage === null}
  title="Share"
/>
```

### Marking image

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

## See the solution

Switch to branch: `01-dev-builds-solution`
