"""System gettext, gap-only hint translations and exact-owned Pulse control."""
import gettext
import json
import re
import subprocess
from pathlib import Path

KEYS=('M = Turn On Audio','M = Turn Off Audio')

def hint_labels(environment):
    raw=next((environment.get(k) for k in ('LANGUAGE','LC_ALL','LC_MESSAGES','LANG') if environment.get(k)), 'C')
    locales=[]
    for loc in raw.split(':'):
        loc=loc.split('.')[0].split('@')[0].replace('-','_')
        if loc in ('C','POSIX','en') or loc.startswith('en_'): break
        for candidate in (loc,loc.split('_')[0]):
            if candidate not in locales: locales.append(candidate)
    gaps=json.loads(Path(__file__).with_name('i18n.json').read_text())
    result=[]
    for key in KEYS:
        translated=key
        for loc in locales:
            for domain in ('gtk30','gtk40','glib20','gdk-pixbuf','gnome-desktop-3.0'):
                catalog=gettext.translation(domain,'/usr/share/locale',languages=[loc],fallback=True)
                value=catalog.gettext(key)
                if value!=key: translated=value; break
            if translated==key: translated=gaps.get(loc,{}).get(key,key)
            if translated!=key: break
        result.append(translated)
    return tuple(result)

class OwnedAudio:
    """No default-sink or system mute commands; identity checked each operation.

    Random per-child application.id is inherited by ONLY the registered sandbox.
    The caller additionally verifies the actual child ancestry/namespace before apply.
    Native connect wrapper guarantees initial server mute + 10% linear stream gain.
    """
    def __init__(self,token,environment):
        if not re.fullmatch(r'org\.omarchy\.amiga-screensaver\.[a-f0-9]{32}',token):
            raise ValueError('Invalid owned audio token')
        self.token=token; self.env=dict(environment,LC_ALL='C'); self.index=None
    def command(self,*args):
        return subprocess.check_output(['pactl',*args],env=self.env,text=True,timeout=3)
    def find(self):
        matches=[x for x in json.loads(self.command('-f','json','list','sink-inputs'))
                 if x.get('properties',{}).get('application.id')==self.token
                 and x.get('properties',{}).get('application.process.binary')=='fs-uae']
        if len(matches)>1: raise RuntimeError('Ambiguous owned stream')
        if not matches: return None
        stream=matches[0]
        if self.index is not None and stream['index']!=self.index:
            raise RuntimeError('Owned stream replaced unexpectedly')
        return stream
    def apply(self,muted):
        stream=self.find()
        if stream is None: return None
        self.index=stream['index']
        # Require bounded native startup volume before ANY unmute operation.
        volumes=[channel['value'] for channel in stream['volume'].values()]
        if not volumes or any(v>round(65536 * (0.10 ** (1/3))) for v in volumes):
            self.command('set-sink-input-mute',str(self.index),'1')
            raise RuntimeError('Unsafe stream gain; kept muted')
        self.command('set-sink-input-mute',str(self.index),'1' if muted else '0')
        actual=self.find()
        if actual is None or actual['mute'] is not muted:
            raise RuntimeError('Audio mute readback failed')
        return actual
