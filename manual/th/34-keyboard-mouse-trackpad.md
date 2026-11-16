# คีย์บอร์ด, เมาส์, แทร็กแพด

Hyprland ให้คุณกำหนดค่าอุปกรณ์อินพุตทั้งหมดได้อย่างละเอียดมาก คุณสามารถเปลี่ยนการทำซ้ำของคีย์บอร์ดให้เร็วเหนือเสียง หรือทำให้แทร็กแพดใช้การเลื่อนแบบธรรมชาติ คุณเปลี่ยนทั้งหมดได้ใน `~/.config/hypr/input.lua` ซึ่งเข้าได้ผ่าน _Setup > Input_ ในเมนู Omarchy (`Super + Space`) เช่นกัน สิ่งใดก็ตามที่คุณตั้งไว้ที่นั่นจะแทนที่ค่าเริ่มต้นของ Omarchy

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

คุณสามารถ [ดูตัวเลือกอินพุตทั้งหมด](https://wiki.hypr.land/Configuring/Basics/Variables/#input) บน wiki ของ Hyprland สำหรับอินพุต

CapsLock ทำงานเป็น Caps Lock ปกติ และ `Shift + CapsLock` เป็นปุ่ม compose สำหรับ [อิโมจิด่วน](07-hotkeys.md#quick-emojis) และ [การเติมข้อความอื่นๆ](07-hotkeys.md#quick-completions) หากคุณอยากให้ปุ่ม compose อยู่ที่อื่นแทน ให้แทนที่ `omarchy:shift_caps_compose` ใน `kb_options` ตัวอย่างเช่น โค้ดนี้ย้ายปุ่ม compose ไปที่ Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### ปุ่มฟังก์ชัน

แถวบนสุดของคีย์บอร์ดแล็ปท็อปจะส่งปุ่มมีเดีย (ระดับเสียง ความสว่าง และอื่นๆ) เป็นค่าเริ่มต้น และการกด `Fn` ค้างไว้จะให้ F1-F12; `Fn + Esc` จะล็อกสลับไปอีกทางจนกว่าคุณจะกดมันอีกครั้ง คีย์บอร์ดส่วนใหญ่จดจำสถานะล็อกนั้นไว้เอง แล็ปท็อป ASUS และคีย์บอร์ดสไตล์ Apple ปล่อยเรื่องนี้ให้ Linux ซึ่งจะเริ่มด้วยปุ่มมีเดียทุกครั้งที่บูต หากต้องการให้เริ่มด้วย F1-F12 แทน ให้รัน `omarchy keyboard toprow fnkeys` (และ `omarchy keyboard toprow mediakeys` เพื่อกลับไป); ในแล็ปท็อปบางเครื่องจะมีผลหลังรีบูต Mac ที่ใช้ Apple Silicon จะคงการตั้งค่าของตัวเองไว้

### ท่าทางบนแทร็กแพด

ปัดบนแทร็กแพดเพื่อเลื่อนไปรอบๆ เดสก์ท็อป:

| ท่าทาง | การทำงาน |
| --- | --- |
| สามนิ้วไปซ้าย / ขวา | Workspace ก่อนหน้า / ถัดไป รวมถึง workspace ที่ว่างอยู่ |
| สามนิ้วขึ้น | เปิด/ปิดคอนโซล AI |
| สามนิ้วลง | เปิดเมนู Omarchy |
| สี่นิ้วไปซ้าย / ขวา | ย้ายหน้าต่างที่ใช้งานอยู่ไปยัง workspace ก่อนหน้า / ถัดไป |
| สี่นิ้วลง | เปิด/ปิดเต็มหน้าจอ |

หากต้องการเปลี่ยนท่าทางใด ให้ยกเลิกการตั้งค่าของมันใน `~/.config/hypr/input.lua` ก่อนเพิ่ม [ท่าทางบนทัชแพด](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) ของคุณเอง เนื่องจาก Hyprland จะไม่รับสองท่าทางที่ใช้จำนวนนิ้วและทิศทางเดียวกัน:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

หากต้องการปิดท่าทางทั้งหมดของ Omarchy ให้ตั้ง `omarchy_default_gestures = false` ใกล้ด้านบนของ `~/.config/hypr/hyprland.lua` ก่อนที่ค่าเริ่มต้นของ Omarchy จะโหลด

บนแล็ปท็อป Dell XPS ที่มีทัชแพดแบบ haptic คุณยังตั้งความแรงของการคลิกเป็น low, mid หรือ high ได้ใน _Trigger > Hardware > Touchpad Haptics_

### การพิมพ์ภาษาจีน ญี่ปุ่น และภาษาอื่นๆ

เลือก Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin) หรือ Hong Kong (Cangjie) เมื่อโปรแกรมติดตั้งถามหาคีย์บอร์ดของคุณ Omarchy จะกำหนดค่าคีย์บอร์ดและเอนจินการป้อนข้อมูลที่ตรงกันให้โดยอัตโนมัติ รวมถึงระหว่างการตั้งค่าครั้งแรกแบบออฟไลน์ตอนบูตครั้งแรกด้วย ภาษาญี่ปุ่นใช้ Mozc, ภาษาเกาหลีใช้ Hangul แบบสองชุดมาตรฐาน, ภาษาจีนตัวย่อใช้ Pinyin, ไต้หวันใช้รูปแบบ Zhuyin มาตรฐานของ Chewing และฮ่องกงใช้ Cangjie พร้อมรูปอักษรแบบฮ่องกง Japanese (US keyboard) ให้ Mozc พร้อมเลย์เอาต์คีย์บอร์ด US ปุ่ม Hangul, Zhuyin และ Cangjie ยังคงอยู่ในตำแหน่งมาตรฐาน แม้ว่าคุณจะพิมพ์ตัวอักษรละตินด้วย Dvorak, Colemak หรือ AZERTY ก็ตาม หากคุณเคยเพิ่ม Hangul หรือ Chewing ไว้ก่อนหน้านี้ ให้ยกเลิกการเลือกแล้วเลือกใหม่ใน _Setup > Keyboard > Input Methods_ เพื่อย้ายปุ่มของมันไปไว้ที่นั่น; Omarchy จะไม่แตะต้องเอนจินที่คุณใช้พิมพ์อยู่แล้ว

การพิมพ์จะเริ่มในโหมดละติน กด `Super + I` เพื่อวนผ่านวิธีป้อนข้อมูลที่กำหนดค่าไว้ และ `Super + Shift + I` เพื่อวนย้อนกลับ แตะ `Shift` อย่างเดียวเพื่อก้าวออกจากวิธีป้อนข้อมูลเช่น Pinyin ไปสู่ตัวอักษรละติน และแตะอีกครั้งเพื่อกลับไป แบบเดียวกับที่ Sogou, Microsoft Pinyin และ macOS ทำงาน; `Shift` พร้อมตัวอักษรยังคงพิมพ์ตัวพิมพ์ใหญ่ บนคีย์บอร์ดภาษาญี่ปุ่น 全角/半角 จะสลับการป้อนข้อมูล 変換 จะเปิดใช้งาน และ 無変換 จะปิดใช้งาน ด้วยภาษาเกาหลี 한/영 จะสลับ Hangul และ 한자 จะแปลงเป็น Hanja ไม่ว่าคีย์บอร์ดของคุณจะมีปุ่มเฉพาะหรือส่ง Right Alt และ Right Ctrl มาแทนอย่างที่แล็ปท็อปหลายเครื่องทำ ดังนั้น Right Alt และ Right Ctrl จึงไม่ใช่ปุ่ม modifier ธรรมดาที่นั่น; การพิมพ์ตามคำบอกจะสลับด้วย Alt + Space แทน `Ctrl + Space` ยังคงใช้ได้สำหรับ Tmux และ Herdr; `Shift + CapsLock` ยังคงเป็นปุ่ม compose

ตัวบ่งชี้คีย์บอร์ดจะปรากฏทางขวาของแถบเมื่อคุณมีเลย์เอาต์คีย์บอร์ดหรือวิธีป้อนข้อมูลหลายแบบ คลิกที่ตัวบ่งชี้เพื่อสลับภาษาป้อนข้อมูล; ภาษาญี่ปุ่นจะแสดง あ สำหรับ hiragana สำหรับตัวเลือกอักษรภาษาญี่ปุ่น ให้สลับไปเป็นภาษาญี่ปุ่น พิมพ์คำเช่น `nihongo` แล้วกด Space สองครั้ง กด Enter เพื่อยอมรับตัวเลือกของคุณ หากคุณมีเลย์เอาต์คีย์บอร์ดหลายแบบด้วย ให้คลิกขวาที่ตัวบ่งชี้เพื่อวนผ่านเลย์เอาต์เหล่านั้น

ใช้ _Setup > Keyboard > Keyboard Inputs_ เพื่อเลือกเลย์เอาต์เช่น English และ French จากตัวเลือกเดียวกับที่เสนอระหว่างการติดตั้ง ใช้ _Setup > Keyboard > Input Methods_ เพื่อเลือกว่าเอนจินการประกอบข้อความใดทำงานอยู่ ตัวเลือกทั้งสองจะเปิดภายในเมนู Omarchy โดยตัวเลือกปัจจุบันของคุณจะมีเครื่องหมายถูกไว้ คลิกหรือกด Enter เพื่อสลับตัวเลือก; การเปลี่ยนแปลงแต่ละครั้งจะมีผลทันที การยกเลิกการเลือกวิธีป้อนข้อมูลจะนำมันออกจากวงจรการสลับโดยไม่ถอนการติดตั้ง; คีย์บอร์ดยังคงใช้งานได้

รัน `omarchy setup keyboard` หรือ `omarchy setup input` เพื่อเปิดตัวเลือกเดียวกัน หากต้องการเพิ่มหนึ่งภาษาจากบรรทัดคำสั่ง ให้ใช้ `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` หรือ `cangjie5` Quick, Boshiamy และ Array มาอยู่ในแพ็กเกจเดียวกับ Cangjie และจะปรากฏในตัวเลือก Input Methods ปุ่มสลับแบบกำหนดเองของคุณจะถูกเก็บไว้ สำหรับเลย์เอาต์หรือปุ่มของเอนจินแบบอื่น ให้ติดตั้ง `fcitx5-configtool` ด้วย `omarchy pkg add fcitx5-configtool` และเปิดมันจากเทอร์มินัล การเลือกภาษาป้อนข้อมูลจะไม่เปลี่ยนภาษาของเดสก์ท็อป การเลือก Japanese, Korean หรือ Chinese ใน _Setup > Language_ จะเพิ่มวิธีป้อนข้อมูลของภาษานั้นเมื่อคุณยังไม่มีเลย

ใช้ `Super + I` เพื่อวนผ่านวิธีป้อนข้อมูลหรือเลย์เอาต์คีย์บอร์ด และ `Super + Shift + I` เพื่อย้อนกลับไปอีกทาง ดังนั้นเมื่อกำหนดค่าไว้สามแบบ คุณจึงเลื่อนไปมาระหว่างสองแบบที่อยู่ติดกันได้ ตัวบ่งชี้การป้อนข้อมูลจะปรากฏทางขวาของแถบเฉพาะเมื่อมีการกำหนดวิธีป้อนข้อมูลหรือเลย์เอาต์มากกว่าหนึ่งแบบเท่านั้น การผูกปุ่มบนเดสก์ท็อปนี้ทำงานควบคู่กับปุ่มสลับ Fcitx ที่มีอยู่ของคุณ; คุณสามารถแทนที่มันได้ใน `~/.config/hypr/bindings.lua` เอนจินการป้อนข้อมูลและลำดับ compose ใช้บริการ [Fcitx5](https://fcitx-im.org/) ที่ทำงานอยู่แล้วในทุกเซสชัน

### ใช้ ALT เป็น SUPER

บนคีย์บอร์ดบางรุ่น การใช้ปุ่ม meta หลัก (ปุ่ม Windows/cmd) เป็น SUPER นั้นไม่สะดวก คุณสามารถเปลี่ยนให้เป็น ALT แทนได้ด้วยการเปลี่ยนแปลงนี้:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
