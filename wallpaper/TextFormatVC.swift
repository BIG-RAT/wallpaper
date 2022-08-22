//
//  TextFormatVC.swift
//  Jamf Wallpaper
//
//  Created by Leslie Helou on 4/13/22.
//  Copyright © 2022 Jamf. All rights reserved.
//

import AppKit
import Cocoa
import Foundation

protocol SendingTextFormatDelegate {
    func sendTextFormat(textFormat: (String, Float, NSColor, Bool, Bool, Bool))
}

class TextFormatVC: NSViewController, NSTextFieldDelegate {
    
    var delegate: SendingTextFormatDelegate? = nil
    
    let colorPanel = NSColorWell()
    
    @IBOutlet weak var colorBorder_textfield: NSTextField!
    @IBOutlet weak var fontList_button: NSPopUpButton!
    @IBOutlet weak var textColor_button: NSButton!
    @IBOutlet weak var textSize_textfield: NSTextField!
    @IBOutlet weak var sizeStepper_stepper: NSStepper!
    
    @IBOutlet weak var boldText_button: NSButton!
    @IBOutlet weak var italicText_button: NSButton!
    @IBOutlet weak var underlinedText_button: NSButton!
    
    @IBOutlet weak var justifiedLeft_button: NSButton!
    @IBOutlet weak var justifiedCenter_button: NSButton!
    @IBOutlet weak var justifiedRight_button: NSButton!
    
    var textIsBold       = false
    var textIsItalic     = false
    var textIsUnderlined = false
    var textStyle        = 0
    var styleDict        = [String:String]()
    var fontNameDict     = [String:String]()
    var fullFontDict = [String:[String:String]]()   // Dictionary of font family and all its available styles
    var selectedFontName = ""   // Used to lookup if bold, italic is available
    
    @IBAction func stepper_action(_ sender: Any) {
        textSize_textfield.stringValue = "\((sender as AnyObject).integerValue ?? 48) pt"
        appInfo.defaultFontSize = Float((sender as AnyObject).integerValue)
        sendData()
    }
    
    @IBAction func fontList_action(_ sender: Any) {
        selectedFontName        = fontList_button.titleOfSelectedItem!
        appInfo.defaultMenuItemFont = selectedFontName
        appInfo.defaultFontName = fontNameDict[selectedFontName]
//        print("appInfo.defaultFontName: \(String(describing: appInfo.defaultFontName))")
        boldText_button.state       = NSControl.StateValue(rawValue: 0)
        italicText_button.state     = NSControl.StateValue(rawValue: 0)
        underlinedText_button.state = NSControl.StateValue(rawValue: 0)
        checkStyles()
        setStyle_action(self)
        
        sendData()
    }
    
    @IBAction func changeTextColor_action(_ sender: NSButton) {
        
        if NSColorPanel.sharedColorPanelExists {
            NSColorPanel.shared.orderOut(self)
        }
        colorPanel.activate(true)
//        NSApplication.shared.orderFrontColorPanel(self)
        
        colorPanel.window?.collectionBehavior = .moveToActiveSpace
        colorPanel.window?.title = "Text Colors"
        colorPanel.window?.hidesOnDeactivate = true
        colorPanel.action = #selector(changeTextColor)
    }
    
    @objc func changeTextColor(_ sender: Any?) {
        (textColor_button.cell! as! NSButtonCell).backgroundColor = colorPanel.color
        appInfo.defaultTextColor = colorPanel.color
        sendData()
    }
    @IBAction func setStyle_action(_ sender: Any?) {
        appInfo.defaultTextStyle = 0
        if boldText_button.state.rawValue       == 1 { appInfo.defaultTextStyle += 1 }
        if italicText_button.state.rawValue     == 1 { appInfo.defaultTextStyle += 2 }
        if underlinedText_button.state.rawValue == 1 { appInfo.defaultTextStyle += 4 }

        switch appInfo.defaultTextStyle {
        case 1,5:
            appInfo.defaultFontName! = fullFontDict[selectedFontName]!["Bold"]!
        case 2,6:
            appInfo.defaultFontName! = fullFontDict[selectedFontName]!["Italic"]!
        case 3,7:
            appInfo.defaultFontName! = fullFontDict[selectedFontName]!["Bold Italic"]!
        default:
            appInfo.defaultFontName! = fullFontDict[selectedFontName]!["Regular"]!
        }
        if underlinedText_button.state.rawValue == 1 {
            textIsUnderlined = true
        } else {
            textIsUnderlined = false
        }
        sendData()
    }
    @IBAction func setJustification_action(_ sender: NSButton) {
        switch sender.title {
        case "left":
            appInfo.justification = "left"
            justifiedLeft_button.state   = NSControl.StateValue(rawValue: 1)
            justifiedRight_button.state  = NSControl.StateValue(rawValue: 0)
            justifiedCenter_button.state = NSControl.StateValue(rawValue: 0)
        case "right":
            appInfo.justification = "right"
            justifiedRight_button.state  = NSControl.StateValue(rawValue: 1)
            justifiedLeft_button.state   = NSControl.StateValue(rawValue: 0)
            justifiedCenter_button.state = NSControl.StateValue(rawValue: 0)
        default:
            appInfo.justification = "center"
            justifiedCenter_button.state = NSControl.StateValue(rawValue: 1)
            justifiedLeft_button.state   = NSControl.StateValue(rawValue: 0)
            justifiedRight_button.state  = NSControl.StateValue(rawValue: 0)
        }
        UserDefaults.standard.set(sender.title, forKey: "justification")
        sendData()
    }
    
    
    
    func controlTextDidChange(_ obj: Notification) {
        let pointSizeArray = textSize_textfield.stringValue.components(separatedBy: CharacterSet.decimalDigits.inverted)
        if pointSizeArray[0] != "" {
            print("point value is \(pointSizeArray[0])")
            sizeStepper_stepper.integerValue = Int(pointSizeArray[0])!
            appInfo.defaultFontSize = Float(sizeStepper_stepper.integerValue)
            sendData()
        }
    }
    func isBoldAvailable() {
        if !boldText_button.isEnabled {
            textIsBold = false
        } else {
//            appInfo.defaultFontName = styledFontName
        }
    }
    func isItalicAvailable() {
        checkStyles()
        if !italicText_button.isEnabled {
            textIsItalic = false
        }
    }
    func checkStyles() {
        styleDict.removeAll()
        var boldAvailable   = false
        var italicAvailable = false
        
        if let fontStyles = NSFontManager.shared.availableMembers(ofFontFamily: fontList_button.titleOfSelectedItem!) {
            
            let theFontArray      = fontStyles as [Array]
            let regularFontArray  = theFontArray[0]
            let regularFont       = regularFontArray[0] as! String
            fontNameDict[selectedFontName] = regularFont
            fullFontDict[selectedFontName] = ["Regular":regularFont]
        
            for i in 1..<theFontArray.count {
                let styleInfo = theFontArray[i]
                let theStyle   = styleInfo[1] as! String
                fullFontDict[selectedFontName]![theStyle] = styleInfo[0] as? String
                
                switch theStyle {
                case "Bold":
                    boldAvailable = true
                case "Italic":
                    italicAvailable = true
                default:
                    continue
                }
            }
        }
        boldText_button.isEnabled   = boldAvailable
        italicText_button.isEnabled = italicAvailable
    }
    
    func sendData() {
        let dataToBeSent = (appInfo.defaultFontName!, appInfo.defaultFontSize!, appInfo.defaultTextColor!, textIsBold, textIsItalic, textIsUnderlined)
        delegate?.sendTextFormat(textFormat: dataToBeSent)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        colorBorder_textfield.wantsLayer = true
        colorBorder_textfield.isBordered = true
        colorBorder_textfield.layer?.borderColor = NSColor.systemGray.cgColor
        colorBorder_textfield.layer?.borderWidth = 1
        textSize_textfield.delegate = self
        let paragraphStyle       = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let textAttributes = [NSAttributedString.Key.foregroundColor: NSColor.controlTextColor, NSAttributedString.Key.font: NSFont(name: "Helvetica Neue", size: 16)!, NSAttributedString.Key.underlineStyle: 1, NSAttributedString.Key.paragraphStyle: paragraphStyle] as [NSAttributedString.Key : Any]

        let attributedText = NSMutableAttributedString(string: "U", attributes: textAttributes)
        attributedText.addAttribute(.underlineStyle, value: 1, range: NSRange(location: 0, length: 1))
        underlinedText_button.attributedTitle = attributedText

        for theFont in NSFontManager.shared.availableFontFamilies {
//            print("theFont members (\(theFont)): \(NSFontManager.shared.availableMembers(ofFontFamily: theFont)!)")
            let regularFontArray  = NSFontManager.shared.availableMembers(ofFontFamily: theFont)![0] as [Any]
            let regularFont       = regularFontArray[0] as! String
            fontNameDict[theFont] = regularFont
        }
        (textColor_button.cell! as! NSButtonCell).backgroundColor = appInfo.defaultTextColor!
        fontList_button.addItems(withTitles: NSFontManager.shared.availableFontFamilies)
        if NSFontManager.shared.availableFontFamilies.firstIndex(of: appInfo.defaultMenuItemFont) != nil {
            fontList_button.selectItem(withTitle: appInfo.defaultMenuItemFont)
        }
        textSize_textfield.stringValue   = String(format: "%.0f", appInfo.defaultFontSize!) + " pt"
        sizeStepper_stepper.integerValue = Int(appInfo.defaultFontSize ?? 48)
        switch appInfo.defaultTextStyle {
        case 1,5:
            boldText_button.state       = NSControl.StateValue(rawValue: 1)
        case 2,6:
            italicText_button.state     = NSControl.StateValue(rawValue: 1)
        case 3,7:
            boldText_button.state       = NSControl.StateValue(rawValue: 1)
            italicText_button.state     = NSControl.StateValue(rawValue: 1)
        default:
            boldText_button.state       = NSControl.StateValue(rawValue: 0)
            italicText_button.state     = NSControl.StateValue(rawValue: 0)
            underlinedText_button.state = NSControl.StateValue(rawValue: 0)
        }
        if appInfo.defaultTextStyle >= 4 {
            underlinedText_button.state = NSControl.StateValue(rawValue: 1)
        }
        switch appInfo.justification {
        case "left":
            justifiedLeft_button.state   = NSControl.StateValue(rawValue: 1)
        case "right":
            justifiedRight_button.state  = NSControl.StateValue(rawValue: 1)
        default:
            justifiedCenter_button.state = NSControl.StateValue(rawValue: 1)
        }
        checkStyles()
    }
    
}
