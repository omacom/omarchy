export async function api(path, body) {
  const response = await fetch(path, {
    ...(body ? { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) } : {}),
    cache: 'no-store', signal: AbortSignal.timeout(body ? 30000 : 8000)
  });
  let value;
  try { value = await response.json(); } catch { value = {}; }
  if (!response.ok) throw new Error(value.error || 'Desktop service unreachable.');
  return value;
}
