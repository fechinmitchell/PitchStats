//
//  PitchType.swift
//  PitchStatsV2
//
//  Created by Fechin Mitchell on 09/02/2024.
//
import Foundation

enum PitchType: String, CaseIterable, Identifiable, Codable {
    case gaa = "GAA Pitch"
    case soccer = "Soccer Pitch"

    var id: String { self.rawValue }
}
