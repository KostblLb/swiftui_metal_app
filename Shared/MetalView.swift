import SwiftUI
import UIKit
import MetalKit

struct MetalView: UIViewRepresentable {
    var r: Double
    var g: Double
    var b: Double
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        uiView.clearColor = MTLClearColorMake(r, g, b, 1.0)
        uiView.draw()
    }
    
    func makeUIView(context: Context) -> MTKView {
        let view = MTKView()
        view.enableSetNeedsDisplay = true;
        view.device = MTLCreateSystemDefaultDevice();
        view.clearColor = MTLClearColorMake(r, g, b, 1.0);
        
        guard let renderer = Renderer(view: view)
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
        var renderer: Renderer?

        init(_ view: MetalView) {
            self.view = view
            self.renderer = nil
        }
    }
    
    init(r: Double, g: Double, b: Double) {
        self.r = r
        self.g = g
        self.b = b
    }
}
