//
//  Exclusion.swift
//  RadiusAssignment
//
//  Created by Shreyas Rajapurkar on 18/01/22.
//

import Foundation

/**
 Represents a unique combination of facility id + options id
 */
public class Exclusion: Decodable, Hashable {
    let facility_id: String
    let options_id: String
    
    init(facility_id: String, options_id: String) {
        self.facility_id = facility_id
        self.options_id = options_id
    }
    
    public static func == (lhs: Exclusion, rhs: Exclusion) -> Bool {
        if lhs.facility_id == rhs.facility_id && lhs.options_id == rhs.options_id {
            return true
        }

        return false
    }
    
    public func hash(into hasher: inout Hasher) {
        // No-op
    }
}
