//
//  ContentView.swift
//  BetterRest
//
//  Created by kqDevs on 28/07/2024.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    //@State private var alertTitle = ""
    //@State private var alertMessage = ""
    //@State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("When do you want to wake up?") {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                // more code to come
                
                Section("Desired amount of sleep") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                    
                Section("Daily coffee intake") {
                    Picker("Select how many cups of coffee", selection: $coffeeAmount) {
                        ForEach(1..<21) {
                            Text("^[\($0) cup](inflect: true) ☕️")
                        }
                    }
                    .labelsHidden()
                    //Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 1...20)
                    // Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cup(s)", value: $coffeeAmount, in: 1...20)
                }
            }
            .navigationTitle("BetterRest")
            //.toolbar {
            //    Button("Calculate", action: calculateBedTime)
            //}
            //.alert(alertTitle, isPresented: $showingAlert) {
            //    Button("OK") { }
            //} message: {
            //    Text(alertMessage)
            //}
            
            VStack {
                Text("Your ideal bedtime is...")
                    //.frame(maxWidth: .infinity)
                .padding(.vertical)
                .font(.title3.bold())
                
                Text("\(calculateBedTime())")
                    //.frame(maxWidth: .infinity, maxHeight: 100)
                    .fontDesign(.serif)
                    .font(.system(size: 60))
                    .bold()
            }
            .frame(maxWidth: .infinity, maxHeight: 120, alignment: .center)
            .background(.windowBackground)
            
            Spacer()
            Spacer()
        }
        Spacer()
        Spacer()
    }
    
    func calculateBedTime() -> String {
        var sleepMessage: String
        
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            sleepMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            //alertTitle = "Your ideal bedtime is..."
            //alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            //alertTitle = "Error"
            sleepMessage = "Sorry, there was a problem calculating your bedtime."
        }
        
        //showingAlert = true
        return sleepMessage
    }
}

#Preview {
    ContentView()
}
