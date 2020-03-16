//
//  AddTripViewController.swift
//  ArtOfTheTrek
//
//  Created by Rajinder on 11/03/20.
//  Copyright © 2020 appzpixel. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AddTripViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!

    var startDate: Double!
    var endDate: Double!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupView()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

//MARK:- Setup View Methods
extension AddTripViewController {
    
    private func setupView() {

        let nameValid = nameTextField.rx.text.orEmpty
            .map { $0.count > 0 }
            .share(replay: 1)

        let startDateValid = startDateTextField.rx.text.orEmpty
            .map { $0.count > 0 }
            .share(replay: 1)

        let endDateValid = endDateTextField.rx.text.orEmpty
            .map { $0.count > 0 }
            .share(replay: 1)

        startDateValid
            .bind(to: endDateTextField.rx.isEnabled)
            .disposed(by: disposeBag)

        let isValidTrip = Observable.combineLatest(nameValid, startDateValid, endDateValid) { $0 && $1 && $2}
            .share(replay: 1)

        isValidTrip
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)

        
        startDateTextField.rx.controlEvent([.editingDidBegin])
        .asObservable()
            .subscribe({ [weak self] _ in
            self?.setInputViewDatePicker(textField: self?.startDateTextField)

        })
        .disposed(by: disposeBag)

        endDateTextField.rx.controlEvent([.editingDidBegin])
        .asObservable()
            .subscribe({ [weak self] _ in
            self?.setInputViewDatePicker(textField: self?.endDateTextField)

        })
        .disposed(by: disposeBag)

        
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                
                self?.saveTrip()
            })
            .disposed(by: disposeBag)
        
    }
    
    func setInputViewDatePicker(textField: UITextField?) {

        guard let textField = textField else {
            return
        }
        
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date

        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonAction))
        toolBar.setItems([flexible, barButton], animated: false)

        textField.inputView = datePicker
        textField.inputAccessoryView = toolBar

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        if textField == endDateTextField {
            datePicker.minimumDate = Date(timeIntervalSince1970: startDate)
        }
        datePicker.rx.value.asObservable()
            .map { [weak self] date in

                if textField == self?.startDateTextField {
                    self?.startDate = date.timeIntervalSince1970
                } else {
                    self?.endDate = date.timeIntervalSince1970
                }
                
                return dateFormatter.string(from:date)

            }
        .bind(to: textField.rx.text)
        .disposed(by: disposeBag)
            
    }
    
    @objc func doneButtonAction() {
        if startDateTextField.isFirstResponder {
            startDateTextField.resignFirstResponder()
        } else {
            endDateTextField.resignFirstResponder()
        }
    }
}

//MARK:- Save Methods
extension AddTripViewController {
    
    private func saveTrip() {
        
        let trip = Trip(name: nameTextField.text, startDate: startDate, endDate: endDate)
        DBManager.shared.addTrip(trip: trip) { [weak self] (error) in
            if let error = error {
                Utility.showAlert(error.localizedDescription, self)
                print("Error adding trip: \(error.localizedDescription)")
            } else {
                print("trip added successfully")
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
}
