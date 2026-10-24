# Penyelesaian masalah

### Saya merosakkan sistem saya dengan kemas kini!

Mula-mula cuba [kembalikan sistem anda](47-system-snapshots.md) kepada versi sebelum kemas kini terbaharu anda. Jika itu tidak berfungsi, gunakan `omarchy-debug` untuk berkongsi masalah anda di #omarchy-help dalam Discord. Dan jika semua itu gagal, anda boleh memasang semula konfigurasi dan pakej lalai menggunakan `omarchy-reinstall`.

### Mengapa sesetengah aplikasi sangat besar pada paparan saya?

Omarchy menganggap paparan resolusi tinggi 2x, yang memerlukan penetapan `GDK_SCALE` kepada 2 dalam `~/.config/hypr/monitors.lua`. Tetapi jika anda menggunakan paparan 1x, anda boleh menukar `local omarchy_gdk_scale = 2` kepada 1 (dan kemudian mulakan semula mana-mana aplikasi yang bersaiz besar). Lihat [manual tentang monitor](33-monitors.md).

Untuk Spotify, anda boleh menggunakan `Ctrl + Minus` untuk mengecilkan UI (dan `Ctrl + Plus` untuk membesarkannya).

### Wi-Fi, Bluetooth, audio, atau pad sentuh saya tiba-tiba berhenti berfungsi

Sebelum anda but semula, cuba mulakan semula subsistem yang bermasalah itu sahaja. _Kemas Kini > Perkakasan_ dalam menu Omarchy mempunyai Wi-Fi, Bluetooth, Audio, dan Pad Sentuh, dan memuat semula salah satu daripadanya menyelesaikan kebanyakan situasi "ia berfungsi lima minit yang lalu" — set kepala Bluetooth yang tidak mahu menyambung semula, pad sentuh yang mati selepas suspend, bunyi yang hilang apabila anda mencabut monitor.

### Mengapa pembesar suara luaran saya tidak berbunyi?

Mungkin kerana ia tidak ditetapkan sebagai output utama. Klik ikon pembesar suara di sebelah kanan bar, dan ia akan membuka tetingkap timbul kelantangan di mana anda boleh memilih peranti output (dan mencampur kelantangan setiap aplikasi juga).

### Pembesar suara laptop saya kedengaran tidak betul

Pada sesetengah laptop, Omarchy secara automatik menggunakan penalaan pembesar suara yang membetulkan tindak balas frekuensi pembesar suara terbina dalam. `omarchy audio tuning status` memberitahu anda sama ada satu penalaan aktif pada mesin anda, dan `omarchy audio tuning off` mematikannya jika anda lebih suka mendengar pembesar suara secara mentah.

### Mengapa saya tidak boleh log masuk atau sudo dengan kata laluan saya?

Anda mungkin menaipnya salah terlalu banyak kali dan dikunci keluar. Jika ini berlaku pada skrin kunci, anda boleh tekan `CTRL + ALT + F2` untuk memulakan TTY baharu di mana anda boleh log masuk sebagai root, kemudian jalankan `faillock --reset --user [your-username]`. Itu akan menetapkan semula penguncian, dan anda sudah bersedia.

### Mengapa gesaan kebenaran 1Password saya untuk 1Password SSH Agent / CLI tidak muncul?

Ini boleh berlaku atas 2 sebab:

Agar gesaan kelulusan yang kaya muncul, Settings > Advanced > Use Hardware Acceleration mesti dihidupkan. _Nota: Ini memerlukan but semula untuk mula berfungsi._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Atau jika anda belum melancarkan 1Password sejak but, gesaan tidak akan muncul.
