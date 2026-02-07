

## Phase 1 总目标

```text
目标：
- 项目可以 flutter run
- 锁定横屏
- 主题、字体、基础布局完成
- 不实现任何业务逻辑
```

------

## 🧩 Step 1 — main.dart

### Claude Code Prompt

```text
创建文件：lib/main.dart

要求：
- 使用 WidgetsFlutterBinding.ensureInitialized
- 锁定横屏（LandscapeLeft + LandscapeRight）
- 入口只做系统级初始化
- 不写任何 UI 逻辑
- 最终调用 runApp(App())

只输出该文件完整代码。
```

------

## 🧩 Step 2 — app.dart

### Claude Code Prompt

```text
创建文件：lib/app.dart

要求：
- 定义 App widget
- 使用 MaterialApp
- 关闭 debug banner
- 设置主题（调用 AppTheme.light）
- 设置默认 locale 为 zh
- home 使用 LandscapeScaffold（先空实现）

不引入路由系统
只输出该文件代码
```

------

## 🧩 Step 3 — app_theme.dart

### Claude Code Prompt

```text
创建文件：lib/core/theme/app_theme.dart

要求：
- 定义 AppTheme 类
- 提供 static ThemeData light
- 主色使用 #003764
- 字体使用 Inter
- AppBar / Card / TextTheme 做基础定制
- 不引入 Dark Theme

颜色值直接写，不做抽象
```

------

## 🧩 Step 4 — ws_colors.dart

### Claude Code Prompt

```text
创建文件：lib/core/constants/ws_colors.dart

要求：
- 定义 WorldSkills 色彩常量
- 至少包含：
  - darkBlue (#003764)
  - white
  - lightGray
- 使用 static const Color
- 不引入 ThemeData
```

------

## 🧩 Step 5 — landscape_scaffold.dart

### Claude Code Prompt

```text
创建文件：lib/layout/landscape_scaffold.dart

要求：
- 只支持横屏
- 使用 Scaffold
- body 为 Row 布局
- 左侧为占位导航栏（固定宽度）
- 右侧为 Expanded 内容区
- 内容区暂时显示占位文本：SkillCount

不要实现真实导航
```

------

## 🧩 Step 6 — 字体资源声明（pubspec.yaml）

### Claude Code Prompt

```text
修改文件：pubspec.yaml

要求：
- 注册 Inter 字体
- 保留 Flutter 默认配置
- 不删除已有内容
- 字体 family 名称为 Inter
```

------

> ✅ **Phase 1 完成标准**
>
> - `flutter run` 无错误
> - 横屏锁定生效
> - 页面显示 SkillCount 占位

------

# 🚀 Phase 2 — 核心倒计时（比赛级核心）

## Phase 2 总目标

```text
目标：
- 主倒计时可用
- 时间计算正确
- UI 有“世赛气质”
- 不做动画、不做多页面
```

------

## 🧠 Step 1 — ws_times.dart

### Claude Code Prompt

```text
创建文件：lib/core/constants/ws_times.dart

要求：
- 定义 WorldSkills 关键时间点
- 必须包含：
  - competitionOpenTime = 2026-09-22 19:00 UTC+8
- 使用 DateTime
- 写清楚时区处理方式（注释即可）
```

------

## 🧠 Step 2 — time_utils.dart

### Claude Code Prompt

```text
创建文件：lib/core/utils/time_utils.dart

要求：
- 提供方法：
  - Duration timeLeft(DateTime target)
- 自动使用本地时间
- 只负责计算，不负责格式化
- 无 UI 依赖
```

------

## 🧠 Step 3 — countdown_page.dart

### Claude Code Prompt

```text
创建文件：lib/features/countdown/countdown_page.dart

要求：
- StatefulWidget
- 使用 Timer.periodic 每秒刷新
- 使用 ws_times 中的开幕时间
- 使用 time_utils 计算剩余时间
- 页面居中显示大号倒计时

布局要求：
- 天 / 时 / 分 / 秒 分区显示
- 数字明显大于标签
```

------

## 🧠 Step 4 — ws_timer_text.dart

### Claude Code Prompt

```text
创建文件：lib/widgets/ws_timer_text.dart

要求：
- StatelessWidget
- 接收数字 + label
- 数字字体大、粗
- label 小且克制
- 可复用
```

------

## 🧠 Step 5 — countdown 接入主布局

### Claude Code Prompt

```text
修改文件：lib/layout/landscape_scaffold.dart

要求：
- 右侧内容区替换为 CountdownPage
- 左侧导航栏保留占位
- 不引入路由
```

好，下面我直接给你 **Phase 3 / Phase 4 的「逐文件指令版 Prompt」**，
风格、粒度、约束 **完全和你前面 Phase 1 / Phase 2 一致**，可以无缝接着用在 **Claude Code** 里。

目标仍然是：**不重构、不返工、一步一步稳态推进**。

------

# 🚀 Phase 3 — 功能完整度（Pomodoro + Milestones）

## Phase 3 总目标

```text
目标：
- Skill Pomodoro 可完整使用
- 关键时间节点列表展示
- 功能“少而准”
- UI 保持世赛气质，不追求复杂
```

------

## 🧠 Step 1 — milestone_model.dart

### Claude Code Prompt

```text
创建文件：lib/features/milestones/milestone_model.dart

要求：
- 定义 Milestone 类
- 字段：
  - String title
  - DateTime targetTime
- 提供 const 构造函数
- 不包含任何 UI 代码
```

------

## 🧠 Step 2 — milestone_list.dart

### Claude Code Prompt

```text
创建文件：lib/features/milestones/milestone_list.dart

要求：
- StatelessWidget
- 内部定义一个 List<Milestone>
- 至少包含：
  - 报名截止
  - 技术描述发布
  - 比赛开幕
  - 比赛闭幕
- 时间写死（合理即可）
- 使用 Column / ListView 展示
```

------

## 🧠 Step 3 — milestone_card.dart

### Claude Code Prompt

```text
创建文件：lib/features/milestones/milestone_card.dart

要求：
- StatelessWidget
- 接收 Milestone
- 使用 Card 展示
- 显示：
  - 标题
  - 剩余时间（天/时）
- 剩余时间使用 time_utils 计算
- 不显示秒，保持克制
```

------

## 🧠 Step 4 — milestones 接入 Countdown 页面

### Claude Code Prompt

```text
修改文件：lib/features/countdown/countdown_page.dart

要求：
- 主倒计时保持不变
- 下方新增 MilestoneList
- 使用 Column + Expanded
- 不引入滚动冲突
```

------

## ⏱️ Step 5 — pomodoro_controller.dart

### Claude Code Prompt

```text
创建文件：lib/features/pomodoro/pomodoro_controller.dart

要求：
- 管理 Pomodoro 状态
- 字段：
  - Duration totalDuration
  - Duration remaining
  - bool isRunning
- 使用 Timer
- 提供方法：
  - start()
  - pause()
  - reset()
- 不依赖 UI
```

------

## ⏱️ Step 6 — pomodoro_timer.dart

### Claude Code Prompt

```text
创建文件：lib/features/pomodoro/pomodoro_timer.dart

要求：
- StatelessWidget
- 接收 remaining Duration
- 显示：HH : MM : SS
- 字体大，适合远距离观看
```

------

## ⏱️ Step 7 — pomodoro_page.dart

### Claude Code Prompt

```text
创建文件：lib/features/pomodoro/pomodoro_page.dart

要求：
- StatefulWidget
- 使用 PomodoroController
- 提供按钮：
  - Start
  - Pause
  - Reset
- 提供时长选择：
  - 1h / 2h / 3h
- 风格：训练模块，不是生活番茄钟
```

------

## 🧩 Step 8 — 临时接入 Pomodoro 页面

### Claude Code Prompt

```text
修改文件：lib/layout/landscape_scaffold.dart

要求：
- 使用一个 bool 开关
- 可在 CountdownPage / PomodoroPage 间切换
- 不引入路由
- 仅用于展示
```

------

> ✅ **Phase 3 完成标准**
>
> - Pomodoro 可完整使用
> - Milestones 显示正确
> - 页面无明显逻辑 Bug
> - 可演示“训练节奏 + 比赛节点”

------

# 🌍 Phase 4 — 国际化 & 时区（展示加分项）

## Phase 4 总目标

```text
目标：
- 中英文切换
- 时区对比功能
- 代码结构清楚，可答辩
```

------

## 🌐 Step 1 — strings.dart

### Claude Code Prompt

```text
创建文件：lib/core/i18n/strings.dart

要求：
- 定义 AppStrings 抽象接口
- 包含：
  - appTitle
  - countdown
  - pomodoro
  - milestones
- 不涉及 BuildContext
```

------

## 🌐 Step 2 — zh.dart / en.dart

### Claude Code Prompt（各执行一次）

```text
创建文件：lib/core/i18n/zh.dart

要求：
- 实现 AppStrings
- 使用简体中文
创建文件：lib/core/i18n/en.dart

要求：
- 实现 AppStrings
- 使用简洁英文
```

------

## 🌐 Step 3 — 时区模型

### Claude Code Prompt

```text
创建文件：lib/features/timezone/timezone_model.dart

要求：
- 定义 TimeZoneCity
- 字段：
  - String name
  - int utcOffset
- 不使用任何第三方库
```

------

## 🌐 Step 4 — timezone_converter.dart

### Claude Code Prompt

```text
创建文件：lib/features/timezone/timezone_converter.dart

要求：
- 提供方法：
  - DateTime convert(DateTime base, int offset)
- 基于 UTC 偏移计算
- 不处理夏令时
```

------

## 🌐 Step 5 — timezone_page.dart

### Claude Code Prompt

```text
创建文件：lib/features/timezone/timezone_page.dart

要求：
- StatelessWidget
- 基准时间：上海
- 展示多个城市当前时间
- 使用 Column + Card
- 强调“国际比赛协作”
```

------

## 🌐 Step 6 — 接入主布局

### Claude Code Prompt

```text
修改文件：lib/layout/landscape_scaffold.dart

要求：
- 支持切换：
  - Countdown
  - Pomodoro
  - Timezone
- 仍然不使用 Navigator
```

------

> ✅ **Phase 4 完成标准**
>
> - 中英文可切换（哪怕是硬切）
> - 时区计算正确
> - 功能讲得清楚、代码稳

