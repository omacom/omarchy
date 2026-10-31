# Plugin của shell

Màn hình nền Omarchy chạy như một tiến trình Quickshell có tuổi thọ dài duy nhất có tên `omarchy-shell`, và gần như mọi thứ bạn thấy trên màn hình đều là một plugin bên trong nó. Thanh là một plugin. Các bảng điều khiển thả xuống từ đó cũng vậy, các lớp phủ toàn màn hình như bộ chọn emoji và trình quản lý khay nhớ tạm, chính menu Omarchy, màn hình khóa, hộp thoại polkit, và các dịch vụ không có giao diện theo dõi pin của bạn và làm ấm màn hình của bạn vào ban đêm.

Đó không chỉ là một chi tiết triển khai. Nó có nghĩa là bạn có thể tắt các phần của màn hình nền, hoán đổi chúng, hoặc viết cái của riêng bạn mà không cần đụng vào một dòng mã nguồn nào của Omarchy.

Các plugin chính thức đi kèm Omarchy và nằm trong `$OMARCHY_PATH/shell/plugins/`. Bất cứ thứ gì bạn tự thêm — các thí nghiệm của riêng bạn, hoặc thứ gì đó bạn tìm thấy trên GitHub — nằm trong `~/.config/omarchy/plugins/`. Cả hai đều được khám phá theo cùng một cách khi khởi động, nhưng các plugin tích hợp sẵn nhận các giao diện shell đáng tin cậy trong khi các plugin của bên thứ ba nhận một giao diện giới hạn trong phạm vi dịch vụ và vòng đời của chính chúng. Các bản sao của plugin tích hợp sẵn chỉ giữ lại cấu hình dành riêng cho nguồn và các lệnh gọi giao diện người dùng cần thiết cho hành vi gốc.

## Xem những gì bạn có

```
omarchy plugin list
```

Lệnh đó in ra mọi plugin đã khám phá được với id của nó, trạng thái bật hay tắt, là chính thức hay của bên thứ ba, các loại của nó và tên hiển thị của nó. Thêm `--json` nếu bạn đang truyền nó cho thứ khác.

Các id của plugin được đặt trong không gian tên. Các plugin tích hợp sẵn đều bắt đầu bằng `omarchy.` — `omarchy.clock`, `omarchy.network`, `omarchy.notifications` — và không gian tên đó được dành riêng, vì vậy một plugin của bên thứ ba không bao giờ có thể chiếm nó.

## Bật và tắt chúng

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

Hoặc dùng menu: _Thiết lập > Plugin_ có Bật, Tắt, Thêm, Sao chép và Gỡ bỏ, mỗi mục với một bộ chọn chỉ cung cấp các plugin hợp lý cho hành động đó.

Trạng thái bật được lưu trong `~/.config/omarchy/shell.json`, và quy tắc khác nhau một chút đối với hai loại plugin. Một plugin của bên thứ ba được bật chính xác khi id của nó xuất hiện ở đâu đó trong tệp đó — dưới dạng một mục bố cục thanh, dưới dạng một mục trong `plugins[]`, hoặc dưới dạng `bar.id`. Các plugin chính thức không phải là widget thanh thì ngược lại: chúng bật theo mặc định và chỉ tắt khi được liệt kê trong `disabledPlugins[]`.

Một plugin thanh đầy đủ hoàn toàn không có trạng thái tắt. Luôn luôn có đúng một thanh, vì vậy bạn thay thế nó bằng cách bật một thanh khác. Vị trí của widget thanh được đề cập trong [thanh trên cùng](05-the-top-bar.md).

## Thêm một plugin từ git

Một plugin của bên thứ ba chỉ là một kho git với một `manifest.json` ở thư mục gốc của nó.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Trước khi làm bất cứ điều gì, nó nói thẳng với bạn rằng các plugin chạy như mã tùy ý, không bị giới hạn trong hộp cát bên trong tiến trình shell có tuổi thọ dài của bạn, hiển thị cho bạn URL, và yêu cầu bạn xác nhận. Hãy coi trọng điều đó. Giao diện plugin của bên thứ ba không trực tiếp để lộ các dịch vụ xác thực, và một thanh thay thế chỉ nhận các khả năng giới hạn cho giao diện người dùng không xác thực đã cấu hình. Các plugin trực quan vẫn chia sẻ cảnh QML của shell và có thể đi qua các đối tượng cha thông thường, trong khi mọi mã plugin đều chạy với mọi thứ tài khoản người dùng của bạn có thể tiếp cận. Trạng thái xác thực được bảo vệ riêng bằng cách giữ các dịch vụ đó bên ngoài đồ thị đối tượng máy chủ có thể tiếp cận được. Chỉ thêm các kho bạn sẵn lòng chạy, và đọc chúng trước khi bạn bật chúng.

Một thanh thay thế có thể kết xuất các widget đã cài đặt, nhưng các widget của bên thứ ba được hỗ trợ bởi dịch vụ có thể bị giảm chức năng ở đó vì thanh không được phép yêu cầu đối tượng dịch vụ trực tiếp của một plugin khác. Chuyển lại về `omarchy.bar` tích hợp sẵn nếu một widget như vậy cần dịch vụ đi kèm của nó.

Sau đó nó sao chép (clone) kho vào một thư mục tạm thời, xác thực bản kê khai (manifest), từ chối cài đặt nếu một plugin khác đã chiếm id đó, và di chuyển nó vào `~/.config/omarchy/plugins/<id>/`. Không có `--enable` nó sẽ hỏi bạn có muốn bật nó ngay bây giờ không, và bạn có thể nói không và đi đọc mã trước. Nó không bao giờ chạy bất cứ thứ gì từ plugin, không bao giờ thực thi một hook cài đặt, và không bao giờ yêu cầu sudo — nó sao chép các tệp, kiểm tra bản kê khai, và lật một bit qua IPC.

Cập nhật là một thao tác kéo chuyển tiếp nhanh (fast-forward pull) của cùng bản sao đó:

```
omarchy plugin update acme.weather
omarchy plugin update
```

Không có id, nó cập nhật mọi plugin được quản lý bằng git mà bạn có. Nó hiển thị cho bạn phần khác biệt trước khi áp dụng, từ chối cập nhật nếu bạn có các thay đổi cục bộ mà nó không thể chuyển tiếp nhanh qua được, và khôi phục lại nếu phiên bản mới không đạt kiểm tra xác thực.

```
omarchy plugin remove acme.weather
```

Việc gỡ bỏ sẽ tắt plugin trước, rồi xóa nó nếu đó là một bản sao git (kho vẫn còn ở thượng nguồn) hoặc hủy liên kết nó nếu đó là một liên kết tượng trưng (symlink). Một thư mục plugin tự làm không có kho git sẽ được di chuyển đến một bản sao lưu đóng dấu thời gian bên trong thư mục plugin thay vì bị xóa hoàn toàn.

## Sao chép một plugin tích hợp sẵn để sửa đổi nó

Đây là phần yêu thích của tôi. Nếu bạn muốn thay đổi cách một widget tích hợp sẵn hoạt động, đừng chỉnh sửa các tệp trong `$OMARCHY_PATH` — chúng thuộc về gói và bản cập nhật tiếp theo sẽ ghi đè chúng. Thay vào đó hãy sao chép nó:

```
omarchy plugin clone omarchy.clock
```

Thao tác đó sao chép toàn bộ plugin vào `~/.config/omarchy/plugins/dhh.clock` (tên người dùng của bạn, không phải của tôi), đổi tên nó thành "My Clock", bật nó, và chuyển shell từ bản tích hợp sẵn sang bản sao của bạn — giữ nguyên vị trí và cài đặt của một widget thanh hiện có. Thêm `--edit` để mở thư mục mới trong `$EDITOR` của bạn ngay lập tức, đó là điều mục _Thiết lập > Plugin > Sao chép plugin_ trong menu làm cho bạn.

Tiền tố tên người dùng giữ cho id của bản sao là của riêng bạn, vì vậy việc chia sẻ nó không xung đột với của bất kỳ ai khác. Các lệnh gọi đến id tích hợp sẵn gốc sẽ được định tuyến đến bản sao của bạn, vì vậy không thứ gì đã tham chiếu đến `omarchy.clock` cần cập nhật. Và nếu bạn làm rối tung nó, `omarchy plugin remove dhh.clock` sẽ đưa bản tích hợp sẵn trở lại.

Lưu một tệp ở bất cứ đâu trong `~/.config/omarchy/plugins/` sẽ tự động tải lại mã plugin, vì vậy bạn có thể để trình soạn thảo mở và xem các thay đổi của mình xuất hiện.

## Tự viết plugin của riêng bạn

Một plugin là một thư mục với một `manifest.json` và một ít QML. Bản kê khai tuyên bố `schemaVersion: 1`, một `id`, `name`, `version`, một hoặc nhiều `kinds`, và một đối tượng `entryPoints` trỏ đến tệp QML cho mỗi loại:

| Loại | Nó là gì |
|------|------------|
| `bar-widget` | Một thành phần mà thanh đang hoạt động có thể thả vào một phần |
| `panel` | Một cửa sổ nổi bền vững hoặc được triệu hồi |
| `overlay` | Một lớp phủ toàn màn hình |
| `menu` | Một bề mặt menu được triệu hồi |
| `service` | Một singleton không có giao diện và không có giao diện người dùng |
| `bar` | Một thanh đầy đủ thay thế thanh tích hợp sẵn |

Một plugin có thể tuyên bố nhiều loại cùng lúc — plugin đa phương tiện vừa là một `service` vừa là một `bar-widget`. Các widget thanh nhận thêm một khối `barWidget` với một tên hiển thị, một danh mục, một `defaultSection` tùy chọn, và `allowMultiple`, cho biết liệu có hợp lý không khi có nhiều hơn một cái trên thanh. Hầu hết các widget đặt nó thành `false`; các miếng đệm và chỉ báo đặt nó thành `true`.

Trước khi bạn xuất bản bất cứ thứ gì, hãy kiểm tra nó:

```
omarchy plugin validate ./my-plugin
```

Lệnh đó chạy các kiểm tra giống như shell thực hiện tại thời điểm tải: phiên bản lược đồ, các trường bắt buộc, một id không bị dành riêng, các điểm vào là đường dẫn tương đối an toàn và thực sự tồn tại, một điểm vào cho mỗi loại bạn đã tuyên bố, và không có liên kết tượng trưng nào ở bất cứ đâu bên trong thư mục.

Để phát triển plugin, xem [tài liệu tham khảo về shell](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) và [danh mục plugin chính thức](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md).

## Chia sẻ plugin của bạn với thế giới

Khi bạn đã tạo ra thứ gì đó bạn thích, hãy đưa nó vào một kho git công khai. Đó là toàn bộ cơ chế phân phối — bất kỳ ai sau đó đều có thể chạy `omarchy plugin add` đối với URL của bạn và có nó chạy trong vài giây.

Để giúp mọi người thực sự tìm thấy nó, hãy liệt kê nó tại [plugins.omarchy.org](https://plugins.omarchy.org). Đó là thị trường cho các plugin shell của Omarchy, và đó là nơi đầu tiên để tìm khi bạn đang tự hỏi liệu ai đó đã xây dựng widget bạn sắp viết hay chưa. Hãy duyệt nó trước khi bạn bắt đầu!
