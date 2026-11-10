# 品牌定制

Omarchy 允许你为启动解锁、屏幕保护程序和关于界面设置你的公司标志或个人图像。

### 启动解锁

你可以使用 `omarchy plymouth preview` 查看你的自定义标志和颜色会是什么样子。它接受一个背景色、一个文字颜色、一个 logo png，以及一个预览图像的路径：

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

然后使用 `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png` 应用该设置，这也会为 SDDM 登录界面设置相同的颜色和标志。如果你想恢复，可以使用 `omarchy plymouth reset`。

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### 屏幕保护程序

你可以在 _外观 > 品牌定制 > 屏幕保护程序_ 下更改用于屏幕保护程序的标志。它是一个 ASCII 标志，所以你可以直接编辑文本，但你也可以给它一个 png 或 svg 图像，我们会将其转换为 ASCII。看起来相当酷。

 ![branding-screensaver](images/branding-screensaver.webp)

该菜单中有三个条目：

- **编辑文本** 会在你的编辑器中打开 `~/.config/omarchy/branding/screensaver.txt`。输入或粘贴任何你喜欢的内容——ASCII 艺术、你的名字、一句粗话。保存并退出，屏幕保护程序会立即启动，让你看到效果。
- **从图像设置** 会打开一个文件选择器，用于选择 png 或 svg，将其转换为 ASCII，并向你展示结果。轮廓清晰的标志效果远比照片好。
- **恢复默认** 会将 Omarchy 标志恢复回来。

### 关于界面

在 _外观 > 品牌定制 > 关于_ 下有相同的三个选项，用于从 Omarchy 菜单打开的 _关于_ 界面，它们的工作方式完全相同——文件是 `~/.config/omarchy/branding/about.txt`，并且每次更改后关于窗口都会弹出。关于界面的图案会转换为比屏幕保护程序更小的尺寸，因为它必须适合窗口，而不是填满你的显示器。

窗口打开时，每隔几秒钟会有一道绿色的微光斜掠过图案，然后让它再次静止。只要你的图案中每个字符都是一列宽，你自己的图案也会有这个效果——_从图像设置_ 生成的任何内容都是如此。用 emoji 或双宽字符构建的图案则会保持静止，如果你保留自己的 fastfetch 配置，界面也会保持静止：在这些情况下，静态标志是动画主动避让而不是失败，因为让一道微光滑过它们会使该行其余部分落在错误的位置。

 ![branding-about](images/branding-about.webp)

### 自己转换图像

两个 _从图像设置_ 选项实际上只是调用 `omarchy transcode ascii`，如果你想控制转换过程，可以直接运行它：

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

它接受以终端列和行为单位的 `--width` 和 `--height`，一个 `--mode`，可以是 `braille`（默认值，而且精细得多）或 `block`，一个 `--threshold` 百分比，用于决定哪些像素算作标志的一部分，以及当你的标志是深色背景上的浅色时使用的 `--invert`。如果转换结果变成一团，通常应该调整的就是阈值这个旋钮。

### 用文字代替标志

`omarchy ascii` 使用 Delta Corps Priest 1 绘制文本，这是 Omarchy 文字标志本身所使用的 FIGlet 字体，所以屏幕保护程序可以显示文字，而不是展示图片：

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

它将文本作为参数，或者在没有给定参数时从管道中读取。该字体仅包含字母和空格——绘制时没有数字或标点符号——所以任何其他内容都会被丢弃，并在 stderr 上明确指出，而不是悄悄吞掉。
