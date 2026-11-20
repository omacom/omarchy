# ธีม

Omarchy มาพร้อมธีมสวย ๆ ถึงยี่สิบสองธีม คุณสามารถเลือกเปลี่ยนระหว่างธีมเหล่านี้ได้ผ่าน _รูปลักษณ์ > ธีม_ ใน Omarchy Menu (`Super + Space`) หรือกระโดดไปยังตัวเลือกธีมได้โดยตรงด้วย `Super + Ctrl + T`

แต่ละธีมจะจัดสไตล์ให้กับเดสก์ท็อป เทอร์มินัล neovim หน้าจอกิจกรรม (btop) Chromium และ Omarchy shell ทั้งหมด: แถบด้านบน เมนู การแจ้งเตือน OSD และหน้าจอล็อก (สำหรับ Obsidian คุณต้องเลือกธีม Omarchy ด้วยตนเองผ่าน _รูปลักษณ์ > ธีม_ ภายในแอป)

ธีมมีชุดภาพพื้นหลังที่คุณเลือกสลับไปมาได้ด้วย `Super + Ctrl + W`

คุณสามารถค้นหาธีมเพิ่มเติมได้อีกที่ [หน้าเพจธีมเพิ่มเติม](https://omarchy.org/themes/) หรือแม้แต่ [สร้างธีมของคุณเอง](43-making-your-own-theme.md)

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

### ไอคอนแอป

ไอคอนในตัวเรียกใช้แอปและ dock จะถูกวาดด้วยสีของธีมของคุณ จึงเปลี่ยนไปพร้อมกับธีม ไอคอนเหล่านี้มาจากชุดไอคอน ซึ่งคุณเลือกแยกจากธีมได้ภายใต้ _รูปลักษณ์ > ไอคอน_ จากภาพตัวอย่างของแต่ละชุด ในแบบเดียวกับที่คุณเลือกธีม:

- _Papercraft_ คือค่าเริ่มต้น: ทุกอย่างที่ติดตั้งมาจะถูกวาดในสไตล์เดียวกัน แอปที่เป็นที่รู้จักจากโลโก้ของมัน อย่าง Chrome, HEY หรือ YouTube จะคงรูปทรงเดิมไว้และรับสีของธีมไปใช้
- _Arcade_ วาดแอปเดียวกันเหล่านั้นเป็นศิลปะพิกเซลแบบ 8-bit เหมือนที่เครื่องเกมคอนโซลรุ่นเก่าจะทำ
- _Original_ แสดงทุกแอปด้วยไอคอนที่ผู้สร้างของมันให้มา

คุณสามารถติดตั้งชุดไอคอนที่คนอื่นทำขึ้นได้ด้วย _ติดตั้ง > สไตล์ > ไอคอน_ (หรือ `omarchy icons install <git url>`) และลบออกได้อีกครั้งภายใต้ _ลบ > ไอคอน_ ส่วน _อัปเดต > ไอคอนเสริม_ จะดึงเวอร์ชันล่าสุดของชุดที่คุณติดตั้งไว้

หากต้องการทำของคุณเอง ให้ใส่ไอคอนของคุณไว้ใน `~/.config/omarchy/icons/<name>/` หนึ่งไฟล์ต่อหนึ่งแอป โดยตั้งชื่อตามบรรทัด `Icon=` ของไฟล์ `.desktop` ของแอปนั้น ไฟล์ที่ลงท้ายด้วย `.svg` จะแสดงตามที่เป็นอยู่ ไฟล์ที่ลงท้ายด้วย `.svg.tpl` จะถูกวาดด้วยสีของธีม: ให้เขียน `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` หรือ `{{ icon_shadow }}` ตรงตำแหน่งที่ควรเป็นสี ชุดค่าเริ่มต้นใน `/usr/share/omarchy/icons/papercraft/` เป็นจุดเริ่มต้นที่ดี เพิ่ม `preview.png` เพื่อแสดงชุดของคุณในตัวเลือก หากไม่มี Omarchy จะวาดภาพตัวอย่างจากไอคอนของคุณ หากต้องการเปลี่ยนไอคอนเพียงอันเดียวของชุดค่าเริ่มต้น ให้ใส่เวอร์ชันของคุณไว้ใน `~/.config/omarchy/icons/papercraft/`

### การปลดล็อก

ธีมยังสามารถมีดีไซน์การปลดล็อกแบบกำหนดเองได้ ซึ่งใช้สำหรับกระบวนการถอดรหัสตอนบูต คุณสามารถเลือกแบบหนึ่งเหล่านี้ได้ภายใต้ _รูปลักษณ์ > ปลดล็อก_ หน้าตาของมันเป็นแบบนี้:

 ![catppuccin](../themes/catppuccin/preview-unlock.png)
_Catppuccin_

 ![catppuccin-latte](../themes/catppuccin-latte/preview-unlock.png)
_Catppuccin Latte_

 ![ethereal](../themes/ethereal/preview-unlock.png)
_Ethereal_

 ![everforest](../themes/everforest/preview-unlock.png)
_Everforest_

 ![flexoki-light](../themes/flexoki-light/preview-unlock.png)
_Flexoki Light_

 ![gruvbox](../themes/gruvbox/preview-unlock.png)
_Gruvbox_

 ![hackerman](../themes/hackerman/preview-unlock.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview-unlock.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview-unlock.png)
_Kanagawa_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![matte-black](../themes/matte-black/preview-unlock.png)
_Matte Black_

![miasma](../themes/miasma/preview-unlock.png)
_Miasma_

 ![nord](../themes/nord/preview-unlock.png)
_Nord_

 ![retro-82](../themes/retro-82/preview-unlock.png)
_Retro 82_

 ![ristretto](../themes/ristretto/preview-unlock.png)
_Ristretto_

![rose-pine](../themes/rose-pine/preview-unlock.png)
_Rose Pine_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
