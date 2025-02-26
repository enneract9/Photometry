import SceneKit
import UniformTypeIdentifiers

@MainActor
class PreviewGenerator {
    enum PreviewGeneratorError: Error {
        case unsupportedFileExtension
    }
    
    static var supportedFileExtensions: [UTType] {
        [.usdz]
    }
    
    /// Возвращает превью для .usdz файла
    static func getPreviewImage(from url: URL) async throws -> UIImage? {
        guard let type = UTType(url.pathExtension),
            supportedFileExtensions.contains(where: { $0 == type })
        else {
            throw PreviewGeneratorError.unsupportedFileExtension
        }
        
        let imagePath = url
            .deletingPathExtension()
            .appendingPathExtension("png")
            .path()
        
        guard FileManager.default.fileExists(atPath: imagePath) else {
            let image = try await generatePreviewImage(from: url)
            
            FileManager.default.createFile(atPath: imagePath, contents: image?.pngData())
            
            return image
        }
        guard let data = FileManager.default.contents(atPath: imagePath) else {
            return nil
        }
        
        return UIImage(data: data)
    }
    
    /// Создает превью для .usdz файла
    static func generatePreviewImage(from url: URL) async throws ->  UIImage? {
        guard let type = UTType(url.pathExtension),
            supportedFileExtensions.contains(where: { $0 == type })
        else {
            throw PreviewGeneratorError.unsupportedFileExtension
        }
        
        guard let scene = try? SCNScene(url: url) else {
            return nil
        }
        
        let sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        sceneView.scene = scene
        sceneView.backgroundColor = UIColor.clear
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .ambient
        scene.rootNode.addChildNode(lightNode)
        
//        let cameraNode = SCNNode()
//        cameraNode.camera = SCNCamera()
//        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
//        scene.rootNode.addChildNode(cameraNode)
        
        return sceneView.snapshot()

    }
}
