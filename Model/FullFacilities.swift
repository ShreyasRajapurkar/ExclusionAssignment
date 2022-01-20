//
//  FullFacilities.swift
//  RadiusAssignment
//
//  Created by Shreyas Rajapurkar on 18/01/22.
//

public class FullFacities: Decodable {
    let facilities: [Facility]
    let exclusions: [[Exclusion]]

    init(facilities: [Facility], exclusions: [[Exclusion]]) {
        self.facilities = facilities
        self.exclusions = exclusions
    }
}
