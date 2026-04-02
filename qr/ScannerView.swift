import SwiftUI
import VisionKit
import Vision        // VNBarcodeSymbology.qr

struct ScannerView: UIViewControllerRepresentable {
    let onCodeFound: (String) -> Void
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [VNBarcodeSymbology.qr])],
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        try? scanner.startScanning()
        return scanner
    }
    
    func updateUIViewController(_: DataScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator { Coordinator(onCodeFound: onCodeFound) }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onCodeFound: (String) -> Void
        
        init(onCodeFound: @escaping (String) -> Void) {
            self.onCodeFound = onCodeFound
        }
        
        // Автоматически срабатывает при обнаружении QR-кода
        func dataScanner(_ scanner: DataScannerViewController, didAdd items: [RecognizedItem], allItems: [RecognizedItem]) {
            guard case .barcode(let barcode) = items.first,
                  let value = barcode.payloadStringValue else { return }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            scanner.stopScanning()
            onCodeFound(value)
        }
    }
}
