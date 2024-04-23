import ExpoModulesCore
+import ActivityKit
+import WidgetKit

Function("reloadWidget") { () in
           // Trigger a widget update to sync the data
            if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }