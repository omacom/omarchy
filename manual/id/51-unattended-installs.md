# Pemasangan Tanpa Pengawasan

ISO Omarchy bisa memasang dirinya sendiri tanpa ada siapa pun di keyboard. Jika pemasang menemukan drive kedua berlabel `cidata` yang membawa berkas konfigurasinya, ia menyalinnya, melewati wizard pengaturan sepenuhnya, dan melakukan reboot ke sistem yang selesai dengan sendirinya. Tidak ada build ISO khusus, tidak ada entri menu boot tambahan — tanpa drive seperti itu terpasang, tidak ada yang berubah dan kamu mendapatkan wizard normal.

Ini membuat Omarchy hebat sebagai citra dasar untuk lingkungan dev sekali pakai: buat VM di Proxmox atau dengan Packer, boot, tinggalkan, SSH masuk. `cidata` adalah label `NoCloud` cloud-init, jadi semua perkakas virtualisasi umum sudah tahu cara memasang drive seperti itu.

## Berkas konfigurasi

Berkas-berkas tersebut persis seperti yang ditulis wizard pemasang itu sendiri, jadi cara termudah untuk mendapatkan rangkaian awal adalah menjalankan satu pemasangan interaktif (di VM, misalnya) dan menyalin apa yang ditulisnya ke `/root`:

| Berkas | Wajib | Tujuan |
|------|----------|---------|
| `user_configuration.json` | Ya | Disk, hostname, zona waktu, keyboard |
| `user_credentials.json` | Ya | Nama pengguna dan hash kata sandi |
| `user_full_name.txt` | Tidak | Nama lengkap Git |
| `user_email_address.txt` | Tidak | Email Git |
| `user_encrypt_installation.txt` | Tidak | `true` saat konfigurasi memuat blok `disk_encryption` |
| `authorized_keys` | Tidak | Kunci publik SSH, satu per baris |
| `tailscale_authkey` | Tidak | Kunci auth Tailscale untuk bergabung dengan tailnet kamu pada boot pertama |

Hasilkan hash kata sandi untuk `user_credentials.json` dengan `openssl passwd -6 "yourpassword"`.

Kamu juga bisa meletakkan berkas kosong bernama `defer-provisioning` sebagai pengganti `user_credentials.json`. Itu menjalankan [pemasangan siapkan-untuk-pemilik-lain](02-getting-started.md) yang sama yang bisa kamu picu secara interaktif: mesin terpasang tanpa detail pribadi, dan siapa pun yang melakukan boot pertama memilih keyboard mereka dan membuat pengguna mereka. Itulah mode untuk rig pencitraan, di mana drive tidak boleh membawa kredensial siapa pun sama sekali.

## Akses SSH

Saat `authorized_keys` ada, pemasangan mengatur kunci sebagai `~/.ssh/authorized_keys` milik pengguna, mengaktifkan `sshd`, dan membuka firewall untuknya. (Pemasangan Omarchy standar dilengkapi openssh dengan layanan dinonaktifkan dan port ditutup, jadi mesin tanpa pengawasan sebaliknya tidak akan bisa dijangkau.) Pemasangan hanya menambahkan kuncimu — ia tidak melonggarkan pengaturan autentikasi daemon SSH lainnya.

Saat `tailscale_authkey` ada, mesin bergabung dengan tailnet kamu pada boot pertama sebagai gantinya: Tailscale dipasang dari paket yang dibundel ISO, firewall mengizinkan antarmuka tailnet, dan pekerjaan latar belakang menjalankan penggabungan begitu mesin benar-benar memiliki jaringan, mencoba lagi sampai berhasil. Gunakan kunci yang bisa digunakan ulang dan telah diotorisasi sebelumnya agar satu citra drive bisa melayani banyak mesin.

## Membangun drive cidata

Sistem berkas apa pun dengan label yang tepat berfungsi. ISO kecil adalah cara mudah:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Lalu pasang ke VM di samping ISO Omarchy. Ini adalah contoh Proxmox lengkap:

```bash
qm create 101 --name my-omarchy \
  --bios ovmf --machine q35 --cpu host --cores 4 --memory 8192 \
  --ostype l26 --scsihw virtio-scsi-single \
  --efidisk0 local-lvm:0,efitype=4m,pre-enrolled-keys=0 \
  --scsi0 local-lvm:40,discard=on,iothread=1 \
  --net0 virtio,bridge=vmbr0 --vga virtio --serial0 socket \
  --ide2 local:iso/omarchy.iso,media=cdrom \
  --ide3 local:iso/cidata.iso,media=cdrom \
  --boot order='scsi0;ide2'

qm start 101
```

Urutan boot mencantumkan disk terlebih dahulu dengan sengaja: disk kosong berlanjut ke ISO pada boot pertama, dan sistem terpasang boot dari disk untuk selamanya setelah itu.

## Dua peringatan

Pemasangan tanpa pengawasan terenkripsi tidak sepenuhnya tanpa pengawasan — seseorang masih harus mengetikkan frasa sandi LUKS pada boot pertama. Dan blok `disk_encryption` di `user_configuration.json` membawa frasa sandi itu dalam teks biasa, jadi perlakukan drive cidata yang dibangun dari pemasangan terenkripsi sebagai rahasia yang memang demikian.
