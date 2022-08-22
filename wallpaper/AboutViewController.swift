//
//  AboutViewController.swift
//  Jamf Wallpaper
//
//  Created by Leslie Helou on 4/13/22.
//  Copyright © 2022 Jamf. All rights reserved.
//

import AppKit
import Cocoa
import Foundation

class AboutViewController: NSViewController {
    
    @IBOutlet weak var about_image: NSImageView!
    
    @IBOutlet weak var appName_textfield: NSTextField!
    @IBOutlet weak var version_textfield: NSTextField!
    @IBOutlet var license_textfield: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // fix for dark/light mode
//        self.view.wantsLayer = true
//        self.view.layer?.backgroundColor = CGColor(gray: 0.13, alpha: 1.0)
        view.window?.titlebarAppearsTransparent = true
        view.window?.isOpaque = false
        
        let iconUrl = Bundle.main.url(forResource: "AppIcon", withExtension: "icns")
        if let rawImageData = try? Data(contentsOf: iconUrl!) {
            if let imageData = NSImage(data: rawImageData) {
                DispatchQueue.main.async { [self] in
                    about_image.image = imageData
                }
            }
        }
        appName_textfield.stringValue = appInfo.name
        version_textfield.stringValue = "Version \(appInfo.version) (\(appInfo.build))"
        license_textfield.string      = """
Copyright © 2022. All rights reserved.

THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE, LLC BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
"""
    }
    
}
