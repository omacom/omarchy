# คีย์บอร์ด, เมาส์, แทร็กแพด

Hyprland ให้คุณกำหนดค่าอุปกรณ์นำเข้าทั้งหมดได้อย่างละเอียดมาก คุณสามารถเปลี่ยนการกดซ้ำของคีย์บอร์ดให้เร็วแบบเหนือเสียง หรือทำให้แทร็กแพดใช้การเลื่อนแบบธรรมชาติได้ คุณเปลี่ยนทั้งหมดนี้ได้ใน `~/.config/hypr/input.lua` ซึ่งเข้าถึงได้ผ่าน _Setup > Input_ ในเมนู Omarchy (`Super + Space`) เช่นกัน สิ่งใดก็ตามที่คุณตั้งไว้ที่นั่นจะแทนที่ค่าเริ่มต้นของ Omarchy

นี่คือตัวอย่าง:

```lua
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,dk",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",

    -- Change speed of keyboard repeat
    repeat_rate = 40,
    repeat_delay = 600,

    -- Increase sensitivity for mouse/trackpad (default: 0)
    sensitivity = 0.35,

    touchpad = {
      -- Use natural (inverse) scrolling
      natural_scroll = true,

      -- Use two-finger clicks for right-click instead of lower-right corner
      clickfinger_behavior = true,

      -- Control the speed of your scrolling
      scroll_factor = 0.3,
    },
  },
})

-- Scroll faster in the terminal
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
```

คุณสามารถ[ดูตัวเลือกการนำเข้าทั้งหมด](https://wiki.hypr.land/Configuring/Basics/Variables/#input)ได้บนวิกิ Hyprland สำหรับการนำเข้า

CapsLock ทำงานเป็น Caps Lock ตามปกติ และ `Shift + CapsLock` เป็นปุ่ม compose สำหรับ[อิโมจิลัด](07-hotkeys.md#quick-emojis)และ[การเติมข้อความลัดอื่น ๆ](07-hotkeys.md#quick-completions) หากคุณอยากให้ปุ่ม compose ไปอยู่ที่อื่นแทน ให้แทนที่ `omarchy:shift_caps_compose` ใน `kb_options` ตัวอย่างเช่น วิธีนี้จะย้ายปุ่ม compose ไปที่ Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### ปุ่มฟังก์ชัน

แถวบนสุดของคีย์บอร์ดแล็ปท็อปจะส่งปุ่มสื่อ (ระดับเสียง ความสว่าง และอื่น ๆ) เป็นค่าเริ่มต้น และการกด `Fn` ค้างไว้จะให้ F1-F12 ส่วน `Fn + Esc` จะล็อกสลับไปอีกทางจนกว่าคุณจะกดมันอีกครั้ง คีย์บอร์ดส่วนใหญ่จะจดจำการล็อกนั้นไว้เอง แล็ปท็อป ASUS และคีย์บอร์ดแบบ Apple ปล่อยเรื่องนี้ไว้กับ Linux ซึ่งจะเริ่มต้นที่ปุ่มสื่อทุกครั้งที่บูต หากต้องการให้เริ่มต้นที่ F1-F12 แทน ให้รัน `omarchy device keyboard toprow fnkeys` (และ `omarchy device keyboard toprow mediakeys` เพื่อกลับไป) บนแล็ปท็อปบางรุ่นจะมีผลหลังจากรีบูต ส่วน Apple Silicon Macs จะคงการตั้งค่าของตัวเองไว้

### ท่าทางบนแทร็กแพด

ปัดบนแทร็กแพดเพื่อเคลื่อนไปรอบ ๆ เดสก์ท็อป:

| ท่าทาง | การกระทำ |
| --- | --- |
| สามนิ้วไปทางซ้าย / ขวา | workspace ก่อนหน้า / ถัดไป รวมถึง workspace ที่ว่างเปล่า |
| สามนิ้วขึ้น | สลับคอนโซล AI |
| สามนิ้วลง | เปิดเมนู Omarchy |
| สี่นิ้วไปทางซ้าย / ขวา | ย้ายหน้าต่างที่ใช้งานอยู่ไปยัง workspace ก่อนหน้า / ถัดไป |
| สี่นิ้วลง | สลับเต็มหน้าจอ |

หากต้องการเปลี่ยนท่าทางใด ให้ยกเลิกการตั้งค่าท่าทางนั้นใน `~/.config/hypr/input.lua` ก่อนเพิ่ม[ท่าทางบนทัชแพด](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/)ของคุณเอง เนื่องจาก Hyprland จะไม่ยอมรับสองท่าทางที่ใช้นิ้วและทิศทางเดียวกัน:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

หากต้องการปิดท่าทางทั้งหมดของ Omarchy ให้ตั้ง `omarchy_default_gestures = false` ไว้ใกล้ด้านบนของ `~/.config/hypr/hyprland.lua` ก่อนที่ค่าเริ่มต้นของ Omarchy จะโหลด

บนแล็ปท็อป Dell XPS ที่มีทัชแพดแบบสั่นสัมผัส คุณยังสามารถตั้งค่าความแรงของการคลิกเป็น low, mid หรือ high ได้ภายใต้ _Trigger > Hardware > Touchpad Haptics_

### การพิมพ์ภาษาจีน ภาษาญี่ปุ่น และภาษาอื่น ๆ

เลือก Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin) หรือ Hong Kong (Cangjie) เมื่อโปรแกรมติดตั้งถามถึงคีย์บอร์ดของคุณ Omarchy จะกำหนดค่าคีย์บอร์ดและเครื่องมือป้อนข้อความที่ตรงกันให้โดยอัตโนมัติ รวมถึงในระหว่างการตั้งค่าครั้งแรกแบบออฟไลน์ด้วย Japanese ใช้ Mozc, Korean ใช้ Hangul แบบมาตรฐานสองชุด, Simplified Chinese ใช้ Pinyin, Taiwan ใช้การจัดวาง Zhuyin มาตรฐานของ Chewing และ Hong Kong ใช้ Cangjie พร้อมรูปแบบตัวอักษรของ Hong Kong ส่วน Japanese (US keyboard) จะให้ Mozc พร้อมเลย์เอาต์คีย์บอร์ด US ปุ่ม Hangul, Zhuyin และ Cangjie จะยังคงอยู่ในตำแหน่งมาตรฐานแม้เมื่อคุณพิมพ์ตัวอักษรละตินด้วย Dvorak, Colemak หรือ AZERTY หากคุณเคยเพิ่ม Hangul หรือ Chewing ไว้ก่อนหน้านี้ ให้ยกเลิกการเลือกแล้วเลือกใหม่ภายใต้ _Setup > Keyboard > Input Methods_ เพื่อย้ายปุ่มของมันไปไว้ที่นั่น Omarchy จะไม่แตะต้องเครื่องมือที่คุณกำลังใช้พิมพ์อยู่แล้ว

การพิมพ์จะเริ่มต้นในโหมดละติน กด `Super + I` เพื่อวนไปตามวิธีการป้อนข้อความที่กำหนดค่าไว้ และ `Super + Shift + I` เพื่อวนกลับ แตะ `Shift` เดี่ยว ๆ เพื่อก้าวออกจากวิธีการป้อนข้อความอย่าง Pinyin ไปสู่ตัวอักษรละติน และแตะอีกครั้งเพื่อกลับไป ในแบบเดียวกับที่ Sogou, Microsoft Pinyin และ macOS ทำงาน ส่วน `Shift` พร้อมตัวอักษรยังคงพิมพ์ตัวพิมพ์ใหญ่ บนคีย์บอร์ด Japanese ปุ่ม 全角/半角 จะสลับการป้อนข้อความ ปุ่ม 変換 จะเปิดมัน และปุ่ม 無変換 จะปิดมัน สำหรับ Korean ปุ่ม 한/영 จะสลับ Hangul และปุ่ม 한자 จะแปลงเป็น Hanja ไม่ว่าคีย์บอร์ดของคุณจะมีปุ่มเฉพาะหรือส่ง Right Alt และ Right Ctrl มาแทนปุ่มเหล่านั้นอย่างที่แล็ปท็อปหลายรุ่นทำก็ตาม ดังนั้น Right Alt และ Right Ctrl จึงไม่ใช่ปุ่มปรับแต่งธรรมดาที่นั่น ส่วนการพิมพ์ตามคำบอกจะสลับด้วย Alt + Space แทน `Ctrl + Space` ยังคงพร้อมใช้สำหรับ Tmux และ Herdr ส่วน `Shift + CapsLock` ยังคงเป็นปุ่ม compose

ตัวบ่งชี้คีย์บอร์ดจะปรากฏทางด้านขวาของแถบเมื่อคุณมีเลย์เอาต์คีย์บอร์ดหรือวิธีการป้อนข้อความหลายรายการ คลิกที่มันเพื่อสลับภาษาป้อนข้อความ Japanese จะแสดง あ สำหรับ hiragana สำหรับตัวเลือกตัวอักษร Japanese ให้สลับไปเป็น Japanese พิมพ์คำเช่น `nihongo` จากนั้นกด Space สองครั้ง กด Enter เพื่อยืนยันตัวเลือกของคุณ หากคุณยังมีเลย์เอาต์คีย์บอร์ดหลายรายการด้วย ให้คลิกขวาที่ตัวบ่งชี้เพื่อวนไปตามเลย์เอาต์เหล่านั้น

ใช้ _Setup > Keyboard > Keyboard Inputs_ เพื่อเลือกเลย์เอาต์เช่น English และ French จากตัวเลือกเดียวกันกับที่เสนอในระหว่างการติดตั้ง ใช้ _Setup > Keyboard > Input Methods_ เพื่อเลือกว่าเครื่องมือประกอบข้อความใดกำลังใช้งานอยู่ ตัวเลือกทั้งสองจะเปิดขึ้นภายในเมนู Omarchy พร้อมตัวเลือกปัจจุบันของคุณที่ถูกทำเครื่องหมายไว้ คลิกหรือกด Enter เพื่อสลับตัวเลือก การเปลี่ยนแปลงแต่ละครั้งจะมีผลทันที การยกเลิกการเลือกวิธีการป้อนข้อความจะนำมันออกจากวงจรโดยไม่ถอนการติดตั้ง ส่วนคีย์บอร์ดยังคงพร้อมใช้งานอยู่

รัน `omarchy setup keyboard` หรือ `omarchy setup input` เพื่อเปิดตัวเลือกเดียวกัน หากต้องการเพิ่มภาษาหนึ่งภาษาจากบรรทัดคำสั่ง ให้ใช้ `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` หรือ `cangjie5` ส่วน Quick, Boshiamy และ Array มาอยู่ในแพ็กเกจเดียวกับ Cangjie และปรากฏในตัวเลือก Input Methods ปุ่มสลับที่คุณกำหนดเองจะยังคงถูกเก็บไว้ สำหรับเลย์เอาต์หรือปุ่มของเครื่องมือทางเลือก ให้ติดตั้ง `fcitx5-configtool` ด้วย `omarchy pkg add fcitx5-configtool` และเปิดใช้งานจากเทอร์มินัล การเลือกภาษาป้อนข้อความไม่ได้เปลี่ยนภาษาของเดสก์ท็อป การเลือก Japanese, Korean หรือ Chinese ภายใต้ _Setup > Region > Language_ จะเพิ่มวิธีการป้อนข้อความของภาษานั้นเมื่อคุณยังไม่มีเลย

ใช้ `Super + I` เพื่อวนไปตามวิธีการป้อนข้อความหรือเลย์เอาต์คีย์บอร์ด และ `Super + Shift + I` เพื่อวนกลับไปอีกทาง ดังนั้นเมื่อกำหนดค่าไว้สามรายการ คุณจึงย้ายไปมาระหว่างสองรายการที่อยู่ติดกันได้ ตัวบ่งชี้การป้อนข้อความจะปรากฏทางด้านขวาของแถบเฉพาะเมื่อมีการกำหนดค่าวิธีการป้อนข้อความหรือเลย์เอาต์มากกว่าหนึ่งรายการเท่านั้น ปุ่มลัดบนเดสก์ท็อปนี้ทำงานควบคู่ไปกับปุ่มสลับ Fcitx ที่คุณมีอยู่แล้ว คุณสามารถแทนที่มันได้ใน `~/.config/hypr/bindings.lua` เครื่องมือป้อนข้อความและลำดับ compose ใช้บริการ [Fcitx5](https://fcitx-im.org/) ที่กำลังทำงานอยู่ในทุกเซสชันอยู่แล้ว

### ใช้ ALT เป็น SUPER

บนคีย์บอร์ดบางรุ่น การใช้ปุ่ม meta หลัก (ปุ่ม Windows/cmd) เป็น SUPER นั้นไม่สะดวก คุณสามารถเปลี่ยนให้เป็น ALT แทนได้ด้วยการเปลี่ยนแปลงนี้:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
