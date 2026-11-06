# Chơi game

Omarchy không chỉ dành cho _nĂnG SuẤt_, nó còn để giải trí, và còn gì vui hơn chơi game? Omarchy đi kèm một bộ đầy đủ các lựa chọn chơi game — Steam và RetroArch cho chơi game gốc và game hoài cổ, Battle.net, Lutris và Heroic cho các cửa hàng ngoài Steam, Moonlight cho phát trực tuyến từ PC, Xbox Cloud Gaming + NVIDIA GeForce NOW cho chơi game trên đám mây, cộng thêm Minecraft bất hủ.

Nhờ công việc đáng kinh ngạc của Valve trên [lớp tương thích proton](https://en.wikipedia.org/wiki/Proton_(software)), hiện có hàng chục nghìn trò chơi hiện đại có thể chơi được trên Linux. À, và bạn có biết rằng [Steam Deck](https://store.steampowered.com/steamdeck/) thực ra chạy Arch không!

Mọi trình cài đặt chơi game đều nằm trong _Cài đặt > Chơi game_ trong menu Omarchy (`Super + Space`). Nếu bạn muốn gỡ bỏ một cái, hãy dùng _Gỡ bỏ > Chơi game_.

## Steam

Cài đặt [Steam](https://store.steampowered.com/) bằng cách chọn _Cài đặt > Chơi game > Steam_ từ menu Omarchy (`Super + Space`).

Sau khi bạn đã cài đặt nó, bạn sẽ có thể khởi chạy Steam bằng `Super + Space`.

Lưu ý rằng Steam có thể mất 10-20 giây để khởi động, và nó sẽ không cung cấp bất kỳ phản hồi hình ảnh nào cho thấy nó đang tải.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Cài đặt [RetroArch](https://www.retroarch.com/) bằng cách chọn _Cài đặt > Chơi game > RetroArch_ từ menu Omarchy (`Super + Space`). Nó đi kèm bộ đầy đủ các lõi libretro, vì vậy mọi hệ thống cổ điển đều được bao phủ.

RetroArch được cấu hình sẵn hoàn toàn với shader CRT Royale tuyệt đẹp cho diện mạo hoài cổ hoàn hảo đó.

Để bắt đầu:

1. Thả các tệp BIOS của bạn vào `~/Games/bios` và các ROM của bạn vào `~/Games/roms`.
2. Khởi chạy RetroArch bằng `Super + Space` và gõ `retro`.
3. Quét thư mục `~/Games/roms` và bạn đã sẵn sàng chơi.

Bạn cũng có thể tạo cho một trò chơi yêu thích một mục riêng trong trình khởi chạy ứng dụng bằng _Cài đặt > Chơi game > Trình khởi chạy trò chơi RetroArch_, cho phép bạn chọn một lõi và một ROM, và nhảy thẳng vào trò chơi từ `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Cài đặt ứng dụng web Xbox Cloud Gaming bằng cách chọn _Cài đặt > Chơi game > Xbox Cloud Gaming_ từ menu Omarchy (`Super + Space`). Nó "chỉ" là một ứng dụng web cho dịch vụ, nhưng nó khởi động nhanh và chạy tuyệt vời ở 1080p.

Nếu bạn đã có Xbox Game Pass, đây là một cách vững chắc để chơi Fortnite và các tựa game khác mà bạn không thể chạy gốc trên Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Cài đặt dịch vụ chơi game trên đám mây [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) bằng cách chọn _Cài đặt > Chơi game > NVIDIA GeForce NOW_ từ menu Omarchy (`Super + Space`). Một cách tuyệt vời khác để chơi các tựa game không có sẵn gốc trên Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Cài đặt Minecraft bằng cách chọn _Cài đặt > Chơi game > Minecraft_ từ menu Omarchy (`Super + Space`).

Giống như Steam, lưu ý rằng có thể mất một lúc sau khi đăng nhập hoặc khởi động để màn hình tiếp theo xuất hiện, và bạn sẽ không nhận được bất kỳ phản hồi nào trong khi chờ đợi.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Tay cầm Xbox

Cài đặt hỗ trợ cho tay cầm Xbox qua Bluetooth bằng cách chọn _Cài đặt > Chơi game > Tay cầm Xbox_ từ menu Omarchy (`Super + Space`). Ghép nối các tay cầm qua Bluetooth (`Super + Ctrl + B`) và chúng sẽ hoạt động trong mọi trò chơi của bạn. Bạn không cần điều này nếu bạn chỉ kết nối tay cầm bằng cáp USB-C.

## Moonlight (Phát trực tuyến trò chơi từ một PC)

Ứng dụng khách [Moonlight](https://github.com/moonlight-stream/moonlight-qt) được cài sẵn với Omarchy, vì vậy bạn có thể phát trực tuyến trò chơi từ một PC Windows đang chạy [Sunshine](https://app.lizardbyte.dev/Sunshine/) ngay lập tức. Khởi chạy Moonlight qua `Super + Space`.

Nếu cả máy Omarchy của bạn và PC chơi game từ xa đều được nối dây, trải nghiệm sẽ không thể phân biệt được với việc chơi cục bộ. Tăng độ phân giải lên mức gốc, đặt tốc độ làm tươi ở 120Hz, và tối đa hóa tốc độ bit — đây là cách tốt nhất để chơi các trò bắn súng cạnh tranh như Fortnite trên Linux.

Bạn cũng có thể biến một máy Omarchy thành máy chủ bằng cách chạy `omarchy install service sunshine`, lệnh này cài đặt Sunshine và mở các cổng phát trực tuyến Moonlight cho mạng LAN và Tailscale của bạn.

## Battle.net

Cài đặt [Battle.net](https://eu.shop.battle.net/en-us) bằng cách chọn _Cài đặt > Chơi game > Battle.net_ từ menu Omarchy (`Super + Space`). Điều này cho bạn các tựa game như Diablo, Starcraft và World of Warcraft dưới dạng một bản cài đặt độc lập chạy dưới GE-Proton — không cần Steam, Lutris hay Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Trò chơi Windows)

Cài đặt [Lutris](https://lutris.net/) bằng cách chọn _Cài đặt > Chơi game > Lutris_ từ menu Omarchy (`Super + Space`). Lutris là cách để chơi các trò chơi Windows từ các cửa hàng như EA và Ubisoft Connect mà không có trình cài đặt riêng ở trên.

Quá trình cài đặt hơi trục trặc và đôi khi trông như không có gì đang xảy ra — cứ kiên nhẫn, nó đang hoạt động ở chế độ nền.

## Heroic Launcher (Epic Games)

Cài đặt [Heroic Launcher](https://heroicgameslauncher.com/) bằng cách chọn _Cài đặt > Chơi game > Heroic (Epic Games)_ từ menu Omarchy (`Super + Space`). Heroic cho phép bạn chạy các tựa game Epic Games, như OddSparks, mà không dựa vào chống gian lận — cộng thêm các trò chơi từ GOG và Amazon Prime Gaming. Đáng tiếc, điều đó có nghĩa là không có Fortnite và không có Rocket League — cho đến khi Tim Sweeney đến với Linux, đây là mức gần nhất có thể.

Giống như Lutris, nó có thể cảm thấy chậm và trục trặc khi cài đặt trò chơi. Hãy cho nó thời gian.
