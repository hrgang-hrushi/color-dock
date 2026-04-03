import SwiftUI
import AppKit

@MainActor
class ScreenPixelSampler: ObservableObject {
    @Published var color: Color = .clear
    @Published var hex: String = "#000000"
    @Published var isSampling = false
    
    private var monitor: Any?
    
    func startSampling() {
        isSampling = true
        NSCursor.crosshair.set()
        
        monitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown]) { [weak self] event in
            guard let self = self else { return }
            self.samplePixel(at: event.locationInWindow)
            self.stopSampling()
        }
        
        NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown]) { [weak self] event in
            guard let self = self else { return event }
            self.samplePixel(at: NSEvent.mouseLocation)
            self.stopSampling()
            return nil
        }
    }
    
    func stopSampling() {
        isSampling = false
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
        NSCursor.arrow.set()
    }
    
    private func samplePixel(at point: CGPoint) {
        let cgPoint = CGPoint(x: point.x, y: point.y)
        guard let image = CGDisplayCreateImage(CGMainDisplayID(), rect: CGRect(origin: cgPoint, size: CGSize(width: 1, height: 1))) else { return }
        guard let dataProvider = image.dataProvider, let data = dataProvider.data else { return }
        let ptr = CFDataGetBytePtr(data)
        let r = ptr![0]
        let g = ptr![1]
        let b = ptr![2]
        
        DispatchQueue.main.async { [weak self] in
            self?.color = Color(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
            self?.hex = String(format: "#%02X%02X%02X", r, g, b)
        }
    }
}

struct ContentView: View {
    @StateObject private var sampler = ScreenPixelSampler()
    @State private var showCopied = false
    
    private func copyHexToPasteboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(sampler.hex, forType: .string)
        
        showCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showCopied = false
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(sampler.color == .clear ? Color.gray.opacity(0.2) : sampler.color)
                .frame(height: 60)
                .overlay(
                    Text(sampler.color == .clear ? "Click eyedropper to pick" : sampler.hex)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(sampler.color == .clear ? .gray : .white.opacity(0.9))
                )
            
            Button(action: {
                if sampler.isSampling {
                    sampler.stopSampling()
                } else {
                    sampler.startSampling()
                }
            }) {
                Label(sampler.isSampling ? "Click anywhere..." : "Pick Color", systemImage: sampler.isSampling ? "cursorarrow.rays" : "eyedropper")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .tint(sampler.isSampling ? .orange : .blue)
            
            Button(action: copyHexToPasteboard) {
                Label(showCopied ? "Copied!" : "Copy Hex", systemImage: showCopied ? "checkmark" : "doc.on.doc")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .disabled(sampler.color == .clear)
        }
        .padding()
        .frame(width: 220)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}