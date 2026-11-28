//! Header: `sysdeps/mips/nptl/bits/struct_mutex.h`

use crate::prelude::*;

pub const fn __PTHREAD_MUTEX_INITIALIZER(__kind: c_int) -> crate::pthread_mutex_t {
    // We don't need the whole complicated `__pthread_mutex_s` definition, just use the
    // offset of the `__kind` field.
    let kind_offset = if cfg!(target_abi = "abi64") {
        4 * size_of::<c_int>()
    } else {
        3 * size_of::<c_int>()
    };

    let size = [0; crate::__SIZEOF_PTHREAD_MUTEX_T];
    let kind_bytes = __kind.to_ne_bytes();
    let repl = u8_slice_cast_char_slice(&kind_bytes);
    let size = replace_array_items(size, repl, kind_offset);
    crate::pthread_mutex_t { size }
}
