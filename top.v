/*
 *  my_multiplier - an unoptimized multiplier
 *
 *  copyright (c) 2021  hirosh dabui <hirosh@dabui.de>
 *
 *  permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  the software is provided "as is" and the author disclaims all warranties
 *  with regard to this software including all implied warranties of
 *  merchantability and fitness. in no event shall the author be liable for
 *  any special, direct, indirect, or consequential damages or any damages
 *  whatsoever resulting from loss of use, data or profits, whether in an
 *  action of contract, negligence or other tortious action, arising out of
 *  or in connection with the use or performance of this software.
 *
 */
`include "ledscan.v"
`include "mul.v"
module top(input clk12MHz,
           input  resetn,
           output led1,
           output led2,
           output led3,
           output led4,
           output led5,
           output led6,
           output led7,
           output led8,
           output lcol1,
           output lcol2,
           output lcol3,
           output lcol4);

// these are the led holding registers, whatever you write to these appears on the led display
reg [7:0] leds1;
reg [7:0] leds2;
reg [7:0] leds3;
reg [7:0] leds4;

// The output from the ledscan module
wire [7:0] leds;
wire [3:0] lcol;

// map the output of ledscan to the port pins
assign { led8, led7, led6, led5, led4, led3, led2, led1 } = leds[7:0];
assign { lcol4, lcol3, lcol2, lcol1 } = lcol[3:0];

// Counter register

// instantiate the led scan module
LedScan scan (
            .clk12MHz(clk12MHz),
            .leds1(leds1),
            .leds2(leds2),
            .leds3(leds3),
            .leds4(leds4),
            .leds(leds),
            .lcol(lcol)
        );

`ifdef SYNTHESIS
`else
reg clk;
always  #(10) clk = (clk === 1'b0);

initial begin
    $dumpfile("testbench.vcd");
    $dumpvars(0, top);
    $dumpon;
    repeat(100) @(posedge clk);
    $finish;
end
`endif

localparam WIDTH = 8;
localparam WAIT_STATES = 12_000_0;
reg  [WIDTH-1:0] a;
reg  [WIDTH-1:0] b;
wire [(WIDTH<<1)-1:0] c;

wire clk = clk12MHz;

mul #(WIDTH) mul_i(a, b, c);
assign leds4 = ~a;
assign leds3 = ~b;
assign leds2 = ~c[7:0];
assign leds1 = ~(c[15:8]);

reg [2:0] state = 0;
reg [2:0] return_state = 0;
reg [31:0] wait_states = 0;

always @(posedge clk) begin
  if (~resetn) state <= 0;
  else
    case (state)
        0: begin
            a <= 0;
            b <= 0;
            state <= 1;
        end
        1: begin
            a <= a + 1;
            wait_states <= WAIT_STATES;
            state <= 3;
            return_state <= &a ? 2 : 1;
        end
        2: begin
            b <= b + 1;
            wait_states <= WAIT_STATES;
            return_state <= 1;
            state <= 3;
        end
        3: begin
            wait_states <= wait_states - 1;
            if (wait_states == 1) state <= return_state;
        end
    endcase
end


endmodule
