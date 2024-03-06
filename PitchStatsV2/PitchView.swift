//
//  PitchView.swift
//  PitchStatsV2
//
//  Created by Fechin Mitchell on 08/01/2024.
//
import SwiftUI

// Part 1: Define the ColorAction struct to use UIColor
struct ColorAction: Identifiable, Equatable, Hashable {
    let id = UUID()
    var color: UIColor // Use UIColor directly for consistent color comparison
    var actionName: String
}

// Part 2: Initialize colorOptions with UIColor
struct PitchView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var markers: [Marker] = [] // Marker should have a UIColor property for color
    @State private var selectedColor: UIColor = .clear
    @State private var showingNumberInput = false
    @State private var showingColorPicker = false
    @State private var newMarkerLocation: CGPoint?
    @State private var inputNumber: String = ""
    @State private var tempSelectedColor: Color = .clear
    @State private var tempActionName: String = ""
    @State private var colorOptions: [ColorAction] = [
        ColorAction(color: UIColor.red, actionName: "Shot"),
        ColorAction(color: UIColor.blue, actionName: "Pass"),
        ColorAction(color: UIColor.green, actionName: "Tackle")
    ]

@State private var showingDeletionConfirm = false
    @State private var colorActionToDelete: ColorAction?
    @State private var showingStats = false

    var teamOneName: String
    var teamTwoName: String
    var pitchType: PitchType // Make sure this line exists
    var gameDate: Date // Add this line
    let fixedWidth: CGFloat = 1366
    let fixedHeight: CGFloat = 900


    var body: some View {
        ZStack(alignment: .top) {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                //teamNamesVsView // Display team names at the top
                homeAndStatsButtons.padding(.top, 50)
                GeometryReader { geometry in
                    Image(pitchType == .gaa ? "GAA_pitch_image" : "Soccer_pitch_image")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: fixedWidth, height: fixedHeight) // Set the fixed width and height
                        .onAppear {
                                    // Print the size for debugging
                                    print("PitchView size: \(geometry.size)")
                                }
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
                        .overlay(markerOverlay(in: CGSize(width: fixedWidth, height: fixedHeight)))
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
            StatsView(stats: self.aggregateStats(markers: self.markers), teamOneName: self.teamOneName, teamTwoName: self.teamTwoName, markers: self.markers)
        }
    }
    
    // Part 3: Function to check if two UIColors are equivalent
    private func areColorsEquivalent(_ color1: UIColor, _ color2: UIColor) -> Bool {
        return color1.isEqual(color2)
    }

    // Part 4: Update the aggregateStats function
    private func aggregateStats(markers: [Marker]) -> [String: Int] {
        var stats: [String: Int] = [:]
        for marker in markers {
            if let actionName = colorOptions.first(where: { areColorsEquivalent($0.color, marker.color) })?.actionName {
                stats[actionName, default: 0] += 1
            } else {
                print("Unmatched Color: \(marker.color)")
            }
        }
        return stats
    }

    // Part 5: Modify the addMarker function
    private func addMarker(at location: CGPoint, color: UIColor, number: String) {
        guard color != UIColor.clear else { return }
        markers.append(Marker(id: UUID(), x: location.x, y: location.y, color: color, number: number, isDirectional: false))
    }

    // Part 6: Adjust numberInputSheet to use UIColor
    private func numberInputSheet() -> some View {
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
                        showingNumberInput = false
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(10)
                    
                    Button("Submit") {
                        if !inputNumber.isEmpty {
                            if let location = newMarkerLocation {
                                addMarker(at: location, color: selectedColor, number: inputNumber)
                            }
                        }
                        showingNumberInput = false
                        inputNumber = ""
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
    
    // Part 7: Adjust colorPickerSheet to use UIColor
    private func colorPickerSheet() -> some View {
        VStack {
            ColorPicker("Pick a new color", selection: $tempSelectedColor, supportsOpacity: false)
                .padding()
            TextField("Action Name", text: $tempActionName)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke())
            Button("Confirm Color") {
                let newColor = UIColor(tempSelectedColor)
                if !colorOptions.contains(where: { areColorsEquivalent($0.color, newColor) }) && !tempActionName.isEmpty {
                    colorOptions.append(ColorAction(color: newColor, actionName: tempActionName))
                }
                showingColorPicker = false
                tempActionName = ""
                tempSelectedColor = .clear
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
    
    // Part 8: Update markerOverlay to convert UIColor to Color
    private func markerOverlay(in size: CGSize) -> some View {
            ForEach($markers, id: \.id) { $marker in // Use \.id for identifying markers
                ZStack {
                    Circle()
                        .fill(Color($marker.color.wrappedValue)) // Convert UIColor to Color
                        .frame(width: 30, height: 30)
                        .overlay(Text($marker.number.wrappedValue)
                        .font(.caption)
                        .foregroundColor(.white))
                        .position(x: size.width * $marker.x.wrappedValue, y: size.height * $marker.y.wrappedValue)

                    if $marker.isDirectional.wrappedValue, let endX = $marker.endX.wrappedValue, let endY = $marker.endY.wrappedValue {
                        ArrowShape(
                            start: CGPoint(x: size.width * $marker.x.wrappedValue, y: size.height * $marker.y.wrappedValue),
                            end: CGPoint(x: endX, y: endY)
                        )
                        .stroke(Color($marker.color.wrappedValue), lineWidth: 2) // Convert UIColor to Color
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
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
    // Part 9: Update colorActionButtons for selection
    private var colorActionButtons: some View {
        ForEach(colorOptions, id: \.id) { colorAction in
            VStack {
                Button(action: {
                    self.selectedColor = colorAction.color
                }) {
                    Circle()
                        .fill(Color(colorAction.color)) // Convert UIColor to Color here
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
            .padding(.bottom, 10)
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
                    let stats = self.aggregateStats(markers: self.markers)
                    print("Stats to be shown: \(stats)") // This will print the stats to the console
                    self.showingStats = true
                }) {
                    Text("Stats")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                }

                Button(action: {
                            self.saveCurrentMatch(gameDate: self.gameDate) // Pass the gameDate property to the function.
                        }) {
                            Text("Export")
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

    private func deletionAlert() -> Alert {
        Alert(
            title: Text("Delete Color Action"),
            message: Text("Are you sure you want to delete this color action?"),
            primaryButton: .destructive(Text("Confirm")) {
                if let actionToDelete = colorActionToDelete {
                    colorOptions.removeAll { $0.id == actionToDelete.id }
                    colorActionToDelete = nil
                }
            },
            secondaryButton: .cancel()
        )
    }

    private func removeLastMarker() {
        markers.removeLast()
    }

    private func saveCurrentMatch(gameDate: Date) {
        // Aggregate stats from markers
        let stats = aggregateStats(markers: self.markers)
        
        // Convert markers to CodableMarker instances
        let codableMarkers = markers.map { marker in
            return CodableMarker(from: marker)
        }
        
        // Create a new SavedMatch instance with all necessary properties
        let savedMatch = SavedMatch(
            id: UUID(),  // You need to generate a new UUID for the saved match
            teamOneName: teamOneName,
            teamTwoName: teamTwoName,
            gameDate: gameDate,
            pitchType: pitchType,
            stats: stats, // Use the stats computed from the markers
            markers: codableMarkers // Use the array of CodableMarkers
        )
        
        // Load existing saved matches
        var savedMatches = loadSavedMatches()
        // Append the new match
        savedMatches.append(savedMatch)
        
        // Try to encode the array of saved matches and save it to UserDefaults
        if let data = try? JSONEncoder().encode(savedMatches) {
            UserDefaults.standard.set(data, forKey: "savedMatches")
        }
    }


    private func loadSavedMatches() -> [SavedMatch] {
        guard let data = UserDefaults.standard.data(forKey: "savedMatches") else { return [] }
        if let savedMatches = try? JSONDecoder().decode([SavedMatch].self, from: data) {
            return savedMatches
        }
        return []
    }
    
}

struct StatsView: View {
    var stats: [String: Int]
    var teamOneName: String
    var teamTwoName: String
    var markers: [Marker] // Assuming Marker is already defined as per your setup

    var body: some View {
        ScrollView { // Ensures content fits even if it exceeds screen size
            VStack(alignment: .leading) {
                // Team names header
                Text("\(teamOneName) Vs \(teamTwoName)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue) // Customize this color as needed
                    .padding()
                    .frame(maxWidth: .infinity) // Use maxWidth to ensure the Text view takes up all available space
                    .multilineTextAlignment(.center) // Center-align the text within its frame


                Divider()

                // Table header
                HStack {
                    Text("Action")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary) // Subtle color for the header
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    Text("Count")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary) // Matching style for consistency
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal)
                }
                .padding(.vertical, 5)
                .background(Color(UIColor.systemGray5)) // Slightly darker background for header
                .cornerRadius(8)

                // Stats rows
                ForEach(stats.keys.sorted(), id: \.self) { key in
                    HStack {
                        Text(key)
                            .fontWeight(.medium)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        Text("\(stats[key, default: 0])")
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                            .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    Divider() // Adds a divider between rows for clear separation
                }
            }
            .padding() // Padding for the entire VStack
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
// Helper extension to convert from SwiftUI Color to UIColor
extension UIColor {
    static func from(color: Color) -> UIColor {
        let components = color.components()
        return UIColor(red: components.red, green: components.green, blue: components.blue, alpha: components.alpha)
    }
}

extension Color {
    func components() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }
}
