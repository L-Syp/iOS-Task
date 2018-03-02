//
//  SettingsManager.swift
//  Task
//
//  Created by Łukasz Sypniewski on 02/03/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import Foundation

class SettingsManager {
    static func saveAppSettings(settings: QuerySettings) {
        let defaults = UserDefaults.standard
        defaults.set(NSKeyedArchiver.archivedData(withRootObject: settings.queries!), forKey: QuerySettings.Keys.Queries.rawValue)
        defaults.set(settings.apiKey!, forKey: QuerySettings.Keys.ApiKey.rawValue)
        defaults.set(settings.endpoint!.rawValue, forKey: QuerySettings.Keys.Endpoint.rawValue)
        defaults.set(settings.itemsCount!, forKey: QuerySettings.Keys.ItemsCount.rawValue)
    }
    
    static func loadAppSettings() -> QuerySettings {
        let defaults = UserDefaults.standard
        let queries: [URLQueryItem] = {
            if let queriesObject = defaults.value(forKey: QuerySettings.Keys.Queries.rawValue) as? NSData {
                return NSKeyedUnarchiver.unarchiveObject(with: queriesObject as Data) as! [URLQueryItem]
            } else {
                return [URLQueryItem(name: "q", value: "bitcoin"), URLQueryItem(name: "language", value: "pl")]
            }
        }()
        let apiKey = defaults.string(forKey: QuerySettings.Keys.ApiKey.rawValue) ?? "2beb5953fd92424983abae1dc1c7d58c"
        let endpointValue = defaults.string(forKey: QuerySettings.Keys.Endpoint.rawValue) ?? ArticlesProvider.Endpoints.everything.rawValue
        let itemsCount = defaults.integer(forKey: QuerySettings.Keys.ItemsCount.rawValue) != 0 ?
            defaults.integer(forKey: QuerySettings.Keys.ItemsCount.rawValue) : 5
        let endpoint = ArticlesProvider.Endpoints(rawValue: endpointValue)!
        return QuerySettings(apiKey: apiKey, endpoint: endpoint, itemsCount: itemsCount, queries: queries)
    }
    
    static func printSettings() {
        let settings = loadAppSettings()
        print("\(QuerySettings.Keys.ApiKey.rawValue): \(settings.apiKey!)")
        print("\(QuerySettings.Keys.Queries.rawValue): \(settings.queries!)")
        print("\(QuerySettings.Keys.Endpoint.rawValue): \(settings.endpoint!)")
        print("\(QuerySettings.Keys.ItemsCount.rawValue): \(settings.itemsCount!)")
    }
}
