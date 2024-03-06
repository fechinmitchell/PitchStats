//
//  PitchDisplayView.swift
//  PitchStatsV2
//
//  Created by Fechin Mitchell on 14/02/2024.
//
import SwiftUI

struct PitchDisplayView: View {
    let savedMatch: SavedMatch
    let fixedWidth: CGFloat = 1366
    let fixedHeight: CGFloat = 900
    var pitchType: PitchType // Make sure this line exists


    
    var body: some View {
        GeometryReader { geometry in
            Image(pitchType == .gaa ? "GAA_pitch_image" : "Soccer_pitch_image")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: fixedWidth, height: fixedHeight) // Use the same fixed width and height
                .contentShape(Rectangle())
                .overlay(markerOverlay(in: CGSize(width: fixedWidth, height: fixedHeight)))

        }
    }
    
    private func markerOverlay(in size: CGSize) -> some View {
        ForEach(savedMatch.markers.map { $0.toMarker() }, id: \.id) { marker in
            // Calculate start and end points based on the actual size of the image
            let startPoint = CGPoint(x: size.width * marker.x, y: size.height * marker.y)
            let endPoint = CGPoint(
                x: size.width * (marker.isDirectional ? (marker.endX ?? marker.x) : marker.x),
                y: size.height * (marker.isDirectional ? (marker.endY ?? marker.y) : marker.y)
            )
            
            ZStack {
                Circle()
                    .fill(Color(marker.color)) // Convert UIColor to Color
                    .frame(width: 30, height: 30)
                    .overlay(Text(marker.number)
                        .font(.caption)
                        .foregroundColor(.white))
                    .position(startPoint)
                if marker.isDirectional {
                    ArrowShape(start: startPoint, end: endPoint)
                    .stroke(Color(marker.color), lineWidth: 2)
                }
            }
        }
    }



    private func markerView(for marker: Marker, in size: CGSize) -> some View {
        let startX = size.width * marker.x
        let startY = size.height * marker.y
        let endX = marker.isDirectional ? size.width * (marker.endX ?? marker.x) : startX
        let endY = marker.isDirectional ? size.height * (marker.endY ?? marker.y) : startY

        return ZStack {
            Circle()
                .fill(Color(marker.color)) // Ensure you are converting the UIColor to Color
                .frame(width: 30, height: 30)
                .overlay(Text(marker.number)
                    .font(.caption)
                    .foregroundColor(.white))
                .position(x: startX, y: startY)

            if marker.isDirectional {
                ArrowShape(start: CGPoint(x: startX, y: startY),
                           end: CGPoint(x: endX, y: endY))
                .stroke(Color(marker.color), lineWidth: 2) // Ensure you are converting the UIColor to Color
            }
        }
    }


}



