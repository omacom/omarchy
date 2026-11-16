# Vitendakazi vya Shell

Omarchy huja na seti ya vitendakazi vya shell kurahisisha kazi za kawaida na kufupisha miito ya vigezo iliyochanganyikiwa.

## Ukandamizaji

- `compress [file/dir]`: Unda kumbukumbu ya tar.gz kutoka faili/saraka.
- `decompress [file.tar.gz]`: Panua faili ya tar.gz.

## Hifadhi

- `iso2sd [image.iso]`: Unda hifadhi inayoweza kuwashwa kwenye kadi ya SD kwa kutumia faili ya iso inayorejelewa na kuchagua hifadhi kwa mwingiliano.
- `format-drive [device] [name]`: Umbiza diski nzima yenye kizigeu kimoja cha exFAT (ambacho hufanya kazi kwenye Windows na macOS pia). Endesha bila hoja kuona hifadhi zilizopo. Kuwa mwangalifu!

## Miundo ya uendelezaji

Miundo ya papo hapo ya vidirisha vingi ya uendelezaji kwa tmux:

- `tdl [ai]`: Unda Mpangilio wa Uendelezaji wa Tmux wenye kihariri chako, ajenti wa AI, na terminali. Tumia vifupisho vya ajenti, kama `tdl c` kwa opencode au `tdl cx` kwa Claude Code, au pitisha ajenti wa pili kuendesha zote mbili, kama `tdl c cx`.
- `tds`: Unda Mraba wa Uendelezaji wa Tmux wenye kihariri, ufuatiliaji wa tofauti (kupitia `hunk diff --watch`), terminali, na opencode.
- `tdlm [ai]`: Unda dirisha la `tdl` kwa kila saraka ndogo katika saraka ya sasa.
- `tsl [count] [command]`: Unda kundi la vidirisha vilivyowekwa vigae katika gridi, vyote vikiendesha amri ile ile (nzuri sana kwa ajenti wa AI).

Miundo ile ile inapatikana kwa Herdr kama `hdl`, `hds`, `hdlm`, na `hsl`.

## Miti ya kazi ya Git

- `ga [branch]`: Unda mti mpya wa kazi na tawi karibu na hazina ya sasa na uruke ndani yake.
- `gd`: Ondoa mti wa kazi wa sasa na tawi lake (huomba uthibitisho kwanza).

## Wafuatiliaji wa Rsync

- `rsw [source] [destination]`: Anzisha mfuatiliaji wa nyuma unaotumia rsync kutoka chanzo hadi mwisho kila kitu kinapobadilika. Mwisho unaweza kuwa mwenyeji wa mbali, kama `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: Orodhesha wafuatiliaji wote hai.
- `dsw`: Simamisha wafuatiliaji wote hai.

## Usambazaji wa Mlango wa SSH

Inafaa sana kwa kufanya uendelezaji wa wavuti wenye marupurupu ya muktadha salama wa localhost dhidi ya kisanduku cha mbali.

- `fip`: Sambaza mlango mmoja au zaidi kutoka mwenyeji wa mbali hadi localhost kupitia SSH.
- `dip`: Tenganisha mlango mmoja au zaidi uliosambazwa.
- `lip`: Orodhesha usambazaji wote hai wa milango ya SSH.

Tuseme unaanzisha seva ya uendelezaji kwenye mlango `3000` kwenye mashine inayofikiwa kama `nyc-dev`, kisha unaweza kuendesha `fip nyc-dev 3000` kusambaza mlango huo, hivyo `localhost:3000` kwa kweli hufikia `nyc-dev:3000`, lakini bila hitaji la vyeti vya SSL kuthibitisha muktadha salama unaohitajika kwa kujaribu soketi za wavuti au mambo kama hayo.

## Uunganishaji upya wa SSH

`ssh` yenyewe imefunikwa katika kitendakazi kinachosafisha terminali kama muunganiko ukifa huku tmux ya mbali, Herdr, au kihariri kimeidai, na kisha huunganisha tena kiotomatiki wakati kikao kinachoingiliana kinapodondoka (Ctrl-C husimamisha kitanzi cha kujaribu tena).
