//////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2021 , Dinesh Annayya                          
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0
// SPDX-FileContributor: Created by Dinesh Annayya <dinesha@opencores.org>
//
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Digital core                                                ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////                                                              ////
////  Description                                                 ////
////      This is digital core and integrate all the main block   ////
////      here.  Following block are integrated here              ////
////      1. Risc V Core                                          ////
////      2. Quad SPI Master                                      ////
////      3. Wishbone Cross Bar                                   ////
////      4. UART                                                 ////
////      5, USB 1.1                                              ////
////      6. SPI Master (Single)                                  ////
////      7. SRAM 2KB                                             ////
////      8. 6 Channel ADC                                        ////
////      9. Pinmux with GPIO and 6 PWM                           ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 16th Feb 2021, Dinesh A                             ////
////          Initial integration with Risc-V core +              ////
////          Wishbone Cross Bar + SPI  Master                    ////
////    0.2 - 17th June 2021, Dinesh A                            ////
////        1. In risc core, wishbone and core domain is          ////
////           created                                            ////
////        2. cpu and rtc clock are generated in glbl reg block  ////
////        3. in wishbone interconnect:- Stagging flop are added ////
////           at interface to break wishbone timing path         ////
////        4. buswidth warning are fixed inside spi_master       ////
////        modified rtl files are                                ////
////           verilog/rtl/digital_core/src/digital_core.sv       ////
////           verilog/rtl/digital_core/src/glbl_cfg.sv           ////
////           verilog/rtl/lib/wb_stagging.sv                     ////
////           verilog/rtl/syntacore/scr1/src/top/scr1_dmem_wb.sv ////
////           verilog/rtl/syntacore/scr1/src/top/scr1_imem_wb.sv ////
////           verilog/rtl/syntacore/scr1/src/top/scr1_top_wb.sv  ////
////           verilog/rtl/user_project_wrapper.v                 ////
////           verilog/rtl/wb_interconnect/src/wb_interconnect.sv ////
////           verilog/rtl/spi_master/src/spim_clkgen.sv          ////
////           verilog/rtl/spi_master/src/spim_ctrl.sv            ////
////    0.3 - 20th June 2021, Dinesh A                            ////
////           1. uart core is integrated                         ////
////           2. 3rd Slave ported added to wishbone interconnect ////
////    0.4 - 25th June 2021, Dinesh A                            ////
////          Moved the pad logic inside sdram,spi,uart block to  ////
////          avoid logic at digital core level                   ////
////    0.5 - 25th June 2021, Dinesh A                            ////
////          Since carvel gives only 16MB address space for user ////
////          space, we have implemented indirect address select  ////
////          with 8 bit bank select given inside wb_host         ////
////          core Address = {Bank_Sel[7:0], Wb_Address[23:0]     ////
////          caravel user address space is                       ////
////          0x3000_0000 to 0x30FF_FFFF                          ////
////    0.6 - 27th June 2021, Dinesh A                            ////
////          Digital core level tie are moved inside IP to avoid ////
////          power hook up at core level                         ////
////          u_risc_top - test_mode & test_rst_n                 ////
////          u_intercon - s*_wbd_err_i                           ////
////          unused wb_cti_i is removed from u_sdram_ctrl        ////
////    0.7 - 28th June 2021, Dinesh A                            ////
////          wb_interconnect master port are interchanged for    ////
////          better physical placement.                          ////
////          m0 - External HOST                                  ////
////          m1 - RISC IMEM                                      ////
////          m2 - RISC DMEM                                      ////
////    0.8 - 6th July 2021, Dinesh A                             ////
////          For Better SDRAM Interface timing we have taping    ////
////          sdram_clock goint to io_out[29] directly from       ////
////          global register block, this help in better SDRAM    ////
////          interface timing control                            ////
////    0.9 - 7th July 2021, Dinesh A                             ////
////          Removed 2 Unused port connection io_in[31:30] to    ////
////          spi_master to avoid lvs issue                       ////
////    1.0 - 28th July 2021, Dinesh A                            ////
////          i2cm integrated part of uart_i2cm module,           ////
////          due to number of IO pin limitation,                 ////
////          Only UART OR I2C selected based on config mode      ////
////    1.1 - 1st Aug 2021, Dinesh A                              ////
////          usb1.1 host integrated part of uart_i2cm_usb module,////
////          due to number of IO pin limitation,                 ////
////          Only UART/I2C/USB selected based on config mode     ////
////    1.2 - 29th Sept 2021, Dinesh.A                            ////
////          1. copied the repo from yifive and renames as       ////
////             riscdunino                                       ////
////          2. Removed the SDRAM controlled                     ////
////          3. Added PinMux                                     ////
////          4. Added SAR ADC for 6 channel                      ////
////    1.3 - 30th Sept 2021, Dinesh.A                            ////
////          2KB SRAM Interface added to RISC Core               ////
////    1.4 - 13th Oct 2021, Dinesh A                             ////
////          Basic verification and Synthesis cleanup            ////
////    1.5 - 6th Nov 2021, Dinesh A                              ////
////          Clock Skew block moved inside respective block due  ////
//            to top-level power hook-up challenges for small IP  ////
////    1.6   Nov 14, 2021, Dinesh A                              ////
////          Major bug, clock divider inside the wb_host reset   ////
////          connectivity open is fixed                          ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////


module user_project_wrapper (
`ifdef USE_POWER_PINS
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground
`endif
    input   wire                       wb_clk_i        ,  // System clock
    input   wire                       user_clock2     ,  // user Clock
    input   wire                       wb_rst_i        ,  // Regular Reset signal

    input   wire                       wbs_cyc_i       ,  // strobe/request
    input   wire                       wbs_stb_i       ,  // strobe/request
    input   wire [WB_WIDTH-1:0]        wbs_adr_i       ,  // address
    input   wire                       wbs_we_i        ,  // write
    input   wire [WB_WIDTH-1:0]        wbs_dat_i       ,  // data output
    input   wire [3:0]                 wbs_sel_i       ,  // byte enable
    output  wire [WB_WIDTH-1:0]        wbs_dat_o       ,  // data input
    output  wire                       wbs_ack_o       ,  // acknowlegement

    // Analog (direct connection to GPIO pad---use with caution)
    // Note that analog I/O is not available on the 7 lowest-numbered
    // GPIO pads, and so the analog_io indexing is offset from the
    // GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
    inout [`MPRJ_IO_PADS-10:0] analog_io,
 
    // Logic Analyzer Signals
    input  wire [127:0]                la_data_in      ,
    output wire [127:0]                la_data_out     ,
    input  wire [127:0]                la_oenb         ,
 

    // IOs
    input  wire  [37:0]                io_in           ,
    output wire  [37:0]                io_out          ,
    output wire  [37:0]                io_oeb          ,

    output wire  [2:0]                 user_irq             

);

//---------------------------------------------------
// Local Parameter Declaration
// --------------------------------------------------

parameter      SDR_DW   = 8;  // SDR Data Width 
parameter      SDR_BW   = 1;  // SDR Byte Width
parameter      WB_WIDTH = 32; // WB ADDRESS/DARA WIDTH

//---------------------------------------------------------------------
// Wishbone Risc V Instruction Memory Interface
//---------------------------------------------------------------------
wire                           wbd_riscv_imem_stb_i; // strobe/request
wire   [WB_WIDTH-1:0]          wbd_riscv_imem_adr_i; // address
wire                           wbd_riscv_imem_we_i;  // write
wire   [WB_WIDTH-1:0]          wbd_riscv_imem_dat_i; // data output
wire   [3:0]                   wbd_riscv_imem_sel_i; // byte enable
wire   [WB_WIDTH-1:0]          wbd_riscv_imem_dat_o; // data input
wire                           wbd_riscv_imem_ack_o; // acknowlegement
wire                           wbd_riscv_imem_err_o;  // error

//---------------------------------------------------------------------
// RISC V Wishbone Data Memory Interface
//---------------------------------------------------------------------
wire                           wbd_riscv_dmem_stb_i; // strobe/request
wire   [WB_WIDTH-1:0]          wbd_riscv_dmem_adr_i; // address
wire                           wbd_riscv_dmem_we_i;  // write
wire   [WB_WIDTH-1:0]          wbd_riscv_dmem_dat_i; // data output
wire   [3:0]                   wbd_riscv_dmem_sel_i; // byte enable
wire   [WB_WIDTH-1:0]          wbd_riscv_dmem_dat_o; // data input
wire                           wbd_riscv_dmem_ack_o; // acknowlegement
wire                           wbd_riscv_dmem_err_o; // error

//---------------------------------------------------------------------
// WB HOST Interface
//---------------------------------------------------------------------
wire                           wbd_int_cyc_i; // strobe/request
wire                           wbd_int_stb_i; // strobe/request
wire   [WB_WIDTH-1:0]          wbd_int_adr_i; // address
wire                           wbd_int_we_i;  // write
wire   [WB_WIDTH-1:0]          wbd_int_dat_i; // data output
wire   [3:0]                   wbd_int_sel_i; // byte enable
wire   [WB_WIDTH-1:0]          wbd_int_dat_o; // data input
wire                           wbd_int_ack_o; // acknowlegement
wire                           wbd_int_err_o; // error
//---------------------------------------------------------------------
//    SPI Master Wishbone Interface
//---------------------------------------------------------------------
wire                           wbd_spim_stb_o; // strobe/request
wire   [WB_WIDTH-1:0]          wbd_spim_adr_o; // address
wire                           wbd_spim_we_o;  // write
wire   [WB_WIDTH-1:0]          wbd_spim_dat_o; // data output
wire   [3:0]                   wbd_spim_sel_o; // byte enable
wire                           wbd_spim_cyc_o ;
wire   [WB_WIDTH-1:0]          wbd_spim_dat_i; // data input
wire                           wbd_spim_ack_i; // acknowlegement
wire                           wbd_spim_err_i;  // error

//---------------------------------------------------------------------
//    SPI Master Wishbone Interface
//---------------------------------------------------------------------
wire                           wbd_adc_stb_o ;
wire [7:0]                     wbd_adc_adr_o ;
wire                           wbd_adc_we_o  ; // 1 - Write, 0 - Read
wire [WB_WIDTH-1:0]            wbd_adc_dat_o ;
wire [WB_WIDTH/8-1:0]          wbd_adc_sel_o ; // Byte enable
wire                           wbd_adc_cyc_o ;
wire  [2:0]                    wbd_adc_cti_o ;
wire  [WB_WIDTH-1:0]           wbd_adc_dat_i ;
wire                           wbd_adc_ack_i ;

//---------------------------------------------------------------------
//    Global Register Wishbone Interface
//---------------------------------------------------------------------
wire                           wbd_glbl_stb_o; // strobe/request
wire   [7:0]                   wbd_glbl_adr_o; // address
wire                           wbd_glbl_we_o;  // write
wire   [WB_WIDTH-1:0]          wbd_glbl_dat_o; // data output
wire   [3:0]                   wbd_glbl_sel_o; // byte enable
wire                           wbd_glbl_cyc_o ;
wire   [WB_WIDTH-1:0]          wbd_glbl_dat_i; // data input
wire                           wbd_glbl_ack_i; // acknowlegement
wire                           wbd_glbl_err_i;  // error

//---------------------------------------------------------------------
//    Global Register Wishbone Interface
//---------------------------------------------------------------------
wire                           wbd_uart_stb_o; // strobe/request
wire   [31:0]                  wbd_uart_adr_o; // address
wire                           wbd_uart_we_o;  // write
wire   [31:0]                  wbd_uart_dat_o; // data output
wire   [3:0]                   wbd_uart_sel_o; // byte enable
wire                           wbd_uart_cyc_o ;
wire   [31:0]                  wbd_uart_dat_i; // data input
wire                           wbd_uart_ack_i; // acknowlegement
wire                           wbd_uart_err_i;  // error

//----------------------------------------------------
//  CPU Configuration
//----------------------------------------------------
wire                              cpu_rst_n     ;
wire                              qspim_rst_n     ;
wire                              sspim_rst_n     ;
wire                              uart_rst_n    ;// uart reset
wire                              i2c_rst_n     ;// i2c reset
wire                              usb_rst_n     ;// i2c reset
wire   [1:0]                      uart_i2c_usb_sel  ;// 0 - uart, 1 - I2C, 2- USb
wire                              sdram_clk           ;
wire                              cpu_clk       ;
wire                              rtc_clk       ;
wire                              usb_clk       ;
wire                              wbd_clk_int   ;
wire                              wbd_clk_pinmux   ;
//wire                              wbd_clk_int1  ;
//wire                              wbd_clk_int2  ;
wire                              wbd_int_rst_n ;
//wire                              wbd_int1_rst_n ;
//wire                              wbd_int2_rst_n ;

wire [31:0]                       fuse_mhartid  ;
wire [15:0]                       irq_lines     ;
wire                              soft_irq      ;

wire [7:0]                        cfg_glb_ctrl  ;
wire [31:0]                       cfg_clk_ctrl1 ;
wire [31:0]                       cfg_clk_ctrl2 ;
wire [3:0]                        cfg_cska_wi   ; // clock skew adjust for wishbone interconnect
wire [3:0]                        cfg_cska_riscv; // clock skew adjust for riscv
wire [3:0]                        cfg_cska_uart ; // clock skew adjust for uart
wire [3:0]                        cfg_cska_spi  ; // clock skew adjust for spi
wire [3:0]                        cfg_cska_pinmux; // clock skew adjust for pinmux
wire [3:0]                        cfg_cska_sp_co ; // clock skew adjust for global reg
wire [3:0]                        cfg_cska_wh   ; // clock skew adjust for web host


wire                              wbd_clk_wi    ; // clock for wishbone interconnect
wire                              wbd_clk_riscv ; // clock for riscv
wire                              wbd_clk_uart  ; // clock for uart
wire                              wbd_clk_spi   ; // clock for spi
wire                              wbd_clk_sdram ; // clock for sdram
wire                              wbd_clk_glbl  ; // clock for global reg
wire                              wbd_clk_wh    ; // clock for global reg



wire [31:0]                       spi_debug           ;
wire [31:0]                       pinmux_debug           ;
wire [63:0]                       riscv_debug         ;

// SFLASH I/F
wire                             sflash_sck          ;
wire                             sflash_ss           ;
wire [3:0]                       sflash_oen          ;
wire [3:0]                       sflash_do           ;
wire [3:0]                       sflash_di           ;

// SSRAM I/F
//wire                             ssram_sck           ;
//wire                             ssram_ss            ;
//wire                             ssram_oen           ;
//wire [3:0]                       ssram_do            ;
//wire [3:0]                       ssram_di            ;

// USB I/F
wire                             usb_dp_o            ;
wire                             usb_dn_o            ;
wire                             usb_oen             ;
wire                             usb_dp_i            ;
wire                             usb_dn_i            ;

// UART I/F
wire                             uart_txd            ;
wire                             uart_rxd            ;

// I2CM I/F
wire                             i2cm_clk_o          ;
wire                             i2cm_clk_i          ;
wire                             i2cm_clk_oen        ;
wire                             i2cm_data_oen       ;
wire                             i2cm_data_o         ;
wire                             i2cm_data_i         ;

// SPI MASTER
wire                             spim_sck            ;
wire                             spim_ss             ;
wire                             spim_miso           ;
wire                             spim_mosi           ;

wire [7:0]                       sar2dac             ;
wire                             analog_dac_out      ;
wire                             pulse1m_mclk        ;
wire                             h_reset_n           ;

`ifndef SCR1_TCM_MEM
// SRAM PORT-0 - DMEM I/F
wire                             sram_csb0           ; // CS#
wire                             sram_web0           ; // WE#
wire   [8:0]                     sram_addr0          ; // Address
wire   [3:0]                     sram_wmask0         ; // WMASK#
wire   [31:0]                    sram_din0           ; // Write Data
wire   [31:0]                    sram_dout0          ; // Read Data

// SRAM PORT-1, IMEM I/F
wire                             sram_csb1           ; // CS#
wire  [8:0]                      sram_addr1          ; // Address
wire  [31:0]                     sram_dout1          ; // Read Data
`endif

// SPIM I/F
wire                             sspim_sck           ; // clock out
wire                             sspim_so            ; // serial data out
wire                             sspim_si            ; // serial data in
wire                             sspim_ssn           ; // cs_n


wire                             usb_intr_o          ;
wire                             i2cm_intr_o         ;
/////////////////////////////////////////////////////////
// Clock Skew Ctrl
////////////////////////////////////////////////////////

assign cfg_cska_wi     = cfg_clk_ctrl1[3:0];
assign cfg_cska_riscv  = cfg_clk_ctrl1[7:4];
assign cfg_cska_uart   = cfg_clk_ctrl1[11:8];
assign cfg_cska_spi    = cfg_clk_ctrl1[15:12];
assign cfg_cska_pinmux = cfg_clk_ctrl1[19:16];
assign cfg_cska_wh     = cfg_clk_ctrl1[23:20];
assign cfg_cska_sp_co  = cfg_clk_ctrl1[27:24];


//assign la_data_out    = {riscv_debug,spi_debug,sdram_debug};
assign la_data_out[127:0]    = {pinmux_debug,spi_debug,riscv_debug};

//clk_buf u_buf1_wb_rstn  (.clk_i(wbd_int_rst_n),.clk_o(wbd_int1_rst_n));
//clk_buf u_buf2_wb_rstn  (.clk_i(wbd_int1_rst_n),.clk_o(wbd_int2_rst_n));
//
//clk_buf u_buf1_wbclk    (.clk_i(wbd_clk_int),.clk_o(wbd_clk_int1));
//clk_buf u_buf2_wbclk    (.clk_i(wbd_clk_int1),.clk_o(wbd_clk_int2));

wb_host u_wb_host(
`ifdef USE_POWER_PINS
    .vccd1                 (vccd1                    ),// User area 1 1.8V supply
    .vssd1                 (vssd1                    ),// User area 1 digital ground
`endif
       .user_clock1      (wb_clk_i             ),
       .user_clock2      (user_clock2          ),

       .sdram_clk        (sdram_clk            ),
       .cpu_clk          (cpu_clk              ),
       .rtc_clk          (rtc_clk              ),
       .usb_clk          (usb_clk              ),

       .wbd_int_rst_n    (wbd_int_rst_n        ),
       .cpu_rst_n        (cpu_rst_n            ),
       .qspim_rst_n      (qspim_rst_n          ),
       .sspim_rst_n      (sspim_rst_n          ), // spi reset
       .uart_rst_n       (uart_rst_n           ), // uart reset
       .i2cm_rst_n       (i2c_rst_n            ), // i2c reset
       .usb_rst_n        (usb_rst_n            ), // usb reset
       .uart_i2c_usb_sel (uart_i2c_usb_sel     ), // 0 - uart, 1 - I2C, 2- USB

    // Master Port
       .wbm_rst_i        (wb_rst_i             ),  
       .wbm_clk_i        (wb_clk_i             ),  
       .wbm_cyc_i        (wbs_cyc_i            ),  
       .wbm_stb_i        (wbs_stb_i            ),  
       .wbm_adr_i        (wbs_adr_i            ),  
       .wbm_we_i         (wbs_we_i             ),  
       .wbm_dat_i        (wbs_dat_i            ),  
       .wbm_sel_i        (wbs_sel_i            ),  
       .wbm_dat_o        (wbs_dat_o            ),  
       .wbm_ack_o        (wbs_ack_o            ),  
       .wbm_err_o        (                     ),  

    // Clock Skeq Adjust
       .wbd_clk_int      (wbd_clk_int          ),
       .wbd_clk_wh       (wbd_clk_wh           ),  
       .cfg_cska_wh      (cfg_cska_wh          ),

    // Slave Port
       .wbs_clk_out      (wbd_clk_int          ),
       .wbs_clk_i        (wbd_clk_wh           ),  
       .wbs_cyc_o        (wbd_int_cyc_i        ),  
       .wbs_stb_o        (wbd_int_stb_i        ),  
       .wbs_adr_o        (wbd_int_adr_i        ),  
       .wbs_we_o         (wbd_int_we_i         ),  
       .wbs_dat_o        (wbd_int_dat_i        ),  
       .wbs_sel_o        (wbd_int_sel_i        ),  
       .wbs_dat_i        (wbd_int_dat_o        ),  
       .wbs_ack_i        (wbd_int_ack_o        ),  
       .wbs_err_i        (wbd_int_err_o        ),  

       .cfg_clk_ctrl1    (cfg_clk_ctrl1        ),
       .cfg_clk_ctrl2    (cfg_clk_ctrl2        )

    );




//------------------------------------------------------------------------------
// RISC V Core instance
//------------------------------------------------------------------------------
scr1_top_wb u_riscv_top (
`ifdef USE_POWER_PINS
    .vccd1                 (vccd1                    ),// User area 1 1.8V supply
    .vssd1                 (vssd1                    ),// User area 1 digital ground
`endif
    .wbd_clk_int           (wbd_clk_int               ), 
    .cfg_cska_riscv        (cfg_cska_riscv            ), 
    .wbd_clk_riscv         (wbd_clk_riscv             ),

    // Reset
    .pwrup_rst_n            (wbd_int_rst_n             ),
    .rst_n                  (wbd_int_rst_n             ),
    .cpu_rst_n              (cpu_rst_n                 ),
    .riscv_debug            (riscv_debug               ),

    // Clock
    .core_clk               (cpu_clk                   ),
    .rtc_clk                (rtc_clk                   ),

    // Fuses
    .fuse_mhartid           (fuse_mhartid              ),

    // IRQ
    .irq_lines              (irq_lines                 ), 
    .soft_irq               (soft_irq                  ), // TODO - Interrupts

    // DFT
    // .test_mode           (1'b0                      ), // Moved inside IP
    // .test_rst_n          (1'b1                      ), // Moved inside IP

`ifndef SCR1_TCM_MEM
    // SRAM PORT-0
    .sram_csb0              (sram_csb0                 ),
    .sram_web0              (sram_web0                 ),
    .sram_addr0             (sram_addr0                ),
    .sram_wmask0            (sram_wmask0               ),
    .sram_din0              (sram_din0                 ),
    .sram_dout0             (sram_dout0                ),
    
    // SRAM PORT-0
    .sram_csb1              (sram_csb1                 ),
    .sram_addr1             (sram_addr1                ),
    .sram_dout1             (sram_dout1                ),
`endif
    
    .wb_rst_n               (wbd_int_rst_n             ),
    .wb_clk                 (wbd_clk_riscv             ),
    // Instruction memory interface
    .wbd_imem_stb_o         (wbd_riscv_imem_stb_i      ),
    .wbd_imem_adr_o         (wbd_riscv_imem_adr_i      ),
    .wbd_imem_we_o          (wbd_riscv_imem_we_i       ), 
    .wbd_imem_dat_o         (wbd_riscv_imem_dat_i      ),
    .wbd_imem_sel_o         (wbd_riscv_imem_sel_i      ),
    .wbd_imem_dat_i         (wbd_riscv_imem_dat_o      ),
    .wbd_imem_ack_i         (wbd_riscv_imem_ack_o      ),
    .wbd_imem_err_i         (wbd_riscv_imem_err_o      ),

    // Data memory interface
    .wbd_dmem_stb_o         (wbd_riscv_dmem_stb_i      ),
    .wbd_dmem_adr_o         (wbd_riscv_dmem_adr_i      ),
    .wbd_dmem_we_o          (wbd_riscv_dmem_we_i       ), 
    .wbd_dmem_dat_o         (wbd_riscv_dmem_dat_i      ),
    .wbd_dmem_sel_o         (wbd_riscv_dmem_sel_i      ),
    .wbd_dmem_dat_i         (wbd_riscv_dmem_dat_o      ),
    .wbd_dmem_ack_i         (wbd_riscv_dmem_ack_o      ),
    .wbd_dmem_err_i         (wbd_riscv_dmem_err_o      ) 
);

`ifndef SCR1_TCM_MEM
sky130_sram_2kbyte_1rw1r_32x512_8 u_sram_2kb(
`ifdef USE_POWER_PINS
    .vccd1 (vccd1),// User area 1 1.8V supply
    .vssd1 (vssd1),// User area 1 digital ground
`endif
// Port 0: RW
    .clk0     (cpu_clk),
    .csb0     (sram_csb0),
    .web0     (sram_web0),
    .wmask0   (sram_wmask0),
    .addr0    (sram_addr0),
    .din0     (sram_din0),
    .dout0    (sram_dout0),
// Port 1: R
    .clk1     (cpu_clk),
    .csb1     (sram_csb1),
    .addr1    (sram_addr1),
    .dout1    (sram_dout1)
  );

`endif


/*********************************************************
* SPI Master
* This is an implementation of an SPI master that is controlled via an AXI bus. 
* It has FIFOs for transmitting and receiving data. 
* It supports both the normal SPI mode and QPI mode with 4 data lines.
* *******************************************************/

qspim_top
#(
`ifndef SYNTHESIS
    .WB_WIDTH  (WB_WIDTH)
`endif
) u_qspi_master
(
`ifdef USE_POWER_PINS
         .vccd1         (vccd1                 ),// User area 1 1.8V supply
         .vssd1         (vssd1                 ),// User area 1 digital ground
`endif
    .mclk                   (wbd_clk_spi               ),
    .rst_n                  (qspim_rst_n               ),

    // Clock Skew Adjust
    .cfg_cska_sp_co         (cfg_cska_sp_co            ),
    .cfg_cska_spi           (cfg_cska_spi              ),
    .wbd_clk_int            (wbd_clk_int               ),
    .wbd_clk_spi            (wbd_clk_spi               ),

    .wbd_stb_i              (wbd_spim_stb_o            ),
    .wbd_adr_i              (wbd_spim_adr_o            ),
    .wbd_we_i               (wbd_spim_we_o             ), 
    .wbd_dat_i              (wbd_spim_dat_o            ),
    .wbd_sel_i              (wbd_spim_sel_o            ),
    .wbd_dat_o              (wbd_spim_dat_i            ),
    .wbd_ack_o              (wbd_spim_ack_i            ),
    .wbd_err_o              (wbd_spim_err_i            ),

    .spi_debug              (spi_debug                 ),

    // Pad Interface
    .spi_sdi                (sflash_di                 ),
    .spi_clk                (sflash_sck                ),
    .spi_csn0               (sflash_ss                 ),
    .spi_sdo                (sflash_do                 ),
    .spi_oen                (sflash_oen                )

);



wb_interconnect  u_intercon (
`ifdef USE_POWER_PINS
         .vccd1         (vccd1                 ),// User area 1 1.8V supply
         .vssd1         (vssd1                 ),// User area 1 digital ground
`endif
     // Clock Skew adjust
	 .wbd_clk_int   (wbd_clk_int           ), 
	 .cfg_cska_wi   (cfg_cska_wi           ), 
	 .wbd_clk_wi    (wbd_clk_wi            ),

         .clk_i         (wbd_clk_wi            ), 
         .rst_n         (wbd_int_rst_n         ),

         // Master 0 Interface
         .m0_wbd_dat_i  (wbd_int_dat_i         ),
         .m0_wbd_adr_i  (wbd_int_adr_i         ),
         .m0_wbd_sel_i  (wbd_int_sel_i         ),
         .m0_wbd_we_i   (wbd_int_we_i          ),
         .m0_wbd_cyc_i  (wbd_int_cyc_i         ),
         .m0_wbd_stb_i  (wbd_int_stb_i         ),
         .m0_wbd_dat_o  (wbd_int_dat_o         ),
         .m0_wbd_ack_o  (wbd_int_ack_o         ),
         .m0_wbd_err_o  (wbd_int_err_o         ),
         
         // Master 0 Interface
         .m1_wbd_dat_i  (wbd_riscv_imem_dat_i  ),
         .m1_wbd_adr_i  (wbd_riscv_imem_adr_i  ),
         .m1_wbd_sel_i  (wbd_riscv_imem_sel_i  ),
         .m1_wbd_we_i   (wbd_riscv_imem_we_i   ),
         .m1_wbd_cyc_i  (wbd_riscv_imem_stb_i  ),
         .m1_wbd_stb_i  (wbd_riscv_imem_stb_i  ),
         .m1_wbd_dat_o  (wbd_riscv_imem_dat_o  ),
         .m1_wbd_ack_o  (wbd_riscv_imem_ack_o  ),
         .m1_wbd_err_o  (wbd_riscv_imem_err_o  ),
         
         // Master 1 Interface
         .m2_wbd_dat_i  (wbd_riscv_dmem_dat_i  ),
         .m2_wbd_adr_i  (wbd_riscv_dmem_adr_i  ),
         .m2_wbd_sel_i  (wbd_riscv_dmem_sel_i  ),
         .m2_wbd_we_i   (wbd_riscv_dmem_we_i   ),
         .m2_wbd_cyc_i  (wbd_riscv_dmem_stb_i  ),
         .m2_wbd_stb_i  (wbd_riscv_dmem_stb_i  ),
         .m2_wbd_dat_o  (wbd_riscv_dmem_dat_o  ),
         .m2_wbd_ack_o  (wbd_riscv_dmem_ack_o  ),
         .m2_wbd_err_o  (wbd_riscv_dmem_err_o  ),
         
         
         // Slave 0 Interface
         // .s0_wbd_err_i  (1'b0           ), - Moved inside IP
         .s0_wbd_dat_i  (wbd_spim_dat_i ),
         .s0_wbd_ack_i  (wbd_spim_ack_i ),
         .s0_wbd_dat_o  (wbd_spim_dat_o ),
         .s0_wbd_adr_o  (wbd_spim_adr_o ),
         .s0_wbd_sel_o  (wbd_spim_sel_o ),
         .s0_wbd_we_o   (wbd_spim_we_o  ),  
         .s0_wbd_cyc_o  (wbd_spim_cyc_o ),
         .s0_wbd_stb_o  (wbd_spim_stb_o ),
         
         // Slave 1 Interface
         // .s1_wbd_err_i  (1'b0           ), - Moved inside IP
         .s1_wbd_dat_i  (wbd_uart_dat_i ),
         .s1_wbd_ack_i  (wbd_uart_ack_i ),
         .s1_wbd_dat_o  (wbd_uart_dat_o ),
         .s1_wbd_adr_o  (wbd_uart_adr_o ),
         .s1_wbd_sel_o  (wbd_uart_sel_o ),
         .s1_wbd_we_o   (wbd_uart_we_o  ),  
         .s1_wbd_cyc_o  (wbd_uart_cyc_o ),
         .s1_wbd_stb_o  (wbd_uart_stb_o ),
         
         // Slave 2 Interface
         // .s2_wbd_err_i  (1'b0           ), - Moved inside IP
         .s2_wbd_dat_i  (wbd_adc_dat_i ),
         .s2_wbd_ack_i  (wbd_adc_ack_i ),
         .s2_wbd_dat_o  (wbd_adc_dat_o ),
         .s2_wbd_adr_o  (wbd_adc_adr_o ),
         .s2_wbd_sel_o  (wbd_adc_sel_o ),
         .s2_wbd_we_o   (wbd_adc_we_o  ),  
         .s2_wbd_cyc_o  (wbd_adc_cyc_o ),
         .s2_wbd_stb_o  (wbd_adc_stb_o ),

         // Slave 3 Interface
         // .s3_wbd_err_i  (1'b0           ), - Moved inside IP
         .s3_wbd_dat_i  (wbd_glbl_dat_i ),
         .s3_wbd_ack_i  (wbd_glbl_ack_i ),
         .s3_wbd_dat_o  (wbd_glbl_dat_o ),
         .s3_wbd_adr_o  (wbd_glbl_adr_o ),
         .s3_wbd_sel_o  (wbd_glbl_sel_o ),
         .s3_wbd_we_o   (wbd_glbl_we_o  ),  
         .s3_wbd_cyc_o  (wbd_glbl_cyc_o ),
         .s3_wbd_stb_o  (wbd_glbl_stb_o )
	);


uart_i2c_usb_spi_top   u_uart_i2c_usb_spi (
`ifdef USE_POWER_PINS
         .vccd1                 (vccd1                    ),// User area 1 1.8V supply
         .vssd1                 (vssd1                    ),// User area 1 digital ground
`endif
	.wbd_clk_int            (wbd_clk_int              ), 
	.cfg_cska_uart          (cfg_cska_uart            ), 
	.wbd_clk_uart           (wbd_clk_uart             ),

        .uart_rstn              (uart_rst_n               ), // uart reset
        .i2c_rstn               (i2c_rst_n                ), // i2c reset
        .usb_rstn               (usb_rst_n                ), // USB reset
        .spi_rstn               (sspim_rst_n              ), // SPI reset
        .app_clk                (wbd_clk_uart             ),
	.usb_clk                (usb_clk                  ),

        // Reg Bus Interface Signal
       .reg_cs                  (wbd_uart_stb_o           ),
       .reg_wr                  (wbd_uart_we_o            ),
       .reg_addr                (wbd_uart_adr_o[7:0]      ),
       .reg_wdata               (wbd_uart_dat_o           ),
       .reg_be                  (wbd_uart_sel_o           ),

       // Outputs
       .reg_rdata               (wbd_uart_dat_i           ),
       .reg_ack                 (wbd_uart_ack_i           ),

       // Pad interface
       .scl_pad_i               (i2cm_clk_i               ),
       .scl_pad_o               (i2cm_clk_o               ),
       .scl_pad_oen_o           (i2cm_clk_oen             ),

       .sda_pad_i               (i2cm_data_i              ),
       .sda_pad_o               (i2cm_data_o              ),
       .sda_padoen_o            (i2cm_data_oen            ),
     
       .i2cm_intr_o             (i2cm_intr_o              ),

       .uart_rxd                (uart_rxd                 ),
       .uart_txd                (uart_txd                 ),

       .usb_in_dp               (usb_dp_i                 ),
       .usb_in_dn               (usb_dn_i                 ),

       .usb_out_dp              (usb_dp_o                 ),
       .usb_out_dn              (usb_dn_o                 ),
       .usb_out_tx_oen          (usb_oen                  ),
       
       .usb_intr_o              (usb_intr_o               ),

      // SPIM Master
       .sspim_sck               (sspim_sck                ), 
       .sspim_so                (sspim_so                 ),  
       .sspim_si                (sspim_si                 ),  
       .sspim_ssn               (sspim_ssn                )  

     );


pinmux u_pinmux(
`ifdef USE_POWER_PINS
         .vccd1         (vccd1                 ),// User area 1 1.8V supply
         .vssd1         (vssd1                 ),// User area 1 digital ground
`endif
        //clk skew adjust
        .cfg_cska_pinmux        (cfg_cska_pinmux           ),
        .wbd_clk_int            (wbd_clk_int               ),
        .wbd_clk_pinmux         (wbd_clk_pinmux            ),

        // System Signals
        // Inputs
	.mclk                   (wbd_clk_pinmux            ),
        .h_reset_n              (wbd_int_rst_n             ),

        // Reg Bus Interface Signal
        .reg_cs                 (wbd_glbl_stb_o            ),
        .reg_wr                 (wbd_glbl_we_o             ),
        .reg_addr               (wbd_glbl_adr_o            ),
        .reg_wdata              (wbd_glbl_dat_o            ),
        .reg_be                 (wbd_glbl_sel_o            ),

       // Outputs
        .reg_rdata              (wbd_glbl_dat_i            ),
        .reg_ack                (wbd_glbl_ack_i            ),


       // Risc configuration
        .fuse_mhartid           (fuse_mhartid              ),
        .irq_lines              (irq_lines                 ),
        .soft_irq               (soft_irq                  ),
        .user_irq               (user_irq                  ),
        .usb_intr               (usb_intr_o                ),
        .i2cm_intr              (i2cm_intr_o               ),

       // Digital IO
        .digital_io_out         (io_out                    ),
        .digital_io_oen         (io_oeb                    ),
        .digital_io_in          (io_in                     ),

       // SFLASH I/F
        .sflash_sck             (sflash_sck                ),
        .sflash_ss              (sflash_ss                 ),
        .sflash_oen             (sflash_oen                ),
        .sflash_do              (sflash_do                 ),
        .sflash_di              (sflash_di                 ),


       // USB I/F
        .usb_dp_o               (usb_dp_o                  ),
        .usb_dn_o               (usb_dn_o                  ),
        .usb_oen                (usb_oen                   ),
        .usb_dp_i               (usb_dp_i                  ),
        .usb_dn_i               (usb_dn_i                  ),

       // UART I/F
        .uart_txd               (uart_txd                  ),
        .uart_rxd               (uart_rxd                  ),

       // I2CM I/F
        .i2cm_clk_o             (i2cm_clk_o                ),
        .i2cm_clk_i             (i2cm_clk_i                ),
        .i2cm_clk_oen           (i2cm_clk_oen              ),
        .i2cm_data_oen          (i2cm_data_oen             ),
        .i2cm_data_o            (i2cm_data_o               ),
        .i2cm_data_i            (i2cm_data_i               ),

       // SPI MASTER
        .spim_sck               (sspim_sck                 ),
        .spim_ss                (sspim_ssn                 ),
        .spim_miso              (sspim_so                  ),
        .spim_mosi              (sspim_si                  ),

	.pulse1m_mclk           (pulse1m_mclk              ),

	.pinmux_debug           (pinmux_debug              )
   ); 

sar_adc  u_adc (
`ifdef USE_POWER_PINS
        .vccd1 (vccd1),// User area 1 1.8V supply
        .vssd1 (vssd1),// User area 1 digital ground
        .vccd2 (vccd1), // (vccd2),// User area 2 1.8V supply (analog) - DOTO: Need Fix
        .vssd2 (vssd1), // (vssd2),// User area 2 ground      (analog) - DOTO: Need Fix
`endif

    
        .clk           (wbd_clk_int),// The clock (digital)
        .reset_n       (wbd_int_rst_n),// Active low reset (digital)

    // Reg Bus Interface Signal
        .reg_cs        (wbd_adc_stb_o   ),
        .reg_wr        (wbd_adc_we_o    ),
        .reg_addr      (wbd_adc_adr_o[7:0] ),
        .reg_wdata     (wbd_adc_dat_o   ),
        .reg_be        (wbd_adc_sel_o   ),

    // Outputs
        .reg_rdata     (wbd_adc_dat_i   ),
        .reg_ack       (wbd_adc_ack_i   ),

        .pulse1m_mclk  (pulse1m_mclk),


	// DAC I/F
        .sar2dac         (sar2dac       ), 
        //.analog_dac_out  (analog_dac_out) ,  // TODO: Need to connect to DAC O/P
        .analog_dac_out  (analog_io[6]) , 

        // ADC Input 
        .analog_din(analog_io[5:0])    // (Analog)

);

/****
* TODO: Need to uncomment the DAC
DAC_8BIT u_dac (
     `ifdef USE_POWER_PINS
        .vdd(vccd2),
        .gnd(vssd2),
    `endif 
        .d0(sar2dac[0]),
        .d1(sar2dac[1]),
        .d2(sar2dac[2]),
        .d3(sar2dac[3]),
        .d4(sar2dac[4]),
        .d5(sar2dac[5]),
        .d6(sar2dac[6]),
        .d7(sar2dac[7]),
        .inp1(analog_io[6]),
        .out_v(analog_dac_out)
    );

**/

endmodule : user_project_wrapper
