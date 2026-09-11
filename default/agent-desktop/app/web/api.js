export async function api(path, body) {
  const response = await fetch(path, { ...(body ? { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) } : {}),
    cache: 'no-store', signal: AbortSignal.timeout(30000) });
  const value = await response.json();
  if (!response.ok) throw new Error(value.error || 'Request failed.');
  return value;
}
export function native(message) {
  if (window.webkit?.messageHandlers?.native) window.webkit.messageHandlers.native.postMessage(JSON.stringify(message));
  else if (message.type === 'overview') location.href = './';
  else if (message.type === 'chat') window.open(`chat.html?id=${encodeURIComponent(message.id)}`, '_blank');
}
