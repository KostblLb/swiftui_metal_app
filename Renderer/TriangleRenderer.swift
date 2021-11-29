//
//  Renderer.swift
//  ModelViewer
//
//  Created by Konstantin Vysotski on 31.10.2021.
//

import Foundation
import MetalKit
import simd



class TriangleRenderer: NSObject, MTKViewDelegate {
    var device: MTLDevice
    var cmdQueue: MTLCommandQueue
    var pipelineState: MTLRenderPipelineState
    var viewportSize: vector_float2 = vector_float2()
    
    var rotation: matrix_float2x2 = matrix_float2x2(diagonal: vector_float2(1,1))
    
    private static var TriangleVertices: [vector_float2] = [
        vector_float2(250,  -250),
        vector_float2( -250,  -250),
        vector_float2(    0,   250)
    ]
    
    
    private var TrianglePositions: [Vertex] = [
        Vertex( position: TriangleVertices[0], color: vector_float4( 1, 0, 0, 1 ) ),
        Vertex( position: TriangleVertices[1], color: vector_float4( 0, 1, 0, 1 ) ),
        Vertex( position: TriangleVertices[2], color: vector_float4( 0, 0, 1, 1 ) ),
    ]
    
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Save the size of the drawable to pass to the vertex shader.
        viewportSize.x = Float(size.width);
        viewportSize.y = Float(size.height);
    }
    
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
        
        // Load all the shader files with a .metal file extension in the project.
        let defaultLibrary = device.makeDefaultLibrary()

        let vertexFunction = defaultLibrary?.makeFunction(name: "vertexShader")
        let fragmentFunction = defaultLibrary?.makeFunction(name: "fragmentShader")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.label = "Simple Pipeline";
        pipelineStateDescriptor.vertexFunction = vertexFunction;
        pipelineStateDescriptor.fragmentFunction = fragmentFunction;
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat;
        
        do {
            try pipelineState = device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch {
            // Pipeline State creation could fail if the pipeline descriptor isn't set up properly.
            //  If the Metal API validation is enabled, you can find out more information about what
            //  went wrong.  (Metal API validation is enabled by default when a debug build is run
            //  from Xcode.)
                
            NSLog("Failed to create pipeline state: \(error.localizedDescription)");
            return nil
        }

        super.init()
    }
    
    func draw(in view: MTKView) {
        // The render pass descriptor references the texture into which Metal should draw
        guard let renderPassDescriptor = view.currentRenderPassDescriptor
        else {
            return;
        }

        let commandBuffer = cmdQueue.makeCommandBuffer()
        commandBuffer?.label = "MyCommand"
        
        // Create a render pass and immediately end encoding, causing the drawable to be cleared
        guard let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        else {
            return
        }
        
        commandEncoder.label = "MyEncoder"
        commandEncoder.setViewport(MTLViewport(
            originX: 0,
            originY: 0,
            width: Double(viewportSize.x),
            height: Double(viewportSize.y),
            znear: 0, zfar: 1)
        )
        commandEncoder.setRenderPipelineState(pipelineState)
        
        // Pass in the parameter data.
        commandEncoder.setVertexBytes(
            TrianglePositions,
            length: TrianglePositions.count * MemoryLayout<Vertex>.size,
            index: Int(VertexInputIndexVertices.rawValue))

        commandEncoder.setVertexBytes(&viewportSize, length: MemoryLayout<vector_float2>.size, index: Int(VertexInputIndexViewportSize.rawValue))

        // Draw the triangle.
        commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        
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
    
    var t = 0.0;
    func update(_ deltaTime: UInt64) {
        t += 0.0000000001 * Double(deltaTime);
        rotation[0, 0] = Float(cos(t));
        rotation[1, 1] = Float(cos(t));
        rotation[1, 0] = Float(sin(t));
        rotation[0, 1] = Float(sin(t));
        
        TrianglePositions[0].position = rotation * TriangleRenderer.TriangleVertices[0];
        TrianglePositions[1].position = rotation * TriangleRenderer.TriangleVertices[1];
        TrianglePositions[2].position = rotation * TriangleRenderer.TriangleVertices[2];
    }
}
