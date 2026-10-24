# Công cụ phát triển

## Trình soạn thảo thay thế

Omarchy đi kèm [Neovim](https://neovim.io/) theo mặc định, nhưng nếu bạn muốn thứ gì đó phổ biến và quen thuộc hơn một chút, bạn có thể mở Menu Omarchy (`Super + Space`) và xem các tùy chọn trong _Cài đặt > Trình soạn thảo_. Ở đó có VSCode, Cursor, Zed, Sublime Text, Helix, Vim và Emacs. Nếu không tìm thấy thứ mình muốn, hãy xem _Cài đặt > Gói_, biết đâu nó có trong một gói Arch nào đó (và nếu không, hãy thử _Cài đặt > AUR_ để kiểm tra AUR).

Trình soạn thảo `vi` gốc cũng có sẵn ngay từ đầu. Chạy `vi filename` để sửa một tệp trong terminal.

Chức năng đồng bộ giao diện được hỗ trợ cho `VSCode`, `Cursor`, `VSCodium` và `Helix`.

Bạn có thể đặt trình soạn thảo mặc định cho toàn hệ thống trong `Thiết lập > Mặc định > Trình soạn thảo`.

## Môi trường

Omarchy hỗ trợ thiết lập hàng loạt môi trường phát triển thông qua mục _Cài đặt > Phát triển_ của Menu Omarchy (`Super + Space`). Tất nhiên bạn sẽ tìm thấy _Ruby on Rails_, nhưng cũng có cả ba runtime chính cho JavaScript (Node.js, Bun, Deno), cùng các framework PHP phổ biến như Laravel và Symfony. À, còn có Go, Rust, Python, Java, Elixir (với Phoenix), .NET, OCaml, Zig, Clojure và Scala nữa. Lựa chọn rất phong phú!

Phần lớn các môi trường này được quản lý bởi [Mise](https://mise.jdx.dev/). Đây là công cụ cho phép bạn cài đặt và chạy nhiều phiên bản của một ngôn ngữ lập trình trên cùng một máy. Nó giống như rbenv hay rvm cho Ruby hay virtualenv cho Python, nhưng hoạt động với nhiều môi trường khác nhau.

Để cài đặt, chẳng hạn, Ruby, bạn chạy `mise use -g ruby`, lệnh này vừa cài Ruby vừa đặt nó làm mặc định toàn cục. Hoặc, nếu dự án của bạn có tệp .ruby-version, bạn chỉ cần chạy `mise i` ở thư mục gốc của dự án đó.

## Docker

[Docker](https://www.docker.com/) hầu như không cần giới thiệu. Nó cho phép bạn chạy các container biệt lập, và Omarchy cài đặt mọi thứ cần thiết để chạy nó thật tốt, bao gồm cả Docker và [Docker Compose](https://docs.docker.com/compose/).

Theo mặc định, người dùng của bạn *không* thuộc nhóm `docker`. Nhóm đó thực chất là quyền root không cần mật khẩu — bất cứ thứ gì thuộc nhóm đó đều có thể chạy `docker run -v /:/host` và chiếm lấy máy — vì vậy một script hay phụ thuộc gian lận chạy dưới quyền của bạn sẽ chỉ cách quyền root đúng một lệnh. Do đó trên dòng lệnh bạn chạy Docker với `sudo` (`sudo docker ps`, `sudo docker compose up`), và các công cụ đồ họa giao tiếp với daemon — như máy ảo Windows — sẽ xin phép khi cần. Nếu bạn muốn lấy lại sự tiện lợi của thiết lập không cần thuộc nhóm và hiểu rõ sự đánh đổi, hãy bật nó trong **Thiết lập > Bảo mật > Docker không cần sudo** (hoặc chạy `omarchy-setup-security-sudoless-docker`), lệnh này sẽ thêm bạn vào nhóm `docker` sau một lời cảnh báo; khi đó `docker` thường và bí danh `d` lại hoạt động mà không cần `sudo`.

Bạn có thể thiết lập các cơ sở dữ liệu phổ biến cho phát triển cục bộ trong Docker bằng _Cài đặt > Phát triển > Docker DB_ trong menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) cho phép bạn xác thực với tài khoản GitHub của mình và dùng nó để sao chép (clone) các kho riêng tư. Nó được kết nối như một trong các stub tải chậm của mise, vì vậy lần đầu tiên bạn chạy `gh`, nó sẽ tự cài đặt. Để xác thực, chạy `gh auth login`. Sau đó bạn có thể sao chép các kho riêng tư bằng `gh repo clone org/repo`.

Bạn cũng có thể thực hiện nhiều thao tác GitHub khác bằng lệnh này. Chỉ cần chạy `gh` để xem mọi khả năng.

Ngoài ra còn có một stub tự cài đặt chậm cho `ghui` để quản lý các pull request của bạn trong một TUI. Và [lazygit](https://github.com/jesseduffield/lazygit) được cài sẵn, nếu bạn muốn điều khiển git từ một TUI.
