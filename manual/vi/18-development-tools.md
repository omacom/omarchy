# Công cụ phát triển

## Trình soạn thảo thay thế

Omarchy đi kèm Plain làm trình soạn thảo mặc định trên các bản cài mới và [Neovim](https://neovim.io/) được cài sẵn, nhưng nếu bạn muốn thứ gì đó phổ biến và quen thuộc hơn một chút, bạn có thể chạy Omarchy Menu (`Super + Space`) và xem các tùy chọn dưới _Install > Editor_. Chúng tôi có VSCode, Cursor, Zed, Sublime Text, Helix, Vim và Emacs được liệt kê ở đó. Nếu bạn không tìm thấy thứ mình đang tìm, hãy kiểm tra _Install > Package_ và xem nó có trong một gói Arch nào không (và nếu không, hãy thử _Install > AUR_ để kiểm tra AUR).

Trình soạn thảo `vi` gốc cũng có sẵn ngay từ đầu. Chạy `vi filename` để chỉnh sửa một tệp trong terminal.

Tính năng khớp theme được cung cấp cho `VSCode`, `Cursor`, `VSCodium` và `Helix`.

Bạn có thể đặt trình soạn thảo mặc định cho toàn hệ thống dưới `Setup > Defaults > Editor`.

## Môi trường

Omarchy hỗ trợ thiết lập cả loạt môi trường phát triển thông qua mục _Install > Development_ của Omarchy Menu (`Super + Space`). Tất nhiên bạn sẽ tìm thấy _Ruby on Rails_, nhưng cũng có cả ba runtime chính cho JavaScript (Node.js, Bun, Deno), cũng như các framework PHP phổ biến như Laravel và Symfony. À, và cũng có Go, Rust, Python, Java, Elixir (với Phoenix), .NET, OCaml, Zig, Clojure và Scala nữa. Đó là một lựa chọn rất phong phú!

Phần lớn các môi trường này được quản lý bởi [Mise](https://mise.jdx.dev/). Đó là một công cụ cho phép bạn cài đặt và chạy nhiều phiên bản của một ngôn ngữ lập trình trên cùng một máy. Nó giống như rbenv hoặc rvm cho Ruby hoặc virtualenv cho Python, nhưng hoạt động với nhiều môi trường khác nhau.

Để cài đặt, chẳng hạn, Ruby, bạn sẽ chạy `mise use -g ruby`, lệnh này vừa cài đặt Ruby vừa đặt nó làm mặc định toàn cục. Hoặc, nếu dự án của bạn có tệp .ruby-version, bạn có thể chỉ cần chạy `mise i` trong thư mục gốc của dự án đó.

## Công cụ CLI được cài sẵn

`uv`, Node.js và `playwright-cli` (để các agent điều khiển một trình duyệt, sử dụng Chrome đã cài) được cài sẵn dưới dạng gói, và `omarchy update` giữ chúng luôn cập nhật cùng với phần còn lại của hệ thống. [Hunk](https://github.com/modem-dev/hunk) cùng các CLI của GitHub, Basecamp, Cloudflare và HEY chỉ cách một lần chọn dưới _Install > CLI_, và [coding agents](17-ai.md) dưới _Install > AI > CLI_.

mise chỉ quản lý các runtime bạn thiết lập từ _Install > Development_; Omarchy tự nó không cài đặt gì thông qua nó. Chạy `omarchy update` để cập nhật chúng cùng với phần còn lại của Omarchy; alias `mup` chỉ cập nhật các công cụ do mise quản lý. Để thêm một công cụ khác vào cấu hình của riêng bạn, hãy dùng `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) hầu như không cần giới thiệu. Nó cho phép bạn chạy các container cô lập, và Omarchy cài đặt mọi thứ cần thiết để chạy nó tốt, bao gồm chính Docker và [Docker Compose](https://docs.docker.com/compose/).

Theo mặc định, người dùng của bạn *không* nằm trong nhóm `docker`. Nhóm đó thực tế là root không cần mật khẩu — bất cứ thứ gì trong đó đều có thể `docker run -v /:/host` và chiếm quyền kiểm soát máy — vì vậy một script hoặc dependency nguy hiểm duy nhất chạy dưới quyền của bạn nếu không sẽ chỉ cách root một lệnh. Vì vậy trên dòng lệnh, bạn chạy Docker bằng `sudo` (`sudo docker ps`, `sudo docker compose up`), và các công cụ đồ họa giao tiếp với daemon — Windows VM — sẽ yêu cầu ủy quyền khi cần. Nếu bạn muốn lấy lại sự tiện lợi của thiết lập không cần nhóm và hiểu rõ sự đánh đổi, hãy bật nó từ **Setup > Security > Sudoless Docker** (hoặc chạy `omarchy-setup-security-sudoless-docker`), lệnh này sẽ thêm bạn vào nhóm `docker` sau một cảnh báo; khi đó `docker` thông thường và alias `d` lại hoạt động mà không cần `sudo`.

Bạn có thể thiết lập các cơ sở dữ liệu phổ biến cho phát triển cục bộ trong Docker bằng _Install > Development > Docker DB_ trong menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) là `gh`, để làm việc với các repository, issue và pull request từ terminal. _Setup > Git_ sẽ cài đặt nó khi bạn chọn đăng nhập vào GitHub ở đó, hoặc cài đặt riêng nó từ _Install > CLI > GitHub_. Sau đó `gh repo clone org/repo` sẽ clone một repository; chạy `gh --help` để khám phá các lệnh của nó.

[Lazygit](https://github.com/jesseduffield/lazygit) được cài sẵn để làm việc với chính Git.
