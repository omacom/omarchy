# 알림

단축키 알림을 사용하면 날짜와 시간, 배터리 상태, 현재 날씨에 빠르게 접근할 수 있습니다.

### 날짜 및 시간

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### 날씨

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

위치는 IP 주소로부터 감지되며, 보통 충분히 가깝지만 항상 그런 것은 아닙니다. `omarchy weather location --set Malibu`로 고정하거나, 좌표를 추가해 정확하게 지정할 수 있습니다: `omarchy weather location --set Malibu 34.0259,-118.7798`. `omarchy weather location`을 단독으로 실행하면 현재 위치로 파악하고 있는 곳을 볼 수 있고, `--clear`를 사용하면 자동 감지로 돌아갑니다.

### 배터리

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
