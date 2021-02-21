; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv64 -mattr=+experimental-v,+d,+experimental-zfh -verify-machineinstrs \
; RUN:   --riscv-no-aliases < %s | FileCheck %s
declare <vscale x 2 x float> @llvm.riscv.vfwredsum.nxv2f32.nxv1f16(
  <vscale x 2 x float>,
  <vscale x 1 x half>,
  <vscale x 2 x float>,
  i64);

define <vscale x 2 x float> @intrinsic_vfwredsum_vs_nxv2f32_nxv1f16_nxv2f32(<vscale x 2 x float> %0, <vscale x 1 x half> %1, <vscale x 2 x float> %2, i64 %3) nounwind {
; CHECK-LABEL: intrinsic_vfwredsum_vs_nxv2f32_nxv1f16_nxv2f32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli a0, a0, e16,mf4,ta,mu
; CHECK-NEXT:    vfwredsum.vs v8, v9, v10
; CHECK-NEXT:    jalr zero, 0(ra)
entry:
  %a = call <vscale x 2 x float> @llvm.riscv.vfwredsum.nxv2f32.nxv1f16(
    <vscale x 2 x float> %0,
    <vscale x 1 x half> %1,
    <vscale x 2 x float> %2,
    i64 %3)

  ret <vscale x 2 x float> %a
}

declare <vscale x 2 x float> @llvm.riscv.vfwredsum.mask.nxv2f32.nxv1f16.nxv2f32(
  <vscale x 2 x float>,
  <vscale x 1 x half>,
  <vscale x 2 x float>,
  <vscale x 1 x i1>,
  i64);

define <vscale x 2 x float> @intrinsic_vfwredsum_mask_vs_nxv2f32_nxv1f16_nxv2f32(<vscale x 2 x float> %0, <vscale x 1 x half> %1, <vscale x 2 x float> %2, <vscale x 1 x i1> %3, i64 %4) nounwind {
; CHECK-LABEL: intrinsic_vfwredsum_mask_vs_nxv2f32_nxv1f16_nxv2f32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli a0, a0, e16,mf4,ta,mu
; CHECK-NEXT:    vfwredsum.vs v8, v9, v10, v0.t
; CHECK-NEXT:    jalr zero, 0(ra)
entry:
  %a = call <vscale x 2 x float> @llvm.riscv.vfwredsum.mask.nxv2f32.nxv1f16.nxv2f32(
    <vscale x 2 x float> %0,
    <vscale x 1 x half> %1,
    <vscale x 2 x float> %2,
    <vscale x 1 x i1> %3,
    i64 %4)

  ret <vscale x 2 x float> %a
}

declare <vscale x 2 x float> @llvm.riscv.vfwredsum.nxv2f32.nxv2f16(
  <vscale x 2 x float>,
  <vscale x 2 x half>,
  <vscale x 2 x float>,
  i64);

define <vscale x 2 x float> @intrinsic_vfwredsum_vs_nxv2f32_nxv2f16_nxv2f32(<vscale x 2 x float> %0, <vscale x 2 x half> %1, <vscale x 2 x float> %2, i64 %3) nounwind {
; CHECK-LABEL: intrinsic_vfwredsum_vs_nxv2f32_nxv2f16_nxv2f32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli a0, a0, e16,mf2,ta,mu
; CHECK-NEXT:    vfwredsum.vs v8, v9, v10
; CHECK-NEXT:    jalr zero, 0(ra)
entry:
  %a = call <vscale x 2 x float> @llvm.riscv.vfwredsum.nxv2f32.nxv2f16(
    <vscale x 2 x float> %0,
    <vscale x 2 x half> %1,
    <vscale x 2 x float> %2,
    i64 %3)

  ret <vscale x 2 x float> %a
}

declare <vscale x 2 x float> @llvm.riscv.vfwredsum.mask.nxv2f32.nxv2f16.nxv2f32(
  <vscale x 2 x float>,
  <vscale x 2 x half>,
  <vscale x 2 x float>,
  <vscale x 2 x i1>,
  i64);

define <vscale x 2 x float> @intrinsic_vfwredsum_mask_vs_nxv2f32_nxv2f16_nxv2f32(<vscale x 2 x float> %0, <vscale x 2 x half> %1, <vscale x 2 x float> %2, <vscale x 2 x i1> %3, i64 %4) nounwind {
; CHECK-LABEL: intrinsic_vfwredsum_mask_vs_nxv2f32_nxv2f16_nxv2f32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli a0, a0, e16,mf2,ta,mu
; CHECK-NEXT:    vfwredsum.vs v8, v9, v10, v0.t
; CHECK-NEXT:    jalr zero, 0(ra)
entry:
  %a = call <vscale x 2 x float> @llvm.riscv.vfwredsum.mask.nxv2f32.nxv2f16.nxv2f32(
    <vscale x 2 x float> %0,
    <vscale x 2 x half> %1,
    <vscale x 2 x float> %2,
    <vscale x 2 x i1> %3,
    i64 %4)

  ret <vscale x 2 x float> %a
}

declare <vscale x 2 x float> @llvm.riscv.vfwredsum.nxv2f32.nxv4f16(
  <vscale x 2 x float>,
  <vscale x 4 x half>,
  <vscale x 2 x float>,
  i64);

define <vscale x 2 x float> @intrinsic_vfwredsum_vs_nxv2f32_nxv4f16_nxv2f32(<vscale x 2 x float> %0, <vscale x 4 x half> %1, <vscale x 2 x float> %2, i64 %3) nounwind {
; CHECK-LABEL: intrinsic_vfwredsum_vs_nxv2f32_nxv4f16_nxv2f32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli a0, a0, e16,m1,ta,mu
; CHECK-NEXT:    vfwredsum.vs v8, v9, v10
; CHECK-NEXT:    jalr zero, 0(ra)
entry:
  %a = call <vscale x 2 x float> @llvm.riscv.vfwredsum.nxv2f32.nxv4f16(
    <vscale x 2 x float> %0,
    <vscale x 4 x half> %1,
    <vscale x 2 x float> %2,
    i64 %3)

  ret <vscale x 2 x float> %a
}

declare <vscale x 2 x float> @llvm.riscv.vfwredsum.mask.nxv2f32.nxv4f16.nxv2f32(
  <vscale x 2 x float>,
  <vscale x 4 x half>,
  <vscale x 2 x float>,
  <vscale x 4 x i1>,
  i64);

define <vscale x 2 x float> @intrinsic_vfwredsum_mask_vs_nxv2f32_nxv4f16_nxv2f32(<vscale x 2 x float> %0, <vscale x 4 x half> %1, <vscale x 2 x float> %2, <vscale x 4 x i1> %3, i64 %4) nounwind {
; CHECK-LABEL: intrinsic_vfwredsum_mask_vs_nxv2f32_nxv4f16_nxv2f32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli a0, a0, e16,m1,ta,mu
; CHECK-NEXT:    vfwredsum.vs v8, v9, v10, v0.t
; CHECK-NEXT:    jalr zero, 0(ra)
entry:
  %a = call <vscale x 2 x float> @llvm.riscv.vfwredsum.mask.nxv2f32.nxv4f16.nxv2f32(
    <vscale x 2 x float> %0,
    <vscale x 4 x half> %1,
    <vscale x 2 x float> %2,
    <vscale x 4 x i1> %3,
    i64 %4)

  ret <vscale x 2 x float> %a
}

declare <vscale x 2 x float> @llvm.riscv.vfwredsum.nxv2f32.nxv8f16(
  <vscale x 2 x float>,
  <vscale x 8 x half>,
  <vscale x 2 x float>,
  i64);

define <vscale x 2 x float> @intrinsic_vfwredsum_vs_nxv2f32_nxv8f16_nxv2f32(<vscale x 2 x float> %0, <vscale x 8 x half> %1, <vscale x 2 x float> %2, i64 %3) nounwind {
; CHECK-LABEL: intrinsic_vfwredsum_vs_nxv2f32_nxv8f16_nxv2f32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli a0, a0, e16,m2,ta,mu
; CHECK-NEXT:    vfwredsum.vs v8, v10, v9
; CHECK-NEXT:    jalr zero, 0(ra)
entry:
  %a = call <vscale x 2 x float> @llvm.riscv.vfwredsum.nxv2f32.nxv8f16(
    <vscale x 2 x float> %0,
    <vscale x 8 x half> %1,
    <vscale x 2 x float> %2,
    i64 %3)

  ret <vscale x 2 x float> %a
}

declare <vscale x 2 x float> @llvm.riscv.vfwredsum.mask.nxv2f32.nxv8f16.nxv2f32(
  <vscale x 2 x float>,
  <vscale x 8 x half>,
  <vscale x 2 x float>,
  <vscale x 8 x i1>,
  i64);

define <vscale x 2 x float> @intrinsic_vfwredsum_mask_vs_nxv2f32_nxv8f16_nxv2f32(<vscale x 2 x float> %0, <vscale x 8 x half> %1, <vscale x 2 x float> %2, <vscale x 8 x i1> %3, i64 %4) nounwind {
; CHECK-LABEL: intrinsic_vfwredsum_mask_vs_nxv2f32_nxv8f16_nxv2f32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli a0, a0, e16,m2,ta,mu
; CHECK-NEXT:    vfwredsum.vs v8, v10, v9, v0.t
; CHECK-NEXT:    jalr zero, 0(ra)
entry:
  %a = call <vscale x 2 x float> @llvm.riscv.vfwredsum.mask.nxv2f32.nxv8f16.nxv2f32(
    <vscale x 2 x float> %0,
    <vscale x 8 x half> %1,
    <vscale x 2 x float> %2,
    <vscale x 8 x i1> %3,
    i64 %4)

  ret <vscale x 2 x float> %a
}

declare <vscale x 2 x float> @llvm.riscv.vfwredsum.nxv2f32.nxv16f16(
  <vscale x 2 x float>,
  <vscale x 16 x half>,
  <vscale x 2 x float>,
  i64);

define <vscale x 2 x float> @intrinsic_vfwredsum_vs_nxv2f32_nxv16f16_nxv2f32(<vscale x 2 x float> %0, <vscale x 16 x half> %1, <vscale x 2 x float> %2, i64 %3) nounwind {
; CHECK-LABEL: intrinsic_vfwredsum_vs_nxv2f32_nxv16f16_nxv2f32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli a0, a0, e16,m4,ta,mu
; CHECK-NEXT:    vfwredsum.vs v8, v12, v9
; CHECK-NEXT:    jalr zero, 0(ra)
entry:
  %a = call <vscale x 2 x float> @llvm.riscv.vfwredsum.nxv2f32.nxv16f16(
    <vscale x 2 x float> %0,
    <vscale x 16 x half> %1,
    <vscale x 2 x float> %2,
    i64 %3)

  ret <vscale x 2 x float> %a
}

declare <vscale x 2 x float> @llvm.riscv.vfwredsum.mask.nxv2f32.nxv16f16.nxv2f32(
  <vscale x 2 x float>,
  <vscale x 16 x half>,
  <vscale x 2 x float>,
  <vscale x 16 x i1>,
  i64);

define <vscale x 2 x float> @intrinsic_vfwredsum_mask_vs_nxv2f32_nxv16f16_nxv2f32(<vscale x 2 x float> %0, <vscale x 16 x half> %1, <vscale x 2 x float> %2, <vscale x 16 x i1> %3, i64 %4) nounwind {
; CHECK-LABEL: intrinsic_vfwredsum_mask_vs_nxv2f32_nxv16f16_nxv2f32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli a0, a0, e16,m4,ta,mu
; CHECK-NEXT:    vfwredsum.vs v8, v12, v9, v0.t
; CHECK-NEXT:    jalr zero, 0(ra)
entry:
  %a = call <vscale x 2 x float> @llvm.riscv.vfwredsum.mask.nxv2f32.nxv16f16.nxv2f32(
    <vscale x 2 x float> %0,
    <vscale x 16 x half> %1,
    <vscale x 2 x float> %2,
    <vscale x 16 x i1> %3,
    i64 %4)

  ret <vscale x 2 x float> %a
}

declare <vscale x 2 x float> @llvm.riscv.vfwredsum.nxv2f32.nxv32f16(
  <vscale x 2 x float>,
  <vscale x 32 x half>,
  <vscale x 2 x float>,
  i64);

define <vscale x 2 x float> @intrinsic_vfwredsum_vs_nxv2f32_nxv32f16_nxv2f32(<vscale x 2 x float> %0, <vscale x 32 x half> %1, <vscale x 2 x float> %2, i64 %3) nounwind {
; CHECK-LABEL: intrinsic_vfwredsum_vs_nxv2f32_nxv32f16_nxv2f32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli a0, a0, e16,m8,ta,mu
; CHECK-NEXT:    vfwredsum.vs v8, v16, v9
; CHECK-NEXT:    jalr zero, 0(ra)
entry:
  %a = call <vscale x 2 x float> @llvm.riscv.vfwredsum.nxv2f32.nxv32f16(
    <vscale x 2 x float> %0,
    <vscale x 32 x half> %1,
    <vscale x 2 x float> %2,
    i64 %3)

  ret <vscale x 2 x float> %a
}

declare <vscale x 2 x float> @llvm.riscv.vfwredsum.mask.nxv2f32.nxv32f16(
  <vscale x 2 x float>,
  <vscale x 32 x half>,
  <vscale x 2 x float>,
  <vscale x 32 x i1>,
  i64);

define <vscale x 2 x float> @intrinsic_vfwredsum_mask_vs_nxv2f32_nxv32f16_nxv2f32(<vscale x 2 x float> %0, <vscale x 32 x half> %1, <vscale x 2 x float> %2, <vscale x 32 x i1> %3, i64 %4) nounwind {
; CHECK-LABEL: intrinsic_vfwredsum_mask_vs_nxv2f32_nxv32f16_nxv2f32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli a0, a0, e16,m8,ta,mu
; CHECK-NEXT:    vfwredsum.vs v8, v16, v9, v0.t
; CHECK-NEXT:    jalr zero, 0(ra)
entry:
  %a = call <vscale x 2 x float> @llvm.riscv.vfwredsum.mask.nxv2f32.nxv32f16(
    <vscale x 2 x float> %0,
    <vscale x 32 x half> %1,
    <vscale x 2 x float> %2,
    <vscale x 32 x i1> %3,
    i64 %4)

  ret <vscale x 2 x float> %a
}

declare <vscale x 1 x double> @llvm.riscv.vfwredsum.nxv1f64.nxv1f32(
  <vscale x 1 x double>,
  <vscale x 1 x float>,
  <vscale x 1 x double>,
  i64);

define <vscale x 1 x double> @intrinsic_vfwredsum_vs_nxv1f64_nxv1f32_nxv1f64(<vscale x 1 x double> %0, <vscale x 1 x float> %1, <vscale x 1 x double> %2, i64 %3) nounwind {
; CHECK-LABEL: intrinsic_vfwredsum_vs_nxv1f64_nxv1f32_nxv1f64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli a0, a0, e32,mf2,ta,mu
; CHECK-NEXT:    vfwredsum.vs v8, v9, v10
; CHECK-NEXT:    jalr zero, 0(ra)
entry:
  %a = call <vscale x 1 x double> @llvm.riscv.vfwredsum.nxv1f64.nxv1f32(
    <vscale x 1 x double> %0,
    <vscale x 1 x float> %1,
    <vscale x 1 x double> %2,
    i64 %3)

  ret <vscale x 1 x double> %a
}

declare <vscale x 1 x double> @llvm.riscv.vfwredsum.mask.nxv1f64.nxv1f32.nxv1f64(
  <vscale x 1 x double>,
  <vscale x 1 x float>,
  <vscale x 1 x double>,
  <vscale x 1 x i1>,
  i64);

define <vscale x 1 x double> @intrinsic_vfwredsum_mask_vs_nxv1f64_nxv1f32_nxv1f64(<vscale x 1 x double> %0, <vscale x 1 x float> %1, <vscale x 1 x double> %2, <vscale x 1 x i1> %3, i64 %4) nounwind {
; CHECK-LABEL: intrinsic_vfwredsum_mask_vs_nxv1f64_nxv1f32_nxv1f64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli a0, a0, e32,mf2,ta,mu
; CHECK-NEXT:    vfwredsum.vs v8, v9, v10, v0.t
; CHECK-NEXT:    jalr zero, 0(ra)
entry:
  %a = call <vscale x 1 x double> @llvm.riscv.vfwredsum.mask.nxv1f64.nxv1f32.nxv1f64(
    <vscale x 1 x double> %0,
    <vscale x 1 x float> %1,
    <vscale x 1 x double> %2,
    <vscale x 1 x i1> %3,
    i64 %4)

  ret <vscale x 1 x double> %a
}

declare <vscale x 1 x double> @llvm.riscv.vfwredsum.nxv1f64.nxv2f32(
  <vscale x 1 x double>,
  <vscale x 2 x float>,
  <vscale x 1 x double>,
  i64);

define <vscale x 1 x double> @intrinsic_vfwredsum_vs_nxv1f64_nxv2f32_nxv1f64(<vscale x 1 x double> %0, <vscale x 2 x float> %1, <vscale x 1 x double> %2, i64 %3) nounwind {
; CHECK-LABEL: intrinsic_vfwredsum_vs_nxv1f64_nxv2f32_nxv1f64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli a0, a0, e32,m1,ta,mu
; CHECK-NEXT:    vfwredsum.vs v8, v9, v10
; CHECK-NEXT:    jalr zero, 0(ra)
entry:
  %a = call <vscale x 1 x double> @llvm.riscv.vfwredsum.nxv1f64.nxv2f32(
    <vscale x 1 x double> %0,
    <vscale x 2 x float> %1,
    <vscale x 1 x double> %2,
    i64 %3)

  ret <vscale x 1 x double> %a
}

declare <vscale x 1 x double> @llvm.riscv.vfwredsum.mask.nxv1f64.nxv2f32.nxv1f64(
  <vscale x 1 x double>,
  <vscale x 2 x float>,
  <vscale x 1 x double>,
  <vscale x 2 x i1>,
  i64);

define <vscale x 1 x double> @intrinsic_vfwredsum_mask_vs_nxv1f64_nxv2f32_nxv1f64(<vscale x 1 x double> %0, <vscale x 2 x float> %1, <vscale x 1 x double> %2, <vscale x 2 x i1> %3, i64 %4) nounwind {
; CHECK-LABEL: intrinsic_vfwredsum_mask_vs_nxv1f64_nxv2f32_nxv1f64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli a0, a0, e32,m1,ta,mu
; CHECK-NEXT:    vfwredsum.vs v8, v9, v10, v0.t
; CHECK-NEXT:    jalr zero, 0(ra)
entry:
  %a = call <vscale x 1 x double> @llvm.riscv.vfwredsum.mask.nxv1f64.nxv2f32.nxv1f64(
    <vscale x 1 x double> %0,
    <vscale x 2 x float> %1,
    <vscale x 1 x double> %2,
    <vscale x 2 x i1> %3,
    i64 %4)

  ret <vscale x 1 x double> %a
}

declare <vscale x 1 x double> @llvm.riscv.vfwredsum.nxv1f64.nxv4f32(
  <vscale x 1 x double>,
  <vscale x 4 x float>,
  <vscale x 1 x double>,
  i64);

define <vscale x 1 x double> @intrinsic_vfwredsum_vs_nxv1f64_nxv4f32_nxv1f64(<vscale x 1 x double> %0, <vscale x 4 x float> %1, <vscale x 1 x double> %2, i64 %3) nounwind {
; CHECK-LABEL: intrinsic_vfwredsum_vs_nxv1f64_nxv4f32_nxv1f64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli a0, a0, e32,m2,ta,mu
; CHECK-NEXT:    vfwredsum.vs v8, v10, v9
; CHECK-NEXT:    jalr zero, 0(ra)
entry:
  %a = call <vscale x 1 x double> @llvm.riscv.vfwredsum.nxv1f64.nxv4f32(
    <vscale x 1 x double> %0,
    <vscale x 4 x float> %1,
    <vscale x 1 x double> %2,
    i64 %3)

  ret <vscale x 1 x double> %a
}

declare <vscale x 1 x double> @llvm.riscv.vfwredsum.mask.nxv1f64.nxv4f32.nxv1f64(
  <vscale x 1 x double>,
  <vscale x 4 x float>,
  <vscale x 1 x double>,
  <vscale x 4 x i1>,
  i64);

define <vscale x 1 x double> @intrinsic_vfwredsum_mask_vs_nxv1f64_nxv4f32_nxv1f64(<vscale x 1 x double> %0, <vscale x 4 x float> %1, <vscale x 1 x double> %2, <vscale x 4 x i1> %3, i64 %4) nounwind {
; CHECK-LABEL: intrinsic_vfwredsum_mask_vs_nxv1f64_nxv4f32_nxv1f64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli a0, a0, e32,m2,ta,mu
; CHECK-NEXT:    vfwredsum.vs v8, v10, v9, v0.t
; CHECK-NEXT:    jalr zero, 0(ra)
entry:
  %a = call <vscale x 1 x double> @llvm.riscv.vfwredsum.mask.nxv1f64.nxv4f32.nxv1f64(
    <vscale x 1 x double> %0,
    <vscale x 4 x float> %1,
    <vscale x 1 x double> %2,
    <vscale x 4 x i1> %3,
    i64 %4)

  ret <vscale x 1 x double> %a
}

declare <vscale x 1 x double> @llvm.riscv.vfwredsum.nxv1f64.nxv8f32(
  <vscale x 1 x double>,
  <vscale x 8 x float>,
  <vscale x 1 x double>,
  i64);

define <vscale x 1 x double> @intrinsic_vfwredsum_vs_nxv1f64_nxv8f32_nxv1f64(<vscale x 1 x double> %0, <vscale x 8 x float> %1, <vscale x 1 x double> %2, i64 %3) nounwind {
; CHECK-LABEL: intrinsic_vfwredsum_vs_nxv1f64_nxv8f32_nxv1f64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli a0, a0, e32,m4,ta,mu
; CHECK-NEXT:    vfwredsum.vs v8, v12, v9
; CHECK-NEXT:    jalr zero, 0(ra)
entry:
  %a = call <vscale x 1 x double> @llvm.riscv.vfwredsum.nxv1f64.nxv8f32(
    <vscale x 1 x double> %0,
    <vscale x 8 x float> %1,
    <vscale x 1 x double> %2,
    i64 %3)

  ret <vscale x 1 x double> %a
}

declare <vscale x 1 x double> @llvm.riscv.vfwredsum.mask.nxv1f64.nxv8f32.nxv1f64(
  <vscale x 1 x double>,
  <vscale x 8 x float>,
  <vscale x 1 x double>,
  <vscale x 8 x i1>,
  i64);

define <vscale x 1 x double> @intrinsic_vfwredsum_mask_vs_nxv1f64_nxv8f32_nxv1f64(<vscale x 1 x double> %0, <vscale x 8 x float> %1, <vscale x 1 x double> %2, <vscale x 8 x i1> %3, i64 %4) nounwind {
; CHECK-LABEL: intrinsic_vfwredsum_mask_vs_nxv1f64_nxv8f32_nxv1f64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli a0, a0, e32,m4,ta,mu
; CHECK-NEXT:    vfwredsum.vs v8, v12, v9, v0.t
; CHECK-NEXT:    jalr zero, 0(ra)
entry:
  %a = call <vscale x 1 x double> @llvm.riscv.vfwredsum.mask.nxv1f64.nxv8f32.nxv1f64(
    <vscale x 1 x double> %0,
    <vscale x 8 x float> %1,
    <vscale x 1 x double> %2,
    <vscale x 8 x i1> %3,
    i64 %4)

  ret <vscale x 1 x double> %a
}

declare <vscale x 1 x double> @llvm.riscv.vfwredsum.nxv1f64.nxv16f32(
  <vscale x 1 x double>,
  <vscale x 16 x float>,
  <vscale x 1 x double>,
  i64);

define <vscale x 1 x double> @intrinsic_vfwredsum_vs_nxv1f64_nxv16f32_nxv1f64(<vscale x 1 x double> %0, <vscale x 16 x float> %1, <vscale x 1 x double> %2, i64 %3) nounwind {
; CHECK-LABEL: intrinsic_vfwredsum_vs_nxv1f64_nxv16f32_nxv1f64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli a0, a0, e32,m8,ta,mu
; CHECK-NEXT:    vfwredsum.vs v8, v16, v9
; CHECK-NEXT:    jalr zero, 0(ra)
entry:
  %a = call <vscale x 1 x double> @llvm.riscv.vfwredsum.nxv1f64.nxv16f32(
    <vscale x 1 x double> %0,
    <vscale x 16 x float> %1,
    <vscale x 1 x double> %2,
    i64 %3)

  ret <vscale x 1 x double> %a
}

declare <vscale x 1 x double> @llvm.riscv.vfwredsum.mask.nxv1f64.nxv16f32(
  <vscale x 1 x double>,
  <vscale x 16 x float>,
  <vscale x 1 x double>,
  <vscale x 16 x i1>,
  i64);

define <vscale x 1 x double> @intrinsic_vfwredsum_mask_vs_nxv1f64_nxv16f32_nxv1f64(<vscale x 1 x double> %0, <vscale x 16 x float> %1, <vscale x 1 x double> %2, <vscale x 16 x i1> %3, i64 %4) nounwind {
; CHECK-LABEL: intrinsic_vfwredsum_mask_vs_nxv1f64_nxv16f32_nxv1f64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vsetvli a0, a0, e32,m8,ta,mu
; CHECK-NEXT:    vfwredsum.vs v8, v16, v9, v0.t
; CHECK-NEXT:    jalr zero, 0(ra)
entry:
  %a = call <vscale x 1 x double> @llvm.riscv.vfwredsum.mask.nxv1f64.nxv16f32(
    <vscale x 1 x double> %0,
    <vscale x 16 x float> %1,
    <vscale x 1 x double> %2,
    <vscale x 16 x i1> %3,
    i64 %4)

  ret <vscale x 1 x double> %a
}
