import Foundation
import SwiftUI
import Combine

class AppController: ObservableObject {
    static let shared = AppController()
    
    @Published var isWindowVisible = false
    @Published var currentTheme: AppTheme = .default
    @Published var iconSize: CGFloat = 80
    @Published var gridSize: Int = 6
    @Published var searchQuery = ""
    @Published var hotkeyModifiers: UInt = 2048
    @Published var hotkeyCode: UInt = 49
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadSettings()
    }
    
    func initializeData(context: NSManagedObjectContext) {
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: "hasLaunchedBefore") {
            scanApplications(context: context)
            defaults.set(true, forKey: "hasLaunchedBefore")
        }
    }
    
    func scanApplications(context: NSManagedObjectContext) {
        let scanner = ApplicationScanner.shared
        scanner.scan { apps in
            DispatchQueue.main.async {
                context.perform {
                    for app in apps {
                        let entity = AppEntity(context: context)
                        entity.id = app.bundleID
                        entity.name = app.name
                        entity.bundleID = app.bundleID
                        entity.url = app.url
                        entity.order = Int32(apps.firstIndex(where: { $0.bundleID == app.bundleID }) ?? 0)
                        entity.isHidden = false
                    }
                    try? context.save()
                }
            }
        }
    }
    
    func loadSettings() {
        let defaults = UserDefaults.standard
        iconSize = defaults.double(forKey: "iconSize") > 0 ? defaults.double(forKey: "iconSize") : 80
        gridSize = defaults.integer(forKey: "gridSize") > 0 ? defaults.integer(forKey: "gridSize") : 6
        if let themeData = defaults.data(forKey: "currentTheme"),
           let theme = try? JSONDecoder().decode(AppTheme.self, from: themeData) {
            currentTheme = theme
        }
    }
    
    func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(iconSize, forKey: "iconSize")
        defaults.set(gridSize, forKey: "gridSize")
        if let themeData = try? JSONEncoder().encode(currentTheme) {
            defaults.set(themeData, forKey: "currentTheme")
        }
    }
    
    func toggleWindowVisibility() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isWindowVisible.toggle()
        }
    }
}

struct AppTheme: Codable, Equatable {
    var name: String
    var backgroundColor: String
    var accentColor: String
    var isDark: Bool
    
    // MARK: - 预设主题
    
    /// 默认蓝色主题
    static let `default` = AppTheme(name: "默认", backgroundColor: "#FFFFFF", accentColor: "#007AFF", isDark: false)
    
    /// 马年主题 - 中国红 + 金色
    static let yearOfHorse = AppTheme(name: "马年", backgroundColor: "#C41E3A", accentColor: "#FFD700", isDark: false)
    
    /// 夜光主题 - 深色背景
    static let night = AppTheme(name: "夜光", backgroundColor: "#1C1C1E", accentColor: "#0A84FF", isDark: true)
    
    /// 海洋主题 - 蓝色渐变
    static let ocean = AppTheme(name: "海洋", backgroundColor: "#0077B6", accentColor: "#90E0EF", isDark: false)
    
    /// 森林主题 - 绿色系
    static let forest = AppTheme(name: "森林", backgroundColor: "#2D6A4F", accentColor: "#95D5B2", isDark: false)
    
    ///  sunset 落日主题 - 橙红色
    static let sunset = AppTheme(name: "落日", backgroundColor: "#FB8500", accentColor: "#FFB703", isDark: false)
    
    /// 紫罗兰主题 - 紫色系
    static let violet = AppTheme(name: "紫罗兰", backgroundColor: "#7B2CBF", accentColor: "#E0AAFF", isDark: false)
    
    /// 粉红主题 - 甜美粉色
    static let pink = AppTheme(name: "甜蜜", backgroundColor: "#FF69B4", accentColor: "#FFC0CB", isDark: false)
    
    /// 星际主题 - 深空蓝
    static let galaxy = AppTheme(name: "星际", backgroundColor: "#0B0B3B", accentColor: "#00D4FF", isDark: true)
    
    /// 巧克力主题 - 棕色系
    static let chocolate = AppTheme(name: "巧克力", backgroundColor: "#3E2723", accentColor: "#D7CCC8", isDark: true)
    
    /// 所有预设主题列表
    static let allThemes: [AppTheme] = [
        .default,
        .yearOfHorse,
        .night,
        .ocean,
        .forest,
        .sunset,
        .violet,
        .pink,
        .galaxy,
        .chocolate
    ]
}
