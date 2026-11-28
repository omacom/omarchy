# Điều hướng

Mọi thứ trong Omarchy đều diễn ra qua bàn phím — _MỌI THỨ!_ Khi hệ thống mới khởi động, bạn thực sự không thể làm được gì chỉ với chuột. Nhưng bạn có thể nhấn `Super + Space` để hiện Menu Omarchy và từ đây bạn có thể làm gần như mọi thứ.

Nhưng menu Omarchy thậm chí còn không được dự định là cách chính để vận hành hệ thống trong phần lớn thời gian. Chúng ta còn có thể nhanh hơn thế! Tất cả các ứng dụng quan trọng nhất đều được gán trực tiếp vào từng phím nóng riêng. Bạn khởi động terminal bằng `Super + Return` và trình duyệt bằng `Super + Shift + Return`. Thử làm cái này nối tiếp cái kia, bạn sẽ thấy phép màu của cơ chế xếp lớp của Hyprland đang hoạt động:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Bạn sau đó có thể nhấn `Super + J` để xếp chồng chúng lên nhau thay vì đặt chúng cạnh nhau:

 ![navigation-stacked](images/navigation-stacked.webp)

Nhấn `Super + J` lần nữa để đưa chúng trở lại vị trí cạnh nhau. Sau đó thử `Super + Shift + Arrow Right` khi đang ở trong trình duyệt để hoán đổi các cửa sổ.

Giờ thử `Super + Shift + T` để khởi động trình theo dõi Activity. Nó sẽ xuất hiện dưới dạng một cửa sổ nổi, với một thanh tiêu đề để kéo nó và các nút để thu nhỏ, phóng to và đóng nó. Mọi cửa sổ nổi đều có một thanh như vậy, dù nó ở đâu. Bạn có thể xếp lớp nó bằng `Super + T` (và nhấn lại lần nữa để biến nó thành cửa sổ nổi trở lại). Giờ nhấn `Super + Shift + F` để mở trình quản lý tệp. Bạn sẽ có một bố cục bốn cửa sổ gọn gàng:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Bạn điều hướng tới cửa sổ mà bạn muốn kích hoạt bằng `Super + Arrow`. Thao tác này sẽ chuyển tiêu điểm và di chuyển con trỏ tới trung tâm của ứng dụng mới. Ở mép của một màn hình, nó sẽ tiếp tục sang màn hình ở phía đó.

Nếu bạn nhấn `Super + Shift + 2`, bạn sẽ di chuyển ứng dụng đang được lấy tiêu điểm hiện tại sang workspace thứ hai. `Super + Shift + 1` sẽ di chuyển nó trở lại. (Và `Super + Shift + Alt + 2` sẽ di chuyển ứng dụng đang được lấy tiêu điểm hiện tại sang workspace thứ hai mà không chuyển sang workspace đó).

Với nhiều màn hình, mỗi màn hình có các workspace từ 1 đến 10 của riêng nó. `Super + 2` đi tới workspace thứ hai của màn hình bạn đang ở, và thanh trên cùng của mỗi màn hình hiển thị các workspace của riêng nó và workspace mà nó đang hiển thị. `Super + Tab` chuyển vòng qua các workspace trên màn hình bạn đang ở. `Super + Shift + Ctrl + Arrows` di chuyển cửa sổ bạn đang ở sang màn hình theo hướng đó, vào workspace mà màn hình đó đang hiển thị, và `Super + Shift + Alt + Arrows` di chuyển workspace bạn đang ở sang màn hình theo hướng đó, nơi nó mang cùng số nếu số đó đang trống. Một màn hình giữ các workspace của nó khi bạn rút nó ra: chúng nhập vào một màn hình khác, được đánh số tiếp sau các workspace mà màn hình đó đã có, và trở lại với số cũ của chúng khi màn hình quay trở lại.

Nếu bạn giữ `Super` và dùng chuột để nhấp vào một cửa sổ, bạn sẽ có thể sắp xếp lại vị trí của nó. Nếu bạn giữ `Super` và dùng nút phải trên chuột, bạn có thể tự do thay đổi kích thước cửa sổ.

Bạn đóng một cửa sổ bằng `Super + W` hoặc `Super + Q` (và đóng tất cả các cửa sổ bằng `Ctrl + Alt + Delete`).

Bạn cũng có thể chuyển sang toàn màn hình bằng `Super + F` hoặc thậm chí chỉ toàn chiều rộng (vẫn giữ thanh trên cùng) bằng `Super + Alt + F` hoặc toàn màn hình bên trong một cửa sổ bằng `Super + Ctrl + F` (rất tiện cho YouTube!).

### Bố cục dwindle và bố cục cuộn

Bố cục mặc định của Omarchy được gọi là dwindle. Nó giữ mọi cửa sổ bạn mở trên một workspace luôn hiển thị mọi lúc, ngay cả khi nó phải thu nhỏ chúng xuống.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Nhưng bạn cũng có thể chọn biến một workspace thành bố cục cuộn, nơi các cửa sổ được xếp cạnh nhau, vượt ra ngoài mép hiển thị của màn hình. Bạn biến một workspace đơn lẻ thành bố cục này bằng `Super + L`.

Nhấn `Super + L` lần nữa sẽ biến workspace thành nổi, nơi các cửa sổ chồng lên nhau tự do và bạn tự đặt chúng, và nhấn lần thứ ba sẽ đưa nó trở lại dwindle. `Super + Alt + L` đi qua chúng theo chiều ngược lại. Một cửa sổ vốn đã nổi — một cửa sổ bạn tách ra bằng `Super + T`, hoặc một ứng dụng luôn mở dưới dạng nổi — vẫn giữ trạng thái nổi khi workspace trở lại chế độ xếp lớp. Thanh trên cùng đánh dấu workspace bạn đang ở bằng bố cục của nó: một hình vuông cho dwindle, một hình tròn cho cuộn, và một hình tam giác cho nổi. Nhấp vào dấu đó cũng chuyển vòng qua các bố cục, và phím hiển thị trên các laptop có phím đó cũng vậy.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Lựa chọn này áp dụng cho từng workspace, và nó được giữ nguyên. Vì vậy bạn có thể giữ workspace 1 ở dwindle để duyệt web và workspace 2 ở cuộn để viết mã, và chúng sẽ trở lại như vậy sau khi khởi động lại.

Nếu bạn muốn dùng bố cục cuộn làm mặc định, bạn có thể đặt điều đó trong `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Các workspace nổi

Một workspace nổi hoạt động như một desktop truyền thống: các cửa sổ chồng lên nhau, và bạn tự di chuyển và thay đổi kích thước chúng. Mỗi cửa sổ có một thanh tiêu đề với màu sắc của chủ đề của bạn, với các nút để thu nhỏ, phóng to và đóng. `Super + M` cũng thu nhỏ cửa sổ đang được lấy tiêu điểm. Một cửa sổ đã thu nhỏ sẽ chờ trong dock; nhấp vào ứng dụng của nó để đưa nó trở lại. Nhấp vào một cửa sổ để đưa nó lên phía trước. Thay đổi kích thước nó từ bất kỳ mép hoặc góc nào. Nhấp đúp vào một thanh tiêu đề để phóng to cửa sổ trong khi vẫn giữ thanh trên cùng trong tầm nhìn, và nhấp đúp lần nữa để lấy lại kích thước cũ của nó. Chrome và các trình duyệt khác dựa trên Chromium, Disks và Document Viewer bỏ qua thanh tiêu đề và thay vào đó dùng phần đầu trang của riêng chúng; `Super + Alt + F` phóng to chúng, và `Super + M` thu nhỏ chúng.

Mỗi workspace có một dock, với các ứng dụng đã ghim của bạn, mọi thứ đang chạy, và một lưới mọi ứng dụng nằm sau nút ứng dụng, nút mà `Super + Alt + Space` và _Apps_ trong menu Omarchy cũng mở. Nhấp chuột phải vào một ứng dụng trên lưới, hoặc nhấn `Delete`, để gỡ cài đặt nó. Nhấp vào một ứng dụng để mở nó, hoặc để đưa cửa sổ của nó lên phía trước; nhấp lần nữa để chuyển vòng qua các cửa sổ của nó. Files chỉ đưa trở lại một cửa sổ từ workspace bạn đang ở và nếu không sẽ mở một cửa sổ mới, và Terminal và Agent luôn khởi động một cái khác, mặc dù một cửa sổ đã thu nhỏ sẽ trở lại trước. Nhấp chuột giữa mở một cửa sổ mới. Kéo một biểu tượng dọc theo dock để di chuyển nó; kéo một ứng dụng đang chạy vào giữa các ứng dụng khác sẽ giữ nó ở đó. Nhấp chuột phải để giữ một ứng dụng trong dock, lấy nó ra, hoặc thoát nó. Dock vẫn hiện ra trong khi một workspace trống, và một khi workspace có một cửa sổ, nó sẽ ẩn cho đến khi con trỏ chạm tới mép của nó. Một cửa sổ toàn màn hình sẽ ẩn nó hoàn toàn. Kéo nút ứng dụng về phía một mép khác của màn hình để di chuyển dock tới đó. Nhấp chuột phải vào nó để chọn _Position_, để chọn một mép, _Layout_, để đặt bố cục mặc định như _Appearance > Workspace Layout_ làm, và _Visibility_, để giữ dock luôn bật, để ứng dụng đầu tiên ẩn nó, hoặc giữ nó luôn ẩn. `omarchy dock visibility always` đặt điều đó từ một terminal. Vị trí cũng nằm trong _Appearance > Dock > Dock Position_, và `omarchy dock position left` đặt nó từ một terminal. Các ứng dụng bạn giữ trong dock sẽ bị mờ đi trong khi chúng không chạy. Để giữ dock chỉ dành cho các workspace nổi, dùng _Appearance > Dock > Dock Only on Floating_ hoặc `omarchy dock tiling off`.

Các workspace mới, và bất kỳ workspace nào bạn chưa tự cho nó một bố cục bằng `Super + L`, đều dùng bố cục mặc định. Thay đổi mặc định sẽ đặt lại mọi workspace không có cửa sổ theo nó, trong khi một workspace có cửa sổ trên đó giữ bố cục mà nó có. Một cửa sổ đã thu nhỏ vào dock vẫn tính là một cửa sổ trên workspace mà nó đã rời đi. Chọn nó trong _Appearance > Workspace Layout_: Tiling, Scrolling, hoặc Floating. `omarchy hyprland workspace layout default scrolling` đặt nó từ một terminal.

### Nhóm các cửa sổ

Các cửa sổ có thể được nhóm bằng `Super + G`. Một khi bạn đã ở trong một nhóm, mọi cửa sổ bạn khởi động trong khi nhóm đó đang hoạt động sẽ thuộc về nhóm đó. Bạn có thể di chuyển giữa các cửa sổ đã nhóm này bằng `Super + Ctrl + Arrow Left/Right` hoặc `Super + Alt + 1/2/3/4` để đi trực tiếp tới các cửa sổ đã nhóm theo thứ tự.

Bạn có thể di chuyển một cửa sổ ra khỏi nhóm bằng `Super + Alt + G` hoặc giải tán toàn bộ nhóm bằng cách nhấn `Super + G` lần nữa. Cuối cùng, bạn có thể di chuyển các cửa sổ ở ngoài nhóm vào trong nó bằng `Super + Alt + Arrows`.

### Tách các cửa sổ ra

Bạn có thể tách một cửa sổ ra khỏi phần phân bổ workspace của nó bằng `Super + O`. Thao tác đó sẽ ghim nó thành một cửa sổ nổi đi theo bạn tới bất kỳ workspace nào bạn đi tới. Rất tuyệt cho các trình phát video và những thứ tương tự.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Workspace scratchpad

Có một workspace scratchpad đặc biệt có kích thước đầy đủ, phủ lên bất kỳ workspace nào bạn đang ở. Bạn truy cập những gì trên đó bằng `Super + S`, và bạn đặt các cửa sổ ở đó bằng `Super + Alt + S`.

Nó hoạt động tốt cho các điều khiển hoặc một terminal mà bạn muốn tương tác nhanh chóng mà không rời khỏi workspace hiện tại.

### Bảng điều khiển Quake

Cuối cùng, có một bảng điều khiển Quake cao bằng nửa màn hình, thả xuống phủ lên bất kỳ workspace nào bạn đang ở. Bật/tắt nó bằng `Super + the key above Tab` (grave trên các bố cục US), và đặt một cửa sổ ở đó bằng `Super + Shift + the key above Tab`.

Lần đầu tiên nó mở, nó khởi động agent mặc định của bạn, hoặc yêu cầu bạn chọn một agent nếu bạn chưa chọn. Trong khi bảng điều khiển chỉ chứa một cửa sổ duy nhất, nó thả xuống dưới dạng một bảng ở giữa thay vì trải rộng khắp màn hình. Đặt một ứng dụng thứ hai lên nó và nó sẽ trở lại chiều rộng đầy đủ, để cả hai có chỗ ngồi cạnh nhau.

Để di chuyển một cửa sổ ra khỏi scratchpad hoặc bảng điều khiển, hãy gửi nó trực tiếp tới một workspace khác bằng một phím như `Super + Shift + 1`.

### Cần một chút thời gian để làm quen!

Cần một chút thời gian để làm quen với việc điều hướng desktop của bạn như thế này, nhưng một khi bạn đã quen, sẽ rất khó để quay lại trải nghiệm desktop truyền thống điều khiển bằng chuột!
