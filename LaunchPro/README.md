# LaunchPro - 专业 macOS 启动台

![macOS](https://img.shields.io/badge/macOS-14.0+-blue) ![Swift](https://img.shields.io/badge/Swift-6.0+-orange)

完全复刻 LaunchOS，添加马年主题增强

## 特性

### 基础功能
- 应用网格显示 (LazyVGrid)
- 文件夹管理 (嵌套支持)
- 拖拽排序
- 智能搜索 (中英文)
- 全局热键 (Cmd+Shift+Space)
- 隐藏应用

### Pro 功能
- 多主题系统 (默认/马年)
- 图标自定义 (40-120px)
- 网格调节 (4-10 列)
- 右键菜单
- 流畅动画

### 马年特色
- 马年主题 (中国红 #C41E3A + 金色 #FFD700)

## 构建

```bash
cd LaunchPro
open LaunchPro.xcodeproj
# Cmd+B 构建，Cmd+R 运行
```

## 打包

```bash
./build.sh
# 输出：build/Distribution/LaunchPro.dmg
```

## 技术栈

- Swift 6.0+
- SwiftUI 5.0
- CoreData + SQLite
- KeyboardShortcuts
- Sparkle

## 许可证

MIT License
