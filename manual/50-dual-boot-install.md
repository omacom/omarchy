# Dual Boot Install

You're able to install Omarchy to a single partition alongside Windows or other installations.

This installation method still comes with LUKS encryption for the partition by default so it's effectively no different than full drive and simply requires free space to be available on the disk.

## Making Space on Windows

To install alongside Windows, type `disk management` in the start menu and select the option for **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Find the appropriate partition, right click, and choose **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Input the amount you'd like to shrink the volume by. Note that this will be the size of your future Omarchy install inclusive of the boot partition.

 ![dual-boot-3](images/dual-boot-3.webp)

When you're finished, you should see something like this where the 50GB section is where we'll install Omarchy in this example.

 ![dual-boot-4](images/dual-boot-4.webp)

## Installing Omarchy

The install process for Omarchy is effectively the same as normal. After you select your disk, you'll be given the option of **Free space install**. Select that option to prevent wiping the full disk.

 ![dual-boot-5](images/dual-boot-5.webp)

Confirm that everything looks good and wait for the install to finish like normal. This is also where you could elect to install unencrypted (not recommended) just like on a full-drive install.
 ![dual-boot-6](images/dual-boot-6.webp)

## Adding Other Installs to the Bootloader

When you finish your Omarchy install, you'll notice that the Limine bootloader is the default now. With this, you can also add options to Limine for your other installs such as Windows.

To add other operating systems, run `limine-scan` and follow the prompts to add the entries you want to your Limine config. The boot menu stays hidden by default and starts Omarchy after one second. To choose Windows or another entry, press any key as soon as Limine starts; when the menu appears, use the arrow keys to select an entry and press Enter. If Omarchy starts before you press a key, restart and try again. If you turned on _Setup > Direct Boot_, the firmware skips Limine entirely, so pick Limine from your BIOS boot menu or run _Setup > Direct Boot_ again to remove the entry.

## Bitlocker

It's important to note that this install method is not compatible with Bitlocker as it encrypts the entire drive, not just the partition. If you encounter an error stating that Bitlocker is enabled, boot to Windows, go to **Settings -> Privacy & Security -> Device encryption** and toggle Bitlocker off. It may take some time to decrypt the drive.

 ![dual-boot-7](images/dual-boot-7.webp)
