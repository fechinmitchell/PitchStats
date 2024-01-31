//
//  PitchView.swift
//  PitchStatsV2
//
//  Created by Fechin Mitchell on 08/01/2024.
//
import SwiftUI

struct Marker: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var color: Color
    var number: String
    var isDirectional: Bool = false
    var endX: CGFloat?
    var endY: CGFloat?
}

struct ColorAction: Identifiable, Equatable, Hashable {
    let id = UUID()
    var color: Color
    var actionName: String
}

struct StatsView: View {
    var stats: [String: Int]

    var body: some View {
        VStack {
            ForEach(stats.keys.sorted(), id: \.self) { key in
                Text("\(key): \(stats[key, default: 0])")
            }
        }
    }
}

struct ArrowShape: Shape {
    var start: CGPoint
    var end: CGPoint
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            // Line from start to end
            path.move(to: start)
            path.addLine(to: end)
            
            // Calculate the angle of the line
            let deltaX = end.x - start.x
            let deltaY = end.y - start.y
            let angle = atan2(deltaY, deltaX)
            
            // Define the arrowhead size
            let arrowheadLength: CGFloat = 15
            //let arrowheadWidth: CGFloat = 10
            
            // Calculate two points that form the arrowhead
            let arrowPoint1 = CGPoint(
                x: end.x - arrowheadLength * cos(angle + .pi / 6),
                y: end.y - arrowheadLength * sin(angle + .pi / 6)
            )
            
            let arrowPoint2 = CGPoint(
                x: end.x - arrowheadLength * cos(angle - .pi / 6),
                y: end.y - arrowheadLength * sin(angle - .pi / 6)
            )
            
            // Draw the lines for the arrowhead
            path.addLine(to: arrowPoint1)
            path.move(to: end)
            path.addLine(to: arrowPoint2)
            path.move(to: arrowPoint1)
            path.addLine(to: arrowPoint2)
        }
    }
}




struct PitchView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var markers: [Marker] = []
    @State private var selectedColor: Color = .clear
    @State private var showingNumberInput = false
    @State private var showingColorPicker = false
    @State private var newMarkerLocation: CGPoint?
    @State private var inputNumber: String = ""
    @State private var tempSelectedColor: Color = .clear
    @State private var tempActionName: String = ""
    @State private var colorOptions: [ColorAction] = [
        ColorAction(color: .red, actionName: "Shot"),
        ColorAction(color: .blue, actionName: "Pass"),
        ColorAction(color: .green, actionName: "Tackle")
    ]
    @State private var showingDeletionConfirm = false
    @State private var colorActionToDelete: ColorAction?
    @State private var showingStats = false

    var teamOneName: String
    var teamTwoName: String

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                //teamNamesVsView // Display team names at the top
                homeAndStatsButtons.padding(.top, 50)
                GeometryReader { geometry in
                    Image("GAA_pitch_image")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onEnded({ value in
                                    let location = geometry.frame(in: .local).contains(value.location) ? value.location : CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                                    let x = location.x / geometry.size.width
                                    let y = location.y / geometry.size.height
                                    self.newMarkerLocation = CGPoint(x: x, y: y)
                                    self.showingNumberInput = true
                                })
                        )
                        .overlay(markerOverlay(in: geometry.size))
                }
                .padding(.top, 10)
                .padding(.bottom, 10)
            }
            VStack {
                Spacer().frame(height: 30)
                teamNamesVsView // Add this line to display the team names with "Vs"
                colorButtons.padding(.horizontal).padding(.bottom, 10)
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showingNumberInput) {
            numberInputSheet()
        }
        .sheet(isPresented: $showingColorPicker) {
            colorPickerSheet()
        }
        .alert(isPresented: $showingDeletionConfirm) {
            deletionAlert()
        }
        .sheet(isPresented: $showingStats) {
            StatsView(stats: self.aggregateStats())
        }
    }
    
    private var teamNamesVsView: some View {
            HStack {
                Text(teamOneName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                Text("Vs")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(teamTwoName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
            }
            .padding(.bottom, 10) // Add padding to give some space above the color buttons
        }
    
    private var homeAndStatsButtons: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Label("Home", systemImage: "house")
                    .labelStyle(.titleAndIcon)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .shadow(radius: 3)
            }
            
            Spacer()
            
            Button(action: {
                self.showingStats = true
            }) {
                Text("Stats")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .shadow(radius: 3)
            }
        }
        .padding(.horizontal)
    }
    
    private var colorButtons: some View {
        HStack {
            addColorButton
            colorActionButtons
            undoButton
        }
    }
    
    private var addColorButton: some View {
        Button(action: {
            self.showingColorPicker = true
        }) {
            Image(systemName: "plus.circle.fill")
                .font(.title)
                .frame(width: 30, height: 30)
                .foregroundColor(.white)
        }
    }
    
    private var colorActionButtons: some View {
        ForEach(colorOptions, id: \.id) { colorAction in
            VStack {
                Button(action: {
                    self.selectedColor = colorAction.color
                }) {
                    Circle()
                        .fill(colorAction.color)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: self.selectedColor == colorAction.color ? 3 : 0)
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
                    .foregroundColor(.white)
            }
        }
    }
    
    private var undoButton: some View {
        Button(action: {
            self.removeLastMarker()
        }) {
            Image(systemName: "arrow.uturn.backward.circle.fill")
                .font(.title)
                .frame(width: 30, height: 30)
                .foregroundColor(.gray)
        }
        .foregroundColor(.white)
    }
    
    private func markerOverlay(in size: CGSize) -> some View {
        ForEach($markers) { $marker in
            ZStack {
                Circle()
                    .fill($marker.color.wrappedValue)
                    .frame(width: 30, height: 30)
                    .overlay(Text($marker.number.wrappedValue).font(.caption).foregroundColor(.white))
                    .position(x: size.width * $marker.x.wrappedValue, y: size.height * $marker.y.wrappedValue)

                if $marker.isDirectional.wrappedValue, let endX = $marker.endX.wrappedValue, let endY = $marker.endY.wrappedValue {
                    // The ArrowShape's start and end points should be set in the GeometryReader's coordinate space
                    ArrowShape(
                        start: CGPoint(x: size.width * $marker.x.wrappedValue, y: size.height * $marker.y.wrappedValue),
                        end: CGPoint(x: endX, y: endY)
                    )
                    .stroke($marker.color.wrappedValue, lineWidth: 2)
                }
            }
            // The gesture is applied to the ZStack, so the location is relative to the GeometryReader
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Update the end position of the arrow during the drag
                        // Assuming value.location is the location of the drag in the GeometryReader's coordinate space
                        $marker.endX.wrappedValue = value.location.x
                        $marker.endY.wrappedValue = value.location.y
                        $marker.isDirectional.wrappedValue = true
                    }
                    .onEnded { _ in
                        // If you need to lock the arrow's end position after the drag ends, you can do it here
                    }
            )
        }
    }
    
    // Function to snap a value to a grid
    private func snapToGrid(value: CGFloat, gridSize: CGFloat) -> CGFloat {
        let gridFactor = CGFloat(0.1) // Adjust the grid factor to your needs
        let snapValue = round(value / (gridSize * gridFactor)) * (gridSize * gridFactor)
        return snapValue
    }
    
    private func numberInputSheet() -> some View {
        NumberInputView(inputNumber: $inputNumber) { confirmed in
            if confirmed, let location = newMarkerLocation, !inputNumber.isEmpty {
                addMarker(at: location, color: selectedColor, number: inputNumber)
            }
            showingNumberInput = false
            inputNumber = ""
        }
    }
    
    private func addMarker(at location: CGPoint, color: Color, number: String) {
        guard color != .clear else { return }
        // Initialize a marker without directional data initially
        markers.append(Marker(x: location.x, y: location.y, color: color, number: number, isDirectional: false))
    }
    
    private func colorPickerSheet() -> some View {
            VStack {
                ColorPicker("Pick a new color", selection: $tempSelectedColor, supportsOpacity: false)
                    .padding()
                TextField("Action Name", text: $tempActionName)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke())
                Button("Confirm Color") {
                    if !colorOptions.contains(where: { $0.color == tempSelectedColor }) {
                        colorOptions.append(ColorAction(color: tempSelectedColor, actionName: tempActionName))
                        tempActionName = ""
                        tempSelectedColor = .clear // Resetting the color picker after use
                    }
                    showingColorPicker = false
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    
    private func deletionAlert() -> Alert {
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
    
    private func removeLastMarker() {
        if !markers.isEmpty {
            markers.removeLast()
        }
    }
    
    private func aggregateStats() -> [String: Int] {
        var stats: [String: Int] = [:]
        for marker in markers {
            if let actionName = colorOptions.first(where: { $0.color == marker.color })?.actionName {
                stats[actionName, default: 0] += 1
            }
        }
        return stats
    }
    
    struct PitchView_Previews: PreviewProvider {
        static var previews: some View {
            PitchView(teamOneName: "Team One", teamTwoName: "Team Two")
        }
    }
    
    struct NumberInputView: View {
        @Binding var inputNumber: String
        var onCommit: (Bool) -> Void
        
        var body: some View {
            VStack(spacing: 20) {
                Text("Enter the number for the marker")
                    .font(.headline)
                
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
}
