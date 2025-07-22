import types_pkg::*;

module Hazard_unit(
    //forwarding
    input logic RegWriteM,
    input logic RegWriteW,
    input reg_addr_t RdM,
    input reg_addr_t RdW,       //w.RdW
    input reg_addr_t Rs2E,
    input reg_addr_t Rs1E,
    input logic ResultSrcE0,

    output [1:0] ForwardAE,
    output [1:0] ForwardEE,

    //load use
    input logic clk,
    // input logic MemReadE,
    input reg_addr_t RdE,
    input reg_addr_t Rs1D,
    input reg_addr_t Rs2D,

    output logic StallF
    output logic StallD,
    output logic FlushE,


    //branch
    input logic PCSrcE,

    output logic FlushD,
    output logic FluchE
    );

    //handle forwarding
    logic [1:0] fwd_AE, fwd_EE;
    always_comb begin
        if(RegWriteW && RdW != 0 && ResultSrcE0 && RdW == Rs1E) begin
            fwd_AE = 2'b01;
        end else if(RegWriteM && RdM != 0 && RdM == Rs1E) begin
            fwd_AE = 2'b10;
        end else begin
            fwd_AE = 2'b00;
        end

        if(RegWriteM && RdM != 0 && RdM != Rs2E && RdM == Rs2E) begin
            fwd_EE = 2'b01;
        end else if(RegWriteM && RdM != 0 && RdM == Rs2E) begin
            fwd_EE = 2'b10;
        end else begin
            fwd_EE = 2'b00;
        end
    end


    //handle load use and stalling
    logic [1:0] delayed_forward;
    logic Rs1_sel, Rs2_sel;
    always_ff @( posedge clk ) begin

        if(ResultSrcE0 && (RdE == Rs1D || RdE == Rs2D) ) begin
            delayed_forward <= 2'b01;
            if (RdE == Rs1D) begin
                Rs1_sel <= 'b1;
            end else begin
                Rs1_sel <= 'b0;
            end

            if(RdE == Rs2D) begin
                Rs2_sel <= 'b1;
            end else begin
                Rs2_sel <= 'b0;
            end
        end else begin
            delayed_forward <= 2'b00;
        end

    end
    assign ForwardAE = (delayed_forward & Rs1_sel) || fwd_AE;
    assign ForwardEE = (delayed_forward & Rs2_sel) || fwd_EE;
    logic flushE_load;
    always_comb begin
        if(ResultSrcE0 && (RdE == Rs1D || RdE == Rs2D) ) begin
            StallF = 'b1;
            StallD = 'b1;
            flushE_load = 'b1;
        end else begin
            StallF = 'b0;
            StallD = 'b0;
            flushE_load = 'b0;
        end
    end


    //handle branches and flushing
    assign FlushD = PCSrcE;
    assign FlushE = PCSrcE || flushE_load;
endmodule


//extra can be removed?
// module load_store_unit(
//     input logic MemReadM,       //m.MemWriteM?
//     input logic MemWriteE,      //m.MemWriteE?
//     input reg_addr_t RdM,
//     input reg_addr_t Rs2E,

//     output logic ForwardMM          //new output signal?
// );

//     always_comb begin
//         if(MemRead && MemWriteE && RdM == Rs2E) begin
//             ForwardMM = 'b1;
//         end else begin
//             ForwardMM = 'b0;
//         end
//     end

// endmodule
