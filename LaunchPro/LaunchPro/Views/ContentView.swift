import SwiftUI
import CoreData
import AppKit

struct ContentView: View {
    @StateObject private var dataStore = DataStore.shared
    @EnvironmentObject private var appController: AppController
    
    @State private var expandedFolderID: String?
    @State private var draggedApp: AppItem?
    @State private var isShowingFolders = true
    
    // MARK: - 键盘导航状态
    @State private var selectedIndex: Int = 0
    @State private var isSelectionMode: Bool = false
    
    // 计算可见项目
    private var visibleItems: [AnyView] {
        var items: [AnyView] = []
        
        // 文件夹
        if expandedFolderID == nil && appController.searchQuery.isEmpty {
            for _ in dataStore.folders {
                items.append(AnyView(EmptyView()))
            }
        }
        
        // 应用
        for app in getVisibleApps() {
            items.append(AnyView(EmptyView()))
        }
        
        return items
    }
    
    var body: some View {
        ZStack {
            // Full-screen blur gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: appController.currentTheme.backgroundColor),
                    Color(hex: appController.currentTheme.backgroundColor).opacity(0.85),
                    Color(hex: appController.currentTheme.backgroundColor).opacity(0.7)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Blur overlay for depth effect
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.3)
        }
        .ignoresSafeArea()
        
        .frame(minWidth: 900, minHeight: 650)
        .overlay(
            VStack(spacing: 16) {
                searchField
                
                ScrollView {
                    VStack(spacing: 24) {
                        if let folderID = expandedFolderID,
                           let folder = dataStore.folders.first(where: { $0.id == folderID }) {
                            expandedFolderSection(folder)
                        }
                        
                        appGrid
                    }
                    .padding()
                }
                
                bottomToolbar
            }
            .padding()
        )
        .onAppear {
            setupKeyboardShortcuts()
            if dataStore.apps.isEmpty {
                dataStore.scanApplications()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .toggleLaunchProWindow)) { _ in
            appController.toggleWindowVisibility()
        }
    }
    
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("搜索应用...", text: $appController.searchQuery)
                .textFieldStyle(.plain)
                .font(.system(size: 16))
            
            if !appController.searchQuery.isEmpty {
                Button(action: { appController.searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(Color(hex: appController.currentTheme.accentColor).opacity(0.1))
        .cornerRadius(10)
    }
    
    private var appGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(expandedFolderID == nil ? "应用" : "其他应用")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(getVisibleApps().count + (expandedFolderID == nil && appController.searchQuery.isEmpty ? dataStore.folders.count : 0)) 个项目")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: appController.gridSize),
                alignment: .leading,
                spacing: 20
            ) {
                // Folders in grid
                if expandedFolderID == nil && appController.searchQuery.isEmpty {
                    ForEach(dataStore.folders) { folder in
                        FolderItemView(
                            folder: folder,
                            appCount: dataStore.getAppsInFolder(folder.id).count,
                            isExpanded: false,
                            onTap: { toggleFolder(folder) },
                            onDelete: { deleteFolder(folder) },
                            iconSize: appController.iconSize,
                            onRename: { newName in renameFolder(folder, newName: newName) }
                        )
                    }
                }
                
                // Then apps
                ForEach(getVisibleApps()) { app in
                    DraggableAppIconView(
                        app: app,
                        iconSize: appController.iconSize,
                        onDragStart: { draggedApp = $0 },
                        onDragEnd: { draggedApp = nil },
                        onLaunch: { launchApp($0) },
                        onDrop: { targetApp in
                            if let droppedApp = draggedApp, droppedApp.id != targetApp.id {
                                createFolderFromApps(droppedApp: droppedApp, targetApp: targetApp)
                            }
                        },
                        onRemoveFromFolder: nil
                    )
                }
            }
        }
    }
    
    private func expandedFolderSection(_ folder: FolderItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button(action: { expandedFolderID = nil }) {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.plain)
                
                Text(folder.name)
                    .font(.headline)
                
                Spacer()
                
                Text("\(dataStore.getAppsInFolder(folder.id).count) 个应用")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: appController.gridSize),
                alignment: .leading,
                spacing: 20
            ) {
                ForEach(dataStore.getAppsInFolder(folder.id)) { app in
                    DraggableAppIconView(
                        app: app,
                        iconSize: appController.iconSize,
                        onDragStart: { draggedApp = $0 },
                        onDragEnd: { draggedApp = nil },
                        onLaunch: { launchApp($0) },
                        onDrop: { targetApp in
                            if let droppedApp = draggedApp, droppedApp.id != targetApp.id {
                                createFolderFromApps(droppedApp: droppedApp, targetApp: targetApp)
                            }
                        },
                        onRemoveFromFolder: {
                            dataStore.removeAppFromFolder(app)
                        }
                    )
                }
            }
        }
        .padding()
        .background(Color(hex: appController.currentTheme.accentColor).opacity(0.05))
        .cornerRadius(12)
    }
    
    private var bottomToolbar: some View {
        HStack {
            // 键盘导航提示
            keyboardHint
            
            Spacer()
            
            Button(action: { dataStore.scanApplications() }) {
                Label("刷新", systemImage: "arrow.clockwise")
            }
            
            Spacer()
            
            // 选择模式指示器
            if isSelectionMode {
                Text("选择模式")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.2))
                    .cornerRadius(4)
            }
            
            Spacer()
            
            Button(action: { NSApp.terminate(nil) }) {
                Label("退出", systemImage: "xmark.circle.fill")
            }
        }
        .padding(.horizontal)
    }
    
    private func getVisibleApps() -> [AppItem] {
        if !appController.searchQuery.isEmpty {
            return dataStore.apps.filter { app in
                app.name.localizedCaseInsensitiveContains(appController.searchQuery)
            }
        }
        
        if expandedFolderID != nil {
            return []
        }
        
        // Filter out apps that are already in folders
        return dataStore.apps.filter { app in
            !app.isHidden && app.groupID == nil
        }
    }
    
    private func toggleFolder(_ folder: FolderItem) {
        if expandedFolderID == folder.id {
            expandedFolderID = nil
        } else {
            expandedFolderID = folder.id
        }
    }
    
    private func deleteFolder(_ folder: FolderItem) {
        dataStore.folders.removeAll { $0.id == folder.id }
        if expandedFolderID == folder.id {
            expandedFolderID = nil
        }
    }
    
    private func renameFolder(_ folder: FolderItem, newName: String) {
        if let index = dataStore.folders.firstIndex(where: { $0.id == folder.id }) {
            dataStore.folders[index].name = newName
        }
    }
    
    private func createFolderFromApps(droppedApp: AppItem, targetApp: AppItem) {
        let folderName = "\(droppedApp.name) 和 \(targetApp.name)"
        let folder = FolderItem(id: UUID().uuidString, name: folderName, order: dataStore.folders.count)
        dataStore.folders.append(folder)
        
        dataStore.addAppToFolder(droppedApp, folderID: folder.id)
        dataStore.addAppToFolder(targetApp, folderID: folder.id)
    }
    
    private func launchApp(_ app: AppItem) {
        guard let url = URL(string: app.url) else { return }
        NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
    }
    
    private func setupKeyboardShortcuts() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains(.command), event.keyCode == 87 {
                appController.toggleWindowVisibility()
                return nil
            }
            
            // 键盘导航
            if isSelectionMode {
                switch event.keyCode {
                case 123: // 左
                    moveSelection(by: -1)
                    return nil
                case 124: // 右
                    moveSelection(by: 1)
                    return nil
                case 125: // 下
                    moveSelection(by: appController.gridSize)
                    return nil
                case 126: // 上
                    moveSelection(by: -appController.gridSize)
                    return nil
                case 36: // Enter - 启动应用
                    launchSelectedApp()
                    return nil
                case 53: // ESC - 退出选择模式
                    isSelectionMode = false
                    selectedIndex = 0
                    return nil
                default:
                    break
                }
            }
            
            // 按任意字母键进入选择模式
            if event.keyCode >= 0 && event.keyCode <= 56 {
                if !appController.searchQuery.isEmpty {
                    isSelectionMode = true
                }
            }
            
            return event
        }
    }
    
    // MARK: - 键盘导航功能
    private func moveSelection(by offset: Int) {
        let totalItems = getVisibleApps().count + (expandedFolderID == nil && appController.searchQuery.isEmpty ? dataStore.folders.count : 0)
        guard totalItems > 0 else { return }
        
        let newIndex = selectedIndex + offset
        if newIndex >= 0 && newIndex < totalItems {
            withAnimation(.easeInOut(duration: 0.1)) {
                selectedIndex = newIndex
            }
        }
    }
    
    private func launchSelectedApp() {
        let apps = getVisibleApps()
        let folderCount = expandedFolderID == nil && appController.searchQuery.isEmpty ? dataStore.folders.count : 0
        
        if selectedIndex < folderCount {
            // 选中的是文件夹
            let folder = dataStore.folders[selectedIndex]
            expandedFolderID = folder.id
        } else {
            // 选中的是应用
            let appIndex = selectedIndex - folderCount
            if appIndex < apps.count {
                launchApp(apps[appIndex])
            }
        }
    }
    
    private var keyboardHint: some View {
        HStack(spacing: 16) {
            Label("↑↓←→ 导航", systemImage: "arrow.keys")
            Label("Enter 启动", systemImage: "return")
            Label("ESC 退出", systemImage: "escape")
        }
        .font(.caption)
        .foregroundColor(.secondary)
    }
}

// MARK: - Folder Item View with LaunchOS-style app icons
struct FolderItemView: View {
    let folder: FolderItem
    let appCount: Int
    let isExpanded: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    let iconSize: CGFloat
    let onRename: (String) -> Void  // 修改为非可选
    
    @State private var isHovering = false
    @State private var isEditing = false  // 编辑模式
    @State private var editedName: String = ""
    
    // Get apps in this folder
    private var folderApps: [AppItem] {
        DataStore.shared.apps.filter { folder.appIDs.contains($0.id) }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // LaunchOS-style folder with app icons - 使用动态大小
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: iconSize, height: iconSize)  // 使用动态 iconSize
                
                // Show up to 4 app icons in a grid (like LaunchOS)
                if folderApps.isEmpty {
                    Image(systemName: "folder.fill")
                        .font(.system(size: iconSize * 0.35))
                        .foregroundColor(.accentColor)
                } else {
                    let gridSize = iconSize * 0.25
                    LazyVGrid(columns: [GridItem(.fixed(gridSize)), GridItem(.fixed(gridSize))], spacing: 2) {
                        ForEach(Array(folderApps.prefix(4))) { app in
                            if let icon = app.icon {
                                Image(nsImage: icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: gridSize - 2, height: gridSize - 2)
                                    .cornerRadius(3)
                            } else {
                                Image(systemName: "app.fill")
                                    .font(.system(size: gridSize * 0.7))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.accentColor.opacity(isHovering ? 0.5 : 0.2), lineWidth: isHovering ? 2 : 1)
            )
            .scaleEffect(isHovering ? 1.05 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isHovering)
            .onHover { hovering in
                isHovering = hovering
            }
            .onTapGesture(count: 2) {
                editedName = folder.name
                isEditing = true
            }
            .onTapGesture {
                onTap()
            }
            
            // 文件夹名称
            if isEditing {
                TextField("文件夹名", text: $editedName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.caption)
                    .frame(width: iconSize)
                    .multilineTextAlignment(.center)
                    .onSubmit {
                        if !editedName.isEmpty && editedName != folder.name {
                            onRename(editedName)
                        }
                        isEditing = false
                    }
            } else {
                Text(folder.name)
                    .font(.caption)
                    .lineLimit(1)
                    .frame(width: iconSize)
            }
        }
        .contextMenu {
            Button(action: { onTap() }) {
                Label("打开", systemImage: "folder")
            }
            Button(action: {
                editedName = folder.name
                isEditing = true
            }) {
                Label("重命名", systemImage: "pencil")
            }
            Divider()
            Button(role: .destructive, action: onDelete) {
                Label("删除文件夹", systemImage: "trash")
            }
        }
    }
}

// MARK: - Draggable App Icon View
struct DraggableAppIconView: View {
    let app: AppItem
    let iconSize: CGFloat
    let onDragStart: (AppItem) -> Void
    let onDragEnd: () -> Void
    let onLaunch: (AppItem) -> Void
    let onDrop: ((AppItem) -> Void)?
    let onRemoveFromFolder: (() -> Void)?
    let isSelected: Bool = false  // 新增：键盘选择状态
    
    @State private var isHovering = false
    @State private var isDropTarget = false
    
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
                        .stroke(Color.accentColor, lineWidth: 2)
                        .frame(width: iconSize + 4, height: iconSize + 4)
                }
                
                if isDropTarget {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.accentColor.opacity(0.3))
                        .frame(width: iconSize + 8, height: iconSize + 8)
                }
            }
            .scaleEffect(isHovering ? 1.05 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isHovering)
            
            Text(app.name)
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
        .onTapGesture(count: 2) {
            onLaunch(app)
        }
        .onDrag {
            onDragStart(app)
            return NSItemProvider(object: app.bundleID as NSString)
        }
        .onDrop(of: [.text], isTargeted: $isDropTarget) { providers in
            // 处理拖拽进入 - 创建文件夹或添加应用
            if let onDrop = onDrop {
                onDrop(app)
            }
            return true
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 1)
                .onEnded { value in
                    // 拖拽结束时处理
                    onDragEnd()
                }
        )
        .contextMenu {
            Button(action: { onLaunch(app) }) {
                Label("打开", systemImage: "play.fill")
            }
            Divider()
            Button(action: { revealInFinder() }) {
                Label("在 Finder 中显示", systemImage: "folder")
            }
            if let onRemoveFromFolder = onRemoveFromFolder {
                Button(action: onRemoveFromFolder) {
                    Label("移出文件夹", systemImage: "folder.badge.minus")
                }
                Divider()
            }
            Button(action: { hideApp() }) {
                Label("隐藏", systemImage: "eye.slash")
            }
        }
    }
    
    private func revealInFinder() {
        guard let url = URL(string: app.url) else { return }
        NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: url.deletingLastPathComponent().path)
    }
    
    private func hideApp() {
        DataStore.shared.hideApp(app)
    }
}
