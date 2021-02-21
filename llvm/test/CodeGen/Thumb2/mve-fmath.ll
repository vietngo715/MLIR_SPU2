; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=thumbv8.1m.main-none-none-eabi -mattr=+mve,+fullfp16 -verify-machineinstrs %s -o - | FileCheck %s --check-prefix=CHECK
; RUN: llc -mtriple=thumbv8.1m.main-none-none-eabi -mattr=+mve.fp -verify-machineinstrs %s -o - | FileCheck %s --check-prefix=CHECK

define arm_aapcs_vfpcc <4 x float> @sqrt_float32_t(<4 x float> %src) {
; CHECK-LABEL: sqrt_float32_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vsqrt.f32 s7, s3
; CHECK-NEXT:    vsqrt.f32 s6, s2
; CHECK-NEXT:    vsqrt.f32 s5, s1
; CHECK-NEXT:    vsqrt.f32 s4, s0
; CHECK-NEXT:    vmov q0, q1
; CHECK-NEXT:    bx lr
entry:
  %0 = call fast <4 x float> @llvm.sqrt.v4f32(<4 x float> %src)
  ret <4 x float> %0
}

define arm_aapcs_vfpcc <8 x half> @sqrt_float16_t(<8 x half> %src) {
; CHECK-LABEL: sqrt_float16_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmov q1, q0
; CHECK-NEXT:    vmovx.f16 s0, s4
; CHECK-NEXT:    vsqrt.f16 s8, s0
; CHECK-NEXT:    vsqrt.f16 s0, s4
; CHECK-NEXT:    vins.f16 s0, s8
; CHECK-NEXT:    vmovx.f16 s8, s5
; CHECK-NEXT:    vsqrt.f16 s8, s8
; CHECK-NEXT:    vsqrt.f16 s1, s5
; CHECK-NEXT:    vins.f16 s1, s8
; CHECK-NEXT:    vmovx.f16 s8, s6
; CHECK-NEXT:    vsqrt.f16 s8, s8
; CHECK-NEXT:    vsqrt.f16 s2, s6
; CHECK-NEXT:    vins.f16 s2, s8
; CHECK-NEXT:    vmovx.f16 s8, s7
; CHECK-NEXT:    vsqrt.f16 s8, s8
; CHECK-NEXT:    vsqrt.f16 s3, s7
; CHECK-NEXT:    vins.f16 s3, s8
; CHECK-NEXT:    bx lr
entry:
  %0 = call fast <8 x half> @llvm.sqrt.v8f16(<8 x half> %src)
  ret <8 x half> %0
}

define arm_aapcs_vfpcc <2 x double> @sqrt_float64_t(<2 x double> %src) {
; CHECK-LABEL: sqrt_float64_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    .vsave {d8, d9}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vmov r0, r1, d9
; CHECK-NEXT:    bl sqrt
; CHECK-NEXT:    vmov r2, r3, d8
; CHECK-NEXT:    vmov d9, r0, r1
; CHECK-NEXT:    mov r0, r2
; CHECK-NEXT:    mov r1, r3
; CHECK-NEXT:    bl sqrt
; CHECK-NEXT:    vmov d8, r0, r1
; CHECK-NEXT:    vmov q0, q4
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    pop {r7, pc}
entry:
  %0 = call fast <2 x double> @llvm.sqrt.v2f64(<2 x double> %src)
  ret <2 x double> %0
}

define arm_aapcs_vfpcc <4 x float> @cos_float32_t(<4 x float> %src) {
; CHECK-LABEL: cos_float32_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r4, r5, r7, lr}
; CHECK-NEXT:    push {r4, r5, r7, lr}
; CHECK-NEXT:    .vsave {d8, d9}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vmov r0, s18
; CHECK-NEXT:    bl cosf
; CHECK-NEXT:    mov r4, r0
; CHECK-NEXT:    vmov r0, s19
; CHECK-NEXT:    bl cosf
; CHECK-NEXT:    vmov r1, s17
; CHECK-NEXT:    vmov r5, s16
; CHECK-NEXT:    vmov s19, r0
; CHECK-NEXT:    vmov s18, r4
; CHECK-NEXT:    mov r0, r1
; CHECK-NEXT:    bl cosf
; CHECK-NEXT:    vmov s17, r0
; CHECK-NEXT:    mov r0, r5
; CHECK-NEXT:    bl cosf
; CHECK-NEXT:    vmov s16, r0
; CHECK-NEXT:    vmov q0, q4
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    pop {r4, r5, r7, pc}
entry:
  %0 = call fast <4 x float> @llvm.cos.v4f32(<4 x float> %src)
  ret <4 x float> %0
}

define arm_aapcs_vfpcc <8 x half> @cos_float16_t(<8 x half> %src) {
; CHECK-LABEL: cos_float16_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    .vsave {d8, d9, d10, d11}
; CHECK-NEXT:    vpush {d8, d9, d10, d11}
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s16
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl cosf
; CHECK-NEXT:    vcvtt.f32.f16 s0, s16
; CHECK-NEXT:    vmov s20, r0
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    mov r0, r1
; CHECK-NEXT:    bl cosf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s20, s20
; CHECK-NEXT:    vcvtt.f16.f32 s20, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s17
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl cosf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s21, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s17
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl cosf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtt.f16.f32 s21, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s18
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl cosf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s22, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s18
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl cosf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtt.f16.f32 s22, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s19
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl cosf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s23, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s19
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl cosf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtt.f16.f32 s23, s0
; CHECK-NEXT:    vmov q0, q5
; CHECK-NEXT:    vpop {d8, d9, d10, d11}
; CHECK-NEXT:    pop {r7, pc}
entry:
  %0 = call fast <8 x half> @llvm.cos.v8f16(<8 x half> %src)
  ret <8 x half> %0
}

define arm_aapcs_vfpcc <2 x double> @cos_float64_t(<2 x double> %src) {
; CHECK-LABEL: cos_float64_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    .vsave {d8, d9}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vmov r0, r1, d9
; CHECK-NEXT:    bl cos
; CHECK-NEXT:    vmov r2, r3, d8
; CHECK-NEXT:    vmov d9, r0, r1
; CHECK-NEXT:    mov r0, r2
; CHECK-NEXT:    mov r1, r3
; CHECK-NEXT:    bl cos
; CHECK-NEXT:    vmov d8, r0, r1
; CHECK-NEXT:    vmov q0, q4
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    pop {r7, pc}
entry:
  %0 = call fast <2 x double> @llvm.cos.v2f64(<2 x double> %src)
  ret <2 x double> %0
}

define arm_aapcs_vfpcc <4 x float> @sin_float32_t(<4 x float> %src) {
; CHECK-LABEL: sin_float32_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r4, r5, r7, lr}
; CHECK-NEXT:    push {r4, r5, r7, lr}
; CHECK-NEXT:    .vsave {d8, d9}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vmov r0, s18
; CHECK-NEXT:    bl sinf
; CHECK-NEXT:    mov r4, r0
; CHECK-NEXT:    vmov r0, s19
; CHECK-NEXT:    bl sinf
; CHECK-NEXT:    vmov r1, s17
; CHECK-NEXT:    vmov r5, s16
; CHECK-NEXT:    vmov s19, r0
; CHECK-NEXT:    vmov s18, r4
; CHECK-NEXT:    mov r0, r1
; CHECK-NEXT:    bl sinf
; CHECK-NEXT:    vmov s17, r0
; CHECK-NEXT:    mov r0, r5
; CHECK-NEXT:    bl sinf
; CHECK-NEXT:    vmov s16, r0
; CHECK-NEXT:    vmov q0, q4
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    pop {r4, r5, r7, pc}
entry:
  %0 = call fast <4 x float> @llvm.sin.v4f32(<4 x float> %src)
  ret <4 x float> %0
}

define arm_aapcs_vfpcc <8 x half> @sin_float16_t(<8 x half> %src) {
; CHECK-LABEL: sin_float16_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    .vsave {d8, d9, d10, d11}
; CHECK-NEXT:    vpush {d8, d9, d10, d11}
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s16
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl sinf
; CHECK-NEXT:    vcvtt.f32.f16 s0, s16
; CHECK-NEXT:    vmov s20, r0
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    mov r0, r1
; CHECK-NEXT:    bl sinf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s20, s20
; CHECK-NEXT:    vcvtt.f16.f32 s20, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s17
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl sinf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s21, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s17
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl sinf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtt.f16.f32 s21, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s18
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl sinf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s22, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s18
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl sinf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtt.f16.f32 s22, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s19
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl sinf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s23, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s19
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl sinf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtt.f16.f32 s23, s0
; CHECK-NEXT:    vmov q0, q5
; CHECK-NEXT:    vpop {d8, d9, d10, d11}
; CHECK-NEXT:    pop {r7, pc}
entry:
  %0 = call fast <8 x half> @llvm.sin.v8f16(<8 x half> %src)
  ret <8 x half> %0
}

define arm_aapcs_vfpcc <2 x double> @sin_float64_t(<2 x double> %src) {
; CHECK-LABEL: sin_float64_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    .vsave {d8, d9}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vmov r0, r1, d9
; CHECK-NEXT:    bl sin
; CHECK-NEXT:    vmov r2, r3, d8
; CHECK-NEXT:    vmov d9, r0, r1
; CHECK-NEXT:    mov r0, r2
; CHECK-NEXT:    mov r1, r3
; CHECK-NEXT:    bl sin
; CHECK-NEXT:    vmov d8, r0, r1
; CHECK-NEXT:    vmov q0, q4
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    pop {r7, pc}
entry:
  %0 = call fast <2 x double> @llvm.sin.v2f64(<2 x double> %src)
  ret <2 x double> %0
}

define arm_aapcs_vfpcc <4 x float> @exp_float32_t(<4 x float> %src) {
; CHECK-LABEL: exp_float32_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r4, r5, r7, lr}
; CHECK-NEXT:    push {r4, r5, r7, lr}
; CHECK-NEXT:    .vsave {d8, d9}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vmov r0, s18
; CHECK-NEXT:    bl expf
; CHECK-NEXT:    mov r4, r0
; CHECK-NEXT:    vmov r0, s19
; CHECK-NEXT:    bl expf
; CHECK-NEXT:    vmov r1, s17
; CHECK-NEXT:    vmov r5, s16
; CHECK-NEXT:    vmov s19, r0
; CHECK-NEXT:    vmov s18, r4
; CHECK-NEXT:    mov r0, r1
; CHECK-NEXT:    bl expf
; CHECK-NEXT:    vmov s17, r0
; CHECK-NEXT:    mov r0, r5
; CHECK-NEXT:    bl expf
; CHECK-NEXT:    vmov s16, r0
; CHECK-NEXT:    vmov q0, q4
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    pop {r4, r5, r7, pc}
entry:
  %0 = call fast <4 x float> @llvm.exp.v4f32(<4 x float> %src)
  ret <4 x float> %0
}

define arm_aapcs_vfpcc <8 x half> @exp_float16_t(<8 x half> %src) {
; CHECK-LABEL: exp_float16_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    .vsave {d8, d9, d10, d11}
; CHECK-NEXT:    vpush {d8, d9, d10, d11}
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s16
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl expf
; CHECK-NEXT:    vcvtt.f32.f16 s0, s16
; CHECK-NEXT:    vmov s20, r0
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    mov r0, r1
; CHECK-NEXT:    bl expf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s20, s20
; CHECK-NEXT:    vcvtt.f16.f32 s20, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s17
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl expf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s21, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s17
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl expf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtt.f16.f32 s21, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s18
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl expf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s22, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s18
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl expf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtt.f16.f32 s22, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s19
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl expf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s23, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s19
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl expf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtt.f16.f32 s23, s0
; CHECK-NEXT:    vmov q0, q5
; CHECK-NEXT:    vpop {d8, d9, d10, d11}
; CHECK-NEXT:    pop {r7, pc}
entry:
  %0 = call fast <8 x half> @llvm.exp.v8f16(<8 x half> %src)
  ret <8 x half> %0
}

define arm_aapcs_vfpcc <2 x double> @exp_float64_t(<2 x double> %src) {
; CHECK-LABEL: exp_float64_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    .vsave {d8, d9}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vmov r0, r1, d9
; CHECK-NEXT:    bl exp
; CHECK-NEXT:    vmov r2, r3, d8
; CHECK-NEXT:    vmov d9, r0, r1
; CHECK-NEXT:    mov r0, r2
; CHECK-NEXT:    mov r1, r3
; CHECK-NEXT:    bl exp
; CHECK-NEXT:    vmov d8, r0, r1
; CHECK-NEXT:    vmov q0, q4
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    pop {r7, pc}
entry:
  %0 = call fast <2 x double> @llvm.exp.v2f64(<2 x double> %src)
  ret <2 x double> %0
}

define arm_aapcs_vfpcc <4 x float> @exp2_float32_t(<4 x float> %src) {
; CHECK-LABEL: exp2_float32_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r4, r5, r7, lr}
; CHECK-NEXT:    push {r4, r5, r7, lr}
; CHECK-NEXT:    .vsave {d8, d9}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vmov r0, s18
; CHECK-NEXT:    bl exp2f
; CHECK-NEXT:    mov r4, r0
; CHECK-NEXT:    vmov r0, s19
; CHECK-NEXT:    bl exp2f
; CHECK-NEXT:    vmov r1, s17
; CHECK-NEXT:    vmov r5, s16
; CHECK-NEXT:    vmov s19, r0
; CHECK-NEXT:    vmov s18, r4
; CHECK-NEXT:    mov r0, r1
; CHECK-NEXT:    bl exp2f
; CHECK-NEXT:    vmov s17, r0
; CHECK-NEXT:    mov r0, r5
; CHECK-NEXT:    bl exp2f
; CHECK-NEXT:    vmov s16, r0
; CHECK-NEXT:    vmov q0, q4
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    pop {r4, r5, r7, pc}
entry:
  %0 = call fast <4 x float> @llvm.exp2.v4f32(<4 x float> %src)
  ret <4 x float> %0
}

define arm_aapcs_vfpcc <8 x half> @exp2_float16_t(<8 x half> %src) {
; CHECK-LABEL: exp2_float16_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    .vsave {d8, d9, d10, d11}
; CHECK-NEXT:    vpush {d8, d9, d10, d11}
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s16
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl exp2f
; CHECK-NEXT:    vcvtt.f32.f16 s0, s16
; CHECK-NEXT:    vmov s20, r0
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    mov r0, r1
; CHECK-NEXT:    bl exp2f
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s20, s20
; CHECK-NEXT:    vcvtt.f16.f32 s20, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s17
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl exp2f
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s21, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s17
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl exp2f
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtt.f16.f32 s21, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s18
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl exp2f
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s22, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s18
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl exp2f
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtt.f16.f32 s22, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s19
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl exp2f
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s23, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s19
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl exp2f
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtt.f16.f32 s23, s0
; CHECK-NEXT:    vmov q0, q5
; CHECK-NEXT:    vpop {d8, d9, d10, d11}
; CHECK-NEXT:    pop {r7, pc}
entry:
  %0 = call fast <8 x half> @llvm.exp2.v8f16(<8 x half> %src)
  ret <8 x half> %0
}

define arm_aapcs_vfpcc <2 x double> @exp2_float64_t(<2 x double> %src) {
; CHECK-LABEL: exp2_float64_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    .vsave {d8, d9}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vmov r0, r1, d9
; CHECK-NEXT:    bl exp2
; CHECK-NEXT:    vmov r2, r3, d8
; CHECK-NEXT:    vmov d9, r0, r1
; CHECK-NEXT:    mov r0, r2
; CHECK-NEXT:    mov r1, r3
; CHECK-NEXT:    bl exp2
; CHECK-NEXT:    vmov d8, r0, r1
; CHECK-NEXT:    vmov q0, q4
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    pop {r7, pc}
entry:
  %0 = call fast <2 x double> @llvm.exp2.v2f64(<2 x double> %src)
  ret <2 x double> %0
}

define arm_aapcs_vfpcc <4 x float> @log_float32_t(<4 x float> %src) {
; CHECK-LABEL: log_float32_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r4, r5, r7, lr}
; CHECK-NEXT:    push {r4, r5, r7, lr}
; CHECK-NEXT:    .vsave {d8, d9}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vmov r0, s18
; CHECK-NEXT:    bl logf
; CHECK-NEXT:    mov r4, r0
; CHECK-NEXT:    vmov r0, s19
; CHECK-NEXT:    bl logf
; CHECK-NEXT:    vmov r1, s17
; CHECK-NEXT:    vmov r5, s16
; CHECK-NEXT:    vmov s19, r0
; CHECK-NEXT:    vmov s18, r4
; CHECK-NEXT:    mov r0, r1
; CHECK-NEXT:    bl logf
; CHECK-NEXT:    vmov s17, r0
; CHECK-NEXT:    mov r0, r5
; CHECK-NEXT:    bl logf
; CHECK-NEXT:    vmov s16, r0
; CHECK-NEXT:    vmov q0, q4
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    pop {r4, r5, r7, pc}
entry:
  %0 = call fast <4 x float> @llvm.log.v4f32(<4 x float> %src)
  ret <4 x float> %0
}

define arm_aapcs_vfpcc <8 x half> @log_float16_t(<8 x half> %src) {
; CHECK-LABEL: log_float16_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    .vsave {d8, d9, d10, d11}
; CHECK-NEXT:    vpush {d8, d9, d10, d11}
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s16
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl logf
; CHECK-NEXT:    vcvtt.f32.f16 s0, s16
; CHECK-NEXT:    vmov s20, r0
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    mov r0, r1
; CHECK-NEXT:    bl logf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s20, s20
; CHECK-NEXT:    vcvtt.f16.f32 s20, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s17
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl logf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s21, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s17
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl logf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtt.f16.f32 s21, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s18
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl logf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s22, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s18
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl logf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtt.f16.f32 s22, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s19
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl logf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s23, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s19
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl logf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtt.f16.f32 s23, s0
; CHECK-NEXT:    vmov q0, q5
; CHECK-NEXT:    vpop {d8, d9, d10, d11}
; CHECK-NEXT:    pop {r7, pc}
entry:
  %0 = call fast <8 x half> @llvm.log.v8f16(<8 x half> %src)
  ret <8 x half> %0
}

define arm_aapcs_vfpcc <2 x double> @log_float64_t(<2 x double> %src) {
; CHECK-LABEL: log_float64_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    .vsave {d8, d9}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vmov r0, r1, d9
; CHECK-NEXT:    bl log
; CHECK-NEXT:    vmov r2, r3, d8
; CHECK-NEXT:    vmov d9, r0, r1
; CHECK-NEXT:    mov r0, r2
; CHECK-NEXT:    mov r1, r3
; CHECK-NEXT:    bl log
; CHECK-NEXT:    vmov d8, r0, r1
; CHECK-NEXT:    vmov q0, q4
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    pop {r7, pc}
entry:
  %0 = call fast <2 x double> @llvm.log.v2f64(<2 x double> %src)
  ret <2 x double> %0
}

define arm_aapcs_vfpcc <4 x float> @log2_float32_t(<4 x float> %src) {
; CHECK-LABEL: log2_float32_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r4, r5, r7, lr}
; CHECK-NEXT:    push {r4, r5, r7, lr}
; CHECK-NEXT:    .vsave {d8, d9}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vmov r0, s18
; CHECK-NEXT:    bl log2f
; CHECK-NEXT:    mov r4, r0
; CHECK-NEXT:    vmov r0, s19
; CHECK-NEXT:    bl log2f
; CHECK-NEXT:    vmov r1, s17
; CHECK-NEXT:    vmov r5, s16
; CHECK-NEXT:    vmov s19, r0
; CHECK-NEXT:    vmov s18, r4
; CHECK-NEXT:    mov r0, r1
; CHECK-NEXT:    bl log2f
; CHECK-NEXT:    vmov s17, r0
; CHECK-NEXT:    mov r0, r5
; CHECK-NEXT:    bl log2f
; CHECK-NEXT:    vmov s16, r0
; CHECK-NEXT:    vmov q0, q4
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    pop {r4, r5, r7, pc}
entry:
  %0 = call fast <4 x float> @llvm.log2.v4f32(<4 x float> %src)
  ret <4 x float> %0
}

define arm_aapcs_vfpcc <8 x half> @log2_float16_t(<8 x half> %src) {
; CHECK-LABEL: log2_float16_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    .vsave {d8, d9, d10, d11}
; CHECK-NEXT:    vpush {d8, d9, d10, d11}
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s16
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl log2f
; CHECK-NEXT:    vcvtt.f32.f16 s0, s16
; CHECK-NEXT:    vmov s20, r0
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    mov r0, r1
; CHECK-NEXT:    bl log2f
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s20, s20
; CHECK-NEXT:    vcvtt.f16.f32 s20, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s17
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl log2f
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s21, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s17
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl log2f
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtt.f16.f32 s21, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s18
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl log2f
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s22, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s18
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl log2f
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtt.f16.f32 s22, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s19
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl log2f
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s23, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s19
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl log2f
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtt.f16.f32 s23, s0
; CHECK-NEXT:    vmov q0, q5
; CHECK-NEXT:    vpop {d8, d9, d10, d11}
; CHECK-NEXT:    pop {r7, pc}
entry:
  %0 = call fast <8 x half> @llvm.log2.v8f16(<8 x half> %src)
  ret <8 x half> %0
}

define arm_aapcs_vfpcc <2 x double> @log2_float64_t(<2 x double> %src) {
; CHECK-LABEL: log2_float64_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    .vsave {d8, d9}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vmov r0, r1, d9
; CHECK-NEXT:    bl log2
; CHECK-NEXT:    vmov r2, r3, d8
; CHECK-NEXT:    vmov d9, r0, r1
; CHECK-NEXT:    mov r0, r2
; CHECK-NEXT:    mov r1, r3
; CHECK-NEXT:    bl log2
; CHECK-NEXT:    vmov d8, r0, r1
; CHECK-NEXT:    vmov q0, q4
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    pop {r7, pc}
entry:
  %0 = call fast <2 x double> @llvm.log2.v2f64(<2 x double> %src)
  ret <2 x double> %0
}

define arm_aapcs_vfpcc <4 x float> @log10_float32_t(<4 x float> %src) {
; CHECK-LABEL: log10_float32_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r4, r5, r7, lr}
; CHECK-NEXT:    push {r4, r5, r7, lr}
; CHECK-NEXT:    .vsave {d8, d9}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vmov r0, s18
; CHECK-NEXT:    bl log10f
; CHECK-NEXT:    mov r4, r0
; CHECK-NEXT:    vmov r0, s19
; CHECK-NEXT:    bl log10f
; CHECK-NEXT:    vmov r1, s17
; CHECK-NEXT:    vmov r5, s16
; CHECK-NEXT:    vmov s19, r0
; CHECK-NEXT:    vmov s18, r4
; CHECK-NEXT:    mov r0, r1
; CHECK-NEXT:    bl log10f
; CHECK-NEXT:    vmov s17, r0
; CHECK-NEXT:    mov r0, r5
; CHECK-NEXT:    bl log10f
; CHECK-NEXT:    vmov s16, r0
; CHECK-NEXT:    vmov q0, q4
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    pop {r4, r5, r7, pc}
entry:
  %0 = call fast <4 x float> @llvm.log10.v4f32(<4 x float> %src)
  ret <4 x float> %0
}

define arm_aapcs_vfpcc <8 x half> @log10_float16_t(<8 x half> %src) {
; CHECK-LABEL: log10_float16_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    .vsave {d8, d9, d10, d11}
; CHECK-NEXT:    vpush {d8, d9, d10, d11}
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s16
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl log10f
; CHECK-NEXT:    vcvtt.f32.f16 s0, s16
; CHECK-NEXT:    vmov s20, r0
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    mov r0, r1
; CHECK-NEXT:    bl log10f
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s20, s20
; CHECK-NEXT:    vcvtt.f16.f32 s20, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s17
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl log10f
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s21, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s17
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl log10f
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtt.f16.f32 s21, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s18
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl log10f
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s22, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s18
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl log10f
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtt.f16.f32 s22, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s19
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl log10f
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s23, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s19
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl log10f
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtt.f16.f32 s23, s0
; CHECK-NEXT:    vmov q0, q5
; CHECK-NEXT:    vpop {d8, d9, d10, d11}
; CHECK-NEXT:    pop {r7, pc}
entry:
  %0 = call fast <8 x half> @llvm.log10.v8f16(<8 x half> %src)
  ret <8 x half> %0
}

define arm_aapcs_vfpcc <2 x double> @log10_float64_t(<2 x double> %src) {
; CHECK-LABEL: log10_float64_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    .vsave {d8, d9}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vmov r0, r1, d9
; CHECK-NEXT:    bl log10
; CHECK-NEXT:    vmov r2, r3, d8
; CHECK-NEXT:    vmov d9, r0, r1
; CHECK-NEXT:    mov r0, r2
; CHECK-NEXT:    mov r1, r3
; CHECK-NEXT:    bl log10
; CHECK-NEXT:    vmov d8, r0, r1
; CHECK-NEXT:    vmov q0, q4
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    pop {r7, pc}
entry:
  %0 = call fast <2 x double> @llvm.log10.v2f64(<2 x double> %src)
  ret <2 x double> %0
}

define arm_aapcs_vfpcc <4 x float> @pow_float32_t(<4 x float> %src1, <4 x float> %src2) {
; CHECK-LABEL: pow_float32_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r4, r5, r6, lr}
; CHECK-NEXT:    push {r4, r5, r6, lr}
; CHECK-NEXT:    .vsave {d8, d9, d10, d11}
; CHECK-NEXT:    vpush {d8, d9, d10, d11}
; CHECK-NEXT:    vmov q4, q1
; CHECK-NEXT:    vmov q5, q0
; CHECK-NEXT:    vmov r0, s22
; CHECK-NEXT:    vmov r1, s18
; CHECK-NEXT:    bl powf
; CHECK-NEXT:    mov r4, r0
; CHECK-NEXT:    vmov r0, s23
; CHECK-NEXT:    vmov r1, s19
; CHECK-NEXT:    bl powf
; CHECK-NEXT:    vmov r2, s21
; CHECK-NEXT:    vmov r1, s17
; CHECK-NEXT:    vmov r6, s16
; CHECK-NEXT:    vmov s19, r0
; CHECK-NEXT:    vmov r5, s20
; CHECK-NEXT:    vmov s18, r4
; CHECK-NEXT:    mov r0, r2
; CHECK-NEXT:    bl powf
; CHECK-NEXT:    vmov s17, r0
; CHECK-NEXT:    mov r0, r5
; CHECK-NEXT:    mov r1, r6
; CHECK-NEXT:    bl powf
; CHECK-NEXT:    vmov s16, r0
; CHECK-NEXT:    vmov q0, q4
; CHECK-NEXT:    vpop {d8, d9, d10, d11}
; CHECK-NEXT:    pop {r4, r5, r6, pc}
entry:
  %0 = call fast <4 x float> @llvm.pow.v4f32(<4 x float> %src1, <4 x float> %src2)
  ret <4 x float> %0
}

define arm_aapcs_vfpcc <8 x half> @pow_float16_t(<8 x half> %src1, <8 x half> %src2) {
; CHECK-LABEL: pow_float16_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    .vsave {d8, d9, d10, d11, d12, d13}
; CHECK-NEXT:    vpush {d8, d9, d10, d11, d12, d13}
; CHECK-NEXT:    vmov q5, q0
; CHECK-NEXT:    vmov q4, q1
; CHECK-NEXT:    vcvtb.f32.f16 s0, s20
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s16
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    bl powf
; CHECK-NEXT:    vcvtt.f32.f16 s0, s20
; CHECK-NEXT:    vmov s24, r0
; CHECK-NEXT:    vmov r2, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s16
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    mov r0, r2
; CHECK-NEXT:    bl powf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s24, s24
; CHECK-NEXT:    vcvtt.f16.f32 s24, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s21
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s17
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    bl powf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s25, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s21
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s17
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    bl powf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtt.f16.f32 s25, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s22
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s18
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    bl powf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s26, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s22
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s18
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    bl powf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtt.f16.f32 s26, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s23
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s19
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    bl powf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s27, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s23
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    vcvtt.f32.f16 s0, s19
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    bl powf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtt.f16.f32 s27, s0
; CHECK-NEXT:    vmov q0, q6
; CHECK-NEXT:    vpop {d8, d9, d10, d11, d12, d13}
; CHECK-NEXT:    pop {r7, pc}
entry:
  %0 = call fast <8 x half> @llvm.pow.v8f16(<8 x half> %src1, <8 x half> %src2)
  ret <8 x half> %0
}

define arm_aapcs_vfpcc <2 x double> @pow_float64_t(<2 x double> %src1, <2 x double> %src2) {
; CHECK-LABEL: pow_float64_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    .vsave {d8, d9, d10, d11}
; CHECK-NEXT:    vpush {d8, d9, d10, d11}
; CHECK-NEXT:    vmov q4, q1
; CHECK-NEXT:    vmov q5, q0
; CHECK-NEXT:    vmov r0, r1, d11
; CHECK-NEXT:    vmov r2, r3, d9
; CHECK-NEXT:    bl pow
; CHECK-NEXT:    vmov lr, r12, d10
; CHECK-NEXT:    vmov r2, r3, d8
; CHECK-NEXT:    vmov d9, r0, r1
; CHECK-NEXT:    mov r0, lr
; CHECK-NEXT:    mov r1, r12
; CHECK-NEXT:    bl pow
; CHECK-NEXT:    vmov d8, r0, r1
; CHECK-NEXT:    vmov q0, q4
; CHECK-NEXT:    vpop {d8, d9, d10, d11}
; CHECK-NEXT:    pop {r7, pc}
entry:
  %0 = call fast <2 x double> @llvm.pow.v2f64(<2 x double> %src1, <2 x double> %src2)
  ret <2 x double> %0
}

define arm_aapcs_vfpcc <4 x float> @copysign_float32_t(<4 x float> %src1, <4 x float> %src2) {
; CHECK-LABEL: copysign_float32_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r4, r5, r7, lr}
; CHECK-NEXT:    push {r4, r5, r7, lr}
; CHECK-NEXT:    vmov r0, s5
; CHECK-NEXT:    vmov lr, s6
; CHECK-NEXT:    vmov r12, s7
; CHECK-NEXT:    vmov r3, s1
; CHECK-NEXT:    vmov r2, s2
; CHECK-NEXT:    vmov r1, s3
; CHECK-NEXT:    vmov r4, s4
; CHECK-NEXT:    vmov r5, s0
; CHECK-NEXT:    lsrs r0, r0, #31
; CHECK-NEXT:    bfi r3, r0, #31, #1
; CHECK-NEXT:    lsr.w r0, lr, #31
; CHECK-NEXT:    bfi r2, r0, #31, #1
; CHECK-NEXT:    lsr.w r0, r12, #31
; CHECK-NEXT:    bfi r1, r0, #31, #1
; CHECK-NEXT:    vmov s3, r1
; CHECK-NEXT:    lsrs r0, r4, #31
; CHECK-NEXT:    vmov s2, r2
; CHECK-NEXT:    bfi r5, r0, #31, #1
; CHECK-NEXT:    vmov s1, r3
; CHECK-NEXT:    vmov s0, r5
; CHECK-NEXT:    pop {r4, r5, r7, pc}
entry:
  %0 = call fast <4 x float> @llvm.copysign.v4f32(<4 x float> %src1, <4 x float> %src2)
  ret <4 x float> %0
}

define arm_aapcs_vfpcc <8 x half> @copysign_float16_t(<8 x half> %src1, <8 x half> %src2) {
; CHECK-LABEL: copysign_float16_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .pad #32
; CHECK-NEXT:    sub sp, #32
; CHECK-NEXT:    vmovx.f16 s8, s4
; CHECK-NEXT:    vstr.16 s8, [sp, #24]
; CHECK-NEXT:    vmovx.f16 s8, s5
; CHECK-NEXT:    vstr.16 s4, [sp, #28]
; CHECK-NEXT:    vstr.16 s8, [sp, #16]
; CHECK-NEXT:    vmovx.f16 s8, s6
; CHECK-NEXT:    vstr.16 s5, [sp, #20]
; CHECK-NEXT:    vstr.16 s8, [sp, #8]
; CHECK-NEXT:    vmovx.f16 s8, s7
; CHECK-NEXT:    vstr.16 s6, [sp, #12]
; CHECK-NEXT:    vstr.16 s8, [sp]
; CHECK-NEXT:    vstr.16 s7, [sp, #4]
; CHECK-NEXT:    vmovx.f16 s4, s0
; CHECK-NEXT:    ldrb.w r0, [sp, #25]
; CHECK-NEXT:    vabs.f16 s4, s4
; CHECK-NEXT:    vneg.f16 s6, s4
; CHECK-NEXT:    tst.w r0, #128
; CHECK-NEXT:    cset r0, ne
; CHECK-NEXT:    lsls r0, r0, #31
; CHECK-NEXT:    ldrb.w r0, [sp, #29]
; CHECK-NEXT:    vseleq.f16 s8, s4, s6
; CHECK-NEXT:    vabs.f16 s4, s0
; CHECK-NEXT:    vabs.f16 s0, s3
; CHECK-NEXT:    tst.w r0, #128
; CHECK-NEXT:    vneg.f16 s6, s4
; CHECK-NEXT:    cset r0, ne
; CHECK-NEXT:    lsls r0, r0, #31
; CHECK-NEXT:    ldrb.w r0, [sp, #17]
; CHECK-NEXT:    vseleq.f16 s4, s4, s6
; CHECK-NEXT:    vins.f16 s4, s8
; CHECK-NEXT:    vmovx.f16 s8, s1
; CHECK-NEXT:    tst.w r0, #128
; CHECK-NEXT:    vabs.f16 s8, s8
; CHECK-NEXT:    cset r0, ne
; CHECK-NEXT:    vneg.f16 s10, s8
; CHECK-NEXT:    lsls r0, r0, #31
; CHECK-NEXT:    ldrb.w r0, [sp, #21]
; CHECK-NEXT:    vseleq.f16 s8, s8, s10
; CHECK-NEXT:    vabs.f16 s10, s1
; CHECK-NEXT:    tst.w r0, #128
; CHECK-NEXT:    vneg.f16 s12, s10
; CHECK-NEXT:    cset r0, ne
; CHECK-NEXT:    lsls r0, r0, #31
; CHECK-NEXT:    ldrb.w r0, [sp, #9]
; CHECK-NEXT:    vseleq.f16 s5, s10, s12
; CHECK-NEXT:    vins.f16 s5, s8
; CHECK-NEXT:    vmovx.f16 s8, s2
; CHECK-NEXT:    tst.w r0, #128
; CHECK-NEXT:    vabs.f16 s8, s8
; CHECK-NEXT:    cset r0, ne
; CHECK-NEXT:    vneg.f16 s10, s8
; CHECK-NEXT:    lsls r0, r0, #31
; CHECK-NEXT:    ldrb.w r0, [sp, #13]
; CHECK-NEXT:    vseleq.f16 s8, s8, s10
; CHECK-NEXT:    vabs.f16 s10, s2
; CHECK-NEXT:    vneg.f16 s2, s0
; CHECK-NEXT:    tst.w r0, #128
; CHECK-NEXT:    vneg.f16 s12, s10
; CHECK-NEXT:    cset r0, ne
; CHECK-NEXT:    lsls r0, r0, #31
; CHECK-NEXT:    ldrb.w r0, [sp, #1]
; CHECK-NEXT:    vseleq.f16 s6, s10, s12
; CHECK-NEXT:    vins.f16 s6, s8
; CHECK-NEXT:    vmovx.f16 s8, s3
; CHECK-NEXT:    tst.w r0, #128
; CHECK-NEXT:    vabs.f16 s8, s8
; CHECK-NEXT:    cset r0, ne
; CHECK-NEXT:    vneg.f16 s10, s8
; CHECK-NEXT:    lsls r0, r0, #31
; CHECK-NEXT:    ldrb.w r0, [sp, #5]
; CHECK-NEXT:    vseleq.f16 s8, s8, s10
; CHECK-NEXT:    tst.w r0, #128
; CHECK-NEXT:    cset r0, ne
; CHECK-NEXT:    lsls r0, r0, #31
; CHECK-NEXT:    vseleq.f16 s7, s0, s2
; CHECK-NEXT:    vins.f16 s7, s8
; CHECK-NEXT:    vmov q0, q1
; CHECK-NEXT:    add sp, #32
; CHECK-NEXT:    bx lr
entry:
  %0 = call fast <8 x half> @llvm.copysign.v8f16(<8 x half> %src1, <8 x half> %src2)
  ret <8 x half> %0
}

define arm_aapcs_vfpcc <2 x double> @copysign_float64_t(<2 x double> %src1, <2 x double> %src2) {
; CHECK-LABEL: copysign_float64_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    vmov r0, r1, d3
; CHECK-NEXT:    vmov r0, lr, d2
; CHECK-NEXT:    vmov r0, r3, d1
; CHECK-NEXT:    vmov r12, r2, d0
; CHECK-NEXT:    lsrs r1, r1, #31
; CHECK-NEXT:    bfi r3, r1, #31, #1
; CHECK-NEXT:    lsr.w r1, lr, #31
; CHECK-NEXT:    bfi r2, r1, #31, #1
; CHECK-NEXT:    vmov d1, r0, r3
; CHECK-NEXT:    vmov d0, r12, r2
; CHECK-NEXT:    pop {r7, pc}
entry:
  %0 = call fast <2 x double> @llvm.copysign.v2f64(<2 x double> %src1, <2 x double> %src2)
  ret <2 x double> %0
}

declare <4 x float> @llvm.sqrt.v4f32(<4 x float>)
declare <4 x float> @llvm.cos.v4f32(<4 x float>)
declare <4 x float> @llvm.sin.v4f32(<4 x float>)
declare <4 x float> @llvm.exp.v4f32(<4 x float>)
declare <4 x float> @llvm.exp2.v4f32(<4 x float>)
declare <4 x float> @llvm.log.v4f32(<4 x float>)
declare <4 x float> @llvm.log2.v4f32(<4 x float>)
declare <4 x float> @llvm.log10.v4f32(<4 x float>)
declare <4 x float> @llvm.pow.v4f32(<4 x float>, <4 x float>)
declare <4 x float> @llvm.copysign.v4f32(<4 x float>, <4 x float>)
declare <8 x half> @llvm.sqrt.v8f16(<8 x half>)
declare <8 x half> @llvm.cos.v8f16(<8 x half>)
declare <8 x half> @llvm.sin.v8f16(<8 x half>)
declare <8 x half> @llvm.exp.v8f16(<8 x half>)
declare <8 x half> @llvm.exp2.v8f16(<8 x half>)
declare <8 x half> @llvm.log.v8f16(<8 x half>)
declare <8 x half> @llvm.log2.v8f16(<8 x half>)
declare <8 x half> @llvm.log10.v8f16(<8 x half>)
declare <8 x half> @llvm.pow.v8f16(<8 x half>, <8 x half>)
declare <8 x half> @llvm.copysign.v8f16(<8 x half>, <8 x half>)
declare <2 x double> @llvm.sqrt.v2f64(<2 x double>)
declare <2 x double> @llvm.cos.v2f64(<2 x double>)
declare <2 x double> @llvm.sin.v2f64(<2 x double>)
declare <2 x double> @llvm.exp.v2f64(<2 x double>)
declare <2 x double> @llvm.exp2.v2f64(<2 x double>)
declare <2 x double> @llvm.log.v2f64(<2 x double>)
declare <2 x double> @llvm.log2.v2f64(<2 x double>)
declare <2 x double> @llvm.log10.v2f64(<2 x double>)
declare <2 x double> @llvm.pow.v2f64(<2 x double>, <2 x double>)
declare <2 x double> @llvm.copysign.v2f64(<2 x double>, <2 x double>)

