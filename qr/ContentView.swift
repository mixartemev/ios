import SwiftUI

// MARK: - Главный экран
struct ContentView: View {
    @State private var scannedText = ""
    @State private var isScanning = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

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
        .fullScreenCover(isPresented: $isScanning) {
            ScannerView { code in
                scannedText = code
                isScanning = false
            }
        }
    }
}

#Preview { ContentView() }
