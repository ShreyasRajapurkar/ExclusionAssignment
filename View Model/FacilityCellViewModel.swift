//
//  FacilityCellViewModel.swift
//  RadiusAssignment
//
//  Created by Shreyas Rajapurkar on 18/01/22.
//

import Foundation
import UIKit

class FacilityCellViewModel {
    let title: String
    let facilityId: Int
    let options: [Option]

    // Disabled buttons in the radio group
    var disabledButtons: [Int:Int]

    // Tag of the currently selected button in the radio group
    var selectedButtonTag: Int?

    init(title: String, facilityId: Int, disabledButtons: [Int:Int], options: [Option], selectedButtonTag: Int?) {
        self.title = title
        self.facilityId = facilityId
        self.disabledButtons = disabledButtons
        self.options = options
        self.selectedButtonTag = selectedButtonTag
    }
}
