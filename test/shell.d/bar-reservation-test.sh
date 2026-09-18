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
for (const patch of [
  {version:2}, {position:'center'}, {size:-1}, {size:257}, {size:26.5}, {size:'26'},
  {screens:['DP-1','DP-1']}, {screens:[{}]}, {screens:Array(33).fill('DP-1')},
  {screens:['x'.repeat(129)]}, {hidden:'false'}, {ready:1},
  {background:'red'}, {foreground:'<b>text</b>'}
]) assertEqual(parse(encode({...good,...patch})), null, `rejects malformed state ${encode(patch)}`)
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
