# Điều hướng

Mọi thứ trong Omarchy đều diễn ra qua bàn phím — _MỌI THỨ!_ Khi hệ thống mới khởi động, bạn thực sự không thể làm được gì chỉ bằng chuột. Nhưng bạn có thể nhấn `Super + Space` để mở Omarchy Menu và từ đây bạn có thể làm gần như mọi thứ.

Nhưng Omarchy menu thậm chí không được thiết kế để là cách chính để vận hành hệ thống trong phần lớn thời gian. Chúng ta có thể nhanh hơn thế! Tất cả các ứng dụng quan trọng nhất đều được gán trực tiếp vào các phím tắt riêng. Bạn mở terminal bằng `Super + Return` và trình duyệt bằng `Super + Shift + Return`. Hãy thử làm lần lượt từng cái, và bạn sẽ thấy sự kỳ diệu của cơ chế xếp cửa sổ của Hyprland đang hoạt động:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Sau đó bạn có thể nhấn `Super + J` để xếp chúng chồng lên nhau thay vì cạnh nhau:

 ![navigation-stacked](images/navigation-stacked.webp)

Nhấn `Super + J` lần nữa để đưa chúng trở lại vị trí cạnh nhau. Sau đó thử `Super + Shift + Arrow Right` khi đang ở trong trình duyệt để hoán đổi các cửa sổ.

Bây giờ thử `Super + Shift + T` để mở Activity monitor. Nó sẽ xuất hiện dưới dạng một cửa sổ nổi. Bạn có thể xếp nó bằng `Super + T` (và nhấn lại để biến nó thành cửa sổ nổi lần nữa). Bây giờ nhấn `Super + Shift + F` để mở trình quản lý tệp. Bạn sẽ có một bố cục bốn cửa sổ gọn gàng:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Bạn điều hướng giữa các cửa sổ mà bạn muốn kích hoạt bằng `Super + Arrow`. Thao tác này sẽ chuyển tiêu điểm và di chuyển con trỏ đến giữa ứng dụng mới. Ở cạnh của một màn hình, nó sẽ tiếp tục sang màn hình ở phía đó.

Nếu bạn nhấn `Super + Shift + 2`, bạn sẽ di chuyển ứng dụng đang được lấy tiêu điểm hiện tại sang workspace thứ hai. `Super + Shift + 1` di chuyển nó trở lại. (Và `Super + Shift + Alt + 2` sẽ di chuyển ứng dụng đang được lấy tiêu điểm hiện tại sang workspace thứ hai mà không chuyển sang đó).

Khi có nhiều màn hình, mỗi màn hình có các workspace từ 1 đến 10 của riêng nó. `Super + 2` đi đến workspace thứ hai của màn hình bạn đang ở, và thanh trên cùng của mỗi màn hình hiển thị các workspace của nó và workspace mà nó đang hiển thị. `Super + Tab` chuyển qua lại giữa các workspace trên màn hình bạn đang ở. `Super + Shift + Ctrl + Arrows` di chuyển cửa sổ bạn đang ở sang màn hình theo hướng đó, vào workspace mà màn hình đó đang hiển thị, và `Super + Shift + Alt + Arrows` di chuyển workspace bạn đang ở sang màn hình theo hướng đó, tại đó nó sẽ giữ cùng số nếu số đó còn trống. Một màn hình vẫn giữ các workspace của nó khi bạn rút nó ra: chúng sẽ nhập vào một màn hình khác, được đánh số sau các workspace mà màn hình đó đã có, và quay trở lại với số cũ của chúng khi màn hình trở lại.

Nếu bạn giữ `Super` và dùng chuột để nhấp vào một cửa sổ, bạn sẽ có thể sắp xếp lại vị trí của nó. Nếu bạn giữ `Super` và dùng nút phải trên chuột, bạn có thể tự do thay đổi kích thước cửa sổ.

Bạn đóng một cửa sổ bằng `Super + W` hoặc `Super + Q` (và đóng tất cả cửa sổ bằng `Ctrl + Alt + Delete`).

Bạn cũng có thể chuyển sang toàn màn hình bằng `Super + F` hoặc thậm chí chỉ toàn chiều rộng (vẫn giữ thanh trên cùng) bằng `Super + Alt + F` hoặc toàn màn hình bên trong một cửa sổ bằng `Super + Ctrl + F` (rất tốt cho YouTube!).

### Bố cục dwindle so với bố cục cuộn

Bố cục mặc định của Omarchy được gọi là dwindle. Nó giữ mọi cửa sổ bạn mở trên một workspace luôn hiển thị mọi lúc, ngay cả khi nó phải thu nhỏ chúng xuống.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Nhưng bạn cũng có thể chọn biến một workspace thành bố cục cuộn, nơi các cửa sổ được xếp cạnh nhau, vượt ra ngoài cạnh hiển thị của màn hình. Bạn biến một workspace đơn lẻ thành bố cục này bằng `Super + L`.

Nhấn `Super + L` lần nữa sẽ biến workspace thành nổi, nơi các cửa sổ chồng lên nhau một cách tự do và bạn tự đặt chúng, và lần nhấn thứ ba sẽ đưa nó trở lại dwindle. `Super + Alt + L` đi qua chúng theo chiều ngược lại. Một cửa sổ vốn đã nổi — một cửa sổ bạn đã bật ra bằng `Super + T`, hoặc một ứng dụng luôn mở dưới dạng nổi — vẫn tiếp tục nổi khi workspace quay trở lại chế độ xếp cửa sổ. Thanh trên cùng đánh dấu workspace bạn đang ở bằng bố cục của nó: một hình vuông cho dwindle, một hình tròn cho cuộn, và một hình tam giác cho nổi. Nhấp vào dấu đó cũng chuyển đổi bố cục, và phím hiển thị trên các laptop có phím đó cũng vậy.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Lựa chọn này áp dụng cho từng workspace, và nó được giữ nguyên. Vì vậy bạn có thể giữ workspace 1 ở dwindle để duyệt web và workspace 2 ở cuộn để viết code, và chúng sẽ trở lại như vậy sau khi khởi động lại.

Nếu bạn muốn sử dụng bố cục cuộn làm mặc định, bạn có thể đặt điều đó trong `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Các workspace nổi

Một workspace nổi hoạt động giống như một desktop truyền thống: các cửa sổ chồng lên nhau, và bạn tự di chuyển và thay đổi kích thước chúng. Mỗi cửa sổ có một thanh tiêu đề với màu sắc của theme của bạn, cùng các nút để thu nhỏ, phóng to và đóng. `Super + M` cũng thu nhỏ cửa sổ đang được lấy tiêu điểm. Một cửa sổ đã thu nhỏ sẽ chờ trong dock; nhấp vào ứng dụng của nó để đưa nó trở lại. Nhấp vào một cửa sổ để đưa nó lên trước. Thay đổi kích thước nó từ bất kỳ cạnh hoặc góc nào. Nhấp đúp vào thanh tiêu đề để phóng to cửa sổ trong khi vẫn giữ thanh trên cùng hiển thị, và nhấp đúp lần nữa để lấy lại kích thước cũ của nó. Chrome và các trình duyệt khác dựa trên Chromium, Disks và Document Viewer bỏ qua thanh tiêu đề và thay vào đó sử dụng header riêng của chúng; `Super + Alt + F` phóng to chúng, và `Super + M` thu nhỏ chúng.

Một workspace nổi cũng hiển thị một dock, với các ứng dụng đã ghim của bạn, mọi thứ đang chạy, và một lưới mọi ứng dụng phía sau nút apps, nút mà `Super + Alt + Space` và _Apps_ trong Omarchy menu cũng mở. Nhấp chuột phải vào một ứng dụng trên lưới, hoặc nhấn `Delete`, để gỡ cài đặt nó. Nhấp vào một ứng dụng để mở nó, hoặc để đưa cửa sổ của nó lên trước; nhấp lần nữa để chuyển qua lại giữa các cửa sổ của nó. Files chỉ đưa trở lại một cửa sổ từ workspace bạn đang ở và nếu không sẽ mở một cửa sổ mới, và Terminal và Agent luôn khởi động một cái khác, mặc dù một cửa sổ đã thu nhỏ sẽ trở lại trước. Nhấp chuột giữa mở một cửa sổ mới. Kéo một biểu tượng dọc theo dock để di chuyển nó; kéo một ứng dụng đang chạy vào giữa các ứng dụng khác sẽ giữ nó ở đó. Nhấp chuột phải để giữ một ứng dụng trong dock, lấy nó ra, hoặc thoát nó. Dock sẽ nhường đường cho một cửa sổ toàn màn hình. Nhấp chuột phải vào nút apps để di chuyển dock sang một cạnh khác hoặc để nó ẩn cho đến khi con trỏ chạm tới cạnh của nó. Vị trí cũng nằm trong _Appearance > Dock > Dock Position_, và `omarchy dock position left` và `omarchy dock autohide on` đặt cả hai từ terminal. Các ứng dụng bạn giữ trong dock sẽ mờ đi khi chúng không chạy.

Các workspace mới, và bất kỳ workspace nào bạn chưa đặt bố cục riêng bằng `Super + L`, sẽ sử dụng bố cục mặc định. Thay đổi mặc định sẽ đặt lại mọi workspace không có cửa sổ thành bố cục đó, trong khi một workspace có cửa sổ trên đó sẽ giữ bố cục mà nó đang có. Một cửa sổ đã thu nhỏ vào dock vẫn được tính là một cửa sổ trên workspace mà nó đã rời khỏi. Chọn nó trong _Appearance > Workspace Layout_: Tiling, Scrolling, hoặc Floating. `omarchy hyprland workspace layout default scrolling` đặt nó từ terminal.

### Nhóm các cửa sổ

Các cửa sổ có thể được nhóm lại bằng `Super + G`. Khi bạn đã ở trong một nhóm, mọi cửa sổ bạn khởi động trong khi nhóm đó đang hoạt động sẽ thuộc về nhóm. Bạn có thể di chuyển giữa các cửa sổ đã nhóm này bằng `Super + Ctrl + Arrow Left/Right` hoặc `Super + Alt + 1/2/3/4` để đi trực tiếp đến các cửa sổ đã nhóm theo thứ tự.

Bạn có thể di chuyển một cửa sổ ra khỏi nhóm bằng `Super + Alt + G` hoặc giải tán toàn bộ nhóm bằng cách nhấn `Super + G` lần nữa. Cuối cùng, bạn có thể di chuyển các cửa sổ bên ngoài nhóm vào trong nhóm bằng `Super + Alt + Arrows`.

### Tách cửa sổ ra

Bạn có thể tách một cửa sổ ra khỏi phân bổ workspace của nó bằng `Super + O`. Thao tác đó sẽ ghim nó thành một cửa sổ nổi đi theo bạn đến bất kỳ workspace nào bạn đi tới. Rất tuyệt cho trình phát video và những thứ tương tự.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Workspace scratchpad

Có một workspace scratchpad đặc biệt có kích thước đầy đủ, nó phủ lên bất kỳ workspace nào bạn đang ở. Bạn truy cập những gì trên đó bằng `Super + S`, và bạn đặt các cửa sổ ở đó bằng `Super + Alt + S`.

Nó hoạt động tốt cho các điều khiển hoặc một terminal mà bạn muốn tương tác nhanh chóng mà không cần rời khỏi workspace hiện tại.

### Console Quake

Cuối cùng, có một console Quake cao bằng nửa màn hình, nó thả xuống trên bất kỳ workspace nào bạn đang ở. Bật/tắt nó bằng `Super + Grave`, và đặt một cửa sổ ở đó bằng `Super + Shift + Grave`.

Lần đầu tiên nó mở, nó khởi động agent mặc định của bạn, hoặc yêu cầu bạn chọn một agent nếu bạn chưa chọn. Trong khi console chỉ chứa một cửa sổ duy nhất, nó thả xuống dưới dạng một bảng ở giữa thay vì trải rộng khắp màn hình. Đặt một ứng dụng thứ hai lên nó và nó sẽ trở lại chiều rộng đầy đủ, để cả hai có chỗ ngồi cạnh nhau.

Để di chuyển một cửa sổ ra khỏi scratchpad hoặc console, hãy gửi nó trực tiếp đến một workspace khác bằng một phím như `Super + Shift + 1`.

### Cần một chút thời gian để làm quen!

Cần một chút thời gian để làm quen với việc điều hướng desktop của bạn như thế này, nhưng một khi bạn đã quen, sẽ rất khó để quay trở lại trải nghiệm desktop truyền thống điều khiển bằng chuột!
