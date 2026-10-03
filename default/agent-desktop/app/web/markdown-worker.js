import { marked } from './vendor/marked.js';
self.onmessage = ({ data: { id, text } }) => {
  try { self.postMessage({ id, html: marked.parse(text, { gfm: true, breaks: false }) }); }
  catch { self.postMessage({ id, error: 'Could not render this message.' }); }
};
