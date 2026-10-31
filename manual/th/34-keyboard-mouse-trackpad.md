# คีย์บอร์ด, เมาส์, แทร็กแพด

Hyprland ให้คุณกำหนดค่าอุปกรณ์อินพุตทั้งหมดได้ในรายละเอียดอย่างมาก คุณสามารถเปลี่ยนการทำซ้ำของคีย์บอร์ดให้เร็วเหนือเสียง หรือทำให้แทร็กแพดใช้การเลื่อนแบบธรรมชาติได้ คุณเปลี่ยนทั้งหมดนี้ได้ใน `~/.config/hypr/input.lua` ซึ่งคุณสามารถเข้าถึงได้ผ่าน _Setup > Input_ ในเมนู Omarchy (`Super + Space`) ด้วย สิ่งใดก็ตามที่คุณตั้งไว้ที่นั่นจะแทนที่ค่าเริ่มต้นของ Omarchy

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

คุณสามารถ[ดูตัวเลือกอินพุตทั้งหมด](https://wiki.hypr.land/Configuring/Basics/Variables/#input)ได้บนวิกิ Hyprland สำหรับอินพุต

CapsLock ทำงานเป็น Caps Lock ปกติ และ `Shift + CapsLock` เป็น compose key สำหรับ[อิโมจิด่วน](07-hotkeys.md#quick-emojis)และ[การเติมข้อความด่วนอื่นๆ](07-hotkeys.md#quick-completions) หากคุณอยากให้ compose key อยู่ตำแหน่งอื่น ให้แทนที่ `omarchy:shift_caps_compose` ใน `kb_options` ตัวอย่างเช่น โค้ดนี้ย้าย compose key ไปที่ Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### ท่าทางบนแทร็กแพด

ปัดบนแทร็กแพดเพื่อเคลื่อนที่ไปรอบๆ เดสก์ท็อป:

| Gesture | Action |
| --- | --- |
| สามนิ้วไปทางซ้าย / ขวา | Workspace ก่อนหน้า / ถัดไป รวมถึง workspace ที่ว่างเปล่าด้วย |
| สามนิ้วขึ้น | สลับคอนโซล AI |
| สามนิ้วลง | เปิดเมนู Omarchy |
| สี่นิ้วไปทางซ้าย / ขวา | ย้ายหน้าต่างที่ใช้งานอยู่ไปยัง workspace ก่อนหน้า / ถัดไป |
| สี่นิ้วลง | สลับโหมดเต็มหน้าจอ |

หากต้องการเปลี่ยนท่าทางใดท่าทางหนึ่ง ให้ unset ท่าทางนั้นใน `~/.config/hypr/input.lua` ก่อน แล้วจึงเพิ่ม[ท่าทางบนทัชแพด](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/)ของคุณเอง เนื่องจาก Hyprland จะไม่ยอมรับสองท่าทางบนจำนวนนิ้วและทิศทางเดียวกัน:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

หากต้องการปิดท่าทางทั้งหมดของ Omarchy ให้ตั้งค่า `omarchy_default_gestures = false` ใกล้กับด้านบนของ `~/.config/hypr/hyprland.lua` ก่อนที่ค่าเริ่มต้นของ Omarchy จะโหลด

บนแล็ปท็อป Dell XPS ที่มีทัชแพดแบบ haptic คุณยังสามารถตั้งค่าความแรงของการคลิกเป็นต่ำ กลาง หรือสูงได้ภายใต้ _Trigger > Hardware > Touchpad Haptics_

### การพิมพ์ภาษาจีน ญี่ปุ่น และภาษาอื่นๆ

เลือก Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin) หรือ Hong Kong (Cangjie) เมื่อตัวติดตั้งถามเกี่ยวกับคีย์บอร์ดของคุณ Omarchy จะกำหนดค่าคีย์บอร์ดและเอนจินอินพุตที่ตรงกันให้โดยอัตโนมัติ รวมถึงในระหว่างการตั้งค่าครั้งแรกแบบออฟไลน์ด้วย Japanese ใช้ Mozc, Korean ใช้ Hangul แบบสองชุดมาตรฐาน, Simplified Chinese ใช้ Pinyin, Taiwan ใช้รูปแบบ Zhuyin มาตรฐานของ Chewing และ Hong Kong ใช้ Cangjie พร้อมรูปแบบตัวอักษรของ Hong Kong ส่วน Japanese (US keyboard) ให้ Mozc พร้อมเลย์เอาต์คีย์บอร์ด US ปุ่ม Hangul, Zhuyin และ Cangjie จะยังคงอยู่ในตำแหน่งมาตรฐาน แม้ว่าคุณจะพิมพ์ตัวอักษร Latin ด้วย Dvorak, Colemak หรือ AZERTY ก็ตาม หากคุณเคยเพิ่ม Hangul หรือ Chewing ไว้ก่อนหน้านี้ ให้ยกเลิกการเลือกแล้วเลือกใหม่ภายใต้ _Setup > Typing > Input Methods_ เพื่อย้ายปุ่มของมันไปยังตำแหน่งเหล่านั้น Omarchy จะไม่แตะต้องเอนจินที่คุณกำลังพิมพ์อยู่แล้ว

การพิมพ์จะเริ่มต้นในโหมด Latin กด `Super + I` เพื่อวนผ่านวิธีป้อนข้อมูลที่กำหนดค่าไว้ และกด `Super + Shift + I` เพื่อวนย้อนกลับ แตะ `Shift` เพียงอย่างเดียวเพื่อก้าวออกจากวิธีป้อนข้อมูลอย่าง Pinyin ไปเป็นตัวอักษร Latin และแตะอีกครั้งเพื่อกลับไป แบบเดียวกับที่ Sogou, Microsoft Pinyin และ macOS ทำงาน `Shift` พร้อมกับตัวอักษรยังคงพิมพ์ตัวพิมพ์ใหญ่ บนคีย์บอร์ด Japanese ปุ่ม 全角/半角 จะสลับการป้อนข้อมูล 変換 จะเปิดใช้งาน และ 無変換 จะปิดใช้งาน สำหรับ Korean ปุ่ม 한/영 จะสลับ Hangul และ 한자 จะแปลงเป็น Hanja ไม่ว่าคีย์บอร์ดของคุณจะมีปุ่มเฉพาะ หรือส่ง Right Alt และ Right Ctrl มาแทนสำหรับปุ่มเหล่านั้น อย่างที่แล็ปท็อปหลายเครื่องทำ ดังนั้น Right Alt และ Right Ctrl จึงไม่ใช่ modifier ธรรมดาที่นั่น ฟีเจอร์ push-to-talk สำหรับการเขียนตามคำบอกยังคงอยู่ที่ F9 ส่วน `Ctrl + Space` ยังคงพร้อมใช้งานสำหรับ Tmux และ Herdr และ `Shift + CapsLock` ยังคงเป็น compose key

ตัวบ่งชี้คีย์บอร์ดจะปรากฏทางด้านขวาของแถบเมื่อคุณมีเลย์เอาต์คีย์บอร์ดหรือวิธีป้อนข้อมูลหลายรายการ คลิกที่ตัวบ่งชี้นั้นเพื่อสลับภาษาอินพุต สำหรับ Japanese จะแสดง あ สำหรับ hiragana สำหรับตัวเลือกตัวอักษร Japanese ให้สลับไปเป็น Japanese พิมพ์คำอย่างเช่น `nihongo` แล้วกด Space สองครั้ง กด Enter เพื่อยอมรับตัวเลือกของคุณ หากคุณมีเลย์เอาต์คีย์บอร์ดหลายรายการด้วย ให้คลิกขวาที่ตัวบ่งชี้เพื่อวนผ่านเลย์เอาต์เหล่านั้น

ใช้ _Setup > Typing > Keyboard Layouts_ เพื่อเลือกเลย์เอาต์อย่าง English และ French จากตัวเลือกเดียวกับที่เสนอในระหว่างการติดตั้ง ใช้ _Setup > Typing > Input Methods_ เพื่อเลือกว่าเอนจินการประกอบตัวอักษรใดกำลังใช้งานอยู่ ตัวเลือกทั้งสองจะเปิดภายในเมนู Omarchy พร้อมกับเครื่องหมายถูกที่ตัวเลือกปัจจุบันของคุณ คลิกหรือกด Enter เพื่อสลับตัวเลือก การเปลี่ยนแปลงแต่ละครั้งจะมีผลทันที การยกเลิกการเลือกวิธีป้อนข้อมูลจะนำมันออกจากวงจรการสลับโดยไม่ถอนการติดตั้ง คีย์บอร์ดยังคงพร้อมใช้งานอยู่

เรียกใช้ `omarchy setup keyboard` หรือ `omarchy setup input` เพื่อเปิดตัวเลือกเดียวกัน หากต้องการเพิ่มภาษาเดียวจากบรรทัดคำสั่ง ให้ใช้ `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` หรือ `cangjie5` ส่วน Quick, Boshiamy และ Array มาอยู่ในแพ็กเกจเดียวกับ Cangjie และจะปรากฏในตัวเลือก Input Methods ปุ่มสลับแบบกำหนดเองของคุณจะยังคงอยู่ สำหรับเลย์เอาต์หรือปุ่มของเอนจินทางเลือก ให้ติดตั้ง `fcitx5-configtool` ด้วย `omarchy pkg add fcitx5-configtool` แล้วเปิดใช้งานจากเทอร์มินัล การเลือกภาษาอินพุตจะไม่เปลี่ยนภาษาของเดสก์ท็อป การเลือก Japanese, Korean หรือ Chinese ภายใต้ _Setup > Language_ จะเพิ่มวิธีป้อนข้อมูลของภาษานั้นเมื่อคุณยังไม่มีวิธีป้อนข้อมูลใดๆ เลย

ใช้ `Super + I` เพื่อวนผ่านวิธีป้อนข้อมูลหรือเลย์เอาต์คีย์บอร์ด และใช้ `Super + Shift + I` เพื่อกลับไปในทิศทางอื่น ดังนั้นเมื่อคุณกำหนดค่าไว้สามรายการ คุณจึงสามารถเคลื่อนที่ระหว่างสองรายการที่อยู่ติดกันได้ ตัวบ่งชี้อินพุตจะปรากฏทางด้านขวาของแถบเฉพาะเมื่อมีการกำหนดค่าวิธีป้อนข้อมูลหรือเลย์เอาต์ไว้มากกว่าหนึ่งรายการเท่านั้น การผูกปุ่มบนเดสก์ท็อปนี้ทำงานควบคู่ไปกับปุ่มสลับ Fcitx ที่มีอยู่ของคุณ คุณสามารถแทนที่มันได้ใน `~/.config/hypr/bindings.lua` เอนจินอินพุตและลำดับ compose ใช้บริการ [Fcitx5](https://fcitx-im.org/) ที่ทำงานอยู่แล้วในทุกเซสชัน

### ใช้ ALT เป็น SUPER

บนคีย์บอร์ดบางรุ่น การใช้ปุ่ม meta หลัก (ปุ่ม Windows/cmd) เป็น SUPER ไม่สะดวกนัก คุณสามารถเปลี่ยนให้เป็น ALT แทนได้ด้วยการเปลี่ยนแปลงนี้:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
