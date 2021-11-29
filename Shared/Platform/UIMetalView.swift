#if !os(macOS)

import SwiftUI
import UIKit
import MetalKit

struct MetalView: UIViewRepresentable {
    var r: Double
    var g: Double
    var b: Double
    var frame: CGRect
    var counter: UInt64
    
    func updateUIView(_ view: MTKView, context: Context) {
        let deltaTime = counter - context.coordinator.prevCounter;
        view.clearColor = MTLClearColorMake(r, g, b, 1.0)
        view.draw()
        context.coordinator.renderer?.update(deltaTime)
        
        context.coordinator.prevCounter = counter
    }
    
    func makeUIView(context: Context) -> MTKView {
        let view = MTKView(frame: frame)
        view.enableSetNeedsDisplay = true
        view.device = MTLCreateSystemDefaultDevice()
        view.clearColor = MTLClearColorMake(r, g, b, 1.0)
        
        guard let renderer = TriangleRenderer(view: view)
        else {
            return view
        }
         
        context.coordinator.renderer = renderer
        
        context.coordinator.renderer!.mtkView(view, drawableSizeWillChange: view.drawableSize)
        
        view.delegate = context.coordinator.renderer
        return view
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var view: MetalView
        var renderer: TriangleRenderer?
        var prevCounter: UInt64 = 0;

        init(_ view: MetalView) {
            self.view = view
            self.renderer = nil
        }
    }
    
    init(frame: CGRect, counter: UInt64, r: Double, g: Double, b: Double) {
        self.frame = frame
        self.r = r
        self.g = g
        self.b = b
        self.counter = counter
    }
}

#endif
