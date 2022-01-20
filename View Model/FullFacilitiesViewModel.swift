//
//  FullFacilitiesViewModel.swift
//  RadiusAssignment
//
//  Created by Shreyas Rajapurkar on 18/01/22.
//

import Foundation

protocol FullFacilitiesViewProtocol: NSObject {
    func didFetchFullFacilitiesData()
}

class FullFacilitiesViewModel {
    weak var delegate: FullFacilitiesViewProtocol?
    var fullFacilities: FullFacities? {
        didSet {
            delegate?.didFetchFullFacilitiesData()
        }
    }
    
    /**
     This will store mappings for exclusions -> exclusions array defining that a for a particular combination of featureId and optionId,
     all the the combinations of featureId and optionId that need to be disabled/enabled.
     */
    var exclusionMap = [Exclusion: [Exclusion]]()
    
    init(delegate: FullFacilitiesViewProtocol?) {
        self.delegate = delegate
    }

    public func fetchData() {
        NetworkingClient.fetchFullFacilityData { [weak self] fullFacilities in
            guard let strongSelf = self else {
                return
            }
            strongSelf.fullFacilities = fullFacilities
            
            for exclusion in fullFacilities.exclusions {
                if let firstValue = exclusion.first,
                   let secondValue = exclusion.last {
                    // Store the exclusions as mappings, so that they can be looked up later quickly when resolving exclusions
                    strongSelf.populateExclusionMap(key: firstValue, value: secondValue)
                    strongSelf.populateExclusionMap(key: secondValue, value: firstValue)
                }
            }
        }
    }

    /**
     Returns an Exclusion object that will map to a radio button that should be disabled/enabled.
     */
    func resolveExclusionsIfNeeded(facilityId: Int, optionId: Int) -> [Exclusion]? {
        let key = Exclusion(facility_id: String(facilityId), options_id: String(optionId))
        return exclusionMap[key]
    }

    private func populateExclusionMap(key: Exclusion, value: Exclusion) {
        if exclusionMap.keys.contains(key) {
            let currentExclusions = exclusionMap[key]
            var newExclusions = [Exclusion]()
            newExclusions.append(contentsOf: currentExclusions ?? [])
            newExclusions.append(value)
            exclusionMap.updateValue(newExclusions, forKey: key)
        } else {
            var newEntry = [Exclusion]()
            newEntry.append(value)
            exclusionMap.updateValue(newEntry, forKey: key)
        }
    }
}
