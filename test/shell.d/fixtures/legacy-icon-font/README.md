Stock Omarchy icon font from `config/omarchy.ttf` at `babfafa5^`, before fonts moved into the settings package. SHA-256: `e55e67119e82f56f92d90cbf54b7ccc1b2946b32c535a29370439d7ef5215966`.

The migration test uses the real font so it exercises the exact-content guard without mocking `sha256sum`.
