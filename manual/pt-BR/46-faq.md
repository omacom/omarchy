# FAQ

### Como alterno entre layouts de teclado?

Edite seu arquivo `~/.config/hypr/input.lua` e adicione isto para alternar entre layouts com `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

A barra mostrará automaticamente seu layout de teclado atual quando você tiver vários layouts configurados (e você também pode clicar nela para alternar).

### Como mudo o formato do relógio para 12 horas?

Clique com o botão direito no relógio na barra para alternar entre os formatos comuns, incluindo os de 12 horas. Você também pode definir o formato diretamente:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Isso exibirá Domingo 10:55 AM.

### Como mudo meu fuso horário?

Execute _Setup > Region > Timezone_ no menu do Omarchy e escolha a partir da lista. Se o fuso horário estiver correto, mas o próprio relógio estiver desregulado, _Update > Time_ reinicia a sincronização de horário para você.

### Como mudo meu DNS, compartilho meu Wi-Fi ou verifico a velocidade da minha conexão?

Tudo isso está em [redes](35-networking.md).

### Como verifico a velocidade do meu disco?

_Trigger > Speed Test > Disk Speed Test_ mede a velocidade de leitura e gravação em tempo real no seu disco, ou `omarchy disk speedtest` a partir do terminal.

### Como adiciono uma impressora?

A impressão já vem configurada e funcionando de fábrica, e você adiciona cada impressora por conta própria a partir de _Print Settings_ no launcher de aplicativos (`Super + Space`).

Escolha _Add_ e dê um momento para ela procurar: uma impressora conectada por USB, e a maioria das impressoras de rede, são encontradas para você. Se a sua não estiver na lista, escolha _Network Printer > Internet Printing Protocol (ipp)_ e insira o endereço dela — a própria tela da impressora ou a página web dela dirá qual é, geralmente algo como `192.168.1.50` com uma fila de `ipp/print`. _Forward_ então oferece um driver, onde uma impressora moderna funciona melhor no perfil sem driver _IPP Everywhere_ e uma mais antiga exige o driver do próprio modelo.

Clique com o botão direito em uma impressora e escolha _Set as Default_ para escolher qual delas seus aplicativos procurarão primeiro, e _Properties_ para definir tamanho do papel, duplex e qualidade.

A descoberta automática, onde as impressoras na rede aparecem sem serem adicionadas, está temporariamente desativada enquanto é retrabalhada, e é por isso que o primeiro passo acima é seu, e não automático. Imprimir para um arquivo PDF funciona sem impressora nenhuma.

### Como mudo onde as capturas de tela ou gravações de tela são salvas?

As capturas de tela salvas vão para `~/Pictures/Screenshots` por padrão. Para usar outro diretório, adicione isto a um arquivo em `~/.config/uwsm/env.d/` (como `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Você pode fazer o mesmo para gravações de tela usando `OMARCHY_SCREENRECORD_DIR`.

O Omasnap cria seu diretório de capturas de tela automaticamente. Crie você mesmo o diretório de gravações de tela e reinicie o Omarchy para qualquer uma das alterações de ambiente entrar em vigor.

### Como faço os alto-falantes + webcam funcionarem no meu Apple Studio Display?

Você pensaria que tudo deveria funcionar só de conectar o USB C, mas infelizmente não é o caso. A solução que encontrei para fazer funcionar de forma confiável é usar [o cabo WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Então os alto-falantes e a webcam funcionam perfeitamente.

Lembre-se de que você tem controle de brilho integrado no Omarchy para os Apple Displays (tanto o Studio quanto o XDR) usando os botões normais de brilho do teclado.

### Como me livro de todo o software extra?

Se você não quer programas como Obsidian ou LibreOffice ou qualquer outra coisa pré-instalada, pode removê-los com muita facilidade.

Execute _Remove > Package_ para ver todos os pacotes instalados. Então você pode selecionar qualquer pacote que queira remover com tab e começar a remover tudo o que selecionou com return.

E você pode usar _Remove > Web App_ no menu do Omarchy para remover qualquer um dos web apps pré-instalados que não queira.

Ou execute _Remove > Preinstalls_ para varrer todos os extras pré-instalados — web apps, TUIs e aplicativos opcionais — de uma só vez. As teclas de atalho que os lançavam desaparecem junto com eles, então você fica com um quadro limpo de atalhos para preencher com os seus em `~/.config/hypr/bindings.lua`.

---

Para erros e coisas quebradas, veja [a seção de Solução de problemas](45-troubleshooting.md).
