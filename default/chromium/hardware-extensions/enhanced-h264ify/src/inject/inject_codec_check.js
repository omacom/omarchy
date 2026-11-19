/**
 * The MIT License (MIT)
 *
 * Copyright (c) 2019 alextrv
 * Copyright (c) 2015 erkserkserks
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

function override() {
  // Override video element canPlayType() function
  var videoElem = document.createElement('video');
  var origCanPlayType = videoElem.canPlayType.bind(videoElem);
  videoElem.__proto__.canPlayType = makeModifiedTypeChecker(origCanPlayType);

  // Override media source extension isTypeSupported() function
  var mse = window.MediaSource;
  // Check for MSE support before use
  if (mse === undefined) return;
  var origIsTypeSupported = mse.isTypeSupported.bind(mse);
  mse.isTypeSupported = makeModifiedTypeChecker(origIsTypeSupported);
}

// return a custom MIME type checker that can defer to the original function
function makeModifiedTypeChecker(origChecker) {
  // Check if a video type is allowed
  return function (type) {
    if (type === undefined) return '';
    var disallowed_types = [];
    if (localStorage['enhanced-h264ify-block_h264'] === 'true') {
      disallowed_types.push('avc');
    }
    if (localStorage['enhanced-h264ify-block_vp8'] === 'true') {
      disallowed_types.push('vp8');
    }
    if (localStorage['enhanced-h264ify-block_vp9'] === 'true') {
      disallowed_types.push('vp9', 'vp09');
    }
    if (localStorage['enhanced-h264ify-block_av1'] === 'true') {
      disallowed_types.push('av01', 'av99');
    }
    if (localStorage['enhanced-h264ify-block_opus'] === 'true') {
      disallowed_types.push('opus');
    }
    if (localStorage['enhanced-h264ify-block_mp4a'] === 'true') {
      disallowed_types.push('mp4a');
    }

    // If video type is in disallowed_types, say we don't support them
    for (var i = 0; i < disallowed_types.length; i++) {
      if (type.indexOf(disallowed_types[i]) !== -1) return '';
    }

    if (localStorage['enhanced-h264ify-block_60fps'] === 'true') {
      var match = /framerate=(\d+)/.exec(type);
      if (match && match[1] > 30) return '';
    }

    // Otherwise, ask the browser
    return origChecker(type);
  };
}

override();
