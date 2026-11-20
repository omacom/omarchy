# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit), GitHub Desktop gibi bir uygulamaya keyifli bir alternatiftir ve terminalin içinde çalışır.

Onu doğrudan çalıştırabilirsiniz; git tarafından yönetilen herhangi bir dizine gidip `lazygit` çalıştırmanız yeterli. Ya da Neovim içinde çalıştırabilirsiniz; orada `Space G G` ile başlatılır.

Farklı bölmeler arasında `Tab` ile gezersiniz. Files bölmesinde, `Space` ile dosyaları hazırlık alanına eklenecek şekilde seçersiniz ve ardından `c` ile yeni bir commit oluşturabilirsiniz. Mevcut tüm komutları `?` ile görebilirsiniz.

## Btop

[Btop](https://github.com/aristocratos/btop), bellek, CPU, disk ve ağ kullanımını gösteren güzel bir kaynak yöneticisidir. Ayrıca tüm etkin süreçleri listeler ve onları yönetmenize olanak tanır.

Omarchy buna Activity Monitor der ve onu uygulama başlatıcıdan ya da `Super + Shift + T` tuşlarına basarak başlatırsınız. Yüzen bir pencere olarak açılır; `Super + T` ile döşeyebilirsiniz.

## Herdr

[Herdr](https://github.com/omacom-io/herdr), size çalışma alanları, sekmeler ve bölmeler sunan ve hepsini, daha sonra ayrılıp geri dönebileceğiniz kalıcı bir oturumda çalışır durumda tutan bir terminal çalışma alanı yöneticisidir.

Onu uygulama başlatıcıdan ya da `Super + Ctrl + Return` ile başlatırsınız (veya mevcut oturumunuza yeniden bağlanırsınız). Omarchy, Tmux yapılandırmasını yansıtan bir Herdr yapılandırmasıyla gelir, bu yüzden önek tuşu burada da `Ctrl + Space` tuşudur. Tüm tuş atamalarına `Super + Ctrl + K` ile göz atabilirsiniz.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch), çekirdek sürümü, çalışma süresi, tema, CPU, bellek ve daha fazlası gibi sistem bilgilerini gösterir. Popüler neofetch aracının halefidir.

Omarchy bunu Omarchy menüsünde (`Super + Space`) _System > About_ olarak paketlemiştir.

## Cliamp

[Cliamp](https://www.cliamp.stream/), Winamp 2.x'ten ilham alan, lo-fi beat'ler için yerleşik radyo istasyonlarıyla birlikte gelen retro bir terminal müzik çalarıdır. Onu `Super + Shift + Alt + M` ile ya da Omarchy menüsünde _Apps_ altından başlatın. Tam tuş atama listesi için `?` tuşuna basın.

## Peki ya Wi-Fi ve Bluetooth?

Wi-Fi ve Bluetooth için TUI bulamazsınız — bu işler Omarchy kabuğuna aittir. Ağları görmek ve bağlanmak için üst çubuktaki Wi-Fi simgesine tıklayın (ya da `Super + Ctrl + N` tuşlarına basın), cihazları eşleştirmek ve bağlamak için de Bluetooth simgesine tıklayın (ya da `Super + Ctrl + B` tuşlarına basın). Hikâyenin tamamı için bkz. [ağ](35-networking.md).

## Kendinizinkini ekleme

Herhangi bir terminal programı tam uygulama muamelesi görebilir. Omarchy menüsünde (`Super + Space`) _Install > TUI_ yoluna gidin, ona bir ad, bir başlatma komutu, bir pencere stili ve bir simge verin; uygulama başlatıcıda diğer tüm uygulamalar gibi görünecektir. Onu _Remove > TUI_ altından tekrar kaldırabilirsiniz.
