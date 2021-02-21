// RUN: mlir-opt %s -split-input-file -linalg-generalize-named-ops | FileCheck %s

func @generalize_conv(%input : memref<1x225x225x3xf32>, %filter: memref<3x3x3x32xf32>, %output: memref<1x112x112x32xf32>) {
  linalg.conv(%filter, %input, %output) {dilations = [2, 3], strides = [4, 5]} : memref<3x3x3x32xf32>, memref<1x225x225x3xf32>, memref<1x112x112x32xf32>
  return
}

// CHECK: #[[FILTER_MAP:.+]] = affine_map<(d0, d1, d2, d3, d4, d5, d6) -> (d5, d6, d4, d3)>
// CHECK:  #[[INPUT_MAP:.+]] = affine_map<(d0, d1, d2, d3, d4, d5, d6) -> (d0, d1 * 4 + d5 * 2, d2 * 5 + d6 * 3, d4)>
// CHECK: #[[OUTPUT_MAP:.+]] = affine_map<(d0, d1, d2, d3, d4, d5, d6) -> (d0, d1, d2, d3)>

// CHECK: func @generalize_conv
// CHECK-SAME:  %[[INPUT:.+]]: memref<1x225x225x3xf32>
// CHECK-SAME: %[[FILTER:.+]]: memref<3x3x3x32xf32>
// CHECK-SAME: %[[OUTPUT:.+]]: memref<1x112x112x32xf32>

// CHECK: linalg.generic
// CHECK-SAME: indexing_maps = [#[[FILTER_MAP]], #[[INPUT_MAP]], #[[OUTPUT_MAP]]]
// CHECK-SAME: iterator_types = ["parallel", "parallel", "parallel", "parallel", "reduction", "window", "window"]
// CHECK-SAME:  ins(%[[FILTER]], %[[INPUT]]
// CHECK-SAME: outs(%[[OUTPUT]]

// CHECK: ^{{.*}}(%[[FILTER_ARG:.+]]: f32, %[[INPUT_ARG:.+]]: f32, %[[OUTPUT_ARG:.+]]: f32)
// CHECK:   %[[MUL:.+]] = mulf %[[FILTER_ARG]], %[[INPUT_ARG]]
// CHECK:   %[[ADD:.+]] = addf %[[MUL]], %[[OUTPUT_ARG]]
// CHECK:   linalg.yield %[[ADD]]

// -----

func @generalize_matmul_buffer(%A : memref<16x8xf32>, %B: memref<8x32xf32>, %C: memref<16x32xf32>) {
  linalg.matmul ins(%A, %B: memref<16x8xf32>, memref<8x32xf32>)
               outs(%C: memref<16x32xf32>)
  return
}


// CHECK: #[[A_MAP:.+]] = affine_map<(d0, d1, d2) -> (d0, d2)>
// CHECK: #[[B_MAP:.+]] = affine_map<(d0, d1, d2) -> (d2, d1)>
// CHECK: #[[C_MAP:.+]] = affine_map<(d0, d1, d2) -> (d0, d1)>

// CHECK: func @generalize_matmul_buffer
// CHECK-SAME: %[[A:.+]]: memref<16x8xf32>
// CHECK-SAME: %[[B:.+]]: memref<8x32xf32>
// CHECK-SAME: %[[C:.+]]: memref<16x32xf32>

// CHECK: linalg.generic
// CHECK-SAME: indexing_maps = [#[[A_MAP]], #[[B_MAP]], #[[C_MAP]]]
// CHECK-SAME: iterator_types = ["parallel", "parallel", "reduction"]
// CHECK-SAME:  ins(%[[A]], %[[B]]
// CHECK-SAME: outs(%[[C]]

// CHECK: ^{{.*}}(%[[A_ARG:.+]]: f32, %[[B_ARG:.+]]: f32, %[[C_ARG:.+]]: f32)
// CHECK:   %[[MUL:.+]] = mulf %[[A_ARG]], %[[B_ARG]] : f32
// CHECK:   %[[ADD:.+]] = addf %[[C_ARG]], %[[MUL]] : f32
// CHECK:   linalg.yield %[[ADD]] : f32

// -----

func @generalize_matmul_tensor(%A : tensor<16x8xf32>, %B: tensor<8x32xf32>, %C: tensor<16x32xf32>) -> tensor<16x32xf32> {
  %0 = linalg.matmul ins(%A, %B: tensor<16x8xf32>, tensor<8x32xf32>)
                    outs(%C: tensor<16x32xf32>) -> tensor<16x32xf32>
  return %0: tensor<16x32xf32>
}

// CHECK: func @generalize_matmul_tensor

// CHECK: linalg.generic
// CHECK-SAME:  ins(%{{.+}}, %{{.+}} : tensor<16x8xf32>, tensor<8x32xf32>)
// CHECK-SAME: outs(%{{.+}} : tensor<16x32xf32>)

// CHECK:      ^{{.*}}(%[[A_ARG:.+]]: f32, %[[B_ARG:.+]]: f32, %[[C_ARG:.+]]: f32)
// CHECK-NEXT:   %[[MUL:.+]] = mulf %[[A_ARG]], %[[B_ARG]] : f32
// CHECK-NEXT:   %[[ADD:.+]] = addf %[[C_ARG]], %[[MUL]] : f32
// CHECK-NEXT:   linalg.yield %[[ADD]] : f32
// CHECK-NEXT: -> tensor<16x32xf32>

// -----

func @depthwise_conv_2d_input_nhwc_filter_hwc(%input: memref<1x113x113x96xf32>, %filter: memref<3x3x96xf32>, %output: memref<1x56x56x96xf32>) {
  linalg.depthwise_conv_2d_input_nhwc_filter_hwc {strides = dense<2> : vector<2xi64>}
    ins(%input, %filter: memref<1x113x113x96xf32>, memref<3x3x96xf32>)
    outs(%output: memref<1x56x56x96xf32>)
  return
}

// CHECK-DAG: #[[MAP0:.+]] = affine_map<(d0, d1, d2, d3, d4, d5) -> (d0, d1 * 2 + d4, d2 * 2 + d5, d3)>
// CHECK-DAG: #[[MAP1:.+]] = affine_map<(d0, d1, d2, d3, d4, d5) -> (d4, d5, d3)>
// CHECK-DAG: #[[MAP2:.+]] = affine_map<(d0, d1, d2, d3, d4, d5) -> (d0, d1, d2, d3)>

// CHECK: func @depthwise_conv_2d_input_nhwc_filter_hwc

// CHECK: linalg.generic
// CHECK-SAME: indexing_maps = [#[[MAP0]], #[[MAP1]], #[[MAP2]]]
// CHECK-SAME: iterator_types = ["parallel", "parallel", "parallel", "parallel", "reduction", "reduction"]}
// CHECK-SAME: ins(%{{.+}}, %{{.+}} : memref<1x113x113x96xf32>, memref<3x3x96xf32>)
// CHECK-SAME: outs(%{{.+}} : memref<1x56x56x96xf32>)

// CHECK:         ^{{.+}}(%[[BBARG0:.+]]: f32, %[[BBARG1:.+]]: f32, %[[BBARG2:.+]]: f32)
// CHECK-NEXT:      %[[MUL:.+]] = mulf %[[BBARG0]], %[[BBARG1]] : f32
// CHECK-NEXT:      %[[ADD:.+]] = addf %[[BBARG2]], %[[MUL]] : f32
// CHECK-NEXT:      linalg.yield %[[ADD]] : f32

// -----

func @conv_1d_input_nwc_filter_wcf(%input: memref<?x?x?xf32>, %filter: memref<?x?x?xf32>, %output: memref<?x?x?xf32>) {
  linalg.conv_1d_input_nwc_filter_wcf {dilations = dense<1> : tensor<1xi64>,
                                       strides = dense<1> : tensor<1xi64>}
     ins (%input, %filter: memref<?x?x?xf32>, memref<?x?x?xf32>)
    outs (%output: memref<?x?x?xf32>)
  return
}
// CHECK-DAG: #[[MAP0:.+]] = affine_map<(d0, d1, d2, d3, d4) -> (d0, d1 + d3, d4)>
// CHECK-DAG: #[[MAP1:.+]] = affine_map<(d0, d1, d2, d3, d4) -> (d3, d4, d2)>
// CHECK-DAG: #[[MAP2:.+]] = affine_map<(d0, d1, d2, d3, d4) -> (d0, d1, d2)>

// CHECK: func @conv_1d_input_nwc_filter_wcf

// CHECK: linalg.generic
// CHECK-SAME: indexing_maps = [#[[MAP0]], #[[MAP1]], #[[MAP2]]]
// CHECK-SAME: iterator_types = ["parallel", "parallel", "parallel", "reduction", "parallel"]}
// CHECK-SAME: ins(%{{.+}}, %{{.+}} : memref<?x?x?xf32>, memref<?x?x?xf32>)
// CHECK-SAME: outs(%{{.+}} : memref<?x?x?xf32>)

// CHECK:         ^{{.+}}(%[[BBARG0:.+]]: f32, %[[BBARG1:.+]]: f32, %[[BBARG2:.+]]: f32)
// CHECK-NEXT:      %[[MUL:.+]] = mulf %[[BBARG0]], %[[BBARG1]] : f32
// CHECK-NEXT:      %[[ADD:.+]] = addf %[[BBARG2]], %[[MUL]] : f32
// CHECK-NEXT:      linalg.yield %[[ADD]] : f32

// -----

func @conv_1d_input_ncw_filter_wcf(%input: memref<?x?x?xf32>, %filter: memref<?x?x?xf32>, %output: memref<?x?x?xf32>) {
  linalg.conv_1d_input_ncw_filter_wcf {dilations = dense<1> : tensor<1xi64>,
                                       strides = dense<1> : tensor<1xi64>}
     ins (%input, %filter: memref<?x?x?xf32>, memref<?x?x?xf32>)
    outs (%output: memref<?x?x?xf32>)
  return
}

// CHECK-DAG: #[[MAP0:.+]] = affine_map<(d0, d1, d2, d3, d4) -> (d0, d4, d2 + d3)>
// CHECK-DAG: #[[MAP1:.+]] = affine_map<(d0, d1, d2, d3, d4) -> (d3, d4, d1)>
// CHECK-DAG: #[[MAP2:.+]] = affine_map<(d0, d1, d2, d3, d4) -> (d0, d1, d2)>

// CHECK: func @conv_1d_input_ncw_filter_wcf
// CHECK: linalg.generic
// CHECK-SAME: indexing_maps = [#[[MAP0]], #[[MAP1]], #[[MAP2]]]
// CHECK-SAME: iterator_types = ["parallel", "parallel", "parallel", "reduction", "parallel"]}
// CHECK-SAME: ins(%{{.+}}, %{{.+}} : memref<?x?x?xf32>, memref<?x?x?xf32>)
// CHECK-SAME: outs(%{{.+}} : memref<?x?x?xf32>)

// CHECK:         ^{{.+}}(%[[BBARG0:.+]]: f32, %[[BBARG1:.+]]: f32, %[[BBARG2:.+]]: f32)
// CHECK-NEXT:      %[[MUL:.+]] = mulf %[[BBARG0]], %[[BBARG1]] : f32
// CHECK-NEXT:      %[[ADD:.+]] = addf %[[BBARG2]], %[[MUL]] : f32
// CHECK-NEXT:      linalg.yield %[[ADD]] : f32

// -----

func @conv_2d_input_nhwc_filter_hwcf(%input: memref<?x?x?x?xf32>, %filter: memref<?x?x?x?xf32>, %output: memref<?x?x?x?xf32>) {
  linalg.conv_2d_input_nhwc_filter_hwcf {dilations = dense<2> : tensor<2xi64>,
                                         strides = dense<3> : tensor<2xi64>}
     ins (%input, %filter: memref<?x?x?x?xf32>, memref<?x?x?x?xf32>)
    outs (%output: memref<?x?x?x?xf32>)
  return
}

// CHECK-DAG: #[[MAP0:.+]] = affine_map<(d0, d1, d2, d3, d4, d5, d6) -> (d0, d1 * 3 + d4 * 2, d2 * 3 + d5 * 2, d6)>
// CHECK-DAG: #[[MAP1:.+]] = affine_map<(d0, d1, d2, d3, d4, d5, d6) -> (d4, d5, d6, d3)>
// CHECK-DAG: #[[MAP2:.+]] = affine_map<(d0, d1, d2, d3, d4, d5, d6) -> (d0, d1, d2, d3)>

// CHECK: func @conv_2d_input_nhwc_filter_hwcf

// CHECK: linalg.generic
// CHECK-SAME: indexing_maps = [#[[MAP0]], #[[MAP1]], #[[MAP2]]]
// CHECK-SAME: iterator_types = ["parallel", "parallel", "parallel", "parallel", "reduction", "reduction", "parallel"]}
// CHECK-SAME: ins(%{{.+}}, %{{.+}} : memref<?x?x?x?xf32>, memref<?x?x?x?xf32>)
// CHECK-SAME: outs(%{{.+}} : memref<?x?x?x?xf32>)

// CHECK:         ^{{.+}}(%[[BBARG0:.+]]: f32, %[[BBARG1:.+]]: f32, %[[BBARG2:.+]]: f32)
// CHECK-NEXT:      %[[MUL:.+]] = mulf %[[BBARG0]], %[[BBARG1]] : f32
// CHECK-NEXT:      %[[ADD:.+]] = addf %[[BBARG2]], %[[MUL]] : f32
// CHECK-NEXT:      linalg.yield %[[ADD]] : f32

// -----

func @conv_2d_input_nchw_filter_hwcf(%input: memref<?x?x?x?xf32>, %filter: memref<?x?x?x?xf32>, %output: memref<?x?x?x?xf32>) {
  linalg.conv_2d_input_nchw_filter_hwcf {dilations = dense<1> : tensor<2xi64>,
                                         strides = dense<1> : tensor<2xi64>}
     ins (%input, %filter: memref<?x?x?x?xf32>, memref<?x?x?x?xf32>)
    outs (%output: memref<?x?x?x?xf32>)
  return
}

// CHECK-DAG: #[[MAP0:.+]] = affine_map<(d0, d1, d2, d3, d4, d5, d6) -> (d0, d6, d2 + d4, d3 + d5)>
// CHECK-DAG: #[[MAP1:.+]] = affine_map<(d0, d1, d2, d3, d4, d5, d6) -> (d4, d5, d6, d1)>
// CHECK-DAG: #[[MAP2:.+]] = affine_map<(d0, d1, d2, d3, d4, d5, d6) -> (d0, d1, d2, d3)>

// CHECK: func @conv_2d_input_nchw_filter_hwcf

// CHECK: linalg.generic
// CHECK-SAME: indexing_maps = [#[[MAP0]], #[[MAP1]], #[[MAP2]]]
// CHECK-SAME: iterator_types = ["parallel", "parallel", "parallel", "parallel", "reduction", "reduction", "parallel"]}
// CHECK-SAME: ins(%{{.+}}, %{{.+}} : memref<?x?x?x?xf32>, memref<?x?x?x?xf32>)
// CHECK-SAME: outs(%{{.+}} : memref<?x?x?x?xf32>)

// CHECK:         ^{{.+}}(%[[BBARG0:.+]]: f32, %[[BBARG1:.+]]: f32, %[[BBARG2:.+]]: f32)
// CHECK-NEXT:      %[[MUL:.+]] = mulf %[[BBARG0]], %[[BBARG1]] : f32
// CHECK-NEXT:      %[[ADD:.+]] = addf %[[BBARG2]], %[[MUL]] : f32
// CHECK-NEXT:      linalg.yield %[[ADD]] : f32

// -----

func @conv_3d_input_ndhwc_filter_dhwcf(%input: memref<?x?x?x?x?xf32>, %filter: memref<?x?x?x?x?xf32>, %output: memref<?x?x?x?x?xf32>) {
  linalg.conv_3d_input_ndhwc_filter_dhwcf {dilations = dense<1> : tensor<3xi64>,
                                           strides = dense<1> : tensor<3xi64>}
     ins (%input, %filter: memref<?x?x?x?x?xf32>, memref<?x?x?x?x?xf32>)
    outs (%output: memref<?x?x?x?x?xf32>)
  return
}

// CHECK-DAG: #[[MAP0:.+]] = affine_map<(d0, d1, d2, d3, d4, d5, d6, d7, d8) -> (d0, d1 + d5, d2 + d6, d3 + d7, d8)>
// CHECK-DAG: #[[MAP1:.+]] = affine_map<(d0, d1, d2, d3, d4, d5, d6, d7, d8) -> (d5, d6, d7, d8, d4)>
// CHECK-DAG: #[[MAP2:.+]] = affine_map<(d0, d1, d2, d3, d4, d5, d6, d7, d8) -> (d0, d1, d2, d3, d4)>

// CHECK: func @conv_3d_input_ndhwc_filter_dhwcf

// CHECK: linalg.generic
// CHECK-SAME: indexing_maps = [#[[MAP0]], #[[MAP1]], #[[MAP2]]]
// CHECK-SAME: iterator_types = ["parallel", "parallel", "parallel", "parallel", "parallel", "reduction", "reduction", "reduction", "parallel"]}
// CHECK-SAME: ins(%{{.+}}, %{{.+}} : memref<?x?x?x?x?xf32>, memref<?x?x?x?x?xf32>)
// CHECK-SAME: outs(%{{.+}} : memref<?x?x?x?x?xf32>)

// CHECK:         ^{{.+}}(%[[BBARG0:.+]]: f32, %[[BBARG1:.+]]: f32, %[[BBARG2:.+]]: f32)
// CHECK-NEXT:      %[[MUL:.+]] = mulf %[[BBARG0]], %[[BBARG1]] : f32
// CHECK-NEXT:      %[[ADD:.+]] = addf %[[BBARG2]], %[[MUL]] : f32
// CHECK-NEXT:      linalg.yield %[[ADD]] : f32

// -----

func @conv_3d_input_ncdhw_filter_dhwcf(%input: memref<?x?x?x?x?xf32>, %filter: memref<?x?x?x?x?xf32>, %output: memref<?x?x?x?x?xf32>) {
  linalg.conv_3d_input_ncdhw_filter_dhwcf {dilations = dense<1> : tensor<3xi64>,
                                           strides = dense<1> : tensor<3xi64>}
     ins (%input, %filter: memref<?x?x?x?x?xf32>, memref<?x?x?x?x?xf32>)
    outs (%output: memref<?x?x?x?x?xf32>)
  return
}

// CHECK-DAG: #[[MAP0:.+]] = affine_map<(d0, d1, d2, d3, d4, d5, d6, d7, d8) -> (d0, d8, d2 + d5, d3 + d6, d4 + d7)>
// CHECK-DAG: #[[MAP1:.+]] = affine_map<(d0, d1, d2, d3, d4, d5, d6, d7, d8) -> (d5, d6, d7, d8, d1)>
// CHECK-DAG: #[[MAP2:.+]] = affine_map<(d0, d1, d2, d3, d4, d5, d6, d7, d8) -> (d0, d1, d2, d3, d4)>

// CHECK: func @conv_3d_input_ncdhw_filter_dhwcf

// CHECK: linalg.generic
// CHECK-SAME: indexing_maps = [#[[MAP0]], #[[MAP1]], #[[MAP2]]]
// CHECK-SAME: iterator_types = ["parallel", "parallel", "parallel", "parallel", "parallel", "reduction", "reduction", "reduction", "parallel"]}
// CHECK-SAME: ins(%{{.+}}, %{{.+}} : memref<?x?x?x?x?xf32>, memref<?x?x?x?x?xf32>)
// CHECK-SAME: outs(%{{.+}} : memref<?x?x?x?x?xf32>)

// CHECK:         ^{{.+}}(%[[BBARG0:.+]]: f32, %[[BBARG1:.+]]: f32, %[[BBARG2:.+]]: f32)
// CHECK-NEXT:      %[[MUL:.+]] = mulf %[[BBARG0]], %[[BBARG1]] : f32
// CHECK-NEXT:      %[[ADD:.+]] = addf %[[BBARG2]], %[[MUL]] : f32
// CHECK-NEXT:      linalg.yield %[[ADD]] : f32
