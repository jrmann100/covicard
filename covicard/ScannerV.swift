// With credit to https://github.com/appcoda/QRCodeReader

import AVFoundation
import SwiftUI
import UIKit

class ScannerC: UIViewController {
    var captureSession = AVCaptureSession()
    var videoL: AVCaptureVideoPreviewLayer?
    @Binding var barcode: String?
    
    init(barcode: Binding<String?>) {
        self._barcode = barcode
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: fallback for permissions denied error.
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get the camera device.")
            return
        }
        
        enum FocusError: Error {
            case runtimeError(String)
        }
        
        do {
            try captureDevice.lockForConfiguration()
            if captureDevice.isFocusModeSupported(.continuousAutoFocus) {
                captureDevice.focusMode = .continuousAutoFocus
            } else if captureDevice.isFocusModeSupported(.autoFocus) {
                captureDevice.focusMode = .autoFocus
            }
            
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch {
            print(error)
            return
        }
        
        videoL = AVCaptureVideoPreviewLayer(session: captureSession)
        videoL?.videoGravity = .resizeAspectFill
        videoL?.frame = view.layer.bounds
        view.layer.addSublayer(videoL!)
        
        captureSession.startRunning()
    }
}

extension ScannerC: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard metadataObjects.count != 0 else { return }
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        barcode = metadataObj.stringValue!
    }
}

struct ScannerV: UIViewControllerRepresentable {
    let barcode: Binding<String?>
    func makeUIViewController(context: Context) -> ScannerC {
        return ScannerC(barcode: barcode)
    }

    func updateUIViewController(_ uiViewController: ScannerC, context: Context) {}
}
