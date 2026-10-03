#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const { parse, append } = requireFromRoot('shell/bar-reservation/State.js')
const good = { version: 1, screens: ['DP-1', 'eDP-1'], position: 'top', size: 26,
  hidden: false, ready: true, background: '#123456', foreground: '#abcdef' }
const encode = value => JSON.stringify(value)
for (const position of ['top', 'bottom', 'left', 'right']) {
  const next = parse(encode({ ...good, position }))
  assertEqual(next.position, position, `accepts the ${position} bar edge`)
}
assertEqual(parse(encode({version:1,loading:true})).loading, true, 'loading keeps the previous reservation')
assertEqual(parse(encode({...good,hidden:true})).hidden, true, 'hidden state is explicit')
assertEqual(parse(encode({...good,screens:[],size:0})).size, 0, 'replacement bars can release all reservations')
assertEqual(parse(encode({...good,size:300})).size, 300, 'custom bar sizes above 256 retain reservations')
assertEqual(parse(encode({...good,size:2147483647})).size, 2147483647, 'accepts the native signed integer boundary')
for (const patch of [
  {version:2}, {position:'center'}, {size:-1}, {size:2147483648}, {size:26.5}, {size:'26'},
  {client:1}, {client:'not-a-launcher-token'},
  {screens:['DP-1','DP-1']}, {screens:[{}]}, {screens:Array(33).fill('DP-1')},
  {screens:['x'.repeat(129)]}, {hidden:'false'}, {ready:1},
  {background:'red'}, {foreground:'<b>text</b>'}
]) assertEqual(parse(encode({...good,...patch})), null, `rejects malformed state ${encode(patch)}`)
assertEqual(parse(encode({...good,client:'12345678-1234-1234-1234-123456789abc'})).client,
  '12345678-1234-1234-1234-123456789abc', 'preserves a launcher token across process replacement')
for (const input of ['', 'null', '{', 'x'.repeat(16385)]) assertEqual(parse(input),null,'rejects invalid or oversized frames')
const next = parse(encode({...good,command:'should not cross',path:'/tmp/not-used'}))
assert(!('command' in next) && !('path' in next), 'keeps only supported scalar display fields')
const framed = encode(good) + '\n'
const first = append('', framed.slice(0,20))
assertEqual(first.lines.length,0,'partial frames are not interpreted')
assertEqual(append(first.pending,framed.slice(20)).lines[0],encode(good),'partial frames reassemble')
assertEqual(append('',framed + framed).lines.length,2,'coalesced frames are separated')
assertEqual(append('','x'.repeat(16385)),null,'unterminated frames are bounded')
assertEqual(append('','x'.repeat(65537)),null,'oversized chunks are rejected')
assertDeepEqual(good.screens, ['DP-1','eDP-1'], 'parsing does not mutate the input state')
JS
