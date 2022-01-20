//
//  ViewController.swift
//  RadiusAssignment
//
//  Created by Shreyas Rajapurkar on 18/01/22.
//

import UIKit

protocol ExclusionHandler: NSObject {
    func resolveExclusionsIfNeeded(facilityId: Int, optionId: Int, previousOption: Int?)
}

class ViewController: UIViewController, FullFacilitiesViewProtocol, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ExclusionHandler {
    var viewModel: FullFacilitiesViewModel?
    var cellViewModels: [FacilityCellViewModel]?

    let collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        return UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = FullFacilitiesViewModel(delegate: self)
        viewModel?.fetchData()

        setupCollectionView()
    }
    
    func setupCollectionView() {
        view.addSubview(collectionView)
        
        collectionView.register(FacilityCell.self, forCellWithReuseIdentifier: "FacilityCell")
        collectionView.backgroundColor = UIColor.darkGray
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        constraints.append(collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor))
        constraints.append(collectionView.topAnchor.constraint(equalTo: view.topAnchor))
        constraints.append(collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        constraints.append(collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor))

        NSLayoutConstraint.activate(constraints)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.fullFacilities?.facilities.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FacilityCell", for: indexPath)
        if let cellViewModel = cellViewModels?[indexPath.row] {
            (cell as? FacilityCell)?.setup(cellViewModel: cellViewModel, exclusionDelegate: self)
        }

        return cell
    }
    
    func didFetchFullFacilitiesData() {
        cellViewModels = viewModel?.fullFacilities?.facilities.map({ facility in
            return FacilityCellViewModel(
                title: facility.name,
                facilityId: Int(facility.facility_id) ?? 0,
                disabledButtons: [:],
                options: facility.options,
                selectedButtonTag: nil)
        })

        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    func resolveExclusionsIfNeeded(facilityId: Int, optionId: Int, previousOption: Int?) {
        defer {
            collectionView.reloadData()
        }

        if let currentCellViewModel = cellViewModels?[facilityId - 1] {
            currentCellViewModel.selectedButtonTag = optionId
        }
        
        if let previousOption = previousOption,
        let includedValues = viewModel?.resolveExclusionsIfNeeded(facilityId: facilityId, optionId: previousOption) {
            for exclusionValue in includedValues {
                updateButtonStateInViewModel(exclusionValues: exclusionValue, offset: -1)
            }
        }

        guard let excludedValues = viewModel?.resolveExclusionsIfNeeded(facilityId: facilityId, optionId: optionId) else {
            return
        }

        
        for exclusionValue in excludedValues {
            updateButtonStateInViewModel(exclusionValues: exclusionValue, offset: 1)
        }
        
        cellViewModels?[facilityId - 1].selectedButtonTag = optionId
    }

    /**
     Updates the required button states in the view model (enabled/disabled)
     */
    private func updateButtonStateInViewModel(exclusionValues: Exclusion, offset: Int) {
        guard let facilityId = Int(exclusionValues.facility_id),
        let optionId = Int(exclusionValues.options_id),
            let cellViewModel = cellViewModels?[facilityId - 1] else {
                return
            }

        if cellViewModel.disabledButtons.keys.contains(optionId) {
            if let currentValue = cellViewModel.disabledButtons[optionId] {
                cellViewModel.disabledButtons.updateValue(currentValue + offset, forKey: optionId)
            }
        } else if offset == 1 {
            cellViewModel.disabledButtons.updateValue(offset, forKey: optionId)
        }
    }
}

