import UIKit
import VisionKit
import Vision

class MainVC: UIViewController, DataScannerViewControllerDelegate {
    private let resultLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        resultLabel.text = "Нажмите кнопку для сканирования"
        resultLabel.numberOfLines = 0
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultLabel)

        let button = UIButton(primaryAction: UIAction(title: "Сканировать QR") { [weak self] _ in self?.startScan() })
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        NSLayoutConstraint.activate([
            resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resultLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            resultLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -40),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
        ])
    }

    private func startScan() {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.qr])],
            isHighlightingEnabled: true
        )
        scanner.delegate = self
        present(scanner, animated: true) {
            try? scanner.startScanning()
        }
    }

    func dataScanner(_ scanner: DataScannerViewController,
                     didAdd items: [RecognizedItem], allItems: [RecognizedItem]) {
        guard case .barcode(let barcode) = items.first,
              let value = barcode.payloadStringValue else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        scanner.stopScanning()
        scanner.dismiss(animated: true) { [self] in
            resultLabel.text = value
        }
    }
}

#Preview { MainVC() }
