//
//  ContentView.swift
//  PitchStatsV2
//
//  Created by Fechin Mitchell on 08/01/2024.
//
import SwiftUI

struct ContentView: View {
    @State private var showingNewGameView = false

    var body: some View {
        VStack(spacing: 20) {
            // New Game button
            Button("New Game") {
                showingNewGameView = true
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(40)
            .shadow(radius: 5)
            .padding(.horizontal)
            .sheet(isPresented: $showingNewGameView) {
                NewGameView()
            }
            
            // New Game button
            Button("Previous Games") {
                showingNewGameView = true
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(40)
            .shadow(radius: 5)
            .padding(.horizontal)
            .sheet(isPresented: $showingNewGameView) {
                NewGameView()
            }

            // Previous Games button
            Button("Statistics") {
                // Action for Previous Games
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(40)
            .shadow(radius: 5)
            .padding(.horizontal)
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

