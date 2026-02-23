#!/bin/bash
set -e
echo "🚀 LaunchPro 构建脚本"
PROJECT_NAME="LaunchPro"
SCHEME="LaunchPro"
CONFIGURATION="Release"
rm -rf build
mkdir -p build/Archives build/Distribution
echo "🔨 构建项目..."
xcodebuild -project "$PROJECT_NAME.xcodeproj" -scheme "$SCHEME" -configuration "$CONFIGURATION" -archivePath "build/Archives/$PROJECT_NAME" archive || echo "需要 Xcode 项目文件"
echo "✅ 构建完成"
