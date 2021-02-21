; NOTE: Assertions have been autogenerated by utils/update_analyze_test_checks.py
; RUN: opt < %s -analyze -enable-new-pm=0 -scalar-evolution -scalar-evolution-huge-expr-threshold=1 | FileCheck %s
; RUN: opt < %s -disable-output "-passes=print<scalar-evolution>" -scalar-evolution-huge-expr-threshold=1 2>&1 | FileCheck %s

define void @test(i32 %a, i32 %b, i32 %c, i32 %d, i32 %e, i32 %f) {
; CHECK-LABEL: 'test'
; CHECK-NEXT:  Classifying expressions for: @test
; CHECK-NEXT:    %add1 = add i32 %a, %b
; CHECK-NEXT:    --> (%a + %b) U: full-set S: full-set
; CHECK-NEXT:    %add2 = add i32 %add1, %c
; CHECK-NEXT:    --> ((%a + %b) + %c) U: full-set S: full-set
; CHECK-NEXT:    %add3 = add i32 %add2, %d
; CHECK-NEXT:    --> (((%a + %b) + %c) + %d) U: full-set S: full-set
; CHECK-NEXT:    %add4 = add i32 %add3, %e
; CHECK-NEXT:    --> ((((%a + %b) + %c) + %d) + %e) U: full-set S: full-set
; CHECK-NEXT:    %add5 = add i32 %add4, %f
; CHECK-NEXT:    --> (((((%a + %b) + %c) + %d) + %e) + %f) U: full-set S: full-set
; CHECK-NEXT:    %mul1 = mul i32 %a, %b
; CHECK-NEXT:    --> (%a * %b) U: full-set S: full-set
; CHECK-NEXT:    %mul2 = mul i32 %mul1, %c
; CHECK-NEXT:    --> ((%a * %b) * %c) U: full-set S: full-set
; CHECK-NEXT:    %mul3 = mul i32 %mul2, %d
; CHECK-NEXT:    --> (((%a * %b) * %c) * %d) U: full-set S: full-set
; CHECK-NEXT:    %mul4 = mul i32 %mul3, %e
; CHECK-NEXT:    --> ((((%a * %b) * %c) * %d) * %e) U: full-set S: full-set
; CHECK-NEXT:    %mul5 = mul i32 %mul4, %f
; CHECK-NEXT:    --> (((((%a * %b) * %c) * %d) * %e) * %f) U: full-set S: full-set
; CHECK-NEXT:  Determining loop execution counts for: @test
;
  %add1 = add i32 %a, %b
  %add2 = add i32 %add1, %c
  %add3 = add i32 %add2, %d
  %add4 = add i32 %add3, %e
  %add5 = add i32 %add4, %f

  %mul1 = mul i32 %a, %b
  %mul2 = mul i32 %mul1, %c
  %mul3 = mul i32 %mul2, %d
  %mul4 = mul i32 %mul3, %e
  %mul5 = mul i32 %mul4, %f
  ret void
}
