//
//  ContentView.swift
//  Shared
//
//  Created by Thomas Step on 11/5/20.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var noisePlayer = NoisePlayer()
    @State private var selectedNoise = NoiseTypes.brown
    @State private var repeatPomodoro : Bool = true
    @State private var focusTime : Double = 25
    @State private var breakTime : Double = 5
    @State private var longBreakTime : Double = 20
    @State private var pomodoroIteration : Int = 1
    @State private var timer : Timer?
    @State private var timeInSeconds : Int = 1500
    @State private var started : Bool = false
    @State private var focusing : Bool = false
    @State private var breaking : Bool = false
    
    var body: some View {
        ScrollView {
            if (started) {
                VStack {
                    // Timer and stop botton
                    let minutes = timeInSeconds / 60 % 60
                    let seconds = timeInSeconds % 60
                    let clock = String(format:"%02i:%02i", minutes, seconds)
                    if (focusing) {
                        Text("\(clock) focusing")
                            .padding()
                    } else if (breaking) {
                        Text("\(clock) breaking")
                            .padding()
                    }
                    Button("Stop", action: stopTimer)
                        .padding()
                }
                .padding()
            } else {
                // Noise option, timing options and start button
                VStack {
                    Text("Pick your noise")
                    Picker("Noise", selection: $selectedNoise) {
                        Text("White").tag(NoiseTypes.white)
                        Text("Brown").tag(NoiseTypes.brown)
                        Text("Pink").tag(NoiseTypes.pink)
                    }
                }
                VStack {
                    Text("Pomodoro timer options")
                    Slider(value: $focusTime, in: 1...60, step: 1)
                        .padding()
                    Text("\(focusTime, specifier: "%.0f") minutes on")

                    Slider(value: $breakTime, in: 1...60, step: 1)
                        .padding()
                    Text("\(breakTime, specifier: "%.0f") minutes off")

                    Slider(value: $longBreakTime, in: 1...60, step: 1)
                        .padding()
                    Text("\(longBreakTime, specifier: "%.0f") minutes off every four rounds")
                }
                VStack {
                    let minutes = Int(focusTime) % 60
                    let seconds = Int(focusTime) * 60 % 60
                    let clock = String(format:"%02i:%02i", minutes, seconds)
                    Text("\(clock)")
                        .padding()
                    Button("Start", action: startTimer)
                        .padding()
                }
            }
        }
    }
    
    func startTimer() -> Void {
        timeInSeconds = Int(focusTime * 60)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {
            timerInBlock in
            if (timeInSeconds <= 0) {
                if (focusing && pomodoroIteration < 4) {
                    print("pomodoro interations: \(pomodoroIteration)")
                    print("focus to break")
                    timeInSeconds = Int(breakTime * 60)
                    noisePlayer.pauseSound()
                    pomodoroIteration += 1
                    focusing = false
                    breaking = true
                } else if (focusing && pomodoroIteration >= 4) {
                    print("pomodoro interations: \(pomodoroIteration)")
                    print("focus to long break")
                    timeInSeconds = Int(longBreakTime * 60)
                    noisePlayer.pauseSound()
                    pomodoroIteration = 1
                    focusing = false
                    breaking = true
                }  else if (breaking) {
                    print("break to focus")
                    timeInSeconds = Int(focusTime * 60)
                    noisePlayer.resumeSound()
                    focusing = true
                    breaking = false
                } else {
                    // In case of a weird state
                    stopTimer()
                }
            }
            timeInSeconds -= 1
        })
        noisePlayer.playSound(noise: selectedNoise.id)
        focusing = true
        breaking = false
        started = true
    }
    
    func stopTimer() -> Void {
        timer?.invalidate()
        noisePlayer.stopSound()
        focusing = false
        breaking = false
        started = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
