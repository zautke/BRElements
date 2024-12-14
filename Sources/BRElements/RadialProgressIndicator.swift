//
//  RadialProgressIndicator.swift
//  BRElements
//
//  Created by Luke Zautke on 12/14/24.
//

import SwiftUI

@available(iOS 13.0, macOS 13.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)

public struct RadialProgressIndicator: View {
    /// Progress should be between 0.0 (no progress) and 1.0 (complete)
    @Binding var progress: CGFloat

    /// The thickness of the stroke for both the background track and the progress arc
    var lineWidth: CGFloat = 2.0
    
    /// The background track color
    var trackColor: Color = Color(.quaternaryLabel)
    
    /// The progress arc color
    var progressColor: Color = Color.accentColor
    
    public var body: some View {
        ZStack {
            // Background Track
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)
            
            // Foreground Progress Arc
            Circle()
                .trim(from: 0.0, to: max(0.0, min(progress, 1.0)))
                .stroke(progressColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                // Rotate so that progress starts at 12 o'clock
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 16, height: 16)
        .animation(.easeInOut(duration: 0.2), value: progress)
    }
}

@available(iOS 13.0, *)
@MainActor
class ProgressViewModel: ObservableObject {
    @Published var progress: CGFloat = 0.0
    private var task: Task<Void, Never>? = nil

    func startProgress(interval: TimeInterval = 0.5) {
        stopProgress() // Stop any existing task before starting a new one
        task = Task { @MainActor in
            await simulateProgress(interval: interval)
        }
    }

    func stopProgress() {
        task?.cancel()
        task = nil
    }

    @MainActor
    private func simulateProgress(interval: TimeInterval) async {
        while progress < 1.0 {
            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            progress += 0.1
        }
    }
}

@available(iOS 14.0, *)
struct ContentView: View {
    @StateObject private var viewModel = ProgressViewModel()

    var body: some View {
        VStack {
            HStack {
                Text("Copying to Volume")
                RadialProgressIndicator(progress: $viewModel.progress)
            }
            .padding()
            
            Button("Start Progress") {
                viewModel.startProgress()
            }
            
            Button("Stop Progress") {
                viewModel.stopProgress()
            }
        }
    }
}
