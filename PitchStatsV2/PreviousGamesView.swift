//
//  PreviousGamesView.swift
//  PitchStatsV2
//
//  Created by Fechin Mitchell on 08/02/2024.
//
import SwiftUI

struct PreviousGamesView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var savedMatches: [SavedMatch] = loadSavedMatches()

    var body: some View {
        NavigationView {
            List {
                ForEach(savedMatches, id: \.id) { match in
                    NavigationLink(destination: PitchDetailView(savedMatch: match)) {
                        VStack(alignment: .leading) {
                            Text("\(match.teamOneName) vs \(match.teamTwoName)")
                            Text("Date: \(match.gameDate.formatted())")
                            Text("Pitch Type: \(match.pitchType.rawValue)")
                        }
                    }
                }
                .onDelete(perform: deleteMatch)
            }
            .navigationBarTitle("Previous Games", displayMode: .inline)
            .navigationBarItems(leading: Button("Home") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: EditButton())
            .onAppear {
                self.savedMatches = Self.loadSavedMatches()
            }
        }
    }
    
    func deleteMatch(at offsets: IndexSet) {
        savedMatches.remove(atOffsets: offsets)
        saveMatches()
    }
    
    func saveMatches() {
        do {
            let data = try JSONEncoder().encode(savedMatches)
            UserDefaults.standard.set(data, forKey: "savedMatches")
        } catch {
            print("Error saving matches: \(error)")
        }
    }
    
    static func loadSavedMatches() -> [SavedMatch] {
        guard let data = UserDefaults.standard.data(forKey: "savedMatches") else { return [] }
        do {
            return try JSONDecoder().decode([SavedMatch].self, from: data)
        } catch {
            print("Error loading matches: \(error)")
            return []
        }
    }
}

