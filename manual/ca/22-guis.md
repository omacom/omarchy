# GUI

## Fitxers

Fitxers (Nautilus) és el gestor gràfic de fitxers. `Super + Shift + F` l'obre, i `Super + Shift + Alt + F` l'obre al directori on es troba el teu terminal, cosa que estalvia molts clics. `Ctrl + L` et permet escriure una ruta, i prement `Space` sobre qualsevol fitxer obtens una previsualització ràpida sense obrir res.

Connecta una memòria USB o una targeta SD i es munta automàticament, de manera que simplement apareix a la barra lateral. Per a qualsevol cosa més complexa — formatar una unitat, comprovar l'estat SMART, crear particions — llança _Discs_ des del llançador d'aplicacions (`Super + Space`).

El doble clic segueix opcions per defecte sensates: les imatges s'obren amb imv, el vídeo amb mpv, els PDF amb Document Viewer i el text pla amb Neovim.

## Disktree

Quan la unitat s'omple i no tens ni idea de què se l'està menjant, llança [Disktree](https://github.com/tobi/disktree) des del llançador d'aplicacions (`Super + Space`). Mostra un mapa en arbre gràfic del teu directori personal. Els blocs més grans ocupen més espai; ves per dins dels directoris amb el teclat o el ratolí, marca què ha de desaparèixer i revisa les seleccions abans d'eliminar res. Executa `disktree --disk` per escanejar tot el disc.

## Obsidian

[Obsidian](https://obsidian.md/) és una aplicació gratuïta i altament extensible per prendre notes que fa servir fitxers Markdown senzills per a l'emmagatzematge.

Obsidian és gratuït per a tots els usos, incloent-hi l'ús personal, comercial i sense ànim de lucre.

Obsidian també ofereix un [complement comercial de sincronització](https://obsidian.md/sync) amb aplicacions mòbils per a iOS i Android. (https://obsidian.md/pricing).

Inicies Obsidian amb `Super + Shift + O`. Per fer servir la sincronització de tema, has de seleccionar el tema `Omarchy` a la configuració.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) és la senzillíssima aplicació pròpia d'Omarchy per escriure en Markdown. Sense magatzems, sense connectors, només tu i les paraules.

Inicies Omawrite amb `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) és una eina bàsica d'edició d'imatges fantàstica per retallar, redimensionar i fer altres manipulacions bàsiques. Només que no t'esperis una alternativa a Photoshop. Però tot i així té vareta màgica i capes!

Inicies Pinta des del llançador d'aplicacions (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) és una aplicació de temes que pot extreure colors d'una imatge de fons i convertir-los en un tema complet i cohesionat. És la manera més fàcil de [fer el teu propi tema](43-making-your-own-theme.md).

Inicies Aether des del llançador d'aplicacions (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) et permet enviar fitxers a altres dispositius de la mateixa xarxa que executin l'aplicació, com l'AirDrop d'Apple. És multiplataforma, tanmateix, de manera que pots enviar fitxers cap a i des de Windows, macOS, Android, iOS i, és clar, Linux.

Pots obrir el menú de Compartir amb `Super + Ctrl + S` o a _Activa > Comparteix_ al menú d'Omarchy. Et dona quatre opcions:

- **Porta-retalls** envia el que hagis copiat com a fitxer de text. Genial per fer arribar un enllaç o un fragment al telèfon sense enviar-te un correu a tu mateix.
- **Fitxer** obre un selector de fitxers on en pots triar diversos alhora.
- **Carpeta** envia un directori sencer.
- **Rep** obre LocalSend pròpiament perquè un altre dispositiu et pugui enviar alguna cosa.

El mateix funciona des del terminal amb `omarchy share clipboard`, `omarchy share file [path]` i `omarchy share folder [path]`. Omet la ruta i obtindràs el selector.

També pots enviar directament des del gestor de fitxers: fes clic amb el botó dret sobre qualsevol selecció a Nautilus i tria _Envia mitjançant LocalSend_.

El tallafocs d'Omarchy està tancat per defecte excepte pel port de LocalSend, de manera que això funciona de sèrie en una instal·lació nova. Consulta [seguretat](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) és un paquet d'ofimàtica complet amb processador de textos, full de càlcul, presentacions, aplicació de dibuix i més coses. És compatible amb els fitxers de Microsoft Office, de manera que és una manera fantàstica de poder obrir aquells documents de Word.

Inicies LibreOffice des del llançador d'aplicacions (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) és la senzillíssima aplicació pròpia d'Omarchy per a presentacions. La teva presentació és un sol fitxer Markdown amb les imatges i els vídeos al costat: escriu cada diapositiva a sota d'una previsualització en directe, arrossega les diapositives per ordenar-les i després presenta a pantalla completa o exporta a PDF i PowerPoint. Fins i tot adopta el teu tema d'Omarchy.

Inicies Hype des del llançador d'aplicacions (`Super + Space`). Prem `?` a dins per veure totes les dreceres.

## Signed

[Signed](https://github.com/omacom/signed) és la senzillíssima manera pròpia d'Omarchy de signar PDF i emplenar-los. Posa la signatura que tinguis desada, text i la data d'avui on vulguis d'una pàgina i després desa una còpia signada al costat de l'original. Consulta [Emplenar PDF](27-filling-out-pdfs.md) per saber com.

Inicies Signed des del llançador d'aplicacions (`Super + Space`), o obres-hi un PDF des del gestor de fitxers.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) és la senzillíssima calculadora pròpia d'Omarchy, que s'obre en una finestra flotant.

Inicies Omacalc amb `Super + Ctrl + Q` (o la tecla de calculadora, si el teu teclat en té una).

## Signal

[Signal](https://signal.org/) és el pioner de la missatgeria xifrada d'extrem a extrem, i una gran opció de comunicació per a qualsevol que prefereixi no passar per un dels grans conglomerats tecnològics.

Inicies Signal amb `Super + Shift + G`. No forma part de la instal·lació base, de manera que la primera vegada que premis això, Omarchy t'oferirà instal·lar-lo (també és a _Instal·la > Servei_ al menú d'Omarchy).

## mpv

[mpv](https://mpv.io/) és un reproductor multimèdia senzill i ràpid que reproduirà gairebé qualsevol cosa de qualsevol font. Genial per mirar vídeos.

Inicies mpv des del llançador d'aplicacions (`Super + Space`) o simplement fent doble clic en un vídeo al gestor de fitxers.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) és el senzillíssim retallador de vídeo propi d'Omarchy. Quan tot el que necessites és retallar el començament i el final d'un clip, guanya per golejada a engegar un editor de vídeo complet.

Inicies Omacut des del llançador d'aplicacions (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) és el senzillíssim gravador de webcam propi d'Omarchy. Tria la càmera i el micròfon una vegada, després prem `Space` per gravar i un altre cop per posar en pausa i reprendre la mateixa presa. Sempre grava a la resolució màxima de la teva càmera, amb un mesurador de micròfon en directe perquè puguis comprovar els nivells abans de començar.

Atura la presa i s'obre de seguida en un editor integrat. Fes doble clic en un clip per dividir-lo, arrossega els tiradors per retallar cada tros i elimina les parts que no vols. Després desa'l com a MP4. La gravació original es conserva fins que la descartis, de manera que sempre hi pots tornar i retallar-la d'una altra manera.

Inicies Monologue des del llançador d'aplicacions (`Super + Space`).
