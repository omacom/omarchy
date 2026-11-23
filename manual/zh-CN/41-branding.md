# 品牌标识

Omarchy 允许你为启动解锁、屏幕保护程序和关于屏幕设置你的公司徽标或个人图像。

### 启动解锁

你可以使用 `omarchy plymouth preview` 查看你的自定义徽标和颜色的效果。它接受一个背景颜色、一个文本颜色、一个徽标 png，以及预览图的路径：

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

然后使用 `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png` 应用这套设置，这也会让 SDDM 登录屏幕使用相同的颜色和徽标。如果你想恢复，可以使用 `omarchy plymouth reset`。

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### 屏幕保护程序

你可以在 _外观 > 品牌标识 > 屏幕保护程序_ 下更改屏幕保护程序使用的徽标。它是一个 ASCII 徽标，所以你可以直接编辑文本，但你也可以给它一个 png 或 svg 图像，我们会将其转换为 ASCII。它看起来相当酷。

 ![branding-screensaver](images/branding-screensaver.webp)

该菜单中有三个条目：

- **编辑文本** 在你的编辑器中打开 `~/.config/omarchy/branding/screensaver.txt`。输入或粘贴任何你喜欢的内容——ASCII 艺术、你的名字、一句粗话。保存并退出，屏幕保护程序会立即启动，让你可以看到效果。
- **从图像设置** 打开一个 png 或 svg 的文件选择器，将其转换为 ASCII，并向你展示结果。轮廓清晰的徽标效果远比照片好。
- **恢复默认** 将 Omarchy 徽标放回来。

### 关于屏幕

在 _外观 > 品牌标识 > 关于_ 下有相同的三个选项，用于从 Omarchy 菜单打开的 _关于_ 屏幕，它们的工作方式完全相同——文件是 `~/.config/omarchy/branding/about.txt`，并且每次更改后都会弹出关于窗口。关于图案会被转换成比屏幕保护程序更小的尺寸，因为它必须装进一个窗口，而不是填满你的显示器。

窗口打开时，一道明亮的白光带每隔几秒就会斜掠过图案，然后又让它静止下来。只要你的图案中每个字符都是单列宽，你自己的图案也会有这个效果——任何通过 _从图像设置_ 生成的都是如此。由 emoji 或双宽字符构成的图案则保持静止，如果你保留了自己的 fastfetch 配置，屏幕也会如此：在这些情况下，静止的徽标是动画主动避让而不是失败，因为让一道 glint 滑过它们会使行中其余部分落在错误的位置。

 ![branding-about](images/branding-about.webp)

### 自己转换图像

两个 _从图像设置_ 选项实际上都只是在调用 `omarchy transcode ascii`，如果你想要控制转换过程，可以直接运行它：

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

它接受以终端列和行表示的 `--width` 和 `--height`，接受 `braille`（默认选项，而且精细得多）或 `block` 两种 `--mode` 之一，接受一个用于决定哪些像素算作徽标一部分的 `--threshold` 百分比，以及在你的徽标是深色背景上的浅色时使用的 `--invert`。如果转换结果出来是一团，通常要调的就是阈值这个旋钮。

### 用文字代替徽标

`omarchy ascii` 使用 Delta Corps Priest 1 绘制文本，这正是绘制 Omarchy 词标本身的 FIGlet 字体，所以屏幕保护程序可以说点什么，而不是展示一幅图画：

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

它将文本作为参数接受，或者在未给出任何参数时从管道读取。字体只包含字母和空格——绘制时没有包含数字或标点符号——所以任何其他内容都会被丢弃并在 stderr 上指明，而不是被悄悄吞掉。
