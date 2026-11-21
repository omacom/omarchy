use core::ffi::c_void;
use core::mem::size_of;

extern "C" {
    /// <https://github.com/gcc-mirror/gcc/blob/28219f7f99a80519d1c6ab5e5dc83b4c7f8d7251/libsanitizer/include/sanitizer/msan_interface.h#L40>
    #[link_name = "__msan_unpoison"]
    pub(crate) fn unpoison(a: *const c_void, size: usize);
}

pub(crate) fn unpoison_maybe_uninit<T>(t: &MaybeUninit<T>) {
    unpoison(t.as_ptr(), size_of::<T>())
}
