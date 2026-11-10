# การเล่นเกม

Omarchy ไม่ได้มีไว้สำหรับ _pRoDUcTiVItY_ อย่างเดียว มันยังเอาไว้เล่นสนุกด้วย และอะไรจะสนุกไปกว่าการเล่นเกม? Omarchy มาพร้อมชุดตัวเลือกการเล่นเกมทั้งชุด — Steam และ RetroArch สำหรับการเล่นเนทีฟและย้อนยุค, Battle.net, Lutris และ Heroic สำหรับร้านที่ไม่ใช่ Steam, Moonlight สำหรับการสตรีมจาก PC, Xbox Cloud Gaming + NVIDIA GeForce NOW สำหรับคลาวด์ บวกกับ Minecraft ที่อมตะนิรันดร์กาล

ด้วยงานอันเหลือเชื่อของ Valve บน [เลเยอร์ความเข้ากันได้ proton](https://en.wikipedia.org/wiki/Proton_(software)) ตอนนี้จึงมีเกมสมัยใหม่ที่เล่นได้หลายหมื่นเกมบน Linux อ้อ แล้วคุณรู้ไหมว่า [Steam Deck](https://store.steampowered.com/steamdeck/) จริง ๆ แล้วรัน Arch!

ตัวติดตั้งเกมทั้งหมดอยู่ใต้ _ติดตั้ง > Gaming_ ในเมนู Omarchy (`Super + Space`) ถ้าคุณต้องการยกเลิกตัวใดตัวหนึ่งเมื่อไร ให้ใช้ _นำออก > Gaming_

## Steam

ติดตั้ง [Steam](https://store.steampowered.com/) โดยเลือก _ติดตั้ง > Gaming > Steam_ จากเมนู Omarchy (`Super + Space`)

หลังจากที่คุณติดตั้งมันแล้ว คุณจะสามารถเปิด Steam ได้ด้วย `Super + Space`

โปรดทราบว่า Steam อาจใช้เวลา 10-20 วินาทีในการเริ่ม และมันจะไม่ให้สัญญาณภาพใด ๆ ว่ามันกำลังโหลดอยู่

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

ติดตั้ง [RetroArch](https://www.retroarch.com/) โดยเลือก _ติดตั้ง > Gaming > RetroArch_ จากเมนู Omarchy (`Super + Space`) มันมาพร้อมชุด libretro core ครบเซ็ต ดังนั้นระบบคลาสสิกทั้งหมดจึงครอบคลุม

RetroArch ตั้งค่าไว้ล่วงหน้าเต็มรูปแบบด้วยเชดเดอร์ CRT Royale ที่สวยงาม เพื่อลุคย้อนยุคที่สมบูรณ์แบบนั้น

วิธีเริ่มต้น:

1. วางไฟล์ BIOS ของคุณลงใน `~/Games/bios` และ ROM ลงใน `~/Games/roms`
2. เปิด RetroArch ด้วย `Super + Space` แล้วพิมพ์ `retro`
3. สแกนไดเรกทอรี `~/Games/roms` แล้วคุณก็พร้อมเล่น

คุณยังให้เกมโปรดมีรายการของตัวเองในตัวเปิดแอปได้ด้วย _ติดตั้ง > Gaming > RetroArch Game Launcher_ ซึ่งให้คุณเลือก core และ ROM และกระโดดตรงเข้าเกมจาก `Super + Space`

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

ติดตั้งเว็บแอป Xbox Cloud Gaming โดยเลือก _ติดตั้ง > Gaming > Xbox Cloud Gaming_ จากเมนู Omarchy (`Super + Space`) มันเป็น "แค่" เว็บแอปสำหรับบริการนั้น แต่มันเริ่มเร็วและรันได้ดีที่ 1080p

ถ้าคุณมี Xbox Game Pass อยู่แล้ว นี่คือวิธีที่มั่นคงในการเล่น Fortnite และเกมอื่น ๆ ที่คุณรันแบบเนทีฟบน Linux ไม่ได้

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

ติดตั้งบริการเกมคลาวด์ [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) โดยเลือก _ติดตั้ง > Gaming > NVIDIA GeForce NOW_ จากเมนู Omarchy (`Super + Space`) อีกวิธีที่ดีในการเล่นเกมที่ไม่มีให้แบบเนทีฟบน Linux

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

ติดตั้ง Minecraft โดยเลือก _ติดตั้ง > Gaming > Minecraft_ จากเมนู Omarchy (`Super + Space`)

เช่นเดียวกับ Steam โปรดทราบว่ามันอาจใช้เวลาสักพักหลังจากเข้าสู่ระบบหรือเริ่มก่อนที่หน้าจอถัดไปจะโผล่มา และคุณจะไม่ได้รับสัญญาณใด ๆ ขณะรอ

 ![gaming-minecraft](images/gaming-minecraft.webp)

## คอนโทรลเลอร์ Xbox

ติดตั้งการสนับสนุนคอนโทรลเลอร์ Xbox แบบ Bluetooth โดยเลือก _ติดตั้ง > Gaming > Xbox Controllers_ จากเมนู Omarchy (`Super + Space`) จับคู่คอนโทรลเลอร์ผ่าน Bluetooth (`Super + Ctrl + B`) แล้วพวกมันจะทำงานในเกมทั้งหมดของคุณ คุณไม่จำเป็นต้องมีสิ่งนี้ถ้าคุณแค่เสียบคอนโทรลเลอร์แบบมีสายด้วยสาย USB-C

## Moonlight (การสตรีมเกมจาก PC)

[ไคลเอนต์ Moonlight](https://github.com/moonlight-stream/moonlight-qt) ติดตั้งมาให้ล่วงหน้ากับ Omarchy ดังนั้นคุณจึงสตรีมเกมจาก PC Windows ที่รัน [Sunshine](https://app.lizardbyte.dev/Sunshine/) ได้ทันที เปิด Moonlight ผ่าน `Super + Space`

ถ้าทั้งเครื่อง Omarchy ของคุณและ PC เกมระยะไกลเสียบสายอยู่ทั้งคู่ ประสบการณ์ก็แยกไม่ออกจากการเล่นในเครื่องเลย ดันความละเอียดขึ้นไปเป็นเนทีฟ ตั้งรีเฟรชเป็น 120Hz และดันบิตเรตให้สุด — นี่คือวิธีที่ดีที่สุดในการเล่นเกมยิงแข่งขันอย่าง Fortnite บน Linux

คุณยังเปลี่ยนเครื่อง Omarchy ให้เป็นโฮสต์ได้โดยรัน `omarchy install service sunshine` ซึ่งจะติดตั้ง Sunshine และเปิดพอร์ตสตรีม Moonlight สำหรับ LAN และ Tailscale ของคุณ

## Battle.net

ติดตั้ง [Battle.net](https://eu.shop.battle.net/en-us) โดยเลือก _ติดตั้ง > Gaming > Battle.net_ จากเมนู Omarchy (`Super + Space`) สิ่งนี้ให้คุณมีเกมอย่าง Diablo, Starcraft และ World of Warcraft เป็นการติดตั้งแบบแยกเดี่ยวที่รันใต้ GE-Proton — ไม่ต้องใช้ Steam, Lutris หรือ Heroic

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (เกม Windows)

ติดตั้ง [Lutris](https://lutris.net/) โดยเลือก _ติดตั้ง > Gaming > Lutris_ จากเมนู Omarchy (`Super + Space`) Lutris คือวิธีเล่นเกม Windows จากร้านอย่าง EA และ Ubisoft Connect ที่ไม่มีตัวติดตั้งของตัวเองด้านบน

การติดตั้งค่อนข้างขรุขระและดูเหมือนไม่มีอะไรเกิดขึ้นในบางครั้ง — แค่อดทนไว้ มันกำลังทำงานอยู่เบื้องหลัง

## Heroic Launcher (Epic Games)

ติดตั้ง [Heroic Launcher](https://heroicgameslauncher.com/) โดยเลือก _ติดตั้ง > Gaming > Heroic (Epic Games)_ จากเมนู Omarchy (`Super + Space`) Heroic ให้คุณรันเกม Epic Games อย่าง OddSparks ที่ไม่ได้อาศัยการป้องกันการโกงได้ — บวกกับเกมจาก GOG และ Amazon Prime Gaming น่าเสียดาย นั่นหมายความว่าไม่มี Fortnite และไม่มี Rocket League — จนกว่า Tim Sweeney จะมาที่ Linux นี่ก็ใกล้ที่สุดเท่าที่จะได้แล้ว

เช่นเดียวกับ Lutris มันอาจรู้สึกช้าและขรุขระขณะติดตั้งเกม ให้เวลามันหน่อย
