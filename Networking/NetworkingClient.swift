//
//  NetworkingClient.swift
//  Assignment
//
//  Created by Shreyas Rajapurkar on 01/01/22.
//

import Foundation

class NetworkingClient {
    public static func fetchFullFacilityData(completion: @escaping (FullFacities) -> Void) {
        guard let url = URL(string: "https://my-json-server.typicode.com/iranjith4/ad-assignment/db") else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                return
            }
            if let data = data {
                if let fullFacilities = parseData(data: data) {
                    completion(fullFacilities)
                }
            }
        }
        dataTask.resume()
    }

    private static func parseData(data: Data) -> FullFacities? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(FullFacities.self, from: data)
            return FullFacities(facilities: decodedData.facilities, exclusions: decodedData.exclusions)
        } catch {
            print(error)
        }

        return nil
    }
}

