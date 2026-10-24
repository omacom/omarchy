# 品牌定制

Omarchy 允许你为开机解锁、屏保和关于屏幕设置公司标志或个人图片。

### 开机解锁

你可以使用 `omarchy plymouth preview` 查看你的自定义标志和颜色会是什么样子。它接受一个背景颜色、一个文本颜色、一个标志 png 和一个预览图片路径：

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

然后用 `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png` 应用设置，这也会让 SDDM 登录屏幕使用相同的颜色和标志。如果你想还原，可以使用 `omarchy plymouth reset`。

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### 屏保

你可以在 _样式 > 屏保_ 下更改屏保使用的标志。它是一个 ASCII 标志，所以你可以直接编辑文本，但你也可以给它一个 png 或 svg 图片，我们会将其转换为 ASCII。看起来挺酷的。

 ![branding-screensaver](images/branding-screensaver.webp)

该菜单中有三项：

- **编辑文本** 在你的编辑器中打开 `~/.config/omarchy/branding/screensaver.txt`。输入或粘贴任何你喜欢的内容——ASCII 艺术、你的名字、一句粗话。保存并退出，屏保会立即启动，这样你就能看到它。
- **从图片设置** 打开一个用于选择 png 或 svg 的文件选择器，将其转换为 ASCII，并向你展示结果。轮廓清晰的标志效果远比照片好。
- **恢复默认** 恢复 Omarchy 标志。

### 关于屏幕

同样的三个选项位于 _样式 > 关于_ 下，用于你从 Omarchy 菜单得到的 _关于_ 屏幕，它们的工作方式完全相同——文件是 `~/.config/omarchy/branding/about.txt`，且关于窗口在每次更改后都会弹出。关于图被转换得比屏保的小，因为它必须装在一个窗口里，而不是填满你的显示器。

窗口打开期间，一道绿光每隔几秒斜扫过这幅图，然后让它再次静止。只要你的图中每个字符都是一列宽，你自己的图也会有此效果——_从图片设置_ 产生的任何内容都是如此。由表情符号或双宽字符构成的图则会保持静止，如果你保留自己的一份 fastfetch 配置，屏幕也是如此：在这些情况下静止的标志是动画在主动避让而不是失败了，因为让一道光扫过它们会让该行的其余部分错位。

 ![branding-about](images/branding-about.webp)

### 自行转换图片

两个 _从图片设置_ 选项都只是在调用 `omarchy transcode ascii`，如果你想控制转换过程，可以直接运行它：

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

它接受以终端列和行为单位的 `--width` 和 `--height`、模式 `--mode` 为 `braille`（默认，且精细得多）或 `block`、用于决定哪些像素算作标志一部分的百分比 `--threshold`，以及当你的标志在深色背景上呈浅色时使用的 `--invert`。如果一次转换出来的是一团模糊的东西，通常需要调节的旋钮是阈值。

### 用文字代替标志

`omarchy ascii` 使用 Delta Corps Priest 1 绘制文本，这是 Omarchy 词标本身所用的 FIGlet 字体，所以屏保可以说点什么，而不是显示一幅图片：

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

它接受文本作为参数，或者当没有参数时从管道中读取。该字体只有字母和空格——它被绘制时没有数字或标点——所以其他任何内容都会被丢弃，并在 stderr 上被指出，而不是被悄悄吞掉。
