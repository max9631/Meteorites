//
//  URL+Extensions.swift
//  Mateorite
//
//  Created by Adam Salih on 17.04.2021.
//

import Foundation

extension URL: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(string: value)!
    }
}
