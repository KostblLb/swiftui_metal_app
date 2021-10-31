//
//  ContentView.swift
//  Shared
//
//  Created by Konstantin Vysotski on 29.10.2021.
//

import SwiftUI

struct ContentView: View {
    @State var r: Double
    @State var g: Double
    @State var b: Double

    var body: some View {
        VStack {
            MetalView(r: r, g: g, b: b)
            Stepper(value: $r, in: 0...1, step: 0.2) {
                Text("R \(r)")
            }
            Stepper(value: $g, in: 0...1, step: 0.2) {
                Text("G \(g)")
            }
            Stepper(value: $b, in: 0...1, step: 0.2) {
                Text("B \(b)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(r: 0.5, g: 0.5, b: 0.5)
    }
}
