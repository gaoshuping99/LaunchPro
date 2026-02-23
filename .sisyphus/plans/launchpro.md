# LaunchPro - 专业 macOS 启动台复刻计划

## TL;DR
> **项目目标**: 完整复刻 LaunchOS（包括基础功能和 Pro 功能），设计更专业漂亮的界面，添加马年特殊标识
>
> **技术栈**: Swift + SwiftUI + CoreData + SQLite
>
> **核心特性**:
> - 应用网格显示与拖拽排序
> - 文件夹管理（嵌套支持）
> - 全局热键快速访问
> - 智能搜索过滤
> - 马年主题（中国红+金色配色）
> - 图标自定义
>
> **开发周期**: 预计 6-8 周
> **最低系统**: macOS 14.0+

---

## Context

### 原始需求
用户要求复刻 LaunchOS 应用（官方网址：https://launchosapp.com/），完全复制包括基础功能和 Pro 功能，设计更专业漂亮的界面，添加马年特殊标识。

### LaunchOS 深度分析
通过实际分析用户电脑上的 LaunchOS.app（版本 1.1.1），获得以下关键信息：

#### 技术架构
- **Bundle ID**: `app.remixdesign.LaunchOS`
- **版本**: 1.1.1 (Build 67)
- **技术栈**: Swift + SwiftUI + CoreData + SQLite
- **架构**: Universal Binary (x86_64 + arm64)
- **依赖库**: Sparkle 2.8.0、KeyboardShortcuts、Firebase
- **最低系统**: macOS 26.0 (Tahoe)

#### 数据库结构
**ZAPPENTITY (应用表)**:
- Z_PK, Z_ENT, Z_OPT, ZHIDDEN, ZORDER, ZGROUP
- ZALIAS, ZBUNDLEID, ZID, ZNAME, ZURL

**ZGROUPENTITY (分组表)**:
- Z_PK, Z_ENT, Z_OPT, ZISFOLDER, ZORDER, ZPAGE, ZID, ZNAME

#### 用户数据
- 应用总数: 123 个
- 文件夹数: 9 个
- 文件夹: 浏览器、视频、视频会议、开发者工具等

---

## Work Objectives

### 核心目标
完全复刻 LaunchOS 所有功能，并添加马年主题增强

### 功能清单

#### 基础功能（必须实现）
1. 应用网格显示
2. 文件夹管理
3. 拖拽排序
4. 搜索过滤
5. 热键触发
6. 隐藏应用
7. 多语言支持

#### Pro 功能（完整复刻）
1. 自定义主题
2. 图标大小调节
3. 高级动画
4. 右键菜单
5. 使用统计
6. 备份恢复

#### 马年增强功能
1. 马年角标设计
2. 中国红+金色主题
3. 春节特殊效果

---

## Verification Strategy

### 测试策略
- 单元测试覆盖核心业务逻辑
- UI 测试验证界面交互
- 集成测试验证完整流程

### QA 要点
- 应用扫描准确性
- 拖拽排序流畅性
- 搜索响应速度
- 热键全局可用性
- 数据持久化可靠性

---

## Execution Strategy

### Wave 1: 项目搭建
任务 1-3: Xcode 项目 + CoreData 模型 + 基础架构

### Wave 2: 核心功能
任务 4-8: 应用扫描 + 网格显示 + 文件夹 + 搜索

### Wave 3: 增强功能
任务 9-12: 热键 + 主题 + 动画 + 马年标识

### Wave 4: 测试发布
任务 13-15: 测试 + 自动更新 + 打包发布

---

## TODOs

### 任务 1: Xcode 项目搭建
**What to do**:
- 创建 macOS App 项目
- 配置签名和 Bundle ID
- 设置最低系统版本 macOS 14.0
- 添加依赖库（Sparkle、KeyboardShortcuts）

**Must NOT do**:
- 不要添加不必要的依赖
- 不要改变项目结构

**QA Scenarios**:
- 项目编译成功
- 运行在 Intel 和 Apple Silicon

---

### 任务 2: CoreData 数据模型
**What to do**:
- 创建 AppEntity 实体
- 创建 GroupEntity 实体
- 配置关系映射
- 实现数据迁移

**References**:
- LaunchOS ZAPPENTITY 结构
- LaunchOS ZGROUPENTITY 结构

---

### 任务 3: 应用扫描器
**What to do**:
- 扫描 /Applications 目录
- 扫描 ~/Applications 目录
- 提取应用图标
- 缓存应用信息

**QA Scenarios**:
- 正确识别 123+ 应用
- 图标加载正常

---

### 任务 4: 网格布局视图
**What to do**:
- 实现 LazyVGrid 布局
- 支持多列显示
- 响应窗口大小变化
- 实现分页切换

---

### 任务 5: 文件夹管理
**What to do**:
- 创建文件夹
- 拖拽应用到文件夹
- 文件夹展开/折叠
- 文件夹重命名

---

### 任务 6: 拖拽排序
**What to do**:
- 实现拖拽手势
- 更新 ZORDER 字段
- 实时重排界面
- 支持跨文件夹拖拽

---

### 任务 7: 搜索功能
**What to do**:
- 实时搜索过滤
- 支持中英文
- 模糊匹配
- 高亮匹配文本

---

### 任务 8: 热键触发
**What to do**:
- 集成 KeyboardShortcuts
- 默认 Cmd+Shift+Space
- 支持自定义热键
- 全局监听

---

### 任务 9: 主题系统
**What to do**:
- 浅色/深色模式
- 马年主题（红金配色）
- 自定义背景
- 透明度调节

---

### 任务 10: 马年图标设计
**What to do**:
- 设计应用图标（1024x1024）
- 马年角标（右下角）
- 多尺寸导出
- 创建 AppIcon.appiconset

---

### 任务 11: 动画效果
**What to do**:
- 页面切换动画
- 文件夹展开动画
- 应用启动动画
- 搜索展开动画

---

### 任务 12: Pro 功能
**What to do**:
- 图标大小调节
- 使用频率统计
- 备份恢复功能
- 右键菜单

---

### 任务 13: 自动更新
**What to do**:
- 集成 Sparkle
- 配置更新服务器
- 签名验证
- 静默更新选项

---

### 任务 14: 测试验证
**What to do**:
- 单元测试
- UI 测试
- 性能测试
- 兼容性测试

---

### 任务 15: 打包发布
**What to do**:
- 创建 .dmg 安装包
- 代码签名
- 公证（可选）
- GitHub Release

---

## Final Verification Wave

### F1: 功能完整性检查
验证所有 LaunchOS 功能已复刻

### F2: 性能测试
验证启动速度 < 1 秒

### F3: 兼容性测试
验证 macOS 14.0+ 运行正常

### F4: 马年主题验证
验证主题切换和角标显示

---

## Success Criteria

### 功能完成
- [ ] 应用网格显示正常
- [ ] 文件夹管理完整
- [ ] 拖拽排序流畅
- [ ] 搜索过滤准确
- [ ] 热键触发正常
- [ ] 马年主题可用

### 质量指标
- [ ] 单元测试覆盖率 > 80%
- [ ] 无内存泄漏
- [ ] 启动时间 < 1 秒
- [ ] 界面帧率 60fps

### 交付物
- [ ] LaunchPro.app
- [ ] 源代码仓库
- [ ] 安装包 (.dmg)
- [ ] 使用文档
