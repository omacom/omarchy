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

Isso exibirá Sunday 10:55 AM.

### Como mudo meu fuso horário?

Execute _Atualizar > Fuso horário_ no menu do Omarchy e escolha na lista. Se o fuso horário estiver certo, mas o próprio relógio tiver desregulado, _Atualizar > Hora_ reinicia a sincronização de hora para você.

### Como mudo meu DNS, compartilho meu Wi-Fi ou verifico a velocidade da minha conexão?

Tudo isso está em [rede](35-networking.md).

### Como verifico a velocidade do meu disco?

_Acionar > Teste de velocidade > Teste de velocidade do disco_ mede a velocidade de leitura e escrita ao vivo no seu disco, ou `omarchy disk speedtest` no terminal.

### Por que não consigo entrar na minha conta Google no Chromium?

A compilação de código aberto pura do Chromium não traz as credenciais OAuth que o Google exige para o login na conta. Execute _Instalar > Serviço > Conta Chromium_ no menu do Omarchy para adicioná-las, reinicie o navegador, e o login vai funcionar.

### Como adiciono uma impressora?

A impressão já vem configurada e funcionando, e você adiciona cada impressora você mesmo em _Configurações de impressão_ no lançador de aplicativos (`Super + Space`).

Escolha _Adicionar_ e dê um momento para ele procurar: uma impressora conectada via USB, e a maioria das impressoras de rede, são encontradas para você. Se a sua não estiver na lista, escolha _Impressora de rede > Internet Printing Protocol (ipp)_ e digite o endereço dela — a própria tela da impressora ou sua página web dirá qual é, geralmente algo como `192.168.1.50` com uma fila `ipp/print`. _Avançar_ então oferece um driver, onde uma impressora moderna funciona melhor com o perfil sem driver _IPP Everywhere_ e uma mais antiga quer o driver do próprio modelo.

Clique com o botão direito em uma impressora e escolha _Definir como padrão_ para escolher qual seus aplicativos usarão primeiro, e _Propriedades_ para definir o tamanho do papel, duplex e qualidade.

A descoberta automática, em que as impressoras na rede aparecem sem serem adicionadas, está temporariamente desativada enquanto é reformulada, e é por isso que o primeiro passo acima é seu, e não automático. Imprimir para um arquivo PDF funciona sem nenhuma impressora.

### Como mudo onde as capturas de tela ou gravações de tela são salvas?

As capturas de tela salvas vão para `~/Pictures/Screenshots` por padrão. Para usar outro diretório, adicione isto a um arquivo em `~/.config/uwsm/env.d/` (como `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Você pode fazer o mesmo para gravações de tela usando `OMARCHY_SCREENRECORD_DIR`.

O Omasnap cria seu diretório de capturas de tela automaticamente. Crie o diretório de gravações de tela você mesmo e depois reinicie o Omarchy para que qualquer uma das alterações de ambiente entre em vigor.

### Como faço as caixas de som + a webcam do meu Apple Studio Display funcionarem?

Você pensaria que tudo deveria funcionar só de plugar o USB C, mas infelizmente não é o caso. A solução que encontrei para fazer funcionar de forma confiável é usar [o cabo WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Aí as caixas de som e a webcam funcionam perfeitamente.

Lembre-se de que você tem controle de brilho embutido no Omarchy para os Apple Displays (Studio e XDR) usando os botões normais de brilho do teclado.

### Como me livro de todo o software extra?

Se você não quer programas como Obsidian ou LibreOffice ou qualquer outra coisa pré-instalada, pode removê-los muito facilmente.

Execute _Remover > Pacote_ para ver todos os pacotes instalados. Aí você pode selecionar qualquer pacote que quer remover com tab e começar a remover tudo o que selecionou com return.

E você pode usar _Remover > Aplicativo web_ no menu do Omarchy para remover qualquer um dos aplicativos web pré-instalados que não quer.

Ou execute _Remover > Pré-instalados_ para varrer todos os extras pré-instalados — aplicativos web, TUIs e aplicativos opcionais — de uma vez só. As teclas de atalho que os abriam vão embora com eles, então você fica com um conjunto limpo de atalhos para preencher com os seus em `~/.config/hypr/bindings.lua`.

---

Para erros e partes quebradas, veja [a seção de solução de problemas](45-troubleshooting.md).
