// Created by deovinsum

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 1
    @State private var coffeeCupArray = Array(1...20)
    
    @State private var bedTime = ""
    @State private var message = ""
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        
        NavigationStack {
            Form {
                Section("When do you want wake up?") {
                    
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: .infinity, alignment: .center)
                        .onChange(of: wakeUp) {
                            calculateBedTime()
                        }
                }
                
                Section("Desired amount of sleep") {
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                        .onChange(of: sleepAmount) {
                            calculateBedTime()
                        }
                }
            
                Section("Dayily coffee intake") {
                    
                    Picker("Select how many", selection: $coffeeAmount) {
                        ForEach(coffeeCupArray, id: \.self) {
                            Text($0, format: .number)
                        }
                    }
                    .onChange(of: coffeeAmount) {
                        calculateBedTime()
                    }
                }
                
                Section("Your ideal bedtime is...") {
                    Text(message)
                        .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(.blue)
                        .font(.headline)
                }
            }
            
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("BetterRest")
            .onAppear {
                self.calculateBedTime()
            }

        }
    }
    
    func calculateBedTime() {
        
        do {
            
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            bedTime = sleepTime.formatted(date: .omitted, time: .shortened)
            message = "Your ideal bedtime is \(bedTime)"
            
        } catch {
            
            message = "Sorry, there was a problem calculating you bedtime."

        }
    }
}

#Preview {
    ContentView()
}
