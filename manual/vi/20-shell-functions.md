# Hàm shell

Omarchy đi kèm một tập hợp các hàm shell để đơn giản hóa các tác vụ phổ biến và đóng gói những lệnh gọi tham số rườm rà.

## Nén

- `compress [file/dir]`: Tạo một tệp lưu trữ tar.gz từ tệp/thư mục.
- `decompress [file.tar.gz]`: Giải nén một tệp tar.gz.

## Ổ đĩa

- `iso2sd [image.iso]`: Tạo một ổ đĩa có thể khởi động trên thẻ SD bằng tệp iso được chỉ định và chọn ổ đĩa theo cách tương tác.
- `format-drive [device] [name]`: Định dạng toàn bộ đĩa với một phân vùng exFAT duy nhất (hoạt động cả trên Windows và macOS). Chạy nó mà không có đối số để xem các ổ đĩa khả dụng. Hãy cẩn thận!

## Bố cục phát triển

Bố cục phát triển nhiều ngăn tức thì cho tmux:

- `tdl [ai]`: Tạo một Tmux Dev Layout với trình soạn thảo của bạn, một tác nhân AI và một terminal. Dùng các bí danh tác nhân, như `tdl c` cho opencode hoặc `tdl cx` cho Claude Code, hoặc truyền một tác nhân thứ hai để chạy cả hai, như `tdl c cx`.
- `tds`: Tạo một Tmux Dev Square với trình soạn thảo, theo dõi diff (qua `hunk diff --watch`), terminal và opencode.
- `tdlm [ai]`: Tạo một cửa sổ `tdl` cho mỗi thư mục con trong thư mục hiện tại.
- `tsl [count] [command]`: Tạo một đám các ngăn xếp theo lưới, tất cả đều chạy cùng một lệnh (rất tuyệt cho các tác nhân AI).

Các bố cục tương tự cũng có cho Herdr với tên `hdl`, `hds`, `hdlm` và `hsl`.

## Git worktree

- `ga [branch]`: Tạo một worktree và nhánh mới bên cạnh kho hiện tại rồi nhảy vào đó.
- `gd`: Xóa worktree hiện tại và nhánh của nó (sẽ xin xác nhận trước).

## Trình theo dõi rsync

- `rsw [source] [destination]`: Bắt đầu một trình theo dõi ở chế độ nền, đồng bộ (rsync) từ nguồn đến đích mỗi khi có thay đổi. Đích có thể là một máy chủ từ xa, như `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: Liệt kê mọi trình theo dõi đang hoạt động.
- `dsw`: Dừng mọi trình theo dõi đang hoạt động.

## Chuyển tiếp cổng SSH

Lý tưởng cho việc phát triển web với quyền ngữ cảnh bảo mật của localhost đối với một máy từ xa.

- `fip`: Chuyển tiếp một hoặc nhiều cổng từ một máy chủ từ xa đến localhost qua SSH.
- `dip`: Ngắt kết nối một hoặc nhiều cổng đã chuyển tiếp.
- `lip`: Liệt kê mọi chuyển tiếp cổng SSH đang hoạt động.

Giả sử bạn khởi động một máy chủ phát triển trên cổng `3000` trên một máy có thể truy cập với tên `nyc-dev`, thì bạn có thể chạy `fip nyc-dev 3000` để chuyển tiếp cổng đó, để `localhost:3000` thực tế đến được `nyc-dev:3000`, nhưng không cần chứng chỉ SSL để thiết lập ngữ cảnh bảo mật cần thiết cho việc kiểm tra websocket hay những thứ tương tự.

## Kết nối lại SSH

Bản thân `ssh` được bọc trong một hàm dọn dẹp terminal nếu một kết nối bị ngắt trong khi một tmux, Herdr hoặc trình soạn thảo từ xa đang chiếm nó, rồi tự động kết nối lại khi một phiên tương tác bị rớt (Ctrl-C dừng vòng lặp thử lại).
