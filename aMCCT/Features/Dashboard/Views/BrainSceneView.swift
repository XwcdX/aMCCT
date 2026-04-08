import SceneKit
import SwiftUI

struct TransparentSceneView: UIViewRepresentable {
    let scene: SCNScene
    let pointOfView: SCNNode?

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = scene
        view.pointOfView = pointOfView
        view.preferredFramesPerSecond = 30
        view.antialiasingMode = .multisampling2X
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true
        view.backgroundColor = .clear
        view.isOpaque = false
        view.layer.isOpaque = false
        view.rendersContinuously = false
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.pointOfView = pointOfView
    }
}

struct BrainSceneView: View {
    var brainLevel: Int

    @State private var scene = SCNScene()
    @State private var amccNodes: [SCNNode] = []
    @State private var brainRoot = SCNNode()
    @State private var isInitialized = false

    private let amccNodeNames: Set<String> = [
        "Allen_cingulate_gyrus_rostral_anterior_part_L",
        "Allen_cingulate_gyrus_rostral_anterior_part_R",
    ]

    private let cortexNodeNames: Set<String> = []

    var body: some View {
        TransparentSceneView(
            scene: scene,
            pointOfView: scene.rootNode.childNode(
                withName: "camera",
                recursively: false
            )
        )
        .onAppear {
            if !isInitialized {
                setupScene()
                isInitialized = true
            }
        }
        .onChange(of: brainLevel) { _, newValue in
            updateaMCC(level: newValue)
        }
    }

    private func setupScene() {
        scene.background.contents = UIColor.clear

        guard let brainScene = SCNScene(named: "3d-vh-m-allen-brain.usdz")
        else {
            print("Failed to load brain USDZ")
            return
        }

        for child in brainScene.rootNode.childNodes {
            brainRoot.addChildNode(child.clone())
        }
        scene.rootNode.addChildNode(brainRoot)

        let (minVec, maxVec) = brainRoot.boundingBox
        let currentHeight = maxVec.y - minVec.y
        let currentWidth = maxVec.x - minVec.x
        let currentDepth = maxVec.z - minVec.z
        let maxDimension = max(currentHeight, currentWidth, currentDepth)

        let targetSize: Float = 2.0
        let autoScale = targetSize / maxDimension
        brainRoot.scale = SCNVector3(autoScale, autoScale, autoScale)

        let centerX = (minVec.x + maxVec.x) / 2 * autoScale
        let centerY = (minVec.y + maxVec.y) / 2 * autoScale
        let centerZ = (minVec.z + maxVec.z) / 2 * autoScale
        brainRoot.position = SCNVector3(-centerX, -centerY, -centerZ)

        brainRoot.enumerateChildNodes { node, _ in
            guard let name = node.name else { return }

            if amccNodeNames.contains(name) {
                amccNodes.append(node)
                styleaMCC(node: node, level: brainLevel)
            } else if cortexNodeNames.contains(name) {
                node.geometry?.materials.forEach {
                    $0.diffuse.contents = UIColor.white.withAlphaComponent(9)
                    $0.emission.contents = UIColor.clear
                    $0.isDoubleSided = true
                    $0.blendMode = .alpha
                    $0.writesToDepthBuffer = false
                }
            } else {
                node.geometry?.materials.forEach {
                    $0.diffuse.contents = UIColor(white: 0, alpha: 2)
                    $0.emission.contents = UIColor.clear
                    $0.isDoubleSided = true
                    $0.blendMode = .alpha
                    $0.writesToDepthBuffer = false
                }
            }
        }

        let cameraNode = SCNNode()
        cameraNode.name = "camera"
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 4)
        cameraNode.camera?.wantsHDR = true
        cameraNode.camera?.zNear = 0.01
        cameraNode.camera?.zFar = 100
        cameraNode.camera?.fieldOfView = 45

        if let bloom = CIFilter(name: "CIBloom") {
            bloom.setValue(8.0, forKey: "inputRadius")
            bloom.setValue(0.8, forKey: "inputIntensity")
            cameraNode.filters = [bloom]
        }
        scene.rootNode.addChildNode(cameraNode)

        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light!.type = .ambient
        ambient.light!.intensity = 300
        scene.rootNode.addChildNode(ambient)

        let fill = SCNNode()
        fill.light = SCNLight()
        fill.light!.type = .directional
        fill.light!.intensity = 600
        fill.position = SCNVector3(2, 4, 4)
        scene.rootNode.addChildNode(fill)

        let rotate = SCNAction.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 20)
        brainRoot.runAction(.repeatForever(rotate))

        updateaMCC(level: brainLevel)
    }

    private func styleaMCC(node: SCNNode, level: Int) {
        let t01 = max(0.0, min(1.0, CGFloat(level) / 100.0))
        let t = max(t01, 0.4)
        let hue = 0.72 - (0.14 * t)
        let brightness = 0.5 + (0.5 * t)
        let color = UIColor(
            hue: hue,
            saturation: 0.9,
            brightness: brightness,
            alpha: 1.0
        )
        let glowAlpha = 0.2 + (0.5 * t)
        let glow = UIColor.cyan.withAlphaComponent(glowAlpha)

        node.geometry?.materials.forEach { mat in
            mat.diffuse.contents = color
            mat.emission.contents = glow
            mat.isDoubleSided = true
            mat.blendMode = .replace
            mat.writesToDepthBuffer = true
        }
    }

    private func updateaMCC(level: Int) {
        let t01 = max(0.0, min(1.0, Double(level) / 100.0))

        SCNTransaction.begin()
        SCNTransaction.animationDuration = 2
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(
            name: .easeInEaseOut
        )

        amccNodes.forEach { node in
            styleaMCC(node: node, level: level)
            let s = Float(1 + max(t01, 0) * 0)
            node.scale = SCNVector3(s, s, s)
        }

        SCNTransaction.commit()
    }
}

#Preview("Brain Scene") {
    BrainSceneView(brainLevel: 70)
}
