//
//  ContentView.swift
//  Shared
//
//  Created by Thomas Step on 11/5/20.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedNoise = Noises.white
    @State private var repeatPomodoro : Bool = true
    @State private var focusTime : Double = 25
    @State private var breakTime : Double = 5
    @State private var longBreakTime : Double = 5
    @State private var timer : Timer?
    @State private var timeInSeconds : Int = 1500
    @State private var started : Bool = false
    @State private var focusing : Bool = false
    @State private var breaking : Bool = false
    
    var body: some View {
        ScrollView {
            VStack{
                Text("Pick your noise")
                // https://developer.apple.com/documentation/swiftui/picker
                Picker("Noise", selection: $selectedNoise) {
                    Text("White").tag(Noises.white)
                    Text("Brown").tag(Noises.brown)
                    Text("Pink").tag(Noises.pink)
                }
                Toggle(isOn: $repeatPomodoro) {
                    Text("Repeat timer?")
                }
                    .padding()
                
                if (!repeatPomodoro) {
                    Text("Timer")
                    Slider(value: $focusTime, in: 0...60, step: 1)
                        .padding()
                    Text("\(focusTime, specifier: "%.0f") minutes")
                } else {
                    Text("Pomodoro timer options")
                    Slider(value: $focusTime, in: 0...60, step: 1)
                        .padding()
                    Text("\(focusTime, specifier: "%.0f") minutes on")
                    
                    Slider(value: $breakTime, in: 0...60, step: 1)
                        .padding()
                    Text("\(breakTime, specifier: "%.0f") minutes off")
                    
                    Slider(value: $longBreakTime, in: 0...60, step: 1)
                        .padding()
                    Text("\(longBreakTime, specifier: "%.0f") minutes off every four rounds")
                }

                if (!started) {
                    Button("Start", action: startTimer)
                        .padding()
                } else {
                    Button("Stop", action: stopTimer)
                        .padding()
                    let minutes = timeInSeconds / 60 % 60
                    let seconds = timeInSeconds % 60
                    let clock = String(format:"%02i:%02i", minutes, seconds)
                    if (focusing) {
                        Text("\(clock) focusing")
                    }
                    if (breaking) {
                        Text("\(clock) breaking")
                    }
                }
            }
        }
    }
    
    func startTimer() -> Void {
        timeInSeconds = Int(focusTime * 60)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {
            _ in
            if (timeInSeconds <= 0) {
                if (focusing) {
                    print("focusing")
                    timeInSeconds = Int(breakTime * 60)
                    breaking = true
                    focusing = false
                } else if (breaking) {
                    print("breaking")
                    timeInSeconds = Int(focusTime * 60)
                    focusing = true
                    breaking = false
                }
            }
            timeInSeconds -= 1
        })
        focusing = true
        started = true
    }
    
    func stopTimer() -> Void {
        timer?.invalidate()
        started = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
