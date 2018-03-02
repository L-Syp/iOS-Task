//
//  CountriesProvider.swift
//  Task
//
//  Created by Łukasz Sypniewski on 28/02/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import Foundation

struct Countries: Codable {
    let countries: [Country]
}

struct Country: Codable {
    let code: String
    let name: String
    let flag: String
    
    enum CodingKeys : String, CodingKey {
        case code
        case name
        case flag = "emoji"
    }
}

struct CountriesProvider {
    static let availableCountries: [String] = ["ae", "ar", "at", "au", "be", "bg", "br", "ca", "ch", "cn", "co",
                                               "cu", "cz", "de", "eg", "fr", "gb", "gr", "hk", "hu", "id", "ie",
                                               "il", "in", "it", "jp", "kr", "lt", "lv", "ma", "mx", "my", "ng",
                                               "nl", "no", "nz", "ph", "pl", "pt", "ro", "rs", "ru", "sa", "se",
                                               "sg", "si", "sk", "th", "tr", "tw", "ua", "us", "ve", "za"]
    
    static func decodeJSON(from filePath: String) throws -> [Country]? {
        do {
            let jsonString = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue)
            let jsonData = jsonString.data(using: String.Encoding.utf8.rawValue)!
            let decoder = JSONDecoder()
            let countries = try! decoder.decode(Countries.self, from: jsonData)
            return countries.countries
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    static func getCountryName(from countries: [Country], for countryCode: String) -> String {
        let filtered = filterCountriesByCode(from: countries, for: countryCode)
        return filtered.name
    }
    
    static func getCountryFlag(from countries: [Country], for countryCode: String) -> String {
        let filtered = filterCountriesByCode(from: countries, for: countryCode)
        return filtered.flag
    }
    
    private static func filterCountriesByCode(from countries: [Country], for countryCode: String) -> Country {
        let filtered = countries.filter{ $0.code == countryCode }
        guard filtered.count == 1 else {fatalError("JSON file contains \(filtered.count) countries with code: \(countryCode)")}
        return filtered[0]
    }
}

