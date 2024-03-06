//
//  PitchDetailView.swift
//  PitchStatsV2
//
//  Created by Fechin Mitchell on 14/02/2024.
//
import SwiftUI
struct PitchDetailView: View {
    var savedMatch: SavedMatch

    var body: some View {
        ScrollView {
            VStack {
                PitchDisplayView(savedMatch: savedMatch, pitchType: savedMatch.pitchType)
                    .frame(height: 900) // Adjust the height as needed

                // Convert the CodableMarkers back to Markers here before passing them to StatsView
                let markers = savedMatch.markers.map { $0.toMarker() }
                StatsView(stats: savedMatch.stats, teamOneName: savedMatch.teamOneName, teamTwoName: savedMatch.teamTwoName, markers: markers)
            }
        }
        .navigationBarTitle(Text("\(savedMatch.teamOneName) vs \(savedMatch.teamTwoName)"), displayMode: .inline)
    }
}
