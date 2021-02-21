; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -mtriple=thumbv8.1m.main-none-none-eabi -mattr=+mve.fp < %s -codegenprepare -S | FileCheck -check-prefix=CHECK %s

; Sink the shufflevector/insertelement pair, followed by the trunc. The sunk instruction end up dead.
define signext i8 @dead(i16* noalias nocapture readonly %s1, i16 zeroext %x, i8* noalias nocapture %d, i32 %n) {
; CHECK-LABEL: @dead(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[N_VEC:%.*]] = and i32 [[N:%.*]], -8
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP0:%.*]] = trunc i16 [[X:%.*]] to i8
; CHECK-NEXT:    [[L6:%.*]] = getelementptr inbounds i16, i16* [[S1:%.*]], i32 [[INDEX]]
; CHECK-NEXT:    [[L7:%.*]] = bitcast i16* [[L6]] to <8 x i16>*
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <8 x i16>, <8 x i16>* [[L7]], align 2
; CHECK-NEXT:    [[L8:%.*]] = trunc <8 x i16> [[WIDE_LOAD]] to <8 x i8>
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <8 x i8> poison, i8 [[TMP0]], i32 0
; CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <8 x i8> [[TMP1]], <8 x i8> poison, <8 x i32> zeroinitializer
; CHECK-NEXT:    [[L9:%.*]] = mul <8 x i8> [[TMP2]], [[L8]]
; CHECK-NEXT:    [[L13:%.*]] = getelementptr inbounds i8, i8* [[D:%.*]], i32 [[INDEX]]
; CHECK-NEXT:    [[L14:%.*]] = bitcast i8* [[L13]] to <8 x i8>*
; CHECK-NEXT:    store <8 x i8> [[L9]], <8 x i8>* [[L14]], align 1
; CHECK-NEXT:    [[INDEX_NEXT]] = add i32 [[INDEX]], 8
; CHECK-NEXT:    [[L15:%.*]] = icmp eq i32 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[L15]], label [[EXIT:%.*]], label [[VECTOR_BODY]]
; CHECK:       exit:
; CHECK-NEXT:    ret i8 0
;
entry:
  %n.vec = and i32 %n, -8
  %l0 = trunc i16 %x to i8
  %l1 = insertelement <8 x i8> poison, i8 %l0, i32 0
  %broadcast.splat26 = shufflevector <8 x i8> %l1, <8 x i8> poison, <8 x i32> zeroinitializer
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %entry
  %index = phi i32 [ 0, %entry ], [ %index.next, %vector.body ]
  %l6 = getelementptr inbounds i16, i16* %s1, i32 %index
  %l7 = bitcast i16* %l6 to <8 x i16>*
  %wide.load = load <8 x i16>, <8 x i16>* %l7, align 2
  %l8 = trunc <8 x i16> %wide.load to <8 x i8>
  %l9 = mul <8 x i8> %broadcast.splat26, %l8
  %l13 = getelementptr inbounds i8, i8* %d, i32 %index
  %l14 = bitcast i8* %l13 to <8 x i8>*
  store <8 x i8> %l9, <8 x i8>* %l14, align 1
  %index.next = add i32 %index, 8
  %l15 = icmp eq i32 %index.next, %n.vec
  br i1 %l15, label %exit, label %vector.body

exit:                                     ; preds = %vector.body
  ret i8 0
}

; Same as above, but the shuffle has an extra use meaning it shouldnt be deleted
define signext i8 @alive(i16* noalias nocapture readonly %s1, i16 zeroext %x, i8* noalias nocapture %d, i32 %n) {
; CHECK-LABEL: @alive(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[N_VEC:%.*]] = and i32 [[N:%.*]], -8
; CHECK-NEXT:    [[L0:%.*]] = trunc i16 [[X:%.*]] to i8
; CHECK-NEXT:    [[L1:%.*]] = insertelement <8 x i8> poison, i8 [[L0]], i32 0
; CHECK-NEXT:    [[BROADCAST_SPLAT26:%.*]] = shufflevector <8 x i8> [[L1]], <8 x i8> poison, <8 x i32> zeroinitializer
; CHECK-NEXT:    [[L2:%.*]] = sub <8 x i8> zeroinitializer, [[BROADCAST_SPLAT26]]
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP0:%.*]] = trunc i16 [[X]] to i8
; CHECK-NEXT:    [[L6:%.*]] = getelementptr inbounds i16, i16* [[S1:%.*]], i32 [[INDEX]]
; CHECK-NEXT:    [[L7:%.*]] = bitcast i16* [[L6]] to <8 x i16>*
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <8 x i16>, <8 x i16>* [[L7]], align 2
; CHECK-NEXT:    [[L8:%.*]] = trunc <8 x i16> [[WIDE_LOAD]] to <8 x i8>
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <8 x i8> poison, i8 [[TMP0]], i32 0
; CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <8 x i8> [[TMP1]], <8 x i8> poison, <8 x i32> zeroinitializer
; CHECK-NEXT:    [[L9:%.*]] = mul <8 x i8> [[TMP2]], [[L8]]
; CHECK-NEXT:    [[L13:%.*]] = getelementptr inbounds i8, i8* [[D:%.*]], i32 [[INDEX]]
; CHECK-NEXT:    [[L14:%.*]] = bitcast i8* [[L13]] to <8 x i8>*
; CHECK-NEXT:    store <8 x i8> [[L9]], <8 x i8>* [[L14]], align 1
; CHECK-NEXT:    [[INDEX_NEXT]] = add i32 [[INDEX]], 8
; CHECK-NEXT:    [[L15:%.*]] = icmp eq i32 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[L15]], label [[EXIT:%.*]], label [[VECTOR_BODY]]
; CHECK:       exit:
; CHECK-NEXT:    ret i8 0
;
entry:
  %n.vec = and i32 %n, -8
  %l0 = trunc i16 %x to i8
  %l1 = insertelement <8 x i8> poison, i8 %l0, i32 0
  %broadcast.splat26 = shufflevector <8 x i8> %l1, <8 x i8> poison, <8 x i32> zeroinitializer
  %l2 = sub <8 x i8> zeroinitializer, %broadcast.splat26
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %entry
  %index = phi i32 [ 0, %entry ], [ %index.next, %vector.body ]
  %l6 = getelementptr inbounds i16, i16* %s1, i32 %index
  %l7 = bitcast i16* %l6 to <8 x i16>*
  %wide.load = load <8 x i16>, <8 x i16>* %l7, align 2
  %l8 = trunc <8 x i16> %wide.load to <8 x i8>
  %l9 = mul <8 x i8> %broadcast.splat26, %l8
  %l13 = getelementptr inbounds i8, i8* %d, i32 %index
  %l14 = bitcast i8* %l13 to <8 x i8>*
  store <8 x i8> %l9, <8 x i8>* %l14, align 1
  %index.next = add i32 %index, 8
  %l15 = icmp eq i32 %index.next, %n.vec
  br i1 %l15, label %exit, label %vector.body

exit:                                     ; preds = %vector.body
  ret i8 0
}
