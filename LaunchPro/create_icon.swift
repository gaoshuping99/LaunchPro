import Foundation
import AppKit

func createIcon() -> NSImage {
    let size = NSSize(width: 512, height: 512)
    let image = NSImage(size: size)
    image.lockFocus()
    
    // 马年主题背景 - 中国红渐变
    let redColor = NSColor(red: 0.769, green: 0.118, blue: 0.227, alpha: 1.0)
    let gradient = NSGradient(starting: redColor, ending: NSColor(red: 0.5, green: 0.0, blue: 0.1, alpha: 1.0))
    gradient?.draw(in: NSRect(origin: .zero, size: size), angle: 135)
    
    // 金色边框
    let borderRect = NSRect(x: 20, y: 20, width: 472, height: 472).insetBy(dx: 10, dy: 10)
    let borderPath = NSBezierPath(roundedRect: borderRect, xRadius: 40, yRadius: 40)
    borderPath.lineWidth = 8
    NSColor(red: 1.0, green: 0.843, blue: 0.0, alpha: 1.0).setStroke()
    borderPath.stroke()
    
    // 马字书法（简化版 - 使用几何图形）
    let horsePath = NSBezierPath()
    horsePath.lineWidth = 25
    horsePath.lineCapStyle = .round
    
    // 马的简化图案
    horsePath.move(to: NSPoint(x: 180, y: 380))
    horsePath.line(to: NSPoint(x: 180, y: 180))
    horsePath.curve(to: NSPoint(x: 256, y: 120), controlPoint1: NSPoint(x: 180, y: 150), controlPoint2: NSPoint(x: 220, y: 120))
    horsePath.line(to: NSPoint(x: 356, y: 180))
    horsePath.line(to: NSPoint(x: 356, y: 380))
    
    NSColor(red: 1.0, green: 0.843, blue: 0.0, alpha: 1.0).setStroke()
    horsePath.stroke()
    
    // 顶部装饰
    let topPath = NSBezierPath()
    topPath.appendArc(withCenter: NSPoint(x: 256, y: 256), radius: 60, startAngle: 0, endAngle: 180)
    topPath.lineWidth = 15
    NSColor(red: 1.0, green: 0.843, blue: 0.0, alpha: 0.8).setStroke()
    topPath.stroke()
    
    image.unlockFocus()
    return image
}

let icon = createIcon()
let fileURL = URL(fileURLWithPath: "LaunchPro/LaunchPro/Resources/AppIcon.icns")

// 创建临时 PNG
let pngData = NSBitmapImageRep(data: icon.tiffRepresentation!)?.representation(using: .png, properties: [:])
try? pngData?.write(to: URL(fileURLWithPath: "icon_temp.png"))

print("图标创建完成")
