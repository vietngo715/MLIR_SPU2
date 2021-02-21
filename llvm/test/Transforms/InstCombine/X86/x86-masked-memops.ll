; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -mtriple=x86_64-unknown-unknown -S | FileCheck %s

;; MASKED LOADS

; If the mask isn't constant, do nothing.

define <4 x float> @mload(i8* %f, <4 x i32> %mask) {
; CHECK-LABEL: @mload(
; CHECK-NEXT:    [[LD:%.*]] = tail call <4 x float> @llvm.x86.avx.maskload.ps(i8* [[F:%.*]], <4 x i32> [[MASK:%.*]])
; CHECK-NEXT:    ret <4 x float> [[LD]]
;
  %ld = tail call <4 x float> @llvm.x86.avx.maskload.ps(i8* %f, <4 x i32> %mask)
  ret <4 x float> %ld
}

; If the mask comes from a comparison, convert to an LLVM intrinsic. The backend should optimize further.

define <4 x float> @mload_v4f32_cmp(i8* %f, <4 x i32> %src) {
; CHECK-LABEL: @mload_v4f32_cmp(
; CHECK-NEXT:    [[ICMP:%.*]] = icmp ne <4 x i32> [[SRC:%.*]], zeroinitializer
; CHECK-NEXT:    [[CASTVEC:%.*]] = bitcast i8* [[F:%.*]] to <4 x float>*
; CHECK-NEXT:    [[TMP1:%.*]] = call <4 x float> @llvm.masked.load.v4f32.p0v4f32(<4 x float>* [[CASTVEC]], i32 1, <4 x i1> [[ICMP]], <4 x float> zeroinitializer)
; CHECK-NEXT:    ret <4 x float> [[TMP1]]
;
  %icmp = icmp ne <4 x i32> %src, zeroinitializer
  %mask = sext <4 x i1> %icmp to <4 x i32>
  %ld = tail call <4 x float> @llvm.x86.avx.maskload.ps(i8* %f, <4 x i32> %mask)
  ret <4 x float> %ld
}

; Zero mask returns a zero vector.

define <4 x float> @mload_zeros(i8* %f) {
; CHECK-LABEL: @mload_zeros(
; CHECK-NEXT:    ret <4 x float> zeroinitializer
;
  %ld = tail call <4 x float> @llvm.x86.avx.maskload.ps(i8* %f, <4 x i32> zeroinitializer)
  ret <4 x float> %ld
}

; Only the sign bit matters.

define <4 x float> @mload_fake_ones(i8* %f) {
; CHECK-LABEL: @mload_fake_ones(
; CHECK-NEXT:    ret <4 x float> zeroinitializer
;
  %ld = tail call <4 x float> @llvm.x86.avx.maskload.ps(i8* %f, <4 x i32> <i32 1, i32 2, i32 3, i32 2147483647>)
  ret <4 x float> %ld
}

; All mask bits are set, so this is just a vector load.

define <4 x float> @mload_real_ones(i8* %f) {
; CHECK-LABEL: @mload_real_ones(
; CHECK-NEXT:    [[CASTVEC:%.*]] = bitcast i8* [[F:%.*]] to <4 x float>*
; CHECK-NEXT:    [[UNMASKEDLOAD:%.*]] = load <4 x float>, <4 x float>* [[CASTVEC]], align 1
; CHECK-NEXT:    ret <4 x float> [[UNMASKEDLOAD]]
;
  %ld = tail call <4 x float> @llvm.x86.avx.maskload.ps(i8* %f, <4 x i32> <i32 -1, i32 -2, i32 -3, i32 2147483648>)
  ret <4 x float> %ld
}

; It's a constant mask, so convert to an LLVM intrinsic. The backend should optimize further.

define <4 x float> @mload_one_one(i8* %f) {
; CHECK-LABEL: @mload_one_one(
; CHECK-NEXT:    [[CASTVEC:%.*]] = bitcast i8* [[F:%.*]] to <4 x float>*
; CHECK-NEXT:    [[TMP1:%.*]] = call <4 x float> @llvm.masked.load.v4f32.p0v4f32(<4 x float>* [[CASTVEC]], i32 1, <4 x i1> <i1 false, i1 false, i1 false, i1 true>, <4 x float> <float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float poison>)
; CHECK-NEXT:    ret <4 x float> [[TMP1]]
;
  %ld = tail call <4 x float> @llvm.x86.avx.maskload.ps(i8* %f, <4 x i32> <i32 0, i32 0, i32 0, i32 -1>)
  ret <4 x float> %ld
}

; Try doubles.

define <2 x double> @mload_one_one_double(i8* %f) {
; CHECK-LABEL: @mload_one_one_double(
; CHECK-NEXT:    [[CASTVEC:%.*]] = bitcast i8* [[F:%.*]] to <2 x double>*
; CHECK-NEXT:    [[TMP1:%.*]] = call <2 x double> @llvm.masked.load.v2f64.p0v2f64(<2 x double>* [[CASTVEC]], i32 1, <2 x i1> <i1 true, i1 false>, <2 x double> <double poison, double 0.000000e+00>)
; CHECK-NEXT:    ret <2 x double> [[TMP1]]
;
  %ld = tail call <2 x double> @llvm.x86.avx.maskload.pd(i8* %f, <2 x i64> <i64 -1, i64 0>)
  ret <2 x double> %ld
}

; Try 256-bit FP ops.

define <8 x float> @mload_v8f32(i8* %f) {
; CHECK-LABEL: @mload_v8f32(
; CHECK-NEXT:    [[CASTVEC:%.*]] = bitcast i8* [[F:%.*]] to <8 x float>*
; CHECK-NEXT:    [[TMP1:%.*]] = call <8 x float> @llvm.masked.load.v8f32.p0v8f32(<8 x float>* [[CASTVEC]], i32 1, <8 x i1> <i1 false, i1 false, i1 false, i1 true, i1 false, i1 false, i1 false, i1 false>, <8 x float> <float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float poison, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>)
; CHECK-NEXT:    ret <8 x float> [[TMP1]]
;
  %ld = tail call <8 x float> @llvm.x86.avx.maskload.ps.256(i8* %f, <8 x i32> <i32 0, i32 0, i32 0, i32 -1, i32 0, i32 0, i32 0, i32 0>)
  ret <8 x float> %ld
}

define <8 x float> @mload_v8f32_cmp(i8* %f, <8 x float> %src0, <8 x float> %src1) {
; CHECK-LABEL: @mload_v8f32_cmp(
; CHECK-NEXT:    [[ICMP0:%.*]] = fcmp one <8 x float> [[SRC0:%.*]], zeroinitializer
; CHECK-NEXT:    [[ICMP1:%.*]] = fcmp one <8 x float> [[SRC1:%.*]], zeroinitializer
; CHECK-NEXT:    [[MASK1:%.*]] = and <8 x i1> [[ICMP0]], [[ICMP1]]
; CHECK-NEXT:    [[CASTVEC:%.*]] = bitcast i8* [[F:%.*]] to <8 x float>*
; CHECK-NEXT:    [[TMP1:%.*]] = call <8 x float> @llvm.masked.load.v8f32.p0v8f32(<8 x float>* [[CASTVEC]], i32 1, <8 x i1> [[MASK1]], <8 x float> zeroinitializer)
; CHECK-NEXT:    ret <8 x float> [[TMP1]]
;
  %icmp0 = fcmp one <8 x float> %src0, zeroinitializer
  %icmp1 = fcmp one <8 x float> %src1, zeroinitializer
  %ext0 = sext <8 x i1> %icmp0 to <8 x i32>
  %ext1 = sext <8 x i1> %icmp1 to <8 x i32>
  %mask = and <8 x i32> %ext0, %ext1
  %ld = tail call <8 x float> @llvm.x86.avx.maskload.ps.256(i8* %f, <8 x i32> %mask)
  ret <8 x float> %ld
}

define <4 x double> @mload_v4f64(i8* %f) {
; CHECK-LABEL: @mload_v4f64(
; CHECK-NEXT:    [[CASTVEC:%.*]] = bitcast i8* [[F:%.*]] to <4 x double>*
; CHECK-NEXT:    [[TMP1:%.*]] = call <4 x double> @llvm.masked.load.v4f64.p0v4f64(<4 x double>* [[CASTVEC]], i32 1, <4 x i1> <i1 true, i1 false, i1 false, i1 false>, <4 x double> <double poison, double 0.000000e+00, double 0.000000e+00, double 0.000000e+00>)
; CHECK-NEXT:    ret <4 x double> [[TMP1]]
;
  %ld = tail call <4 x double> @llvm.x86.avx.maskload.pd.256(i8* %f, <4 x i64> <i64 -1, i64 0, i64 0, i64 0>)
  ret <4 x double> %ld
}

; Try the AVX2 variants.

define <4 x i32> @mload_v4i32(i8* %f) {
; CHECK-LABEL: @mload_v4i32(
; CHECK-NEXT:    [[CASTVEC:%.*]] = bitcast i8* [[F:%.*]] to <4 x i32>*
; CHECK-NEXT:    [[TMP1:%.*]] = call <4 x i32> @llvm.masked.load.v4i32.p0v4i32(<4 x i32>* [[CASTVEC]], i32 1, <4 x i1> <i1 false, i1 false, i1 false, i1 true>, <4 x i32> <i32 0, i32 0, i32 0, i32 poison>)
; CHECK-NEXT:    ret <4 x i32> [[TMP1]]
;
  %ld = tail call <4 x i32> @llvm.x86.avx2.maskload.d(i8* %f, <4 x i32> <i32 0, i32 0, i32 0, i32 -1>)
  ret <4 x i32> %ld
}

define <2 x i64> @mload_v2i64(i8* %f) {
; CHECK-LABEL: @mload_v2i64(
; CHECK-NEXT:    [[CASTVEC:%.*]] = bitcast i8* [[F:%.*]] to <2 x i64>*
; CHECK-NEXT:    [[TMP1:%.*]] = call <2 x i64> @llvm.masked.load.v2i64.p0v2i64(<2 x i64>* [[CASTVEC]], i32 1, <2 x i1> <i1 true, i1 false>, <2 x i64> <i64 poison, i64 0>)
; CHECK-NEXT:    ret <2 x i64> [[TMP1]]
;
  %ld = tail call <2 x i64> @llvm.x86.avx2.maskload.q(i8* %f, <2 x i64> <i64 -1, i64 0>)
  ret <2 x i64> %ld
}

define <8 x i32> @mload_v8i32(i8* %f) {
; CHECK-LABEL: @mload_v8i32(
; CHECK-NEXT:    [[CASTVEC:%.*]] = bitcast i8* [[F:%.*]] to <8 x i32>*
; CHECK-NEXT:    [[TMP1:%.*]] = call <8 x i32> @llvm.masked.load.v8i32.p0v8i32(<8 x i32>* [[CASTVEC]], i32 1, <8 x i1> <i1 false, i1 false, i1 false, i1 true, i1 false, i1 false, i1 false, i1 false>, <8 x i32> <i32 0, i32 0, i32 0, i32 poison, i32 0, i32 0, i32 0, i32 0>)
; CHECK-NEXT:    ret <8 x i32> [[TMP1]]
;
  %ld = tail call <8 x i32> @llvm.x86.avx2.maskload.d.256(i8* %f, <8 x i32> <i32 0, i32 0, i32 0, i32 -1, i32 0, i32 0, i32 0, i32 0>)
  ret <8 x i32> %ld
}

define <4 x i64> @mload_v4i64(i8* %f) {
; CHECK-LABEL: @mload_v4i64(
; CHECK-NEXT:    [[CASTVEC:%.*]] = bitcast i8* [[F:%.*]] to <4 x i64>*
; CHECK-NEXT:    [[TMP1:%.*]] = call <4 x i64> @llvm.masked.load.v4i64.p0v4i64(<4 x i64>* [[CASTVEC]], i32 1, <4 x i1> <i1 true, i1 false, i1 false, i1 false>, <4 x i64> <i64 poison, i64 0, i64 0, i64 0>)
; CHECK-NEXT:    ret <4 x i64> [[TMP1]]
;
  %ld = tail call <4 x i64> @llvm.x86.avx2.maskload.q.256(i8* %f, <4 x i64> <i64 -1, i64 0, i64 0, i64 0>)
  ret <4 x i64> %ld
}

define <4 x i64> @mload_v4i64_cmp(i8* %f, <4 x i64> %src) {
; CHECK-LABEL: @mload_v4i64_cmp(
; CHECK-NEXT:    [[SRC_LOBIT:%.*]] = ashr <4 x i64> [[SRC:%.*]], <i64 63, i64 63, i64 63, i64 63>
; CHECK-NEXT:    [[SRC_LOBIT_NOT:%.*]] = xor <4 x i64> [[SRC_LOBIT]], <i64 -1, i64 -1, i64 -1, i64 -1>
; CHECK-NEXT:    [[LD:%.*]] = tail call <4 x i64> @llvm.x86.avx2.maskload.q.256(i8* [[F:%.*]], <4 x i64> [[SRC_LOBIT_NOT]])
; CHECK-NEXT:    ret <4 x i64> [[LD]]
;
  %icmp = icmp sge <4 x i64> %src, zeroinitializer
  %mask = sext <4 x i1> %icmp to <4 x i64>
  %ld = tail call <4 x i64> @llvm.x86.avx2.maskload.q.256(i8* %f, <4 x i64> %mask)
  ret <4 x i64> %ld
}

;; MASKED STORES

; If the mask isn't constant, do nothing.

define void @mstore(i8* %f, <4 x i32> %mask, <4 x float> %v) {
; CHECK-LABEL: @mstore(
; CHECK-NEXT:    tail call void @llvm.x86.avx.maskstore.ps(i8* [[F:%.*]], <4 x i32> [[MASK:%.*]], <4 x float> [[V:%.*]])
; CHECK-NEXT:    ret void
;
  tail call void @llvm.x86.avx.maskstore.ps(i8* %f, <4 x i32> %mask, <4 x float> %v)
  ret void
}

; If the mask comes from a comparison, convert to an LLVM intrinsic. The backend should optimize further.

define void @mstore_v4f32_cmp(i8* %f, <4 x i32> %src, <4 x float> %v) {
; CHECK-LABEL: @mstore_v4f32_cmp(
; CHECK-NEXT:    [[ICMP:%.*]] = icmp eq <4 x i32> [[SRC:%.*]], zeroinitializer
; CHECK-NEXT:    [[CASTVEC:%.*]] = bitcast i8* [[F:%.*]] to <4 x float>*
; CHECK-NEXT:    call void @llvm.masked.store.v4f32.p0v4f32(<4 x float> [[V:%.*]], <4 x float>* [[CASTVEC]], i32 1, <4 x i1> [[ICMP]])
; CHECK-NEXT:    ret void
;
  %icmp = icmp eq <4 x i32> %src, zeroinitializer
  %mask = sext <4 x i1> %icmp to <4 x i32>
  tail call void @llvm.x86.avx.maskstore.ps(i8* %f, <4 x i32> %mask, <4 x float> %v)
  ret void
}

; Zero mask is a nop.

define void @mstore_zeros(i8* %f, <4 x float> %v)  {
; CHECK-LABEL: @mstore_zeros(
; CHECK-NEXT:    ret void
;
  tail call void @llvm.x86.avx.maskstore.ps(i8* %f, <4 x i32> zeroinitializer, <4 x float> %v)
  ret void
}

; Only the sign bit matters.

define void @mstore_fake_ones(i8* %f, <4 x float> %v) {
; CHECK-LABEL: @mstore_fake_ones(
; CHECK-NEXT:    ret void
;
  tail call void @llvm.x86.avx.maskstore.ps(i8* %f, <4 x i32> <i32 1, i32 2, i32 3, i32 2147483647>, <4 x float> %v)
  ret void
}

; All mask bits are set, so this is just a vector store.

define void @mstore_real_ones(i8* %f, <4 x float> %v) {
; CHECK-LABEL: @mstore_real_ones(
; CHECK-NEXT:    [[CASTVEC:%.*]] = bitcast i8* [[F:%.*]] to <4 x float>*
; CHECK-NEXT:    store <4 x float> [[V:%.*]], <4 x float>* [[CASTVEC]], align 1
; CHECK-NEXT:    ret void
;
  tail call void @llvm.x86.avx.maskstore.ps(i8* %f, <4 x i32> <i32 -1, i32 -2, i32 -3, i32 -2147483648>, <4 x float> %v)
  ret void
}

; It's a constant mask, so convert to an LLVM intrinsic. The backend should optimize further.

define void @mstore_one_one(i8* %f, <4 x float> %v) {
; CHECK-LABEL: @mstore_one_one(
; CHECK-NEXT:    [[CASTVEC:%.*]] = bitcast i8* [[F:%.*]] to <4 x float>*
; CHECK-NEXT:    call void @llvm.masked.store.v4f32.p0v4f32(<4 x float> [[V:%.*]], <4 x float>* [[CASTVEC]], i32 1, <4 x i1> <i1 false, i1 false, i1 false, i1 true>)
; CHECK-NEXT:    ret void
;
  tail call void @llvm.x86.avx.maskstore.ps(i8* %f, <4 x i32> <i32 0, i32 0, i32 0, i32 -1>, <4 x float> %v)
  ret void
}

; Try doubles.

define void @mstore_one_one_double(i8* %f, <2 x double> %v) {
; CHECK-LABEL: @mstore_one_one_double(
; CHECK-NEXT:    [[CASTVEC:%.*]] = bitcast i8* [[F:%.*]] to <2 x double>*
; CHECK-NEXT:    call void @llvm.masked.store.v2f64.p0v2f64(<2 x double> [[V:%.*]], <2 x double>* [[CASTVEC]], i32 1, <2 x i1> <i1 true, i1 false>)
; CHECK-NEXT:    ret void
;
  tail call void @llvm.x86.avx.maskstore.pd(i8* %f, <2 x i64> <i64 -1, i64 0>, <2 x double> %v)
  ret void
}

; Try 256-bit FP ops.

define void @mstore_v8f32(i8* %f, <8 x float> %v) {
; CHECK-LABEL: @mstore_v8f32(
; CHECK-NEXT:    [[CASTVEC:%.*]] = bitcast i8* [[F:%.*]] to <8 x float>*
; CHECK-NEXT:    call void @llvm.masked.store.v8f32.p0v8f32(<8 x float> [[V:%.*]], <8 x float>* [[CASTVEC]], i32 1, <8 x i1> <i1 false, i1 false, i1 false, i1 false, i1 true, i1 true, i1 true, i1 true>)
; CHECK-NEXT:    ret void
;
  tail call void @llvm.x86.avx.maskstore.ps.256(i8* %f, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 -1, i32 -2, i32 -3, i32 -4>, <8 x float> %v)
  ret void
}

define void @mstore_v4f64(i8* %f, <4 x double> %v) {
; CHECK-LABEL: @mstore_v4f64(
; CHECK-NEXT:    [[CASTVEC:%.*]] = bitcast i8* [[F:%.*]] to <4 x double>*
; CHECK-NEXT:    call void @llvm.masked.store.v4f64.p0v4f64(<4 x double> [[V:%.*]], <4 x double>* [[CASTVEC]], i32 1, <4 x i1> <i1 true, i1 false, i1 false, i1 false>)
; CHECK-NEXT:    ret void
;
  tail call void @llvm.x86.avx.maskstore.pd.256(i8* %f, <4 x i64> <i64 -1, i64 0, i64 1, i64 2>, <4 x double> %v)
  ret void
}

define void @mstore_v4f64_cmp(i8* %f, <4 x i32> %src, <4 x double> %v) {
; CHECK-LABEL: @mstore_v4f64_cmp(
; CHECK-NEXT:    [[SRC_LOBIT:%.*]] = ashr <4 x i32> [[SRC:%.*]], <i32 31, i32 31, i32 31, i32 31>
; CHECK-NEXT:    [[TMP1:%.*]] = xor <4 x i32> [[SRC_LOBIT]], <i32 -1, i32 -1, i32 -1, i32 -1>
; CHECK-NEXT:    [[DOTNOT:%.*]] = sext <4 x i32> [[TMP1]] to <4 x i64>
; CHECK-NEXT:    tail call void @llvm.x86.avx.maskstore.pd.256(i8* [[F:%.*]], <4 x i64> [[DOTNOT]], <4 x double> [[V:%.*]])
; CHECK-NEXT:    ret void
;
  %icmp = icmp sge <4 x i32> %src, zeroinitializer
  %mask = sext <4 x i1> %icmp to <4 x i64>
  tail call void @llvm.x86.avx.maskstore.pd.256(i8* %f, <4 x i64> %mask, <4 x double> %v)
  ret void
}

; Try the AVX2 variants.

define void @mstore_v4i32(i8* %f, <4 x i32> %v) {
; CHECK-LABEL: @mstore_v4i32(
; CHECK-NEXT:    [[CASTVEC:%.*]] = bitcast i8* [[F:%.*]] to <4 x i32>*
; CHECK-NEXT:    call void @llvm.masked.store.v4i32.p0v4i32(<4 x i32> [[V:%.*]], <4 x i32>* [[CASTVEC]], i32 1, <4 x i1> <i1 false, i1 false, i1 true, i1 true>)
; CHECK-NEXT:    ret void
;
  tail call void @llvm.x86.avx2.maskstore.d(i8* %f, <4 x i32> <i32 0, i32 1, i32 -1, i32 -2>, <4 x i32> %v)
  ret void
}

define void @mstore_v2i64(i8* %f, <2 x i64> %v) {
; CHECK-LABEL: @mstore_v2i64(
; CHECK-NEXT:    [[CASTVEC:%.*]] = bitcast i8* [[F:%.*]] to <2 x i64>*
; CHECK-NEXT:    call void @llvm.masked.store.v2i64.p0v2i64(<2 x i64> [[V:%.*]], <2 x i64>* [[CASTVEC]], i32 1, <2 x i1> <i1 true, i1 false>)
; CHECK-NEXT:    ret void
;
  tail call void @llvm.x86.avx2.maskstore.q(i8* %f, <2 x i64> <i64 -1, i64 0>, <2 x i64> %v)
  ret void

}

define void @mstore_v8i32(i8* %f, <8 x i32> %v) {
; CHECK-LABEL: @mstore_v8i32(
; CHECK-NEXT:    [[CASTVEC:%.*]] = bitcast i8* [[F:%.*]] to <8 x i32>*
; CHECK-NEXT:    call void @llvm.masked.store.v8i32.p0v8i32(<8 x i32> [[V:%.*]], <8 x i32>* [[CASTVEC]], i32 1, <8 x i1> <i1 false, i1 false, i1 false, i1 false, i1 true, i1 true, i1 true, i1 true>)
; CHECK-NEXT:    ret void
;
  tail call void @llvm.x86.avx2.maskstore.d.256(i8* %f, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 -1, i32 -2, i32 -3, i32 -4>, <8 x i32> %v)
  ret void
}

define void @mstore_v4i64(i8* %f, <4 x i64> %v) {
; CHECK-LABEL: @mstore_v4i64(
; CHECK-NEXT:    [[CASTVEC:%.*]] = bitcast i8* [[F:%.*]] to <4 x i64>*
; CHECK-NEXT:    call void @llvm.masked.store.v4i64.p0v4i64(<4 x i64> [[V:%.*]], <4 x i64>* [[CASTVEC]], i32 1, <4 x i1> <i1 true, i1 false, i1 false, i1 false>)
; CHECK-NEXT:    ret void
;
  tail call void @llvm.x86.avx2.maskstore.q.256(i8* %f, <4 x i64> <i64 -1, i64 0, i64 1, i64 2>, <4 x i64> %v)
  ret void
}

define void @mstore_v4i64_cmp(i8* %f, <4 x i64> %src0, <4 x i64> %src1, <4 x i64> %v) {
; CHECK-LABEL: @mstore_v4i64_cmp(
; CHECK-NEXT:    [[ICMP0:%.*]] = icmp eq <4 x i64> [[SRC0:%.*]], zeroinitializer
; CHECK-NEXT:    [[ICMP1:%.*]] = icmp ne <4 x i64> [[SRC1:%.*]], zeroinitializer
; CHECK-NEXT:    [[MASK1:%.*]] = and <4 x i1> [[ICMP0]], [[ICMP1]]
; CHECK-NEXT:    [[CASTVEC:%.*]] = bitcast i8* [[F:%.*]] to <4 x i64>*
; CHECK-NEXT:    call void @llvm.masked.store.v4i64.p0v4i64(<4 x i64> [[V:%.*]], <4 x i64>* [[CASTVEC]], i32 1, <4 x i1> [[MASK1]])
; CHECK-NEXT:    ret void
;
  %icmp0 = icmp eq <4 x i64> %src0, zeroinitializer
  %icmp1 = icmp ne <4 x i64> %src1, zeroinitializer
  %ext0 = sext <4 x i1> %icmp0 to <4 x i64>
  %ext1 = sext <4 x i1> %icmp1 to <4 x i64>
  %mask = and <4 x i64> %ext0, %ext1
  tail call void @llvm.x86.avx2.maskstore.q.256(i8* %f, <4 x i64> %mask, <4 x i64> %v)
  ret void
}

; The original SSE2 masked store variant.

define void @mstore_v16i8_sse2_zeros(<16 x i8> %d, i8* %p) {
; CHECK-LABEL: @mstore_v16i8_sse2_zeros(
; CHECK-NEXT:    ret void
;
  tail call void @llvm.x86.sse2.maskmov.dqu(<16 x i8> %d, <16 x i8> zeroinitializer, i8* %p)
  ret void
}

declare <4 x float> @llvm.x86.avx.maskload.ps(i8*, <4 x i32>)
declare <2 x double> @llvm.x86.avx.maskload.pd(i8*, <2 x i64>)
declare <8 x float> @llvm.x86.avx.maskload.ps.256(i8*, <8 x i32>)
declare <4 x double> @llvm.x86.avx.maskload.pd.256(i8*, <4 x i64>)

declare <4 x i32> @llvm.x86.avx2.maskload.d(i8*, <4 x i32>)
declare <2 x i64> @llvm.x86.avx2.maskload.q(i8*, <2 x i64>)
declare <8 x i32> @llvm.x86.avx2.maskload.d.256(i8*, <8 x i32>)
declare <4 x i64> @llvm.x86.avx2.maskload.q.256(i8*, <4 x i64>)

declare void @llvm.x86.avx.maskstore.ps(i8*, <4 x i32>, <4 x float>)
declare void @llvm.x86.avx.maskstore.pd(i8*, <2 x i64>, <2 x double>)
declare void @llvm.x86.avx.maskstore.ps.256(i8*, <8 x i32>, <8 x float>)
declare void @llvm.x86.avx.maskstore.pd.256(i8*, <4 x i64>, <4 x double>)

declare void @llvm.x86.avx2.maskstore.d(i8*, <4 x i32>, <4 x i32>)
declare void @llvm.x86.avx2.maskstore.q(i8*, <2 x i64>, <2 x i64>)
declare void @llvm.x86.avx2.maskstore.d.256(i8*, <8 x i32>, <8 x i32>)
declare void @llvm.x86.avx2.maskstore.q.256(i8*, <4 x i64>, <4 x i64>)

declare void @llvm.x86.sse2.maskmov.dqu(<16 x i8>, <16 x i8>, i8*)
