//
//  CountriesModel.swift
//  Task
//
//  Created by Łukasz Sypniewski on 28/02/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import Foundation

class CountriesModel {
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
    
    private init() {}
}

