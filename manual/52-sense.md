# Sense

Sense learns the way you already work and quietly puts it back when it drifts. Turn it on with `omarchy sense enable` (also under _Trigger > Sense_). It records only two things, locally on your machine: which application has focus, and which applications sit on which workspaces. Window titles, file paths and keystrokes are never recorded, and nothing is sent anywhere.

After the same window layout has come back on a few different days, Sense names it a scene, after the time of day and the app that appears in it most often, like `morning-ghostty`. Run `omarchy sense scenes` to see what it has learned. When your windows end up scattered, `omarchy sense apply morning-ghostty` moves the open ones back to their usual workspaces. It never launches or closes applications, it only tidies what is already open.

Sense also learns routines: the same ordered sequence of applications, like terminal to editor to browser and back, repeated across different days. Run `omarchy sense routines` to see them. Sense mentions each new routine once, when it first notices it, and `omarchy sense routine ghostty-to-code` (use the name it shows you) walks the sequence for you, putting each open application on its usual workspace and focusing it in turn. If a suggestion is not useful, `omarchy sense routine dismiss <name>` stops that one for good.

Sense also watches how focus moves. When you settle into one application for a good stretch with few switches, it calls that flow and, if you ask it to guard (`omarchy sense guard`, or leave the session watcher running), silences notifications until you surface again. What you had silenced yourself is always left alone, and anything Sense silenced is restored when the flow breaks. `omarchy sense why` explains the current reading with the numbers behind it, so you never have to wonder why it did something.

Stop learning any time with `omarchy sense disable`. Delete everything it learned with `omarchy sense forget`. With Sense off, the session watcher exits immediately and records nothing.
