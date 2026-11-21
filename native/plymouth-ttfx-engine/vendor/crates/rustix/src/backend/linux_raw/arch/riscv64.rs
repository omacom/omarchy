//! riscv64 Linux system calls.
//!
//! Syscalls do not preserve vector registers.
//! <https://docs.kernel.org/arch/riscv/vector.html#vector-register-state-across-system-calls>

use crate::backend::reg::{
    ArgReg, FromAsm, RetReg, SyscallNumber, ToAsm as _, A0, A1, A2, A3, A4, A5, R0,
};
use core::arch::asm;

#[inline]
pub(in crate::backend) unsafe fn syscall0_readonly(nr: SyscallNumber<'_>) -> RetReg<R0> {
    let r0;
    asm!(
        "ecall",
        in("a7") nr.to_asm(),
        lateout("a0") r0,
        lateout("v0") _,
        lateout("v1") _,
        lateout("v2") _,
        lateout("v3") _,
        lateout("v4") _,
        lateout("v5") _,
        lateout("v6") _,
        lateout("v7") _,
        lateout("v8") _,
        lateout("v9") _,
        lateout("v10") _,
        lateout("v11") _,
        lateout("v12") _,
        lateout("v13") _,
        lateout("v14") _,
        lateout("v15") _,
        lateout("v16") _,
        lateout("v17") _,
        lateout("v18") _,
        lateout("v19") _,
        lateout("v20") _,
        lateout("v21") _,
        lateout("v22") _,
        lateout("v23") _,
        lateout("v24") _,
        lateout("v25") _,
        lateout("v26") _,
        lateout("v27") _,
        lateout("v28") _,
        lateout("v29") _,
        lateout("v30") _,
        lateout("v31") _,
        options(nostack, readonly)
    );
    FromAsm::from_asm(r0)
}

#[inline]
pub(in crate::backend) unsafe fn syscall1(nr: SyscallNumber<'_>, a0: ArgReg<'_, A0>) -> RetReg<R0> {
    let r0;
    asm!(
        "ecall",
        in("a7") nr.to_asm(),
        inlateout("a0") a0.to_asm() => r0,
        lateout("v0") _,
        lateout("v1") _,
        lateout("v2") _,
        lateout("v3") _,
        lateout("v4") _,
        lateout("v5") _,
        lateout("v6") _,
        lateout("v7") _,
        lateout("v8") _,
        lateout("v9") _,
        lateout("v10") _,
        lateout("v11") _,
        lateout("v12") _,
        lateout("v13") _,
        lateout("v14") _,
        lateout("v15") _,
        lateout("v16") _,
        lateout("v17") _,
        lateout("v18") _,
        lateout("v19") _,
        lateout("v20") _,
        lateout("v21") _,
        lateout("v22") _,
        lateout("v23") _,
        lateout("v24") _,
        lateout("v25") _,
        lateout("v26") _,
        lateout("v27") _,
        lateout("v28") _,
        lateout("v29") _,
        lateout("v30") _,
        lateout("v31") _,
        options(nostack)
    );
    FromAsm::from_asm(r0)
}

#[inline]
pub(in crate::backend) unsafe fn syscall1_readonly(
    nr: SyscallNumber<'_>,
    a0: ArgReg<'_, A0>,
) -> RetReg<R0> {
    let r0;
    asm!(
        "ecall",
        in("a7") nr.to_asm(),
        inlateout("a0") a0.to_asm() => r0,
        lateout("v0") _,
        lateout("v1") _,
        lateout("v2") _,
        lateout("v3") _,
        lateout("v4") _,
        lateout("v5") _,
        lateout("v6") _,
        lateout("v7") _,
        lateout("v8") _,
        lateout("v9") _,
        lateout("v10") _,
        lateout("v11") _,
        lateout("v12") _,
        lateout("v13") _,
        lateout("v14") _,
        lateout("v15") _,
        lateout("v16") _,
        lateout("v17") _,
        lateout("v18") _,
        lateout("v19") _,
        lateout("v20") _,
        lateout("v21") _,
        lateout("v22") _,
        lateout("v23") _,
        lateout("v24") _,
        lateout("v25") _,
        lateout("v26") _,
        lateout("v27") _,
        lateout("v28") _,
        lateout("v29") _,
        lateout("v30") _,
        lateout("v31") _,
        options(nostack, readonly)
    );
    FromAsm::from_asm(r0)
}

#[inline]
pub(in crate::backend) unsafe fn syscall1_noreturn(nr: SyscallNumber<'_>, a0: ArgReg<'_, A0>) -> ! {
    asm!(
        "ecall",
        "unimp",
        in("a7") nr.to_asm(),
        in("a0") a0.to_asm(),
        options(nostack, noreturn)
    );
}

#[inline]
pub(in crate::backend) unsafe fn syscall2(
    nr: SyscallNumber<'_>,
    a0: ArgReg<'_, A0>,
    a1: ArgReg<'_, A1>,
) -> RetReg<R0> {
    let r0;
    asm!(
        "ecall",
        in("a7") nr.to_asm(),
        inlateout("a0") a0.to_asm() => r0,
        in("a1") a1.to_asm(),
        lateout("v0") _,
        lateout("v1") _,
        lateout("v2") _,
        lateout("v3") _,
        lateout("v4") _,
        lateout("v5") _,
        lateout("v6") _,
        lateout("v7") _,
        lateout("v8") _,
        lateout("v9") _,
        lateout("v10") _,
        lateout("v11") _,
        lateout("v12") _,
        lateout("v13") _,
        lateout("v14") _,
        lateout("v15") _,
        lateout("v16") _,
        lateout("v17") _,
        lateout("v18") _,
        lateout("v19") _,
        lateout("v20") _,
        lateout("v21") _,
        lateout("v22") _,
        lateout("v23") _,
        lateout("v24") _,
        lateout("v25") _,
        lateout("v26") _,
        lateout("v27") _,
        lateout("v28") _,
        lateout("v29") _,
        lateout("v30") _,
        lateout("v31") _,
        options(nostack)
    );
    FromAsm::from_asm(r0)
}

#[inline]
pub(in crate::backend) unsafe fn syscall2_readonly(
    nr: SyscallNumber<'_>,
    a0: ArgReg<'_, A0>,
    a1: ArgReg<'_, A1>,
) -> RetReg<R0> {
    let r0;
    asm!(
        "ecall",
        in("a7") nr.to_asm(),
        inlateout("a0") a0.to_asm() => r0,
        in("a1") a1.to_asm(),
        lateout("v0") _,
        lateout("v1") _,
        lateout("v2") _,
        lateout("v3") _,
        lateout("v4") _,
        lateout("v5") _,
        lateout("v6") _,
        lateout("v7") _,
        lateout("v8") _,
        lateout("v9") _,
        lateout("v10") _,
        lateout("v11") _,
        lateout("v12") _,
        lateout("v13") _,
        lateout("v14") _,
        lateout("v15") _,
        lateout("v16") _,
        lateout("v17") _,
        lateout("v18") _,
        lateout("v19") _,
        lateout("v20") _,
        lateout("v21") _,
        lateout("v22") _,
        lateout("v23") _,
        lateout("v24") _,
        lateout("v25") _,
        lateout("v26") _,
        lateout("v27") _,
        lateout("v28") _,
        lateout("v29") _,
        lateout("v30") _,
        lateout("v31") _,
        options(nostack, readonly)
    );
    FromAsm::from_asm(r0)
}

#[inline]
pub(in crate::backend) unsafe fn syscall3(
    nr: SyscallNumber<'_>,
    a0: ArgReg<'_, A0>,
    a1: ArgReg<'_, A1>,
    a2: ArgReg<'_, A2>,
) -> RetReg<R0> {
    let r0;
    asm!(
        "ecall",
        in("a7") nr.to_asm(),
        inlateout("a0") a0.to_asm() => r0,
        in("a1") a1.to_asm(),
        in("a2") a2.to_asm(),
        lateout("v0") _,
        lateout("v1") _,
        lateout("v2") _,
        lateout("v3") _,
        lateout("v4") _,
        lateout("v5") _,
        lateout("v6") _,
        lateout("v7") _,
        lateout("v8") _,
        lateout("v9") _,
        lateout("v10") _,
        lateout("v11") _,
        lateout("v12") _,
        lateout("v13") _,
        lateout("v14") _,
        lateout("v15") _,
        lateout("v16") _,
        lateout("v17") _,
        lateout("v18") _,
        lateout("v19") _,
        lateout("v20") _,
        lateout("v21") _,
        lateout("v22") _,
        lateout("v23") _,
        lateout("v24") _,
        lateout("v25") _,
        lateout("v26") _,
        lateout("v27") _,
        lateout("v28") _,
        lateout("v29") _,
        lateout("v30") _,
        lateout("v31") _,
        options(nostack)
    );
    FromAsm::from_asm(r0)
}

#[inline]
pub(in crate::backend) unsafe fn syscall3_readonly(
    nr: SyscallNumber<'_>,
    a0: ArgReg<'_, A0>,
    a1: ArgReg<'_, A1>,
    a2: ArgReg<'_, A2>,
) -> RetReg<R0> {
    let r0;
    asm!(
        "ecall",
        in("a7") nr.to_asm(),
        inlateout("a0") a0.to_asm() => r0,
        in("a1") a1.to_asm(),
        in("a2") a2.to_asm(),
        lateout("v0") _,
        lateout("v1") _,
        lateout("v2") _,
        lateout("v3") _,
        lateout("v4") _,
        lateout("v5") _,
        lateout("v6") _,
        lateout("v7") _,
        lateout("v8") _,
        lateout("v9") _,
        lateout("v10") _,
        lateout("v11") _,
        lateout("v12") _,
        lateout("v13") _,
        lateout("v14") _,
        lateout("v15") _,
        lateout("v16") _,
        lateout("v17") _,
        lateout("v18") _,
        lateout("v19") _,
        lateout("v20") _,
        lateout("v21") _,
        lateout("v22") _,
        lateout("v23") _,
        lateout("v24") _,
        lateout("v25") _,
        lateout("v26") _,
        lateout("v27") _,
        lateout("v28") _,
        lateout("v29") _,
        lateout("v30") _,
        lateout("v31") _,
        options(nostack, readonly)
    );
    FromAsm::from_asm(r0)
}

#[inline]
pub(in crate::backend) unsafe fn syscall4(
    nr: SyscallNumber<'_>,
    a0: ArgReg<'_, A0>,
    a1: ArgReg<'_, A1>,
    a2: ArgReg<'_, A2>,
    a3: ArgReg<'_, A3>,
) -> RetReg<R0> {
    let r0;
    asm!(
        "ecall",
        in("a7") nr.to_asm(),
        inlateout("a0") a0.to_asm() => r0,
        in("a1") a1.to_asm(),
        in("a2") a2.to_asm(),
        in("a3") a3.to_asm(),
        lateout("v0") _,
        lateout("v1") _,
        lateout("v2") _,
        lateout("v3") _,
        lateout("v4") _,
        lateout("v5") _,
        lateout("v6") _,
        lateout("v7") _,
        lateout("v8") _,
        lateout("v9") _,
        lateout("v10") _,
        lateout("v11") _,
        lateout("v12") _,
        lateout("v13") _,
        lateout("v14") _,
        lateout("v15") _,
        lateout("v16") _,
        lateout("v17") _,
        lateout("v18") _,
        lateout("v19") _,
        lateout("v20") _,
        lateout("v21") _,
        lateout("v22") _,
        lateout("v23") _,
        lateout("v24") _,
        lateout("v25") _,
        lateout("v26") _,
        lateout("v27") _,
        lateout("v28") _,
        lateout("v29") _,
        lateout("v30") _,
        lateout("v31") _,
        options(nostack)
    );
    FromAsm::from_asm(r0)
}

#[inline]
pub(in crate::backend) unsafe fn syscall4_readonly(
    nr: SyscallNumber<'_>,
    a0: ArgReg<'_, A0>,
    a1: ArgReg<'_, A1>,
    a2: ArgReg<'_, A2>,
    a3: ArgReg<'_, A3>,
) -> RetReg<R0> {
    let r0;
    asm!(
        "ecall",
        in("a7") nr.to_asm(),
        inlateout("a0") a0.to_asm() => r0,
        in("a1") a1.to_asm(),
        in("a2") a2.to_asm(),
        in("a3") a3.to_asm(),
        lateout("v0") _,
        lateout("v1") _,
        lateout("v2") _,
        lateout("v3") _,
        lateout("v4") _,
        lateout("v5") _,
        lateout("v6") _,
        lateout("v7") _,
        lateout("v8") _,
        lateout("v9") _,
        lateout("v10") _,
        lateout("v11") _,
        lateout("v12") _,
        lateout("v13") _,
        lateout("v14") _,
        lateout("v15") _,
        lateout("v16") _,
        lateout("v17") _,
        lateout("v18") _,
        lateout("v19") _,
        lateout("v20") _,
        lateout("v21") _,
        lateout("v22") _,
        lateout("v23") _,
        lateout("v24") _,
        lateout("v25") _,
        lateout("v26") _,
        lateout("v27") _,
        lateout("v28") _,
        lateout("v29") _,
        lateout("v30") _,
        lateout("v31") _,
        options(nostack, readonly)
    );
    FromAsm::from_asm(r0)
}

#[inline]
pub(in crate::backend) unsafe fn syscall5(
    nr: SyscallNumber<'_>,
    a0: ArgReg<'_, A0>,
    a1: ArgReg<'_, A1>,
    a2: ArgReg<'_, A2>,
    a3: ArgReg<'_, A3>,
    a4: ArgReg<'_, A4>,
) -> RetReg<R0> {
    let r0;
    asm!(
        "ecall",
        in("a7") nr.to_asm(),
        inlateout("a0") a0.to_asm() => r0,
        in("a1") a1.to_asm(),
        in("a2") a2.to_asm(),
        in("a3") a3.to_asm(),
        in("a4") a4.to_asm(),
        lateout("v0") _,
        lateout("v1") _,
        lateout("v2") _,
        lateout("v3") _,
        lateout("v4") _,
        lateout("v5") _,
        lateout("v6") _,
        lateout("v7") _,
        lateout("v8") _,
        lateout("v9") _,
        lateout("v10") _,
        lateout("v11") _,
        lateout("v12") _,
        lateout("v13") _,
        lateout("v14") _,
        lateout("v15") _,
        lateout("v16") _,
        lateout("v17") _,
        lateout("v18") _,
        lateout("v19") _,
        lateout("v20") _,
        lateout("v21") _,
        lateout("v22") _,
        lateout("v23") _,
        lateout("v24") _,
        lateout("v25") _,
        lateout("v26") _,
        lateout("v27") _,
        lateout("v28") _,
        lateout("v29") _,
        lateout("v30") _,
        lateout("v31") _,
        options(nostack)
    );
    FromAsm::from_asm(r0)
}

#[inline]
pub(in crate::backend) unsafe fn syscall5_readonly(
    nr: SyscallNumber<'_>,
    a0: ArgReg<'_, A0>,
    a1: ArgReg<'_, A1>,
    a2: ArgReg<'_, A2>,
    a3: ArgReg<'_, A3>,
    a4: ArgReg<'_, A4>,
) -> RetReg<R0> {
    let r0;
    asm!(
        "ecall",
        in("a7") nr.to_asm(),
        inlateout("a0") a0.to_asm() => r0,
        in("a1") a1.to_asm(),
        in("a2") a2.to_asm(),
        in("a3") a3.to_asm(),
        in("a4") a4.to_asm(),
        lateout("v0") _,
        lateout("v1") _,
        lateout("v2") _,
        lateout("v3") _,
        lateout("v4") _,
        lateout("v5") _,
        lateout("v6") _,
        lateout("v7") _,
        lateout("v8") _,
        lateout("v9") _,
        lateout("v10") _,
        lateout("v11") _,
        lateout("v12") _,
        lateout("v13") _,
        lateout("v14") _,
        lateout("v15") _,
        lateout("v16") _,
        lateout("v17") _,
        lateout("v18") _,
        lateout("v19") _,
        lateout("v20") _,
        lateout("v21") _,
        lateout("v22") _,
        lateout("v23") _,
        lateout("v24") _,
        lateout("v25") _,
        lateout("v26") _,
        lateout("v27") _,
        lateout("v28") _,
        lateout("v29") _,
        lateout("v30") _,
        lateout("v31") _,
        options(nostack, readonly)
    );
    FromAsm::from_asm(r0)
}

#[inline]
pub(in crate::backend) unsafe fn syscall6(
    nr: SyscallNumber<'_>,
    a0: ArgReg<'_, A0>,
    a1: ArgReg<'_, A1>,
    a2: ArgReg<'_, A2>,
    a3: ArgReg<'_, A3>,
    a4: ArgReg<'_, A4>,
    a5: ArgReg<'_, A5>,
) -> RetReg<R0> {
    let r0;
    asm!(
        "ecall",
        in("a7") nr.to_asm(),
        inlateout("a0") a0.to_asm() => r0,
        in("a1") a1.to_asm(),
        in("a2") a2.to_asm(),
        in("a3") a3.to_asm(),
        in("a4") a4.to_asm(),
        in("a5") a5.to_asm(),
        lateout("v0") _,
        lateout("v1") _,
        lateout("v2") _,
        lateout("v3") _,
        lateout("v4") _,
        lateout("v5") _,
        lateout("v6") _,
        lateout("v7") _,
        lateout("v8") _,
        lateout("v9") _,
        lateout("v10") _,
        lateout("v11") _,
        lateout("v12") _,
        lateout("v13") _,
        lateout("v14") _,
        lateout("v15") _,
        lateout("v16") _,
        lateout("v17") _,
        lateout("v18") _,
        lateout("v19") _,
        lateout("v20") _,
        lateout("v21") _,
        lateout("v22") _,
        lateout("v23") _,
        lateout("v24") _,
        lateout("v25") _,
        lateout("v26") _,
        lateout("v27") _,
        lateout("v28") _,
        lateout("v29") _,
        lateout("v30") _,
        lateout("v31") _,
        options(nostack)
    );
    FromAsm::from_asm(r0)
}

#[inline]
pub(in crate::backend) unsafe fn syscall6_readonly(
    nr: SyscallNumber<'_>,
    a0: ArgReg<'_, A0>,
    a1: ArgReg<'_, A1>,
    a2: ArgReg<'_, A2>,
    a3: ArgReg<'_, A3>,
    a4: ArgReg<'_, A4>,
    a5: ArgReg<'_, A5>,
) -> RetReg<R0> {
    let r0;
    asm!(
        "ecall",
        in("a7") nr.to_asm(),
        inlateout("a0") a0.to_asm() => r0,
        in("a1") a1.to_asm(),
        in("a2") a2.to_asm(),
        in("a3") a3.to_asm(),
        in("a4") a4.to_asm(),
        in("a5") a5.to_asm(),
        lateout("v0") _,
        lateout("v1") _,
        lateout("v2") _,
        lateout("v3") _,
        lateout("v4") _,
        lateout("v5") _,
        lateout("v6") _,
        lateout("v7") _,
        lateout("v8") _,
        lateout("v9") _,
        lateout("v10") _,
        lateout("v11") _,
        lateout("v12") _,
        lateout("v13") _,
        lateout("v14") _,
        lateout("v15") _,
        lateout("v16") _,
        lateout("v17") _,
        lateout("v18") _,
        lateout("v19") _,
        lateout("v20") _,
        lateout("v21") _,
        lateout("v22") _,
        lateout("v23") _,
        lateout("v24") _,
        lateout("v25") _,
        lateout("v26") _,
        lateout("v27") _,
        lateout("v28") _,
        lateout("v29") _,
        lateout("v30") _,
        lateout("v31") _,
        options(nostack, readonly)
    );
    FromAsm::from_asm(r0)
}
