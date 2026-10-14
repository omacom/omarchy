# การสนับสนุน Mac

Omarchy มีการสนับสนุนในตัวสำหรับ **Intel Macs** มีข้อจำกัดที่ทราบกันอยู่สองสามข้อในตอนนี้ แต่ตราบใดที่คุณตระหนักและโอเคกับข้อจำกัดเหล่านั้น คุณก็สามารถชุบชีวิตใหม่ให้ Mac เครื่องเก่าของคุณได้โดยการโหลด Omarchy

โปรดทราบว่าการติดตั้งบน Mac ซีรีส์ M ยังไม่ได้รับการสนับสนุนโดยตรงในขณะนี้ คุณสามารถหาข้อมูลเพิ่มเติมเกี่ยวกับสถานะของเรื่องนี้ได้ใน #omarchy-on-other ใน [Discord](https://discord.gg/tXFUdasqhY) ของเรา

ในการทดสอบง่าย ๆ เราสามารถทำประสิทธิภาพเพิ่ม 36% บน MacBook Pro ปี 2019 ได้แค่โดยการติดตั้ง Omarchy

 ![macbook-omarchy](images/macbook-omarchy.webp)

### การติดตั้ง Omarchy บน Mac

Omarchy สนับสนุนการเป็น OS **เดียว** ที่ติดตั้งในขณะนี้เท่านั้น ระหว่างการติดตั้ง ไดรฟ์จะถูกล้างและ MacOS จะบูตไม่ได้อีกต่อไป

คุณยังกู้คืนมันได้ภายหลังผ่าน Internet Recovery ถ้าคุณต้องการ

สำหรับส่วนนี้ เราจะสมมติว่าคุณได้ทบทวน [เริ่มต้นใช้งาน](02-getting-started.md) แล้วและมีไดรฟ์ USB พร้อม ถ้าคุณยังไม่มี ไปทำตอนนี้เลย

#### ปิดใช้งาน Secure Boot

จำเป็นต้องปิดใช้งาน Secure Boot ของ Apple เพื่อบูต USB ที่บูตได้ รวมถึงตัว OS เอง หากต้องการปิดใช้งาน ให้ทำดังต่อไปนี้:

1. ปิด Mac ของคุณ
2. เปิดมันและกด Command-R ค้างไว้ _ทันที_ จนกว่าคุณจะเห็นหน้าจอโหลดปรากฏ
3. เลือกผู้ใช้ของคุณและป้อนรหัสผ่านถ้าถูกขอ
4. เมื่ออยู่ในหน้าจอกู้คืนแล้ว เลือก **Utilities > Startup Security Utility** จากแถบเมนู
5. ป้อนรหัสผ่านเมื่อถูกขอให้ยืนยันตัวตน
6. เลือก "No Security" จากตัวเลือก Secure Boot
7. เลือก "Allow booting from external or removable media" จากตัวเลือก External Boot

#### เริ่มการติดตั้ง

1. เสียบไดรฟ์ USB
2. รีสตาร์ต Mac ของคุณและกด Option ค้างไว้ _ทันที_ จนกว่าคุณจะเห็นหน้าจออุปกรณ์บูต
3. เลือกอุปกรณ์ EFI Boot สีส้ม
4. ดำเนินการ [ติดตั้งตามปกติ](02-getting-started.md)

ตัวติดตั้งตรวจจับฮาร์ดแวร์ Mac และใช้การแก้ไขที่จำเป็นโดยอัตโนมัติ: ไดรเวอร์และเฟิร์มแวร์ Wi-Fi Broadcom ไดรเวอร์คีย์บอร์ด SPI บนรุ่น MacBook ที่ต้องการมัน และการแก้ไขการพักเครื่อง NVMe สำหรับรุ่นเดียวกันเหล่านั้น

### ข้อจำกัดที่ทราบ

สมาชิกของชุมชนกำลังทำงานอย่างต่อเนื่องหาทางแก้สำหรับความท้าทายเหล่านี้ ดังนั้นถ้าสิ่งเหล่านี้เป็นปัญหาสำหรับคุณ เข้าร่วม #omarchy-on-other ใน [Discord](https://discord.gg/tXFUdasqhY) ของเราและดูว่ามีวิธีที่ทันสมัยสำหรับการแก้ปัญหาเหล่านี้หรือไม่

#### อุปกรณ์ที่มีชิป T1

ชิป Apple T1 ถูกเปิดตัวปลายปี 2016 และใช้เฉพาะใน MacBook Pro รุ่นแรกที่มี Touch Bar
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### ปัญหาที่ทราบ

- Touch Bar ใช้งานไม่ได้
- เสียงใช้งานไม่ได้

#### อุปกรณ์ที่มีชิป T2

ชิปความปลอดภัย Apple T2 ถูกเปิดตัวในปี 2017 ชิป T2 ถูกยกเลิกไปพร้อมกับการเปลี่ยนไปสู่ Apple silicon (ชิปซีรีส์ M) ตั้งแต่ปี 2020

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

บนรุ่นเหล่านี้ ตัวติดตั้งจะตั้งค่าเคอร์เนล `linux-t2` ที่แพตช์แล้ว การกำหนดค่าเสียง T2 เฟิร์มแวร์ Wi-Fi/Bluetooth Broadcom ของ Apple และการควบคุมพัดลมผ่าน `t2fanrd` โดยอัตโนมัติ Touch Bar ทำงานบนการสนับสนุนสไตล์ Boot Camp ในตัวของเคอร์เนล
