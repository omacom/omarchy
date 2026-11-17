<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>GitHub Copilot</title>
  <desc>GitHub Copilot's mark in a terminal window, as Herdr's ram, with hard shadows.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
    <path id="logo" fill-rule="evenodd" d="M3.5 7C4.1 6.4 4.9 6 5.7 6l9.7.1c.8 0 1.6.3 2.2.9l2.6 2.6c.6.6.9 1.4.9 2.2V16c0 .6-.4 1-1 1h-1c0-.1-.1-.2-.1-.3a2.7 2.7 0 1 0-5.3.3h-5.2a2.7 2.7 0 1 0-4.5 0c0 .1-.1.1-.2.1a1.8 1.8 0 0 1-1.8-1.8V11c0-.8.3-1.6.9-2.2.5-.5 1.1-.8 1.7-1zM5.7 8c-.2 0-.4.1-.5.2-.3.3-.4.7-.4 1v4.3c.9-.8 2.1-1.2 3.3-1.2s2.4.5 3.3 1.2V9.9l-5.7-.2h-.6zm9.3 1.1v2.3c.9-.8 2.1-1.3 3.3-1.3s2.4.5 3.3 1.2V10.6c0-.4-.1-.7-.4-1-.3-.3-.6-.4-.9-.5l-5.3-.1zm-8.5 6c-.8 0-1.5.4-1.9 1.2a2.4 2.4 0 1 0 3.8 0 2 2 0 0 0-.6-.7 2 2 0 0 0-1.3-.5zm7.8 0c-.8 0-1.5.4-1.9 1.2a2.4 2.4 0 1 0 3.8 0 2 2 0 0 0-.6-.7 2 2 0 0 0-1.3-.5z"/>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The window; one hard shadow, as Hype's slides. -->
    <rect x="76" y="92" width="360" height="328" rx="22" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="76" y="92" width="360" height="328" rx="22" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <g transform="translate(124 124) scale(11)">
      <use href="#logo" fill="{{ icon_shadow }}" transform="translate(0 0.7273)"/>
      <use href="#logo" fill="url(#main)"/>
    </g>
  </g>
</svg>
