//
//  ContentView.swift
//  CoinApp
//
//  Created by Zach Huang on 2025/2/18.
//

import SwiftUI

struct ContentView: View {
    @State private var coinCounts: [String: String] = UserDefaults.standard.dictionary(forKey: "coinCounts") as? [String: String] ?? [
        "1": "0", "5": "0", "10": "0", "50": "0", "100": "0", "500": "0", "1000": "0"
    ]
    
    let coinValues: [String: Int] = [
        "1": 1, "5": 5, "10": 10, "50": 50, "100": 100, "500": 500, "1000": 1000
    ]
    
    let maxTotal = 999999  // Max total amount

    @State private var showAlert = false  // Controls alert display
    @FocusState private var isTextFieldFocused: Bool  // Track focus state

    var totalAmount: Int {
        return coinCounts.reduce(0) { total, coin in
            let count = Int(coinCounts[coin.key] ?? "0") ?? 0
            return total + (count * (coinValues[coin.key] ?? 0))
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(coinCounts.keys.sorted { Int($0)! < Int($1)! }, id: \.self) { coin in
                        VStack(spacing: 5) {
                            HStack {
                                Text("\(coin)元")
                                    .font(.title2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                TextField("0", text: Binding(
                                    get: { coinCounts[coin] ?? "0" },
                                    set: { newValue in
                                        let filteredValue = newValue.filter { $0.isNumber }
                                        if filteredValue.count > 6 {
                                            coinCounts[coin] = String(filteredValue.prefix(6))
                                        } else {
                                            coinCounts[coin] = filteredValue
                                        }
                                        saveData()
                                    }
                                ))
                                .font(.system(size: 20))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 9)
                                .background(Color(UIColor.systemGray5))
                                .cornerRadius(8)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                                .focused($isTextFieldFocused) // Track focus state

                                Button(action: {
                                    addTen(to: coin)
                                }) {
                                    Text("+10")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 7)
                                        .background(Color(red: 1.0, green: 0.713, blue: 0.761)) // RGB (255, 182, 193)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }

                Text("Total: \(totalAmount)元")
                    .font(totalAmount > maxTotal ? .system(size: 20, weight: .bold) : .system(size: 28, weight: .bold))
                    .padding()
                
                Button(action: resetCounts) {
                    Text("Reset")
                        .font(Font.title2.bold())
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 0.6, green: 0.8, blue: 1.0)) // Soft blue
                        .cornerRadius(14)
                        .padding(.horizontal)
                }
            }
            .navigationTitle("Billy the Counter")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) { // Apply toolbar globally
                    Spacer()
                    Button("Done") {
                        isTextFieldFocused = false // Dismiss keyboard
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Wow! 💰"),
                    message: Text("You are richer than I thought!"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    /// Adds +10 to the specified coin count (capped at 999999)
    func addTen(to coin: String) {
        let currentCount = Int(coinCounts[coin] ?? "0") ?? 0
        let newCount = currentCount + 10
        coinCounts[coin] = "\(newCount)"
        
        let newTotal = totalAmount + 10 * (coinValues[coin] ?? 0)
        if newTotal > maxTotal {
            showAlert = true  // Show alert if exceeds 999999
        }
        
        saveData()
    }
    
    /// Resets all coin counts to 0 and saves the data
    func resetCounts() {
        coinCounts = coinCounts.mapValues { _ in "0" }
        saveData()
    }
    
    /// Saves the coin count data to UserDefaults
    func saveData() {
        UserDefaults.standard.setValue(coinCounts, forKey: "coinCounts")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

