//
//  SettingsManager.swift
//  Task
//
//  Created by Łukasz Sypniewski on 02/03/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import Foundation

class SettingsController {
    static func saveAppSettings(settings: Settings) {
        let defaults = UserDefaults.standard
        defaults.set(NSKeyedArchiver.archivedData(withRootObject: settings.queries!), forKey: Settings.Keys.Queries.rawValue)
        defaults.set(settings.apiKey!, forKey: Settings.Keys.ApiKey.rawValue)
        defaults.set(settings.endpoint!.rawValue, forKey: Settings.Keys.Endpoint.rawValue)
        defaults.set(settings.itemsCount!, forKey: Settings.Keys.ItemsCount.rawValue)
    }
    
    static func loadAppSettings() -> Settings {
        let defaults = UserDefaults.standard
        let queries: [URLQueryItem] = {
            if let queriesObject = defaults.value(forKey: Settings.Keys.Queries.rawValue) as? NSData {
                return NSKeyedUnarchiver.unarchiveObject(with: queriesObject as Data) as! [URLQueryItem]
            } else {
                return [URLQueryItem(name: "q", value: "bitcoin"), URLQueryItem(name: "language", value: "pl")]
            }
        }()
        let apiKey = defaults.string(forKey: Settings.Keys.ApiKey.rawValue) ?? "2beb5953fd92424983abae1dc1c7d58c"
        let endpointValue = defaults.string(forKey: Settings.Keys.Endpoint.rawValue) ?? ArticleModel.Endpoints.everything.rawValue
        let itemsCount = defaults.integer(forKey: Settings.Keys.ItemsCount.rawValue) != 0 ?
            defaults.integer(forKey: Settings.Keys.ItemsCount.rawValue) : 5
        let endpoint = ArticleModel.Endpoints(rawValue: endpointValue)!
        return Settings(apiKey: apiKey, endpoint: endpoint, itemsCount: itemsCount, queries: queries)
    }
    
    static func printSettings() {
        let settings = loadAppSettings()
        print("\(Settings.Keys.ApiKey.rawValue): \(settings.apiKey!)")
        print("\(Settings.Keys.Queries.rawValue): \(settings.queries!)")
        print("\(Settings.Keys.Endpoint.rawValue): \(settings.endpoint!)")
        print("\(Settings.Keys.ItemsCount.rawValue): \(settings.itemsCount!)")
    }
    
    private init() {}
}
