# Pemasangan Tanpa Pengawasan

ISO Omarchy boleh memasang dirinya sendiri tanpa sesiapa di papan kekunci. Jika pemasang menemui pemacu kedua berlabel `cidata` yang membawa fail konfigurasinya, ia menyalin fail tersebut keluar, melangkau wizard persediaan sepenuhnya, dan but semula ke dalam sistem yang siap dengan sendirinya. Tiada binaan ISO khas, tiada entri menu but tambahan — tanpa pemacu sedemikian dipasang, tiada apa-apa berubah dan anda mendapat wizard biasa.

Ini menjadikan Omarchy hebat sebagai imej asas untuk persekitaran pembangunan pakai buang: cipta VM dalam Proxmox atau dengan Packer, butkannya, tinggalkan, dan SSH masuk. `cidata` ialah label cloud-init `NoCloud`, jadi semua alat virtualisasi yang biasa sudah tahu cara memasang pemacu sedemikian.

## Fail konfigurasi

Fail-fail ini tepat seperti yang ditulis oleh wizard pemasang itu sendiri, jadi cara paling mudah untuk mendapatkan set permulaan ialah menjalankan satu pemasangan interaktif (dalam VM, misalnya) dan menyalin apa yang ditulisnya ke dalam `/root`:

| File | Required | Purpose |
|------|----------|---------|
| `user_configuration.json` | Ya | Cakera, nama hos, zon masa, papan kekunci |
| `user_credentials.json` | Ya | Nama pengguna dan cincang kata laluan |
| `user_encrypt_installation.txt` | Tidak | `true` apabila konfigurasi membawa blok `disk_encryption` |
| `authorized_keys` | Tidak | Kunci awam SSH, satu setiap baris |
| `tailscale_authkey` | Tidak | Kunci auth Tailscale untuk menyertai tailnet anda pada but pertama |

Jana cincang kata laluan untuk `user_credentials.json` dengan `openssl passwd -6 "yourpassword"`.

Nama dan e-mel untuk commit git bukan sebahagian daripada pemasangan. Tetapkannya sebaik sahaja mesin beroperasi, melalui SSH misalnya, dengan `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Anda juga boleh meletakkan fail kosong bernama `defer-provisioning` sebagai ganti `user_credentials.json`. Itu menjalankan [pemasangan sedia-untuk-pemilik-lain](02-getting-started.md) yang sama seperti yang boleh anda cetuskan secara interaktif: mesin dipasang tanpa butiran peribadi, dan sesiapa yang membutnya dahulu memilih papan kekunci mereka dan mencipta pengguna mereka. Itulah mod untuk rig pengimejan, di mana pemacu tidak sepatutnya membawa kelayakan sesiapa pun langsung.

## Akses SSH

Apabila `authorized_keys` wujud, pemasangan menyediakan kunci tersebut sebagai `~/.ssh/authorized_keys` milik pengguna, mendayakan `sshd`, dan membuka tembok api untuknya. (Pemasangan Omarchy stok disertakan dengan openssh dengan perkhidmatan dinyahdayakan dan port ditutup, jadi mesin tanpa pengawasan sebaliknya tidak dapat dicapai.) Pemasangan hanya menambah kunci anda — ia tidak melonggarkan mana-mana tetapan pengesahan daemon SSH yang lain.

Apabila `tailscale_authkey` wujud, mesin sebaliknya menyertai tailnet anda pada but pertama: Tailscale dipasang daripada pakej terhimpun ISO, tembok api membenarkan antara muka tailnet, dan kerja latar belakang menjalankan penyertaan sebaik sahaja mesin benar-benar mempunyai rangkaian, mencuba semula sehingga berjaya. Gunakan kunci boleh guna semula yang telah diprabenarkan supaya satu imej pemacu boleh digunakan untuk banyak mesin.

## Membina pemacu cidata

Mana-mana sistem fail dengan label yang betul akan berfungsi. ISO kecil ialah cara yang mudah:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Kemudian pasangkannya pada VM bersama ISO Omarchy. Berikut ialah contoh Proxmox yang lengkap:

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

Susunan but menyenaraikan cakera dahulu dengan sengaja: cakera kosong akan beralih kepada ISO pada but pertama, dan sistem yang dipasang akan but daripada cakera selama-lamanya selepas itu.

## Dua peringatan

Pemasangan tanpa pengawasan yang disulitkan tidak sepenuhnya tanpa pengawasan — seseorang masih perlu menaip frasa laluan LUKS pada but pertama. Dan blok `disk_encryption` dalam `user_configuration.json` membawa frasa laluan itu dalam teks biasa, jadi layan pemacu cidata yang dibina daripada pemasangan tersulit sebagai rahsia sebagaimana ia sebenarnya.
