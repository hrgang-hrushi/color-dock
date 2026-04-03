import SwiftUI
import AppKit

struct ContentView: View {
    @State private var selectedColor: Color = .clear
    @State private var hexString: String = "#000000"
    @State private var showCopied = false
    
    private func activateEyedropper() {
        let sampler = NSColorSampler()
        sampler.show { nsColor in
            guard let nsColor = nsColor else { return }
            DispatchQueue.main.async {
                selectedColor = Color(nsColor)
                let r = lround(Double(nsColor.redComponent * 255))
                let g = lround(Double(nsColor.greenComponent * 255))
                let b = lround(Double(nsColor.blueComponent * 255))
                hexString = String(format: "#%02lX%02lX%02lX", r, g, b)
            }
        }
    }
    
    private func copyHexToPasteboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(hexString, forType: .string)
        
        showCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showCopied = false
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(selectedColor == .clear ? Color.gray.opacity(0.2) : selectedColor)
                .frame(height: 60)
                .overlay(
                    Text(selectedColor == .clear ? "Click eyedropper to pick" : hexString)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(selectedColor == .clear ? .gray : .white.opacity(0.9))
                )
            
            Button(action: activateEyedropper) {
                Label("Pick Color", systemImage: "eyedropper")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .tint(.blue)
            
            Button(action: copyHexToPasteboard) {
                Label(showCopied ? "Copied!" : "Copy Hex", systemImage: showCopied ? "checkmark" : "doc.on.doc")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .disabled(selectedColor == .clear)
        }
        .padding()
        .frame(width: 220)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}