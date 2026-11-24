# Công cụ phát triển

## Các trình soạn thảo thay thế

Omarchy đi kèm Plain làm trình soạn thảo mặc định trên các bản cài đặt mới và [Neovim](https://neovim.io/) được cài đặt sẵn, nhưng nếu bạn muốn thứ gì đó phổ biến và quen thuộc hơn một chút, bạn có thể chạy Omarchy Menu (`Super + Space`) và xem các lựa chọn trong _Install > Editor_. Tại đó chúng tôi có VSCode, Cursor, Zed, Sublime Text, Helix, Vim và Emacs. Nếu bạn không tìm thấy thứ mình cần, hãy xem _Install > Package_ và kiểm tra xem nó có trong một gói Arch hay không (và nếu không, hãy thử _Install > AUR_ để kiểm tra AUR).

Trình soạn thảo `vi` gốc cũng có sẵn ngay từ đầu. Chạy `vi filename` để chỉnh sửa một tệp trong terminal.

Tính năng khớp theme được cung cấp cho `VSCode`, `Cursor`, `VSCodium` và `Helix`.

Bạn có thể đặt trình soạn thảo mặc định trên toàn hệ thống trong `Setup > Defaults > Editor`.

## Môi trường

Omarchy hỗ trợ thiết lập cả loạt môi trường phát triển thông qua mục _Install > Development_ của Omarchy Menu (`Super + Space`). Tất nhiên bạn sẽ tìm thấy _Ruby on Rails_, nhưng cũng có cả ba runtime chính cho JavaScript (Node.js, Bun, Deno), cũng như các framework PHP phổ biến như Laravel và Symfony. Ồ, và còn có Go, Rust, Python, Java, Elixir (với Phoenix), .NET, OCaml, Zig, Clojure và Scala nữa. Lựa chọn rất phong phú!

Phần lớn các môi trường này được quản lý bởi [Mise](https://mise.jdx.dev/). Đây là một công cụ cho phép bạn cài đặt và chạy nhiều phiên bản của một ngôn ngữ lập trình trên cùng một máy. Nó giống như rbenv hoặc rvm cho Ruby hoặc virtualenv cho Python, nhưng hoạt động với nhiều môi trường khác nhau.

Ví dụ, để cài đặt Ruby, bạn chạy `mise use -g ruby`, lệnh này sẽ vừa cài đặt Ruby vừa đặt nó làm mặc định toàn cục. Hoặc, nếu dự án của bạn có tệp .ruby-version, bạn chỉ cần chạy `mise i` trong thư mục gốc của dự án đó.

## Các công cụ CLI được cài đặt sẵn

Omarchy cung cấp các công cụ như `gh`, `uv` và hầu hết [tác nhân lập trình](17-ai.md) thông qua [cơ chế cài đặt lười của mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Lần đầu tiên bạn chạy một công cụ, mise sẽ cài đặt nó. Các tác nhân lập trình sau đó sẽ kiểm tra bản cập nhật trước khi chạy, tối đa bốn giờ một lần; các công cụ khác, như `gh` và `uv`, sẽ dùng lại phiên bản đã cài đặt cho đến khi bạn cập nhật.

Bạn cũng có thể kiểm tra các mặc định hoặc cài đặt chúng trước:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Chạy `omarchy update` để cập nhật các công cụ đã cài đặt cùng với phần còn lại của Omarchy. Bí danh `mup` chỉ cập nhật các công cụ do mise quản lý. Để thêm một công cụ khác vào cấu hình của riêng bạn, hãy dùng `mise use -g <tool>`.

Thiết lập Python cũng cài đặt `uv` thông qua mise. Việc gỡ bỏ môi trường phát triển Python vẫn giữ `uv` khả dụng dưới dạng một công cụ độc lập.

### Sử dụng bản cài đặt của riêng bạn

Các lệnh của mise đứng trước `~/.local/bin` trên `PATH`, vì vậy một công cụ bạn tự cài đặt, chẳng hạn bằng trình cài đặt riêng của Claude Code hoặc Cursor, vẫn sẽ chạy bản sao của mise. Các ứng dụng được khởi chạy từ desktop cũng tìm thấy các lệnh của mise trước các gói hệ thống, vì vậy một ứng dụng chạy `gh` sẽ nhận được bản sao của mise ngay cả khi bạn đã cài đặt `github-cli` bằng pacman, và mise sẽ cài đặt bản sao đó ngay lần đầu tiên. Để thay vào đó dùng bản của bạn, hãy tắt bản sao của mise trong `~/.config/mise/config.toml`. Ví dụ, nếu bạn tự cài đặt Cursor CLI:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Nếu bạn đã có bảng `[settings]`, hãy thêm mục này vào đó; mở rộng danh sách `disable_tools` hiện có thay vì thay thế nó. Hãy đảm bảo bản cài đặt của bạn nằm trên `PATH`. Sử dụng tên công cụ của mise, tên này có thể khác với lệnh của nó: ví dụ, `oh-my-pi` cung cấp `omp`. Trình khởi chạy tác nhân mặc định cũng ưu tiên Cursor hoặc Muse do người dùng cài đặt trong `~/.local/bin`.

### Gỡ bỏ và khôi phục các mặc định

_Remove > Preinstalls_ gỡ bỏ các web app, TUI và ứng dụng được cài đặt sẵn của Omarchy, đồng thời yêu cầu mise bỏ qua các khai báo công cụ của Omarchy cho người dùng của bạn, bằng cách thêm chúng vào `ignored_config_paths` trong `~/.config/mise/miserc.toml`. _Install > Preinstalls_ sẽ mang chúng trở lại và xóa dòng đó đi. Các công cụ bạn tự khai báo, trong cấu hình của riêng bạn hoặc trong `mise.toml` của một dự án, vẫn hoạt động trong cả hai trường hợp. Nếu bạn chọn một tác nhân mặc định hoặc thiết lập Python sau khi gỡ bỏ các preinstall, công cụ đó sẽ được thêm vào cấu hình của riêng bạn. Cài đặt của mise chỉ áp dụng cho người dùng của bạn, và những người dùng khác vẫn giữ lựa chọn của riêng họ; tuy nhiên, các ứng dụng là các gói, vì vậy việc gỡ bỏ hoặc khôi phục chúng sẽ thay đổi chúng đối với mọi người trên máy.

## Docker

[Docker](https://www.docker.com/) hầu như không cần giới thiệu. Nó cho phép bạn chạy các container tách biệt, và Omarchy cài đặt mọi thứ cần thiết để chạy nó thật tốt, bao gồm Docker và [Docker Compose](https://docs.docker.com/compose/).

Theo mặc định, người dùng của bạn *không* thuộc nhóm `docker`. Nhóm đó thực tế là root không cần mật khẩu — bất cứ thứ gì thuộc nhóm đó đều có thể `docker run -v /:/host` và chiếm quyền kiểm soát máy — vì vậy một script hoặc dependency nguy hại duy nhất chạy dưới quyền của bạn nếu không sẽ chỉ cách root một lệnh. Vì vậy trên dòng lệnh, bạn chạy Docker bằng `sudo` (`sudo docker ps`, `sudo docker compose up`), và các công cụ đồ họa giao tiếp với daemon — Windows VM — sẽ yêu cầu ủy quyền khi cần. Nếu bạn muốn lấy lại sự tiện lợi của thiết lập không cần sudo và hiểu rõ sự đánh đổi, hãy bật nó từ **Setup > Security > Sudoless Docker** (hoặc chạy `omarchy-setup-security-sudoless-docker`), thao tác này sẽ thêm bạn vào nhóm `docker` sau một cảnh báo; sau đó `docker` thông thường và bí danh `d` sẽ lại hoạt động mà không cần `sudo`.

Bạn có thể thiết lập các cơ sở dữ liệu phổ biến cho phát triển cục bộ trong Docker bằng _Install > Development > Docker DB_ trong Omarchy menu.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) có sẵn dưới dạng `gh` để làm việc với các repository, issue và pull request từ terminal. Chạy `gh auth login` để cài đặt nó trong lần sử dụng đầu tiên và xác thực, sau đó `gh repo clone org/repo` để clone một repository. Chạy `gh --help` để khám phá các lệnh của nó.

Để có giao diện terminal cho các pull request, hãy chạy `ghui`; mise cũng cài đặt nó trong lần sử dụng đầu tiên. [Lazygit](https://github.com/jesseduffield/lazygit) được cài đặt sẵn để làm việc với chính Git.
