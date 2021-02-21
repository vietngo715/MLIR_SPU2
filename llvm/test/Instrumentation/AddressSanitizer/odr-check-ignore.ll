; RUN: opt < %s -asan -asan-module -asan-use-private-alias=0 -enable-new-pm=0 -S | FileCheck %s --check-prefix=NOALIAS
; RUN: opt < %s -passes='asan-pipeline' -asan-use-private-alias=0 -S | FileCheck %s --check-prefix=NOALIAS
; RUN: opt < %s -asan -asan-module -asan-use-private-alias=1 -enable-new-pm=0 -S | FileCheck %s --check-prefix=ALIAS
; RUN: opt < %s -passes='asan-pipeline' -asan-use-private-alias=1 -S | FileCheck %s --check-prefix=ALIAS

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@a = global [2 x i32] zeroinitializer, align 4
@b = private global [2 x i32] zeroinitializer, align 4
@c = internal global [2 x i32] zeroinitializer, align 4
@d = unnamed_addr global [2 x i32] zeroinitializer, align 4

; NOALIAS:      @__asan_global_a = private global { i64, i64, i64, i64, i64, i64, i64, i64 } { i64 ptrtoint ({ [2 x i32], [56 x i8] }* @a to i64), i64 8, i64 64, i64 ptrtoint ([2 x i8]* @___asan_gen_.1 to i64), i64 ptrtoint ([8 x i8]* @___asan_gen_ to i64), i64 0, i64 0, i64 0 }
; NOALIAS-NEXT: @__asan_global_b = private global { i64, i64, i64, i64, i64, i64, i64, i64 } { i64 ptrtoint ({ [2 x i32], [56 x i8] }* @b to i64), i64 8, i64 64, i64 ptrtoint ([2 x i8]* @___asan_gen_.2 to i64), i64 ptrtoint ([8 x i8]* @___asan_gen_ to i64), i64 0, i64 0, i64 -1 }
; NOALIAS-NEXT: @__asan_global_c = private global { i64, i64, i64, i64, i64, i64, i64, i64 } { i64 ptrtoint ({ [2 x i32], [56 x i8] }* @c to i64), i64 8, i64 64, i64 ptrtoint ([2 x i8]* @___asan_gen_.3 to i64), i64 ptrtoint ([8 x i8]* @___asan_gen_ to i64), i64 0, i64 0, i64 -1 }
; NOALIAS-NEXT: @__asan_global_d = private global { i64, i64, i64, i64, i64, i64, i64, i64 } { i64 ptrtoint ({ [2 x i32], [56 x i8] }* @d to i64), i64 8, i64 64, i64 ptrtoint ([2 x i8]* @___asan_gen_.4 to i64), i64 ptrtoint ([8 x i8]* @___asan_gen_ to i64), i64 0, i64 0, i64 0 }

; ALIAS:      @__asan_global_a = private global { i64, i64, i64, i64, i64, i64, i64, i64 } { i64 ptrtoint ({ [2 x i32], [56 x i8] }* @0 to i64), i64 8, i64 64, i64 ptrtoint ([2 x i8]* @___asan_gen_.1 to i64), i64 ptrtoint ([8 x i8]* @___asan_gen_ to i64), i64 0, i64 0, i64 0 }
; ALIAS-NEXT: @__asan_global_b = private global { i64, i64, i64, i64, i64, i64, i64, i64 } { i64 ptrtoint ({ [2 x i32], [56 x i8] }* @1 to i64), i64 8, i64 64, i64 ptrtoint ([2 x i8]* @___asan_gen_.2 to i64), i64 ptrtoint ([8 x i8]* @___asan_gen_ to i64), i64 0, i64 0, i64 -1 }
; ALIAS-NEXT: @__asan_global_c = private global { i64, i64, i64, i64, i64, i64, i64, i64 } { i64 ptrtoint ({ [2 x i32], [56 x i8] }* @2 to i64), i64 8, i64 64, i64 ptrtoint ([2 x i8]* @___asan_gen_.3 to i64), i64 ptrtoint ([8 x i8]* @___asan_gen_ to i64), i64 0, i64 0, i64 -1 }
; ALIAS-NEXT: @__asan_global_d = private global { i64, i64, i64, i64, i64, i64, i64, i64 } { i64 ptrtoint ({ [2 x i32], [56 x i8] }* @3 to i64), i64 8, i64 64, i64 ptrtoint ([2 x i8]* @___asan_gen_.4 to i64), i64 ptrtoint ([8 x i8]* @___asan_gen_ to i64), i64 0, i64 0, i64 0 }
; ALIAS:      @0 = private alias {{.*}} @a
; ALIAS-NEXT: @1 = private alias {{.*}} @b
; ALIAS-NEXT: @2 = private alias {{.*}} @c
; ALIAS-NEXT: @3 = private alias {{.*}} @d
