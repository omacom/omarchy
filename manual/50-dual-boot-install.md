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

In order to do that, run `limine-scan` and follow the prompts to add whichever items you'd like to your limine config. Then when you boot, you'll see your normal options for Omarchy, as well as Windows Boot Manager or others.

## Bitlocker

It's important to note that this install method is not compatible with Bitlocker as it encrypts the entire drive, not just the partition. If you encounter an error stating that Bitlocker is enabled, boot to Windows, go to **Settings -> Privacy & Security -> Device encryption** and toggle Bitlocker off. It may take some time to decrypt the drive.

 ![dual-boot-7](images/dual-boot-7.webp)

## The Hardware Clock

Windows keeps the hardware clock (RTC) in local time; Linux expects it in UTC. After a Windows session, Omarchy can briefly come up with a clock that's ahead or behind by your UTC offset until NTP corrects it. That skew is more than cosmetic: once a snapshot is taken while the clock reads in the future — such as the one `omarchy update` takes before updating — the snapshots after it won't appear in the Limine boot menu until real time actually passes that timestamp, because the snapshot sync only treats snapshots newer than the last one it saved as new.

Pick one convention for the whole machine, then check the result with `timedatectl`:

### Keep the RTC in UTC (recommended)

Leave Linux as-is and make Windows read UTC instead of local time. From an administrator Command Prompt or PowerShell in Windows:

```
reg add "HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /t REG_DWORD /d 1 /f
```

Reboot into Windows and let it set the time again (**Settings -> Time & language -> Date & time -> Sync now**), then boot Omarchy and check that `timedatectl` shows the same `RTC time` as `Universal time`.

### Keep the RTC in local time

Alternatively, tell Linux to read the clock the way Windows writes it:

```
timedatectl set-local-rtc 1
```

Run it once `timedatectl` shows `System clock synchronized: yes`, since it writes the current time to the RTC; afterwards it shows `RTC in local TZ: yes`. This is the smaller change, but it's the less common convention for Linux and `timedatectl` itself warns about it (DST transitions need the clock reset). Either choice fixes the skew; mixing the two is what breaks snapshot menu entries.
