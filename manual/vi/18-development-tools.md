# Công cụ phát triển

## Trình soạn thảo thay thế

Omarchy được cài sẵn [Neovim](https://neovim.io/) theo mặc định, nhưng nếu bạn muốn thứ gì đó phổ biến và quen thuộc hơn một chút, bạn có thể mở Omarchy Menu (`Super + Space`) và xem các lựa chọn trong _Install > Editor_. Chúng tôi có VSCode, Cursor, Zed, Sublime Text, Helix, Vim và Emacs được liệt kê ở đó. Nếu không tìm thấy thứ mình cần, hãy xem _Install > Package_, và kiểm tra xem nó có trong một gói Arch nào không (và nếu không, hãy thử _Install > AUR_ để kiểm tra AUR).

Trình soạn thảo `vi` gốc cũng có sẵn ngay từ đầu. Chạy `vi filename` để chỉnh sửa một tệp trong terminal.

Tính năng khớp chủ đề được cung cấp cho `VSCode`, `Cursor`, `VSCodium` và `Helix`.

Bạn có thể đặt trình soạn thảo mặc định cho toàn hệ thống trong `Setup > Defaults > Editor`.

## Môi trường

Omarchy hỗ trợ thiết lập hàng loạt môi trường phát triển thông qua phần _Install > Development_ của Omarchy Menu (`Super + Space`). Tất nhiên bạn sẽ tìm thấy _Ruby on Rails_, nhưng còn có cả ba runtime chính cho JavaScript (Node.js, Bun, Deno), cùng các framework PHP phổ biến như Laravel và Symfony. Ồ, và còn có Go, Rust, Python, Java, Elixir (với Phoenix), .NET, OCaml, Zig, Clojure và Scala nữa. Đây là một lựa chọn rất phong phú!

Phần lớn các môi trường này được quản lý bởi [Mise](https://mise.jdx.dev/). Đây là một công cụ cho phép bạn cài đặt và chạy nhiều phiên bản của một ngôn ngữ lập trình trên cùng một máy. Nó giống như rbenv hoặc rvm cho Ruby hay virtualenv cho Python, nhưng nó hoạt động với hàng loạt môi trường khác nhau.

Để cài đặt, chẳng hạn, Ruby, bạn sẽ chạy `mise use -g ruby`, lệnh này sẽ vừa cài đặt Ruby vừa đặt nó làm mặc định toàn cục. Hoặc, nếu dự án của bạn có tệp .ruby-version, bạn chỉ cần chạy `mise i` trong thư mục gốc của dự án đó.

## Công cụ CLI được cài sẵn

Omarchy cung cấp các công cụ như `gh`, `uv` và hầu hết các [tác nhân viết code](17-ai.md) thông qua [cơ chế cài đặt lười biếng của mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Lần đầu tiên bạn chạy một công cụ, mise sẽ cài đặt nó. Các lần chạy sau sẽ tái sử dụng phiên bản đã cài; chúng không kiểm tra bản cập nhật mỗi lần khởi chạy.

Bạn cũng có thể xem các mặc định hoặc cài đặt chúng trước:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Chạy `omarchy update` để cập nhật các công cụ đã cài cùng với phần còn lại của Omarchy. Bí danh `mup` chỉ cập nhật các công cụ do mise quản lý. Để thêm một công cụ khác vào cấu hình của riêng bạn, hãy dùng `mise use -g <tool>`.

Việc thiết lập Python cũng cài đặt `uv` thông qua mise. Việc loại bỏ môi trường phát triển Python vẫn giữ `uv` khả dụng như một công cụ độc lập.

### Sử dụng bản cài đặt của riêng bạn

Các lệnh của mise đứng trước `~/.local/bin` trên `PATH`, vì vậy một công cụ bạn tự cài đặt, ví dụ bằng trình cài đặt riêng của Claude Code hoặc Cursor, vẫn sẽ chạy bản sao của mise. Các ứng dụng được khởi chạy từ màn hình nền cũng tìm thấy các lệnh của mise trước các gói hệ thống, vì vậy một ứng dụng chạy `gh` sẽ nhận được bản sao của mise ngay cả khi bạn đã cài `github-cli` bằng pacman, và mise sẽ cài đặt bản sao đó ngay trong lần đầu tiên. Để thay vào đó sử dụng bản của bạn, hãy vô hiệu hóa bản sao của mise trong `~/.config/mise/config.toml`. Ví dụ, nếu bạn đã tự cài đặt Cursor CLI:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Nếu bạn đã có bảng `[settings]`, hãy thêm mục vào đó; mở rộng danh sách `disable_tools` hiện có thay vì thay thế nó. Hãy đảm bảo bản cài đặt của bạn nằm trên `PATH`. Sử dụng tên công cụ của mise, tên này có thể khác với lệnh của nó: ví dụ, `oh-my-pi` cung cấp `omp`. Trình khởi chạy tác nhân mặc định cũng ưu tiên Cursor hoặc Muse do người dùng cài đặt trong `~/.local/bin`.

### Loại bỏ và khôi phục các mặc định

_Remove Preinstalls_ khiến mise bỏ qua các khai báo công cụ của Omarchy đối với người dùng của bạn, bằng cách thêm chúng vào `ignored_config_paths` trong `~/.config/mise/miserc.toml`. _Restore Preinstalls_ sẽ loại bỏ lại dòng đó. Các công cụ do chính bạn khai báo, trong cấu hình của riêng bạn hoặc trong `mise.toml` của một dự án, vẫn hoạt động trong cả hai trường hợp. Nếu bạn chọn một tác nhân mặc định hoặc thiết lập Python sau khi loại bỏ các bản cài sẵn, công cụ đó sẽ được thêm vào cấu hình của riêng bạn. Cả hai đều chỉ áp dụng cho người dùng của bạn; những người dùng khác trên máy vẫn giữ lựa chọn của riêng họ.

## Docker

[Docker](https://www.docker.com/) hầu như không cần giới thiệu gì thêm. Nó cho phép bạn chạy các container cô lập, và Omarchy cài đặt mọi thứ cần thiết để chạy nó thật tốt, bao gồm chính Docker và [Docker Compose](https://docs.docker.com/compose/).

Theo mặc định, người dùng của bạn *không* nằm trong nhóm `docker`. Nhóm đó về thực chất là quyền root không cần mật khẩu — bất cứ thứ gì trong nhóm đều có thể `docker run -v /:/host` và chiếm quyền kiểm soát máy — vì vậy chỉ một script hoặc phụ thuộc phá hoại chạy dưới danh nghĩa của bạn thôi cũng sẽ chỉ còn cách quyền root một lệnh. Vì thế trên dòng lệnh, bạn chạy Docker bằng `sudo` (`sudo docker ps`, `sudo docker compose up`), và các công cụ đồ họa giao tiếp với daemon — Windows VM — sẽ yêu cầu ủy quyền khi cần. Nếu bạn muốn lấy lại sự tiện lợi của thiết lập không cần nhóm và hiểu rõ sự đánh đổi, hãy bật nó từ **Setup > Security > Sudoless Docker** (hoặc chạy `omarchy-setup-security-sudoless-docker`), thao tác này sẽ thêm bạn vào nhóm `docker` sau một cảnh báo; khi đó `docker` thông thường và bí danh `d` sẽ lại hoạt động mà không cần `sudo`.

Bạn có thể thiết lập các cơ sở dữ liệu phổ biến cho phát triển cục bộ trong Docker bằng _Install > Development > Docker DB_ trong menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) có sẵn dưới dạng `gh` để làm việc với các kho lưu trữ, issue và pull request từ terminal. Chạy `gh auth login` để cài đặt nó trong lần sử dụng đầu tiên và xác thực, sau đó chạy `gh repo clone org/repo` để sao chép một kho lưu trữ. Chạy `gh --help` để khám phá các lệnh của nó.

Để có giao diện terminal cho pull request, hãy chạy `ghui`; mise cũng cài đặt nó trong lần sử dụng đầu tiên. [Lazygit](https://github.com/jesseduffield/lazygit) được cài sẵn để làm việc với chính Git.
