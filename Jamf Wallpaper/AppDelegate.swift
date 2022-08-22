//
//  AppDelegate.swift
//  Jamf Wallpaper
//
//  Created by Leslie Helou on 4/13/22.
//  Copyright © 2022 Jamf. All rights reserved.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @objc func notificationsAction(_ sender: NSMenuItem) {
//        print("\(sender.identifier!.rawValue)")
//        WriteToLog().message(stringOfText: ["\(sender.identifier!.rawValue)"])
    }
    @IBAction func showAbout(_ sender: Any) {
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let helpWindowController = storyboard.instantiateController(withIdentifier: "aboutWC") as! NSWindowController
        if !windowIsVisible(windowName: "About") {
            helpWindowController.window?.hidesOnDeactivate = false
            helpWindowController.showWindow(self)
        } else {
            let windowsCount = NSApp.windows.count
            for i in (0..<windowsCount) {
                if NSApp.windows[i].title == "About" {
                    NSApp.windows[i].makeKeyAndOrderFront(self)
                    break
                }
            }
        }
    }
    
    func windowIsVisible(windowName: String) -> Bool {
        let options = CGWindowListOption(arrayLiteral: CGWindowListOption.excludeDesktopElements, CGWindowListOption.optionOnScreenOnly)
        let windowListInfo = CGWindowListCopyWindowInfo(options, CGWindowID(0))
        let infoList = windowListInfo as NSArray? as? [[String: AnyObject]]
        for item in infoList! {
            if let _ = item["kCGWindowOwnerName"], let _ = item["kCGWindowName"] {
                if "\(item["kCGWindowOwnerName"]!)" == "Jamf Wallpaper" && "\(item["kCGWindowName"]!)" == windowName {
                    return true
                }
            }
        }
        return false
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        let encoder  = JSONEncoder()
        let defaults = UserDefaults.standard
        
        defaults.set(appInfo.currentPreviewType, forKey: "currentPreviewType")
        defaults.set(appInfo.textPosition, forKey: "textPosition")
        defaults.set(appInfo.textHorizPos, forKey: "textHorizPos")
        defaults.set(appInfo.textVertPos, forKey: "textVertPos")
        defaults.set(appInfo.qrCodeSize, forKey: "qrCodeSize")
        defaults.set(appInfo.qrCodeHorizPos, forKey: "qrCodeHorizPos")
        defaults.set(appInfo.qrCodeVertPos, forKey: "qrCodeVertPos")
        defaults.set(appInfo.overlay, forKey: "overlay")
        defaults.set(appInfo.targetScreen, forKey: "targetScreen")
        
        if let encoded = try? encoder.encode(appInfo.iPadQRCodeRect) {
            defaults.set(encoded, forKey: "iPadQRCodeRect")
        }
        if let encoded = try? encoder.encode(appInfo.iPadTextRect) {
            defaults.set(encoded, forKey: "iPadTextRect")
        }
        if let encoded = try? encoder.encode(appInfo.iPhoneQRCodeRect) {
            defaults.set(encoded, forKey: "iPhoneQRCodeRect")
        }
        if let encoded = try? encoder.encode(appInfo.iPhoneTextRect) {
            defaults.set(encoded, forKey: "iPhoneTextRect")
        }
        
        defaults.set(appInfo.defaultText, forKey: "defaultText")
        defaults.set(appInfo.defaultFontName, forKey: "defaultFontName")
        defaults.set(appInfo.defaultMenuItemFont, forKey: "defaultMenuItemFont")
        defaults.set(appInfo.defaultFontSize, forKey: "defaultFontSize")
        defaults.set(appInfo.defaultTextStyle, forKey: "defaultTextStyle")
        defaults.set(appInfo.defaultBackgroundImageURL, forKey: "defaultBackgroundImageURL")

        if let _ = appInfo.defaultTextColor {
            do {
                let colorData = try NSKeyedArchiver.archivedData(withRootObject: appInfo.defaultTextColor!, requiringSecureCoding: false)
                defaults.set(colorData, forKey: "defaultTextColor")
            } catch {
                WriteToLog().message(theString: "error saving text color")
            }
        }
        defaults.set(appInfo.defaultBackgroundIsColor, forKey: "defaultBackgroundIsColor")
        if appInfo.defaultBackgroundIsColor {
            do {
                let colorData = try NSKeyedArchiver.archivedData(withRootObject: appInfo.defaultBackgroundColor!, requiringSecureCoding: false)
                defaults.set(colorData, forKey: "defaultBackgroundColor")
            } catch {
                WriteToLog().message(theString: "error saving background color")
            }
        }
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    // quit the app if the window is closed - start
    func applicationShouldTerminateAfterLastWindowClosed(_ app: NSApplication) -> Bool {
        return true
    }


}

