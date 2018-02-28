//
//  SettingViewController.swift
//  Task
//
//  Created by Łukasz Sypniewski on 28/02/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import UIKit
import os.log

class SettingViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    // MARK: Properties
    var settings: QuerySettings?
    var pickerData: [Int] = [Int]()
    // MARK: Outlets
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var countryCell: UITableViewCell!
    @IBOutlet weak var topicTextField: UITextField!
    
    // MARK: Actions
    @IBAction func cancelButtonClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preparePickerView()
        countryCell.textLabel?.text = settings?.additionalQueries[1].value
        topicTextField.text = settings?.additionalQueries[0].value
        
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        var newSettings = QuerySettings()
        newSettings.itemsCount = pickerData[pickerView.selectedRow(inComponent: 0)]
        newSettings.additionalQueries = [URLQueryItem(name: "q", value: topicTextField.text), URLQueryItem(name: "language", value: countryCell.textLabel?.text)]
        settings = newSettings
    }
    
    // MARK: PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(pickerData[row])
    }
    
    func preparePickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        for i in 1...20 { pickerData.append(i) }
        if let settings = settings {
            pickerView.selectRow(settings.itemsCount - 1 /*pickerView.numberOfRows(inComponent: 0) does not work*/, inComponent: 0, animated: true)
        } else {
            pickerView.selectRow(10, inComponent: 0, animated: true)
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = topicTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
}
