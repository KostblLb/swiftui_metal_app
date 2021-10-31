//
//  Renderer.swift
//  ModelViewer
//
//  Created by Konstantin Vysotski on 31.10.2021.
//

import Foundation
import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    func draw(in view: MTKView) {
        // The render pass descriptor references the texture into which Metal should draw
        guard let renderPassDescriptor = view.currentRenderPassDescriptor
        else {
            return;
        }

        let commandBuffer = cmdQueue.makeCommandBuffer()
        
        // Create a render pass and immediately end encoding, causing the drawable to be cleared
        guard let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        else {
            return
        }
        
        commandEncoder.endEncoding()
        
        // Get the drawable that will be presented at the end of the frame
        guard let drawable = view.currentDrawable
        else {
            return
        }

        // Request that the drawable texture be presented by the windowing system once drawing is done
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    var device: MTLDevice
    var cmdQueue: MTLCommandQueue
    
    init?(view: MTKView) {
        guard let device = view.device
        else {
            return nil
        }
        self.device = device
        
        guard let cmdQueue = device.makeCommandQueue()
        else {
            return nil
        }
        self.cmdQueue = cmdQueue
        
        super.init()
    }
}
