//
//  WindowController.swift
//  Jamf Wallpaper
//
//  Created by Leslie Helou on 4/13/22.
//  Copyright © 2022 Jamf. All rights reserved.
//

import Cocoa
import Foundation

class WindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        self.windowFrameAutosaveName = "MainAppWindow"
    }
}
