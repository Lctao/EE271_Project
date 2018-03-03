//
//---------------------------------------------------------------------------
//  THIS FILE WAS AUTOMATICALLY GENERATED BY THE STANFORD GENESIS2 ENGINE
//  FOR MORE INFORMATION, CONTACT OFER SHACHAM FROM THE STANFORD VLSI GROUP
//  THIS VERSION OF GENESIS2 IS NOT TO BE USED FOR ANY COMMERCIAL USE
//---------------------------------------------------------------------------
//
//  
//	-----------------------------------------------
//	|            Genesis Release Info             |
//	|  $Change: 11012 $ --- $Date: 2012/09/13 $   |
//	-----------------------------------------------
//	
//
//  Source file: /home/lctao13/EE271_proj/assignment2/rtl/bbox.vp
//  Source template: bbox
//
// --------------- Begin Pre-Generation Parameters Status Report ---------------
//
//	From 'generate' statement (priority=5):
// Parameter SigFig 	= 24
// Parameter Colors 	= 3
// Parameter Vertices 	= 3
// Parameter PipelineDepth 	= 3
// Parameter Radix 	= 10
// Parameter Axis 	= 3
//
//		---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
//
//	From Command Line input (priority=4):
//
//		---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
//
//	From XML input (priority=3):
//
//		---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
//
//	From Config File input (priority=2):
//
// ---------------- End Pre-Generation Pramameters Status Report ----------------

/*
 * Bounding Box Module
 *     
 * Inputs: 
 *   3 x,y,z vertices corresponding to tri 
 *   1 valid bit, indicating triangle is valid data
 * 
 *  Config Inputs:
 *   2 x,y vertices indicating screen dimensions
 *   1 integer representing square root of SS (16MSAA->4)
 *      we will assume config values are held in some
 *      register and are valid given a valid polygon
 * 
 *  Control Input:
 *   1 halt signal indicating that no work should be done 
 * 
 * Outputs:
 *   2 vertices describing a clamped bounding box
 *   1 Valid signal indicating that bounding 
 *           box and triangle value is valid
 *   3 x,y vertices corresponding to tri
 * 
 * Global Signals: 
 *   clk, rst
 * 
 * Function:
 *   Determine a bounding box for the polygon
 *   represented by the vertices.
 * 
 *   Clamp the Bounding Box to the subsample pixel
 *   space
 *   
 *   Clip the Bounding Box to Screen Space
 *
 *   Halt operating but retain values if next stage is busy
 *
 * 
 * Long Description:
 *   This bounding box block accepts a polygon described with three
 *   vertices and determines a set of sample points to test against
 *   the micropolygon.  These sample points correspond to the 
 *   either the pixels in the final image or the pixel fragments 
 *   that compose the pixel if multisample anti-aliasing (MSAA)
 *   is enabled.
 * 
 *   The inputs to the box are clocked with a bank of dflops.  
 * 
 *   After the data is clocked, a bounding box is determined 
 *   for the micropolygon. A bounding box can be determined 
 *   through calculating the maxima and minima for x and y to 
 *   generate a lower left vertice and upper right
 *   vertice.  This data is then clocked.
 * 
 *   The bounding box next needs to be clamped to the fragment grid.
 *   This can be accomplished through rounding the bounding box values
 *   to the fragment grid.  Additionally, any sample points that exist
 *   outside of screen space should be rejected.  So the bounding box
 *   can be clipped to the visible screen space.  This clipping is done
 *   using the screen signal.
 *
 *   The Halt signal is utilized to hold the current polygon bounding box.
 *   This is because one bounding box operation could correspond to
 *   multiple sample test operations later in the pipe.  As these samples
 *   can take a number of cycles to complete, the data held in the bounding
 *   box stage needs to be preserved.  The halt signal is also required for 
 *   when the write device is full/busy.
 * 
 *   The valid signal is utilized to indicate whether or a polygon 
 *   is actual data.  This can be useful if the device being read from,
 *   has no more micropolygons.
 * 
 * 
 * 
 *   Author: John Brunhaver
 *   Created:      Thu 07/23/09
 *   Last Updated: Fri 09/30/10
 *
 *   Copyright 2009 <jbrunhaver@gmail.com>   
 */


/* ***************************************************************************
 * Change bar:
 * -----------
 * Date           Author    Description
 * Sep 19, 2012   jingpu    ported from John's original code to Genesis
 *                          
 * ***************************************************************************/

/******************************************************************************
 * PARAMETERIZATION
 * ***************************************************************************/
// SigFig (_GENESIS2_INHERITANCE_PRIORITY_) = 24
//
// Radix (_GENESIS2_INHERITANCE_PRIORITY_) = 10
//
// Vertices (_GENESIS2_INHERITANCE_PRIORITY_) = 3
//
// Axis (_GENESIS2_INHERITANCE_PRIORITY_) = 3
//
// Colors (_GENESIS2_INHERITANCE_PRIORITY_) = 3
//
// PipelineDepth (_GENESIS2_INHERITANCE_PRIORITY_) = 3
//

/* A Note on Signal Names:
 *
 * Most signals have a suffix of the form _RxxxxN 
 * where R indicates that it is a Raster Block signal
 * xxxx indicates the clock slice that it belongs to
 * N indicates the type of signal that it is.
 *    H indicates logic high, 
 *    L indicates logic low,
 *    U indicates unsigned fixed point, 
 *    S indicates signed fixed point.
 * 
 * For all the signed fixed point signals (logic signed [24-1:0]),
 * their highest 14 bits, namely [23:10]
 * represent the integer part of the fixed point number, 
 * while the lowest 10 bits, namely [9:0]
 * represent the fractional part of the fixed point number.
 * 
 * 
 * 
 * For signal subSample_RnnnnU (logic [3:0])
 * 1000 for  1x MSAA eq to 1 sample per pixel
 * 0100 for  4x MSAA eq to 4 samples per pixel, 
 *              a sample is half a pixel on a side
 * 0010 for 16x MSAA eq to 16 sample per pixel,
 *              a sample is a quarter pixel on a side.  
 * 0001 for 64x MSAA eq to 64 samples per pixel, 
 *              a sample is an eighth of a pixel on a side.
 * 
 */



module bbox_unq1
  (
   //Input Signals
   input logic signed [24-1:0] 	poly_R10S[3-1:0][3-1:0] , // Sets X,Y Fixed Point Values
   input logic 				unsigned [24-1:0] color_R10U[3-1:0] , // Color of Poly
   input logic 				isQuad_R10H , // Is Poly Quad?
   input logic 				validPoly_R10H , // Valid Data for Operation

   //Control Signals
   input logic 				halt_RnnnnL , // Indicates No Work Should Be Done
   input logic signed [24-1:0] 	screen_RnnnnS[1:0] , // Screen Dimensions
   input logic [3:0] 			subSample_RnnnnU , // SubSample_Interval

   //Global Signals
   input logic 				clk, // Clock 
   input logic 				rst, // Reset

   //Outout Signals
   output logic signed [24-1:0] poly_R13S[3-1:0][3-1:0], // 4 Sets X,Y Fixed Point Values
   output logic 			unsigned [24-1:0] color_R13U[3-1:0] , // Color of Poly
   output logic 			isQuad_R13H, // Is Poly Quad?
   output logic signed [24-1:0] box_R13S[1:0][1:0], // 2 Sets X,Y Fixed Point Values  
   output logic 			validPoly_R13H                  // Valid Data for Operation
   );
   
   
   //Signals In Clocking Order

   //R10 Signals

   // Step 1 Result: LL and UR X, Y Fixed Point Values determined by calculating min/max vertices
   // box_R10S[0][0]: LL X
   // box_R10S[0][1]: LL Y
   // box_R10S[1][0]: UR X
   // box_R10S[1][1]: UR Y
   logic signed [24-1:0] 	box_R10S[1:0][1:0];
   // Step 2 Result: LL and UR Rounded Down to SubSample Interval
   logic signed [24-1:0] 	rounded_box_R10S[1:0][1:0];
   // Step 3 Result: LL and UR X, Y Fixed Point Values after Clipping
   logic signed [24-1:0] 	out_box_R10S[1:0][1:0];      // bounds for output
   // Step 3 Result: valid if validPoly_R10H && BBox within screen
   logic 				outvalid_R10H;               // output is valid
   
   //////// DECLARE OTHER SIGNALS YOU NEED
   logic [1:0][3:0] comp_sel_R10H;
   logic [3:0] comp_val_R10S;

   logic [2:0] subSample_mask_R10U;

   logic [3:0] validBox_R10H;
   //R10 Signals
   
   // output for retiming registers
   logic signed [24-1:0] 	poly_R13S_retime[3-1:0][3-1:0]; // 4 Sets X,Y Fixed Point Values
   logic 				unsigned [24-1:0] color_R13U_retime[3-1:0];        // Color of Poly
   logic signed [24-1:0] 	box_R13S_retime[1:0][1:0];             // 2 Sets X,Y Fixed Point Values  
   logic 				isQuad_R13H_retime;                   // Is Poly Quad?
   logic 				validPoly_R13H_retime ;                 // Valid Data for Operation
   // output for retiming registers


   // ********** Step 1:  Determining a Bounding Box ********** 

   /* OLD QUAD CODE Used to be here */
   
   /* Note to the bold!!! */
   /* You can actually process more than
    * 3 vertices if you really want.
    * You can even do more than 4.
    * If you are interested in building
    * a paramaterized implementation
    * to evaluate N-vertice draw calls,
    * talk with John B.
    * */

   // Assign select signals
   always_comb begin
      comp_sel_R10H[0][0] = poly_R10S[0][0] < poly_R10S[1][0];
      comp_sel_R10H[0][1] = poly_R10S[0][1] < poly_R10S[1][1];
      comp_sel_R10H[0][2] = poly_R10S[0][0] > poly_R10S[1][0];
      comp_sel_R10H[0][3] = poly_R10S[0][1] > poly_R10S[1][1];

      comp_sel_R10H[1][0] = comp_val_R10S[0] < poly_R10S[2][0];
      comp_sel_R10H[1][1] = comp_val_R10S[1] < poly_R10S[2][1];
      comp_sel_R10H[1][2] = comp_val_R10S[2] > poly_R10S[2][0];
      comp_sel_R10H[1][3] = comp_val_R10S[3] > poly_R10S[2][1];
   end

   // Assign mux inout
   always_comb begin
     // Level 1
     // UR_X
      unique case (comp_sel_R10H[0][0])
         (1'b0): comp_val_R10S[0] = poly_R10S[0][0];
         (1'b1): comp_val_R10S[0] = poly_R10S[1][0];
      endcase
      unique case (comp_sel_R10H[1][0])
         (1'b0): box_R10S[1][0]   = comp_val_R10S[0];
         (1'b1): box_R10S[1][0]   = poly_R10S[2][0];
      endcase
     
      // UR_Y
      unique case (comp_sel_R10H[0][1])
         (1'b0): comp_val_R10S[1] = poly_R10S[0][1];
         (1'b1): comp_val_R10S[1] = poly_R10S[1][1];
      endcase
      unique case (comp_sel_R10H[1][1])
         (1'b0): box_R10S[1][1]   = comp_val_R10S[1];
         (1'b1): box_R10S[1][1]   = poly_R10S[2][1];
      endcase

      // LL_X
      unique case (comp_sel_R10H[0][2])
         (1'b0): comp_val_R10S[2] = poly_R10S[0][0];
         (1'b1): comp_val_R10S[2] = poly_R10S[1][0];
      endcase
      unique case (comp_sel_R10H[1][2])
         (1'b0): box_R10S[0][0]   = comp_val_R10S[2];
         (1'b1): box_R10S[0][0]   = poly_R10S[2][0];
      endcase
     
      // LL_Y
      unique case (comp_sel_R10H[0][3])
         1'b0: comp_val_R10S[3] = poly_R10S[0][1];
         1'b1: comp_val_R10S[3] = poly_R10S[1][1];
      endcase
      unique case (comp_sel_R10H[1][3])
         1'b0: box_R10S[0][1]   = comp_val_R10S[3];
         1'b1: box_R10S[0][1]   = poly_R10S[2][1];
      endcase

   end

   // ***************** End of Step 1 *********************


   // ********** Step 2:  Round Values to Subsample Interval **********

   // We will use the floor operation for rounding.
   // To floor a signal, we simply turn all of the bits
   // below a specific 10 to 0.
   // The complication here is that there are 4 setting.
   // 1x MSAA eq. to 1 sample per pixel
   // 4x MSAA eq to 4 samples per pixel, a sample is
   // half a pixel on a side
   // 16x MSAA eq to 16 sample per pixel, a sample is
   // a quarter pixel on a side.  
   // 64x MSAA eq to 64 samples per pixel, a sample is
   // an eighth of a pixel on a side.

   // Note: Cleverly converting the MSAA signal
   //       to a mask would allow you to do this operation
   //       as a bitwise and operation.

   
   //Round LowerLeft and UpperRight for X and Y
   // Convert MSAA signal to mask 
   always_comb begin
      unique case (subSample_RnnnnU)
         (4'b0001): subSample_mask_R10U = 3'b111;
         (4'b0010): subSample_mask_R10U = 3'b110;
         (4'b0100): subSample_mask_R10U = 3'b100;
         (4'b1000): subSample_mask_R10U = 3'b000;
      endcase 
   end // always_comb
   always_comb begin
      
      // Integer Portion of LL and UR Remains the Same 
      rounded_box_R10S[0][0][24-1:10] 
     = box_R10S[0][0][24-1:10];

      // Use mask to assign middle bits
      rounded_box_R10S[0][0][10-1:10-3]
     = box_R10S[0][0][10-1:10-3] & subSample_mask_R10U;

      // All bits of fractional portion below 4 bits are 0
      rounded_box_R10S[0][0][10-4:0] = 7'b0;
   end // always_comb

   always_comb begin
      
      // Integer Portion of LL and UR Remains the Same 
      rounded_box_R10S[0][1][24-1:10] 
     = box_R10S[0][1][24-1:10];

      // Use mask to assign middle bits
      rounded_box_R10S[0][1][10-1:10-3]
     = box_R10S[0][1][10-1:10-3] & subSample_mask_R10U;

      // All bits of fractional portion below 4 bits are 0
      rounded_box_R10S[0][1][10-4:0] = 7'b0;
   end // always_comb

   always_comb begin
      
      // Integer Portion of LL and UR Remains the Same 
      rounded_box_R10S[1][0][24-1:10] 
     = box_R10S[1][0][24-1:10];

      // Use mask to assign middle bits
      rounded_box_R10S[1][0][10-1:10-3]
     = box_R10S[1][0][10-1:10-3] & subSample_mask_R10U;

      // All bits of fractional portion below 4 bits are 0
      rounded_box_R10S[1][0][10-4:0] = 7'b0;
   end // always_comb

   always_comb begin
      
      // Integer Portion of LL and UR Remains the Same 
      rounded_box_R10S[1][1][24-1:10] 
     = box_R10S[1][1][24-1:10];

      // Use mask to assign middle bits
      rounded_box_R10S[1][1][10-1:10-3]
     = box_R10S[1][1][10-1:10-3] & subSample_mask_R10U;

      // All bits of fractional portion below 4 bits are 0
      rounded_box_R10S[1][1][10-4:0] = 7'b0;
   end // always_comb


   // ***************** End of Step 2 *********************


   // ********** Step 3:  Clipping or Rejection ********** 

   // Clamp if LL is down/left of screen origin
   // Clamp if UR is up/right of Screen
   // Invalid if BBox is up/right of Screen
   // Invalid if BBox is down/left of Screen
   // outvalid_R10H high if validPoly_R10H && BBox is valid

   always_comb begin
      //////// PLACE YOUR CODE HERE
      //////// ASSIGN "out_box_R10S" and "outvalid_R10H"

      // Clip rounded box to bounding box
      out_box_R10S[1][0] = (rounded_box_R10S[1][0] > screen_RnnnnS[0]) ? 
                           screen_RnnnnS[0] : rounded_box_R10S[1][0];
      out_box_R10S[1][1] = (rounded_box_R10S[1][1] > screen_RnnnnS[1]) ? 
                           screen_RnnnnS[1] : rounded_box_R10S[1][1];
      out_box_R10S[0][0] = (rounded_box_R10S[0][0] < 0) ? 
                           0 : rounded_box_R10S[0][0]; 
      out_box_R10S[0][1] = (rounded_box_R10S[0][1] < 0) ? 
                           0 : rounded_box_R10S[0][1];

      
      // Check for valid bounding box
      validBox_R10H[0] = (rounded_box_R10S[1][0] >= 0);
      validBox_R10H[1] = (rounded_box_R10S[1][1] >= 0);
      validBox_R10H[2] = (rounded_box_R10S[0][0] <= screen_RnnnnS[0]);
      validBox_R10H[3] = (rounded_box_R10S[0][1] <= screen_RnnnnS[1]);
      outvalid_R10H = validPoly_R10H & (&validBox_R10H);
   end

   // ***************** End of Step 3 *********************


   
   //Flop Clamped Box to R13_retime with retiming registers
   dff3_unq1  d_bbx_r1 (
			       .in(poly_R10S) , 
			       .clk(clk) , .reset(rst), .en(halt_RnnnnL),
			       .out(poly_R13S_retime));
   
   dff2_unq1  d_bbx_r2(
			      .in(color_R10U) , 
			      .clk(clk) , .reset(rst), .en(halt_RnnnnL),
			      .out(color_R13U_retime));
   
   dff3_unq2  d_bbx_r3 (
			       .in(out_box_R10S) , 
			       .clk(clk) , .reset(rst), .en(halt_RnnnnL),
			       .out(box_R13S_retime));
   
   dff_unq2  d_bbx_r4(
			      .in({isQuad_R10H, outvalid_R10H}) , 
			      .clk(clk) , .reset(rst), .en(halt_RnnnnL),
			      .out({isQuad_R13H_retime, validPoly_R13H_retime}));
   //Flop Clamped Box to R13_retime with retiming registers
   
   
   
   //Flop R13_retime to R13 with fixed registers
   dff3_unq3  d_bbx_f1 (
			       .in(poly_R13S_retime) , 
			       .clk(clk) , .reset(rst), .en(halt_RnnnnL),
			       .out(poly_R13S));
   
   dff2_unq3  d_bbx_f2(
			      .in(color_R13U_retime) , 
			      .clk(clk) , .reset(rst), .en(halt_RnnnnL),
			      .out(color_R13U));
   
   dff3_unq4  d_bbx_f3 (
			       .in(box_R13S_retime) , 
			       .clk(clk) , .reset(rst), .en(halt_RnnnnL),
			       .out(box_R13S));
   
   dff_unq4  d_bbx_f4(
			      .in({isQuad_R13H_retime, validPoly_R13H_retime}) , 
			      .clk(clk) , .reset(rst), .en(halt_RnnnnL),
			      .out({isQuad_R13H, validPoly_R13H}));
   //Flop R13_retime to R13 with fixed registers


   //Error Checking Assertions

   //Define a Less Than Property
   //  
   //  a should be less than b
   property rb_lt( rst, a , b , c );
      @(posedge clk) rst | ((a<=b) | !c);
   endproperty

   //Check that Lower Left of Bounding Box is less than equal Upper Right
   assert property( rb_lt( rst, box_R13S[0][0] , box_R13S[1][0] , validPoly_R13H ));
   assert property( rb_lt( rst, box_R13S[0][1] , box_R13S[1][1] , validPoly_R13H ));
   //Check that Lower Left of Bounding Box is less than equal Upper Right
   
   //Error Checking Assertions

   
endmodule 
