# Điều hướng

Mọi thứ trong Omarchy đều diễn ra qua bàn phím — _MỌI THỨ!_ Khi hệ thống mới khởi động, bạn thực sự không thể làm được gì chỉ với chuột. Nhưng bạn có thể nhấn `Super + Space` để hiển thị Omarchy Menu và từ đây bạn có thể làm gần như mọi thứ.

Nhưng Omarchy menu thậm chí không được thiết kế để trở thành cách chính để vận hành hệ thống trong phần lớn thời gian. Chúng ta có thể làm nhanh hơn thế! Tất cả các ứng dụng quan trọng nhất đều được gán trực tiếp cho từng phím tắt riêng. Bạn khởi động terminal bằng `Super + Return` và trình duyệt bằng `Super + Shift + Return`. Hãy thử làm lần lượt cái này rồi cái kia, và bạn sẽ thấy phép màu xếp lớp của Hyprland hoạt động:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Sau đó bạn có thể nhấn `Super + J` để xếp chúng chồng lên nhau thay vì cạnh nhau:

 ![navigation-stacked](images/navigation-stacked.webp)

Nhấn `Super + J` lần nữa để đưa chúng trở lại vị trí cạnh nhau. Sau đó thử `Super + Shift + Arrow Right` khi đang ở trên trình duyệt để hoán đổi các cửa sổ.

Giờ hãy thử `Super + Shift + T` để khởi động Activity monitor. Nó sẽ xuất hiện dưới dạng cửa sổ nổi. Bạn có thể xếp lớp nó bằng `Super + T` (và nhấn lại phím đó để biến nó thành cửa sổ nổi lần nữa). Giờ nhấn `Super + Shift + F` để mở trình quản lý tệp. Bạn sẽ có một bố cục bốn cửa sổ gọn gàng:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Bạn điều hướng giữa các cửa sổ để chọn cửa sổ đang hoạt động bằng `Super + Arrow`. Thao tác này sẽ chuyển tiêu điểm và di chuyển con trỏ đến giữa ứng dụng mới. Ở cạnh của một màn hình, nó sẽ tiếp tục sang màn hình ở phía đó.

Nếu bạn nhấn `Super + Shift + 2`, bạn sẽ di chuyển ứng dụng đang được chọn hiện tại sang không gian làm việc thứ hai. `Super + Shift + 1` sẽ di chuyển nó trở lại. (Và `Super + Shift + Alt + 2` sẽ di chuyển ứng dụng đang được chọn hiện tại sang không gian làm việc thứ hai mà không chuyển sang đó).

Với nhiều màn hình, mỗi màn hình có các không gian làm việc từ 1 đến 10 của riêng nó. `Super + 2` đi đến không gian làm việc thứ hai của màn hình bạn đang ở, và thanh trên cùng của mỗi màn hình hiển thị các không gian làm việc của nó và không gian làm việc nó đang hiển thị. `Super + Tab` luân chuyển qua các không gian làm việc trên màn hình bạn đang ở. `Super + Shift + Ctrl + Arrows` di chuyển cửa sổ bạn đang ở sang màn hình theo hướng đó, vào không gian làm việc mà màn hình đó đang hiển thị, và `Super + Shift + Alt + Arrows` di chuyển không gian làm việc bạn đang ở sang màn hình theo hướng đó, nơi nó sẽ lấy cùng một số nếu số đó còn trống. Một màn hình giữ lại các không gian làm việc của nó khi bạn rút nó ra: chúng sẽ nhập vào một màn hình khác, được đánh số sau các không gian làm việc mà màn hình đó đã có, và quay trở lại dưới số cũ của chúng khi màn hình trở lại.

Nếu bạn giữ `Super` và dùng chuột để nhấp vào một cửa sổ, bạn sẽ có thể sắp xếp lại vị trí của nó. Nếu bạn giữ `Super` và dùng nút phải của chuột, bạn có thể tự do thay đổi kích thước cửa sổ.

Bạn đóng một cửa sổ bằng `Super + W` hoặc `Super + Q` (và đóng tất cả các cửa sổ bằng `Ctrl + Alt + Delete`).

Bạn cũng có thể chuyển sang toàn màn hình bằng `Super + F` hoặc thậm chí chỉ toàn chiều rộng (giữ lại thanh trên cùng) bằng `Super + Alt + F` hoặc toàn màn hình bên trong một cửa sổ bằng `Super + Ctrl + F` (rất hay cho YouTube!).

### Bố cục dwindle và bố cục cuộn

Bố cục mặc định của Omarchy được gọi là dwindle. Nó giữ mọi cửa sổ bạn mở trên một không gian làm việc luôn hiển thị, ngay cả khi phải thu nhỏ chúng xuống.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Nhưng bạn cũng có thể chọn biến một không gian làm việc thành bố cục cuộn, nơi các cửa sổ được xếp cạnh nhau, vượt ra ngoài cạnh hiển thị của màn hình. Bạn biến một không gian làm việc đơn lẻ thành bố cục này bằng `Super + L`.

Nhấn `Super + L` lần nữa sẽ biến không gian làm việc thành dạng nổi, nơi các cửa sổ chồng chéo tự do và bạn tự đặt chúng, và lần nhấn thứ ba sẽ đưa nó trở lại dwindle. `Super + Alt + L` đi qua chúng theo chiều ngược lại. Một cửa sổ vốn đã nổi — một cửa sổ bạn đã tách ra bằng `Super + T`, hoặc một ứng dụng luôn mở dưới dạng nổi — sẽ tiếp tục nổi khi không gian làm việc quay lại dạng xếp lớp. Thanh trên cùng đánh dấu không gian làm việc bạn đang ở bằng bố cục của nó: một hình vuông cho dwindle, một hình tròn cho dạng cuộn, và một hình tam giác cho dạng nổi. Nhấp vào dấu đó cũng sẽ luân chuyển bố cục.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Lựa chọn này áp dụng cho từng không gian làm việc, và nó được giữ lại. Vì vậy bạn có thể giữ không gian làm việc 1 ở dwindle để duyệt web và không gian làm việc 2 ở dạng cuộn để viết code, và chúng sẽ trở lại như vậy sau khi khởi động lại.

Nếu bạn muốn dùng bố cục cuộn làm mặc định, bạn có thể đặt điều đó trong `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Các không gian làm việc nổi

Một không gian làm việc nổi hoạt động giống như một màn hình nền truyền thống: các cửa sổ chồng chéo, và bạn tự di chuyển và định kích thước chúng. Mỗi cửa sổ có một thanh tiêu đề với màu sắc của theme của bạn, với các nút để thu nhỏ, phóng to và đóng. `Super + M` cũng thu nhỏ cửa sổ đang được chọn. Một cửa sổ đã thu nhỏ sẽ chờ trong dock; hãy nhấp vào ứng dụng của nó để đưa nó trở lại. Nhấp vào một cửa sổ để đưa nó lên phía trước. Thay đổi kích thước nó từ bất kỳ cạnh hoặc góc nào. Nhấp đúp vào thanh tiêu đề để phóng to cửa sổ trong khi vẫn giữ thanh trên cùng trong tầm nhìn, và nhấp đúp lần nữa để lấy lại kích thước cũ của nó.

Một không gian làm việc nổi cũng hiển thị một dock, với các ứng dụng đã ghim của bạn, mọi thứ đang chạy, và một lưới mọi ứng dụng đằng sau nút ứng dụng, nút này cũng được mở bằng `Super + Alt + Space` và _Apps_ trong Omarchy menu. Nhấp chuột phải vào một ứng dụng trên lưới, hoặc nhấn `Delete`, để gỡ cài đặt nó. Nhấp vào một ứng dụng để mở nó, hoặc để đưa cửa sổ của nó lên phía trước; nhấp lần nữa để luân chuyển qua các cửa sổ của nó. Nhấp chuột giữa sẽ mở một cửa sổ mới. Kéo một biểu tượng dọc theo dock để di chuyển nó; kéo một ứng dụng đang chạy vào giữa các ứng dụng khác sẽ giữ nó ở đó. Nhấp chuột phải để giữ một ứng dụng trong dock, lấy nó ra, hoặc thoát nó. Dock sẽ nhường đường cho một cửa sổ toàn màn hình. Nhấp chuột phải vào nút ứng dụng để di chuyển dock sang một cạnh khác hoặc để nó ẩn đi cho đến khi con trỏ chạm tới cạnh của nó. Vị trí cũng nằm trong _Appearance > Dock > Dock Position_, và `omarchy dock position left` cùng `omarchy dock autohide on` đặt cả hai từ terminal. Các ứng dụng bạn giữ trong dock sẽ bị làm mờ trong khi chúng không chạy.

Các không gian làm việc mới, và bất kỳ không gian làm việc nào bạn chưa đặt bố cục riêng bằng `Super + L`, sẽ dùng bố cục mặc định. Thay đổi mặc định sẽ đặt lại mọi không gian làm việc không có cửa sổ về bố cục đó, trong khi một không gian làm việc có cửa sổ trên đó sẽ giữ lại bố cục nó đang có. Một cửa sổ đã thu nhỏ vào dock vẫn được tính là một cửa sổ trên không gian làm việc nó đã rời khỏi. Hãy chọn nó trong _Appearance > Workspace Layout_: Tiling, Scrolling, hoặc Floating. `omarchy-hyprland-workspace-layout-default scrolling` đặt nó từ terminal.

### Nhóm các cửa sổ

Các cửa sổ có thể được nhóm lại bằng `Super + G`. Khi bạn đã ở trong một nhóm, mọi cửa sổ bạn khởi động trong lúc nhóm đó đang hoạt động sẽ thuộc về nhóm. Bạn có thể di chuyển giữa các cửa sổ đã nhóm này bằng `Super + Ctrl + Arrow Left/Right` hoặc `Super + Alt + 1/2/3/4` để đi trực tiếp đến cửa sổ đã nhóm theo thứ tự.

Bạn có thể di chuyển một cửa sổ ra khỏi nhóm bằng `Super + Alt + G` hoặc giải tán toàn bộ nhóm bằng cách nhấn `Super + G` lần nữa. Cuối cùng, bạn có thể di chuyển các cửa sổ bên ngoài nhóm vào trong nhóm bằng `Super + Alt + Arrows`.

### Tách các cửa sổ ra

Bạn có thể tách một cửa sổ ra khỏi phân bổ không gian làm việc của nó bằng `Super + O`. Thao tác đó sẽ ghim nó dưới dạng một cửa sổ nổi đi theo bạn đến bất kỳ không gian làm việc nào bạn đi tới. Rất tuyệt cho trình phát video và những thứ tương tự.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Không gian làm việc scratchpad

Có một không gian làm việc scratchpad đặc biệt có kích thước đầy đủ, phủ lên bất kỳ không gian làm việc nào bạn đang ở. Bạn truy cập những gì trên đó bằng `Super + S`, và bạn đặt các cửa sổ vào đó bằng `Super + Alt + S`.

Nó hoạt động tốt cho các điều khiển hoặc một terminal mà bạn muốn tương tác nhanh chóng mà không rời khỏi không gian làm việc hiện tại.

### Bảng điều khiển Quake

Cuối cùng, có một bảng điều khiển Quake cao bằng nửa màn hình, thả xuống trên bất kỳ không gian làm việc nào bạn đang ở. Bật tắt nó bằng `Super + Grave`, và đặt một cửa sổ vào đó bằng `Super + Shift + Grave`.

Nó mở ra với agent mặc định của bạn đã sẵn sàng hoạt động. Trong khi bảng điều khiển chỉ chứa một cửa sổ duy nhất, nó thả xuống dưới dạng một panel ở giữa thay vì trải dài khắp màn hình. Đặt thêm ứng dụng thứ hai vào đó và nó sẽ trở lại chiều rộng đầy đủ, để hai ứng dụng có chỗ ngồi cạnh nhau.

Để di chuyển một cửa sổ ra khỏi scratchpad hoặc bảng điều khiển, hãy gửi nó trực tiếp đến một không gian làm việc khác bằng phím tắt như `Super + Shift + 1`.

### Cần chút thời gian để làm quen!

Cần một chút thời gian để làm quen với việc điều hướng màn hình nền của bạn như thế này, nhưng một khi đã quen, bạn sẽ khó mà quay lại trải nghiệm màn hình nền truyền thống điều khiển bằng chuột!
