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
        ZStack { // Use a ZStack to allow layering of the background behind the VStack
            Color.black.edgesIgnoringSafeArea(.all) // Set the background to black, including under the safe areas

            VStack(spacing: 20) {
                
                Image("Logo_PS") // Replace "logo" with the name of your logo image asset
                                    .resizable() // Make the image resizable
                                    .scaledToFit() // Scale the logo to fit its allocated space
                                    .frame(width: 500, height: 300) // Set the frame to the desired width and height
                                    .padding(.top, 10) // Optional padding from the top of the VStack

                // New Game button
                Button("New Game") {
                    showingNewGameView = true
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.gray]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(40)
                .shadow(radius: 5)
                .padding(.horizontal)
                .sheet(isPresented: $showingNewGameView) {
                    NewGameView()
                }
                
                // New Game button
                Button("Previous Games") {
                   // showingNewGameView = true
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.gray]), startPoint: .leading, endPoint: .trailing))
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
                .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.gray]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(40)
                .shadow(radius: 5)
                .padding(.horizontal)
            }
            .padding(.top, 50) // Add padding at the top if needed
        }
        .edgesIgnoringSafeArea(.all) // Make sure this ZStack also ignores the safe area
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
