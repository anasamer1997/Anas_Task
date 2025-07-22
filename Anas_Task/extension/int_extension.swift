//
//  int_extension.swift
//  AnasTask
//
//  Created by Anas Amer on 27/01/1447 AH.
//

import Foundation

extension Int {
    var formattedDuration: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: TimeInterval(self))
    }
}
