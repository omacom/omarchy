# デュアルブートインストール

Windows や他のインストールと並べて、Omarchy を単一のパーティションにインストールできる。

このインストール方法でもデフォルトでパーティションに LUKS 暗号化が適用されるので、実質的にドライブ全体へのインストールと違いはない。ディスクに空き容量があればいいだけだ。

## Windows で空き容量を作る

Windows と並べてインストールするには、スタートメニューで `disk management` と入力し、**Create and format hard disk partitions** のオプションを選択する。

 ![dual-boot-1](images/dual-boot-1.webp)

適切なパーティションを見つけ、右クリックして **Shrink Volume** を選択する。

![dual-boot-2](images/dual-boot-2.webp)

 ボリュームを縮小したい量を入力する。これが、ブートパーティションを含めた、今後の Omarchy インストールのサイズになる点に注意すること。

 ![dual-boot-3](images/dual-boot-3.webp)

完了すると、このような表示になるはずだ。この例では、50GB のセクションが Omarchy をインストールする場所だ。

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy のインストール

Omarchy のインストール手順は、実質的に通常と同じだ。ディスクを選択すると、**Free space install** のオプションが表示される。ドライブ全体が消去されるのを防ぐため、そのオプションを選択すること。

 ![dual-boot-5](images/dual-boot-5.webp)

すべて問題ないことを確認し、通常どおりインストールが終わるまで待つ。ここでは、ドライブ全体へのインストールと同様に、暗号化なしでインストールすることも選択できる（推奨しない）。
 ![dual-boot-6](images/dual-boot-6.webp)

## 他のインストールをブートローダーに追加する

Omarchy のインストールが終わると、Limine ブートローダーがデフォルトになっていることに気づくだろう。これにより、Windows など他のインストールのためのオプションを Limine に追加することもできる。

他のオペレーティングシステムを追加するには、`limine-scan` を実行し、プロンプトに従って希望するエントリを Limine の設定に追加する。ブートメニューはデフォルトで非表示のままになり、1 秒後に Omarchy が起動する。Windows や他のエントリを選択するには、Limine が起動したらすぐに任意のキーを押す。メニューが表示されたら、矢印キーでエントリを選択し、Enter を押す。キーを押す前に Omarchy が起動してしまった場合は、再起動してやり直すこと。_Setup > Direct Boot_ をオンにしている場合、ファームウェアは Limine を完全にスキップするので、BIOS ブートメニューで Limine を選択するか、_Setup > Direct Boot_ を再度実行してエントリを削除すること。

## Bitlocker

このインストール方法は Bitlocker と互換性がない点に注意することが重要だ。Bitlocker はパーティションだけでなくドライブ全体を暗号化するためだ。Bitlocker が有効になっているというエラーが表示された場合は、Windows を起動し、**Settings -> Privacy & Security -> Device encryption** に移動して Bitlocker をオフに切り替えること。ドライブの暗号化解除には時間がかかる場合がある。

 ![dual-boot-7](images/dual-boot-7.webp)
