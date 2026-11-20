# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) เป็นทางเลือกที่น่าใช้แทนอะไรอย่างแอปพลิเคชัน GitHub Desktop และมันทำงานอยู่ภายใน terminal

คุณสามารถรันมันได้โดยตรง โดยเข้าไปยัง directory ใดก็ได้ที่จัดการด้วย git แล้วรัน `lazygit` หรือคุณสามารถรันมันภายใน Neovim ซึ่งสามารถเปิดได้ด้วย `Space G G`

คุณกระโดดสลับไปมาระหว่าง pane ต่าง ๆ ได้โดยใช้ `Tab` ใน pane ชื่อ Files คุณสามารถเลือกไฟล์สำหรับ staging ได้โดยใช้ `Space` จากนั้นคุณสามารถสร้าง commit ใหม่ได้โดยใช้ `c` คุณสามารถดูคำสั่งทั้งหมดที่มีอยู่ได้โดยใช้ `?`

## Btop

[Btop](https://github.com/aristocratos/btop) เป็นตัวจัดการทรัพยากรที่สวยงาม ซึ่งแสดงการใช้งาน memory, CPU, disk และ network มันยังแสดงรายการ process ที่กำลังทำงานอยู่ทั้งหมด และให้คุณจัดการ process เหล่านั้นได้

Omarchy เรียกมันว่า Activity Monitor และคุณเปิดมันได้จาก app launcher หรือโดยการกด `Super + Shift + T` มันจะเปิดเป็นหน้าต่างแบบลอยตัว ซึ่งคุณสามารถจัดเรียงเป็น tile ได้ด้วย `Super + T`

## Herdr

[Herdr](https://github.com/omacom-io/herdr) เป็นตัวจัดการ workspace ใน terminal ที่ให้คุณมี workspaces, tabs และ panes และทำให้ทั้งหมดนั้นทำงานต่อไปใน session แบบถาวรที่คุณสามารถถอดออกและกลับเข้ามาใหม่ได้ในภายหลัง

คุณเปิดมัน (หรือกลับเข้าไปเชื่อมต่อกับ session เดิมของคุณ) ได้จาก app launcher หรือด้วย `Super + Ctrl + Return` Omarchy มาพร้อมกับการตั้งค่าของ Herdr ที่สะท้อนการตั้งค่า Tmux ของมัน ดังนั้น prefix key ที่นี่ก็คือ `Ctrl + Space` เช่นกัน คุณสามารถเรียกดู keybinding ทั้งหมดได้ด้วย `Super + Ctrl + K`

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) แสดงข้อมูลระบบ เช่น เวอร์ชัน kernel, uptime, theme, CPU, memory และอื่น ๆ มันเป็นตัวสืบทอดจากเครื่องมือ neofetch ที่ได้รับความนิยม

Omarchy ได้จัดมันไว้เป็น _System > About_ ในเมนู Omarchy (`Super + Space`)

## Cliamp

[Cliamp](https://www.cliamp.stream/) เป็นเครื่องเล่นเพลงใน terminal สไตล์ย้อนยุคที่ได้รับแรงบันดาลใจจาก Winamp 2.x พร้อมสถานีวิทยุในตัวสำหรับ lo-fi beats เปิดมันได้ด้วย `Super + Shift + Alt + M` หรือจากเมนู Omarchy ภายใต้ _Apps_ กด `?` เพื่อดูรายการ keybinding ทั้งหมด

## แล้ว Wi-Fi และ Bluetooth ล่ะ?

คุณจะไม่พบ TUI สำหรับ Wi-Fi และ Bluetooth — งานเหล่านั้นเป็นของ Omarchy shell คลิกไอคอน Wi-Fi ในแถบบนสุด (หรือกด `Super + Ctrl + N`) เพื่อดู network และเชื่อมต่อ และคลิกไอคอน Bluetooth (หรือกด `Super + Ctrl + B`) เพื่อจับคู่และเชื่อมต่ออุปกรณ์ ดูเรื่องราวทั้งหมดได้ที่ [การเชื่อมต่อเครือข่าย](35-networking.md)

## เพิ่มของคุณเอง

โปรแกรม terminal โปรแกรมใดก็ได้สามารถได้รับการปฏิบัติแบบแอปเต็มรูปแบบ ไปที่ _Install > TUI_ ในเมนู Omarchy (`Super + Space`) ตั้งชื่อให้มัน ใส่คำสั่งสำหรับเปิดใช้งาน สไตล์หน้าต่าง และไอคอน แล้วมันจะปรากฏใน app launcher เหมือนแอปพลิเคชันอื่น ๆ คุณสามารถลบมันออกอีกครั้งได้ภายใต้ _Remove > TUI_
