//
//  AppError.swift
//  Mateorite
//
//  Created by Adam Salih on 17.04.2021.
//

import Foundation

enum AppError: Error {
    case generalCommunicationError
    case decodeError
    
    var localizedDescription: String {
        switch self {
        case .generalCommunicationError:
            return "Communination Error"
        case .decodeError:
            return "Error in received data"
        }
    }
}
