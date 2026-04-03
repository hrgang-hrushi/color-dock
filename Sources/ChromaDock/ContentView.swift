import SwiftUI
import AppKit

struct ContentView: View {
    @State private var selectedColor: Color = .blue
    
    private func copyHexToPasteboard() {
        let nsColor = NSColor(selectedColor)
        let hexString = String(format: "%02lX%02lX%02lX",
                               lround(Double(nsColor.redComponent * 255)),
                               lround(Double(nsColor.greenComponent * 255)),
                               lround(Double(nsColor.blueComponent * 255)))
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString("#\(hexString)", forType: .string)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ColorPicker("Select Color", selection: $selectedColor)
                .labelsHidden()
                .frame(width: 180)
            
            Button(action: copyHexToPasteboard) {
                Label("Copy Hex", systemImage: "doc.on.doc")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding()
        .frame(width: 200)
        .background(.thinMaterial)
        .cornerRadius(12)
    }
}