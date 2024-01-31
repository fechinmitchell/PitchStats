//
//  NewGameView.swift
//  PitchStatsV2
//
//  Created by Fechin Mitchell on 08/01/2024.
//
import SwiftUI

enum PitchType: String, CaseIterable, Identifiable {
    case gaa = "GAA Pitch"
    case soccer = "Soccer Pitch"

    var id: String { self.rawValue }
}

struct NewGameView: View {
    @State private var teamOneName: String = ""
    @State private var teamTwoName: String = ""
    @State private var gameDate = Date()
    @State private var showingPitchView = false
    @State private var selectedPitchType: PitchType = .gaa

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Team Names")) {
                    TextField("Team 1 Name", text: $teamOneName)
                    TextField("Team 2 Name", text: $teamTwoName)
                }
                Section {
                    DatePicker("Select Date and Time", selection: $gameDate, displayedComponents: [.date, .hourAndMinute])
                }
                Section(header: Text("Pitch Type")) {
                    Picker("Select Pitch Type", selection: $selectedPitchType) {
                        ForEach(PitchType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            Button("Next") {
                showingPitchView = true
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(Color.green)
            .cornerRadius(40)
            .padding(.horizontal)
            .fullScreenCover(isPresented: $showingPitchView, content: {
                PitchView(teamOneName: teamOneName, teamTwoName: teamTwoName, pitchType: selectedPitchType) // Make sure this matches the modified PitchView
            })

        }
    }
}

