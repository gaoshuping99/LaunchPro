import Foundation
import AppKit

struct ApplicationInfo: Identifiable {
    let id = UUID()
    let name: String
    let bundleID: String
    let url: String
    let icon: NSImage?
}

/// 图标缓存管理器 - 性能优化
class IconCache {
    static let shared = IconCache()
    
    private var cache = NSCache<NSString, NSImage>()
    private let queue = DispatchQueue(label: "com.launchpro.iconcache", qos: .utility)
    
    private init() {
        // 设置缓存限制
        cache.countLimit = 500  // 最多缓存 500 个图标
        cache.totalCostLimit = 100 * 1024 * 1024  // 100MB
    }
    
    func getIcon(for path: String) -> NSImage? {
        let key = path as NSString
        
        // 快速路径：从缓存获取
        if let cached = cache.object(forKey: key) {
            return cached
        }
        
        // 异步加载
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let url = URL(fileURLWithPath: path)
            let icon = NSWorkspace.shared.icon(forFile: url.path)
            icon.size = NSSize(width: 128, height: 128)
            
            // 存入缓存
            self.cache.setObject(icon, forKey: key, cost: Int(icon.size.width * icon.size.height * 4))
        }
        
        // 返回默认图标
        return NSImage(systemSymbolName: "app.fill", accessibilityDescription: nil)
    }
    
    func preloadIcons(for paths: [String]) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            for path in paths {
                let url = URL(fileURLWithPath: path)
                let icon = NSWorkspace.shared.icon(forFile: url.path)
                icon.size = NSSize(width: 128, height: 128)
                self.cache.setObject(icon, forKey: path as NSString)
            }
        }
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}

class ApplicationScanner {
    static let shared = ApplicationScanner()
    
    private let applicationDirectories = [
        "/Applications",
        "/System/Applications",
        "/System/Library/CoreServices/Applications",
        "\(NSHomeDirectory())/Applications",
        "/System/Applications/Utilities"
    ]
    
    private let excludedBundleIDs: Set<String> = [
        "com.apple.loginwindow",
        "com.apple.WindowManager",
        "com.apple.SpeechRecognitionCore.speechrecognitiond",
        "com.apple.AccessControl",
        "com.apple.security.pkit"
    ]
    
    // 缓存扫描结果
    private var cachedApps: [ApplicationInfo] = []
    private var lastScanTime: Date?
    private let scanCacheInterval: TimeInterval = 300 // 5分钟缓存
    
    // 搜索索引 - 性能优化
    private var searchIndex: [String: [Int]] = [:]  // name -> indices
    
    func scan(completion: @escaping ([ApplicationInfo]) -> Void) {
        // 检查缓存是否有效
        if let lastScan = lastScanTime,
           Date().timeIntervalSince(lastScan) < scanCacheInterval,
           !cachedApps.isEmpty {
            DispatchQueue.main.async {
                completion(self.cachedApps)
            }
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            var apps: [ApplicationInfo] = []
            var seenBundleIDs = Set<String>()
            var appPaths: [String] = []
            
            for directory in self.applicationDirectories {
                let url = URL(fileURLWithPath: directory)
                guard let contents = try? FileManager.default.contentsOfDirectory(
                    at: url, 
                    includingPropertiesForKeys: [.isApplicationKey], 
                    options: [.skipsHiddenFiles, .skipsPackageDescendants]
                ) else { continue }
                
                for appURL in contents where appURL.pathExtension == "app" {
                    guard let bundle = Bundle(url: appURL),
                          let bundleID = bundle.bundleIdentifier,
                          !self.excludedBundleIDs.contains(bundleID),
                          !seenBundleIDs.contains(bundleID) else { continue }
                    
                    seenBundleIDs.insert(bundleID)
                    
                    let name = bundle.infoDictionary?["CFBundleDisplayName"] as? String
                              ?? bundle.infoDictionary?["CFBundleName"] as? String
                              ?? appURL.deletingPathExtension().lastPathComponent
                    
                    // 使用缓存获取图标
                    let icon = IconCache.shared.getIcon(for: appURL.path)
                    appPaths.append(appURL.path)
                    
                    apps.append(ApplicationInfo(name: name, bundleID: bundleID, url: appURL.absoluteString, icon: icon))
                }
            }
            
            // 排序
            apps.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            
            // 预加载图标
            IconCache.shared.preloadIcons(for: Array(appPaths.prefix(100)))
            
            // 更新缓存
            self.cachedApps = apps
            self.lastScanTime = Date()
            
            // 构建搜索索引
            self.buildSearchIndex(for: apps)
            
            DispatchQueue.main.async { completion(apps) }
        }
    }
    
    /// 构建搜索索引 - 大幅提升搜索速度
    private func buildSearchIndex(for apps: [ApplicationInfo]) {
        searchIndex.removeAll()
        
        for (index, app) in apps.enumerated() {
            // 索引名称的每个单词
            let words = app.name.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted)
            for word in words where word.count >= 2 {
                if searchIndex[word] == nil {
                    searchIndex[word] = []
                }
                searchIndex[word]?.append(index)
            }
            
            // 索引首字母
            if let firstChar = app.name.first {
                let key = String(firstChar).lowercased()
                if searchIndex[key] == nil {
                    searchIndex[key] = []
                }
                searchIndex[key]?.append(index)
            }
        }
    }
    
    /// 快速搜索 - 使用索引
    func fastSearch(query: String, in apps: [ApplicationInfo]) -> [ApplicationInfo] {
        guard !query.isEmpty else { return apps }
        
        let lowercasedQuery = query.lowercased()
        
        // 如果查询很短，使用索引
        if query.count <= 2 {
            var resultIndices = Set<Int>()
            
            // 搜索索引
            let words = lowercasedQuery.components(separatedBy: CharacterSet.alphanumerics.inverted)
            for word in words where word.count >= 2 {
                if let indices = searchIndex[word] {
                    resultIndices.formUnion(indices)
                }
            }
            
            if !resultIndices.isEmpty {
                return resultIndices.compactMap { index -> ApplicationInfo? in
                    guard index < apps.count else { return nil }
                    return apps[index]
                }
            }
        }
        
        // 后备：线性搜索
        return apps.filter { app in
            app.name.localizedCaseInsensitiveContains(lowercasedQuery)
        }
    }
    
    /// 强制刷新缓存
    func refreshCache() {
        cachedApps.removeAll()
        lastScanTime = nil
        searchIndex.removeAll()
    }
    
    func scanAppBundleNames() -> [String] {
        var names: [String] = []
        for directory in applicationDirectories {
            let url = URL(fileURLWithPath: directory)
            guard let contents = try? FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ) else { continue }

            for appURL in contents where appURL.pathExtension == "app" {
                names.append(appURL.deletingPathExtension().lastPathComponent)
            }
        }
        return names
    }
}
