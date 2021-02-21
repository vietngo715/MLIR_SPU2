; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

; PR2479
; (See also PR1800.)

define i1 @test(i32 %In) {
; CHECK-LABEL: @test(
; CHECK-NEXT:    [[C2:%.*]] = icmp eq i32 [[IN:%.*]], 15
; CHECK-NEXT:    ret i1 [[C2]]
;
  %c1 = icmp ugt i32 %In, 13
  %c2 = icmp eq i32 %In, 15
  %V = and i1 %c1, %c2
  ret i1 %V
}

define i1 @test_logical(i32 %In) {
; CHECK-LABEL: @test_logical(
; CHECK-NEXT:    [[C2:%.*]] = icmp eq i32 [[IN:%.*]], 15
; CHECK-NEXT:    ret i1 [[C2]]
;
  %c1 = icmp ugt i32 %In, 13
  %c2 = icmp eq i32 %In, 15
  %V = select i1 %c1, i1 %c2, i1 false
  ret i1 %V
}

