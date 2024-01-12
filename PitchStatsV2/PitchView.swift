//
//  PitchView.swift
//  PitchStatsV2
//
//  Created by Fechin Mitchell on 08/01/2024.
//
import SwiftUI

struct PitchView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var markers: [Marker] = []
    @State private var selectedColor: Color = .clear
    @State private var showingNumberInput = false
    @State private var newMarkerLocation: CGPoint?
    @State private var inputNumber: String = ""

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Label("Home", systemImage: "house")
                        .labelStyle(.titleAndIcon)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                }
                Spacer()
            }
            .padding()
            .padding(.top, 20)

            GeometryReader { geometry in
                Image("pitch_image")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded({ value in
                                let x = value.location.x / geometry.size.width
                                let y = value.location.y / geometry.size.height
                                self.newMarkerLocation = CGPoint(x: x, y: y)
                                self.showingNumberInput = true
                            })
                    )
                    .overlay(markerOverlay(in: geometry.size))
            }

            HStack {
                ForEach(MarkerColor.allCases, id: \.self) { color in
                    Button(action: {
                        self.selectedColor = color.color
                    }) {
                        Circle()
                            .fill(color.color)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: selectedColor == color.color ? 3 : 0)
                            )
                    }
                }
                Button(action: {
                    self.removeLastMarker()
                }) {
                    Image(systemName: "arrow.uturn.backward.circle.fill")
                        .font(.title)
                        .frame(width: 30, height: 30)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)

            Spacer()
        }
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: $showingNumberInput) {
            NumberInputView(inputNumber: $inputNumber) { confirmed in
                if confirmed, let location = self.newMarkerLocation {
                    addMarker(at: location, color: selectedColor, number: inputNumber)
                }
                self.showingNumberInput = false
                self.inputNumber = ""
            }
        }
    }

    private func addMarker(at location: CGPoint, color: Color, number: String) {
        guard color != .clear else { return }
        markers.append(Marker(x: location.x, y: location.y, color: color, number: number))
    }

    private func markerOverlay(in size: CGSize) -> some View {
        ForEach(markers) { marker in
            ZStack {
                Circle()
                    .fill(marker.color)
                    .frame(width: 20, height: 20)
                Text(marker.number)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .position(x: size.width * marker.x, y: size.height * marker.y)
            .transition(.scale)
        }
    }

    private func removeLastMarker() {
        if !markers.isEmpty {
            markers.removeLast()
        }
    }
}

struct NumberInputView: View {
    @Binding var inputNumber: String
    var onCommit: (Bool) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter the number for the marker")
            TextField("Number", text: $inputNumber)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 200)
                .font(.largeTitle)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke())
                .padding()

            HStack {
                Button("Cancel") {
                    onCommit(false)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color.red)
                .cornerRadius(10)

                Button("Submit") {
                    onCommit(true)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color.green)
                .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct Marker: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var color: Color
    var number: String
}

enum MarkerColor: CaseIterable {
    case red, blue, green, yellow

    var color: Color {
        switch self {
        case .red: return .red
        case .blue: return .blue
        case .green: return .green
        case .yellow: return .yellow
        }
    }
}

struct PitchView_Previews: PreviewProvider {
    static var previews: some View {
        PitchView()
    }
}
