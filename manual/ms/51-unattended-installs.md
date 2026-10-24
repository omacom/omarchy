# Pemasangan Tanpa Pengawasan

ISO Omarchy boleh memasang dirinya sendiri tanpa sesiapa di papan kekunci. Jika pemasang menemui pemacu kedua berlabel `cidata` yang membawa fail konfigurasinya, ia menyalinnya, melangkau wizard persediaan sepenuhnya, dan but semula ke dalam sistem yang siap dengan sendirinya. Tiada binaan ISO khas, tiada entri menu but tambahan — tanpa pemacu sedemikian dipasang, tiada apa yang berubah dan anda mendapat wizard biasa.

Ini menjadikan Omarchy hebat sebagai imej asas untuk persekitaran dev boleh buang: cipta VM dalam Proxmox atau dengan Packer, butkannya, tinggalkan, SSH masuk. `cidata` ialah label `NoCloud` cloud-init, jadi semua alat virtualisasi biasa sudah tahu cara memasang pemacu sedemikian.

## Fail konfigurasi

Fail-fail ialah tepat apa yang ditulis oleh wizard pemasang itu sendiri, jadi cara paling mudah untuk mendapatkan set permulaan ialah menjalankan satu pemasangan interaktif (dalam VM, katakan) dan menyalin apa yang ditulisnya ke dalam `/root`:

| Fail | Diperlukan | Tujuan |
|------|----------|---------|
| `user_configuration.json` | Ya | Cakera, nama hos, zon masa, papan kekunci |
| `user_credentials.json` | Ya | Nama pengguna dan hash kata laluan |
| `user_full_name.txt` | Tidak | Nama penuh Git |
| `user_email_address.txt` | Tidak | Emel Git |
| `user_encrypt_installation.txt` | Tidak | `true` apabila konfigurasi membawa blok `disk_encryption` |
| `authorized_keys` | Tidak | Kekunci awam SSH, satu setiap baris |
| `tailscale_authkey` | Tidak | Kekunci auth Tailscale untuk menyertai tailnet anda semasa but pertama |

Jana hash kata laluan untuk `user_credentials.json` dengan `openssl passwd -6 "yourpassword"`.

Anda juga boleh meletakkan fail kosong bernama `defer-provisioning` menggantikan `user_credentials.json`. Itu menjalankan [pemasangan sediakan-untuk-pemilik-lain](02-getting-started.md) yang sama yang boleh anda cetuskan secara interaktif: mesin dipasang tanpa butiran peribadi, dan sesiapa yang membutnya dahulu memilih papan kekunci mereka dan mencipta pengguna mereka. Itulah mod untuk rig pengimejan, di mana pemacu tidak sepatutnya membawa kelayakan sesiapa pun.

## Akses SSH

Apabila `authorized_keys` hadir, pemasangan menyediakan kekunci sebagai `~/.ssh/authorized_keys` pengguna, membolehkan `sshd`, dan membuka tembok api untuknya. (Pemasangan Omarchy stok membekalkan openssh dengan perkhidmatan dilumpuhkan dan port ditutup, jadi mesin tanpa pengawasan sebaliknya tidak dapat dicapai.) Pemasangan hanya menambah kekunci anda — ia tidak melonggarkan mana-mana tetapan pengesahan lain daemon SSH.

Apabila `tailscale_authkey` hadir, mesin menyertai tailnet anda semasa but pertama sebaliknya: Tailscale dipasang dari pakej ikatan ISO, tembok api membenarkan antara muka tailnet, dan kerja latar belakang menjalankan penyertaan sebaik sahaja mesin benar-benar mempunyai rangkaian, mencuba semula sehingga berjaya. Gunakan kekunci boleh guna semula, yang dibenarkan terlebih dahulu supaya satu imej pemacu boleh melayani banyak mesin.

## Membina pemacu cidata

Mana-mana sistem fail dengan label yang betul berfungsi. ISO kecil ialah cara mudah:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Kemudian pasangkannya pada VM di samping ISO Omarchy. Berikut ialah contoh Proxmox penuh:

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

Susunan but menyenaraikan cakera dahulu dengan sengaja: cakera kosong jatuh ke ISO pada but pertama, dan sistem yang dipasang but dari cakera selepas itu.

## Dua amaran

Pemasangan tersulit tanpa pengawasan tidak sepenuhnya tanpa pengawasan — seseorang masih perlu menaip frasa laluan LUKS pada but pertama. Dan blok `disk_encryption` dalam `user_configuration.json` membawa frasa laluan itu dalam teks biasa, jadi layan pemacu cidata yang dibina dari pemasangan tersulit sebagai rahsia seperti yang sepatutnya.
