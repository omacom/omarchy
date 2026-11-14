# Cellular Omarchy Widget

Native Omarchy bar widget for WWAN modems managed by ModemManager.

## Features

- Signal bars in the bar, drawn natively so they follow the bar's icon size and theme colors
- Bars dim when the modem is registered without data, or when another connection holds the default route
- An `R` marks roaming; the urgent color marks a missing SIM, a SIM waiting for its PIN, or a failed modem
- Hover shows operator, technology, connection state, and signal percentage
- Left click opens a keyboard-friendly panel; middle click refreshes
- The panel shows operator and technology, signal, registration, roaming, APN, IPv4 address, bearer uptime, interface, network code, modem model, and the session's received and sent bytes
- Turn mobile data on or off with `nmcli device connect|disconnect` on the modem's device
- Hidden entirely when ModemManager is not installed or not running

## Keyboard shortcuts

Inside the panel:

- `h` / `l` or arrows: move between refresh and the mobile data switch
- `enter` / `space`: activate the current control
- `t`: toggle mobile data
- `r`: refresh
- `c`: copy the IPv4 address
- `tab` / `shift+tab`: switch to the neighboring panel
- `esc`: close

## IPC

`omarchy-shell omarchy.cellular <method>`:

- `open`, `close`, `toggle`: the panel
- `refresh`: read the modem again
- `dataOn`, `dataOff`: mobile data
- `status`: JSON with `state`, `operator`, `technology`, `signal`, `roaming`, `connected`, and `iface`

## Requirements

- `modemmanager` (`mmcli`) for the modem; without it the widget stays hidden
- NetworkManager with a mobile broadband connection for the modem, for the data switch

## How it stays current

The plugin is a service plus a bar widget, so every monitor's widget shares one watcher, and the watcher only runs while a widget is in the bar. It listens to a single `gdbus monitor --system --dest org.freedesktop.ModemManager1`: signal quality is read straight off that stream, and any other change (state, registration, bearers, a modem appearing, ModemManager restarting) triggers one debounced `mmcli` read. There is no polling. While the panel is open the session counters are read from `/sys/class/net/<iface>/statistics/` every two seconds, in-process.

## Add to the bar

This widget ships as first-party plugin `omarchy.cellular`. Add it with `omarchy plugin enable omarchy.cellular`, then place it with `omarchy bar move omarchy.cellular` if desired.
