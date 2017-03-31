//-----------------------------------------------------------------------------
// Copyright 2017 Damien Pretet ThotIP
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//-----------------------------------------------------------------------------  

`timescale 1 ns / 1 ps
`default_nettype none


module wptr_full

    #(
    parameter ADDRSIZE = 4
    )(
    input winc,
    input wclk,
    input  wrst_n,
    input      [ADDRSIZE  :0] wq2_rptr,
    output reg                wfull,
    output     [ADDRSIZE-1:0] waddr,
    output reg [ADDRSIZE  :0] wptr
    );

    reg  [ADDRSIZE:0] wbin;
    wire [ADDRSIZE:0] wgraynext, wbinnext;
    wire wfull_val;

    // GRAYSTYLE2 pointer
    always @(posedge wclk or negedge wrst_n)
        if (!wrst_n) 
            {wbin, wptr} <= 0;
        else         
            {wbin, wptr} <= {wbinnext, wgraynext};
    
    // Memory write-address pointer (okay to use binary to address memory)
    assign waddr = wbin[ADDRSIZE-1:0];
    assign wbinnext  = wbin + (winc & ~wfull);
    assign wgraynext = (wbinnext>>1) ^ wbinnext;
    
    //------------------------------------------------------------------ 
    // Simplified version of the three necessary full-tests:
    // assign wfull_val=((wgnext[ADDRSIZE] !=wq2_rptr[ADDRSIZE] ) &&
    //                   (wgnext[ADDRSIZE-1]  !=wq2_rptr[ADDRSIZE-1]) &&
    // (wgnext[ADDRSIZE-2:0]==wq2_rptr[ADDRSIZE-2:0])); 
    //------------------------------------------------------------------
    
     assign wfull_val = (wgraynext=={~wq2_rptr[ADDRSIZE:ADDRSIZE-1],wq2_rptr[ADDRSIZE-2:0]});

     always @(posedge wclk or negedge wrst_n)
       if (!wrst_n) 
            wfull  <= 1'b0;
        else
            wfull  <= wfull_val;

endmodule

`resetall
