//
//  File.swift
//  
//
//  Created by Kevin van den Hoek on 23/08/2024.
//

import Foundation

extension UserDefaults {
    
    func get<T>(key: String, fallback: T? = nil) -> T? {
        if let data = self.data(forKey: key) {
            do {
                if let type = T.self as? Decodable.Type {
                    let value = try JSONDecoder().decode(type, from: data)
                    return value as? T
                } else {
                    return fallback
                }
            } catch {
                print("Failed to decode \(key) from UserDefaults: \(error)")
                return fallback
            }
        }
        return fallback
    }
    
    func set<T>(key: String, to value: T?) {
        if let value = value as? Encodable {
            do {
                let data = try JSONEncoder().encode(value)
                self.set(data, forKey: key)
            } catch {
                print("Failed to encode \(key) to UserDefaults: \(error)")
            }
        } else {
            self.removeObject(forKey: key)
        }
    }
}
