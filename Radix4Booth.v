module Booth8b (M, X, a, b, c, d); 

input signed [7:0] M, X; 
output signed [15:0] a, b, c, d; 
  
reg signed [15:0] a, b, c, d; 

  reg [2:0] temp0;
  reg [2:0] temp1;
  reg [2:0] temp2;
  reg [2:0] temp3;
  
  
integer i,j;
reg E1; 
reg [7:0] minusM;
reg [7:0] M2;
reg [7:0] minusM2;

always @ (X, M)	
begin	
a = 16'd0;     
  b = 16'd0;
  c = 16'd0;
  d = 16'd0;
  	
minusM = -M;
M2 = M << 1;
minusM2 = -M2;

 i= 0;
 temp0 = {X[1], X[0] , 1'd0};
  case (temp0)
    3'b001 : a[15:8] = M; 
 // +M
    3'b010 : a[15:8] = M;
 // +M
 3'b011 : begin 
   a[15:8]= M;
   i = 1;
 end
 // +2M
 3'b100 : 
   begin
   a[15:8] = minusM;
   i = 1;
   end 
 // -2M
 3'b101 : a[15:8]= minusM;	
 //-M
 3'b110 : a[15:8] = minusM;	 
 //-M
 default: a = 16'd0;
 endcase
  
  a = a >>> 8 ;
  a = a << i ;
  
  i = 0;
  temp0 = {X[3], X[2] , X[1]};
  case (temp0)
    3'b001 : b[15:8] = M; 
 // +M
 3'b010 : b[15:8] = M;
 // +M
 3'b011 : 
   begin
   b[15:8] = M;
     i = 1;
   end
 // +2M
 3'b100 : 
   begin
     b[15:8] = minusM;
     i = 1;
   end 
 // -2M
 3'b101 : b[15:8] = minusM;	
 //-M
 3'b110 : b[15:8] = minusM;	 
 //-M
 default: b = 16'd0;
 endcase
  
  b = b >>> 6;
  b = b << i ;


  i = 0;
  temp0 = {X[5], X[4] ,X[3]};
  case (temp0)
 3'b001 : c[15:8] = M; 
 // +M
 3'b010 :  c[15:8]= M;
 // +M
 3'b011 : 
   begin 
     c[15:8] = M;
     i = 1;
   end 
 // +2M
 3'b100 :  
   begin
     c[15:8] = minusM;
     i = 1;
   end
 // -2M
 3'b101 :  c[15:8] = minusM;	
 //-M
 3'b110 :  c[15:8]= minusM;	 
 //-M
 default:  c[15:8] = 16'd0;
 endcase
  
  c = c >>> 4;
  c = c << i;
  
  
  i = 0;
  temp0 = {X[7], X[6] , X[5]};
  case (temp0)
 3'b001 :  d[15:8] = M; 
 // +M
 3'b010 : d[15:8] = M;
 // +M
 3'b011 : 
   begin
   d[15:8] = M;
   i =  1;
   end 
 // +2M
 3'b100 : 
   begin
     d[15:8] = minusM;
     i = 1;
   end
 // -2M
 3'b101 : d[15:8] = minusM;	
 //-M
 3'b110 : d[15:8] = minusM;	 
 //-M
 default: d = 16'd0;
 endcase

  d = d >>> 2;	
  d = d << i;
end 
endmodule 



module  adder_cla16(a,b, sum);
input [15:0] a,b;
reg cin = 0;
output [15:0] sum;
wire c1,c2,c3;
 
carry_look_ahead_4bit cla1 (.a(a[3:0]), .b(b[3:0]), .cin(cin), .sum(sum[3:0]), .cout(c1));
carry_look_ahead_4bit cla2 (.a(a[7:4]), .b(b[7:4]), .cin(c1), .sum(sum[7:4]), .cout(c2));
carry_look_ahead_4bit cla3(.a(a[11:8]), .b(b[11:8]), .cin(c2), .sum(sum[11:8]), .cout(c3));
carry_look_ahead_4bit cla4(.a(a[15:12]), .b(b[15:12]), .cin(c3), .sum(sum[15:12]), .cout(cout));
 
endmodule

module carry_look_ahead_4bit(a,b, cin, sum,cout);
input [3:0] a,b;
input cin;
output [3:0] sum;
output cout;
 
wire [3:0] p,g,c;
 
assign p=a^b;//propagate
assign g=a&b; //generate
 
assign c[0]=cin;
assign c[1]= g[0]|(p[0]&c[0]);
assign c[2]= g[1] | (p[1]&g[0]) | p[1]&p[0]&c[0];
assign c[3]= g[2] | (p[2]&g[1]) | p[2]&p[1]&g[0] | p[2]&p[1]&p[0]&c[0];
assign cout= g[3] | (p[3]&g[2]) | p[3]&p[2]&g[1] | p[3]&p[2]&p[1]&p[0]&c[0];
assign sum=p^c;
 
endmodule
module test_bench;
  reg signed [7:0] m,x;

  wire signed [15:0] a;
  wire signed [15:0] b;
  wire signed [15:0] c;
  wire signed [15:0] d;

 
  Booth8b generate_partialsum(.M(m), .X(x),.a(a) , .b(b) , .c(c) , .d(d));

wire signed [15:0] sum0;
wire signed [15:0] sum1;
wire signed [15:0] sum2;
output cout ;

 
  adder_cla16 addition1(.a(a), .b(b),.sum(sum0));
  adder_cla16 addition2(.a(c), .b(sum0),.sum(sum1));
  adder_cla16 addition3(.a(d), .b(sum1),.sum(sum2));
 
initial begin
  m=0; x=0;
  #10 m=16'd10; x=16'd10; 
  #10 m=16'd15; x=16'd20; 
  #10 m=16'd20; x=16'd30; 
  #10 m=16'd30; x=16'd40; 
  #10 m=16'd40; x=16'd50; 
  #10 m=16'd50; x=16'd60; 
  #10 m=16'd60; x=16'd70; 
  #10 m=16'd70; x=16'd80; 
  #10 m=16'd80; x=16'd90; 
  #10 m=16'd90; x=16'd100; 
  #10 m=16'd110; x=16'd120; 
  #10 m=16'd120; x=16'd130; 
  #10 m=16'd140; x=16'd150; 
  #10 m=16'd160; x=16'd170; 
  #10 m=16'd180; x=16'd190; 
  #10 m=16'd200; x=16'd210; 
  #10 m=16'd255; x=16'd255; 
  
end

initial  
  $monitor("M=%d, X=%d, Sum=%d", m,x ,sum2);
endmodule
