# Penyelesaian Masalah

### Saya rosakkan sistem saya dengan kemas kini!

Mula-mula cuba [kembalikan sistem anda](47-system-snapshots.md) kepada versi sebelum kemas kini terkini anda. Jika itu tidak berkesan, gunakan `omarchy-debug` untuk berkongsi masalah anda di #omarchy-help dalam Discord. Dan jika semuanya gagal, anda boleh memasang semula konfigurasi dan pakej lalai menggunakan `omarchy-reinstall`.

### Mengapa sesetengah aplikasi begitu besar pada paparan saya?

Omarchy mengandaikan paparan beresolusi tinggi 2x, jadi ia menetapkan `GDK_SCALE` kepada 2 sehingga anda memilih skala dalam panel monitor. Jika anda menggunakan paparan 1x dan aplikasi GTK atau X11 kelihatan terlalu besar, pilih 1x untuknya dalam panel monitor, atau tambahkan `hl.env("GDK_SCALE", "1")` pada `~/.config/hypr/monitors.lua` (dan kemudian mulakan semula mana-mana aplikasi yang terlalu besar). Lihat [manual tentang monitor](33-monitors.md).

Untuk Spotify, anda boleh menggunakan `Ctrl + Minus` untuk mengecilkan UI (dan `Ctrl + Plus` untuk membesarkannya).

### Mengapa semua ikatan kekunci Super saya berhenti berfungsi?

Pada sesetengah komputer riba ASUS ROG dan TUF, `Fn + Super` ialah gabungan kekunci yang mudah terlepas pandang yang menogol kunci kekunci Windows perisian tegar (dimaksudkan untuk permainan supaya anda tidak keluar daripada permainan secara tidak sengaja). Tiada apa-apa pada skrin yang memberitahu anda perkara itu berlaku. Semasa kunci itu aktif, Super tidak mengeluarkan apa-apa langsung — jadi setiap ikatan Omarchy yang menggunakan Super terus berhenti berfungsi, dan ia kelihatan seolah-olah Hyprland yang rosak.

Tekan `Fn + Super` sekali sebelum anda menggali ke dalam `~/.config/hypr/`, dan jika itu tidak mengembalikan Super, tekannya sekali lagi supaya anda tidak membiarkan kunci itu kekal aktif. Ini bukan kunci Fn, yang hanya mengubah fungsi baris kekunci F.

### Wi-Fi, Bluetooth, audio, atau pad jejak saya tiba-tiba berhenti berfungsi

Sebelum anda but semula, cuba mulakan semula subsistem yang bermasalah itu secara berasingan. _Update > Hardware_ dalam menu Omarchy mempunyai Wi-Fi, Bluetooth, Audio, dan Trackpad, dan memuat semula salah satu daripadanya dapat menyelesaikan kebanyakan situasi "ia berfungsi lima minit yang lalu" — set kepala Bluetooth yang tidak mahu menyambung semula, pad jejak yang mati selepas digantung, bunyi yang hilang apabila anda mencabut monitor.

### Mengapa pembesar suara luaran saya tidak berbunyi?

Mungkin kerana ia tidak ditetapkan sebagai output utama. Klik pada ikon pembesar suara di sebelah kanan bar, dan ia akan membuka pop timbul kelantangan di mana anda boleh memilih peranti output (dan mengadun kelantangan mengikut aplikasi juga).

### Pembesar suara komputer riba saya berbunyi pelik

Pada sesetengah komputer riba, Omarchy secara automatik menggunakan penalaan pembesar suara yang membetulkan respons frekuensi pembesar suara terbina dalam. `omarchy audio tuning status` memberitahu anda sama ada penalaan itu aktif pada mesin anda, dan `omarchy audio tuning off` mematikannya jika anda lebih suka mendengar pembesar suara secara mentah.

### Mengapa saya tidak boleh log masuk atau sudo dengan kata laluan saya?

Anda mungkin telah menaipnya dengan salah terlalu banyak kali dan telah dikunci keluar. Jika ini berlaku pada skrin kunci, anda boleh tekan `CTRL + ALT + F2` untuk memulakan TTY baharu di mana anda boleh log masuk sebagai root, kemudian jalankan `faillock --reset --user [your-username]`. Itu akan menetapkan semula penguncian tersebut, dan anda sedia untuk meneruskan.

### Mengapa gesaan kebenaran 1Password saya untuk 1Password SSH Agent / CLI tidak muncul?

Ini boleh berlaku atas 2 sebab:

Agar gesaan kelulusan yang lengkap muncul, Settings > Advanced > Use Hardware Acceleration mesti dihidupkan. _Nota: Ini memerlukan but semula untuk mula berfungsi._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Atau jika anda belum melancarkan 1Password sejak but, gesaan itu tidak akan muncul.
