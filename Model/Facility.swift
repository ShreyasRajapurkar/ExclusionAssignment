//
//  Facility.swift
//  RadiusAssignment
//
//  Created by Shreyas Rajapurkar on 18/01/22.
//

import Foundation

public class Facility: Decodable {
    let facility_id: String
    let name: String
    let options: [Option]
}
