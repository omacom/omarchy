# 듀얼 부팅 설치

Windows나 다른 설치와 함께 단일 파티션에 Omarchy를 설치할 수 있습니다.

이 설치 방식 역시 기본적으로 해당 파티션에 LUKS 암호화를 적용하므로, 사실상 전체 드라이브 설치와 다를 바 없으며 디스크에 빈 공간만 있으면 됩니다.

## Windows에서 공간 만들기

Windows와 함께 설치하려면 시작 메뉴에서 `disk management`를 입력하고 **하드 디스크 파티션 만들기 및 포맷** 옵션을 선택하세요.

 ![dual-boot-1](images/dual-boot-1.webp)

적절한 파티션을 찾아 마우스 오른쪽 버튼으로 클릭한 뒤 **볼륨 축소**를 선택하세요.

![dual-boot-2](images/dual-boot-2.webp)

 볼륨을 축소할 크기를 입력하세요. 이 크기가 부팅 파티션을 포함한 향후 Omarchy 설치의 크기가 된다는 점에 유의하세요.

 ![dual-boot-3](images/dual-boot-3.webp)

완료하면 다음과 같은 화면이 표시되며, 이 예시에서는 50GB 구간에 Omarchy를 설치하게 됩니다.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy 설치하기

Omarchy 설치 과정은 사실상 일반적인 과정과 동일합니다. 디스크를 선택하면 **빈 공간에 설치** 옵션이 제공됩니다. 전체 디스크가 지워지는 것을 막으려면 해당 옵션을 선택하세요.

 ![dual-boot-5](images/dual-boot-5.webp)

모든 것이 제대로 되어 있는지 확인하고 평소와 같이 설치가 완료될 때까지 기다리세요. 이곳에서는 전체 드라이브 설치 때와 마찬가지로 암호화 없이 설치하도록 선택할 수도 있습니다(권장하지 않음).
 ![dual-boot-6](images/dual-boot-6.webp)

## 부트로더에 다른 설치 추가하기

Omarchy 설치를 마치고 나면 이제 Limine 부트로더가 기본값이 된 것을 확인할 수 있습니다. 이를 통해 Windows와 같은 다른 설치를 위한 옵션도 Limine에 추가할 수 있습니다.

다른 운영체제를 추가하려면 `limine-scan`을 실행하고 안내에 따라 원하는 항목을 Limine 구성에 추가하세요. 부팅 메뉴는 기본적으로 숨겨져 있으며 1초 뒤 Omarchy를 시작합니다. Windows나 다른 항목을 선택하려면 Limine이 시작되자마자 아무 키나 누르세요. 메뉴가 나타나면 방향 키를 사용해 항목을 선택하고 Enter를 누르세요. 키를 누르기 전에 Omarchy가 시작되면 다시 시작해서 재시도하세요.

## Bitlocker

이 설치 방식은 Bitlocker와 호환되지 않는다는 점에 유의해야 합니다. Bitlocker는 파티션만이 아니라 드라이브 전체를 암호화하기 때문입니다. Bitlocker가 활성화되어 있다는 오류가 발생하면 Windows로 부팅해 **설정 -> 개인정보 및 보안 -> 장치 암호화**로 이동한 뒤 Bitlocker를 끄세요. 드라이브를 해독하는 데 시간이 걸릴 수 있습니다.

 ![dual-boot-7](images/dual-boot-7.webp)

## Windows 다시 설치하기

이 컴퓨터가 Windows와 함께 출고되었다면 제품 키는 펌웨어에 저장되어 있습니다. `omarchy windows key`를 실행하면 이를 출력할 수 있어, 이 컴퓨터에 Windows를 다시 설치할 경우 Windows를 다시 정품 인증할 수 있습니다.
