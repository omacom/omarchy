//! FxHash: keys here are small integers and short strings, hashed on
//! build-time hot paths, where SipHash's DoS resistance buys nothing.

use std::hash::BuildHasherDefault;

#[derive(Default, Clone, Copy)]
pub struct FxHasher(u64);

impl std::hash::Hasher for FxHasher {
    #[inline]
    fn write(&mut self, bytes: &[u8]) {
        let mut chunks = bytes.chunks_exact(8);
        for chunk in &mut chunks {
            self.write_u64(u64::from_le_bytes(chunk.try_into().unwrap()));
        }
        let rest = chunks.remainder();
        if !rest.is_empty() {
            let mut word = [0u8; 8];
            word[..rest.len()].copy_from_slice(rest);
            self.write_u64(u64::from_le_bytes(word) ^ (rest.len() as u64) << 59);
        }
    }
    #[inline]
    fn write_u64(&mut self, word: u64) {
        self.0 = (self.0.rotate_left(5) ^ word).wrapping_mul(0x51_7c_c1_b7_27_22_0a_95);
    }
    #[inline]
    fn write_u32(&mut self, word: u32) {
        self.write_u64(word as u64);
    }
    #[inline]
    fn write_u16(&mut self, word: u16) {
        self.write_u64(word as u64);
    }
    #[inline]
    fn write_u8(&mut self, byte: u8) {
        self.write_u64(byte as u64);
    }
    #[inline]
    fn write_usize(&mut self, word: usize) {
        self.write_u64(word as u64);
    }
    #[inline]
    fn write_i64(&mut self, word: i64) {
        self.write_u64(word as u64);
    }
    #[inline]
    fn finish(&self) -> u64 {
        self.0
    }
}

pub type FxBuild = BuildHasherDefault<FxHasher>;
