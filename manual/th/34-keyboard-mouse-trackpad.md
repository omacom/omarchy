# แป้นพิมพ์ เมาส์ และแทร็กแพด

Hyprland ให้คุณกำหนดค่าอุปกรณ์รับข้อมูลทั้งหมดได้อย่างละเอียดมาก คุณเปลี่ยนอัตราการซ้ำของแป้นพิมพ์ให้เร็วเหนือเสียงก็ได้ หรือให้แทร็กแพดใช้การเลื่อนแบบธรรมชาติก็ได้ คุณเปลี่ยนทั้งหมดนี้ได้ใน `~/.config/hypr/input.lua` ซึ่งเข้าถึงได้ผ่าน _Setup > Input_ ในเมนู Omarchy (`Super + Space`) เช่นกัน ค่าใด ๆ ที่คุณตั้งไว้ที่นั่นจะแทนที่ค่าเริ่มต้นของ Omarchy

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

คุณสามารถ [ดูตัวเลือกการรับข้อมูลทั้งหมด](https://wiki.hypr.land/Configuring/Basics/Variables/#input) ได้ใน wiki ของ Hyprland สำหรับการรับข้อมูล

CapsLock ทำงานเป็น Caps Lock ปกติ และ `Shift + CapsLock` เป็นแป้น compose สำหรับ [อิโมจิด่วน](07-hotkeys.md#quick-emojis) และ [การเติมข้อความด่วนอื่น ๆ](07-hotkeys.md#quick-completions) หากคุณอยากให้แป้น compose อยู่ที่อื่น ให้แทนที่ `omarchy:shift_caps_compose` ใน `kb_options` ตัวอย่างเช่น โค้ดนี้ย้ายแป้น compose ไปที่ Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### ท่าทางบนแทร็กแพด

คุณยังเปิดใช้ [ท่าทางบนทัชแพด](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) ได้เช่นกัน เช่น การปัดสามนิ้วเพื่อเปลี่ยน workspace:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

บนแล็ปท็อป Dell XPS ที่มีทัชแพดแบบ haptic คุณยังตั้งความแรงของการคลิกเป็น low, mid หรือ high ได้ภายใต้ _Trigger > Hardware > Touchpad Haptics_

### การพิมพ์ภาษาจีน ญี่ปุ่น และภาษาอื่น ๆ

เลือก Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin) หรือ Hong Kong (Cangjie) เมื่อโปรแกรมติดตั้งถามถึงแป้นพิมพ์ของคุณ Omarchy กำหนดค่าแป้นพิมพ์และเครื่องมือป้อนข้อมูลที่ตรงกันให้โดยอัตโนมัติ รวมถึงระหว่างการตั้งค่าเมื่อบูตครั้งแรกแบบออฟไลน์ด้วย Japanese ใช้ Mozc, Korean ใช้ Hangul มาตรฐานแบบสองชุด, Simplified Chinese ใช้ Pinyin, Taiwan ใช้การจัดวาง Zhuyin มาตรฐานของ Chewing และ Hong Kong ใช้ Cangjie พร้อมรูปตัวอักษรของ Hong Kong ส่วน Japanese (US keyboard) ให้ Mozc พร้อมเค้าโครงแป้นพิมพ์ US แป้น Hangul, Zhuyin และ Cangjie ยังคงอยู่ในตำแหน่งมาตรฐาน แม้คุณจะพิมพ์ตัวอักษรละตินด้วย Dvorak, Colemak หรือ AZERTY ก็ตาม หากคุณเคยเพิ่ม Hangul หรือ Chewing ก่อนหน้านี้ ให้ยกเลิกการเลือกแล้วเลือกอีกครั้งภายใต้ _Setup > Typing > Input Methods_ เพื่อย้ายแป้นของมันไปที่นั่น Omarchy จะไม่ยุ่งกับเครื่องมือที่คุณใช้พิมพ์อยู่แล้ว

การพิมพ์จะเริ่มในโหมดละติน กด `Super + I` เพื่อสลับวนผ่านวิธีป้อนข้อมูลที่กำหนดค่าไว้ และ `Super + Shift + I` เพื่อสลับวนย้อนกลับ แตะ `Shift` เพียงอย่างเดียวเพื่อออกจากวิธีป้อนข้อมูลอย่าง Pinyin ไปสู่ตัวอักษรละติน และแตะอีกครั้งเพื่อกลับไป แบบเดียวกับที่ Sogou, Microsoft Pinyin และ macOS ทำงาน `Shift` บวกตัวอักษรยังคงพิมพ์ตัวพิมพ์ใหญ่ บนแป้นพิมพ์ Japanese แป้น 全角/半角 จะสลับการป้อนข้อมูล 変換 จะเปิดใช้งาน และ 無変換 จะปิดใช้งาน สำหรับ Korean แป้น 한/영 จะสลับ Hangul และ 한자 จะแปลงเป็น Hanja ไม่ว่าแป้นพิมพ์ของคุณจะมีแป้นเฉพาะ หรือส่ง Right Alt และ Right Ctrl มาแทน อย่างที่แล็ปท็อปหลายเครื่องทำ ดังนั้น Right Alt และ Right Ctrl จึงไม่ใช่แป้น modifier ธรรมดาที่นั่น การสั่งงานด้วยเสียงแบบ push-to-talk ยังคงอยู่ที่ F9 `Ctrl + Space` ยังคงพร้อมใช้สำหรับ Tmux และ Herdr `Shift + CapsLock` ยังคงเป็นแป้น compose

ตัวบ่งชี้แป้นพิมพ์จะปรากฏทางด้านขวาของแถบเมื่อคุณมีเค้าโครงแป้นพิมพ์หรือวิธีป้อนข้อมูลหลายแบบ คลิกที่มันเพื่อสลับภาษาป้อนข้อมูล Japanese จะแสดง あ สำหรับ hiragana สำหรับตัวเลือกตัวอักษร Japanese ให้สลับไปเป็น Japanese พิมพ์คำอย่างเช่น `nihongo` จากนั้นกด Space สองครั้ง กด Enter เพื่อยอมรับตัวเลือกของคุณ หากคุณมีเค้าโครงแป้นพิมพ์หลายแบบด้วย ให้คลิกขวาที่ตัวบ่งชี้เพื่อสลับวนเค้าโครงเหล่านั้น

ใช้ _Setup > Typing > Keyboard Layouts_ เพื่อเลือกเค้าโครงอย่าง English และ French จากตัวเลือกเดียวกับที่เสนอระหว่างการติดตั้ง ใช้ _Setup > Typing > Input Methods_ เพื่อเลือกว่าเครื่องมือประกอบข้อความใดทำงานอยู่ ตัวเลือกทั้งสองจะเปิดภายในเมนู Omarchy โดยตัวเลือกปัจจุบันของคุณถูกทำเครื่องหมายไว้ คลิกหรือกด Enter เพื่อสลับตัวเลือก การเปลี่ยนแปลงแต่ละครั้งมีผลทันที การยกเลิกการเลือกวิธีป้อนข้อมูลจะนำมันออกจากการสลับวนโดยไม่ถอนการติดตั้ง แป้นพิมพ์ยังคงพร้อมใช้งาน

รัน `omarchy setup keyboard` หรือ `omarchy setup input` เพื่อเปิดตัวเลือกเดียวกัน หากต้องการเพิ่มภาษาหนึ่งภาษาจากบรรทัดคำสั่ง ให้ใช้ `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` หรือ `cangjie5` ส่วน Quick, Boshiamy และ Array มาอยู่ในแพ็กเกจเดียวกับ Cangjie และปรากฏในตัวเลือก Input Methods แป้นสลับที่คุณกำหนดเองจะได้รับการเก็บไว้ สำหรับเค้าโครงหรือแป้นของเครื่องมือทางเลือก ให้ติดตั้ง `fcitx5-configtool` ด้วย `omarchy pkg add fcitx5-configtool` และเปิดใช้จากเทอร์มินัล การเลือกภาษาป้อนข้อมูลจะไม่เปลี่ยนภาษาของเดสก์ท็อป การเลือก Japanese, Korean หรือ Chinese ภายใต้ _Setup > Language_ จะเพิ่มวิธีป้อนข้อมูลของภาษานั้นเมื่อคุณยังไม่มีเลย

ใช้ `Super + I` เพื่อสลับวนผ่านวิธีป้อนข้อมูลหรือเค้าโครงแป้นพิมพ์ และ `Super + Shift + I` เพื่อย้อนกลับไปอีกทาง ดังนั้นเมื่อกำหนดค่าไว้สามแบบ คุณจึงย้ายไปมาระหว่างสองแบบที่อยู่ติดกันได้ ตัวบ่งชี้การป้อนข้อมูลจะปรากฏทางด้านขวาของแถบเฉพาะเมื่อมีการกำหนดวิธีป้อนข้อมูลหรือเค้าโครงไว้มากกว่าหนึ่งแบบเท่านั้น การผูกแป้นบนเดสก์ท็อปนี้ทำงานควบคู่ไปกับแป้นสลับ Fcitx ที่มีอยู่ของคุณ คุณสามารถแทนที่มันได้ใน `~/.config/hypr/bindings.lua` เครื่องมือป้อนข้อมูลและลำดับ compose ใช้บริการ [Fcitx5](https://fcitx-im.org/) ที่ทำงานอยู่ในทุกเซสชันอยู่แล้ว

### ใช้ ALT เป็น SUPER

บนแป้นพิมพ์บางรุ่น การใช้แป้น meta หลัก (แป้น Windows/cmd) เป็น SUPER ไม่สะดวกนัก คุณสามารถเปลี่ยนให้เป็น ALT แทนได้ด้วยการเปลี่ยนแปลงนี้:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
