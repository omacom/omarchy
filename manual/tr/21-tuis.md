# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit), GitHub Desktop gibi bir şeye keyifli bir alternatiftir ve terminalin içinde çalışır.

Onu doğrudan, git tarafından yönetilen herhangi bir dizine gidip `lazygit` çalıştırarak çalıştırabilirsiniz. Ya da `Space G G` ile başlatılabildiği Neovim içinde çalıştırabilirsiniz.

Farklı bölmeler arasında `Tab` ile geçiş yaparsınız. Dosyalar bölmesinde, dosyaları `Space` ile aşamalandırma için seçersiniz ve ardından `c` ile yeni bir commit oluşturabilirsiniz. Kullanılabilir tüm komutları `?` ile görebilirsiniz.

## Btop

[Btop](https://github.com/aristocratos/btop), bellek, CPU, disk ve ağ kullanımını gösteren güzel bir kaynak yöneticisidir. Ayrıca tüm aktif süreçleri listeler ve onları yönetmenize olanak tanır.

Omarchy ona Activity Monitor der ve onu uygulama başlatıcıdan ya da `Super + Shift + T` tuşlarına basarak başlatırsınız. Yüzen bir pencere olarak açılır; `Super + T` ile onu döşeyebilirsiniz.

## Herdr

[Herdr](https://github.com/omacom-io/herdr), size çalışma alanları, sekmeler ve bölmeler sunan ve hepsini daha sonra ayrılıp geri dönebileceğiniz kalıcı bir oturumda çalışır durumda tutan bir terminal çalışma alanı yöneticisidir.

Onu uygulama başlatıcıdan ya da `Super + Ctrl + Return` ile başlatırsınız (ya da mevcut oturumunuza yeniden bağlanırsınız). Omarchy, Tmux yapılandırmasını yansıtan bir Herdr yapılandırmasıyla gelir, bu yüzden önek tuşu burada da `Ctrl + Space` tuşudur. Tüm tuş atamalarına `Super + Ctrl + K` ile göz atabilirsiniz.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch), çekirdek sürümü, çalışma süresi, tema, CPU, bellek ve daha fazlası gibi sistem bilgilerini gösterir. Popüler neofetch aracının halefidir.

Omarchy bunu Omarchy menüsünde (`Super + Space`) _About_ olarak paketlemiştir.

## Cliamp

[Cliamp](https://www.cliamp.stream/), Winamp 2.x'ten esinlenen, lo-fi ritimler için yerleşik radyo istasyonlarıyla birlikte gelen retro bir terminal müzik çalarıdır. Onu `Super + Shift + Alt + M` ile ya da Omarchy menüsünde _Apps_ altından başlatın. Tam tuş atama listesi için `?` tuşuna basın.

## Wi-Fi ve Bluetooth ne olacak?

Wi-Fi ve Bluetooth için TUI'lar bulamazsınız — bu işler Omarchy kabuğuna aittir. Ağları görmek ve bağlanmak için üst çubuktaki Wi-Fi simgesine tıklayın (ya da `Super + Ctrl + N` tuşlarına basın), cihazları eşleştirmek ve bağlamak için de Bluetooth simgesine tıklayın (ya da `Super + Ctrl + B` tuşlarına basın). Hikayenin tamamı için bkz. [ağ](35-networking.md).

## Kendinizinkini ekleme

Herhangi bir terminal programı tam uygulama muamelesi görebilir. Omarchy menüsünde (`Super + Space`) _Install > TUI_ yoluna gidin, ona bir ad, bir başlatma komutu, bir pencere stili ve bir simge verin; uygulama başlatıcıda diğer uygulamalar gibi görünecektir. Onu _Remove > TUI_ altından tekrar kaldırabilirsiniz.
