# 中文界面

Omarchy 的 Quickshell 菜单支持简体中文。界面语言遵循当前桌面语言环境：当 `LANG` 或 `LANGUAGE` 以 `zh` 开头时，菜单标签、系统菜单和日历月份/星期会显示中文；其他语言保持英文。

也可以只为 Omarchy 强制指定语言，不改变系统其他程序：

```bash
export OMARCHY_UI_LANGUAGE=zh-CN  # 中文
export OMARCHY_UI_LANGUAGE=en     # 英文
```

将变量加入 `~/.config/environment.d/omarchy.conf` 后重新登录即可长期生效。菜单中的命令 ID、脚本名称和应用名称不会被翻译，因此快捷键、自动化脚本及第三方扩展保持兼容。新增菜单扩展时使用英文 `label`，中文映射位于 `shell/i18n/zh_CN.js`，可直接提交新的词条。
