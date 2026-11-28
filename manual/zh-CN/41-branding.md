# 品牌形象

Omarchy 允许你为屏保和关于屏幕设置你的公司徽标或个人图像。

### 屏保

你可以在 _Appearance > Branding > Screensaver_ 下更改屏保使用的徽标。它是一个 ASCII 徽标，所以你可以直接编辑文本，但你也可以给它一个 png 或 svg 图像，我们会将其转换为 ASCII。看起来相当酷。

 ![branding-screensaver](images/branding-screensaver.webp)

该菜单中有三个条目：

- **Edit Text** 会在你的编辑器中打开 `~/.config/omarchy/branding/screensaver.txt`。输入或粘贴任何你喜欢的内容——ASCII 艺术、你的名字、一个粗鲁的词。保存并退出，屏保会立即启动，以便你查看效果。
- **Set From Image** 会打开一个文件选择器，用于选择 png 或 svg，将其转换为 ASCII，并向你显示结果。轮廓清晰的徽标效果远好于照片。
- **Restore Default** 会恢复 Omarchy 徽标。

### 关于屏幕

同样的三个选项位于 _Appearance > Branding > About_ 下，用于你从 Omarchy 菜单打开的 _About_ 屏幕，它们的运作方式完全相同——文件是 `~/.config/omarchy/branding/about.txt`，About 窗口会在每次更改后弹出。About 艺术会被转换为比屏保更小的尺寸，因为它需要放进一个窗口，而不是填满你的显示器。

当窗口打开时，每隔几秒钟，一道明亮的白光带会斜过艺术作品，然后让它再次静止。只要你自己的艺术中的每个字符都是一列宽，它也会有这个效果——_Set From Image_ 生成的任何内容都是如此。用 emoji 或双宽字符构建的艺术则会保持静止，如果你保留了自己的 fastfetch 配置，屏幕也会保持静止：在这些情况下，静止的徽标是动画在主动避让而不是失败，因为让一道亮光滑过它们会让该行其余部分落到错误的位置。

 ![branding-about](images/branding-about.webp)

### 自行转换图像

两个 _Set From Image_ 选项实际上都只是在调用 `omarchy transcode ascii`，如果你想要控制转换过程，可以直接运行它：

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

它接受以终端列数和行数为单位的 `--width` 和 `--height`，`--mode` 可以是 `braille`（默认值，而且精细得多）或 `block`，一个用于决定哪些像素算作徽标一部分的 `--threshold` 百分比，以及用于你的徽标在深色背景上是浅色时的 `--invert`。如果转换结果出来是一团糊状物，通常要调的就是阈值这个旋钮。

### 用文字代替徽标

`omarchy ascii` 使用 Delta Corps Priest 1 绘制文本，这就是 Omarchy 字标本身所用的 FIGlet 字体，所以屏保可以说点什么，而不是展示一张图片：

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

它将文本作为参数，或者在未给定任何参数时从管道中读取。该字体只包含字母和空格——它在绘制时没有数字或标点符号——所以任何其他内容都会被丢弃，并在 stderr 上指明，而不是被悄悄吞掉。
