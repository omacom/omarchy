"""Exercise the local socket boundary without launching the desktop or actions."""
import json
import os
from pathlib import Path
import socket
import subprocess
import tempfile
import threading
import time
import unittest
import shutil

SELECTOR = Path(os.environ.get('TEST_SELECTOR', str(Path(__file__).parent.parent / 'plugin/bin/omarchy-menu-select')))


class PickerFallbackTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        bindir = self.root / 'bin'
        bindir.mkdir()
        stock = bindir / 'omarchy-menu-select'
        stock.write_text('#!/usr/bin/python\nimport json, sys\nprint(json.dumps({"args":sys.argv[1:], "stdin":sys.stdin.read()}))\n')
        stock.chmod(0o755)
        self.env = dict(os.environ, OMARCHY_PATH=str(self.root),
                        XDG_RUNTIME_DIR=str(self.root), WAYLAND_DISPLAY='wayland-test')

    def invoke(self, mode, args=None, options=None):
        args = args or ['Keybindings', '--', '--width', '800']
        options = options or 'SUPER + SPACE → Menu "quoted" $(literal)\nCTRL + A → Other\n'
        server = None
        worker = None
        if mode != 'unavailable':
            server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            path = self.root / 'omarchy-shortcuts-wayland-test.sock'
            path.unlink(missing_ok=True)
            server.bind(str(path))
            server.listen(1)
            server.settimeout(4)
            def respond():
                with server.accept()[0] as connection:
                    with connection.makefile('rb') as stream:
                        payload = json.loads(stream.readline())
                    if mode == 'timeout':
                        time.sleep(2.3)
                        return
                    if mode == 'load-error':
                        connection.sendall(b'{"status":"error"}\n')
                        return
                    version = 2 if mode == 'protocol-change' else 1
                    connection.sendall((json.dumps({'status':'ready','version':version})+'\n').encode())
                    if mode in ('disconnect', 'protocol-change'):
                        return
                    if mode == 'invalid-json':
                        connection.sendall(b'not json\n')
                        return
                    value = payload['options'][0].split('\t',1)[-1].rstrip('\t')
                    if mode == 'invalid-selection': value = 'unexpected action'
                    result = {'status':'cancelled' if mode == 'cancelled' else 'selected', 'value':value}
                    connection.sendall((json.dumps(result)+'\n').encode())
            worker = threading.Thread(target=respond, daemon=True)
            worker.start()
        try:
            result = subprocess.run([str(SELECTOR), *args], input=options, text=True,
                                    capture_output=True, env=self.env, timeout=8)
            return result, args, options
        finally:
            if worker: worker.join(timeout=4)
            if server: server.close()

    def test_failed_plugin_preserves_stock_arguments_and_stdin(self):
        for mode in ('unavailable','load-error','protocol-change','timeout','disconnect','invalid-json','invalid-selection'):
            with self.subTest(mode=mode):
                result,args,options = self.invoke(mode)
                self.assertEqual(result.returncode,0,result.stderr)
                self.assertEqual(json.loads(result.stdout),{'args':args,'stdin':options})

    def test_new_flags_are_passed_to_stock(self):
        result,args,options = self.invoke('unavailable',['Keybindings','--','--future-option','value'])
        self.assertEqual(json.loads(result.stdout),{'args':args,'stdin':options})

    def test_selection_values_and_cancellation(self):
        for option in ('SUPER + SPACE → Menu "quoted" $(literal)', 'icon\tCTRL + A\tDetailed selection', 'icon\tCTRL + A\t',
                       'CTRL + É → Français 東京', 'CTRL + L → ' + 'long label ' * 1000):
            with self.subTest(option=option):
                result,_,_ = self.invoke('selected',options=option+'\n')
                self.assertEqual(result.returncode,0,result.stderr)
                self.assertEqual(result.stdout,option.split('\t',1)[-1].rstrip('\t')+'\n')
                self.assertEqual(result.stderr,'')
        result,_,_ = self.invoke('cancelled')
        self.assertEqual(result.returncode,1,result.stderr)
        self.assertEqual(result.stdout,'')
        self.assertEqual(result.stderr,'')

    def test_missing_or_unloadable_native_binary_uses_stock(self):
        shimdir = self.root / 'shim'
        shimdir.mkdir()
        shim = shimdir / 'omarchy-menu-select'
        shutil.copy2(Path(__file__).parent.parent / 'plugin/bin/omarchy-menu-select',shim)
        args = ['Keybindings','--','--width','800']
        options = 'CTRL + A → Preserved input\n'
        for missing in (True,False):
            if not missing:
                binary = shimdir / 'omarchy-shortcut-select'
                binary.write_text('#!/bin/sh\nexit 127\n')
                binary.chmod(0o755)
            result = subprocess.run([str(shim),*args],input=options,text=True,capture_output=True,env=self.env,timeout=3)
            self.assertEqual(result.returncode,0,result.stderr)
            self.assertEqual(json.loads(result.stdout),{'args':args,'stdin':options})


if __name__ == '__main__':
    unittest.main()
