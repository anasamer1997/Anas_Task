//
//  DisplayableContent.swift
//  Anas_Task
//
//  Created by Anas Amer on 28/01/1447 AH.
//

import Foundation

protocol DisplayableContent {
    var displayName: String { get }
    var displayDescription: String { get }
    var displayImageURL: String { get }
    var uniqueID: String { get }
}
