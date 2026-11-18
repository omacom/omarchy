# การเล่นเกม

Omarchy ไม่ได้มีไว้แค่สำหรับ _pRoDUcTiVItY_ เท่านั้น แต่มีไว้เพื่อความสนุกด้วย และจะมีอะไรสนุกไปกว่าการเล่นเกมอีกล่ะ? Omarchy มาพร้อมกับชุดตัวเลือกสำหรับการเล่นเกมครบครัน — Steam และ RetroArch สำหรับการเล่นแบบเนทีฟและแบบเรโทร, Battle.net, Lutris และ Heroic สำหรับร้านค้าที่ไม่ใช่ Steam, Moonlight สำหรับการสตรีมจาก PC, Xbox Cloud Gaming + NVIDIA GeForce NOW สำหรับการเล่นบนคลาวด์ แถมด้วย Minecraft ที่ได้รับความนิยมตลอดกาล

ต้องขอบคุณผลงานอันน่าทึ่งของ Valve กับ [เลเยอร์ความเข้ากันได้ Proton](https://en.wikipedia.org/wiki/Proton_(software)) ตอนนี้จึงมีเกมสมัยใหม่ที่เล่นได้บน Linux หลายหมื่นเกม อ้อ แล้วคุณรู้ไหมว่า [Steam Deck](https://store.steampowered.com/steamdeck/) จริง ๆ แล้วรัน Arch!

ตัวติดตั้งสำหรับการเล่นเกมทั้งหมดอยู่ใน _Install > Gaming_ ในเมนู Omarchy (`Super + Space`) ถ้าวันไหนคุณอยากยกเลิกการติดตั้งอันใดอันหนึ่ง ให้ใช้ _Remove > Gaming_

## Steam

ติดตั้ง [Steam](https://store.steampowered.com/) โดยเลือก _Install > Gaming > Steam_ จากเมนู Omarchy (`Super + Space`)

หลังจากติดตั้งแล้ว คุณจะเปิด Steam ได้ด้วย `Super + Space`

โปรดทราบว่า Steam อาจใช้เวลา 10-20 วินาทีในการเริ่มต้น และมันจะไม่แสดงสัญญาณใด ๆ ให้เห็นเลยว่ากำลังโหลดอยู่

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

ติดตั้ง [RetroArch](https://www.retroarch.com/) โดยเลือก _Install > Gaming > RetroArch_ จากเมนู Omarchy (`Super + Space`) มันมาพร้อมกับชุด libretro cores แบบครบถ้วน ดังนั้นระบบคลาสสิกทั้งหมดจึงครอบคลุมเรียบร้อย

RetroArch ถูกตั้งค่ามาให้พร้อมอย่างสมบูรณ์ด้วยเชเดอร์ CRT Royale ที่สวยงาม เพื่อลุคเรโทรที่สมบูรณ์แบบที่สุด

วิธีเริ่มต้นใช้งาน:

1. วางไฟล์ BIOS ของคุณลงใน `~/Games/bios` และ ROMs ของคุณลงใน `~/Games/roms`
2. เปิด RetroArch ด้วย `Super + Space` แล้วพิมพ์ `retro`
3. สแกนไดเรกทอรี `~/Games/roms` แล้วคุณก็พร้อมเล่นได้เลย

คุณยังสามารถให้เกมโปรดมีรายการของตัวเองในตัวเปิดแอปได้ด้วย _Install > Gaming > RetroArch Game Launcher_ ซึ่งให้คุณเลือก core และ ROM แล้วกระโดดเข้าเกมได้ตรงจาก `Super + Space` เลย

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

ติดตั้งเว็บแอป Xbox Cloud Gaming โดยเลือก _Install > Gaming > Xbox Cloud Gaming_ จากเมนู Omarchy (`Super + Space`) มันเป็น "แค่" เว็บแอปสำหรับบริการนี้ แต่มันเริ่มทำงานได้เร็วและรันได้ดีเยี่ยมที่ 1080p

ถ้าคุณมี Xbox Game Pass อยู่แล้ว นี่เป็นวิธีที่ดีมากในการเล่น Fortnite และเกมอื่น ๆ ที่คุณรันแบบเนทีฟบน Linux ไม่ได้

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

ติดตั้งบริการเกมบนคลาวด์ [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) โดยเลือก _Install > Gaming > NVIDIA GeForce NOW_ จากเมนู Omarchy (`Super + Space`) อีกหนึ่งวิธีที่ยอดเยี่ยมในการเล่นเกมที่ไม่มีให้เล่นแบบเนทีฟบน Linux

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

ติดตั้ง Minecraft โดยเลือก _Install > Gaming > Minecraft_ จากเมนู Omarchy (`Super + Space`)

เช่นเดียวกับ Steam โปรดทราบว่าอาจต้องใช้เวลาสักพักหลังจากเข้าสู่ระบบหรือเริ่มโปรแกรม กว่าหน้าจอถัดไปจะปรากฏ และคุณจะไม่ได้รับสัญญาณใด ๆ เลยในขณะที่กำลังรอ

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

ติดตั้งการรองรับคอนโทรลเลอร์ Xbox ผ่าน Bluetooth โดยเลือก _Install > Gaming > Xbox Controllers_ จากเมนู Omarchy (`Super + Space`) จับคู่คอนโทรลเลอร์ผ่าน Bluetooth (`Super + Ctrl + B`) แล้วมันจะใช้งานได้ในทุกเกมของคุณ คุณไม่จำเป็นต้องใช้สิ่งนี้ถ้าคุณแค่เสียบคอนโทรลเลอร์แบบมีสายด้วยสาย USB-C

## Moonlight (การสตรีมเกมจาก PC)

ติดตั้ง [ไคลเอนต์ Moonlight](https://github.com/moonlight-stream/moonlight-qt) โดยเลือก _Install > Gaming > Moonlight_ จากเมนู Omarchy (`Super + Space`) แล้วคุณจะสามารถสตรีมเกมจาก PC ที่ใช้ Windows ซึ่งรัน [Sunshine](https://app.lizardbyte.dev/Sunshine/) อยู่ได้

ถ้าทั้งเครื่อง Omarchy ของคุณและ PC สำหรับเล่นเกมระยะไกลเสียบสายไว้ทั้งคู่ ประสบการณ์ที่ได้จะแยกไม่ออกจากการเล่นในเครื่องเลย ดันความละเอียดขึ้นไปจนถึงระดับเนทีฟ ตั้งค่าอัตราการรีเฟรชเป็น 120Hz และเร่ง bitrate ให้สูงสุด — นี่คือวิธีที่ดีที่สุดในการเล่นเกมยิงปืนแข่งขันอย่าง Fortnite บน Linux

คุณยังสามารถเปลี่ยนเครื่อง Omarchy ให้เป็นโฮสต์ได้โดยรัน `omarchy install service sunshine` ซึ่งจะติดตั้ง Sunshine และเปิดพอร์ตสำหรับการสตรีม Moonlight สำหรับ LAN และ Tailscale ของคุณ

## Battle.net

ติดตั้ง [Battle.net](https://eu.shop.battle.net/en-us) โดยเลือก _Install > Gaming > Battle.net_ จากเมนู Omarchy (`Super + Space`) นี่จะให้คุณได้เล่นเกมอย่าง Diablo, Starcraft และ World of Warcraft ในการติดตั้งแบบสแตนด์อโลนที่รันภายใต้ GE-Proton — โดยไม่ต้องพึ่ง Steam, Lutris หรือ Heroic เลย

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (เกม Windows)

ติดตั้ง [Lutris](https://lutris.net/) โดยเลือก _Install > Gaming > Lutris_ จากเมนู Omarchy (`Super + Space`) Lutris คือวิธีเล่นเกม Windows จากร้านค้าอย่าง EA และ Ubisoft Connect ที่ไม่มีตัวติดตั้งของตัวเองข้างต้น

การติดตั้งจะดูตะกุกตะกักอยู่บ้าง และบางครั้งจะดูเหมือนไม่มีอะไรเกิดขึ้นเลย — อดทนไว้หน่อย มันกำลังทำงานอยู่ในเบื้องหลัง

## Heroic Launcher (Epic Games)

ติดตั้ง [Heroic Launcher](https://heroicgameslauncher.com/) โดยเลือก _Install > Gaming > Heroic (Epic Games)_ จากเมนู Omarchy (`Super + Space`) Heroic ให้คุณรันเกมจาก Epic Games อย่าง OddSparks ที่ไม่ต้องพึ่งระบบป้องกันการโกงได้ — แถมด้วยเกมจาก GOG และ Amazon Prime Gaming แต่น่าเสียดาย นั่นหมายความว่าไม่มี Fortnite และไม่มี Rocket League — จนกว่า Tim Sweeney จะหันมาหา Linux นี่ก็ใกล้เคียงที่สุดเท่าที่จะทำได้แล้ว

เช่นเดียวกับ Lutris มันอาจรู้สึกช้าและตะกุกตะกักขณะติดตั้งเกม ให้เวลามันหน่อย
