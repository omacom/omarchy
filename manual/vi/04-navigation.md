# Điều hướng

Mọi thứ trong Omarchy đều diễn ra qua bàn phím — _MỌI THỨ!_ Khi hệ thống mới khởi động, bạn thực sự không thể làm được gì chỉ bằng chuột. Nhưng bạn có thể nhấn `Super + Space` để mở Omarchy Menu và từ đây bạn có thể làm gần như mọi thứ.

Nhưng menu Omarchy thậm chí không được dự định là cách chính để vận hành hệ thống trong hầu hết thời gian. Chúng ta có thể nhanh hơn thế! Tất cả các ứng dụng quan trọng nhất đều được gắn trực tiếp vào các phím tắt riêng lẻ. Bạn khởi động terminal bằng `Super + Return` và một trình duyệt bằng `Super + Shift + Return`. Hãy thử làm cái này nối tiếp cái kia, và bạn sẽ thấy điều kỳ diệu của tiling của Hyprland trong thực tế:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Sau đó bạn có thể nhấn `Super + J` để xếp chồng chúng lên nhau thay vì đặt cạnh nhau:

 ![navigation-stacked](images/navigation-stacked.webp)

Nhấn `Super + J` lần nữa để đưa chúng trở lại vị trí cạnh nhau. Sau đó hãy thử `Super + Shift + Arrow Right` trong khi đang ở trong trình duyệt để hoán đổi các cửa sổ.

Bây giờ hãy thử `Super + Shift + T` để khởi động Activity monitor. Nó sẽ xuất hiện dưới dạng một cửa sổ nổi. Bạn có thể xếp nó theo dạng tiling bằng `Super + T` (và nhấn phím đó lần nữa để làm nó nổi trở lại). Bây giờ nhấn `Super + Shift + F` để mở trình quản lý tệp. Bạn sẽ có một bố cục bốn góc gọn gàng:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Bạn điều hướng giữa các cửa sổ muốn kích hoạt bằng `Super + Arrow`. Điều này sẽ chuyển focus và di chuyển con trỏ đến trung tâm của ứng dụng mới. Ở cạnh của một màn hình, nó tiếp tục sang màn hình ở phía đó.

Nếu bạn nhấn `Super + Shift + 2`, bạn sẽ di chuyển ứng dụng đang được focus hiện tại sang không gian làm việc thứ hai. `Super + Shift + 1` di chuyển nó trở lại. (Và `Super + Shift + Alt + 2` sẽ di chuyển ứng dụng đang được focus hiện tại sang không gian làm việc thứ hai mà không chuyển sang nó).

Với nhiều màn hình, mỗi màn hình có các không gian làm việc từ 1 đến 10 của riêng nó. `Super + 2` đi đến không gian làm việc thứ hai của màn hình bạn đang ở, và thanh trên cùng của mỗi màn hình hiển thị các không gian làm việc của riêng nó và không gian nó đang hiển thị. `Super + Tab` chuyển vòng qua các không gian làm việc trên màn hình bạn đang ở. `Super + Shift + Ctrl + Arrows` di chuyển cửa sổ bạn đang ở sang màn hình theo hướng đó, vào không gian làm việc mà màn hình đó đang hiển thị, và `Super + Shift + Alt + Arrows` di chuyển không gian làm việc bạn đang ở sang màn hình theo hướng đó, tại đó nó lấy cùng số nếu số đó còn trống. Một màn hình giữ các không gian làm việc của nó khi bạn rút nó ra: chúng nhập vào một màn hình khác, được đánh số tiếp sau những số màn hình đó đã có, và trở lại dưới các số cũ khi màn hình quay trở lại.

Nếu bạn giữ `Super` và dùng chuột nhấp vào một cửa sổ, bạn sẽ có thể sắp xếp lại vị trí của nó. Nếu bạn giữ `Super` và dùng nút phải chuột, bạn có thể tự do thay đổi kích thước cửa sổ.

Bạn đóng một cửa sổ bằng `Super + W` hoặc `Super + Q` (và đóng tất cả các cửa sổ bằng `Ctrl + Alt + Delete`).

Bạn cũng có thể chuyển sang toàn màn hình bằng `Super + F` hoặc thậm chí chỉ toàn chiều rộng (giữ thanh trên cùng) bằng `Super + Alt + F` hoặc toàn màn hình trong một cửa sổ bằng `Super + Ctrl + F` (tốt cho YouTube!).

### Bố cục dwindle so với scrolling

Bố cục mặc định của Omarchy được gọi là dwindle. Nó giữ mọi cửa sổ bạn mở trên một không gian làm việc luôn hiển thị, ngay cả khi phải thu nhỏ chúng xuống.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Nhưng bạn cũng có thể chọn chuyển một không gian làm việc thành bố cục scrolling, trong đó các cửa sổ được xếp cạnh nhau, vượt ra ngoài cạnh có thể nhìn thấy của màn hình. Bạn chuyển một không gian làm việc duy nhất thành bố cục này bằng `Super + L`.

Nhấn `Super + L` lần nữa sẽ biến không gian làm việc thành dạng nổi, trong đó các cửa sổ chồng lên nhau tự do và bạn tự đặt chúng, và lần nhấn thứ ba đưa nó trở lại dwindle. `Super + Alt + L` đi qua chúng theo chiều ngược lại. Một cửa sổ vốn đã nổi — một cửa sổ bạn đã bật ra bằng `Super + T`, hoặc một ứng dụng luôn mở ở dạng nổi — vẫn giữ dạng nổi khi không gian làm việc trở lại dạng tiling. Thanh trên cùng đánh dấu không gian làm việc bạn đang ở bằng bố cục của nó: một hình vuông cho dwindle, một hình tròn cho scrolling, và một hình tam giác cho floating. Nhấp vào dấu đó cũng chuyển vòng qua các bố cục.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Lựa chọn này áp dụng theo từng không gian làm việc, và nó được giữ nguyên. Vì vậy bạn có thể giữ không gian làm việc 1 ở dwindle để duyệt web và không gian làm việc 2 ở scrolling để viết code, và chúng sẽ trở lại như vậy sau khi khởi động lại.

Nếu bạn muốn sử dụng bố cục scrolling làm mặc định, bạn có thể đặt điều đó trong `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Các không gian làm việc nổi

Một không gian làm việc nổi hoạt động như một desktop truyền thống: các cửa sổ chồng lên nhau, và bạn tự di chuyển và thay đổi kích thước chúng. Mỗi cửa sổ có một thanh tiêu đề theo màu sắc của theme của bạn, với các nút để thu nhỏ, phóng to và đóng. `Super + M` cũng thu nhỏ cửa sổ đang được focus. Một cửa sổ đã thu nhỏ sẽ chờ trong dock; nhấp vào ứng dụng của nó để đưa nó trở lại. Nhấp vào một cửa sổ để đưa nó lên phía trước. Thay đổi kích thước nó từ bất kỳ cạnh hoặc góc nào. Nhấp đúp vào một thanh tiêu đề để phóng to cửa sổ trong khi vẫn giữ thanh trên cùng trong tầm nhìn, và nhấp đúp lần nữa để lấy lại kích thước cũ của nó. Chrome và các trình duyệt dựa trên Chromium khác, Disks và Document Viewer bỏ qua thanh tiêu đề và thay vào đó sử dụng header của riêng chúng; `Super + Alt + F` phóng to chúng, và `Super + M` thu nhỏ chúng.

Một không gian làm việc nổi cũng hiển thị một dock, với các ứng dụng đã ghim của bạn, mọi thứ đang chạy, và một lưới mọi ứng dụng đằng sau nút apps, mà `Super + Alt + Space` và _Apps_ trong menu Omarchy cũng mở. Nhấp chuột phải vào một ứng dụng trên lưới, hoặc nhấn `Delete`, để gỡ cài đặt nó. Nhấp vào một ứng dụng để mở nó, hoặc để đưa cửa sổ của nó lên phía trước; nhấp lần nữa để chuyển vòng qua các cửa sổ của nó. Nhấp chuột giữa mở một cửa sổ mới. Kéo một biểu tượng dọc theo dock để di chuyển nó; kéo một ứng dụng đang chạy vào giữa các ứng dụng khác sẽ giữ nó ở đó. Nhấp chuột phải để giữ một ứng dụng trong dock, đưa nó ra, hoặc thoát nó. Dock tránh đường cho một cửa sổ toàn màn hình. Nhấp chuột phải vào nút apps để di chuyển dock sang một cạnh khác hoặc để nó ẩn cho đến khi con trỏ chạm tới cạnh của nó. Vị trí cũng nằm dưới _Appearance > Dock > Dock Position_, và `omarchy dock position left` và `omarchy dock autohide on` đặt cả hai từ một terminal. Các ứng dụng bạn giữ trong dock sẽ bị làm mờ trong khi chúng không chạy.

Các không gian làm việc mới, và bất kỳ không gian nào bạn chưa tự cho một bố cục bằng `Super + L`, sử dụng bố cục mặc định. Thay đổi bố cục mặc định đặt lại mọi không gian làm việc không có cửa sổ về bố cục đó, trong khi một không gian có cửa sổ trên đó giữ bố cục nó đang có. Một cửa sổ đã thu nhỏ vào dock vẫn tính là một cửa sổ trên không gian làm việc nó đã rời đi. Chọn nó dưới _Appearance > Workspace Layout_: Tiling, Scrolling, hoặc Floating. `omarchy-hyprland-workspace-layout-default scrolling` đặt nó từ một terminal.

### Nhóm các cửa sổ

Các cửa sổ có thể được nhóm bằng `Super + G`. Khi bạn đã ở trong một nhóm, mọi cửa sổ bạn khởi động trong khi nhóm đó đang hoạt động sẽ thuộc về nhóm. Bạn có thể di chuyển giữa các cửa sổ đã nhóm này bằng `Super + Ctrl + Arrow Left/Right` hoặc `Super + Alt + 1/2/3/4` để đi trực tiếp đến các cửa sổ đã nhóm theo thứ tự.

Bạn có thể di chuyển một cửa sổ ra khỏi nhóm bằng `Super + Alt + G` hoặc giải tán toàn bộ nhóm bằng cách nhấn `Super + G` lần nữa. Cuối cùng, bạn có thể di chuyển các cửa sổ bên ngoài nhóm vào trong nó bằng `Super + Alt + Arrows`.

### Bật cửa sổ ra

Bạn có thể bật một cửa sổ ra khỏi vị trí không gian làm việc của nó bằng `Super + O`. Điều đó sẽ ghim nó như một cửa sổ nổi đi theo bạn đến bất kỳ không gian làm việc nào bạn đi tới. Tuyệt vời cho các trình phát video và những thứ tương tự.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Không gian làm việc scratchpad

Có một không gian làm việc scratchpad đặc biệt có kích thước đầy đủ phủ lên bất kỳ không gian làm việc nào bạn đang ở. Bạn truy cập những gì trên đó bằng `Super + S`, và bạn đặt các cửa sổ ở đó bằng `Super + Alt + S`.

Nó hoạt động tốt cho các điều khiển hoặc một terminal bạn muốn tương tác nhanh mà không rời khỏi không gian làm việc hiện tại.

### Bảng điều khiển Quake

Cuối cùng, có một bảng điều khiển Quake cao nửa màn hình thả xuống trên bất kỳ không gian làm việc nào bạn đang ở. Bật/tắt nó bằng `Super + Grave`, và đặt một cửa sổ ở đó bằng `Super + Shift + Grave`.

Nó mở ra với agent mặc định của bạn sẵn sàng hoạt động. Trong khi bảng điều khiển chỉ chứa một cửa sổ duy nhất, nó thả xuống dưới dạng một bảng ở giữa thay vì trải rộng khắp màn hình. Đặt một ứng dụng thứ hai lên nó và nó trở lại chiều rộng đầy đủ, để cả hai có chỗ ngồi cạnh nhau.

Để di chuyển một cửa sổ ra khỏi scratchpad hoặc bảng điều khiển, hãy gửi nó trực tiếp đến một không gian làm việc khác bằng một phím như `Super + Shift + 1`.

### Cần chút thời gian để làm quen!

Cần một chút thời gian để làm quen với việc điều hướng desktop của bạn như thế này, nhưng một khi đã quen, bạn sẽ khó quay lại trải nghiệm desktop truyền thống điều khiển bằng chuột!
