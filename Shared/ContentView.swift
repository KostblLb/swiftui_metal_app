//
//  ContentView.swift
//  Shared
//
//  Created by Konstantin Vysotski on 29.10.2021.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State var r: Double
    @State var g: Double
    @State var b: Double
    
    @State var frame: CGRect = .zero
    
    @StateObject var loop : Loop = Loop()

    var body: some View {
        GeometryReader { geometry in
            VStack {
                MetalView(frame: geometry.frame(in: .local), counter: loop.i, r: r, g: g, b: b)
                Stepper(value: $r, in: 0...1, step: 0.2) {
                    Text("R \(r)")
                }
                Stepper(value: $g, in: 0...1, step: 0.2) {
                    Text("G \(g)")
                }
                Stepper(value: $b, in: 0...1, step: 0.2) {
                    Text("B \(b)")
                }
                Text("\(loop.i)")
            }
        }
    }
}

class Loop : ObservableObject {
    private var counter = PassthroughSubject<UInt64, Never>()

    @Published var i : UInt64 = 0   // only for UI

    func startLoop() {
        while true {
            counter.send(DispatchTime.now().uptimeNanoseconds) // publish event
        }
    }

    private var subscriber: AnyCancellable?
    init() {
        subscriber = counter
            .throttle(for: 0.01, scheduler: DispatchQueue.global(qos: .background), latest: true) // drop in background
            .receive(on: DispatchQueue.main)  // only latest result
            .sink { [weak self] (value) in    // on @pawello2222 comment
               self?.i = value
            }

        DispatchQueue.global(qos: .background).async {
            self.startLoop()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(r: 0.5, g: 0.5, b: 0.5)
    }
}
