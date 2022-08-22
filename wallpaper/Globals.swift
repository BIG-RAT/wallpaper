//
//  Globals.swift
//  Jamf Wallpaper
//
//  Created by Leslie Helou on 4/13/22.
//  Copyright © 2022 Jamf. All rights reserved.
//

import Cocoa
import Foundation

struct appInfo {
    static let dict    = Bundle.main.infoDictionary!
    static let version = dict["CFBundleShortVersionString"] as! String
    static let build   = dict["CFBundleVersion"] as! String
    static let name    = dict["CFBundleExecutable"] as! String
    static var stopUpdates = false

    static let userAgentHeader = "\(String(describing: name.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!))/\(appInfo.version)"
    
    static var bundlePath   = Bundle.main.bundleURL
    static var iconFile     = bundlePath.appendingPathComponent("Contents/Resources/AppIcon.icns")
    static let readme       = bundlePath.appendingPathComponent("Contents/Resources/README.html")
    static var targetScreen: Int?
    static var overlay: Int?
    static var defaultBackgroundColor: NSColor?
//    static var defaultBackgroundImage: NSImage? //unused?
    static var currentPreviewType = "iPad"
    static var defaultBackgroundImageURL = "green768x1024"
//    static var defaultBackgroundImageURL: String?
    static var defaultText: String?
    static var defaultFontName: String?
    static var defaultMenuItemFont = "Helvetica Neue"
    static var defaultFontSize: Float?
    static var defaultTextStyle = 0
    static var defaultTextStyleName = ""
    static var defaultTextColor: NSColor?
    static var defaultBackgroundIsColor = true
    
    static var textPosition   = 0   // 0 - above, 1 - below
    static var textAdjustment = 0.0
    static var qrCodeSize     = 3.0
    
    static var iPadQRCodeRect:   ObjectRect?
    static var iPadTextRect:     ObjectRect?
    static var iPhoneQRCodeRect: ObjectRect?
    static var iPhoneTextRect:   ObjectRect?
    static var qrCodeVertPos  = ["iPad":30, "iPhone":30]
    static var qrCodeHorizPos = ["iPad":50, "iPhone":50]
    static var textVertPos    = ["iPad":30, "iPhone":30]
    static var textHorizPos   = ["iPad":50, "iPhone":50]
    static var justification  = "center"
}
struct JamfProServer {
    static let settingsFile = "/Library/Managed Preferences/jamf.ie.jamfwallpaper.plist"
    static let maxThreads   = 5
    static var majorVersion = 0
    static var minorVersion = 0
    static var patchVersion = 0
    static var build        = ""
    static var authType     = "Basic"
    static var authCreds    = ""
    static var base64Creds  = ""
    static var validToken   = false
    static var version      = ""
    static var URL          = ""
}
struct Log {
    static var path: String? = (NSHomeDirectory() + "/Library/Logs/JamfWallpaper/")
    static var file          = "JamfWallpaper.log"
    static var maxFiles      = 10
    static var maxSize       = 10000000 // 10MB
}
struct ObjectRect: Codable {
    var minX:    Double
    var minY:    Double
    var objectW: Double
    var objectH: Double
}

//
//struct MobileDevice: Codable {
//    var mobileDevice: MobileDeviceClass
//
//    enum CodingKeys: String, CodingKey {
//        case mobileDevice = "mobile_device"
//    }
//}
//struct MobileDeviceClass: Codable {
//    var general: General
//    var location: Location
//    var extensionAttributes: [ExtensionAttribute]
//
//    enum CodingKeys: String, CodingKey {
//        case general, location
//        case extensionAttributes = "extension_attributes"
//    }
//}
//struct ExtensionAttribute: Codable {
//    var id: Int
//    var name: String
//    var type: TypeEnum
//    var multiValue: Bool
//    var value: String
//
//    enum CodingKeys: String, CodingKey {
//        case id, name, type
//        case multiValue = "multi_value"
//        case value
//    }
//}
//
//enum TypeEnum: String, Codable {
//    case number = "Number"
//    case string = "String"
//}
//struct General: Codable {
//    var id: Int
//    var displayName, deviceName, name, assetTag: String
//    var lastInventoryUpdate: String
//    var lastInventoryUpdateEpoch: Int
//    var lastInventoryUpdateUTC: String
//    var capacity, capacityMB, available, availableMB: Int
//    var percentageUsed: Int
//    var osType, osVersion, osBuild, softwareUpdateDeviceID: String
//    var serialNumber, udid: String
//    var initialEntryDateEpoch: Int
//    var initialEntryDateUTC, phoneNumber, ipAddress, wifiMACAddress: String
//    var bluetoothMACAddress, modemFirmware, model, modelIdentifier: String
//    var modelNumber, modelDisplay, generalModelDisplay, deviceOwnershipLevel: String
//    var enrollmentMethod: String
//    var lastEnrollmentEpoch: Int
//    var lastEnrollmentUTC: String
//    var mdmProfileExpirationEpoch: Int
//    var mdmProfileExpirationUTC: String
//    var managed, supervised: Bool
//    var exchangeActivesyncDeviceIdentifier, shared, diagnosticSubmission, appAnalytics: String
//    var tethered: String
//    var batteryLevel: Int
//    var bleCapable, deviceLocatorServiceEnabled, doNotDisturbEnabled, cloudBackupEnabled: Bool
//    var lastCloudBackupDateEpoch: Int
//    var lastCloudBackupDateUTC: String
//    var locationServicesEnabled, itunesStoreAccountIsActive: Bool
//    var lastBackupTimeEpoch: Int
//    var lastBackupTimeUTC: String
//    var site: Site
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case displayName = "display_name"
//        case deviceName = "device_name"
//        case name
//        case assetTag = "asset_tag"
//        case lastInventoryUpdate = "last_inventory_update"
//        case lastInventoryUpdateEpoch = "last_inventory_update_epoch"
//        case lastInventoryUpdateUTC = "last_inventory_update_utc"
//        case capacity
//        case capacityMB = "capacity_mb"
//        case available
//        case availableMB = "available_mb"
//        case percentageUsed = "percentage_used"
//        case osType = "os_type"
//        case osVersion = "os_version"
//        case osBuild = "os_build"
//        case softwareUpdateDeviceID = "software_update_device_id"
//        case serialNumber = "serial_number"
//        case udid
//        case initialEntryDateEpoch = "initial_entry_date_epoch"
//        case initialEntryDateUTC = "initial_entry_date_utc"
//        case phoneNumber = "phone_number"
//        case ipAddress = "ip_address"
//        case wifiMACAddress = "wifi_mac_address"
//        case bluetoothMACAddress = "bluetooth_mac_address"
//        case modemFirmware = "modem_firmware"
//        case model
//        case modelIdentifier = "model_identifier"
//        case modelNumber = "model_number"
//        case modelDisplay
//        case generalModelDisplay = "model_display"
//        case deviceOwnershipLevel = "device_ownership_level"
//        case enrollmentMethod = "enrollment_method"
//        case lastEnrollmentEpoch = "last_enrollment_epoch"
//        case lastEnrollmentUTC = "last_enrollment_utc"
//        case mdmProfileExpirationEpoch = "mdm_profile_expiration_epoch"
//        case mdmProfileExpirationUTC = "mdm_profile_expiration_utc"
//        case managed, supervised
//        case exchangeActivesyncDeviceIdentifier = "exchange_activesync_device_identifier"
//        case shared
//        case diagnosticSubmission = "diagnostic_submission"
//        case appAnalytics = "app_analytics"
//        case tethered
//        case batteryLevel = "battery_level"
//        case bleCapable = "ble_capable"
//        case deviceLocatorServiceEnabled = "device_locator_service_enabled"
//        case doNotDisturbEnabled = "do_not_disturb_enabled"
//        case cloudBackupEnabled = "cloud_backup_enabled"
//        case lastCloudBackupDateEpoch = "last_cloud_backup_date_epoch"
//        case lastCloudBackupDateUTC = "last_cloud_backup_date_utc"
//        case locationServicesEnabled = "location_services_enabled"
//        case itunesStoreAccountIsActive = "itunes_store_account_is_active"
//        case lastBackupTimeEpoch = "last_backup_time_epoch"
//        case lastBackupTimeUTC = "last_backup_time_utc"
//        case site
//    }
//}
//struct Site: Codable {
//    var id: Int
//    var name: String
//}
//struct Location: Codable {
//    var username, realname, realName, emailAddress: String
//    var position, phone, phoneNumber, department: String
//    var building, room: String
//
//    enum CodingKeys: String, CodingKey {
//        case username, realname
//        case realName = "real_name"
//        case emailAddress = "email_address"
//        case position, phone
//        case phoneNumber = "phone_number"
//        case department, building, room
//    }
//}


struct token {
    static var refreshInterval:UInt32 = 15*60  // 15 minutes
    static var sourceServer  = ""
    static var sourceExpires = ""
}
