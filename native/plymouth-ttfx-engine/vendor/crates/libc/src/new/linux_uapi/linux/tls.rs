//! Header: `uapi/linux/tls.h`

use crate::prelude::*;
use crate::{
    __u16,
    __u8,
};

pub const TLS_TX: c_int = 1;
pub const TLS_RX: c_int = 2;
pub const TLS_TX_ZEROCOPY_RO: c_int = 3;
pub const TLS_RX_EXPECT_NO_PAD: c_int = 4;

pub const TLS_1_2_VERSION_MAJOR: __u8 = 0x3;
pub const TLS_1_2_VERSION_MINOR: __u8 = 0x3;
pub const TLS_1_2_VERSION: __u16 =
    ((TLS_1_2_VERSION_MAJOR as __u16) << 8) | (TLS_1_2_VERSION_MINOR as __u16);

pub const TLS_1_3_VERSION_MAJOR: __u8 = 0x3;
pub const TLS_1_3_VERSION_MINOR: __u8 = 0x4;
pub const TLS_1_3_VERSION: __u16 =
    ((TLS_1_3_VERSION_MAJOR as __u16) << 8) | (TLS_1_3_VERSION_MINOR as __u16);

pub const TLS_CIPHER_AES_GCM_128: __u16 = 51;
pub const TLS_CIPHER_AES_GCM_128_IV_SIZE: usize = 8;
pub const TLS_CIPHER_AES_GCM_128_KEY_SIZE: usize = 16;
pub const TLS_CIPHER_AES_GCM_128_SALT_SIZE: usize = 4;
pub const TLS_CIPHER_AES_GCM_128_TAG_SIZE: usize = 16;
pub const TLS_CIPHER_AES_GCM_128_REC_SEQ_SIZE: usize = 8;

pub const TLS_CIPHER_AES_GCM_256: __u16 = 52;
pub const TLS_CIPHER_AES_GCM_256_IV_SIZE: usize = 8;
pub const TLS_CIPHER_AES_GCM_256_KEY_SIZE: usize = 32;
pub const TLS_CIPHER_AES_GCM_256_SALT_SIZE: usize = 4;
pub const TLS_CIPHER_AES_GCM_256_TAG_SIZE: usize = 16;
pub const TLS_CIPHER_AES_GCM_256_REC_SEQ_SIZE: usize = 8;

pub const TLS_CIPHER_AES_CCM_128: __u16 = 53;
pub const TLS_CIPHER_AES_CCM_128_IV_SIZE: usize = 8;
pub const TLS_CIPHER_AES_CCM_128_KEY_SIZE: usize = 16;
pub const TLS_CIPHER_AES_CCM_128_SALT_SIZE: usize = 4;
pub const TLS_CIPHER_AES_CCM_128_TAG_SIZE: usize = 16;
pub const TLS_CIPHER_AES_CCM_128_REC_SEQ_SIZE: usize = 8;

pub const TLS_CIPHER_CHACHA20_POLY1305: __u16 = 54;
pub const TLS_CIPHER_CHACHA20_POLY1305_IV_SIZE: usize = 12;
pub const TLS_CIPHER_CHACHA20_POLY1305_KEY_SIZE: usize = 32;
pub const TLS_CIPHER_CHACHA20_POLY1305_SALT_SIZE: usize = 0;
pub const TLS_CIPHER_CHACHA20_POLY1305_TAG_SIZE: usize = 16;
pub const TLS_CIPHER_CHACHA20_POLY1305_REC_SEQ_SIZE: usize = 8;

pub const TLS_CIPHER_SM4_GCM: __u16 = 55;
pub const TLS_CIPHER_SM4_GCM_IV_SIZE: usize = 8;
pub const TLS_CIPHER_SM4_GCM_KEY_SIZE: usize = 16;
pub const TLS_CIPHER_SM4_GCM_SALT_SIZE: usize = 4;
pub const TLS_CIPHER_SM4_GCM_TAG_SIZE: usize = 16;
pub const TLS_CIPHER_SM4_GCM_REC_SEQ_SIZE: usize = 8;

pub const TLS_CIPHER_SM4_CCM: __u16 = 56;
pub const TLS_CIPHER_SM4_CCM_IV_SIZE: usize = 8;
pub const TLS_CIPHER_SM4_CCM_KEY_SIZE: usize = 16;
pub const TLS_CIPHER_SM4_CCM_SALT_SIZE: usize = 4;
pub const TLS_CIPHER_SM4_CCM_TAG_SIZE: usize = 16;
pub const TLS_CIPHER_SM4_CCM_REC_SEQ_SIZE: usize = 8;

pub const TLS_CIPHER_ARIA_GCM_128: __u16 = 57;
pub const TLS_CIPHER_ARIA_GCM_128_IV_SIZE: usize = 8;
pub const TLS_CIPHER_ARIA_GCM_128_KEY_SIZE: usize = 16;
pub const TLS_CIPHER_ARIA_GCM_128_SALT_SIZE: usize = 4;
pub const TLS_CIPHER_ARIA_GCM_128_TAG_SIZE: usize = 16;
pub const TLS_CIPHER_ARIA_GCM_128_REC_SEQ_SIZE: usize = 8;

pub const TLS_CIPHER_ARIA_GCM_256: __u16 = 58;
pub const TLS_CIPHER_ARIA_GCM_256_IV_SIZE: usize = 8;
pub const TLS_CIPHER_ARIA_GCM_256_KEY_SIZE: usize = 32;
pub const TLS_CIPHER_ARIA_GCM_256_SALT_SIZE: usize = 4;
pub const TLS_CIPHER_ARIA_GCM_256_TAG_SIZE: usize = 16;
pub const TLS_CIPHER_ARIA_GCM_256_REC_SEQ_SIZE: usize = 8;

pub const TLS_SET_RECORD_TYPE: c_int = 1;
pub const TLS_GET_RECORD_TYPE: c_int = 2;

s! {
    pub struct tls_crypto_info {
        pub version: __u16,
        pub cipher_type: __u16,
    }

    pub struct tls12_crypto_info_aes_gcm_128 {
        pub info: tls_crypto_info,
        pub iv: [c_uchar; TLS_CIPHER_AES_GCM_128_IV_SIZE],
        pub key: [c_uchar; TLS_CIPHER_AES_GCM_128_KEY_SIZE],
        pub salt: [c_uchar; TLS_CIPHER_AES_GCM_128_SALT_SIZE],
        pub rec_seq: [c_uchar; TLS_CIPHER_AES_GCM_128_REC_SEQ_SIZE],
    }

    pub struct tls12_crypto_info_aes_gcm_256 {
        pub info: tls_crypto_info,
        pub iv: [c_uchar; TLS_CIPHER_AES_GCM_256_IV_SIZE],
        pub key: [c_uchar; TLS_CIPHER_AES_GCM_256_KEY_SIZE],
        pub salt: [c_uchar; TLS_CIPHER_AES_GCM_256_SALT_SIZE],
        pub rec_seq: [c_uchar; TLS_CIPHER_AES_GCM_256_REC_SEQ_SIZE],
    }

    pub struct tls12_crypto_info_aes_ccm_128 {
        pub info: tls_crypto_info,
        pub iv: [c_uchar; TLS_CIPHER_AES_CCM_128_IV_SIZE],
        pub key: [c_uchar; TLS_CIPHER_AES_CCM_128_KEY_SIZE],
        pub salt: [c_uchar; TLS_CIPHER_AES_CCM_128_SALT_SIZE],
        pub rec_seq: [c_uchar; TLS_CIPHER_AES_CCM_128_REC_SEQ_SIZE],
    }

    pub struct tls12_crypto_info_chacha20_poly1305 {
        pub info: tls_crypto_info,
        pub iv: [c_uchar; TLS_CIPHER_CHACHA20_POLY1305_IV_SIZE],
        pub key: [c_uchar; TLS_CIPHER_CHACHA20_POLY1305_KEY_SIZE],
        pub salt: [c_uchar; TLS_CIPHER_CHACHA20_POLY1305_SALT_SIZE],
        pub rec_seq: [c_uchar; TLS_CIPHER_CHACHA20_POLY1305_REC_SEQ_SIZE],
    }

    pub struct tls12_crypto_info_sm4_gcm {
        pub info: tls_crypto_info,
        pub iv: [c_uchar; TLS_CIPHER_SM4_GCM_IV_SIZE],
        pub key: [c_uchar; TLS_CIPHER_SM4_GCM_KEY_SIZE],
        pub salt: [c_uchar; TLS_CIPHER_SM4_GCM_SALT_SIZE],
        pub rec_seq: [c_uchar; TLS_CIPHER_SM4_GCM_REC_SEQ_SIZE],
    }

    pub struct tls12_crypto_info_sm4_ccm {
        pub info: tls_crypto_info,
        pub iv: [c_uchar; TLS_CIPHER_SM4_CCM_IV_SIZE],
        pub key: [c_uchar; TLS_CIPHER_SM4_CCM_KEY_SIZE],
        pub salt: [c_uchar; TLS_CIPHER_SM4_CCM_SALT_SIZE],
        pub rec_seq: [c_uchar; TLS_CIPHER_SM4_CCM_REC_SEQ_SIZE],
    }

    pub struct tls12_crypto_info_aria_gcm_128 {
        pub info: tls_crypto_info,
        pub iv: [c_uchar; TLS_CIPHER_ARIA_GCM_128_IV_SIZE],
        pub key: [c_uchar; TLS_CIPHER_ARIA_GCM_128_KEY_SIZE],
        pub salt: [c_uchar; TLS_CIPHER_ARIA_GCM_128_SALT_SIZE],
        pub rec_seq: [c_uchar; TLS_CIPHER_ARIA_GCM_128_REC_SEQ_SIZE],
    }

    pub struct tls12_crypto_info_aria_gcm_256 {
        pub info: tls_crypto_info,
        pub iv: [c_uchar; TLS_CIPHER_ARIA_GCM_256_IV_SIZE],
        pub key: [c_uchar; TLS_CIPHER_ARIA_GCM_256_KEY_SIZE],
        pub salt: [c_uchar; TLS_CIPHER_ARIA_GCM_256_SALT_SIZE],
        pub rec_seq: [c_uchar; TLS_CIPHER_ARIA_GCM_256_REC_SEQ_SIZE],
    }
}

c_enum! {
    // FIXME(1.0): This is an i32 in `libc` but enum reprs are `u32`.
    #[repr(c_int)]
    pub enum #anon {
        pub TLS_INFO_UNSPEC,
        pub TLS_INFO_VERSION,
        pub TLS_INFO_CIPHER,
        pub TLS_INFO_TXCONF,
        pub TLS_INFO_RXCONF,
        pub TLS_INFO_ZC_RO_TX,
        pub TLS_INFO_RX_NO_PAD,
        pub TLS_INFO_TX_MAX_PAYLOAD_LEN,
        __TLS_INFO_MAX,
    }
}

/// Constants may change across releases. See the [usage guidelines](crate#usage-guidelines)
/// for details.
pub const TLS_INFO_MAX: c_int = __TLS_INFO_MAX - 1;

pub const TLS_CONF_BASE: c_int = 1;
pub const TLS_CONF_SW: c_int = 2;
pub const TLS_CONF_HW: c_int = 3;
pub const TLS_CONF_HW_RECORD: c_int = 4;
