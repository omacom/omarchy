# Điều hướng

Mọi thứ trong Omarchy đều diễn ra qua bàn phím — _MỌI THỨ!_ Khi hệ thống mới khởi động, bạn đúng là không thể làm được bất cứ việc gì chỉ với con chuột. Nhưng bạn có thể nhấn `Super + Space` để hiện Omarchy Menu và từ đây bạn làm được gần như mọi việc.

Nhưng Omarchy Menu thậm chí không được dự định là cách chính để vận hành hệ thống trong hầu hết thời gian. Chúng ta còn có thể nhanh hơn thế! Tất cả các ứng dụng quan trọng nhất đều được gán trực tiếp vào từng phím tắt riêng. Bạn khởi động terminal bằng `Super + Return` và trình duyệt bằng `Super + Shift + Return`. Hãy thử làm cái này rồi đến cái kia, và bạn sẽ thấy phép màu xếp lớp của Hyprland hoạt động:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Sau đó bạn có thể nhấn `Super + J` để xếp chúng chồng lên nhau thay vì đặt cạnh nhau:

 ![navigation-stacked](images/navigation-stacked.webp)

Nhấn `Super + J` lần nữa để đưa chúng trở lại vị trí cạnh nhau. Sau đó hãy thử `Super + Shift + Arrow Right` khi đang ở trên trình duyệt để hoán đổi các cửa sổ.

Bây giờ hãy thử `Super + Ctrl + T` để khởi động trình giám sát Activity. Nó sẽ xuất hiện dưới dạng cửa sổ nổi. Bạn có thể xếp lớp nó bằng `Super + T` (và nhấn lại phím đó để biến nó thành cửa sổ nổi trở lại). Bây giờ nhấn `Super + Shift + F` để mở trình quản lý files. Bạn sẽ có một bố cục bốn phần gọn gàng:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Bạn điều hướng giữa các cửa sổ mà bạn muốn kích hoạt bằng `Super + Arrow`. Thao tác này sẽ chuyển tiêu điểm và di chuyển con trỏ đến giữa ứng dụng mới.

Nếu bạn nhấn `Super + Shift + 2`, bạn sẽ di chuyển ứng dụng đang được tập trung hiện tại sang không gian làm việc thứ hai. `Super + Shift + 1` di chuyển nó trở lại. (Và `Super + Shift + Alt + 2` sẽ di chuyển ứng dụng đang được tập trung hiện tại sang không gian làm việc thứ hai mà không chuyển sang đó).

Nếu bạn giữ `Super` và dùng chuột nhấp vào một cửa sổ, bạn sẽ có thể sắp xếp lại vị trí của nó. Nếu bạn giữ `Super` và dùng nút phải chuột, bạn có thể tự do thay đổi kích thước cửa sổ.

Bạn đóng một cửa sổ bằng `Super + W` hoặc `Super + Q` (và đóng tất cả các cửa sổ bằng `Ctrl + Alt + Delete`).

Bạn cũng có thể chuyển sang toàn màn hình bằng `Super + F` hoặc thậm chí chỉ toàn chiều rộng (vẫn giữ thanh trên cùng) bằng `Super + Alt + F` hoặc toàn màn hình bên trong một cửa sổ bằng `Super + Ctrl + F` (rất tốt cho YouTube!).

### Dwindle so với bố cục cuộn

Bố cục mặc định của Omarchy được gọi là dwindle. Nó giữ tất cả các cửa sổ bạn mở trên một không gian làm việc luôn hiển thị, ngay cả khi phải thu nhỏ chúng xuống.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Nhưng bạn cũng có thể chọn biến một không gian làm việc thành bố cục cuộn, nơi các cửa sổ được xếp cạnh nhau, vượt ra ngoài cạnh hiển thị của màn hình. Bạn biến một không gian làm việc duy nhất thành bố cục này qua `Super + L`.

Nhấn `Super + L` lần nữa sẽ biến không gian làm việc thành dạng nổi, nơi các cửa sổ tự do chồng lên nhau và bạn tự đặt chúng, và nhấn lần thứ ba sẽ đưa nó trở lại dwindle. `Super + Alt + L` đi qua chúng theo chiều ngược lại. Một cửa sổ vốn đã nổi — cửa sổ bạn đã tách ra bằng `Super + T`, hoặc một ứng dụng luôn mở ở dạng nổi — vẫn tiếp tục nổi khi không gian làm việc trở lại dạng xếp lớp. Thanh trên cùng đánh dấu không gian làm việc bạn đang ở bằng bố cục của nó: một hình vuông cho dwindle, một hình tròn cho bố cục cuộn, và một hình tam giác cho dạng nổi. Nhấp vào dấu đó cũng sẽ chuyển đổi bố cục theo vòng tròn.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Lựa chọn này áp dụng theo từng không gian làm việc, và nó được giữ nguyên. Vì vậy bạn có thể giữ không gian làm việc 1 ở dwindle để duyệt web và không gian làm việc 2 ở bố cục cuộn để viết code, và chúng sẽ trở lại như vậy sau khi khởi động lại.

Nếu bạn muốn dùng bố cục cuộn làm mặc định, bạn có thể đặt điều đó trong `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Không gian làm việc nổi

Một không gian làm việc nổi hoạt động như một desktop truyền thống: các cửa sổ chồng lên nhau, và bạn tự di chuyển và thay đổi kích thước chúng. Mỗi cửa sổ có một thanh tiêu đề theo màu sắc của theme của bạn, với các nút để thu nhỏ, phóng to tối đa, và đóng. `Super + M` cũng thu nhỏ cửa sổ đang được tập trung. Một cửa sổ đã thu nhỏ sẽ chờ trong dock; hãy nhấp vào ứng dụng của nó để đưa nó trở lại. Nhấp vào một cửa sổ để đưa nó lên trước. Thay đổi kích thước nó từ bất kỳ cạnh hoặc góc nào. Nhấp đúp vào thanh tiêu đề để phóng to tối đa cửa sổ trong khi vẫn giữ thanh trên cùng trong tầm nhìn, và nhấp đúp lần nữa để lấy lại kích thước cũ.

Một không gian làm việc nổi cũng hiển thị một dock, với các ứng dụng đã ghim của bạn, mọi thứ đang chạy, và một lưới gồm mọi ứng dụng đằng sau nút ứng dụng, thứ mà `Super + Alt + Space` và _Apps_ trong Omarchy menu cũng mở. Nhấp chuột phải vào một ứng dụng trên lưới, hoặc nhấn `Delete`, để gỡ cài đặt nó. Nhấp vào một ứng dụng để mở nó, hoặc để đưa cửa sổ của nó lên trước; nhấp lần nữa để chuyển qua các cửa sổ của nó theo vòng tròn. Nhấp chuột giữa sẽ mở một cửa sổ mới. Kéo một biểu tượng dọc theo dock để di chuyển nó; kéo một ứng dụng đang chạy vào giữa các ứng dụng khác sẽ giữ nó ở đó. Nhấp chuột phải để giữ một ứng dụng trong dock, loại nó ra, hoặc thoát nó. Dock sẽ tránh đường cho một cửa sổ toàn màn hình. Nhấp chuột phải vào nút ứng dụng để di chuyển dock sang một cạnh khác hoặc để nó ẩn đi cho đến khi con trỏ chạm đến cạnh của nó. Vị trí cũng nằm trong _Trigger > Appearance > Dock > Dock Position_, và `omarchy dock position left` và `omarchy dock autohide on` đặt cả hai từ một terminal. Các ứng dụng bạn giữ trong dock sẽ bị mờ đi khi chúng không chạy.

Các không gian làm việc mới, và bất kỳ không gian nào bạn chưa tự cấp một bố cục riêng bằng `Super + L`, sẽ dùng bố cục mặc định. Thay đổi bố cục mặc định sẽ đặt lại mọi không gian làm việc không có cửa sổ về bố cục đó, trong khi một không gian có cửa sổ trên đó sẽ giữ bố cục mà nó đang có. Một cửa sổ được thu nhỏ xuống dock vẫn được tính là một cửa sổ trên không gian làm việc mà nó đã rời khỏi. Hãy chọn nó trong _Trigger > Appearance > Workspace Layout_: Tiling, Scrolling, hoặc Floating. `omarchy-hyprland-workspace-layout-default scrolling` đặt nó từ một terminal.

### Nhóm các cửa sổ

Các cửa sổ có thể được nhóm lại bằng `Super + G`. Khi bạn đã ở trong một nhóm, mọi cửa sổ bạn khởi động trong khi nhóm đó đang hoạt động sẽ thuộc về nhóm. Bạn có thể di chuyển giữa các cửa sổ đã nhóm này bằng `Super + Ctrl + Arrow Left/Right` hoặc `Super + Alt + 1/2/3/4` để đi trực tiếp đến cửa sổ đã nhóm theo thứ tự.

Bạn có thể di chuyển một cửa sổ ra khỏi nhóm bằng `Super + Alt + G` hoặc tháo rời toàn bộ nhóm bằng cách nhấn `Super + G` lần nữa. Cuối cùng, bạn có thể di chuyển các cửa sổ bên ngoài nhóm vào trong nhóm bằng `Super + Alt + Arrows`.

### Tách cửa sổ ra ngoài

Bạn có thể tách một cửa sổ ra khỏi phần được phân bổ trong không gian làm việc của nó bằng `Super + O`. Thao tác đó sẽ ghim nó thành một cửa sổ nổi đi theo bạn đến bất kỳ không gian làm việc nào bạn đi tới. Rất tuyệt cho trình phát video và những thứ tương tự.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Không gian làm việc scratchpad

Cuối cùng, có một không gian làm việc scratchpad đặc biệt thả xuống trên bất kỳ không gian làm việc nào bạn đang ở, rất giống một Quake console. Bật/tắt nó bằng `Super + Grave` hoặc `Super + S`, và đặt một cửa sổ ở đó bằng `Super + Shift + Grave` hoặc `Super + Alt + S`.

Nó hoạt động đặc biệt tốt cho một terminal đang chạy một agent, hoặc cho các điều khiển bạn muốn tương tác nhanh mà không rời khỏi không gian làm việc hiện tại. Để di chuyển một cửa sổ khỏi scratchpad, hãy gửi nó trực tiếp đến một không gian làm việc khác bằng một phím như `Super + Shift + 1`.

Trong khi scratchpad chứa một cửa sổ duy nhất, nó thả xuống dưới dạng một bảng ở giữa thay vì trải rộng khắp màn hình. Đặt một ứng dụng thứ hai lên đó và nó trở lại toàn bộ chiều rộng, để cả hai có chỗ ngồi cạnh nhau.

### Cần chút thời gian để làm quen!

Cần một chút thời gian để làm quen với việc điều hướng desktop của bạn như thế này, nhưng một khi bạn đã quen, sẽ khó mà quay lại trải nghiệm desktop truyền thống điều khiển bằng chuột!
