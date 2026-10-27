# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) GitHub Desktop gibi bir uygulamaya keyifli bir alternatiftir ve terminalin içinde çalışır.

Onu doğrudan, git tarafından yönetilen herhangi bir dizine gidip `lazygit` çalıştırarak çalıştırabilirsiniz. Ya da onu Neovim içinde çalıştırabilirsiniz; orada `Space G G` ile başlatılabilir.

Farklı bölmeler arasında `Tab` kullanarak gezersiniz. Files bölmesinde, `Space` kullanarak dosyaları sahneye almak için seçersiniz ve ardından `c` kullanarak yeni bir commit oluşturabilirsiniz. Mevcut tüm komutları `?` kullanarak görebilirsiniz.

## Btop

[Btop](https://github.com/aristocratos/btop) bellek, CPU, disk ve ağ kullanımını gösteren güzel bir kaynak yöneticisidir. Ayrıca tüm etkin süreçleri listeler ve onları yönetmenize olanak tanır.

Omarchy ona Activity der ve onu `Super + Shift + T` tuşlarına basarak başlatırsınız. Kayan bir pencere olarak açılır; onu `Super + T` ile döşeyebilirsiniz.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) size çalışma alanları, sekmeler ve bölmeler veren ve hepsini, bağlantısını kesip daha sonra geri dönebileceğiniz kalıcı bir oturumda çalışır durumda tutan bir terminal çalışma alanı yöneticisidir.

Onu `Super + Ctrl + Return` ile başlatırsınız (ya da mevcut oturumunuza yeniden bağlanırsınız). Omarchy, Tmux yapılandırmasını yansıtan bir Herdr yapılandırması ile birlikte gelir, bu yüzden önek tuşu burada da `Ctrl + Space` tuşudur. Tüm tuş atamalarına `Super + Ctrl + K` ile göz atabilirsiniz.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) çekirdek sürümü, çalışma süresi, tema, CPU, bellek ve daha fazlası gibi sistem bilgilerini gösterir. Popüler neofetch aracının halefidir.

Omarchy bunu Omarchy menüsünde (`Super + Space`) _About_ olarak paketlemiştir.

## Cliamp

[Cliamp](https://www.cliamp.stream/) Winamp 2.x'ten ilham alan, lo-fi beats için yerleşik radyo istasyonlarıyla tamamlanmış retro bir terminal müzik çalarıdır. Onu `Super + Shift + Alt + M` ile ya da Omarchy menüsünde _Apps_ altında başlatın. Tam tuş atama listesi için `?` tuşuna basın.

## Peki ya Wi-Fi ve Bluetooth?

Wi-Fi ve Bluetooth için TUI'ler bulamazsınız — bu işler Omarchy kabuğuna aittir. Ağları görmek ve bağlanmak için üst çubuktaki Wi-Fi simgesine tıklayın (ya da `Super + Ctrl + N` tuşlarına basın) ve cihazları eşleştirmek ve bağlamak için Bluetooth simgesine tıklayın (ya da `Super + Ctrl + B` tuşlarına basın). Hikâyenin tamamı için bkz. [ağ](35-networking.md).

## Kendi TUI'nizi ekleme

Herhangi bir terminal programı tam uygulama muamelesi görebilir. Omarchy menüsünde (`Super + Space`) _Install > TUI_ bölümüne gidin, ona bir ad, bir başlatma komutu, bir pencere stili ve bir simge verin; uygulama başlatıcıda diğer tüm uygulamalar gibi görünecektir. Onu _Remove > TUI_ altında tekrar kaldırabilirsiniz.
