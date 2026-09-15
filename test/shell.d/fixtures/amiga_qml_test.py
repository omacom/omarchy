"""Regression replay of actual QML handlers; run only through the isolated test runner.
No compositor, keyboard injection, emulator, service sockets or signals.
This is a handler replay, not live compositor acceptance.
"""
import json
import re
import os
from pathlib import Path
import subprocess
import tempfile

source = (Path(os.environ['ROOT']) / 'packages/amiga-runtime/guard/Guard.qml').read_text()

def body_after(marker):
    start = source.index('{', source.index(marker))
    depth = 1
    for end in range(start + 1, len(source)):
        depth += (source[end] == '{') - (source[end] == '}')
        if depth == 0:
            return source[start + 1:end]
    raise AssertionError('Unbalanced handler: ' + marker)

qml = '''import QtQuick
import QtTest
TestCase {
 id: root
 name: "CurrentGuardMuteReproducer"
 when: windowShown
 property bool active: true
 property bool armed: true
 property bool dismissed: false
 property string reason: ""
 property bool requestedMuted: true
 property int audioRevision: 0
 property bool audioMuted: true
 property string token: "owner"
 property string monitorName: ""
 property string appId: ""
 property bool frameReady: false
 property string demoTitle: ""
 property bool titlePending: false
 property int presentationGeneration: 0
 property int titlePendingGeneration: 0
 Timer { id: titleHint; interval: 5000 }
 Timer { id: hint; interval: 2000 }
 function present(owner,monitor,id,title) { PRESENT }
 function test_title_independent_expiry() {
   compare(present("owner","eDP-1","org.omarchy.amiga-screensaver.0123456789abcdef0123456789abcdef", "<b>Actual & title</b>"), "ok")
   compare(presentationGeneration, 1)
   compare(demoTitle, "<b>Actual & title</b>"); verify(!titleHint.running)
   frameArrived(presentationGeneration); verify(titleHint.running)
   wait(4100); audioApplied("owner",audioRevision,true)
   wait(1100); verify(!titleHint.running); verify(hint.running)
   wait(1000); verify(!hint.running)
   const firstGeneration = presentationGeneration
   present("owner","eDP-1","org.omarchy.amiga-screensaver.1123456789abcdef0123456789abcdef", "Next")
   compare(presentationGeneration, firstGeneration + 1)
   compare(demoTitle,"Next"); verify(!titleHint.running)
   frameArrived(firstGeneration); verify(!titleHint.running, "stale source content rearmed title")
   frameArrived(presentationGeneration); verify(titleHint.running, "content already available did not rearm title")
 }
 function frameArrived(generation) { ARRIVED }
 function audioApplied(owner,revision,muted) { APPLIED }
 function requestAudioToggle() { TOGGLE }
 function relative(dx,dy) { MOTION }
 function dismiss(why) { DISMISS }
 // Removed unclassified idle source: seat events cannot cause dismissal.
 function seat(isIdle) {}
 function press(event) { PRESS }
 function release(event) { RELEASE }
 function init() { hint.stop(); titleHint.stop(); dismissed = false; reason = ""; armed = true; requestedMuted = true; audioRevision = 0; presentationGeneration = 0; titlePendingGeneration = 0; titlePending = false }
 function m(repeat) { return {key: Qt.Key_M, isAutoRepeat: repeat, accepted: false} }
 function test_seat_before_m() {
   seat(false); press(m(false)); verify(!dismissed, "M dismissed via " + reason)
 }
 function test_m_before_seat() {
   press(m(false)); seat(false); verify(!dismissed, "M dismissed via " + reason)
 }
 function test_repeat_m() {
   press(m(true)); verify(!dismissed, "M autorepeat dismissed via " + reason); compare(audioRevision, 0); verify(requestedMuted)
 }
 function test_release_consumed() {
   const event = m(false); release(event); verify(event.accepted); verify(!dismissed)
 }
 function test_other_key_dismisses() {
   press({key: Qt.Key_Escape, isAutoRepeat: false, accepted: false}); verify(dismissed)
 }
 function test_no_unclassified_seat_source() { seat(false); verify(!dismissed) }
 function test_motion_during_m_dismisses() { press(m(false)); relative(1,0); verify(dismissed); compare(reason,"motion") }
 function test_motion_before_m_dismisses() { relative(0,1); press(m(false)); verify(dismissed) }
 function test_zero_motion_ignored() { relative(0,0); verify(!dismissed) }
 function test_preference_survives_demo_transition() {
   press(m(false)); compare(present("owner","eDP-1","org.omarchy.amiga-screensaver.0123456789abcdef0123456789abcdef"),"ok")
   verify(!requestedMuted); compare(audioRevision,1)
 }
 function test_hint_ack_and_two_second_expiry() {
   compare(audioApplied("wrong",0,false),"stale"); verify(!hint.running)
   compare(audioApplied("owner",0,true),"ok"); verify(hint.running)
   tryCompare(hint, "running", false, 2500)
 }
 function test_single_toggle_repeat_release() {
   const event=m(false); press(event); verify(event.accepted); verify(!requestedMuted); compare(audioRevision,1)
   press(m(true)); release(m(false)); verify(!requestedMuted); compare(audioRevision,1)
   press(m(false)); verify(requestedMuted); compare(audioRevision,2)
 }
}
'''
for placeholder, marker in [('DISMISS', 'function dismiss('), ('PRESENT', 'function present('), ('APPLIED', 'function audioApplied('), ('TOGGLE', 'function requestAudioToggle('), ('MOTION', 'onMotion:'), ('PRESS', 'Keys.onPressed:'), ('RELEASE', 'Keys.onReleased:')]:
    qml = qml.replace(placeholder, body_after(marker))
qml = qml.replace('Timer { id: titleHint; interval: 5000 }', re.search(r'Timer \{ id: titleHint; interval: [0-9]+ \}', source).group(0))
qml = qml.replace('ARRIVED', body_after('function frameArrived(') if 'function frameArrived(' in source else '')
qml = qml.replace('Timer { id: hint; interval: 2000 }', re.search(r'Timer \{ id: hint; interval: [0-9]+ \}', source).group(0))
with tempfile.TemporaryDirectory(prefix='mute-repro-') as directory:
    path = Path(directory) / 'tst_m.qml'
    path.write_text(qml)
    env = dict(os.environ, QT_QPA_PLATFORM='offscreen', QT_QUICK_BACKEND='software', HOME='/tmp', XDG_RUNTIME_DIR=directory)
    result = subprocess.run(['/usr/lib/qt6/bin/qmltestrunner', '-input', str(path)], env=env, timeout=20)
    raise SystemExit(result.returncode)
