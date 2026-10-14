# Zana za Uendelezaji

## Vihariri Mbadala

Omarchy huja na [Neovim](https://neovim.io/) kama chaguomsingi, lakini kama ungependa kitu cha kawaida na kinachojulikana zaidi, unaweza kufungua Menyu ya Omarchy (`Super + Space`) na kuona chaguo zilizo chini ya _Sakinisha > Kihariri_. Tuna VSCode, Cursor, Zed, Sublime Text, Helix, Vim, na Emacs zilizoorodheshwa hapo. Kama hukipati unachokitafuta, angalia _Sakinisha > Kifurushi_, na uone kama hakipo katika kifurushi cha Arch (na kama hakipo, jaribu _Sakinisha > AUR_ kuangalia AUR).

Kihariri asili cha `vi` kinapatikana pia mara moja. Endesha `vi filename` kuhariri faili katika terminali.

Ulinganishaji wa mandhari hutolewa kwa `VSCode`, `Cursor`, `VSCodium`, na `Helix`.

Unaweza kuweka kihariri chaguomsingi cha mfumo mzima chini ya `Sanidi > Chaguomsingi > Kihariri`.

## Mazingira

Omarchy huunga mkono kusanidi mazingira mengi sana ya uendelezaji kupitia sehemu ya _Sakinisha > Maendeleo_ ya Menyu ya Omarchy (`Super + Space`). Bila shaka utakuta _Ruby on Rails_, lakini pia mazingira yote matatu makuu ya utekelezaji kwa JavaScript (Node.js, Bun, Deno), pamoja na mifumo maarufu ya PHP kama Laravel na Symfony. Ndiyo, na kuna Go, Rust, Python, Java, Elixir (pamoja na Phoenix), .NET, OCaml, Zig, Clojure, na Scala pia. Ni uteuzi mpana sana!

Mazingira mengi kati ya haya husimamiwa na [Mise](https://mise.jdx.dev/). Ni zana inayokuwezesha kusakinisha na kuendesha matoleo mengi ya lugha ya programu kwenye mashine ile ile. Ni kama rbenv au rvm kwa Ruby au virtualenv kwa Python, lakini inafanya kazi kwa mazingira mengi tofauti.

Kusakinisha, kwa mfano, Ruby, unaweza kuendesha `mise use -g ruby`, ambayo itasakinisha Ruby na kuiweka kama chaguomsingi ya kimataifa. Au, kama mradi wako una faili ya .ruby-version, unaweza kuendesha tu `mise i` katika mzizi wa mradi huo.

## Docker

[Docker](https://www.docker.com/) haihitaji utangulizi wowote. Inakuwezesha kuendesha vipachiko vilivyotengwa, na Omarchy husakinisha kila kinachohitajika kuiendesha vyema, ikiwa ni pamoja na Docker yenyewe na [Docker Compose](https://docs.docker.com/compose/).

Kwa chaguomsingi mtumiaji wako *hayuko* katika kikundi cha `docker`. Kikundi hicho kwa kweli ni mzizi bila nenosiri — chochote kilichomo kinaweza kuendesha `docker run -v /:/host` na kuiteka mashine — hivyo hati moja iliyopotoka au tegemezi inayoendeshwa kama wewe ingekuwa amri moja tu mbali na kuwa mzizi. Kwa hivyo katika mstari wa amri unaendesha Docker kwa `sudo` (`sudo docker ps`, `sudo docker compose up`), na zana za kielelezo zinazowasiliana na daemon — VM ya Windows — huomba idhini zinapohitaji. Kama unataka urahisi wa usanidi bila kikundi tena na unaelewa ubadilishanaji wake, iwashe kutoka **Sanidi > Usalama > Docker bila sudo** (au endesha `omarchy-setup-security-sudoless-docker`), ambayo inakuongeza kwenye kikundi cha `docker` baada ya onyo; kisha `docker` ya kawaida na kifupisho cha `d` vitafanya kazi bila `sudo` tena.

Unaweza kusanidi hifadhidata za kawaida kwa uendelezaji wa ndani katika Docker kwa kutumia _Sakinisha > Maendeleo > Docker DB_ katika menyu ya Omarchy.

## GitHub CLI

[The GitHub CLI](https://cli.github.com/) inakuwezesha kujithibitisha kwa akaunti yako ya GitHub na kunakili hazina za faragha kwa kuitumia. Imeunganishwa kama moja ya vipachiko vya mise vinavyopakia kwa uvivu, hivyo mara ya kwanza unapoendesha `gh`, inajisakinisha yenyewe. Ili kujithibitisha, endesha `gh auth login`. Kisha unaweza kuchukua hazina za faragha kwa kutumia `gh repo clone org/repo`.

Unaweza pia kufanya shughuli nyingi nyingine za GitHub kwa kutumia amri hii. Endesha tu `gh` kuona kila kinachowezekana.

Kuna kipachiko cha kusakinisha kwa uvivu cha `ghui` kwa kusimamia maombi yako ya kuvuta (pull requests) katika TUI pia. Na [lazygit](https://github.com/jesseduffield/lazygit) imekwisha sakinishwa, kama ungependa kuendesha git yenyewe kutoka TUI pia.
