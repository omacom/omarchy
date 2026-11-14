<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Foot</title>
  <desc>Foot's logo in the theme's colors: a dark terminal window with a footprint for a prompt in the main color and an underscore cursor in the highlight, each piece with a hard shadow. The footprint is from the foot logo by Lennard Hofmann, CC BY-SA 4.0.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The terminal; one hard shadow, as Hype's slides. -->
    <rect x="84" y="84" width="344" height="344" rx="26" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="84" y="84" width="344" height="344" rx="26" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <!-- The logo's own drawing, laid out on its 96 unit square. -->
    <g transform="translate(84 84) scale(3.5833333) translate(-16 -16)">
      <!-- The footprint, as the prompt. -->
      <g fill="{{ icon_shadow }}" transform="translate(0 2)">
        <g transform="matrix(.85714209 0 0 .85714209 3.4285132 -145.99985)">
          <path d="M37.0057 207.12866c-.9539-.24232-1.8766-.41748-2.7117-.49721-4.1121-.39258-5.433-.0326-7.5067 2.04908-2.8434 2.85385-2.2667 6.90676 1.4644 10.38038 8.0896 7.53109 8.2202 12.581.4808 18.2752-3.1863 2.34409-5.492 7.85321-4.4994 10.73911 1.2501 3.63469 6.0098 5.02447 10.1635 2.97341 3.8964-1.92373 8.3104-8.49971 11.3208-16.36234.2509-.65526.4966-1.31942.7268-1.9912.6909-2.01525 1.2796-4.09527 1.7466-6.17933 1.4109-6.29466 1.0666-11.19321-.9956-14.13789-1.287-1.83788-6.056-4.19923-10.1892-5.24924z"/>
          <g transform="translate(-1890.6933 -335.56903)">
            <ellipse cx="1921.8835" cy="536.06903" rx="3.8097539" ry="4.5"/>
            <ellipse cx="1929.1934" cy="537.56903" rx="2.5" ry="3"/>
            <ellipse cx="1934.6934" cy="540.29291" rx="2" ry="2.2761035"/>
            <ellipse cx="1939.0691" cy="543.35553" rx="1.6242591" ry="1.7864922"/>
            <ellipse cx="1941.3607" cy="547.06903" rx="1.33263" ry="1.5"/>
          </g>
        </g>
      </g>
      <g fill="url(#main)">
        <g transform="matrix(.85714209 0 0 .85714209 3.4285132 -145.99985)">
          <path d="M37.0057 207.12866c-.9539-.24232-1.8766-.41748-2.7117-.49721-4.1121-.39258-5.433-.0326-7.5067 2.04908-2.8434 2.85385-2.2667 6.90676 1.4644 10.38038 8.0896 7.53109 8.2202 12.581.4808 18.2752-3.1863 2.34409-5.492 7.85321-4.4994 10.73911 1.2501 3.63469 6.0098 5.02447 10.1635 2.97341 3.8964-1.92373 8.3104-8.49971 11.3208-16.36234.2509-.65526.4966-1.31942.7268-1.9912.6909-2.01525 1.2796-4.09527 1.7466-6.17933 1.4109-6.29466 1.0666-11.19321-.9956-14.13789-1.287-1.83788-6.056-4.19923-10.1892-5.24924z"/>
          <g transform="translate(-1890.6933 -335.56903)">
            <ellipse cx="1921.8835" cy="536.06903" rx="3.8097539" ry="4.5"/>
            <ellipse cx="1929.1934" cy="537.56903" rx="2.5" ry="3"/>
            <ellipse cx="1934.6934" cy="540.29291" rx="2" ry="2.2761035"/>
            <ellipse cx="1939.0691" cy="543.35553" rx="1.6242591" ry="1.7864922"/>
            <ellipse cx="1941.3607" cy="547.06903" rx="1.33263" ry="1.5"/>
          </g>
        </g>
      </g>
      <!-- The cursor. -->
      <rect x="48" y="63" width="22" height="5" rx="2.5" fill="{{ icon_shadow }}" transform="translate(0 2)"/>
      <rect x="48" y="63" width="22" height="5" rx="2.5" fill="{{ icon_mark }}"/>
    </g>
  </g>
</svg>
