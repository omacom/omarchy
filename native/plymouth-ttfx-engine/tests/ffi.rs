use std::ffi::CString;
use std::ptr;

use ttfx_plymouth::{
    ttfx_engine_begin_reverse, ttfx_engine_cells, ttfx_engine_create, ttfx_engine_draw_logo,
    ttfx_engine_free, ttfx_engine_record_history, ttfx_engine_reset, ttfx_engine_step, Cell,
    TtfxEngine, TTFX_STATUS_INPUT_TOO_LARGE, TTFX_STATUS_INVALID_ARGUMENT,
    TTFX_STATUS_INVALID_EFFECT, TTFX_STATUS_INVALID_STATE, TTFX_STATUS_INVALID_UTF8,
    TTFX_STATUS_OK, TTFX_STATUS_UNAVAILABLE,
};

#[test]
fn c_abi_create_immediately_exposes_a_complete_real_frame() {
    let effect = CString::new("decrypt").unwrap();
    let input = include_bytes!("../../../logo.txt");
    let mut handle: *mut TtfxEngine = ptr::null_mut();

    assert_eq!(
        unsafe {
            ttfx_engine_create(
                effect.as_ptr(),
                0x4f4d4152434859,
                input.as_ptr(),
                input.len(),
                81,
                10,
                30,
                &mut handle,
            )
        },
        TTFX_STATUS_OK
    );
    assert!(!handle.is_null());

    let mut cells: *const Cell = ptr::null();
    let mut count = 0usize;
    let mut width = 0u32;
    let mut height = 0u32;
    assert_eq!(
        unsafe { ttfx_engine_cells(handle, &mut cells, &mut count, &mut width, &mut height) },
        TTFX_STATUS_OK
    );
    assert!(!cells.is_null());
    assert_eq!((count, width, height), (81 * 10, 81, 10));

    unsafe { ttfx_engine_free(handle) };
}

#[test]
fn c_abi_owns_an_opaque_handle_and_borrows_a_full_snapshot() {
    let effect = CString::new("print").unwrap();
    let input = "Plymouth λ";
    let mut handle: *mut TtfxEngine = ptr::null_mut();
    assert_eq!(
        unsafe {
            ttfx_engine_create(
                effect.as_ptr(),
                99,
                input.as_ptr(),
                input.len(),
                16,
                3,
                60,
                &mut handle,
            )
        },
        TTFX_STATUS_OK
    );
    assert!(!handle.is_null());

    let mut looped = 9u8;
    assert_eq!(
        unsafe { ttfx_engine_step(handle, &mut looped) },
        TTFX_STATUS_OK
    );
    assert_eq!(looped, 0);

    let mut cells: *const Cell = ptr::null();
    let mut count = 0usize;
    let mut width = 0u32;
    let mut height = 0u32;
    assert_eq!(
        unsafe { ttfx_engine_cells(handle, &mut cells, &mut count, &mut width, &mut height) },
        TTFX_STATUS_OK
    );
    assert!(!cells.is_null());
    assert_eq!((count, width, height), (48, 16, 3));
    let snapshot = unsafe { std::slice::from_raw_parts(cells, count) };
    assert!(snapshot.iter().any(|cell| cell.codepoint != u32::from(' ')));

    unsafe { ttfx_engine_free(handle) };
    unsafe { ttfx_engine_free(ptr::null_mut()) };
}

#[test]
fn c_abi_reset_restores_the_first_frame() {
    let effect = CString::new("print").unwrap();
    let input = b"Reset me";
    let mut handle: *mut TtfxEngine = ptr::null_mut();
    assert_eq!(
        unsafe {
            ttfx_engine_create(
                effect.as_ptr(),
                0x55aa,
                input.as_ptr(),
                input.len(),
                12,
                2,
                60,
                &mut handle,
            )
        },
        TTFX_STATUS_OK
    );
    let first = snapshot(handle);
    let mut looped = 0;
    assert_eq!(
        unsafe { ttfx_engine_step(handle, &mut looped) },
        TTFX_STATUS_OK
    );
    assert_ne!(snapshot(handle), first);

    assert_eq!(unsafe { ttfx_engine_reset(handle) }, TTFX_STATUS_OK);
    assert_eq!(snapshot(handle), first);
    assert_eq!(
        unsafe { ttfx_engine_reset(ptr::null_mut()) },
        TTFX_STATUS_INVALID_ARGUMENT
    );

    unsafe { ttfx_engine_free(handle) };
}

fn snapshot(handle: *mut TtfxEngine) -> Vec<Cell> {
    let mut cells = ptr::null();
    let mut count = 0;
    let mut width = 0;
    let mut height = 0;
    assert_eq!(
        unsafe { ttfx_engine_cells(handle, &mut cells, &mut count, &mut width, &mut height) },
        TTFX_STATUS_OK
    );
    unsafe { std::slice::from_raw_parts(cells, count) }.to_vec()
}

#[test]
fn c_abi_rejects_nulls_invalid_utf8_and_unterminated_effect_names() {
    let effect = CString::new("print").unwrap();
    let mut handle: *mut TtfxEngine = ptr::null_mut();
    assert_eq!(
        unsafe { ttfx_engine_step(ptr::null_mut(), ptr::null_mut()) },
        TTFX_STATUS_INVALID_ARGUMENT
    );
    assert_eq!(
        unsafe {
            ttfx_engine_create(
                effect.as_ptr(),
                1,
                [0xffu8].as_ptr(),
                1,
                8,
                2,
                60,
                &mut handle,
            )
        },
        TTFX_STATUS_INVALID_UTF8
    );
    assert!(handle.is_null());

    let mut unterminated = [b'x' as std::ffi::c_char; ttfx_plymouth::MAX_EFFECT_NAME_BYTES];
    assert_eq!(
        unsafe {
            ttfx_engine_create(
                unterminated.as_mut_ptr(),
                1,
                b"x".as_ptr(),
                1,
                8,
                2,
                60,
                &mut handle,
            )
        },
        TTFX_STATUS_INVALID_ARGUMENT
    );
    assert!(handle.is_null());
}

#[test]
fn reserved_looking_effect_name_is_not_magic_production_behavior() {
    let effect = CString::new("__panic__").unwrap();
    let mut handle: *mut TtfxEngine = ptr::null_mut();
    assert_eq!(
        unsafe { ttfx_engine_create(effect.as_ptr(), 1, b"x".as_ptr(), 1, 8, 2, 60, &mut handle,) },
        TTFX_STATUS_INVALID_EFFECT
    );
    assert!(handle.is_null());
}

#[test]
fn c_abi_rejects_oversized_input_before_reading_or_allocating_it() {
    let effect = CString::new("print").unwrap();
    let mut handle: *mut TtfxEngine = ptr::null_mut();

    assert_eq!(
        unsafe {
            ttfx_engine_create(
                effect.as_ptr(),
                1,
                std::ptr::NonNull::<u8>::dangling().as_ptr(),
                ttfx_plymouth::MAX_INPUT_BYTES + 1,
                8,
                2,
                60,
                &mut handle,
            )
        },
        TTFX_STATUS_INPUT_TOO_LARGE
    );
    assert!(handle.is_null());
}

#[test]
fn c_abi_records_history_and_plays_the_reverse_to_the_blank_canvas() {
    let effect = CString::new("decrypt").unwrap();
    let input = include_bytes!("../../plymouth-ttfx-plugin/embedded-logo-v2.txt");
    let mut handle: *mut TtfxEngine = ptr::null_mut();
    assert_eq!(
        unsafe {
            ttfx_engine_create(
                effect.as_ptr(),
                22321466108495961,
                input.as_ptr(),
                input.len(),
                162,
                20,
                240,
                &mut handle,
            )
        },
        TTFX_STATUS_OK
    );
    let mut calls = 7u32;
    assert_eq!(
        unsafe { ttfx_engine_begin_reverse(handle, 168, 2, &mut calls) },
        TTFX_STATUS_UNAVAILABLE
    );
    assert_eq!(calls, 0);
    assert_eq!(
        unsafe { ttfx_engine_begin_reverse(handle, 168, 2, ptr::null_mut()) },
        TTFX_STATUS_INVALID_ARGUMENT
    );
    assert_eq!(
        unsafe { ttfx_engine_record_history(ptr::null_mut(), 128, 4 << 20) },
        TTFX_STATUS_INVALID_ARGUMENT
    );
    assert_eq!(
        unsafe { ttfx_engine_record_history(handle, 128, 4 << 20) },
        TTFX_STATUS_OK
    );
    for _ in 0..400 {
        let mut finished = 0u8;
        assert_eq!(
            unsafe { ttfx_engine_draw_logo(handle, 1, ptr::null_mut(), &mut finished) },
            TTFX_STATUS_OK
        );
        assert_eq!(finished, 0);
    }
    assert_eq!(
        unsafe { ttfx_engine_begin_reverse(handle, 168, 2, &mut calls) },
        TTFX_STATUS_OK
    );
    assert!((2..=168).contains(&calls));
    assert_eq!(
        unsafe { ttfx_engine_draw_logo(handle, 1, ptr::null_mut(), ptr::null_mut()) },
        TTFX_STATUS_INVALID_STATE
    );
    for call in 1..=calls {
        let mut looped = 9u8;
        let mut finished = 9u8;
        assert_eq!(
            unsafe { ttfx_engine_draw_logo(handle, 2, &mut looped, &mut finished) },
            TTFX_STATUS_OK
        );
        assert_eq!(looped, 0);
        assert_eq!(finished, u8::from(call == calls), "call {call} of {calls}");
    }
    let mut cells: *const Cell = ptr::null();
    let mut count = 0usize;
    let mut width = 0u32;
    let mut height = 0u32;
    assert_eq!(
        unsafe { ttfx_engine_cells(handle, &mut cells, &mut count, &mut width, &mut height) },
        TTFX_STATUS_OK
    );
    let cells = unsafe { std::slice::from_raw_parts(cells, count) };
    assert!(cells
        .iter()
        .all(|cell| cell.codepoint == 0x20 && cell.flags == 0 && cell.fg_rgba == 0 && cell.bg_rgba == 0));
    assert_eq!(unsafe { ttfx_engine_reset(handle) }, TTFX_STATUS_OK);
    let mut finished = 9u8;
    assert_eq!(
        unsafe { ttfx_engine_draw_logo(handle, 1, ptr::null_mut(), &mut finished) },
        TTFX_STATUS_OK
    );
    unsafe { ttfx_engine_free(handle) };
}
