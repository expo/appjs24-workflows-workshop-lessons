# Creating the iOS config plugin
## Background- the project.pbxproj file
This file is a beast full of XML that touches practically everything in an iOS project. It almost looks like Apple doesn't want you to edit it directly ;-)

Nonetheless, we can!

We're going to use [@bacons/xcode](https://github.com/EvanBacon/xcode) to edit the file, adding our plugin code files and assets, registering a new build target (all widgets are their own build target, with their own bundle identifier), and setting up build phases for the new target.

## There's actually already a config plugin for this, and it's going to help us
[expo-apple-targets](https://github.com/EvanBacon/expo-apple-targets) can add arbitrary Apple targets, including widget extensions. It's still experimental, so, if you're going to work with Apple targets, it helps a lot to understand them at the level we're going into. However, we will adapt some utility functions from `expo-apple-targets` to make our work just a little easier.

1. Copy [apple-utils.ts](/files/05/apple-utils.ts) to your **plugins** folder.
2. Speaking of these utilities, now is a good time to install the dependencies we need:
```
npm install --dev @bacons/xcode glob
```

## Setting up top level variables
There's a few things that will be referred to a lot within the config plugin. Things like:
- project root (e.g., the top-level folder)
- native project root (**ios**)
- the name of the widget extension ("HelloWidget")
- the widget bundle ID (your bundle id plus `HelloWidget`)

So, let's put those in **withIosWidget.ts**, right inside the `withDangerousMod` callback:
```ts
// constants
const widgetFolderName = "HelloWidget";
const widgetBundleId = dangerousConfig.ios!.bundleIdentifier! + "." + "HelloWidget";
const widgetExtensionFrameworks = ["WidgetKit", "SwiftUI"];
const developmentTeamId = undefined;

// absolute directories we need when reading files from disk
const projectRoot = dangerousConfig.modRequest.projectRoot;
const widgetRoot = path.join(
  projectRoot,
  "widgets/ios/"
);

// relative directories referenced by Xcode (relative to ios folder)
const widgetFolderRelativeToIosProject = "../widgets/ios/"
```

This is a good time to add some utility package references you'll need at the top of the file, as well as everything we'll need from `@bacons/xcode`. Here's your new imports:
```ts
import { ConfigPlugin, withDangerousMod, IOSConfig } from "@expo/config-plugins";
import path from "path";
import fs from "fs";
import { globSync } from "glob";
import {
  PBXGroup,
  XcodeProject,
  PBXBuildFile,
  PBXFileReference,
  PBXSourcesBuildPhase,
  PBXFrameworksBuildPhase,
  PBXResourcesBuildPhase,
  PBXContainerItemProxy,
  PBXTargetDependency,
  PBXCopyFilesBuildPhase,
} from "@bacons/xcode";
import * as xcodeParse from "@bacons/xcode/json";
import { addFrameworksToDisplayFolder, createConfigurationList, getOrCreateBuildFile, getFramework, applyDevelopmentTeamIdToTargets } from "./apple-utils";
```

## Read iOS project and input files, bind them to Xcode project files
Below your constants, open the Xcode project file and read the files you added to the **widgets** folder. These will be used in subsequent steps. The cool thing about leaving these files in-place while referencing in the **.pbxproj** file is that you can open Xcode, edit these files, and they will update in your native project and the changes can be committed to source control. So, you can have full intellisense for SwiftUI!

Add this code:
```ts

// open the Xcode project file
// Now we can start creating objects inside of it
const project = XcodeProject.open(
  IOSConfig.Paths.getPBXProjectPath(dangerousConfig.modRequest.projectRoot)
);

// grab all swift files in the project, create refs with their basenames
const swiftFiles = globSync("*.swift", {
  absolute: true,
  cwd: widgetRoot,
}).map((file) => {
  return PBXBuildFile.create(project, {
    fileRef: PBXFileReference.create(project, {
      path: path.basename(file),
      sourceTree: "<group>",
    }),
  });
});

// do the same for the assets folder
let assetFiles = [
  "*.xcassets",
]
  .map((glob) =>
    globSync(glob, {
      absolute: true,
      cwd: widgetRoot,
    }).map((file) => {
      return PBXBuildFile.create(project, {
        fileRef: PBXFileReference.create(project, {
          path: path.basename(file),
          sourceTree: "<group>",
        }),
      });
    })
  )
  .flat();
```

The contents of `swiftFiles` and `assetFiles` will be Xcode project file references.

## Bind those widget files into groups
The next snippet will create a "group" containing all the widget files, and then add that group to the main project files group. After this, you'll be able to open the project in Xcode and see a "HelloWidget" folder under the project, but it will contain files that are actually in **widgets/ios**:

```ts
// create widget group
const group = PBXGroup.create(project, {
  name: widgetFolderName,
  sourceTree: "<group>",
  path: widgetFolderRelativeToIosProject,
  children: [
    // @ts-expect-error
    ...swiftFiles
      .map((buildFile) => buildFile.props.fileRef)
      .sort((a, b) =>
        a.getDisplayName().localeCompare(b.getDisplayName())
      ),
    // @ts-expect-error
    ...assetFiles
      .map((buildFile) => buildFile.props.fileRef)
      .sort((a, b) =>
        a.getDisplayName().localeCompare(b.getDisplayName())
      ),
    // you may have noticed we didn't create a file reference for this yet- we do it now inline
    // @ts-expect-error
    PBXFileReference.create(project, {
      path: "Info.plist",
      sourceTree: "<group>",
    }),
  ],
});

//add widget group to main group
project.rootObject.props.mainGroup.props.children.unshift(group);
```

## Weird Xcode housekeeping stuff (sorry!)
Add these next. Read the comments if they interest you.

```ts
// Add the widget target to the display folder (cosmetic, makes it look like a normal Xcode project when you open it)
addFrameworksToDisplayFolder(
  project,
  widgetExtensionFrameworks.map((framework) => getFramework(project, framework))
);

// this file is generated when the widget is built and put into the main target.
const appexBuildFile = PBXBuildFile.create(project, {
  fileRef: PBXFileReference.create(project, {
    explicitFileType: "wrapper.app-extension",
    includeInIndex: 0,
    path: widgetFolderName + ".appex",
    sourceTree: "BUILT_PRODUCTS_DIR",
  }),
  settings: {
    ATTRIBUTES: ["RemoveHeadersOnCopy"],
  },
});

project.rootObject.ensureProductGroup().props.children.push(
  // @ts-expect-error
  appexBuildFile.props.fileRef
);
```

**Is this getting messy?** You can refactor these into smaller chunks whenever you'd like!

## Create the widget extension target
Actually, if you want to refactor anything into a separate function, consider making one that creates the widget extension target and returns it to be included in the main project. What we're doing now is creating the widget extension. We're going to keep going assuming that you put this all in one function, though, to keep the instructions simple.

Add this next to create the widget target and setup its build phases:
```ts
const widgetTarget = project.rootObject.createNativeTarget({
  buildConfigurationList: createConfigurationList(project, {
    name: widgetFolderName,
    cwd: widgetFolderRelativeToIosProject,
    bundleId: widgetBundleId,
    deploymentTarget: "17.4",
    currentProjectVersion: "1",
  }),
  name: widgetFolderName,
  productName: widgetFolderName,
  // @ts-expect-error
  productReference:
  appexBuildFile.props.fileRef /* .appex */,
  productType: "com.apple.product-type.app-extension",
});

widgetTarget.createBuildPhase(PBXSourcesBuildPhase, {
  files: [
    ...swiftFiles,
  ],
});

widgetTarget.createBuildPhase(PBXFrameworksBuildPhase, {
  files: widgetExtensionFrameworks.map((framework) =>
    getOrCreateBuildFile(project, getFramework(project, framework))
  ),
});

widgetTarget.createBuildPhase(PBXResourcesBuildPhase, {
  files: [...assetFiles],
});
```

## Link the widget target to the rest of your app
This is the part that takes all that Widget setup- all the files and build configuration and such- and links it to main app target, so the widget is built and packaged up at the same time as the rest of your app.

Add this:
```ts
const mainAppTarget = project.rootObject.getMainAppTarget("ios");

const containerItemProxy = PBXContainerItemProxy.create(project, {
  containerPortal: project.rootObject,
  proxyType: 1,
  remoteGlobalIDString: widgetTarget.uuid,
  remoteInfo: widgetFolderName,
});

const targetDependency = PBXTargetDependency.create(project, {
  target: widgetTarget,
  targetProxy: containerItemProxy,
});

// Add the target dependency to the main app, should be only one.
mainAppTarget!.props.dependencies.push(targetDependency);

// plug into build phases
mainAppTarget!.createBuildPhase(PBXCopyFilesBuildPhase, {
  dstSubfolderSpec: 13,
  buildActionMask: 2147483647,
  files: [appexBuildFile],
  name: "Embed Foundation Extensions",
  runOnlyForDeploymentPostprocessing: 0,
});

// optionally add the team (needed for testing on device)
// how to get team ID: https://help.graphy.com/hc/en-us/articles/6913285345053-iOS-How-to-find-Team-ID-for-Apple-Developer-Account
const myDevelopmentTeamId = developmentTeamId ?? mainAppTarget!.getDefaultBuildSetting("DEVELOPMENT_TEAM");
applyDevelopmentTeamIdToTargets(project, myDevelopmentTeamId);
```

## Write the project file
All that just worked on **project.pbxproj** in memory. Let's write it to disk:
```ts
const contents = xcodeParse.build(project.toJSON());
if (contents.trim().length) {
  fs.writeFileSync(
    IOSConfig.Paths.getPBXProjectPath(projectRoot),
    contents
  );
}
```

**Try it.** Run `npx expo prebuild --clean --platform ios`. Does it apply the configuration correctly? Can you run it and see the widget with `npx expo run:ios`?
