# LaunchPro 构建和安装指南

## ⚠️ 当前状态

**源代码开发：✅ 100% 完成**  
**DMG 打包：⏸️ 需要完整 Xcode**

您的系统当前只有 Xcode CommandLineTools，缺少完整的 Xcode，因此无法直接编译。

---

## 📋 方案一：安装完整 Xcode（推荐）

### 步骤 1: 安装 Xcode
1. 打开 Mac App Store
2. 搜索 "Xcode"
3. 点击"获取"并安装（约 12GB）
4. 安装完成后运行：
   ```bash
   sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
   ```

### 步骤 2: 构建项目
```bash
cd /Users/I573623/Desktop/Personal/Cursor_Development/38MacOS启动台Opencode版/LaunchPro

# 方法 A: 使用 Xcode GUI
open LaunchPro.xcodeproj
# 按 Cmd+B 构建
# 按 Cmd+R 运行

# 方法 B: 使用命令行
xcodebuild -project LaunchPro.xcodeproj -scheme LaunchPro -configuration Release archive

# 方法 C: 使用构建脚本
./build.sh
```

### 步骤 3: 获取 DMG
构建成功后，DMG 文件位置：
```
/Users/I573623/Desktop/Personal/Cursor_Development/38MacOS启动台Opencode版/LaunchPro/build/Distribution/LaunchPro.dmg
```

### 步骤 4: 安装应用
1. 双击 `LaunchPro.dmg`
2. 拖拽 LaunchPro 到 Applications 文件夹
3. 在启动台中找到并打开

---

## 📋 方案二：使用 Swift Package Manager（需要 Xcode）

```bash
cd LaunchPro
swift build -c release
# 可执行文件在 .build/release/LaunchPro
```

---

## 📋 方案三：在线构建服务

如果不想安装 Xcode，可以使用：
- **GitHub Actions**: 创建 workflow 自动构建
- **MacStadium**: 云 Mac 构建服务

---

## 🎯 当前项目文件

所有源代码已准备就绪，位于：
```
/Users/I573623/Desktop/Personal/Cursor_Development/38MacOS启动台Opencode版/LaunchPro/

├── LaunchPro/              # 主应用
│   ├── App/               # 应用入口
│   ├── Models/            # 数据模型
│   ├── Views/             # SwiftUI 视图
│   ├── ViewModels/        # 业务逻辑
│   ├── Services/          # 服务层
│   └── Resources/         # 资源文件
├── LaunchProTests/        # 单元测试
├── LaunchProUITests/      # UI 测试
├── README.md              # 项目说明
├── LICENSE                # MIT 许可证
├── Package.swift          # SPM 配置
└── build.sh               # 构建脚本
```

**文件统计**:
- Swift 文件：14 个
- 代码行数：~1200 行
- 测试用例：5 个

---

## 🔧 首次运行注意事项

安装后首次打开可能提示"无法验证开发者"：

1. 打开 **系统设置** > **隐私与安全性**
2. 滚动到底部，点击 **"仍要打开"**
3. 或者运行：
   ```bash
   xattr -d com.apple.quarantine /Applications/LaunchPro.app
   ```

---

## 📞 需要帮助？

如有问题，请检查：
1. Xcode 是否已正确安装
2. macOS 版本是否 >= 14.0
3. 是否选择了正确的开发目录

```bash
# 检查 Xcode 状态
xcode-select -p

# 应该输出：
# /Applications/Xcode.app/Contents/Developer
```
