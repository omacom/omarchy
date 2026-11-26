# Instalasi Tanpa Pengawasan

ISO Omarchy dapat menginstal dirinya sendiri tanpa siapa pun di depan keyboard. Jika installer menemukan drive kedua berlabel `cidata` yang membawa berkas-berkas konfigurasinya, installer akan menyalinnya, melewati wizard penyiapan sepenuhnya, dan melakukan reboot ke sistem yang sudah jadi dengan sendirinya. Tidak perlu build ISO khusus, tidak perlu entri menu boot tambahan — tanpa drive seperti itu terpasang, tidak ada yang berubah dan Anda mendapatkan wizard normal.

Ini membuat Omarchy hebat sebagai image dasar untuk lingkungan dev sekali pakai: buat VM di Proxmox atau dengan Packer, boot, tinggalkan, lalu masuk lewat SSH. `cidata` adalah label `NoCloud` dari cloud-init, jadi semua perangkat virtualisasi yang umum sudah tahu cara memasang drive seperti itu.

## Berkas-berkas konfigurasi

Berkas-berkas tersebut persis seperti yang ditulis oleh wizard milik installer sendiri, jadi cara termudah untuk mendapatkan set awal adalah menjalankan satu instalasi interaktif (di VM, misalnya) dan menyalin apa yang ditulisnya ke `/root`:

| File | Required | Purpose |
|------|----------|---------|
| `user_configuration.json` | Yes | Disk, hostname, zona waktu, keyboard |
| `user_credentials.json` | Yes | Nama pengguna dan hash kata sandi, serta frasa sandi LUKS untuk instalasi terenkripsi |
| `user_encrypt_installation.txt` | No | `true` ketika konfigurasi membawa blok `disk_encryption` |
| `authorized_keys` | No | Kunci publik SSH, satu per baris |
| `tailscale_authkey` | No | Kunci auth Tailscale untuk bergabung ke tailnet Anda pada boot pertama |

Buat hash kata sandi untuk `user_credentials.json` dengan `openssl passwd -6 "yourpassword"`.

Nama dan email untuk commit git bukan bagian dari instalasi. Atur setelah mesin menyala, lewat SSH misalnya, dengan `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Anda juga dapat menaruh berkas kosong bernama `defer-provisioning` sebagai pengganti `user_credentials.json`. Itu menjalankan [instalasi persiapan untuk pemilik lain](02-getting-started.md) yang sama seperti yang dapat Anda picu secara interaktif: mesin terinstal tanpa detail pribadi apa pun, dan siapa pun yang pertama kali mem-boot-nya memilih keyboard mereka dan membuat pengguna mereka. Itulah mode untuk rig imaging, di mana drive tidak boleh membawa kredensial siapa pun sama sekali.

## Akses SSH

Ketika `authorized_keys` ada, instalasi mengatur kunci-kunci tersebut sebagai `~/.ssh/authorized_keys` milik pengguna, mengaktifkan `sshd`, dan membuka firewall untuknya. (Instalasi Omarchy standar menyertakan openssh dengan layanan dinonaktifkan dan port ditutup, jadi mesin tanpa pengawasan sebaliknya tidak akan dapat dijangkau.) Instalasi hanya menambahkan kunci Anda — instalasi tidak melonggarkan pengaturan autentikasi lain dari daemon SSH.

Ketika `tailscale_authkey` ada, mesin justru bergabung ke tailnet Anda pada boot pertama: Tailscale diinstal dari paket-paket bawaan ISO, firewall mengizinkan antarmuka tailnet, dan sebuah job latar belakang menjalankan proses bergabung segera setelah mesin benar-benar memiliki jaringan, mencoba lagi hingga berhasil. Gunakan kunci yang dapat digunakan kembali dan sudah pra-otorisasi agar satu image drive dapat melayani banyak mesin.

## Membangun drive cidata

Filesystem apa pun dengan label yang tepat dapat digunakan. ISO kecil adalah cara yang mudah:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Kemudian pasang ke VM di samping ISO Omarchy. Berikut contoh lengkap Proxmox:

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

Urutan boot mencantumkan disk terlebih dahulu dengan sengaja: disk kosong akan beralih ke ISO pada boot pertama, dan sistem yang terinstal akan boot dari disk selamanya setelah itu.

## Dua peringatan

Instalasi terenkripsi tanpa pengawasan tidak sepenuhnya tanpa pengawasan — seseorang tetap harus mengetik frasa sandi LUKS pada boot pertama. Dan frasa sandi tersebut berada di level teratas `user_credentials.json` sebagai `encryption_password` — archinstall membacanya di sana, bukan dari blok `disk_encryption` di `user_configuration.json` — jadi perlakukan drive cidata yang dibangun dari instalasi terenkripsi sebagai rahasia sebagaimana mestinya.
