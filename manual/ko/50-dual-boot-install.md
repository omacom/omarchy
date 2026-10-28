# 듀얼 부팅 설치

Windows나 다른 설치 항목과 나란히 단일 파티션에 Omarchy를 설치할 수 있습니다.

이 설치 방법도 기본으로 파티션에 대한 LUKS 암호화를 함께 제공하므로 전체 드라이브와 사실상 다르지 않으며, 디스크에 빈 공간만 있으면 됩니다.

## Windows에서 공간 만들기

Windows와 나란히 설치하려면 시작 메뉴에 `disk management`를 입력하고 **하드 디스크 파티션 만들기 및 포맷** 옵션을 선택하세요.

 ![dual-boot-1](images/dual-boot-1.webp)

적절한 파티션을 찾아 마우스 오른쪽 버튼으로 클릭하고 **볼륨 축소**를 선택하세요.

![dual-boot-2](images/dual-boot-2.webp)

 볼륨을 얼마나 축소할지 입력하세요. 이는 부팅 파티션을 포함해 앞으로의 Omarchy 설치 크기가 된다는 점에 유의하세요.

 ![dual-boot-3](images/dual-boot-3.webp)

완료하면 이 예시에서 Omarchy를 설치할 50GB 섹션과 비슷한 모습이 보여야 합니다.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy 설치하기

Omarchy의 설치 과정은 사실상 평소와 같습니다. 디스크를 선택한 뒤에는 **여유 공간에 설치** 옵션이 주어집니다. 전체 디스크가 지워지는 것을 막으려면 그 옵션을 선택하세요.

 ![dual-boot-5](images/dual-boot-5.webp)

모든 것이 괜찮은지 확인하고 평소처럼 설치가 끝나기를 기다리세요. 이곳에서는 전체 드라이브 설치에서와 마찬가지로 암호화하지 않고 설치하기로 선택할 수도 있습니다(권장하지 않습니다).
 ![dual-boot-6](images/dual-boot-6.webp)

## 다른 설치 항목을 부트로더에 추가하기

Omarchy 설치를 마치면 이제 Limine 부트로더가 기본인 것을 알게 될 것입니다. 이를 이용해 Windows 같은 다른 설치 항목용 옵션을 Limine에 추가할 수도 있습니다.

그러려면 `limine-scan`을 실행하고 안내에 따라 원하는 항목을 limine 설정에 추가하세요. 그러면 부팅할 때 Omarchy용 일반 옵션뿐 아니라 Windows Boot Manager나 다른 항목도 보입니다.

## Bitlocker

이 설치 방법은 전체 드라이브를 암호화하는 Bitlocker와 호환되지 않는다는 점에 유의하는 것이 중요합니다. 파티션만 암호화하는 것이 아닙니다. Bitlocker가 활성화되어 있다는 오류를 만나면 Windows로 부팅하고 **설정 -> 개인정보 및 보안 -> 장치 암호화**로 이동해 Bitlocker를 끄세요. 드라이브를 복호화하는 데 시간이 다소 걸릴 수 있습니다.

 ![dual-boot-7](images/dual-boot-7.webp)
