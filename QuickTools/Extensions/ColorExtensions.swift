//
//  ColorExtensions.swift
//  QuickTools
//
//  Created by Shakthi M on 29/07/25.
//

import SwiftUI

extension Color {
    func toHex() -> String {
        guard let nsColor = NSColor(self).usingColorSpace(.sRGB) else {
            return "#000000"
        }
        let r = Int(nsColor.redComponent * 255)
        let g = Int(nsColor.greenComponent * 255)
        let b = Int(nsColor.blueComponent * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
    
    func toRGB() -> String {
        guard let nsColor = NSColor(self).usingColorSpace(.sRGB) else {
            return "0, 0, 0"
        }
        let r = Int(nsColor.redComponent * 255)
        let g = Int(nsColor.greenComponent * 255)
        let b = Int(nsColor.blueComponent * 255)
        return "\(r), \(g), \(b)"
    }
    
    func toCSSRGB() -> String {
        guard let nsColor = NSColor(self).usingColorSpace(.sRGB) else {
            return "rgb(0, 0, 0)"
        }
        let r = Int(nsColor.redComponent * 255)
        let g = Int(nsColor.greenComponent * 255)
        let b = Int(nsColor.blueComponent * 255)
        let a = nsColor.alphaComponent
        
        if a < 1.0 {
            return String(format: "rgba(%d, %d, %d, %.2f)", r, g, b, a)
        } else {
            return "rgb(\(r), \(g), \(b))"
        }
    }
    
    func toSwift() -> String {
        guard let nsColor = NSColor(self).usingColorSpace(.sRGB) else {
            return "Color.black"
        }
        let r = nsColor.redComponent
        let g = nsColor.greenComponent
        let b = nsColor.blueComponent
        let a = nsColor.alphaComponent
        
        if a < 1.0 {
            return String(format: "Color(red: %.3f, green: %.3f, blue: %.3f, opacity: %.2f)", r, g, b, a)
        } else {
            return String(format: "Color(red: %.3f, green: %.3f, blue: %.3f)", r, g, b)
        }
    }
} 