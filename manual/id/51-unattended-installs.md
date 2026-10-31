# Instalasi Tanpa Pengawasan

ISO Omarchy dapat menginstal dirinya sendiri tanpa ada siapa pun di depan keyboard. Jika installer menemukan drive kedua berlabel `cidata` yang membawa berkas-berkas konfigurasinya, ia menyalin berkas-berkas itu, melewati wizard penyiapan sepenuhnya, dan me-reboot ke sistem yang sudah jadi dengan sendirinya. Tidak perlu build ISO khusus, tidak ada entri menu boot tambahan — tanpa drive semacam itu terpasang, tidak ada yang berubah dan Anda mendapatkan wizard normal.

Ini membuat Omarchy bagus sebagai image dasar untuk lingkungan dev sekali pakai: buat VM di Proxmox atau dengan Packer, boot, tinggalkan, lalu masuk lewat SSH. `cidata` adalah label cloud-init `NoCloud`, jadi semua perangkat virtualisasi yang umum sudah tahu cara memasang drive semacam itu.

## Berkas-berkas konfigurasi

Berkas-berkas ini persis seperti yang ditulis oleh wizard installer itu sendiri, jadi cara termudah untuk mendapatkan set awal adalah menjalankan satu instalasi interaktif (di VM, misalnya) dan menyalin apa yang ditulisnya ke `/root`:

| File | Required | Purpose |
|------|----------|---------|
| `user_configuration.json` | Ya | Disk, hostname, zona waktu, keyboard |
| `user_credentials.json` | Ya | Nama pengguna dan hash kata sandi |
| `user_encrypt_installation.txt` | Tidak | `true` ketika konfigurasi membawa blok `disk_encryption` |
| `authorized_keys` | Tidak | Kunci publik SSH, satu per baris |
| `tailscale_authkey` | Tidak | Kunci autentikasi Tailscale untuk bergabung ke tailnet Anda saat boot pertama |

Buat hash kata sandi untuk `user_credentials.json` dengan `openssl passwd -6 "yourpassword"`.

Nama dan email untuk commit git bukan bagian dari instalasi. Tetapkan setelah mesin hidup, lewat SSH misalnya, dengan `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Anda juga dapat menaruh berkas kosong bernama `defer-provisioning` sebagai pengganti `user_credentials.json`. Itu menjalankan [instalasi siapkan-untuk-pemilik-lain](02-getting-started.md) yang sama seperti yang dapat Anda picu secara interaktif: mesin terinstal tanpa detail pribadi apa pun, dan siapa pun yang pertama kali mem-boot-nya memilih keyboard mereka dan membuat pengguna mereka. Itulah mode untuk rig imaging, di mana drive sama sekali tidak boleh membawa kredensial siapa pun.

## Akses SSH

Ketika `authorized_keys` ada, instalasi menetapkan kunci-kunci tersebut sebagai `~/.ssh/authorized_keys` milik pengguna, mengaktifkan `sshd`, dan membuka firewall untuknya. (Instalasi Omarchy standar disertai openssh dengan layanan dinonaktifkan dan port tertutup, jadi mesin tanpa pengawasan sebaliknya tidak akan dapat dijangkau.) Instalasi hanya menambahkan kunci Anda — ia tidak melonggarkan pengaturan autentikasi lain apa pun dari daemon SSH.

Ketika `tailscale_authkey` ada, mesin justru bergabung ke tailnet Anda saat boot pertama: Tailscale diinstal dari paket-paket bawaan ISO, firewall mengizinkan antarmuka tailnet, dan sebuah job latar belakang menjalankan proses bergabung segera setelah mesin benar-benar memiliki jaringan, mencobanya lagi hingga berhasil. Gunakan kunci yang dapat digunakan kembali dan telah diotorisasi sebelumnya agar satu image drive dapat melayani banyak mesin.

## Membuat drive cidata

Sistem berkas apa pun dengan label yang tepat dapat digunakan. ISO kecil adalah cara yang mudah:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Lalu pasang ISO itu ke VM di samping ISO Omarchy. Berikut contoh lengkap Proxmox:

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

Urutan boot mencantumkan disk terlebih dahulu dengan sengaja: disk yang kosong beralih ke ISO pada boot pertama, dan sistem yang terinstal melakukan boot dari disk untuk seterusnya.

## Dua hal yang perlu diperhatikan

Instalasi tanpa pengawasan yang terenkripsi tidak sepenuhnya tanpa pengawasan — seseorang tetap harus mengetik frasa sandi LUKS saat boot pertama. Dan blok `disk_encryption` di `user_configuration.json` membawa frasa sandi tersebut dalam bentuk teks biasa, jadi perlakukan drive cidata yang dibuat dari instalasi terenkripsi sebagai rahasia, karena memang itulah sifatnya.
