#!/bin/bash
set -e

echo "🚀 LaunchPro 简化构建脚本"
echo "=========================="

BUILD_DIR="./build_output"
APP_NAME="LaunchPro.app"
CONTENTS="$BUILD_DIR/$APP_NAME/Contents"

# 清理
rm -rf "$BUILD_DIR"
mkdir -p "$CONTENTS/MacOS"
mkdir -p "$CONTENTS/Resources"

echo "📦 创建 Info.plist..."
cat > "$CONTENTS/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key><string>LaunchPro</string>
    <key>CFBundleIdentifier</key><string>app.launchpro.LaunchPro</string>
    <key>CFBundleVersion</key><string>1.0.0</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleExecutable</key><string>LaunchPro</string>
    <key>LSMinimumSystemVersion</key><string>14.0</string>
    <key>NSAccentColorName</key><string>AccentColor</string>
</dict>
</plist>
PLIST

echo "⚠️  注意：由于缺少完整 Xcode，无法编译 Swift 源代码"
echo ""
echo "✅ 已创建应用包结构："
echo "   $BUILD_DIR/$APP_NAME"
echo ""
echo "📝 要完成构建，请执行以下步骤："
echo "   1. 安装完整 Xcode (从 Mac App Store)"
echo "   2. 打开 LaunchPro/LaunchPro.xcodeproj"
echo "   3. 按 Cmd+B 构建"
echo "   4. 产品会生成在 build/Distribution/"
echo ""
echo "🎯 当前已完成："
echo "   ✅ 14 个 Swift 源文件"
echo "   ✅ CoreData 模型"
echo "   ✅ 资源配置"
echo "   ✅ 测试文件"
echo "   ✅ 文档 (README, LICENSE)"
echo ""
echo "📂 项目位置：$(pwd)"
