# How to diff files when building a config plugin

When making a config plugin, you're going to do a lot of comparing native project files between what you did manually and what your config plugin is doing. Ultimately, a config plugin is just making some manual configuration automated and repeatable, so this makes sense.

Here's a few tips for checking your work as you build your config plugin.

## Compare your working copy against what's committed in git

1. Do the manual native configuration.
2. Temporarily remove native projects from your **.gitignore**.
3. Commit that.
4. Work on your config plugin.
5. Run `npx expo prebuild --clean` to regenerate your native projects with your config plugin code added.
6. Check the file differences between your working copy and what's in git.

These comparisons will not be perfect, especially with iOS, as GUID's inside the xcodeproj file will change. But they should be close enough to focus in on particular changes happening in your config plugin.

This works particularly well with a git GUI where you can see diffs visually, such as the Github Desktop or Visual Studio Code.

## Focus in on a single file with Visual Studio Code's comparison tool

1. Do the manual native configuration.
2. Copy the files you would like to compare out of the native folder into another folder (e.g., **compare/project.pbxproj**).
3. Work on your config plugin.
4. Run `npx expo prebuild --clean` to regenerate your native projects with your config plugin code added.
5. Right-click the copied file in Visual Studio Code, and click "Select for Compare".
6. Right-click on the newly-generated file in your native project, and click "Compare with Selected".

Now you'll see a diff side-by-side in Visual Studio Code.

This is great for focusing in on a single file. Consider this for the iOS plugin, where almost all of your changes are in the **project.pbxproj** file. You can leave this diff as an open tab in VS Code and keep referring back to it.

## Running prebuild faster

You can run prebuild on a single platform. Don't bother generating native projects for both platforms when you're only working on one platform at a time:

```
npx expo prebuild --clean --platform ios
```

### Skipping Cocoapods install

On iOS, skipping Cocoapods install on prebuild can make prebuild a lot faster. You can do it like this:

```
npx expo prebuild --clean --platform ios --no-install
```

The one downside is that this will change the diff slightly if you're comparing against a manually-changed file that was generated with the Cocoapods install. Usually you can tell what to ignore, though.
