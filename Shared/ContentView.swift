//
//  ContentView.swift
//  Shared
//
//  Created by Thomas Step on 11/5/20.
//

import SwiftUI
import AVFoundation
import Combine

#if canImport(UIKit)
extension View {
    func hideKeyboard() -> Void {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct ContentView: View {
    @State private var noisePlayer = NoisePlayer()
    @State private var selectedNoise = NoiseTypes.brown
    
    // Amount of time to focus (in minutes)
    @State private var focusTime : String = "25"
    
    // Amount of time to break (in minutes)
    @State private var breakTime : String = "5"
    
    // Amount of time to break every 4 rounds (in minutes)
    @State private var longBreakTime : String = "20"
    
    // Amount of short break rounds
    // Used to determine when to have a long break
    @State private var shortBreakRounds : Int = 0
    
    // This holds a timer if it is present
    @State private var timer : Timer?
    
    // This holds the timers value
    @State private var timeInSeconds : Int = 1500
    
    // This is to determine whether or not pomodoro rounds should be counted
    @State private var isLimited : Bool = false
    
    // This is to hold the amount of rounds desired by user
    // Similar to a sleep timer
    @State private var desiredPomodoroRounds : String = "4"
    
    // This is to count pomodoro rounds until it reaches desiredPomodoroRounds
    @State private var pomodoroRounds : Int = 0
    @State private var started : Bool = false
    @State private var focusing : Bool = false
    @State private var breaking : Bool = false
    
    var body: some View {
        if (started) {
            VStack {
                // Timer and stop botton
                let minutes = timeInSeconds / 60 % 60
                let seconds = timeInSeconds % 60
                let clock = String(format:"%02i:%02i", minutes, seconds)
                
                Text("Round \(pomodoroRounds + 1)")
                    .padding()
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
            ScrollView {
                // Noise option, timing options and start button
                VStack {
                    Text("Pick your noise")
                    Picker("Noise", selection: $selectedNoise) {
                        Text("White").tag(NoiseTypes.white)
                        Text("Brown").tag(NoiseTypes.brown)
                        Text("Pink").tag(NoiseTypes.pink)
                    }
                }
                .padding()
                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 20) {
                    Group {
                        Text("Pomodoro timer options")
                        Divider()
                    }

                    Group {
                        Text("Focus time (minutes)")
                        TextField("Default: 25 minutes", text: $focusTime)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .onReceive(Just(focusTime)) { newValue in
                                let filtered = newValue.filter { "0123456789".contains($0)
                                }
                                let numberValue = Int(filtered) ?? 25
                                if numberValue < 1 {
                                    self.focusTime = "1"
                                }
                                
                                if numberValue > 60 {
                                    self.focusTime = "60"
                                }
                                
                                if filtered != newValue {
                                    self.focusTime = filtered
                                }
                            }
                        Divider()
                    }

                    Group {
                        Text("Normal break time (minutes)")
                        TextField("Default: 5 minutes", text: $breakTime)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .onReceive(Just(breakTime)) { newValue in
                                let filtered = newValue.filter { "0123456789".contains($0)
                                }
                                let numberValue = Int(filtered) ?? 5
                                if numberValue < 1 {
                                    self.breakTime = "1"
                                }
                                
                                if numberValue > 60 {
                                    self.breakTime = "60"
                                }
                                
                                if filtered != newValue {
                                    self.breakTime = filtered
                                }
                            }
                        Divider()
                    }
                    
                    Group {
                        Text("Long break time (minutes)")
                        TextField("Default: 20 minutes", text: $longBreakTime)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .onReceive(Just(longBreakTime)) { newValue in
                                let filtered = newValue.filter { "0123456789".contains($0)
                                }
                                let numberValue = Int(filtered) ?? 20
                                if numberValue < 1 {
                                    self.longBreakTime = "1"
                                }
                                
                                if numberValue > 60 {
                                    self.longBreakTime = "60"
                                }
                                
                                if filtered != newValue {
                                    self.longBreakTime = filtered
                                }
                            }
                        Divider()
                    }
                    
                    Group {
                        Toggle(isOn: $isLimited) {
                            Text("Limit pomodoro rounds")
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color.blue))
                        
                        if (isLimited) {
                            TextField("Default: 4 rounds", text: $desiredPomodoroRounds)
                                .multilineTextAlignment(.center)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .onReceive(Just(desiredPomodoroRounds)) { newValue in
                                    let filtered = newValue.filter { "0123456789".contains($0)
                                    }
                                    let numberValue = Int(filtered) ?? 4
                                    if numberValue < 1 {
                                        self.desiredPomodoroRounds = "1"
                                    }
                                    
                                    if numberValue > 60 {
                                        self.desiredPomodoroRounds = "20"
                                    }
                                    
                                    if filtered != newValue {
                                        self.desiredPomodoroRounds = filtered
                                    }
                                }
                        }
                    }
                    
                }
                .padding()
                VStack {
                    Button("Start", action: startTimer)
                        .padding()
                }
            }
            .onTapGesture(count: 1, perform: self.hideKeyboard)
        }
    }

    func startTimer() -> Void {
        timeInSeconds = 60 * (Int(focusTime) ?? 25)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {
            timerInBlock in
            if (timeInSeconds <= 0) {
                if (focusing && shortBreakRounds < 3) {
                    // Reset countdown timer for short break
                    timeInSeconds = 60 * (Int(breakTime) ?? 5)
                    
                    // Transition state to resemble break
                    noisePlayer.pauseSound()
                    focusing = false
                    breaking = true
                    
                    // Add to pomodoro iteration for long break
                    shortBreakRounds += 1
                } else if (focusing && shortBreakRounds >= 3) {
                    // Reset countdown timer for long break
                    timeInSeconds = 60 * (Int(longBreakTime) ?? 20)
                    
                    // Transition state to resemble break
                    noisePlayer.pauseSound()
                    focusing = false
                    breaking = true
                    
                    // Reset pomodoro iteration for next long break
                    shortBreakRounds = 0
                }  else if (breaking) {
                    // Reset countdown timer for focus
                    timeInSeconds = 60 * (Int(focusTime) ?? 25)
                    
                    // Transition state to resemble focus
                    noisePlayer.resumeSound()
                    focusing = true
                    breaking = false
                    
                    // Add to current total rounds tally
                    pomodoroRounds += 1
                } else {
                    // In case of a weird state
                    stopTimer()
                }
                
                if (
                    isLimited
                    && (pomodoroRounds >= (Int(desiredPomodoroRounds) ?? 4))
                ) {
                    stopTimer()
                }
            }
            timeInSeconds -= 1
        })
        
        // Transition state to resemble focus
        noisePlayer.playSound(noise: selectedNoise.id)
        focusing = true
        breaking = false
        started = true
    }
    
    func stopTimer() -> Void {
        timer?.invalidate()
        
        // Transition state to resemble no timing
        noisePlayer.stopSound()
        focusing = false
        breaking = false
        started = false
        shortBreakRounds = 0
        
        // Reset total rounds counter for next time
        pomodoroRounds = 0
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
