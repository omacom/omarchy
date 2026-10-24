# 通知表示

ホットキーによる通知表示で、日付と時刻、バッテリー状態、現在の天気に素早くアクセスできます。

### 日付と時刻

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### 天気

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

位置は IP アドレスから検出され、通常は十分に近いのですが、常にそうとは限りません。`omarchy weather location --set Malibu` で固定したり、座標を追加して正確にしたりできます：`omarchy weather location --set Malibu 34.0259,-118.7798`。`omarchy weather location` を単独で実行すると、どこにいると考えているか確認でき、`--clear` で自動検出に戻ります。

### バッテリー

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
