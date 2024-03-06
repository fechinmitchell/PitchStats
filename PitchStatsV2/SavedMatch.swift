//
//  SavedMatch.swift
//  PitchStatsV2
//  Created by Fechin Mitchell on 08/02/2024.
//
import Foundation
import UIKit

// Extend UIColor to be convertible to/from a hex string for Codable conformance
extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(
            format: "#%02lX%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255)),
            lroundf(Float(a * 255))
        )
    }

    convenience init?(hexString: String) {
        let r, g, b, a: CGFloat

        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = String(hexString[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        return nil
    }
}

// CodableMarker is used for encoding/decoding marker data
struct CodableMarker: Codable {
    var id: UUID
    var x: CGFloat
    var y: CGFloat
    var color: String
    var number: String
    var isDirectional: Bool
    var endX: CGFloat?
    var endY: CGFloat?

    init(from marker: Marker) {
        self.id = marker.id
        self.x = marker.x
        self.y = marker.y
        self.color = marker.color.toHexString()
        self.number = marker.number
        self.isDirectional = marker.isDirectional
        self.endX = marker.endX
        self.endY = marker.endY
    }

    func toMarker() -> Marker {
        return Marker(
            id: self.id,
            x: self.x,
            y: self.y,
            color: UIColor(hexString: self.color) ?? UIColor.black,
            number: self.number,
            isDirectional: self.isDirectional,
            endX: self.endX,
            endY: self.endY
        )
    }
}

// Marker struct for usage within SwiftUI views, not Codable
struct Marker: Identifiable {
    var id: UUID
    var x: CGFloat
    var y: CGFloat
    var color: UIColor
    var number: String
    var isDirectional: Bool
    var endX: CGFloat?
    var endY: CGFloat?
}

// SavedMatch struct represents a match with teams, game date, pitch type, and markers
struct SavedMatch: Codable, Identifiable {
    var id: UUID
    var teamOneName: String
    var teamTwoName: String
    var gameDate: Date
    var pitchType: PitchType
    var stats: [String: Int]  // Add this property to store the stats
    var markers: [CodableMarker]

    // Initializers, methods, or additional properties related to a match can go here
}
