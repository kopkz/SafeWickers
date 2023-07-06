//
//  AppSettings.swift
//  Safe Wickers
//
//  Created by 匡正 on 16/5/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import UIKit

class AppSettings: NSObject {
    
    fileprivate static let kSharedSettingsKey = "DefaultUserSettings"
    
    static let shared: AppSettings = {
        let appSettings: AppSettings
        if let savedData = UserDefaults.standard.object(forKey: AppSettings.kSharedSettingsKey) as? Data,
            let defaultSettings = NSKeyedUnarchiver.unarchiveObject(with: savedData) as? AppSettings {
            appSettings = defaultSettings
        } else {
            appSettings = AppSettings()
        }
        
        return appSettings
    }()
    
    static func saveSharedInstance() {
        let data = NSKeyedArchiver.archivedData(withRootObject: AppSettings.shared)
        UserDefaults.standard.set(data, forKey: AppSettings.kSharedSettingsKey)
    }
    
    enum Language: String {
        case Chinese = "zh-Hans"
        case English = "en"
        case Hindi = "hi"
        var code: String {
            return rawValue
        }
    }
    static func localeIsChinese() -> Bool {
        if let lang = Locale.preferredLanguages.first {
            if lang.hasPrefix("zh") {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
        
    }
    
    var language: Language
    override init() {
        // 第一次初始语言, 看手机是什么语言
        //language = AppSettings.localeIsChinese() ? .Chinese : .English
        language = .Chinese
        super.init()
    }
    
}

private var bundleByLanguageCode: [String: Foundation.Bundle] = [:]
extension AppSettings.Language {
    var bundle: Foundation.Bundle? {
        if let bundle = bundleByLanguageCode[code] {
            return bundle
        } else {
            let mainBundle = Foundation.Bundle.main
            if let path = mainBundle.path(forResource: code, ofType: "lproj"),
                let bundle = Foundation.Bundle(path: path) {
                bundleByLanguageCode[code] = bundle
                return bundle
            } else {
                return nil
            }
        }
    }
}

class Bundle: Foundation.Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let bundle = AppSettings.shared.language.bundle {
            return bundle.localizedString(forKey: key, value: value, table: tableName)
        } else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
    }
}
