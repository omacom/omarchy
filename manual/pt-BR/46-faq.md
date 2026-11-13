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

A barra mostrará automaticamente seu layout de teclado atual assim que você tiver vários layouts configurados (e você também pode clicar nela para alternar).

### Como mudo o formato do relógio para 12 horas?

Clique com o botão direito no relógio na barra para alternar entre os formatos comuns, incluindo os de 12 horas. Você também pode definir o formato diretamente:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Isso exibirá domingo 10:55 AM.

### Como mudo meu fuso horário?

Execute _Update > Timezone_ no menu do Omarchy e escolha na lista. Se o fuso horário estiver certo, mas o próprio relógio tiver desviado, _Update > Time_ reinicia a sincronização de horário para você.

### Como mudo meu DNS, compartilho meu Wi-Fi ou verifico a velocidade da minha conexão?

Tudo isso fica em [rede](35-networking.md).

### Como verifico a velocidade do meu disco?

_Trigger > Speed Test > Disk Speed Test_ mede a velocidade de leitura e gravação ao vivo no seu drive, ou `omarchy disk speedtest` no terminal.

### Como adiciono uma impressora?

A impressão já vem configurada e funcionando de fábrica, e você adiciona cada impressora por conta própria em _Print Settings_ no lançador de aplicativos (`Super + Space`).

Escolha _Add_ e espere um momento enquanto ele procura: uma impressora conectada por USB, e a maioria das impressoras de rede, são encontradas para você. Se a sua não estiver na lista, escolha _Network Printer > Internet Printing Protocol (ipp)_ e insira o endereço dela — a própria tela da impressora ou sua página web dirá qual é, geralmente algo como `192.168.1.50` com uma fila de `ipp/print`. _Forward_ então oferece um driver, onde uma impressora moderna funciona melhor no perfil driverless _IPP Everywhere_ e uma mais antiga quer o driver do próprio modelo.

Clique com o botão direito em uma impressora e escolha _Set as Default_ para definir qual delas seus aplicativos procurarão primeiro, e _Properties_ para definir tamanho do papel, duplex e qualidade.

A descoberta automática, em que impressoras na rede aparecem sem serem adicionadas, está temporariamente desativada enquanto é reformulada, e é por isso que a primeira etapa acima é sua, e não automática. Imprimir para um arquivo PDF funciona sem nenhuma impressora.

### Como mudo onde capturas de tela ou gravações de tela são salvas?

Capturas de tela salvas vão para `~/Pictures/Screenshots` por padrão. Para usar outro diretório, adicione isto a um arquivo em `~/.config/uwsm/env.d/` (como `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Você pode fazer o mesmo para gravações de tela usando `OMARCHY_SCREENRECORD_DIR`.

Omasnap cria seu diretório de capturas de tela automaticamente. Crie você mesmo o diretório de gravações de tela e reinicie o Omarchy para que qualquer uma das alterações de ambiente entre em vigor.

### Como faço os alto-falantes + webcam funcionarem no meu Apple Studio Display?

Você pensaria que tudo deveria funcionar só conectando o USB C, mas infelizmente não é o caso. A solução que encontrei para fazer funcionar de forma confiável é usar [o cabo WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Aí os alto-falantes e a webcam funcionam perfeitamente.

Lembre-se de que você tem controle de brilho integrado no Omarchy para os Apple Displays (tanto Studio quanto XDR) usando os botões normais de brilho do teclado.

### Como me livro de todo o software extra?

Se você não quer programas como Obsidian ou LibreOffice ou qualquer outra coisa pré-instalada, pode removê-los com muita facilidade.

Execute _Remove > Package_ para ver todos os pacotes instalados. Depois, você pode selecionar qualquer pacote que queira remover com tab, e começar a remover tudo o que selecionou com return.

E você pode usar _Remove > Web App_ no menu do Omarchy para remover qualquer um dos web apps pré-instalados que você não queira.

Ou execute _Remove > Preinstalls_ para varrer todos os extras pré-instalados — web apps, TUIs e aplicativos opcionais — de uma só vez. As teclas de atalho que os abriam somem junto com eles, então você fica com um quadro limpo de atalhos para preencher com os seus em `~/.config/hypr/bindings.lua`.

---

Para erros e partes quebradas, veja [a seção de solução de problemas](45-troubleshooting.md).
