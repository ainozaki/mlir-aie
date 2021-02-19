// RUN: aie-opt --aie-standard-lowering="tilecol=1 tilerow=1" %s | FileCheck --check-prefix=CHECK11 %s
// RUN: aie-opt --aie-standard-lowering="tilecol=2 tilerow=1" %s | FileCheck --check-prefix=CHECK21 %s

//CHECK11:  func @core11() {
//CHECK11:    %c0_i32 = constant 0 : i32
//CHECK11:    %c1_i32 = constant 1 : i32
//CHECK11:    %c16_i32 = constant 16 : i32
//CHECK11:    %c32_i128 = constant 32 : i128
//CHECK11:    call @llvm.aie.put.ms(%c0_i32, %c16_i32) : (i32, i32) -> ()
//CHECK11:    call @llvm.aie.put.wms(%c1_i32, %c32_i128) : (i32, i128) -> ()
//CHECK11:    %c64_i384 = constant 64 : i384
//CHECK11:    call @llvm.aie.put.mcd(%c64_i384) : (i384) -> ()
//CHECK11:    return
//CHECK11:  }
//CHECK11:  func @_main() {
//CHECK11:    call @core11() : () -> ()
//CHECK11:    return
//CHECK11:  }

//CHECK21:  func @core21() {
//CHECK21:    %c0_i32 = constant 0 : i32
//CHECK21:    %c1_i32 = constant 1 : i32
//CHECK21:    %0 = call @llvm.aie.get.ss(%c0_i32) : (i32) -> i32
//CHECK21:    %1 = call @llvm.aie.get.ss(%c1_i32) : (i32) -> i32
//CHECK21:    %2 = addi %0, %1 : i32
//CHECK21:    %3 = call @llvm.aie.get.scd() : () -> i384
//CHECK21:    return
//CHECK21:  }
//CHECK21:  func @_main() {
//CHECK21:    call @core21() : () -> ()
//CHECK21:    return
//CHECK21:  }


// Test LLVM lowering to some AIE scalar intrinsic functions (streams, cascades)
// Each core's region is lowered to LLVM Dialect
module @test_core_llvm0 {
  %tile11 = AIE.tile(1, 1)
  %tile21 = AIE.tile(2, 1)

  %core11 = AIE.core(%tile11) {
    %0 = constant 0 : i32
    %1 = constant 1 : i32
    %val0 = constant 16 : i32
    %val1 = constant 32 : i128
    AIE.putStream(%val0 : i32,  %0 : i32)
    AIE.putStream(%val1 : i128, %1 : i32)
    %val2 = constant 64 : i384
    AIE.putCascade(%val2 : i384)
    AIE.end
  }

  %core21 = AIE.core(%tile21) {
    %0 = constant 0 : i32
    %1 = constant 1 : i32
    //%val0 = AIE.getStream(0) : i32
    %val0 = AIE.getStream(%0 : i32) : i32
    %val1 = AIE.getStream(%1 : i32) : i32
    %2 = addi %val0, %val1 : i32
    %3 = AIE.getCascade() : i384
    AIE.end
  }

}
