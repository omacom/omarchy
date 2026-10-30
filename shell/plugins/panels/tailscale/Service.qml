import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import "Model.js" as Model

Item {
  id: root

  signal authUrlOpened()

  property var settings: ({})

  property bool installed: false
  property bool running: false
  property bool needsLogin: false

  // Optimistic off state so the UI reacts the instant you click, rather than
  // waiting for the next status refresh. _desired is -1 while we just follow
  // the real state, or 0/1 while a toggle is still catching up.
  property int _desired: -1
  readonly property bool active: _desired === -1 ? running : (_desired === 1)
  readonly property bool connecting: _desired === 1 && !running && !needsLogin
  property bool refreshing: false
  property string backendState: "Unknown"
  // statusText answers the IPC status() call, so it stays English.
  property string statusText: "Checking…"  // i18n: ignore
  property string selfName: ""
  property string selfDnsName: ""
  property string selfIp: ""
  property string selfUserId: ""
  property bool fileSharing: false
  property string authUrl: ""
  property var peers: []
  property var exitNodes: []
  property var tailnetExitNodes: []
  property var mullvadExitNodes: []
  property var mullvadRegions: []
  property var accounts: []
  property string selectedAccountId: ""
  property string selectedAccountLabel: ""
  property string switchingAccountId: ""
  property string settingExitNodeId: ""
  property bool accountsAccessDenied: false
  property string actionStatus: ""
  property string lastError: ""

  readonly property int refreshIntervalSec: intSetting("refreshIntervalSec", 30, 5, 3600)
  readonly property bool busy: whichProcess.running || statusProcess.running || mullvadExitNodesProcess.running || accountsProcess.running || actionProcess.running || loginProcess.running || switchProcess.running || operatorProcess.running || exitNodeProcess.running
  readonly property string userName: Quickshell.env("USER") || Quickshell.env("LOGNAME")

  property string _statusOutput: ""
  property string _statusError: ""
  property string _accountsOutput: ""
  property string _accountsError: ""
  property string _mullvadExitNodesOutput: ""
  property string _mullvadExitNodesError: ""
  property string _actionOutput: ""
  property string _actionError: ""
  property string _loginOutput: ""
  property string _loginError: ""
  readonly property bool waitingForLogin: _loginInProgress
  property bool _loginTimedOut: false
  property bool _loginSuperseded: false
  property bool _loginInProgress: false
  property bool _loginUrlOpened: false
  // A resume that may yet reveal an expired key. A cached netmap can report
  // Running for about a second before NeedsLogin, which settles _desired, so
  // this intent lasts until the connect deadline, a login or a disconnect.
  property bool _resumePending: false
  property int _stateWatchBackoffMs: 2000
  property string _preLoginAuthUrl: ""
  property double _lastAccountsRefreshMs: 0
  property string _switchOutput: ""
  property string _switchError: ""
  property string _exitNodeOutput: ""
  property string _exitNodeError: ""
  property string _operatorOutput: ""
  property string _operatorError: ""
  // Change signatures for the big arrays. A 4k-machine tailnet makes every
  // status poll rebuild thousands of delegate rows if the arrays are
  // reassigned unconditionally, so only publish an array whose content
  // actually changed.
  property string _peersSig: "[]"
  property string _tailnetExitNodesSig: "[]"
  property string _exitNodesSig: "[]"
  property string _mullvadRegionsSig: "[]"

  // The full status JSON is ~4.6MB on a 4k-machine tailnet, and the bar icon
  // only needs Self/BackendState. Poll light (--peers=false) while the panel
  // is closed; the panel binds peersWanted and forces a full fetch on open.
  property bool peersWanted: false
  property bool _statusFullPeers: false
  property bool _pendingFullPeers: false
  // False until a full peer fetch has answered, so the panel can tell
  // "still loading" apart from "this tailnet has no machines".
  property bool peersLoaded: false

  function publishPeers(next) {
    var sig = JSON.stringify(next)
    if (sig === _peersSig) return
    _peersSig = sig
    peers = next
  }

  function publishTailnetExitNodes(next) {
    var sig = JSON.stringify(next)
    if (sig === _tailnetExitNodesSig) return
    _tailnetExitNodesSig = sig
    tailnetExitNodes = next
  }

  function syncExitNodes() {
    var next = running ? tailnetExitNodes.concat(mullvadRegions) : []
    var sig = JSON.stringify(next)
    if (sig === _exitNodesSig) return
    _exitNodesSig = sig
    exitNodes = next
  }

  Component.onCompleted: refresh()

  function setting(name, fallback) {
    var value = settings ? settings[name] : undefined
    return value === undefined || value === null ? fallback : value
  }

  function intSetting(name, fallback, min, max) {
    var n = parseInt(String(setting(name, fallback)), 10)
    if (!isFinite(n)) n = fallback
    if (n < min) n = min
    if (n > max) n = max
    return n
  }

  function filterIPv4(ips) {
    return Model.filterIPv4(ips)
  }

  function cleanDnsName(name) {
    return Model.cleanDnsName(name)
  }

  function shortDnsName(name) {
    return Model.shortDnsName(name)
  }

  function displayHostName(hostName, dnsName) {
    return Model.displayHostName(hostName, dnsName, I18n.t)
  }

  function osIcon(os) {
    return Model.osIcon(os)
  }

  function accountLabel(account) {
    return Model.accountLabel(account, I18n.t)
  }

  function copyToClipboard(value, label) {
    var text = String(value || "")
    if (text === "") return
    Quickshell.execDetached(["bash", "-c", "printf %s " + Util.shellQuote(text) + " | wl-copy"])
  }

  function copyPeerIp(peer) {
    if (!peer) return
    var ips = filterIPv4(peer.TailscaleIPs || [])
    copyToClipboard(ips.length > 0 ? ips[0] : "", displayHostName(peer.HostName, peer.DNSName) + " IP")
  }

  function copyPeerName(peer) {
    if (!peer) return
    copyToClipboard(displayHostName(peer.HostName, peer.DNSName), displayHostName(peer.HostName, peer.DNSName) + " name")
  }

  function copyPeerDnsName(peer) {
    if (!peer) return
    copyToClipboard(cleanDnsName(peer.DNSName), displayHostName(peer.HostName, peer.DNSName) + " DNS name")
  }

  function peerAddress(peer) {
    if (!peer) return ""
    if (peer.DNSName) return cleanDnsName(peer.DNSName)
    if (peer.HostName) return String(peer.HostName)
    var ips = filterIPv4(peer.TailscaleIPs || [])
    return ips.length > 0 ? ips[0] : ""
  }

  function canSendFiles(peer) {
    if (!fileSharing || !running || !peer) return false
    return Model.isTaildropTarget(peer, selfUserId)
  }

  function sendFile(peer) {
    if (!canSendFiles(peer)) return
    var target = peerAddress(peer)
    if (target === "") return
    Quickshell.execDetached(["omarchy-tailscale-send", target])
  }

  function refresh(forceAccounts, fullPeers) {
    if (installed) {
      refreshStatusAndAccounts(forceAccounts === true, fullPeers === true)
      return
    }
    if (!whichProcess.running) {
      refreshing = true
      whichProcess.command = ["which", "tailscale"]
      whichProcess.running = true
    }
  }

  function startStatusRefresh(fullPeers) {
    if (!installed) return false
    if (statusProcess.running) {
      // A full-peer request arrived while a light poll is in flight; remember
      // it so the panel is not left stale until the next periodic refresh.
      if ((fullPeers === true || peersWanted) && !_statusFullPeers) _pendingFullPeers = true
      return false
    }
    _statusOutput = ""
    _statusError = ""
    refreshing = true
    _statusFullPeers = fullPeers === true || peersWanted || _pendingFullPeers
    if (_statusFullPeers) _pendingFullPeers = false
    statusProcess.command = _statusFullPeers
      ? ["tailscale", "status", "--json"]
      : ["tailscale", "status", "--json", "--peers=false"]
    statusProcess.running = true
    return true
  }

  function refreshStatusOnly() {
    if (startStatusRefresh(false) && !pollWatchdog.running) pollWatchdog.start()
  }

  function startStateWatch() {
    if (!installed || stateWatchProcess.running) return
    // mask 18 = NotifyInitialState (2) | NotifyNoPrivateKeys (16). Only
    // BrowseToURL is read, plus which fields are present. Current tailscaled
    // always redacts private keys; the bit covers older daemons.
    stateWatchProcess.command = ["tailscale", "debug", "localapi", "GET", "/localapi/v0/watch-ipn-bus?mask=18"]
    stateWatchProcess.running = true
  }

  function scheduleStateWatchRestart() {
    if (!installed) return
    stateWatchRestartTimer.interval = _stateWatchBackoffMs
    _stateWatchBackoffMs = Math.min(_stateWatchBackoffMs * 2, 60000)
    stateWatchRestartTimer.restart()
  }

  function handleStateWatchData(data) {
    var text = String(data || "").trim()
    if (text === "") return

    try {
      var notification = JSON.parse(text)
      // Only a real notification object means the daemon is reachable again.
      // An error body on stdout, plain text or JSON, must not reset the backoff.
      if (!notification || typeof notification !== "object" || Array.isArray(notification)) return
      _stateWatchBackoffMs = 2000
      var browseUrl = String(notification.BrowseToURL || "")
      if (browseUrl !== "" && _loginInProgress && !_loginUrlOpened) openAuthUrl(browseUrl)
      // Health updates arrive every few seconds; only refresh for changes
      // that affect what the panel shows.
      if (notification.State != null || notification.Prefs != null || notification.LoginFinished != null) stateWatchRefreshTimer.restart()
    } catch (e) {
      console.warn("tailscale: failed to parse IPN notification", e)
    }
  }

  function refreshStatusAndAccounts(forceAccounts, fullPeers) {
    if (!installed) return
    var launched = startStatusRefresh(fullPeers)
    // Exit nodes and accounts appear only in the panel, so a background
    // refresh with it closed runs the status client alone.
    var panelData = peersWanted || fullPeers === true || forceAccounts === true
    if (panelData && !mullvadExitNodesProcess.running) {
      _mullvadExitNodesOutput = ""
      _mullvadExitNodesError = ""
      mullvadExitNodesProcess.command = ["tailscale", "exit-node", "list"]
      mullvadExitNodesProcess.running = true
      launched = true
    }
    var now = Date.now()
    var shouldRefreshAccounts = panelData && (forceAccounts === true || accounts.length === 0 || now - _lastAccountsRefreshMs > 60000)
    if (shouldRefreshAccounts && !accountsProcess.running) {
      _accountsOutput = ""
      _accountsError = ""
      _lastAccountsRefreshMs = now
      accountsProcess.command = ["tailscale", "switch", "--list", "--json"]
      accountsProcess.running = true
      launched = true
    }
    // Arm on the launch that needs watching and leave it alone after that.
    // Restarting it every refresh pushes the deadline out ahead of a hung
    // process forever once the refresh interval is shorter than the timeout,
    // and refreshIntervalSec goes down to five seconds.
    if (launched && !pollWatchdog.running) pollWatchdog.start()
  }

  function elideStatus(text) {
    var value = String(text || "").replace(/\s+/g, " ").trim()
    return value.length > 140 ? value.substring(0, 137) + "…" : value
  }

  function resetUnavailable(message) {
    running = false
    needsLogin = false
    _desired = -1
    backendState = "Unavailable"
    statusText = message
    selfName = ""
    selfDnsName = ""
    selfIp = ""
    selfUserId = ""
    fileSharing = false
    authUrl = ""
    publishPeers([])
    publishTailnetExitNodes([])
    peersLoaded = false
    syncExitNodes()
    mullvadExitNodes = []
    mullvadRegions = []
    _mullvadRegionsSig = "[]"
    accounts = []
    selectedAccountId = ""
    selectedAccountLabel = ""
    switchingAccountId = ""
    settingExitNodeId = ""
    accountsAccessDenied = false
  }

  function parseStatus(raw) {
    var parsed = Model.parseStatus(raw, I18n.t)
    if (!parsed.ok) {
      resetUnavailable(parsed.message || "Status error")
      lastError = I18n.t("tailscale.statusParseFailed")
      console.warn("tailscale", parsed.error || "Failed to parse tailscale status")
      return
    }
    if (parsed.unavailable) {
      resetUnavailable(parsed.message || "Disconnected")
      return
    }

    backendState = parsed.backendState
    running = parsed.running
    // Reality caught up to the pending toggle — stop overriding.
    if (_desired !== -1 && running === (_desired === 1)) _desired = -1
    needsLogin = parsed.needsLogin
    authUrl = parsed.authUrl
    if (needsLogin && _loginInProgress && !_loginUrlOpened && authUrl !== "" && authUrl !== _preLoginAuthUrl) openAuthUrl(authUrl)
    selfName = parsed.selfName
    selfDnsName = parsed.selfDnsName
    selfIp = parsed.selfIp
    selfUserId = parsed.selfUserId
    fileSharing = parsed.fileSharing
    // A light poll carries no peer data — keep the last full machine list
    // while running, and only clear it when tailscale actually went down.
    if (_statusFullPeers) {
      publishPeers(parsed.running ? parsed.peers : [])
      publishTailnetExitNodes(parsed.running ? parsed.exitNodes : [])
      // A stopped tailnet publishes no peers, so a later light poll finding it
      // running again must not read as "fetched, and this tailnet is empty".
      peersLoaded = parsed.running
    } else if (!parsed.running) {
      publishPeers([])
      publishTailnetExitNodes([])
      peersLoaded = false
    }
    syncExitNodes()

    if (needsLogin) statusText = "Needs login"
    else if (running) {
      statusText = "Connected"
      if (_loginInProgress || _loginTimedOut) actionStatus = ""
      _loginTimedOut = false
      _loginInProgress = false
      _loginUrlOpened = false
      _preLoginAuthUrl = ""
      loginTimeoutTimer.stop()
    } else if (backendState === "Stopped") {
      statusText = "Disconnected"
    } else {
      statusText = backendState
    }
    lastError = ""
    // A stopped daemon may reveal an expired key only after the resume request.
    // Continue that user-requested connection once the request has exited.
    if (needsLogin && (_desired === 1 || _resumePending) && !loginProcess.running) {
      connectTimeoutTimer.stop()
      loginOrUp()
    }
  }

  function parseAccounts(raw) {
    var parsed = Model.parseAccounts(raw, I18n.t)
    accounts = parsed.accounts
    selectedAccountId = parsed.selectedAccountId
    selectedAccountLabel = parsed.selectedAccountLabel
    accountsAccessDenied = false
  }

  function parseMullvadExitNodes(raw) {
    // The raw node list is small and nothing hot binds to it, so publish it
    // unconditionally; only the derived regions need the churn guard.
    mullvadExitNodes = Model.parseExitNodeList(raw)
    var nextRegions = Model.mullvadRegionOptions(mullvadExitNodes)
    var sig = JSON.stringify(nextRegions)
    if (sig !== _mullvadRegionsSig) {
      _mullvadRegionsSig = sig
      mullvadRegions = nextRegions
    }
    syncExitNodes()
  }

  function toggleTailscale() {
    // Match the busy switch for keyboard, bar and IPC toggles.
    if (!installed || connecting || waitingForLogin) return
    if (active) down()
    else loginOrUp()
  }

  function down() {
    // No progress status here — the greyed icon and hero line already convey
    // the optimistic off; only surface a message if the command fails.
    _desired = 0
    _loginInProgress = false
    _resumePending = false
    // A resume or login request still in flight no longer reflects intent.
    if (loginProcess.running) _loginSuperseded = true
    loginTimeoutTimer.stop()
    connectTimeoutTimer.stop()
    runAction(["tailscale", "down"])
  }

  function loginOrUp() {
    if (!installed || loginProcess.running || _loginInProgress) return
    _loginTimedOut = false
    lastError = ""
    actionStatus = ""
    actionStatusTimer.stop()
    _desired = -1
    var plan = Model.loginPlan(needsLogin, authUrl)
    if (plan.authUrl !== "") {
      _loginUrlOpened = false
      openAuthUrl(plan.authUrl)
      return
    }
    _loginOutput = ""
    _loginError = ""
    if (needsLogin) actionStatus = I18n.t("tailscale.waitingForLoginLink")
    else {
      _desired = 1
      connectTimeoutTimer.restart()
    }
    _loginInProgress = needsLogin
    _resumePending = !needsLogin
    _loginUrlOpened = false
    _preLoginAuthUrl = authUrl
    loginProcess.command = timedCommand(plan.command)
    loginProcess.running = true
    if (needsLogin) loginTimeoutTimer.restart()
  }

  function switchAccount(id) {
    var accountId = String(id || "")
    if (!installed || accountId === "" || accountId === selectedAccountId || switchProcess.running) return
    _switchOutput = ""
    _switchError = ""
    lastError = ""
    actionStatus = ""
    actionStatusTimer.stop()
    switchingAccountId = accountId
    switchProcess.command = timedCommand(["tailscale", "switch", accountId])
    switchProcess.running = true
  }

  function exitNodeTarget(peer) {
    if (!peer) return ""
    if (peer.Mullvad === true) {
      var mullvadIps = filterIPv4(peer.TailscaleIPs || [])
      if (mullvadIps.length > 0) return mullvadIps[0]
    }
    return peerAddress(peer)
  }

  function setExitNode(peer) {
    if (!installed || !running || !peer || exitNodeProcess.running) return
    var active = peer.ExitNode === true
    var target = active ? "" : exitNodeTarget(peer)
    if (!active && target === "") return
    _exitNodeOutput = ""
    _exitNodeError = ""
    lastError = ""
    actionStatus = ""
    actionStatusTimer.stop()
    settingExitNodeId = String(peer.id || "")
    exitNodeProcess.command = timedCommand(["tailscale", "set", "--exit-node=" + target])
    exitNodeProcess.running = true
  }

  function authorizeTailscaleOperator() {
    if (!installed || operatorProcess.running || userName === "") return
    _operatorOutput = ""
    _operatorError = ""
    actionStatus = I18n.t("tailscale.authorizingOperator")
    operatorProcess.command = ["pkexec", "tailscale", "set", "--operator=" + userName]
    operatorProcess.running = true
  }

  function timedCommand(command) {
    // Bound finite CLI requests, including a child that ignores termination.
    // This does not cancel work already accepted by tailscaled.
    // Keep the supervisor alive when it must kill the CLI, so QML receives 137.
    return ["timeout", "--foreground", "--kill-after=2s", "20s"].concat(command)
  }

  function showActionError(exitCode, output, fallback) {
    var timedOut = exitCode === 124 || exitCode === 137
    lastError = timedOut ? I18n.t("tailscale.commandTimedOut") : (elideStatus(output) || fallback)
    actionStatus = lastError
    if (timedOut) actionStatusTimer.stop()
    else actionStatusTimer.restart()
  }

  function runAction(command, label) {
    if (actionProcess.running) return
    _actionOutput = ""
    _actionError = ""
    lastError = ""
    actionStatusTimer.stop()
    actionStatus = label || ""
    actionProcess.command = timedCommand(command)
    actionProcess.running = true
  }

  function openAuthUrl(value) {
    if (_loginUrlOpened) return true
    var url = String(value || "").trim()
    if (!/^https?:\/\/\S+$/.test(url)) return false

    _loginUrlOpened = true
    _loginInProgress = false
    _resumePending = false
    loginTimeoutTimer.stop()
    connectTimeoutTimer.stop()
    Quickshell.execDetached(["omarchy-launch-browser", url])
    // Close the panel before dropping the optimistic state so its connected
    // sections do not visibly collapse on the way out.
    authUrlOpened()
    actionStatus = ""
    lastError = ""
    _desired = -1
    return true
  }

  function handleLoginOutput(data, isError) {
    var text = String(data || "")
    // `tailscale debug localapi` narrates the request on stderr as
    // "# doing request …" and "# Response status …"; the body is the message.
    if (/^\s*#/.test(text)) return
    if (isError) _loginError += text + "\n"
    else _loginOutput += text + "\n"
  }

  Timer {
    // The IPN watcher refreshes status whenever State or Prefs change, which
    // is all the bar icon shows. It carries no peer changes, so poll only
    // while the open panel lists machines, exit nodes and accounts. Opening
    // the panel refreshes them at once.
    id: refreshTimer
    interval: root.refreshIntervalSec * 1000
    repeat: true
    running: root.peersWanted
    onTriggered: root.refresh()
  }

  Timer {
    // After a fresh boot the startup poll usually lands before tailscaled has
    // connected, which left the icon stale until the next periodic refresh.
    // Poll quickly until the service shows up, or give up after ~30 seconds.
    id: startupRamp
    property int ticks: 0
    interval: 2000
    repeat: true
    running: true
    onTriggered: {
      ticks += 1
      if (root.running || ticks >= 15) startupRamp.running = false
      else root.refresh()
    }
  }

  Timer {
    id: delayedRefresh
    interval: 600
    repeat: false
    onTriggered: root.refresh()
  }

  Timer {
    // Every poll is skipped while its own process is still running, so one that
    // never exits — tailscale can hang on a network that is coming and going —
    // silently stops the panel refreshing at all, and it stays stopped. Reap
    // anything still running well inside the refresh interval so the next tick
    // starts clean.
    id: pollWatchdog
    interval: 15000
    repeat: false
    onTriggered: {
      if (statusProcess.running) statusProcess.running = false
      if (mullvadExitNodesProcess.running) mullvadExitNodesProcess.running = false
      if (accountsProcess.running) accountsProcess.running = false
    }
  }

  Timer {
    id: actionStatusTimer
    interval: 2200
    repeat: false
    onTriggered: root.actionStatus = ""
  }

  Timer {
    // State notifications update the icon immediately. Debounce the heavier
    // status query that fills in peers, account details, and addresses.
    id: stateWatchRefreshTimer
    interval: 150
    repeat: false
    onTriggered: {
      if (statusProcess.running) restart()
      else root.refreshStatusOnly()
    }
  }

  Timer {
    // Interval is set by scheduleStateWatchRestart: 2 s, doubling to a minute
    // while the daemon stays unreachable, back to 2 s once data flows again.
    id: stateWatchRestartTimer
    interval: 2000
    repeat: false
    onTriggered: root.startStateWatch()
  }

  Timer {
    // The prefs PATCH returns before the backend has connected, so the
    // optimistic "on" needs its own deadline. Past it, follow the real state
    // again rather than showing a switch stuck on "Connecting…".
    id: connectTimeoutTimer
    interval: 20000
    repeat: false
    onTriggered: {
      root._resumePending = false
      if (root._desired !== 1 || root.running) return
      root._desired = -1
      root.actionStatus = I18n.t("tailscale.stillStarting")
      actionStatusTimer.restart()
      // The last poll may predate the backend connecting, and the periodic
      // refresh can be far off, so ask again rather than trust the cache. The
      // debounce timer keeps retrying while a status query is still running.
      stateWatchRefreshTimer.restart()
    }
  }

  Timer {
    id: loginTimeoutTimer
    interval: 25000
    repeat: false
    onTriggered: {
      if (!root._loginInProgress || root._loginUrlOpened) return
      root._loginTimedOut = true
      root._loginInProgress = false
      root._desired = -1
      if (loginProcess.running) loginProcess.running = false
      actionStatusTimer.stop()
      root.actionStatus = I18n.t("tailscale.loginLinkTimedOut")
      stateWatchRefreshTimer.restart()
    }
  }

  Process {
    id: whichProcess
    running: false
    command: []
    onExited: function(exitCode) {
      root.installed = exitCode === 0
      if (root.installed) {
        root.startStateWatch()
        root.refreshStatusAndAccounts()
      }
      else {
        root.refreshing = false
        root.resetUnavailable("Not installed")
      }
    }
  }

  Process {
    id: stateWatchProcess
    running: false
    command: []
    stdout: SplitParser { onRead: function(data) { root.handleStateWatchData(data) } }
    onExited: function(exitCode) {
      // Nothing polls while the panel is closed, so a stopped daemon would
      // otherwise leave the last connected state on the bar.
      stateWatchRefreshTimer.restart()
      root.scheduleStateWatchRestart()
    }
  }

  Process {
    id: statusProcess
    running: false
    command: []
    stdout: StdioCollector { id: statusStdout; waitForEnd: true; onStreamFinished: root._statusOutput = text }
    stderr: StdioCollector { id: statusStderr; waitForEnd: true; onStreamFinished: root._statusError = text }
    onExited: function(exitCode) {
      root.refreshing = false
      var stdout = String(statusStdout.text || root._statusOutput || "")
      var stderr = String(statusStderr.text || root._statusError || "")
      if (exitCode === 0) root.parseStatus(stdout)
      else {
        root.resetUnavailable("Disconnected")
        root.lastError = stderr.trim()
      }
      if (root._pendingFullPeers) {
        root._pendingFullPeers = false
        root.refreshStatusAndAccounts(false, true)
      }
    }
  }

  Process {
    id: accountsProcess
    running: false
    command: []
    stdout: StdioCollector { id: accountsStdout; waitForEnd: true; onStreamFinished: root._accountsOutput = text }
    stderr: StdioCollector { id: accountsStderr; waitForEnd: true; onStreamFinished: root._accountsError = text }
    onExited: function(exitCode) {
      var stdout = String(accountsStdout.text || root._accountsOutput || "")
      var stderr = String(accountsStderr.text || root._accountsError || "")
      if (exitCode === 0) root.parseAccounts(stdout)
      else {
        root.parseAccounts("")
        if (/profiles access denied/i.test(stderr) || /profiles access denied/i.test(stdout)) {
          root.accountsAccessDenied = true
          root.lastError = I18n.t("tailscale.authorizeToShowConnections")
        } else {
          root.lastError = elideStatus(stderr || stdout || I18n.t("tailscale.listConnectionsFailed"))
        }
      }
    }
  }

  Process {
    id: mullvadExitNodesProcess
    running: false
    command: []
    stdout: StdioCollector { id: mullvadExitNodesStdout; waitForEnd: true; onStreamFinished: root._mullvadExitNodesOutput = text }
    stderr: StdioCollector { id: mullvadExitNodesStderr; waitForEnd: true; onStreamFinished: root._mullvadExitNodesError = text }
    onExited: function(exitCode) {
      var stdout = String(mullvadExitNodesStdout.text || root._mullvadExitNodesOutput || "")
      if (exitCode === 0) root.parseMullvadExitNodes(stdout)
      else root.parseMullvadExitNodes("")
    }
  }

  Process {
    id: actionProcess
    running: false
    command: []
    stdout: StdioCollector { id: actionStdout; waitForEnd: true; onStreamFinished: root._actionOutput = text }
    stderr: StdioCollector { id: actionStderr; waitForEnd: true; onStreamFinished: root._actionError = text }
    onExited: function(exitCode) {
      var stdout = String(actionStdout.text || root._actionOutput || "")
      var stderr = String(actionStderr.text || root._actionError || "")
      if (exitCode !== 0) {
        root._desired = -1
        root.showActionError(exitCode, stderr || stdout, I18n.t("tailscale.commandFailed"))
      } else {
        root.lastError = ""
        root.actionStatus = ""
      }
      delayedRefresh.restart()
    }
  }

  Process {
    id: loginProcess
    running: false
    command: []
    stdout: SplitParser { onRead: function(data) { root.handleLoginOutput(data, false) } }
    stderr: SplitParser { onRead: function(data) { root.handleLoginOutput(data, true) } }
    onExited: function(exitCode) {
      var combined = String(root._loginOutput || "") + "\n" + String(root._loginError || "")
      // The success body is the full prefs object; nothing here needs it.
      root._loginOutput = ""
      root._loginError = ""
      if (root._loginTimedOut || root._loginSuperseded) {
        root._loginSuperseded = false
        delayedRefresh.restart()
        return
      }
      if (exitCode !== 0 && !root._loginUrlOpened) {
        loginTimeoutTimer.stop()
        root._desired = -1
        root._loginInProgress = false
        root._resumePending = false
        connectTimeoutTimer.stop()
        root.showActionError(exitCode, combined, I18n.t("tailscale.startFailed"))
      } else {
        root.lastError = ""
        // The request completes before the daemon supplies the login URL.
        if (!root._loginInProgress) root.actionStatus = ""
      }
      delayedRefresh.restart()
    }
  }

  Process {
    id: switchProcess
    running: false
    command: []
    stdout: StdioCollector { id: switchStdout; waitForEnd: true; onStreamFinished: root._switchOutput = text }
    stderr: StdioCollector { id: switchStderr; waitForEnd: true; onStreamFinished: root._switchError = text }
    onExited: function(exitCode) {
      var stdout = String(switchStdout.text || root._switchOutput || "")
      var stderr = String(switchStderr.text || root._switchError || "")
      if (exitCode !== 0) {
        root.showActionError(exitCode, stderr || stdout, I18n.t("tailscale.switchFailed"))
      } else {
        root.lastError = ""
        root.actionStatus = ""
        root._lastAccountsRefreshMs = 0
      }
      root.switchingAccountId = ""
      delayedRefresh.restart()
    }
  }

  Process {
    id: exitNodeProcess
    running: false
    command: []
    stdout: StdioCollector { id: exitNodeStdout; waitForEnd: true; onStreamFinished: root._exitNodeOutput = text }
    stderr: StdioCollector { id: exitNodeStderr; waitForEnd: true; onStreamFinished: root._exitNodeError = text }
    onExited: function(exitCode) {
      var stdout = String(exitNodeStdout.text || root._exitNodeOutput || "")
      var stderr = String(exitNodeStderr.text || root._exitNodeError || "")
      if (exitCode !== 0) {
        root.showActionError(exitCode, stderr || stdout, I18n.t("tailscale.exitNodeFailed"))
      } else {
        root.lastError = ""
        root.actionStatus = ""
      }
      root.settingExitNodeId = ""
      delayedRefresh.restart()
    }
  }

  Process {
    id: operatorProcess
    running: false
    command: []
    stdout: StdioCollector { id: operatorStdout; waitForEnd: true; onStreamFinished: root._operatorOutput = text }
    stderr: StdioCollector { id: operatorStderr; waitForEnd: true; onStreamFinished: root._operatorError = text }
    onExited: function(exitCode) {
      var stdout = String(operatorStdout.text || root._operatorOutput || "")
      var stderr = String(operatorStderr.text || root._operatorError || "")
      if (exitCode !== 0) {
        root.lastError = elideStatus(stderr || stdout || I18n.t("tailscale.authorizationFailed"))
        root.actionStatus = root.lastError
        actionStatusTimer.restart()
      } else {
        root.accountsAccessDenied = false
        root.lastError = ""
        root.actionStatus = I18n.t("tailscale.operatorAuthorized")
        actionStatusTimer.restart()
        root._lastAccountsRefreshMs = 0
      }
      delayedRefresh.restart()
    }
  }
}
