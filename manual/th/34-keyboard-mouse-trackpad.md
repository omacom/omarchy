# แป้นพิมพ์ เมาส์ และทัชแพด

Hyprland ให้คุณกำหนดค่าอุปกรณ์อินพุตทั้งหมดได้อย่างละเอียดมาก คุณสามารถเปลี่ยนการทำซ้ำของแป้นพิมพ์ให้เร็วสุดขีด หรือทำให้ทัชแพดใช้การเลื่อนแบบธรรมชาติได้ คุณเปลี่ยนทั้งหมดนี้ได้ใน `~/.config/hypr/input.lua` ซึ่งเข้าถึงได้ผ่าน _Setup > Input_ ในเมนู Omarchy (`Super + Space`) เช่นกัน สิ่งใดก็ตามที่คุณตั้งไว้ที่นั่นจะแทนที่ค่าเริ่มต้นของ Omarchy

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

คุณสามารถ [ดูตัวเลือกอินพุตทั้งหมด](https://wiki.hypr.land/Configuring/Basics/Variables/#input) ได้ที่ wiki ของ Hyprland สำหรับอินพุต

CapsLock ทำงานเป็น Caps Lock ปกติ และ `Shift + CapsLock` เป็นแป้น compose สำหรับ [อีโมจิด่วน](07-hotkeys.md#quick-emojis) และ [การเติมข้อความอื่นๆ](07-hotkeys.md#quick-completions) หากคุณอยากให้แป้น compose อยู่ที่อื่น ให้แทนที่ `omarchy:shift_caps_compose` ใน `kb_options` ตัวอย่างเช่น โค้ดนี้ย้ายแป้น compose ไปที่ Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### ท่าทางบนทัชแพด

ปัดบนทัชแพดเพื่อเคลื่อนที่ไปรอบๆ เดสก์ท็อป:

| ท่าทาง | การทำงาน |
| --- | --- |
| สามนิ้วไปทางซ้าย / ขวา | workspace ก่อนหน้า / ถัดไป รวมถึง workspace ว่าง |
| สามนิ้วขึ้น | สลับเปิด/ปิดคอนโซล AI |
| สามนิ้วลง | เปิดเมนู Omarchy |
| สี่นิ้วไปทางซ้าย / ขวา | ย้ายหน้าต่างที่ใช้งานอยู่ไปยัง workspace ก่อนหน้า / ถัดไป |
| สี่นิ้วลง | สลับโหมดเต็มหน้าจอ |

หากต้องการเปลี่ยนท่าทางใด ให้ยกเลิกการตั้งค่าท่าทางนั้นใน `~/.config/hypr/input.lua` ก่อนเพิ่ม [ท่าทางบนทัชแพด](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) ของคุณเอง เนื่องจาก Hyprland จะไม่รับสองท่าทางที่ใช้จำนวนนิ้วและทิศทางเดียวกัน:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

หากต้องการปิดท่าทางทั้งหมดของ Omarchy ให้ตั้งค่า `omarchy_default_gestures = false` ใกล้ด้านบนของ `~/.config/hypr/hyprland.lua` ก่อนที่ค่าเริ่มต้นของ Omarchy จะโหลด

บนแล็ปท็อป Dell XPS ที่มีทัชแพดแบบ haptic คุณยังสามารถตั้งค่าแรงคลิกเป็น low, mid หรือ high ได้ที่ _Trigger > Hardware > Touchpad Haptics_

### การพิมพ์ภาษาจีน ภาษาญี่ปุ่น และภาษาอื่นๆ

เลือก Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin) หรือ Hong Kong (Cangjie) เมื่อตัวติดตั้งถามเกี่ยวกับแป้นพิมพ์ของคุณ Omarchy จะกำหนดค่าแป้นพิมพ์และเอนจินอินพุตที่ตรงกันโดยอัตโนมัติ รวมถึงระหว่างการตั้งค่าครั้งแรกแบบออฟไลน์ Japanese ใช้ Mozc, Korean ใช้ Hangul แบบ two-set มาตรฐาน, Simplified Chinese ใช้ Pinyin, Taiwan ใช้การจัดวาง Zhuyin มาตรฐานของ Chewing และ Hong Kong ใช้ Cangjie พร้อมรูปแบบตัวอักษรของ Hong Kong Japanese (US keyboard) ให้ Mozc พร้อมเลย์เอาต์แป้นพิมพ์แบบ US แป้น Hangul, Zhuyin และ Cangjie จะอยู่ในตำแหน่งมาตรฐานเดิม แม้ว่าคุณจะพิมพ์ตัวอักษร Latin ด้วย Dvorak, Colemak หรือ AZERTY หากคุณเคยเพิ่ม Hangul หรือ Chewing ไว้ก่อนหน้านี้ ให้ยกเลิกการเลือกแล้วเลือกใหม่อีกครั้งที่ _Setup > Typing > Input Methods_ เพื่อย้ายแป้นของมันไปไว้ที่นั่น โดย Omarchy จะไม่ยุ่งกับเอนจินที่คุณใช้พิมพ์อยู่แล้ว

การพิมพ์จะเริ่มต้นในโหมด Latin กด `Super + I` เพื่อวนผ่านวิธีป้อนข้อมูลที่กำหนดค่าไว้ และ `Super + Shift + I` เพื่อวนย้อนกลับ แตะ `Shift` เพียงอย่างเดียวเพื่อออกจากวิธีป้อนข้อมูลอย่าง Pinyin ไปเป็นตัวอักษร Latin และแตะอีกครั้งเพื่อกลับไป แบบเดียวกับที่ Sogou, Microsoft Pinyin และ macOS ทำงาน ส่วน `Shift` พร้อมตัวอักษรยังคงพิมพ์ตัวพิมพ์ใหญ่ บนแป้นพิมพ์ Japanese แป้น 全角/半角 จะสลับอินพุต แป้น 変換 จะเปิดใช้งาน และแป้น 無変換 จะปิดใช้งาน สำหรับ Korean แป้น 한/영 จะสลับ Hangul และแป้น 한자 จะแปลงเป็น Hanja ไม่ว่าแป้นพิมพ์ของคุณจะมีแป้นเฉพาะหรือส่ง Right Alt และ Right Ctrl มาแทน อย่างที่แล็ปท็อปหลายเครื่องทำ ดังนั้น Right Alt และ Right Ctrl จึงไม่ใช่แป้นปรับแต่งธรรมดาที่นั่น การสั่งงานด้วยเสียงจะสลับด้วย Alt + Space แทน `Ctrl + Space` ยังคงใช้ได้สำหรับ Tmux และ Herdr ส่วน `Shift + CapsLock` ยังคงเป็นแป้น compose

ตัวบ่งชี้แป้นพิมพ์จะปรากฏทางด้านขวาของแถบเมื่อคุณมีเลย์เอาต์แป้นพิมพ์หรือวิธีป้อนข้อมูลหลายแบบ คลิกที่ตัวบ่งชี้นั้นเพื่อสลับภาษาอินพุต โดย Japanese จะแสดง あ สำหรับ hiragana สำหรับตัวเลือกตัวอักษร Japanese ให้สลับไปเป็น Japanese พิมพ์คำอย่าง `nihongo` แล้วกด Space สองครั้ง กด Enter เพื่อยืนยันตัวเลือกของคุณ หากคุณมีเลย์เอาต์แป้นพิมพ์หลายแบบด้วย ให้คลิกขวาที่ตัวบ่งชี้เพื่อวนผ่านเลย์เอาต์เหล่านั้น

ใช้ _Setup > Typing > Keyboard Layouts_ เพื่อเลือกเลย์เอาต์ เช่น English และ French จากตัวเลือกเดียวกันกับที่เสนอระหว่างการติดตั้ง ใช้ _Setup > Typing > Input Methods_ เพื่อเลือกว่าเอนจินการประกอบตัวอักษรใดทำงานอยู่ ตัวเลือกทั้งสองจะเปิดภายในเมนู Omarchy พร้อมเครื่องหมายถูกที่ตัวเลือกปัจจุบันของคุณ คลิกหรือกด Enter เพื่อสลับตัวเลือก โดยการเปลี่ยนแปลงแต่ละครั้งจะมีผลทันที การยกเลิกการเลือกวิธีป้อนข้อมูลจะนำวิธีนั้นออกจากวงจรโดยไม่ถอนการติดตั้ง แป้นพิมพ์จะยังคงใช้งานได้

เรียกใช้ `omarchy setup keyboard` หรือ `omarchy setup input` เพื่อเปิดตัวเลือกเดียวกัน หากต้องการเพิ่มภาษาเดียวจากบรรทัดคำสั่ง ให้ใช้ `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` หรือ `cangjie5` Quick, Boshiamy และ Array มาอยู่ในแพ็กเกจเดียวกับ Cangjie และจะปรากฏในตัวเลือก Input Methods แป้นสลับแบบกำหนดเองของคุณจะยังคงอยู่ สำหรับเลย์เอาต์หรือแป้นของเอนจินทางเลือก ให้ติดตั้ง `fcitx5-configtool` ด้วย `omarchy pkg add fcitx5-configtool` แล้วเปิดใช้งานจากเทอร์มินัล การเลือกภาษาอินพุตจะไม่เปลี่ยนภาษาของเดสก์ท็อป การเลือก Japanese, Korean หรือ Chinese ที่ _Setup > Language_ จะเพิ่มวิธีป้อนข้อมูลของภาษานั้นเมื่อคุณยังไม่มีวิธีป้อนข้อมูลใดเลย

ใช้ `Super + I` เพื่อวนผ่านวิธีป้อนข้อมูลหรือเลย์เอาต์แป้นพิมพ์ และใช้ `Super + Shift + I` เพื่อย้อนกลับไปอีกทาง ดังนั้นเมื่อกำหนดค่าไว้สามแบบ คุณจึงสามารถเคลื่อนที่ระหว่างสองแบบที่อยู่ติดกันได้ ตัวบ่งชี้อินพุตจะปรากฏทางด้านขวาของแถบเฉพาะเมื่อมีการกำหนดวิธีป้อนข้อมูลหรือเลย์เอาต์มากกว่าหนึ่งแบบเท่านั้น การผูกแป้นบนเดสก์ท็อปนี้ทำงานควบคู่ไปกับแป้นสลับ Fcitx ที่มีอยู่ของคุณ โดยคุณสามารถแทนที่ได้ใน `~/.config/hypr/bindings.lua` เอนจินอินพุตและลำดับ compose ใช้บริการ [Fcitx5](https://fcitx-im.org/) ที่ทำงานอยู่แล้วในทุกเซสชัน

### ใช้ ALT เป็น SUPER

บนแป้นพิมพ์บางรุ่น การใช้แป้น meta หลัก (แป้น Windows/cmd) เป็น SUPER ไม่สะดวกนัก คุณสามารถเปลี่ยนให้ใช้ ALT แทนได้ด้วยการเปลี่ยนแปลงนี้:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
