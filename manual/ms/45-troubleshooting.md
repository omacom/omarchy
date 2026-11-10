# Penyelesaian Masalah

### Sistem saya rosak selepas kemas kini!

Cuba dulu [pulihkan sistem anda](47-system-snapshots.md) ke versi sebelum kemas kini terbaharu anda. Jika itu tidak berjaya, gunakan `omarchy-debug` untuk berkongsi masalah anda di #omarchy-help dalam Discord. Dan jika semuanya gagal, anda boleh memasang semula konfigurasi dan pakej lalai menggunakan `omarchy-reinstall`.

### Mengapa sesetengah aplikasi kelihatan begitu besar pada paparan saya?

Omarchy menganggap paparan beresolusi tinggi 2x, jadi ia menetapkan `GDK_SCALE` kepada 2 sehingga anda memilih skala dalam panel monitor. Jika anda menggunakan paparan 1x dan aplikasi GTK atau X11 kelihatan terlalu besar, pilih 1x untuk paparan itu dalam panel monitor, atau tambah `hl.env("GDK_SCALE", "1")` pada `~/.config/hypr/monitors.lua` (kemudian mulakan semula mana-mana aplikasi yang terlalu besar). Lihat [manual tentang monitor](33-monitors.md).

Untuk Spotify, anda boleh menggunakan `Ctrl + Minus` untuk mengecilkan UI (dan `Ctrl + Plus` untuk membesarkannya).

### Mengapa semua ikatan kekunci Super saya berhenti berfungsi?

Pada sesetengah komputer riba ASUS ROG dan TUF, `Fn + Super` ialah gabungan kekunci yang mudah terlepas pandang yang menogol kunci kekunci Windows perisian tegar (bertujuan untuk permainan supaya anda tidak terkeluar daripada permainan secara tidak sengaja). Tiada apa-apa pada skrin yang memberitahu anda ia telah berlaku. Semasa kunci itu aktif, Super tidak mengeluarkan apa-apa langsung — jadi setiap ikatan Omarchy yang menggunakan Super akan berhenti begitu sahaja, dan ia kelihatan seperti Hyprland yang rosak.

Tekan `Fn + Super` sekali sebelum anda mengutak-atik `~/.config/hypr/`, dan jika itu tidak mengembalikan Super, tekan sekali lagi supaya anda tidak membiarkan kunci itu kekal aktif. Ini bukan Fn-lock, yang hanya mengubah fungsi baris kekunci F.

### Wi-Fi, Bluetooth, audio, atau pad jejak saya tiba-tiba berhenti berfungsi

Sebelum anda but semula, cuba mulakan semula subsistem yang bermasalah itu secara berasingan. _Update > Hardware_ dalam menu Omarchy mempunyai Wi-Fi, Bluetooth, Audio, dan Trackpad, dan memuat semula salah satu daripadanya menyelesaikan kebanyakan situasi "tadi elok sahaja lima minit lepas" — set kepala Bluetooth yang enggan menyambung semula, pad jejak yang mati selepas suspend, bunyi yang hilang apabila anda mencabut monitor.

### Mengapa pembesar suara luaran saya tidak berbunyi?

Mungkin kerana ia tidak ditetapkan sebagai output utama. Klik ikon pembesar suara di sebelah kanan bar, dan ia akan membuka pop timbul kelantangan di mana anda boleh memilih peranti output (dan mengadun kelantangan setiap aplikasi juga).

### Pembesar suara komputer riba saya berbunyi pelik

Pada sesetengah komputer riba, Omarchy secara automatik menggunakan penalaan pembesar suara yang membetulkan respons frekuensi pembesar suara terbina dalam. `omarchy audio tuning status` memberitahu anda sama ada penalaan itu aktif pada mesin anda, dan `omarchy audio tuning off` mematikannya jika anda lebih suka mendengar pembesar suara dalam keadaan asal.

### Mengapa saya tidak boleh log masuk atau sudo dengan kata laluan saya?

Anda mungkin telah menaipnya salah terlalu banyak kali dan telah dikunci keluar. Jika ini berlaku pada skrin kunci, anda boleh menekan `CTRL + ALT + F2` untuk memulakan TTY baharu di mana anda boleh log masuk sebagai root, kemudian jalankan `faillock --reset --user [your-username]`. Itu akan menetapkan semula kunci keluar tersebut, dan anda sudah boleh meneruskan.

### Kata laluan saya diterima, tetapi saya kembali ke skrin log masuk

Fail persekitaran sesi yang rosak boleh menghalang desktop daripada dimulakan walaupun kata laluan anda betul. Ini terutamanya patut diperiksa selepas mengedit `~/.config/uwsm/env.d/`.

Tekan `Ctrl + Alt + F2`, log masuk dengan nama pengguna dan kata laluan biasa anda, dan periksa jurnal pengguna untuk but semasa:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Cari ralat yang menamakan salah satu fail persekitaran anda, seperti `bad substitution`, tepat sebelum mesej bahawa tanda output env tidak ditemui. Alihkan fail itu keluar dari `env.d` sebelum cuba log masuk semula. Contohnya, jika ralat itu menamakan `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM melangkau fail yang mempunyai ralat sintaks, tetapi ralat maut yang hanya muncul semasa fail itu berjalan, seperti `bad substitution`, masih boleh menghalang desktop daripada dimulakan. Pemulihan snapshot sistem tidak membaiki fail-fail ini, kerana `/home` tidak dipulihkan.

Sebaik sahaja anda boleh log masuk, baiki salinan yang disimpan itu sebelum mengalihkannya kembali. `sh -n` menangkap ralat sintaks tanpa menjalankan fail, tetapi tidak dapat menangkap setiap ralat yang berlaku apabila fail itu diambil sebagai sumber. Kekalkan terminal yang berfungsi terbuka semasa menguji perubahan.

### Mengapa gesaan kebenaran 1Password saya untuk 1Password SSH Agent / CLI tidak muncul?

Ini boleh berlaku atas 2 sebab:

Agar gesaan kelulusan yang lengkap itu muncul, Settings > Advanced > Use Hardware Acceleration mesti dihidupkan. _Nota: Ini memerlukan but semula untuk mula berfungsi._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Atau jika anda belum melancarkan 1Password sejak but, gesaan itu tidak akan muncul.
