//
//  ViewController.swift
//  ArtOfTheTrek
//
//  Created by Rajinder on 11/03/20.
//  Copyright © 2020 appzpixel. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

public class TripsViewController: UIViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tripsTableView: UITableView!
    @IBOutlet weak var errorLabel: UILabel!

    var tripsDataSource: RxTableViewSectionedAnimatedDataSource<SectionOfTrips>!
    
    let trips: BehaviorRelay<[Trip]> = BehaviorRelay(value: [])
    let deleteCommand = PublishRelay<IndexPath>()

    private let disposeBag = DisposeBag()

    let dateFormatter = DateFormatter()

    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        dateFormatter.dateFormat = "dd MMM yyyy"

        setupView()
    }

    private func getTripsData() {
        
        let selectedIndex = segmentControl?.selectedSegmentIndex ?? 0
        
        DBManager.shared.getTrips(tripType: TripType(rawValue: selectedIndex) ?? TripType.all) { [weak self] (result, error) in
            
            if let error = error {
                Utility.showAlert(error.localizedDescription, self)
            } else {
                self?.setData(trips: result)
            }
        }
    }
    
    public func setData(trips: [Trip]?) {
        self.trips.accept(trips ?? [])
        
        if self.trips.value.count == 0 {
            Utility.showAlert("No trip found", self)

        }
    }
}

//MARK:- Setup View Methods
extension TripsViewController {
    
    private func setupView() {
        
        segmentControl.rx.selectedSegmentIndex.asObservable()
            .subscribe { [weak self] _ in
                self?.getTripsData()
            }
            .disposed(by: disposeBag)

        DispatchQueue.main.async { [weak self] in
            self?.configureTableView()
        }
    }
    
    private func configureTableView() {
        
        setupDataSource()
        setupDeleteObservables()
    }
    
    private func setupDataSource() {
        
        tripsDataSource =  RxTableViewSectionedAnimatedDataSource(
            animationConfiguration: AnimationConfiguration(insertAnimation: .automatic, reloadAnimation: .automatic, deleteAnimation: .left),
            configureCell:{ [weak self] (ds, tableView, indexPath, trip) -> UITableViewCell in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "tripcell") else {
                    fatalError()
                }
                self?.configureCell(cell: cell, trip: trip)
                return cell
        },
            canEditRowAtIndexPath: { _, _ in true }
        )
        
        //cell configuration binding wth datasource
        trips
            .map { trips in [SectionOfTrips(header: "", items: trips)] }
            .bind(to: tripsTableView.rx.items(dataSource: tripsDataSource))
            .disposed(by: disposeBag)
    }
    
    private func setupDeleteObservables() {
        
        deleteCommand
            .map { $0.row }
            .subscribe(onNext: { [weak self] in
                DBManager.shared.deleteTrip(trip: self?.trips.value[$0]) { (error) in
                    if let error = error {
                        Utility.showAlert(error.localizedDescription, self)
                        print("Error removing document: \(error.localizedDescription)")
                    } else {
                        print("Document successfully removed!")
                    }

            }
            }).disposed(by: disposeBag)
        
        //delete binding
        tripsTableView.rx.itemDeleted
            .bind(to: self.deleteCommand)
            .disposed(by: disposeBag)
    }
    
    
    func configureCell(cell: UITableViewCell, trip: Trip) {
        
        cell.textLabel?.text = trip.name
        
        let startDate = Date(timeIntervalSince1970: trip.startDate ?? 0)
        let endDate = Date(timeIntervalSince1970: trip.endDate ?? 0)
        
        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: endDate)
        
        cell.detailTextLabel?.text = "\(startDateString) - \(endDateString)"
        
    }
}
