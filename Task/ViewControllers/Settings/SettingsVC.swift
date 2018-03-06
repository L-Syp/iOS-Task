//
//  SettingVC.swift
//  Task
//
//  Created by Łukasz Sypniewski on 28/02/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import UIKit

class SettingsVC: UITableViewController {
    
    // MARK: Properties
    let JSONFilePath: String
    lazy var availableCountries: [CountriesModel.Country] = [CountriesModel.Country]()
    lazy var settings: Settings = Settings()
    var pickerData: [Int] {
        get {
            var array = [Int]()
            for i in 1...20 { array.append(i) }
            return array
        }
    }
    
    // MARK: Outlets
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var countryCell: UITableViewCell!
    
    // MARK: Actions
    @IBAction func cancelButtonClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Initializers
    required init?(coder aDecoder: NSCoder) {
        self.JSONFilePath = Bundle.main.path(forResource: "countriesList", ofType: "json")!
        super.init(coder: aDecoder)
    }
    
    // MARK: Set views
    override func viewDidLoad() {
        super.viewDidLoad()
        self.availableCountries = parseAndFilterJSON(from: self.JSONFilePath)
        setCountryCell(countries: availableCountries, countryCode: settings.queries![0].value!)
        preparePickerView()
        
    }
    
    private func parseAndFilterJSON(from path: String) -> [CountriesModel.Country] {
        do {
            let allCountries = try CountriesController.decodeJSON(from: path)!
            return allCountries.filter{ CountriesController.availableCountries.contains($0.code.lowercased()) }
        } catch {
            fatalError("Error during parsing json file containing list of countries.")
        }
    }
    
    private func setCountryCell(countries: [CountriesModel.Country], countryCode: String) {
        let flag = CountriesController.getCountryFlag(from: countries, for: countryCode)
        let name = CountriesController.getCountryName(from: countries, for: countryCode)
        countryCell.textLabel?.text = "\(flag) \(name)"
    }
    
    // MARK: PickerView
    func preparePickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(settings.itemsCount! - 1 /*pickerView.numberOfRows(inComponent: 0) does not work*/, inComponent: 0, animated: true)
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let button = sender as? UIBarButtonItem, button === saveButton {
            settings.itemsCount = pickerData[pickerView.selectedRow(inComponent: 0)]
        }
        if segue.identifier == "countriesTableSegue" {
            let navigationVC = segue.destination as! UINavigationController
            let countriesTableVC = navigationVC.viewControllers.first as! SettingsCountryTableVC
            countriesTableVC.delegate = self
            countriesTableVC.countries = availableCountries
            countriesTableVC.currentCountryCode = settings.queries![0].value!
        }
    }
}

// MARK: UIPickerViewDelegate
extension SettingsVC: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(self.pickerData[row])
    }
}

// MARK: UIPickerViewDataSource
extension SettingsVC: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerData.count
    }
}

// MARK: SettingsCountryTableVCDelegate
extension SettingsVC: SettingsCountryTableVCDelegate {
    func chooseCountry(country: CountriesModel.Country) {
        countryCell.textLabel?.text = "\(country.flag) \(country.name)"
        settings.queries = [URLQueryItem(name: "country", value: country.code)]
    }
}

