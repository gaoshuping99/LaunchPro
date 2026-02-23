import SwiftUI
import AppKit

struct AppIconView: View {
    let app: AppEntity
    let iconSize: CGFloat
    @State private var isHovering = false
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                if let icon = app.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconSize, height: iconSize)
                        .shadow(color: .black.opacity(isHovering ? 0.3 : 0.1), radius: isHovering ? 8 : 4)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: iconSize, height: iconSize)
                        .overlay(
                            Image(systemName: "app.dashed")
                                .font(.system(size: iconSize * 0.5))
                                .foregroundColor(.gray)
                        )
                }
                if isHovering {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue, lineWidth: 2)
                        .frame(width: iconSize + 4, height: iconSize + 4)
                }
            }
            .scaleEffect(isHovering ? 1.05 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isHovering)
            
            Text(app.name ?? "Unknown")
                .font(.system(size: 12, weight: .medium))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: iconSize)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
        .onHover { hovering in
            withAnimation {
                isHovering = hovering
            }
        }
        .contextMenu {
            Button(action: { launchApp() }) {
                Label("打开", systemImage: "play.fill")
            }
            Divider()
            Button(action: { revealInFinder() }) {
                Label("在 Finder 中显示", systemImage: "folder")
            }
            Divider()
            Button(action: { hideApp() }) {
                Label("隐藏", systemImage: "eye.slash")
            }
        }
    }
    
    private func launchApp() {
        guard let urlString = app.url, let url = URL(string: urlString) else { return }
        NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
    }
    
    private func revealInFinder() {
        guard let urlString = app.url, let url = URL(string: urlString) else { return }
        NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: url.deletingLastPathComponent().path)
    }
    
    private func hideApp() {
        app.isHidden = true
        try? app.managedObjectContext?.save()
    }
}
