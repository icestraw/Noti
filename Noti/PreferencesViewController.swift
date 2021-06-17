//
//  NotificationPreferences.swift
//  Noti
//
//  Created by Jari on 01/10/16.
//  Copyright © 2016 Jari Zwarts. All rights reserved.
//

import Cocoa
import Foundation
import EMCLoginItem

enum PreferenceItems: String {
    case blockedNotificationsTitle = "PIblockedNotificationsTitle"
    case blockedNotificationsSubtitle1 = "PIblockedNotificationsSubtitle1"
    case blockedNotificationsSubtitle2 = "PIblockedNotificationsSubtitle2"
    case openAppsData = "PIopenAppsData"
}

open class PreferencesViewController: NSViewController, NSControlTextEditingDelegate {
    
    @IBOutlet weak var sounds:NSArrayController!
    
    @IBOutlet weak var enableEncryption:NSButton!
    @IBOutlet weak var encryptionField:NSSecureTextField!
    @IBOutlet weak var defaultsController:NSUserDefaultsController!
    
    @IBOutlet weak var systemStartup:NSButton!
    
    @IBOutlet weak var roundedImages:NSButton!
    @IBOutlet weak var omitAppName:NSButton!
    
    @IBOutlet weak var bnTitleField: NSTextField!
    @IBOutlet weak var bnSubtitle1Field: NSTextField!
    @IBOutlet weak var bnSubtitle2Field: NSTextField!
    
    @IBOutlet weak var oaTableView: NSTableView!
    
    var isInitialized = false
    var appDelegate = NSApplication.shared.delegate as? AppDelegate
    var loginItem = EMCLoginItem()
    
    var FAKE_PASSWORD = "*********"
    
    override open func viewDidAppear() {
        if (self.view.window != nil) {
            self.view.window!.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
            self.view.window!.titlebarAppearsTransparent = true
            self.view.window!.isMovableByWindowBackground = true
            self.view.window!.invalidateShadow()
        }
    }
    
    @IBAction func encryptionEnabledChange(_ sender: NSButton) {
        encryptionField.isEnabled = sender.state == .on
        if sender.state == .off {
            UserDefaults.standard.removeObject(forKey: "secureKey")
            appDelegate?.pushManager?.initCrypt()
        }
    }
    
    @IBAction func systemStartupChange(_ sender: NSButton) {
        if sender.state == .on {
            loginItem?.add()
        } else {
            loginItem?.remove()
        }
    }
    
    public func controlTextDidChange(_ obj: Notification) {
        if !isInitialized {
            return
        }
        if let tf = obj.object as! NSTextField? {
            if tf == encryptionField {
                //gets called every time password changes
                if(encryptionField.stringValue == FAKE_PASSWORD) {
                    return;
                } else if encryptionField.stringValue == "" {
                    UserDefaults.standard.removeObject(forKey: "secureKey")
                    enableEncryption.state = .off
                    encryptionField.isEnabled = false
                    appDelegate?.pushManager?.initCrypt()
                    return;
                }
                
                appDelegate?.pushManager?.setPassword(password: encryptionField.stringValue)
                print("Changed password, reinitializing crypt...")
                appDelegate?.pushManager?.initCrypt()
            } else if tf == bnTitleField {
                // Blocked notifications title
                UserDefaults.standard.setValue(tf.stringValue, forKey: PreferenceItems.blockedNotificationsTitle.rawValue)
            } else if tf == bnSubtitle1Field {
                UserDefaults.standard.setValue(tf.stringValue, forKey: PreferenceItems.blockedNotificationsSubtitle1.rawValue)
            } else if tf == bnSubtitle2Field {
                UserDefaults.standard.setValue(tf.stringValue, forKey: PreferenceItems.blockedNotificationsSubtitle2.rawValue)
            }
        } else {
            
        }
    }
    
    override open func viewDidLoad() {
        defaultsController.initialValues = [
            "sound": "Glass"
        ];
        
        //get all available system sounds
        let fileManager = FileManager.default
        let enumerator:FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: "/System/Library/Sounds")!
        
        while let element = enumerator.nextObject() as? NSString {
            sounds.addObject(element.deletingPathExtension)
        }
        
        //set intial encryption field values
        let key = UserDefaults.standard.object(forKey: "secureKey")
        enableEncryption.state = key != nil ? .on : .off
        encryptionField.isEnabled = key != nil
        
        //indicate that encryption is enabled
        if key != nil {
            encryptionField.stringValue = FAKE_PASSWORD;
        }
        
        //get initial login value
        if let loginEnabled = loginItem?.isLoginItem() {
            systemStartup.state = loginEnabled ? .on : .off
        }
        
        //this is ugly, but I can't get the checkboxes to work through initialValues for some reason
        let omitAppNameDefaultExists = UserDefaults.standard.object(forKey: "omitAppName") != nil
        let omitAppNameDefault = omitAppNameDefaultExists ? UserDefaults.standard.bool(forKey: "omitAppName") : false;
        omitAppName.state = omitAppNameDefault ? .on : .off;
        let roundedImagesDefaultExists = UserDefaults.standard.object(forKey: "roundedImages") != nil
        let roundedImagesDefault = roundedImagesDefaultExists ? UserDefaults.standard.bool(forKey: "roundedImages") : true;
        roundedImages.state = roundedImagesDefault ? .on : .off;
        
        if !isInitialized {
            bnTitleField.stringValue = UserDefaults.standard.string(forKey: PreferenceItems.blockedNotificationsTitle.rawValue) ?? ""
            bnSubtitle1Field.stringValue = UserDefaults.standard.string(forKey: PreferenceItems.blockedNotificationsSubtitle1.rawValue) ?? ""
            bnSubtitle2Field.stringValue = UserDefaults.standard.string(forKey: PreferenceItems.blockedNotificationsSubtitle2.rawValue) ?? ""
            isInitialized = true
        }
    }
    
    // MARK: Test
    
    @IBAction func testButtonPressed(_ sender: Any) {
        
    }
    
    
    // MARK: Open apps
    
    
}
