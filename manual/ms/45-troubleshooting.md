# Penyelesaian Masalah

### Saya rosakkan sistem saya dengan kemas kini!

Mula-mula cuba [kembalikan sistem anda](47-system-snapshots.md) kepada versi sebelum kemas kini terbaru anda. Jika itu tidak berjaya, gunakan `omarchy-debug` untuk berkongsi masalah anda di #omarchy-help dalam Discord. Dan jika semua itu gagal, anda boleh memasang semula konfigurasi dan pakej lalai menggunakan `omarchy-reinstall`.

### Mengapa sesetengah aplikasi begitu besar pada paparan saya?

Omarchy mengandaikan paparan beresolusi tinggi 2x, jadi ia menetapkan `GDK_SCALE` kepada 2 sehingga anda memilih skala dalam panel monitor. Jika anda menggunakan paparan 1x dan aplikasi GTK atau X11 kelihatan terlalu besar, pilih 1x untuknya dalam panel monitor, atau tambah `hl.env("GDK_SCALE", "1")` pada `~/.config/hypr/monitors.lua` (dan kemudian mulakan semula sebarang aplikasi yang terlalu besar). Lihat [manual tentang monitor](33-monitors.md).

Untuk Spotify, anda boleh menggunakan `Ctrl + Minus` untuk mengecilkan UI (dan `Ctrl + Plus` untuk membesarkannya).

### Mengapa semua ikatan kekunci Super saya berhenti berfungsi?

Pada sesetengah komputer riba ASUS ROG dan TUF, `Fn + Super` ialah gabungan kekunci yang mudah terlepas pandang yang menogol kunci kekunci Windows perisian tegar (dimaksudkan untuk permainan supaya anda tidak keluar daripada permainan secara tidak sengaja). Tiada apa-apa pada skrin yang memberitahu anda ia telah berlaku. Semasa kunci itu aktif, Super tidak menghantar apa-apa langsung — jadi setiap ikatan Omarchy yang menggunakan Super akan berhenti begitu sahaja, dan ia kelihatan seperti Hyprland yang rosak.

Tekan `Fn + Super` sekali sebelum anda mengutak-atik `~/.config/hypr/`, dan jika itu tidak mengembalikan Super, tekannya sekali lagi supaya anda tidak membiarkan kunci itu kekal aktif. Ini bukan Fn-lock, yang hanya mengubah fungsi baris kekunci F.

### Wi-Fi, Bluetooth, audio, atau pad jejak saya tiba-tiba berhenti berfungsi

Sebelum anda but semula, cuba mulakan semula subsistem yang bermasalah itu secara berasingan. _Update > Hardware_ dalam menu Omarchy mempunyai Wi-Fi, Bluetooth, Audio, dan Trackpad, dan memuat semula salah satu daripadanya menyelesaikan kebanyakan situasi "ia berfungsi lima minit lepas" — set kepala Bluetooth yang enggan menyambung semula, pad jejak yang mati selepas suspend, bunyi yang hilang apabila anda mencabut monitor.

### Mengapa pembesar suara luaran saya tidak berbunyi?

Mungkin kerana ia tidak ditetapkan sebagai output utama. Klik pada ikon pembesar suara di sebelah kanan bar, dan ia akan membuka popup kelantangan di mana anda boleh memilih peranti output (dan melaraskan kelantangan setiap aplikasi juga).

### Pembesar suara komputer riba saya berbunyi pelik

Pada sesetengah komputer riba, Omarchy secara automatik menggunakan penalaan pembesar suara yang membetulkan tindak balas frekuensi pembesar suara terbina dalam. `omarchy audio tuning status` memberitahu anda sama ada satu penalaan aktif pada mesin anda, dan `omarchy audio tuning off` mematikannya jika anda lebih suka mendengar pembesar suara dalam keadaan asal.

### Mengapa saya tidak boleh log masuk atau sudo dengan kata laluan saya?

Anda mungkin telah menaipnya salah sepuluh kali dan telah dikunci keluar. Kunci keluar itu akan hilang sendiri selepas dua minit. Jika anda tidak boleh menunggu, dan ini berlaku pada skrin kunci, anda boleh tekan `CTRL + ALT + F2` untuk memulakan TTY baharu di mana anda boleh log masuk sebagai root, kemudian jalankan `faillock --reset --user [your-username]`. Itu akan menetapkan semula kunci keluar tersebut, dan anda sudah boleh teruskan.

### Kata laluan saya diterima, tetapi saya kembali ke skrin log masuk

Fail persekitaran sesi yang rosak boleh menghalang desktop daripada dimulakan walaupun kata laluan anda betul. Ini amat berbaloi untuk diperiksa selepas mengedit `~/.config/uwsm/env.d/`.

Tekan `Ctrl + Alt + F2`, log masuk dengan nama pengguna dan kata laluan biasa anda, dan periksa jurnal pengguna bagi but semasa:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Cari ralat yang menamakan salah satu fail persekitaran anda, seperti `bad substitution`, sejurus sebelum mesej bahawa tanda output env tidak ditemui. Alihkan fail itu keluar daripada `env.d` sebelum cuba log masuk semula. Contohnya, jika ralat itu menamakan `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM melangkau fail yang mempunyai ralat sintaks, tetapi ralat fatal yang hanya muncul semasa fail itu berjalan, seperti `bad substitution`, masih boleh menghalang desktop daripada dimulakan. Pengembalian semula snapshot sistem tidak membaiki fail-fail ini, kerana `/home` tidak dikembalikan.

Sebaik sahaja anda boleh log masuk, baiki salinan yang disimpan itu sebelum mengalihkannya kembali. `sh -n` mengesan ralat sintaks tanpa menjalankan fail, tetapi tidak dapat mengesan setiap ralat yang berlaku apabila ia disumberkan. Pastikan terminal yang berfungsi kekal terbuka semasa menguji perubahan.

### Mengapa gesaan kebenaran 1Password saya untuk 1Password SSH Agent / CLI tidak muncul?

Ini boleh berlaku atas 2 sebab:

Supaya gesaan kelulusan yang lengkap itu muncul, Settings > Advanced > Use Hardware Acceleration mesti dihidupkan. _Nota: Ini memerlukan but semula untuk mula berfungsi._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Atau jika anda belum melancarkan 1Password sejak but, gesaan itu tidak akan muncul.
