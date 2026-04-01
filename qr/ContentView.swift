import SwiftUI
import AVFoundation

// MARK: - Главный экран
struct ContentView: View {
    @State private var scannedText = ""   // результат сканирования
    @State private var isScanning = false // показывается ли камера

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Подсказка или результат
            if scannedText.isEmpty {
                Text("Нажмите кнопку для сканирования")
                    .foregroundStyle(.secondary)
            } else {
                Text(scannedText)
                    .font(.title3)
                    .textSelection(.enabled)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }

            Spacer()

            // Кнопка запуска сканера
            Button {
                scannedText = ""
                isScanning = true
            } label: {
                Label("Сканировать QR", systemImage: "qrcode.viewfinder")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        // Полноэкранная камера поверх основного экрана
        .fullScreenCover(isPresented: $isScanning) {
            ScannerView { code in
                scannedText = code
                isScanning = false
            }
        }
    }
}

// MARK: - SwiftUI-обёртка над UIKit-контроллером камеры
struct ScannerView: UIViewControllerRepresentable {
    let onCodeFound: (String) -> Void

    func makeUIViewController(context: Context) -> ScannerVC {
        ScannerVC(onCodeFound: onCodeFound)
    }

    func updateUIViewController(_: ScannerVC, context: Context) {}
}

// MARK: - UIKit-контроллер: захват видео и распознавание QR
class ScannerVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    let onCodeFound: (String) -> Void
    private let session = AVCaptureSession()
    private var found = false // защита от повторного срабатывания

    init(onCodeFound: @escaping (String) -> Void) {
        self.onCodeFound = onCodeFound
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        // Подключаем камеру как источник видео
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { showError(); return }
        session.addInput(input)

        // Настраиваем распознавание метаданных (QR-кодов)
        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else { showError(); return }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.qr]

        // Превью камеры на весь экран
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.frame = view.bounds
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)

        // Кнопка закрытия (крестик в правом верхнем углу)
        let close = UIButton(type: .close)
        close.translatesAutoresizingMaskIntoConstraints = false
        close.addAction(UIAction { [weak self] _ in self?.dismiss(animated: true) }, for: .touchUpInside)
        view.addSubview(close)
        NSLayoutConstraint.activate([
            close.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            close.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        // Запускаем захват в фоне, чтобы не блокировать UI
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.stopRunning()
    }

    // Делегат AVCaptureMetadataOutput — вызывается при обнаружении QR-кода
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput objects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard !found,
              let obj = objects.first as? AVMetadataMachineReadableCodeObject,
              let value = obj.stringValue else { return }
        found = true
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate)) // вибрация
        dismiss(animated: true) { [weak self] in self?.onCodeFound(value) }
    }

    // Показываем ошибку, если камера недоступна (симулятор, нет разрешения)
    private func showError() {
        let label = UILabel()
        label.text = "Камера недоступна"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

#Preview { ContentView() }
