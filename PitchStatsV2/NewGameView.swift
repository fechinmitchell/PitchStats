//
//  NewGameView.swift
//  PitchStatsV2
//
//  Created by Fechin Mitchell on 08/01/2024.
//
import SwiftUI

struct NewGameView: View {
    @State private var teamOneName: String = ""
    @State private var teamTwoName: String = ""
    @State private var gameDate = Date()
    @State private var showingPitchView = false

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
                PitchView(teamOneName: teamOneName, teamTwoName: teamTwoName)
            })
        }
    }
}

