import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appController: AppController
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            TabView {
                appearanceSettings
                    .tabItem { 
                        Label("外观", systemImage: "paintbrush")
                    }
                
                behaviorSettings
                    .tabItem { 
                        Label("行为", systemImage: "slider.horizontal.3")
                    }
                
                aboutSettings
                    .tabItem { 
                        Label("关于", systemImage: "info.circle")
                    }
            }
            .padding(.top, 8)
        }
        .frame(width: 550, height: 450)
    }
    
    private var header: some View {
        VStack(spacing: 12) {
            // Show horse emoji/logo for 马年 theme, otherwise show rocket
            Group {
                if appController.currentTheme.name == "马年" {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "#FFD700"), Color(hex: "#FFA500")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 70)
                        
                        Text("🐎")
                            .font(.system(size: 40))
                    }
                    .shadow(color: Color(hex: "#FFD700").opacity(0.5), radius: 10)
                } else {
                    Image(systemName: "rocket.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color(hex: appController.currentTheme.accentColor))
                }
            }
            
            Text("LaunchPro")
                .font(.system(size: 24, weight: .bold))
            
            Text("版本 1.0.0")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: appController.currentTheme.backgroundColor).opacity(0.8),
                    Color(hex: appController.currentTheme.backgroundColor).opacity(0.4)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private var appearanceSettings: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("主题")
                        .font(.headline)
                    
                    // 主题网格 - 2行5列
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ThemeButton(
                            title: "默认",
                            color: Color(hex: "#007AFF"),
                            isSelected: appController.currentTheme.name == "默认"
                        ) {
                            appController.currentTheme = .default
                            appController.saveSettings()
                        }
                        
                        ThemeButton(
                            title: "马年",
                            color: Color(hex: "#C41E3A"),
                            isSelected: appController.currentTheme.name == "马年"
                        ) {
                            appController.currentTheme = .yearOfHorse
                            appController.saveSettings()
                        }
                        
                        ThemeButton(
                            title: "夜光",
                            color: Color(hex: "#1C1C1E"),
                            isSelected: appController.currentTheme.name == "夜光"
                        ) {
                            appController.currentTheme = .night
                            appController.saveSettings()
                        }
                        
                        ThemeButton(
                            title: "海洋",
                            color: Color(hex: "#0077B6"),
                            isSelected: appController.currentTheme.name == "海洋"
                        ) {
                            appController.currentTheme = .ocean
                            appController.saveSettings()
                        }
                        
                        ThemeButton(
                            title: "森林",
                            color: Color(hex: "#2D6A4F"),
                            isSelected: appController.currentTheme.name == "森林"
                        ) {
                            appController.currentTheme = .forest
                            appController.saveSettings()
                        }
                        
                        ThemeButton(
                            title: "落日",
                            color: Color(hex: "#FB8500"),
                            isSelected: appController.currentTheme.name == "落日"
                        ) {
                            appController.currentTheme = .sunset
                            appController.saveSettings()
                        }
                        
                        ThemeButton(
                            title: "紫罗兰",
                            color: Color(hex: "#7B2CBF"),
                            isSelected: appController.currentTheme.name == "紫罗兰"
                        ) {
                            appController.currentTheme = .violet
                            appController.saveSettings()
                        }
                        
                        ThemeButton(
                            title: "甜蜜",
                            color: Color(hex: "#FF69B4"),
                            isSelected: appController.currentTheme.name == "甜蜜"
                        ) {
                            appController.currentTheme = .pink
                            appController.saveSettings()
                        }
                        
                        ThemeButton(
                            title: "星际",
                            color: Color(hex: "#0B0B3B"),
                            isSelected: appController.currentTheme.name == "星际"
                        ) {
                            appController.currentTheme = .galaxy
                            appController.saveSettings()
                        }
                        
                        ThemeButton(
                            title: "巧克力",
                            color: Color(hex: "#3E2723"),
                            isSelected: appController.currentTheme.name == "巧克力"
                        ) {
                            appController.currentTheme = .chocolate
                            appController.saveSettings()
                        }
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("网格列数")
                            .font(.headline)
                        Spacer()
                        Text("\(appController.gridSize) 列")
                            .foregroundColor(.secondary)
                    }
                    
                    Picker("", selection: $appController.gridSize) {
                        ForEach(4...10, id: \.self) { size in
                            Text("\(size)").tag(size)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: appController.gridSize) { _, _ in
                        appController.saveSettings()
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("图标大小")
                            .font(.headline)
                        Spacer()
                        Text("\(Int(appController.iconSize)) px")
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $appController.iconSize, in: 40...120, step: 5)
                        .onChange(of: appController.iconSize) { _, _ in
                            appController.saveSettings()
                        }
                }
            }
            .padding(24)
        }
    }
    
    private var behaviorSettings: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("快捷键")
                        .font(.headline)
                    
                    ShortcutRow(
                        title: "打开/关闭启动台",
                        shortcut: "⌘ ⇧ 空格"
                    )
                    
                    ShortcutRow(
                        title: "隐藏窗口",
                        shortcut: "ESC"
                    )
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("启动选项")
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("开机自启动")
                            .font(.body)
                        Spacer()
                    }
                    .foregroundColor(.secondary)
                }
            }
            .padding(24)
        }
    }
    
    private var aboutSettings: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "rocket.fill")
                        .font(.system(size: 64))
                        .foregroundColor(Color(hex: appController.currentTheme.accentColor))
                    
                    Text("LaunchPro")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("版本 1.0.0 (Build 1)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(title: "开发者", value: "LaunchPro Team")
                    InfoRow(title: "版权", value: "© 2026 LaunchPro")
                    InfoRow(title: "许可证", value: "MIT License")
                }
                
                Divider()
                
                Text("感谢使用 LaunchPro！")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding(24)
        }
    }
}

struct ThemeButton: View {
    let title: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
                    .frame(width: 80, height: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.primary : Color.clear, lineWidth: 3)
                    )
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(isSelected ? .primary : .secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ShortcutRow: View {
    let title: String
    let shortcut: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
            Spacer()
            Text(shortcut)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(6)
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
