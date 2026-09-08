// Chinese (Simplified) labels for the Omarchy shell.
// Keys intentionally match the English source labels so extensions and
// third-party plugins continue to work without changing their IDs.
var labels = {
  "Go": "前往", "Input": "输入", "Select": "选择",
  "Apps": "应用", "Learn": "学习", "Trigger": "快捷操作", "Style": "外观",
  "Setup": "设置", "Install": "安装", "Remove": "卸载", "Update": "更新",
  "About": "关于", "System": "系统", "Screensaver": "屏幕保护",
  "Lock": "锁定", "Suspend": "挂起", "Hibernate": "休眠", "Logout": "退出登录",
  "Reboot": "重启", "Shutdown": "关机", "Keybindings": "快捷键",
  "Community": "社区", "Emoji": "表情符号", "Reminder": "提醒",
  "Capture": "截取", "Screenshot": "截图", "Stop Screenrecording": "停止录屏",
  "Screenrecord": "录屏", "Text": "文字", "QR Code": "二维码", "Color": "取色",
  "With no audio": "无音频", "With desktop audio": "桌面音频",
  "With desktop + microphone audio": "桌面音频 + 麦克风",
  "With desktop + microphone audio + webcam": "桌面音频 + 麦克风 + 摄像头",
  "Transcode": "转码", "Share": "分享", "Toggle": "切换", "Hardware": "硬件",
  "Speed Test": "测速", "Laptop Display": "笔记本屏幕", "Mirror Display": "镜像显示",
  "Hybrid GPU": "混合显卡", "Touchpad": "触控板", "Touchpad Haptics": "触控板触感",
  "Touchscreen": "触摸屏", "Set one": "设置提醒", "Show all": "显示全部",
  "Clear all": "清除全部", "Clipboard": "剪贴板", "File": "文件", "Folder": "文件夹",
  "Receive": "接收", "Stay Awake": "保持唤醒", "Notifications": "通知",
  "Crash Capture": "崩溃捕获", "Nightlight": "夜间模式", "Menu Bar": "菜单栏",
  "Battery Percentage": "电池百分比", "Workspace Layout": "工作区布局",
  "Window Gaps": "窗口间距", "1-Window Ratio": "单窗口比例", "Network Speed Test": "网络测速",
  "Disk Speed Test": "磁盘测速", "Theme": "主题", "Background": "背景",
  "Unlock": "解锁界面", "Font": "字体", "Position": "位置", "Transparency": "透明度",
  "Top": "顶部", "Bottom": "底部", "Left": "左侧", "Right": "右侧",
  "Edit Text": "编辑文字", "Set From Image": "从图片设置", "Restore Default": "恢复默认",
  "Monitors": "显示器", "Input": "输入", "Network": "网络", "DNS": "DNS",
  "DHCP": "DHCP", "Custom": "自定义", "Defaults": "默认值", "Browser": "浏览器",
  "Terminal": "终端", "Editor": "编辑器", "Plugins": "插件", "Enable Plugin": "启用插件",
  "Disable Plugin": "禁用插件", "Add Plugin": "添加插件", "Clone Plugin": "克隆插件",
  "Remove Plugin": "移除插件", "Security": "安全", "Password": "密码",
  "Package": "软件包", "AI": "人工智能", "Service": "服务", "Services": "服务",
  "Development": "开发", "Gaming": "游戏", "Web App": "网页应用", "TUI": "终端界面",
  "Windows": "Windows", "Preinstalls": "预装软件", "Extra Themes": "额外主题",
  "Process": "进程", "Firmware": "固件", "Timezone": "时区", "Time": "时间",
  "Reset to default": "恢复默认", "Restart": "重启", "Remove": "卸载",
  "Stable": "稳定版", "Edge": "体验版", "Dev": "开发版", "Audio": "音频",
  "Wi-Fi": "Wi-Fi", "Bluetooth": "蓝牙", "Trackpad": "触控板", "User": "用户",
  "Drive Encryption": "磁盘加密", "No matches for": "没有匹配项", "Nothing here yet": "这里还没有内容",
  "Search...": "搜索…", "Search emojis…": "搜索表情符号…", "Search city": "搜索城市",
  "No options": "没有选项", "No matches": "没有匹配项", "Cancel": "取消", "Confirm": "确认",
  "Back to today": "回到今天", "Open Captive Portal": "打开认证门户",
  "Connected": "已连接", "Disconnected": "未连接", "No connection": "无网络连接",
  "No adapter": "没有适配器", "No Bluetooth adapter": "没有蓝牙适配器"
}

function translate(value) {
  var text = String(value || "")
  return labels[text] || text
}

function translateItems(items) {
  var out = []
  for (var i = 0; i < (items || []).length; i++) {
    var item = items[i]
    var copy = {}
    for (var key in item) copy[key] = item[key]
    copy.label = translate(copy.label)
    if (copy.title) copy.title = translate(copy.title)
    if (copy.description) copy.description = translate(copy.description)
    out.push(copy)
  }
  return out
}

if (typeof module !== "undefined") module.exports = { labels: labels, translate: translate, translateItems: translateItems }
