# Draft: launchOS 复刻版 - 专业启动台应用

## 项目概述
复刻并增强 macOS Launchpad 替代品，设计更专业漂亮的界面，添加马年特殊标识

## 市场研究 - 现有竞品

### 1. LaunchNext (最热门)
- **GitHub**: https://github.com/RoversX/LaunchNext
- **Stars**: 2.2k+ | **Forks**: 112
- **技术栈**: Swift 95.9%, Python 4.1%
- **许可证**: GPL-3.0
- **核心功能**:
  - ✅ 一键导入原生 Launchpad 布局（读取 SQLite 数据库）
  - ✅ 经典 Launchpad 体验
  - ✅ 多语言支持（12 种语言）
  - ✅ 隐藏图标标签
  - ✅ 自定义图标大小
  - ✅ 智能文件夹管理
  - ✅ 即时搜索和键盘导航
  - ✅ 窗口模式/全屏模式切换
- **界面特点**:
  - 圆润边角窗口
  - 毛玻璃效果
  - 设置面板（齿轮图标）
  - 支持多显示器
- **数据存储**: `~/Library/Application Support/LaunchNext/Data.store`
- **原生集成**: 读取 `/private$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db`

### 2. LaunchBack (Liquid Glass 风格)
- **GitHub**: https://github.com/trey-a-12/LaunchBack
- **Stars**: 229 | **Forks**: 10
- **技术栈**: Swift 100%
- **许可证**: 开源免费
- **核心功能**:
  - ✅ 经典 Launchpad 完整复刻
  - ✅ 独立于 Spotlight 和 Launchpad 代码
  - ✅ 手动排序（v1.1.0）
  - ✅ 字母排序切换
  - ✅ 系统级应用扫描
- **界面特点**:
  - Liquid Glass（液体玻璃）设计风格
  - 全屏网格布局
  - 平滑滚动
- **计划功能**:
  - 文件夹支持
  - 右键菜单（Finder 中显示）
  - 自定义热键
  - 网格大小定制
  - Sparkle 自动更新
  - Homebrew 支持

### 3. Launchy (Floaty 模式)
- **官网**: https://launchy.space/
- **GitHub**: https://github.com/Punshnut/macos-launchy
- **Stars**: 39 | **Forks**: 2
- **技术栈**: Swift
- **许可证**: MIT
- **核心功能**:
  - ✅ 全屏模式（经典 Launchpad 感觉）
  - ✅ Floaty 模式（HUD 悬浮窗）
  - ✅ 即时搜索（双语匹配、模糊搜索）
  - ✅ 热角触发
  - ✅ 全局快捷键
  - ✅ 右键菜单（重命名、隐藏、移动、文件夹）
  - ✅ 自动更新
  - ✅ 无障碍支持
- **界面特点**:
  - 7×5 页面网格
  - 缓存图标
  - 可选 ~/Applications 扫描
  - 文件夹嵌套
  - 模糊/透明/纯色背景
  - 自定义调色板
  - 支持壁纸
- **多语言**: 18 种语言支持

### 4. 其他项目
- **launchpick**: 原生 macOS 应用启动器 + 窗口切换器
- **better-launchpad**: 更快的搜索
- **MultiLauncher-for-macOS**: 极简主义启动器
- **kristof12345/Launchpad**: 现代化增强功能
- **lancelot**: SwiftUI 编写

## 技术实现模式

### 数据存储方案
1. **SQLite 数据库**（LaunchNext）
   - 路径：`~/Library/Application Support/{AppName}/Data.store`
   - 读取原生 Launchpad: `/private$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db`

2. **应用扫描**
   - 系统级：`/Applications`
   - 用户级：`~/Applications`
   - 缓存图标到本地

### 界面实现
1. **SwiftUI**（现代方案）
   - 多显示器支持
   - 自动布局
   - 动画效果

2. **AppKit + SwiftUI 混合**
   - 更好的 macOS 集成
   - 窗口管理
   - 热键监听

3. **核心功能模块**:
   - 应用扫描器（后台非阻塞）
   - 图标缓存（智能缓存策略）
   - 网格布局（LazyVGrid）
   - 搜索过滤（模糊匹配）
   - 文件夹管理（拖拽创建）
   - 热键监听（MASHotKey 或自定义）
   - 设置面板

### 图标设计规范（WWDC25）
1. **Icon Composer 工具**
   - 多层导出
   - 实时玻璃效果
   - 跨平台预览
   - 深色/浅色模式

2. **macOS 图标尺寸**
   - 1024x1024（基础）
   - 512x512, 256x256, 128x128, 64x64, 32x32, 16x16
   - 圆角矩形模板

3. **SF Symbols 7**
   - 6900+ 符号
   - 9 种字重
   - 3 种缩放
   - Draw 动画
   - 渐变效果
   - 自定义符号支持

## 马年设计元素

### 传统图案
1. **马的象征元素**:
   - 奔腾的马（动态感）
   - 马头剪影（简洁识别）
   - 马蹄铁（幸运符号）
   - 马鬃毛（流动线条）

2. **中国传统配色**:
   - **红色系**: #C41E3A（中国红）、#E60012
   - **金色系**: #FFD700（黄金）、#DAA520
   - **辅助色**: #8B0000（深红）、#FFA500（橙）

3. **装饰图案**:
   - 云纹（祥云）
   - 回纹（传统边框）
   - 火焰纹（马的动感）
   - 剪纸风格

### 现代设计风格
1. **扁平化 + 微渐变**
   - 简洁几何形状
   - 微妙阴影
   - 2.5D 效果

2. **液态玻璃风格**（Liquid Glass）
   - 毛玻璃效果
   - 透明度层次
   - 光感折射

3. **马年特殊标识**:
   - 小角标形式（右下角）
   - 2026 数字 + 马图案
   - 红色/金色印章风格
   - "马"字书法变体

## 功能清单（增强版）

### 核心功能（必须有）
- [ ] 应用扫描（系统 + 用户目录）
- [ ] 图标缓存（智能预加载）
- [ ] 网格布局（可自定义行列）
- [ ] 文件夹管理（拖拽创建、嵌套）
- [ ] 即时搜索（模糊匹配、拼音）
- [ ] 热键触发（可自定义）
- [ ] 全屏/窗口模式
- [ ] 设置面板

### 增强功能（差异化）
- [ ] **马年主题**（特殊标识、配色）
- [ ] **多主题系统**（浅色/深色/自定义）
- [ ] **动画效果**（页面切换、打开关闭）
- [ ] **右键菜单**（快速操作）
- [ ] **拖拽排序**（手动布局）
- [ ] **隐藏应用**（不显示但可搜索）
- [ ] **应用分类**（自动/手动）
- [ ] **使用频率统计**（智能排序）
- [ ] **最近应用**（快速访问）
- [ ] **多显示器优化**

### 专业功能（高级）
- [ ] **插件系统**（扩展功能）
- [ ] **工作区**（不同场景配置）
- [ ] **快捷键面板**（可视化编辑）
- [ ] **备份恢复**（布局导出导入）
- [ ] **自动更新**（Sparkle）
- [ ] **无障碍支持**（VoiceOver）
- [ ] **性能监控**（内存/CPU）

## 技术栈推荐

### 主技术栈
- **语言**: Swift 5.9+
- **UI 框架**: SwiftUI 5.0 + AppKit（混合）
- **最低版本**: macOS 14.0+
- **Xcode**: 26+

### 关键库
- **热键**: MASHotKey 或 KeyboardShortcuts
- **图标缓存**: SDWebImage 或自定义
- **设置**: Settings 或自定义
- **自动更新**: Sparkle
- **数据库**: SQLite (原生) 或 Realm
- **动画**: SwiftUI Animation + Spring

### 开发工具
- **图标设计**: Icon Composer（WWDC25 工具）
- **矢量工具**: Sketch/Figma/Adobe Illustrator
- **版本控制**: Git + GitHub
- **CI/CD**: GitHub Actions

## 项目结构设计

```
LaunchPro/
├── LaunchPro.xcodeproj
├── LaunchPro/
│   ├── App/
│   │   ├── LaunchProApp.swift
│   │   ├── AppDelegate.swift
│   │   └── Info.plist
│   ├── Models/
│   │   ├── AppItem.swift
│   │   ├── Folder.swift
│   │   ├── Layout.swift
│   │   └── Settings.swift
│   ├── Views/
│   │   ├── MainView.swift
│   │   ├── GridView.swift
│   │   ├── AppIconView.swift
│   │   ├── FolderView.swift
│   │   ├── SearchView.swift
│   │   └── SettingsView.swift
│   ├── ViewModels/
│   │   ├── AppScanner.swift
│   │   ├── IconCache.swift
│   │   ├── LayoutManager.swift
│   │   └── SearchManager.swift
│   ├── Services/
│   │   ├── HotKeyService.swift
│   │   ├── DatabaseService.swift
│   │   └── UpdateService.swift
│   ├── Resources/
│   │   ├── Assets.xcassets
│   │   ├── Icons/
│   │   └── Localizable.strings
│   └── Utils/
│       ├── Constants.swift
│       ├── Extensions.swift
│       └── Helpers.swift
├── LaunchProTests/
└── README.md
```

## 开发里程碑

### Phase 1: 基础框架（1-2 周）
- 项目搭建
- 应用扫描
- 基础网格布局
- 图标显示

### Phase 2: 核心功能（2-3 周）
- 文件夹管理
- 搜索功能
- 热键触发
- 设置面板

### Phase 3: 界面优化（1-2 周）
- 动画效果
- 主题系统
- 马年图标设计
- 多模式切换

### Phase 4: 增强功能（2-3 周）
- 右键菜单
- 拖拽排序
- 隐藏应用
- 性能优化

### Phase 5: 测试发布（1 周）
- Bug 修复
- 性能调优
- 文档编写
- GitHub 发布

## 下一步行动

1. **确认技术栈选择**
2. **确定功能优先级**
3. **设计马年图标草图**
4. **制定详细开发计划**
