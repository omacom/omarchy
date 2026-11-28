# Điều hướng

Mọi thứ trong Omarchy đều diễn ra qua bàn phím — _MỌI THỨ!_ Khi hệ thống mới khởi động, bạn thực sự không thể làm được gì chỉ bằng chuột. Nhưng bạn có thể nhấn `Super + Space` để mở Omarchy Menu và từ đây bạn có thể làm gần như mọi thứ.

Nhưng Omarchy menu thậm chí còn không được dự định là cách chính để vận hành hệ thống trong hầu hết thời gian. Chúng ta có thể nhanh hơn thế! Tất cả các ứng dụng quan trọng nhất đều được gán trực tiếp vào từng phím tắt riêng. Bạn khởi chạy terminal bằng `Super + Return` và trình duyệt bằng `Super + Shift + Return`. Hãy thử làm lần lượt cái này rồi cái kia, và bạn sẽ thấy phép màu xếp lớp của Hyprland phát huy tác dụng:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Sau đó bạn có thể nhấn `Super + J` để xếp chúng chồng lên nhau thay vì nằm cạnh nhau:

 ![navigation-stacked](images/navigation-stacked.webp)

Nhấn `Super + J` lần nữa để đưa chúng trở lại vị trí nằm cạnh nhau. Sau đó thử `Super + Shift + Arrow Right` khi đang ở trong trình duyệt để hoán đổi các cửa sổ.

Giờ hãy thử `Super + Shift + T` để khởi chạy Activity monitor. Nó sẽ xuất hiện dưới dạng cửa sổ nổi. Bạn có thể xếp lớp nó bằng `Super + T` (và nhấn lại phím đó để biến nó thành cửa sổ nổi trở lại). Giờ nhấn `Super + Shift + F` để mở trình quản lý tệp. Bạn sẽ có một bố cục bốn cửa sổ gọn gàng:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Bạn điều hướng giữa các cửa sổ mà bạn muốn kích hoạt bằng `Super + Arrow`. Thao tác này sẽ chuyển tiêu điểm và di chuyển con trỏ đến giữa ứng dụng mới. Ở cạnh của một màn hình, nó sẽ tiếp tục sang màn hình ở phía đó.

Nếu bạn nhấn `Super + Shift + 2`, bạn sẽ di chuyển ứng dụng đang được lấy tiêu điểm hiện tại sang không gian làm việc thứ hai. `Super + Shift + 1` di chuyển nó trở lại. (Và `Super + Shift + Alt + 2` sẽ di chuyển ứng dụng đang được lấy tiêu điểm hiện tại sang không gian làm việc thứ hai mà không chuyển sang đó).

Với nhiều màn hình, mỗi màn hình có các không gian làm việc từ 1 đến 10 của riêng nó. `Super + 2` đi đến không gian làm việc thứ hai của màn hình bạn đang ở, và thanh trên cùng của mỗi màn hình hiển thị các không gian làm việc của riêng nó cùng với không gian làm việc nó đang hiển thị. `Super + Tab` luân chuyển qua các không gian làm việc trên màn hình bạn đang ở. `Super + Shift + Ctrl + Arrows` di chuyển cửa sổ bạn đang ở sang màn hình theo hướng đó, vào không gian làm việc mà màn hình đó đang hiển thị, và `Super + Shift + Alt + Arrows` di chuyển không gian làm việc bạn đang ở sang màn hình theo hướng đó, tại đó nó sẽ lấy cùng một số nếu số đó còn trống. Một màn hình vẫn giữ các không gian làm việc của nó khi bạn rút nó ra: chúng sẽ nhập vào một màn hình khác, được đánh số tiếp sau các số mà màn hình đó đã có, và quay trở lại các số cũ của chúng khi màn hình trở lại.

Nếu bạn giữ `Super` và dùng chuột để nhấp vào một cửa sổ, bạn sẽ có thể sắp xếp lại vị trí của nó. Nếu bạn giữ `Super` và dùng nút phải trên chuột, bạn có thể tự do thay đổi kích thước cửa sổ.

Bạn đóng một cửa sổ bằng `Super + W` hoặc `Super + Q` (và đóng tất cả các cửa sổ bằng `Ctrl + Alt + Delete`).

Bạn cũng có thể chuyển sang toàn màn hình bằng `Super + F` hoặc thậm chí chỉ toàn chiều rộng (giữ lại thanh trên cùng) bằng `Super + Alt + F` hoặc toàn màn hình bên trong một cửa sổ bằng `Super + Ctrl + F` (rất hay cho YouTube!).

### Bố cục dwindle so với bố cục cuộn

Bố cục mặc định của Omarchy được gọi là dwindle. Nó giữ cho tất cả các cửa sổ bạn mở trên một không gian làm việc luôn hiển thị mọi lúc, ngay cả khi nó phải thu nhỏ chúng xuống.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Nhưng bạn cũng có thể chọn biến một không gian làm việc thành bố cục cuộn, trong đó các cửa sổ được xếp cạnh nhau, vượt ra ngoài cạnh có thể nhìn thấy của màn hình hiển thị. Bạn biến một không gian làm việc đơn lẻ thành bố cục này qua `Super + L`.

Nhấn `Super + L` lần nữa sẽ biến không gian làm việc thành dạng nổi, trong đó các cửa sổ tự do chồng lên nhau và bạn tự đặt chúng, và lần nhấn thứ ba sẽ đưa nó trở lại dwindle. `Super + Alt + L` đi qua chúng theo chiều ngược lại. Một cửa sổ vốn đã nổi — một cửa sổ bạn đã tách ra bằng `Super + T`, hoặc một ứng dụng luôn mở ở dạng nổi — vẫn giữ dạng nổi khi không gian làm việc quay trở lại xếp lớp. Thanh trên cùng đánh dấu không gian làm việc bạn đang ở bằng bố cục của nó: một hình vuông cho dwindle, một hình tròn cho bố cục cuộn, và một hình tam giác cho dạng nổi. Nhấp vào dấu đó cũng luân chuyển bố cục, và phím hiển thị trên các laptop có phím đó cũng vậy.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Lựa chọn này áp dụng cho từng không gian làm việc, và nó được giữ nguyên. Vì vậy bạn có thể giữ không gian làm việc 1 ở dwindle để duyệt web và không gian làm việc 2 ở bố cục cuộn để viết code, và chúng sẽ trở lại như vậy sau khi khởi động lại.

Nếu bạn muốn dùng bố cục cuộn làm mặc định, bạn có thể đặt điều đó trong `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Các không gian làm việc nổi

Một không gian làm việc nổi hoạt động giống như một desktop truyền thống: các cửa sổ chồng lên nhau, và bạn tự di chuyển và thay đổi kích thước chúng. Mỗi cửa sổ có một thanh tiêu đề với màu sắc của theme của bạn, kèm các nút để thu nhỏ, phóng to và đóng. `Super + M` cũng thu nhỏ cửa sổ đang được lấy tiêu điểm. Một cửa sổ đã thu nhỏ sẽ chờ trong dock; nhấp vào ứng dụng của nó để đưa nó trở lại. Nhấp vào một cửa sổ để đưa nó lên phía trước. Thay đổi kích thước nó từ bất kỳ cạnh hoặc góc nào. Nhấp đúp vào một thanh tiêu đề để phóng to cửa sổ trong khi vẫn giữ thanh trên cùng trong tầm nhìn, và nhấp đúp lần nữa để lấy lại kích thước cũ của nó. Chrome và các trình duyệt dựa trên Chromium khác, Disks và Document Viewer bỏ qua thanh tiêu đề và thay vào đó dùng header của riêng chúng; `Super + Alt + F` phóng to chúng, và `Super + M` thu nhỏ chúng.

Một không gian làm việc nổi cũng hiển thị một dock, với các ứng dụng đã ghim của bạn, mọi thứ đang chạy, và một lưới mọi ứng dụng nằm sau nút apps, mà `Super + Alt + Space` và _Apps_ trong Omarchy menu cũng mở. Nhấp chuột phải vào một ứng dụng trên lưới, hoặc nhấn `Delete`, để gỡ cài đặt nó. Nhấp vào một ứng dụng để mở nó, hoặc để đưa cửa sổ của nó lên phía trước; nhấp lần nữa để luân chuyển qua các cửa sổ của nó. Files chỉ đưa trở lại một cửa sổ từ không gian làm việc bạn đang ở và nếu không sẽ mở một cửa sổ mới, còn Terminal và Agent luôn khởi chạy một cái khác, mặc dù một cửa sổ đã thu nhỏ sẽ quay trở lại trước. Nhấp chuột giữa mở một cửa sổ mới. Kéo một biểu tượng dọc theo dock để di chuyển nó; kéo một ứng dụng đang chạy vào giữa các ứng dụng khác sẽ giữ nó ở đó. Nhấp chuột phải để giữ một ứng dụng trong dock, lấy nó ra, hoặc thoát nó. Dock sẽ nhường đường cho một cửa sổ toàn màn hình. Nhấp chuột phải vào nút apps để di chuyển dock sang một cạnh khác hoặc để nó ẩn đi cho đến khi con trỏ chạm tới cạnh của nó. Vị trí cũng nằm trong _Appearance > Dock > Dock Position_, và `omarchy dock position left` và `omarchy dock autohide on` đặt cả hai từ một terminal. Các ứng dụng bạn giữ trong dock sẽ mờ đi trong khi chúng không chạy.

Các không gian làm việc mới, và bất kỳ không gian làm việc nào bạn chưa cấp một bố cục riêng bằng `Super + L`, sẽ dùng bố cục mặc định. Việc thay đổi mặc định sẽ đặt lại mọi không gian làm việc không có cửa sổ về bố cục đó, trong khi một không gian làm việc có cửa sổ trên đó vẫn giữ bố cục mà nó đang có. Một cửa sổ đã thu nhỏ vào dock vẫn được tính là một cửa sổ trên không gian làm việc mà nó đã rời khỏi. Chọn nó trong _Appearance > Workspace Layout_: Tiling, Scrolling, hoặc Floating. `omarchy hyprland workspace layout default scrolling` đặt nó từ một terminal.

### Nhóm các cửa sổ

Các cửa sổ có thể được nhóm lại bằng `Super + G`. Một khi bạn đã ở trong một nhóm, mọi cửa sổ bạn khởi chạy trong khi nhóm đó đang hoạt động sẽ thuộc về nhóm. Bạn có thể di chuyển giữa các cửa sổ đã nhóm này bằng `Super + Ctrl + Arrow Left/Right` hoặc `Super + Alt + 1/2/3/4` để đi trực tiếp đến các cửa sổ đã nhóm theo thứ tự.

Bạn có thể di chuyển một cửa sổ ra khỏi nhóm bằng `Super + Alt + G` hoặc tháo rời toàn bộ nhóm bằng cách nhấn `Super + G` lần nữa. Cuối cùng, bạn có thể di chuyển các cửa sổ bên ngoài nhóm vào trong nó bằng `Super + Alt + Arrows`.

### Tách cửa sổ ra

Bạn có thể tách một cửa sổ ra khỏi vị trí không gian làm việc của nó bằng `Super + O`. Thao tác đó sẽ ghim nó thành một cửa sổ nổi đi theo bạn đến bất kỳ không gian làm việc nào bạn tới. Tuyệt vời cho các trình phát video và những thứ tương tự.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Không gian làm việc scratchpad

Có một không gian làm việc scratchpad toàn kích thước đặc biệt phủ lên bất kỳ không gian làm việc nào bạn hiện đang ở. Bạn truy cập những gì trên đó bằng `Super + S`, và bạn đặt các cửa sổ ở đó bằng `Super + Alt + S`.

Nó hoạt động tốt cho các điều khiển hoặc một terminal mà bạn muốn tương tác nhanh chóng mà không rời khỏi không gian làm việc hiện tại.

### Quake console

Cuối cùng, có một Quake console cao nửa màn hình thả xuống phủ lên bất kỳ không gian làm việc nào bạn hiện đang ở. Bật tắt nó bằng `Super + the key above Tab` (grave trên các bố cục US), và đặt một cửa sổ ở đó bằng `Super + Shift + the key above Tab`.

Lần đầu tiên nó mở, nó khởi chạy agent mặc định của bạn, hoặc yêu cầu bạn chọn một agent nếu bạn chưa chọn. Trong khi console chỉ chứa một cửa sổ duy nhất, nó thả xuống dưới dạng một panel ở giữa thay vì trải rộng khắp màn hình. Đặt một ứng dụng thứ hai lên nó và nó sẽ trở lại chiều rộng đầy đủ, để hai ứng dụng có chỗ nằm cạnh nhau.

Để di chuyển một cửa sổ ra khỏi scratchpad hoặc console, hãy gửi nó trực tiếp đến một không gian làm việc khác bằng một phím như `Super + Shift + 1`.

### Cần một chút thời gian để làm quen!

Cần một chút thời gian để làm quen với việc điều hướng desktop của bạn như thế này, nhưng một khi bạn đã quen, sẽ khó mà quay lại trải nghiệm desktop truyền thống điều khiển bằng chuột!
