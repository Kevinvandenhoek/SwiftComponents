//
//  File.swift
//  
//
//  Created by Kevin van den Hoek on 23/08/2024.
//

import Foundation

extension Array: Identifiable where Element: Identifiable {
    
    public var id: [Element.ID] { map({ $0.id }) }
}
