import QtQuick
import QtQuick.Controls as Controls
import qs.Commons
import qs.Ui

Item {
  id: root
  required property var tracker
  property string mode: "projects"
  readonly property bool live: mode === "live"
  readonly property bool projectOverview: !live && tracker.project === "*"
  property color foreground: Color.foreground
  property string fontFamily: Style.font.family
  readonly property color dim: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.58)
  readonly property color fill: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.07)
  property var selected: null
  readonly property var detail: selected && tracker.detail && tracker.detail.id === selected.id ? tracker.detail : selected
  onTrackerChanged: { selected = null; if (detailsPopup) detailsPopup.close() }
  implicitHeight: Style.space(500)
  function count(n) { return n >= 1e9 ? (n / 1e9).toFixed(1) + "B" : n >= 1e6 ? (n / 1e6).toFixed(1) + "M" : n >= 1000 ? (n / 1000).toFixed(1) + "K" : String(n || 0) }
  function clock(ts, full) { return Qt.formatDateTime(new Date(ts * 1000), full ? "dd/MM HH:mm:ss" : "HH:mm:ss") }
  function kind(row) { return row.kind === "session" ? "Sessão · " + row.calls + " chamadas" : row.kind === "turn" ? "Turno · " + row.calls + " chamadas" : "Chamada" }
  function scrollBy(dy) { history.contentY = Math.max(0, Math.min(history.contentHeight - history.height, history.contentY + dy * 42)) }
  function inspect(row) { selected = row; tracker.loadDetails(row.id); detailsPopup.open() }

  component Label: Text {
    textFormat: Text.PlainText
    color: root.foreground
    font.family: root.fontFamily
    font.pixelSize: Style.font.bodySmall
    elide: Text.ElideRight
  }
  component Action: Button {
    foreground: root.foreground
    fontFamily: root.fontFamily
    fontSize: Style.font.caption
    bordered: true
    verticalPadding: Style.space(5)
  }
  component Filter: Dropdown {
    showLabel: false
    foreground: root.foreground
    fontFamily: root.fontFamily
    rowHeight: Style.space(28)
  }

  Column {
    id: dashboard
    anchors.fill: parent
    spacing: Style.space(8)
    Row {
      width: parent.width
      height: Style.space(25)
      spacing: 8
      Action { id: back; visible: !root.live && !root.projectOverview; text: "← Projetos"; onClicked: tracker.project = "*" }
      Label {
        width: parent.width - status.width - (back.visible ? back.width + 8 : 0) - 8
        anchors.verticalCenter: parent.verticalCenter
        text: root.live ? "Tempo real" : root.projectOverview ? "Projetos" : tracker.project.split("/").pop() || "Sem projeto"
        font.pixelSize: Style.font.heading
      }
      Label {
        id: status
        anchors.verticalCenter: parent.verticalCenter
        color: root.dim
        text: tracker.error ? "Falha ao atualizar" : tracker.busy ? "Atualizando…" : (tracker.paused && root.live ? "Pausado · " : "") + (tracker.snapshot.updatedAt ? root.clock(tracker.snapshot.updatedAt, false) : "")
      }
    }
    Row {
      id: filters
      width: parent.width
      spacing: Style.space(6)
      Filter {
        id: period
        visible: !root.live
        width: Style.space(90)
        value: tracker.period
        options: [{value: "day", label: "Hoje"}, {value: "week", label: "7 dias"}, {value: "month", label: "30 dias"}, {value: "total", label: "Tudo"}]
        onChanged: function(value) { tracker.period = value }
      }
      Filter {
        id: provider
        width: Style.space(140)
        value: tracker.provider
        options: [{value: "all", label: "Todos"}, {value: "codex", label: "Codex"}, {value: "claude", label: "Claude"}, {value: "grok", label: "Grok"}, {value: "hermes", label: "Hermes"}, {value: "opencode", label: "OpenCode"}, {value: "devin", label: "Devin"}, {value: "9router", label: "9Router"}]
        onChanged: function(value) { tracker.provider = value }
      }
      Controls.TextField {
        width: Math.max(80, filters.width - provider.width - refresh.width - (root.live ? pause.width : period.width) - filters.spacing * 3)
        height: Style.space(28)
        color: root.foreground
        placeholderTextColor: root.dim
        placeholderText: "Buscar projeto, modelo ou sessão"
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
        background: Rectangle { color: root.fill }
        text: tracker.search
        onTextEdited: tracker.search = text
      }
      Action { id: pause; visible: root.live; text: tracker.paused ? "Retomar" : "Pausar"; onClicked: tracker.paused = !tracker.paused }
      Action { id: refresh; text: "↻"; enabled: !tracker.busy; onClicked: tracker.refresh() }
    }
    Label {
      width: parent.width
      color: root.dim
      text: tracker.error || (tracker.snapshot.errors.length ? tracker.snapshot.errors.join(" · ") : root.projectOverview ? root.count(tracker.snapshot.tokens) + " tokens · " + tracker.snapshot.projects.length + " projetos" : tracker.snapshot.records + " registros" + (root.live ? " hoje · a cada 5 s" : " · " + root.count(tracker.snapshot.tokens) + " tokens"))
    }
    Row {
      id: headings
      width: parent.width
      height: Style.space(16)
      visible: !root.projectOverview
      Label { width: Style.space(65); text: "Hora"; color: root.dim }
      Label { width: headings.width * 0.18; text: "Projeto / agente"; color: root.dim }
      Label { width: headings.width * 0.19; text: "Modelo"; color: root.dim }
      Label { width: headings.width * 0.63 - Style.space(145); text: "Mensagem"; color: root.dim }
      Label { width: Style.space(65); text: "Tokens"; color: root.dim; horizontalAlignment: Text.AlignRight }
    }
    ListView {
      id: history
      width: parent.width
      height: Math.max(100, dashboard.height - y - footer.height - dashboard.spacing)
      clip: true
      spacing: Style.space(2)
      model: root.projectOverview ? tracker.snapshot.projects : tracker.snapshot.rows
      Controls.ScrollBar.vertical: Controls.ScrollBar {}
      onModelChanged: if (root.live && tracker.offset === 0 && !root.selected) positionViewAtBeginning()
      delegate: Rectangle {
        required property var modelData
        width: history.width
        height: Style.space(43)
        color: hover.containsMouse ? Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.12) : root.fill
        Row {
          visible: !root.projectOverview
          anchors.fill: parent
          anchors.topMargin: Style.space(5)
          Label { width: Style.space(65); text: root.clock(modelData.timestamp || 0, false); font.pixelSize: Style.font.caption }
          Column {
            width: history.width * 0.18
            spacing: 3
            Label { width: parent.width - 8; text: modelData.projectName || "" }
            Label { width: parent.width - 8; text: modelData.caller || ""; color: root.dim; font.pixelSize: Style.font.caption }
          }
          Column {
            width: history.width * 0.19
            spacing: 3
            Label { width: parent.width - 8; text: modelData.model || "" }
            Label { width: parent.width - 8; text: modelData.kind ? root.kind(modelData) : ""; color: root.dim; font.pixelSize: Style.font.caption }
          }
          Label {
            width: history.width * 0.63 - Style.space(145)
            height: Style.space(34)
            rightPadding: 10
            wrapMode: Text.Wrap
            maximumLineCount: 2
            text: modelData.preview || "Prévia não disponível"
            color: modelData.preview ? root.foreground : root.dim
          }
          Label { width: Style.space(65); text: root.count((modelData.input || 0) + (modelData.output || 0) + (modelData.cacheRead || 0) + (modelData.cacheWrite || 0)); horizontalAlignment: Text.AlignRight }
          Label { width: Style.space(15); text: "›"; color: root.dim; horizontalAlignment: Text.AlignRight }
        }
        Row {
          visible: root.projectOverview
          anchors.fill: parent
          anchors.margins: Style.space(6)
          Column {
            width: parent.width * 0.58
            spacing: 3
            Label { width: parent.width - 10; text: modelData.name || "" }
            Label { width: parent.width - 10; text: modelData.id || "Diretório não informado"; color: root.dim; font.pixelSize: Style.font.caption }
          }
          Label { width: parent.width * 0.20; text: root.count(modelData.calls) + " chamadas"; color: root.dim }
          Label { width: parent.width * 0.20; text: root.count(modelData.tokens) + " tokens"; horizontalAlignment: Text.AlignRight }
          Label { width: parent.width * 0.02; text: "›"; horizontalAlignment: Text.AlignRight }
        }
        MouseArea {
          id: hover
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            if (root.projectOverview) { tracker.project = modelData.id; history.positionViewAtBeginning() }
            else root.inspect(modelData)
          }
        }
      }
      Label { anchors.centerIn: parent; visible: history.count === 0; text: tracker.busy ? "Lendo registros…" : "Nenhum registro com estes filtros"; color: root.dim }
    }
    Row {
      id: footer
      width: parent.width
      spacing: Style.space(8)
      Label {
        width: parent.width - (root.projectOverview ? 0 : previous.width + next.width + page.width + parent.spacing * 3)
        anchors.verticalCenter: parent.verticalCenter
        text: tracker.provider === "9router" ? "9Router · separado do total" : "Clique em " + (root.projectOverview ? "um projeto" : "uma linha para ver os detalhes")
        color: root.dim
        font.pixelSize: Style.font.caption
      }
      Label { id: page; visible: !root.projectOverview; anchors.verticalCenter: parent.verticalCenter; text: tracker.snapshot.records ? (tracker.snapshot.offset + 1) + "–" + Math.min(tracker.snapshot.offset + 25, tracker.snapshot.records) + " / " + tracker.snapshot.records : "0"; color: root.dim }
      Action { id: previous; visible: !root.projectOverview; text: "←"; enabled: tracker.offset > 0; onClicked: { tracker.offset = Math.max(0, tracker.offset - 25); history.positionViewAtBeginning() } }
      Action { id: next; visible: !root.projectOverview; text: "→"; enabled: tracker.offset + 25 < tracker.snapshot.records; onClicked: { tracker.offset += 25; history.positionViewAtBeginning() } }
    }
  }

  Controls.Popup {
    id: detailsPopup
    width: Math.min(root.width - Style.space(24), Style.space(700))
    height: Math.min(root.height - Style.space(12), Style.space(460))
    x: (root.width - width) / 2
    y: (root.height - height) / 2
    padding: Style.space(14)
    modal: true
    focus: true
    closePolicy: Controls.Popup.CloseOnEscape | Controls.Popup.CloseOnPressOutside
    onClosed: root.selected = null
    background: Rectangle { color: Color.popups.background; border.width: 1; border.color: root.dim }
    Controls.Overlay.modal: Rectangle { color: "#99000000" }
    contentItem: Column {
      spacing: Style.space(10)
      Row {
        width: parent.width
        Label { width: parent.width - close.width; text: root.detail ? root.kind(root.detail) + " · " + root.clock(root.detail.timestamp, true) : "Detalhes"; font.pixelSize: Style.font.title }
        Action { id: close; text: "Fechar ×"; onClicked: detailsPopup.close() }
      }
      Controls.ScrollView {
        width: parent.width
        height: parent.height - y
        clip: true
        contentWidth: availableWidth
        Column {
          width: parent.width
          spacing: Style.space(9)
          Grid {
            id: metadata
            width: parent.width
            columns: 2
            spacing: Style.space(8)
            Repeater {
              model: !root.detail ? [] : [
                {label: "Projeto", value: root.detail.projectName},
                {label: "Agente", value: root.detail.caller},
                {label: "Modelo", value: root.detail.model},
                {label: "Entrada / saída", value: root.count(root.detail.input) + " / " + root.count(root.detail.output)},
                {label: "Cache lido / criado", value: root.count(root.detail.cacheRead) + " / " + root.count(root.detail.cacheWrite)},
                {label: "Estado / duração", value: root.detail.status + (root.detail.duration ? " · " + (root.detail.duration / 1000).toFixed(1) + " s" : "")}
              ]
              Column {
                required property var modelData
                width: (metadata.width - metadata.spacing) / 2
                spacing: 3
                Label { width: parent.width; text: modelData.label; color: root.dim; font.pixelSize: Style.font.caption }
                Label { width: parent.width; text: modelData.value; wrapMode: Text.WrapAnywhere; elide: Text.ElideNone }
              }
            }
          }
          Label { width: parent.width; text: root.detail ? (root.detail.cwd || "Diretório não informado") + "\n" + (root.detail.projectOrigin || "") : ""; wrapMode: Text.WrapAnywhere; elide: Text.ElideNone; color: root.dim }
          Label { text: root.detail ? root.detail.previewLabel || "Prévia da mensagem" : "Prévia da mensagem"; font.pixelSize: Style.font.title }
          Rectangle {
            width: parent.width
            height: preview.implicitHeight + Style.space(18)
            color: root.fill
            Label {
              id: preview
              x: Style.space(9); y: Style.space(9); width: parent.width - Style.space(18)
              text: tracker.detailBusy ? "Carregando mensagem…" : root.detail && root.detail.preview ? root.detail.preview : "A fonte não disponibilizou a mensagem deste registro."
              wrapMode: Text.Wrap
              elide: Text.ElideNone
            }
          }
          Label { width: parent.width; text: root.detail ? "Sessão: " + root.detail.session + "\nRegistro: " + root.detail.id : ""; wrapMode: Text.WrapAnywhere; elide: Text.ElideNone; color: root.dim; font.pixelSize: Style.font.caption }
        }
      }
    }
  }
}
