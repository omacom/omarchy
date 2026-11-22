# Omarchy の動作環境…

### Apple Silicon Mac

Apple Silicon 向け Omarchy は M1、M2、M3 Mac で動作し、macOS の隣にインストールできる。Mac サポートの章の [Apple Silicon 向け Omarchy](44-mac-support.md#omarchy-for-apple-silicon) を参照してほしい。

### Mac で Omarchy を試す

[Omarchy を試す](https://github.com/omacom/try-omarchy) は、macOS 15 以降を搭載したすべての Apple Silicon Mac 上の仮想マシンで Omarchy を実行する。パーティションを作る必要も、macOS の隣にインストールする必要もない。

### VirtualBox

VirtualBox は人気の VM ランナーだ。[その中でも Omarchy を実行できる](https://github.com/omacom/omarchy/discussions/176)。ただし、パフォーマンスはおそらくあまり良くないだろう。

### Windows 11 上の VMware Workstation

Windows 向けのもう一つの人気 VM ランナーだ。[その中でも Omarchy のセットアップが行われている](https://github.com/omacom/omarchy/discussions/572)。

### Steam Deck

Steam Deck は Arch 上で動作する。つまり、Steam Deck で Omarchy を実行できるということだ。Altynbek Orumbayev が[完全なセットアップスクリプトとその方法の解説](https://github.com/aorumbayev/deckarchy)を公開している。最高じゃないか！

### NixOS

Omarchy は本質的には Arch + Hyprland だが、Henry Sipp が[そのセットアップのエッセンスを NixOS に移植した](https://github.com/henrysipp/omarchy-nix)。だから、Nix にハマっているなら、ここが良い出発点になる。最新の Omarchy の変更に追いついているかどうかは分からないが、それでもかなりクールだ！

### その他の環境！

デフォルトではない構成で Omarchy を動かそうとしているなら、[コミュニティ Discord](https://discord.gg/tXFUdasqhY) の #omarchy-on-other チャンネルに参加するといい。
