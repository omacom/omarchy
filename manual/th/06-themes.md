# ธีม

Omarchy มาพร้อมธีมสวย ๆ ถึงยี่สิบสองธีม คุณสามารถเลือกสลับไปมาได้ผ่าน _รูปลักษณ์ > ธีม_ ในเมนู Omarchy (`Super + Space`) หรือกระโดดตรงไปยังตัวเลือกธีมได้เลยด้วย `Super + Ctrl + T`

แต่ละธีมจะกำหนดสไตล์ให้เดสก์ท็อป เทอร์มินัล neovim หน้าจอกิจกรรม (btop) Chromium และ Omarchy shell ทั้งหมด: แถบด้านบน เมนู การแจ้งเตือน OSD และหน้าจอล็อก (สำหรับ Obsidian คุณต้องเลือกธีม Omarchy ด้วยตัวเองผ่าน _รูปลักษณ์ > ธีม_ ภายในแอป)

ธีมต่าง ๆ มีชุดภาพพื้นหลังให้คุณเลือกสลับไปมาได้ด้วย `Super + Ctrl + W`

คุณจะพบธีมเพิ่มเติมอีกมากมายได้ที่ [หน้าเว็บธีมเพิ่มเติม](https://omarchy.org/themes/) หรือแม้แต่ [สร้างธีมของคุณเอง](43-making-your-own-theme.md)

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

ไอคอนในตัวเปิดแอปและด็อกจะถูกวาดด้วยสีของธีมของคุณ ดังนั้นมันจะเปลี่ยนตามธีมไปด้วย ไอคอนเหล่านี้มาจากชุดไอคอน ซึ่งคุณเลือกแยกต่างหากจากธีมได้ใน _รูปลักษณ์ > ไอคอน_:

- _Papercraft_ คือค่าเริ่มต้น: ทุกอย่างที่ติดตั้งมาให้ จะถูกวาดในสไตล์เดียวกัน แอปที่เป็นที่รู้จักจากโลโก้ของมัน อย่าง Chrome, HEY หรือ YouTube จะยังคงรูปทรงเดิมไว้และรับสีของธีมไปใช้
- _Arcade_ วาดแอปเดียวกันออกมาเป็นภาพพิกเซลอาร์ตแบบ 8-bit เหมือนที่เครื่องเกมคอนโซลสมัยก่อนทำ
- _Original_ แสดงทุกแอปด้วยไอคอนที่ผู้สร้างแอปให้มา

คุณสามารถติดตั้งชุดไอคอนที่คนอื่นทำไว้ได้ด้วย _ติดตั้ง > สไตล์ > ไอคอน_ (หรือ `omarchy icons install <git url>`) และลบออกได้อีกครั้งใน _ลบออก > ไอคอน_ ส่วน _อัปเดต > ไอคอนเพิ่มเติม_ จะดึงเวอร์ชันล่าสุดของชุดไอคอนที่คุณติดตั้งไว้มาให้

หากต้องการทำชุดไอคอนของคุณเอง ให้วางไอคอนไว้ใน `~/.config/omarchy/icons/<name>/` หนึ่งไฟล์ต่อหนึ่งแอป โดยตั้งชื่อตามบรรทัด `Icon=` ในไฟล์ `.desktop` ของแอปนั้น ไฟล์ที่ลงท้ายด้วย `.svg` จะแสดงตามที่เป็นอยู่ ส่วนไฟล์ที่ลงท้ายด้วย `.svg.tpl` จะถูกวาดด้วยสีของธีม: ให้เขียน `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` หรือ `{{ icon_shadow }}` ตรงตำแหน่งที่ควรเป็นสี ชุดไอคอนค่าเริ่มต้นใน `/usr/share/omarchy/icons/papercraft/` เป็นจุดเริ่มต้นที่ดี หากต้องการเปลี่ยนไอคอนเพียงตัวเดียวของชุดค่าเริ่มต้น ให้วางเวอร์ชันของคุณไว้ใน `~/.config/omarchy/icons/papercraft/`

### หน้าจอปลดล็อก

ธีมยังสามารถมีดีไซน์หน้าจอปลดล็อกแบบกำหนดเองได้ด้วย ซึ่งใช้สำหรับขั้นตอนถอดรหัสตอนบูตเครื่อง คุณสามารถเลือกหนึ่งในนั้นได้ใน _รูปลักษณ์ > หน้าจอปลดล็อก_ หน้าตาของมันเป็นแบบนี้:

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
