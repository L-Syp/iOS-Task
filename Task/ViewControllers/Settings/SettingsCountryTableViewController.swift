//
//  SettingsCountryTableViewController.swift
//  Task
//
//  Created by Łukasz Sypniewski on 28/02/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import UIKit

protocol SettingsCountryTableVCDelegate {
    func chooseCountry(country: Country)
}

class SettingsCountryTableViewController: UITableViewController  {
    
    // MARK: Properties
    var countries: [Country] = [Country]() {
        didSet {
            countries.sort { $0.name < $1.name } //By default it's sorted by ISO code
        }
    }
    var selectedCountry: Country? = nil
    var currentCountryCode: String = String()
    var delegate: SettingsCountryTableVCDelegate?
    
    // MARK: Outlets
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: Actions
    @IBAction func cancelButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func saveButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        guard let selectedCountry = selectedCountry else { return }
        delegate?.chooseCountry(country: selectedCountry)
    }
    
    // MARK: Set view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectCountry(at: countries.index(where: { $0.code == currentCountryCode })!)
        saveButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func selectCountry(at index: Int) {
        let rowIndex = IndexPath(row: index, section: 0)
        tableView.selectRow(at: rowIndex, animated: true, scrollPosition: .middle)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CountrySettingsCell", for: indexPath) as? SettingsCountryCellTableViewCell else {
            fatalError("The dequeued cell is not an instance of SettingsCountryCellTableViewCell")
        }
        cell.labelName.text = "\(countries[indexPath.row].flag) \(countries[indexPath.row].name)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !saveButton.isEnabled { saveButton.isEnabled = true }
        selectedCountry = countries[indexPath.row]
    }
}


