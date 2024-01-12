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
    @State private var tempSelectedColor: Color = .clear // Temporary color holder
    @State private var tempActionName: String = "" // Temporary action name holder
    @State private var showingNumberInput = false
    @State private var showingColorPicker = false
    @State private var newMarkerLocation: CGPoint?
    @State private var inputNumber: String = ""
    @State private var colorOptions: [ColorAction] = [
        ColorAction(color: .red, actionName: "Shot"),
        ColorAction(color: .blue, actionName: "Pass"),
        ColorAction(color: .green, actionName: "Tackle"),
        ColorAction(color: .yellow, actionName: "Run")
    ]
    @State private var showingDeletionConfirm = false
    @State private var colorActionToDelete: ColorAction?

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

            Spacer().frame(height: 0) // This will push the content up by 20px

            HStack {
                Button(action: {
                    self.showingColorPicker = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .frame(width: 30, height: 30)
                            .foregroundColor(.black)
            }

                ForEach(colorOptions, id: \.self) { colorAction in
                    VStack {
                        Button(action: {
                            self.selectedColor = colorAction.color
                        }) {
                            Circle()
                                .fill(colorAction.color)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: selectedColor == colorAction.color ? 3 : 0)
                                )
                        }
                        .simultaneousGesture(
                            LongPressGesture()
                                .onEnded { _ in
                                    self.colorActionToDelete = colorAction
                                    self.showingDeletionConfirm = true
                                }
                        )
                        Text(colorAction.actionName)
                            .font(.caption)
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
    .sheet(isPresented: $showingColorPicker) {
        VStack {
            ColorPicker("Pick a new color", selection: $tempSelectedColor, supportsOpacity: false)
                .padding()
            TextField("Action Name", text: $tempActionName)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke())
            Button("Confirm Color") {
                if !colorOptions.contains(where: { $0.color == tempSelectedColor }) {
                    colorOptions.append(ColorAction(color: tempSelectedColor, actionName: tempActionName))
                }
                tempActionName = ""
                showingColorPicker = false
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
    .alert(isPresented: $showingDeletionConfirm) {
        Alert(
        title: Text("Delete Color Action"),
        message: Text("Are you sure you want to delete this color action?"),
        primaryButton: .destructive(Text("Confirm")) {
            if let colorAction = self.colorActionToDelete {
                self.colorOptions.removeAll { $0 == colorAction }
                    }
            },
        secondaryButton: .cancel()
        )
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

struct ColorAction: Identifiable, Equatable, Hashable {
    let id = UUID()
    var color: Color
    var actionName: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        // hasher.combine(color) // Cannot hash Color directly
        // If needed, you can add additional properties to hash here
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

struct PitchView_Previews: PreviewProvider {
    static var previews: some View {
    PitchView()
    }
}

