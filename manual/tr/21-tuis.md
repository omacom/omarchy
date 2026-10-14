# TUI'lar

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit), GitHub Desktop uygulaması gibi bir şeye keyifli bir alternatiftir ve terminal içinde çalışır.

Onu doğrudan, git tarafından yönetilen herhangi bir dizine gidip `lazygit` çalıştırarak çalıştırabilirsiniz. Ya da `Space G G` ile başlatılabildiği Neovim içinde çalıştırabilirsiniz.

Farklı bölmeler arasında `Tab` kullanarak gezersiniz. Files bölmesinde, `Space` kullanarak sahneleme (staging) için dosyaları seçersiniz ve ardından `c` kullanarak yeni bir commit oluşturabilirsiniz. Kullanılabilir tüm komutları `?` kullanarak görebilirsiniz.

## Btop

[Btop](https://github.com/aristocratos/btop), bellek, CPU, disk ve ağ kullanımını gösteren güzel bir kaynak yöneticisidir. Ayrıca tüm etkin işlemleri listeler ve onları yönetmenize olanak tanır.

Omarchy buna Activity der ve `Super + Ctrl + T` tuşlarına basarak başlatırsınız. Yüzen bir pencere olarak açılır; bunu `Super + T` ile döşeyebilirsiniz.

## Herdr

[Herdr](https://github.com/omacom-io/herdr), size çalışma alanları, sekmeler ve bölmeler veren ve hepsini daha sonra ayrılıp geri dönebileceğiniz kalıcı bir oturumda çalışır durumda tutan bir terminal çalışma alanı yöneticisidir.

Onu `Super + Ctrl + Return` ile başlatırsınız (veya mevcut oturumunuza yeniden bağlanırsınız). Omarchy, Tmux yapılandırmasını yansıtan bir Herdr yapılandırmasıyla gelir, bu yüzden önek tuşu burada da `Ctrl + Space`'tir. Tüm tuş atamalarına `Super + Ctrl + K` ile göz atabilirsiniz.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch), çekirdek sürümü, çalışma süresi, tema, CPU, bellek ve daha fazlası gibi sistem bilgilerini gösterir. Popüler neofetch aracının halefidir.

Omarchy bunu Omarchy menüsünde (`Super + Space`) _Hakkında_ olarak paketlemiştir.

## Cliamp

[Cliamp](https://www.cliamp.stream/), Winamp 2.x'ten esinlenmiş, lo-fi beat'ler için yerleşik radyo istasyonlarıyla birlikte gelen retro bir terminal müzik çalarıdır. Onu `Super + Shift + Alt + M` ile veya Omarchy menüsündeki _Uygulamalar_ altından başlatın. Tam tuş atama listesi için `?` tuşuna basın.

## Peki ya Wi-Fi ve Bluetooth?

Wi-Fi ve Bluetooth için TUI bulamayacaksınız — bu işler Omarchy kabuğuna aittir. Ağları görmek ve bağlanmak için üst çubuktaki Wi-Fi simgesine tıklayın (veya `Super + Ctrl + W` tuşlarına basın) ve cihazları eşleştirip bağlamak için Bluetooth simgesine tıklayın (veya `Super + Ctrl + B` tuşlarına basın). Tüm hikaye için [ağ](35-networking.md) bölümüne bakın.

## Kendininkini eklemek

Herhangi bir terminal programı tam uygulama muamelesi görebilir. Omarchy menüsünde (`Super + Space`) _Kur > TUI_ seçeneğine gidin, ona bir ad, bir başlatma komutu, bir pencere stili ve bir simge verin; o da diğer uygulamalar gibi uygulama başlatıcıda görünecektir. Onu _Kaldır > TUI_ altından yeniden kaldırabilirsiniz.
