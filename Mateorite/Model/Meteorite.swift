//
//  Meteorite.swift
//  Mateorite
//
//  Created by Adam Salih on 17.04.2021.
//

import Foundation
import MapKit

struct Meteorite: Codable, Hashable {
    static func == (lhs: Meteorite, rhs: Meteorite) -> Bool {
        lhs.id == rhs.id
    }
    
    let name, id: String
    let nametype: String
    let recclass: String
    let mass: String?
    let fall: String
    let year, reclat, reclong: String?
    let geolocation: Geolocation?
    let computedRegionCbhkFwbd, computedRegionNnqa25F4: String?

    enum CodingKeys: String, CodingKey {
        case name, id, nametype, recclass, mass, fall, year, reclat, reclong, geolocation
        case computedRegionCbhkFwbd = ":@computed_region_cbhk_fwbd"
        case computedRegionNnqa25F4 = ":@computed_region_nnqa_25f4"
    }
}

struct Geolocation: Codable, Hashable {
    let type: String
    let coordinates: [Double]
}
