# 其他软件包

Arch 在官方仓库和 Arch User Repository (AUR) 之间，为几乎任何类型的软件都提供了惊人的丰富软件包。

使用起来再简单不过了。你通过进入 Omarchy 菜单（`Super + Space`）中的 _安装 > Package_ 并输入你想要的软件包来安装一个新的 Arch 软件包。它会自动模糊过滤所有软件包的列表。（你也可以在终端中使用 `omarchy pkg add [package]` 手动完成）。

AUR 也可以这样，只需使用 _安装 > AUR_。只是要记住，AUR 没有经过 Arch 团队的审查。它就像 RubyGems 或 npm。任何人都可以上传。

如果你想删除一个软件包，可以使用 Omarchy 菜单中的 _移除 > Package_。它将删除软件包、配置文件和依赖项。（你也可以使用 `omarchy pkg drop [package]` 手动完成）。
