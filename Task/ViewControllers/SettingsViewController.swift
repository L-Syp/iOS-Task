//
//  SettingViewController.swift
//  Task
//
//  Created by Łukasz Sypniewski on 28/02/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    // MARK: Properties
    lazy var settings: QuerySettings = QuerySettings()
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
    @IBOutlet weak var topicTextField: UITextField!
    
    // MARK: Actions
    @IBAction func cancelButtonClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Set views
    override func viewDidLoad() {
        super.viewDidLoad()
        preparePickerView()
        countryCell.textLabel?.text = settings.queries![1].value
        topicTextField.text = settings.queries![0].value
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
       pickerView.selectRow(settings.itemsCount! - 1 /*pickerView.numberOfRows(inComponent: 0) does not work*/, inComponent: 0, animated: true)
    }
    
    // MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = topicTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            print("The save button was not pressed, cancelling")
            return
        }
            settings.itemsCount = pickerData[pickerView.selectedRow(inComponent: 0)]
            settings.queries = [URLQueryItem(name: "q", value: topicTextField.text), URLQueryItem(name: "language", value: countryCell.textLabel?.text)]
    }
}
