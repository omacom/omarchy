# ธีม

Omarchy มาพร้อมกับธีมสวย ๆ ยี่สิบสามธีม คุณสามารถเลือกระหว่างธีมเหล่านี้ได้ผ่าน _ลักษณะที่ปรากฏ > ธีม_ ใน Omarchy Menu (`Super + Space`) หรือกระโดดตรงไปยังตัวเลือกธีมได้โดยใช้ `Super + Ctrl + T`

แต่ละธีมกำหนดสไตล์ให้กับเดสก์ท็อป เทอร์มินัล neovim หน้าจอกิจกรรม (btop) เบราว์เซอร์ของคุณ (Chrome, Chromium, Edge หรือ Brave) และ Omarchy shell ทั้งหมด: แถบบน เมนู การแจ้งเตือน OSD และหน้าจอล็อก (สำหรับ Obsidian คุณต้องเลือกธีม Omarchy ด้วยตัวเองผ่าน _ลักษณะที่ปรากฏ > ธีม_ ภายในแอป)

ธีมต่าง ๆ มีชุดภาพพื้นหลังที่คุณสามารถเลือกสลับระหว่างภาพเหล่านั้นได้โดยใช้ `Super + Ctrl + W`

คุณสามารถค้นหาธีมเพิ่มเติมได้ที่ [หน้าธีมเพิ่มเติม](https://omarchy.org/themes/) หรือแม้แต่ [สร้างธีมของคุณเอง](43-making-your-own-theme.md)

 ![tokyo-night](../themes/tokyo-night/preview.png)
_Tokyo Night_

 ![catppuccin](../themes/catppuccin/preview.png)
_Catppuccin_

 ![lumon](../themes/lumon/preview.png)
_Lumon_

 ![ethereal](../themes/ethereal/preview.png)
_Ethereal_

 ![everforest](../themes/everforest/preview.png)
_Everforest_

 ![gruvbox](../themes/gruvbox/preview.png)
_Gruvbox_

 ![miasma](../themes/miasma/preview.png)
_Miasma_

 ![hackerman](../themes/hackerman/preview.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview.png)
_Kanagawa_

 ![nord](../themes/nord/preview.png)
_Nord_

 ![matte-black](../themes/matte-black/preview.png)
_Matte Black_

 ![vantablack](../themes/vantablack/preview.png)
_Vantablack_

 ![ristretto](../themes/ristretto/preview.png)
_Ristretto_

 ![retro-82](../themes/retro-82/preview.png)
_Retro 82_

 ![flexoki-light](../themes/flexoki-light/preview.png)
_Flexoki Light_

 ![rose-pine](../themes/rose-pine/preview.png)
_Rose Pine_

 ![catppuccin-latte](../themes/catppuccin-latte/preview.png)
_Catppuccin Latte_

 ![white](../themes/white/preview.png)
_White_

 ![last-horizon](../themes/last-horizon/preview.png)
_Last Horizon_

 ![lupine](../themes/lupine/preview.png)
_Lupine_

 ![solitude](../themes/solitude/preview.png)
_Solitude_

 ![starship](../themes/starship/preview.png)
_Starship_

### ไอคอนแอป

ไอคอนในตัวเรียกใช้แอปและ dock ถูกวาดด้วยสีของธีมของคุณ ดังนั้นไอคอนเหล่านั้นจึงเปลี่ยนไปพร้อมกับธีม ไอคอนเหล่านี้มาจากชุดไอคอน ซึ่งคุณเลือกแยกจากธีมภายใต้ _ลักษณะที่ปรากฏ > ไอคอน_ จากภาพตัวอย่างของแต่ละชุด ด้วยวิธีเดียวกับที่คุณเลือกธีม:

- _Papercraft_ เป็นค่าเริ่มต้น: ทุกอย่างที่ติดตั้งมา ถูกวาดในสไตล์เดียวกัน แอปที่เป็นที่รู้จักจากโลโก้ของมัน เช่น Chrome, HEY หรือ YouTube จะคงรูปร่างของมันไว้และรับสีของธีมมาใช้
- _Arcade_ วาดแอปเดียวกันเหล่านี้เป็นศิลปะพิกเซลแบบ 8 บิต เหมือนที่เครื่องเกมคอนโซลรุ่นเก่าจะทำ
- _Original_ แสดงทุกแอปด้วยไอคอนที่ผู้สร้างของมันให้มา

คุณสามารถติดตั้งชุดไอคอนที่คนอื่นทำขึ้นได้ด้วย _ติดตั้ง > สไตล์ > ไอคอน_ (หรือ `omarchy icons install <git url>`) และลบมันออกอีกครั้งได้ภายใต้ _ลบ > ไอคอน_ _อัปเดต > ไอคอนเพิ่มเติม_ จะดึงเวอร์ชันล่าสุดของชุดไอคอนที่คุณติดตั้งไว้

หากต้องการสร้างชุดของคุณเอง ให้ใส่ไอคอนของคุณไว้ใน `~/.config/omarchy/icons/<name>/` หนึ่งไฟล์ต่อหนึ่งแอป โดยตั้งชื่อตามบรรทัด `Icon=` ของไฟล์ `.desktop` ของแอปนั้น ไฟล์ที่ลงท้ายด้วย `.svg` จะแสดงตามที่เป็นอยู่ ไฟล์ที่ลงท้ายด้วย `.svg.tpl` จะถูกวาดด้วยสีของธีม: ให้เขียน `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` หรือ `{{ icon_shadow }}` ในตำแหน่งที่ควรเป็นสี ชุดค่าเริ่มต้นใน `/usr/share/omarchy/icons/papercraft/` เป็นจุดเริ่มต้นที่ดี เพิ่ม `preview.png` เพื่อแสดงชุดของคุณในตัวเลือก หากไม่มี Omarchy จะวาดภาพตัวอย่างจากไอคอนของคุณ หากต้องการเปลี่ยนไอคอนเพียงไอคอนเดียวของชุดค่าเริ่มต้น ให้ใส่เวอร์ชันของคุณไว้ใน `~/.config/omarchy/icons/papercraft/`

### การบูตและการเข้าสู่ระบบ

หน้าจอที่ถามรหัสผ่านไดรฟ์ของคุณเมื่อคอมพิวเตอร์เริ่มทำงาน และหน้าจอเข้าสู่ระบบ ก็เป็นไปตามธีมเช่นกัน ทุกครั้งที่คุณสลับธีม หน้าจอเหล่านั้นจะรับพื้นหลัง ข้อความ สีเน้น และสีแดงของมันมาใช้ ดังนั้นจึงไม่มีดีไซน์การปลดล็อกแยกต่างหากให้เลือก บน Apple Silicon Macs หน้าจอรหัสผ่านไดรฟ์จะคงลุคเริ่มต้นของ Omarchy ไว้ไม่ว่าธีมจะเป็นอะไรก็ตาม
