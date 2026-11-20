# Perguntas frequentes

### Como alterno entre disposições de teclado?

Edite o seu ficheiro `~/.config/hypr/input.lua` e adicione isto para alternar entre disposições com `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

A barra mostrará automaticamente a sua disposição de teclado atual assim que tiver várias disposições configuradas (e também pode clicar nela para alternar).

### Como altero o formato do relógio para 12 horas?

Clique com o botão direito do rato no relógio na barra para percorrer os formatos comuns, incluindo os de 12 horas. Também pode definir o formato diretamente:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Isto mostrará domingo 10:55 AM.

### Como altero o meu fuso horário?

Execute _Setup > Region > Timezone_ no menu do Omarchy e escolha um da lista. Se o fuso horário estiver correto mas o próprio relógio tiver um desvio, _Update > Time_ reinicia a sincronização da hora por si.

### Como altero o meu DNS, partilho o meu Wi-Fi ou verifico a velocidade da minha ligação?

Isso está tudo em [redes](35-networking.md).

### Como verifico a velocidade do meu disco?

_Trigger > Speed Test > Disk Speed Test_ mede a velocidade de leitura e escrita em tempo real no seu disco, ou `omarchy disk speedtest` a partir do terminal.

### Como adiciono uma impressora?

A impressão já está configurada e a funcionar de origem, e adiciona cada impressora manualmente a partir de _Print Settings_ no lançador de aplicações (`Super + Space`).

Escolha _Add_ e dê-lhe um momento para procurar: uma impressora ligada por USB, e a maioria das impressoras de rede, são encontradas por si. Se a sua não estiver na lista, escolha _Network Printer > Internet Printing Protocol (ipp)_ e introduza o respetivo endereço — o ecrã da própria impressora ou a sua página web indicar-lhe-á qual é, normalmente algo como `192.168.1.50` com uma fila de `ipp/print`. Em seguida, _Forward_ oferece um controlador, sendo que uma impressora moderna funciona melhor com o perfil sem controlador _IPP Everywhere_ e uma mais antiga quer o controlador do próprio modelo.

Clique com o botão direito do rato numa impressora e escolha _Set as Default_ para escolher qual é que as suas aplicações utilizam primeiro, e _Properties_ para definir o tamanho do papel, a frente e verso e a qualidade.

A descoberta automática, em que as impressoras na rede aparecem sem serem adicionadas, está temporariamente desativada enquanto está a ser reformulada, razão pela qual o primeiro passo acima é da sua responsabilidade em vez de automático. Imprimir para um ficheiro PDF funciona sem qualquer impressora.

### Como altero onde são guardadas as capturas de ecrã ou as gravações de ecrã?

As capturas de ecrã guardadas vão para `~/Pictures/Screenshots` por defeito. Para utilizar outra pasta, adicione isto a um ficheiro em `~/.config/uwsm/env.d/` (como `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Pode fazer o mesmo para as gravações de ecrã ao utilizar `OMARCHY_SCREENRECORD_DIR`.

O Omasnap cria a pasta das capturas de ecrã automaticamente. Crie a pasta das gravações de ecrã manualmente e depois reinicie o Omarchy para qualquer uma destas alterações ao ambiente entrar em vigor.

### Como ponho as colunas e a webcam do meu Apple Studio Display a funcionar?

Seria de pensar que tudo devia funcionar ao ligar simplesmente por USB C, mas infelizmente não é o caso. A solução que encontrei para pôr tudo a funcionar de forma fiável é utilizar [o cabo WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Depois, as colunas e a webcam funcionam que é uma maravilha.

Lembre-se de que tem controlo de brilho integrado no Omarchy para os ecrãs Apple (tanto o Studio como o XDR) ao utilizar os botões normais de brilho do teclado.

### Como me livro de todo o software extra?

Se não quer programas como o Obsidian ou o LibreOffice, ou qualquer outro material pré-instalado, pode removê-lo com muita facilidade.

Execute _Remove > Package_ para ver todos os pacotes instalados. Depois, pode selecionar qualquer pacote que queira remover com tab e começar a remover tudo o que selecionou com return.

E pode utilizar _Remove > Web App_ a partir do menu do Omarchy para remover qualquer uma das aplicações web pré-instaladas que não queira.

Ou execute _Remove > Preinstalls_ para varrer todos os extras pré-instalados — aplicações web, TUIs e aplicações opcionais — de uma só vez. As teclas de atalho que as lançavam desaparecem com elas, pelo que fica com uma página em branco de atalhos para preencher com os seus em `~/.config/hypr/bindings.lua`.

---

Para erros e coisas avariadas, consulte [a secção de resolução de problemas](45-troubleshooting.md).
