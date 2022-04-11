//
//  SnowObject.swift
//  WeatherApp
//
//  Created by Peter Schwartz on 1/23/22.
//

import Foundation

struct SnowObject: Codable {
    let oneHour: Double
    
    enum CodingKeys: String, CodingKey {
        case oneHourh = "1h"
    }
}
