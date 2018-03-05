//
//  SettingsCountryTableDataSource.swift
//  Task
//
//  Created by Łukasz Sypniewski on 05/03/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import UIKit

class SettingsCountryTableDataSource: NSObject {
    var countries: [CountriesModel.Country] = [CountriesModel.Country]() {
        didSet {
            countries.sort { $0.name < $1.name } //By default it's sorted by ISO code
        }
    }
    
    init(countries: [CountriesModel.Country]) {
        self.countries = countries
    }
}

// MARK: UITableViewDataSource
extension SettingsCountryTableDataSource : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CountrySettingsCell", for: indexPath) as? SettingsCountryCellTableViewCell else {
            fatalError("The dequeued cell is not an instance of SettingsCountryCellTableViewCell")
        }
        cell.name = "\(countries[indexPath.row].flag) \(countries[indexPath.row].name)"
        return cell
    }
}
