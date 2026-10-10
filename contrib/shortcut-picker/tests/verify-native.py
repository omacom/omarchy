#!/usr/bin/python
"""Check C++ results against the saved JavaScript in Qt's own engine."""
import argparse
import json
from pathlib import Path
import random
import re
import subprocess
import tempfile

repo = Path(__file__).resolve().parent.parent
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--sanitize', action='store_true')
args = parser.parse_args()
build = repo / 'build' / ('verify-search-sanitized' if args.sanitize else 'verify-search')
build.mkdir(parents=True, exist_ok=True)
subprocess.run(['qmake6', str(repo / 'native/search/verify.pro'), *(['CONFIG+=sanitize'] if args.sanitize else [])], cwd=build, check=True, stdout=subprocess.DEVNULL)
subprocess.run(['make', '-j2'], cwd=build, check=True, stdout=subprocess.DEVNULL)
fixtures = json.loads((repo / 'tests/fixtures.json').read_text())
options = [row for rows in fixtures.values() for row in rows]
options += ['icon\tCTRL + A\tDescription window <b>&"\t tab', 'icon\tCTRL + B\t',
            'SUPER + İ → İSTANBUL café 😀', 'SUPER + C → café CAFÉ カフェ',
            'SUPER + J → <b>window</b> & "text"', 'CTRL + A → duplicate', 'CTRL + A → duplicate',
            'super super + space → space spacebar', 'SUPER + X → a\tb\tc',
            'CTRL + Σ → ΟΣ ΟΣΑ', 'CTRL + 𐐀 → 𐐀 𐐨', 'CTRL + X → with\u0085NEL',
            'CTRL\ufeff+ A → NBSP\u00a0word', '', '\t', '\t\t', 'icon\t\ttext']
queries = {'',' + ','zzzz','super space','space super','meta spacebar','ctrl enter','window split',
           'splt wndw','İ','i','café','CAFÉ','😀','&','<b>','\t','control','esc','super super',
           'super\tspace','Σ','ΟΣ','ος','οσ','𐐀','\u0085','super\ufeffspace','super\u00a0space'}
for option in options:
    for word in filter(None, re.split(r'[\s+→]+', option)):
        for length in range(1,len(word)+1): queries.add(word[:length])
        queries.update(['super '+word, word+' ctrl', word[::2]])
rng = random.Random(12345)
words = sorted(queries)
for _ in range(1000): queries.add(rng.choice(words)+' '+rng.choice(words))
queries = sorted(queries)
datasets = [{'options':options,'queries':queries}]
# Deterministic fuzz: Unicode casing, punctuation, aliases, overlapping matches,
# spacing, repeated modifier tokens, empty labels, and optional icon/detail fields.
alphabet = 'abcde ABCDE0123_+&<>"\t→İΣσςé😀\u00a0\ufeff\u0085'
random_options = []
for _ in range(100):
    label = ''.join(rng.choice(alphabet) for _ in range(rng.randrange(1,80)))
    detail = ''.join(rng.choice(alphabet) for _ in range(rng.randrange(0,40)))
    random_options.append(label if rng.randrange(2) else 'icon\t'+label+'\t'+detail)
random_queries = [''.join(rng.choice(alphabet) for _ in range(rng.randrange(1,8))) for _ in range(1000)]
datasets.append({'options':random_options,'queries':random_queries})
for replacement in [options[:2], options[-2:], [], options[:1], options, options]:
    datasets.append({'options':replacement,'queries':['','ctrl','zzzz','super','']})
with tempfile.TemporaryDirectory(prefix='verify-native-search-') as directory:
    root = Path(directory)
    (root/'fixtures.json').write_text(json.dumps({'datasets':datasets}))
    (root/'Oracle.js').write_bytes((repo/'tests/Oracle.js').read_bytes())
    subprocess.run([str(build/'verify-search'),str(root/'fixtures.json'),str(root/'Oracle.js')],check=True)
