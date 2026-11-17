# Chơi game

Omarchy không chỉ dành cho _pRoDUcTiVItY_, mà còn để vui chơi, và còn gì vui hơn chơi game? Omarchy đi kèm cả một bộ lựa chọn chơi game — Steam và RetroArch cho game gốc và game retro, Battle.net, Lutris, và Heroic cho các cửa hàng ngoài Steam, Moonlight cho streaming từ PC, Xbox Cloud Gaming + NVIDIA GeForce NOW cho cloud, cộng thêm Minecraft bất hủ.

Nhờ công trình đáng kinh ngạc của Valve trên [lớp tương thích proton](https://en.wikipedia.org/wiki/Proton_(software)), giờ đây đã có hàng chục nghìn game hiện đại chơi được trên Linux. Ồ, và bạn có biết [Steam Deck](https://store.steampowered.com/steamdeck/) thực ra chạy Arch không!

Tất cả trình cài đặt game đều nằm trong _Install > Gaming_ trong menu Omarchy (`Super + Space`). Nếu bao giờ muốn gỡ bỏ một cái, hãy dùng _Remove > Gaming_.

## Steam

Cài [Steam](https://store.steampowered.com/) bằng cách chọn _Install > Gaming > Steam_ từ menu Omarchy (`Super + Space`).

Sau khi cài xong, bạn sẽ có thể khởi chạy Steam bằng `Super + Space`.

Lưu ý rằng Steam có thể mất 10-20 giây để khởi động, và nó sẽ không hiển thị bất kỳ phản hồi trực quan nào cho thấy nó đang tải.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Cài [RetroArch](https://www.retroarch.com/) bằng cách chọn _Install > Gaming > RetroArch_ từ menu Omarchy (`Super + Space`). Nó đi kèm bộ đầy đủ các core libretro, vì vậy mọi hệ máy cổ điển đều được hỗ trợ.

RetroArch được cấu hình sẵn hoàn toàn với shader CRT Royale tuyệt đẹp để có vẻ ngoài retro hoàn hảo đó.

Để bắt đầu:

1. Thả các file BIOS của bạn vào `~/Games/bios` và ROM của bạn vào `~/Games/roms`.
2. Khởi chạy RetroArch bằng `Super + Space` và gõ `retro`.
3. Quét thư mục `~/Games/roms` và bạn đã sẵn sàng chơi.

Bạn cũng có thể tạo cho một game yêu thích mục riêng của nó trong trình khởi chạy ứng dụng bằng _Install > Gaming > RetroArch Game Launcher_, cho phép bạn chọn một core và một ROM, rồi nhảy thẳng vào game từ `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Cài web app Xbox Cloud Gaming bằng cách chọn _Install > Gaming > Xbox Cloud Gaming_ từ menu Omarchy (`Super + Space`). Nó "chỉ" là một web app cho dịch vụ, nhưng khởi động nhanh và chạy rất tốt ở 1080p.

Nếu bạn đã có Xbox Game Pass, đây là một cách chắc chắn để chơi Fortnite và các tựa game khác mà bạn không thể chạy gốc trên Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Cài dịch vụ chơi game trên cloud [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) bằng cách chọn _Install > Gaming > NVIDIA GeForce NOW_ từ menu Omarchy (`Super + Space`). Một cách tuyệt vời khác để chơi các tựa game không có sẵn gốc trên Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Cài Minecraft bằng cách chọn _Install > Gaming > Minecraft_ từ menu Omarchy (`Super + Space`).

Giống Steam, lưu ý rằng nó có thể mất một lúc sau khi đăng nhập hoặc khởi động thì màn hình tiếp theo mới xuất hiện, và bạn sẽ không nhận được bất kỳ phản hồi nào trong lúc chờ.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Tay cầm Xbox

Cài hỗ trợ cho tay cầm Xbox Bluetooth bằng cách chọn _Install > Gaming > Xbox Controllers_ từ menu Omarchy (`Super + Space`). Ghép nối tay cầm qua Bluetooth (`Super + Ctrl + B`) và chúng sẽ hoạt động trong mọi game của bạn. Bạn không cần cái này nếu chỉ cắm cứng tay cầm bằng cáp USB-C.

## Moonlight (Streaming game từ PC)

Cài [Moonlight client](https://github.com/moonlight-stream/moonlight-qt) bằng cách chọn _Install > Gaming > Moonlight_ từ menu Omarchy (`Super + Space`), và bạn có thể stream game từ một PC Windows đang chạy [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Nếu cả máy Omarchy của bạn và PC chơi game từ xa đều cắm dây, trải nghiệm sẽ không thể phân biệt được với chơi tại chỗ. Tăng độ phân giải lên mức gốc, đặt tần số quét thành 120Hz, và tối đa hoá bitrate — đây là cách tốt nhất để chơi các game bắn súng cạnh tranh như Fortnite trên Linux.

Bạn cũng có thể biến một máy Omarchy thành máy chủ bằng cách chạy `omarchy install service sunshine`, lệnh này cài Sunshine và mở các cổng streaming Moonlight cho LAN và Tailscale của bạn.

## Battle.net

Cài [Battle.net](https://eu.shop.battle.net/en-us) bằng cách chọn _Install > Gaming > Battle.net_ từ menu Omarchy (`Super + Space`). Cái này cho bạn các tựa game như Diablo, Starcraft, và World of Warcraft dưới dạng bản cài đặt độc lập chạy bằng GE-Proton — không cần Steam, Lutris, hay Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Game Windows)

Cài [Lutris](https://lutris.net/) bằng cách chọn _Install > Gaming > Lutris_ từ menu Omarchy (`Super + Space`). Lutris là cách để chơi game Windows từ các cửa hàng như EA và Ubisoft Connect mà không có trình cài đặt riêng của chúng ở trên.

Việc cài đặt hơi ì ạch và đôi khi trông như không có gì đang xảy ra — cứ kiên nhẫn, nó đang hoạt động trong nền.

## Heroic Launcher (Epic Games)

Cài [Heroic Launcher](https://heroicgameslauncher.com/) bằng cách chọn _Install > Gaming > Heroic (Epic Games)_ từ menu Omarchy (`Super + Space`). Heroic cho phép bạn chạy các tựa Epic Games, như OddSparks, không dựa vào anti-cheat — cộng thêm game từ GOG và Amazon Prime Gaming. Đáng buồn thay, điều đó có nghĩa là không có Fortnite và không có Rocket League — cho đến khi Tim Sweeney đến với Linux, đây là mức gần nhất có thể rồi.

Giống Lutris, nó có thể cảm thấy chậm và ì ạch khi đang cài game. Hãy cho nó thời gian.
