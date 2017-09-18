set I;
/* source */

set J;
/* destination */

set L;
/* Local bandwidth usage */

/* local bandwidth variables */
var l{i in L};

/* local bandwidth parameters */
param lb;

param nthreads;

set A;
/* core Allocation */

param alpha;
param B;
param e;
param beta;

param n;
/* number of cores per node */

var a{i in A} >= 0 <= n integer;

set C;
var c{i in C} >= 0 <= n integer;
/* core alloction variables */



set Y;
var y{i in Y} >= 0 <=1 integer;

set BD;
param bd{i in BD};
/* local bandwidth demand from dramon */

set LD;
var ld{i in LD};
/* Local bandwidth demand */

param ib{i in I, j in J};
/* bandwidth between the nodes from profiling*/
var rw{i in I, j in J};
/* inter-node read/write bandwidth */

var x{i in I, j in J};
/* bandwidth between the nodes */

param unimax{i in I, j in J};

param bimax{i in I, j in J};

maximize bandwidth: sum{i in I, j in J} x[i,j] + sum{i in L} l[i] - sum{i in A} a[i];

/* s.t. constraint1{i in A}: a[i], <= 0, <= n; this one is captured in the variable*/

s.t. constraint2{i in I, j in J, k in A}: rw[i,j] <= a[k] * ib[i,j];

# Handling Multi-hop Links
# node 0
s.t. n00 : x[0,0] = rw[0,0];
s.t. n01 : x[0,1] = rw[0,1] + rw[2,1] + rw[4,1] + rw[6,1];
s.t. n02 : x[0,2] = rw[0,2] + rw[0,3];
s.t. n03 : x[0,3] = rw[0,3];
s.t. n04 : x[0,4] = rw[0,4] + rw[0,5];
s.t. n05 : x[0,5] = rw[0,5];
s.t. n06 : x[0,6] = rw[0,6] + rw[0,7];
s.t. n07 : x[0,7] = rw[0,7];

# node 1
s.t. n10 : x[1,0] = rw[1,0] + rw[5,0] + rw[7,0];
s.t. n11 : x[1,1] = rw[1,1];
s.t. n12 : x[1,2] = rw[1,2];
s.t. n13 : x[1,3] = rw[1,3] + rw[1,2] + rw[3,0];
s.t. n14 : x[1,4] = rw[1,4];
s.t. n15 : x[1,5] = rw[1,5] + rw[1,4];
s.t. n16 : x[1,6] = rw[1,6];
s.t. n17 : x[1,7] = rw[1,7] + rw[1,6];

# node 2
s.t. n20 : x[2,0] = rw[2,0] + rw[2,1];
s.t. n21 : x[2,1] = rw[2,1];
s.t. n22 : x[2,2] = rw[2,2];
s.t. n23 : x[2,3] = rw[2,3] + rw[4,3] + rw[6,3] + rw[0,3];
s.t. n24 : x[2,4] = rw[2,4] + rw[2,5];
s.t. n25 : x[2,5] = rw[2,5];
s.t. n26 : x[2,6] = rw[2,6] + rw[2,7];
s.t. n27 : x[2,7] = rw[2,7];

# node 3
s.t. n30 : x[3,0] = rw[3,0];
s.t. n31 : x[3,1] = rw[3,1] + rw[3,0];
s.t. n32 : x[3,2] = rw[3,2] + rw[1,2] + rw[5,2];
s.t. n33 : x[3,3] = rw[3,3];
s.t. n34 : x[3,4] = rw[3,4];
s.t. n35 : x[3,5] = rw[3,5] + rw[3,4];
s.t. n36 : x[3,6] = rw[3,6];
s.t. n37 : x[3,7] = rw[3,7] + rw[7,2] + rw[3,6];

# node 4
s.t. n40 : x[4,0] = rw[4,0] + rw[4,1];
s.t. n41 : x[4,1] = rw[4,1];
s.t. n42 : x[4,2] = rw[4,2] + rw[4,3];
s.t. n43 : x[4,3] = rw[4,3];
s.t. n44 : x[4,4] = rw[4,4];
s.t. n45 : x[4,5] = rw[4,5] + rw[6,5] + rw[2,5] + rw[0,5];
s.t. n46 : x[4,6] = rw[4,6] + rw[4,7];
s.t. n47 : x[4,7] = rw[4,7];

# node 5
s.t. n50 : x[5,0] = rw[5,0];
s.t. n51 : x[5,1] = rw[5,1] + rw[5,0];
s.t. n52 : x[5,2] = rw[5,2];
s.t. n53 : x[5,3] = rw[5,3] + rw[5,2] + rw[3,4];
s.t. n54 : x[5,4] = rw[5,4] + rw[1,4];
s.t. n55 : x[5,5] = rw[5,5];
s.t. n56 : x[5,6] = rw[5,6];
s.t. n57 : x[5,7] = rw[5,7] + rw[5,6] + rw[7,4];

# node 6
s.t. n60 : x[6,0] = rw[6,0] + rw[6,1];
s.t. n61 : x[6,1] = rw[6,1];
s.t. n62 : x[6,2] = rw[6,2] + rw[6,3];
s.t. n63 : x[6,3] = rw[6,3];
s.t. n64 : x[6,4] = rw[6,4] + rw[6,5];
s.t. n65 : x[6,5] = rw[6,5];
s.t. n66 : x[6,6] = rw[6,6];
s.t. n67 : x[6,7] = rw[6,7] + rw[4,7] + rw[2,7] + rw[0,7];

# node 7
s.t. n70 : x[7,0] = rw[7,0];
s.t. n71 : x[7,1] = rw[7,1] + rw[7,0];
s.t. n72 : x[7,2] = rw[7,2];
s.t. n73 : x[7,3] = rw[7,3] + rw[7,2] + rw[3,6];
s.t. n74 : x[7,4] = rw[7,4];
s.t. n75 : x[7,5] = rw[7,5] + rw[7,4];
s.t. n76 : x[7,6] = rw[7,6] + rw[5,6] + rw[1,6];
s.t. n77 : x[7,7] = rw[7,7];

s.t. constraint4a{i in I, j in J}: x[i,j] <= unimax[i,j];

# Assumes the local bandwidth demand is linear
/* s.t. constraint3{i in L, k in A}: l[i] <= a[k] * lb; */

s.t. constraint4b{i in I, j in J}: x[i,j] + x[j,i] <= bimax[i,j];

s.t. constraint3a{j in LD}: ld[j] = sum{i in BD} if i = 0 then (y[i] * bd[i]) else (y[i] * (bd[i] - bd[i-1]));

# s.t. constraint3b{i in Y, j in A}: if a[j] >= c[i] then y[i] = 1 else y[i] = 0;

s.t. constraint3b{i in C, j in A}: B * y[i] >= a[j] - i + e;

s.t. constraint3c{i in C, j in A}: i * y[i] <= a[j];

s.t. constraint5b{i in I}: sum{j in J: j != i} x[i,j] + beta * ld[i] <= alpha;

s.t. constraint5a{i in I}: sum{j in J: j != i} x[i,j] + l[i] <= alpha;
s.t. constraint3d{i in L, j in LD}: l[i] <= ld[j];

s.t. constraint6 : sum{i in A} a[i] <= nthreads;

# display{i in BD}: i, bd[i];
# display{i in Y}: y[i];
# display: ib[0,1];
# display: x[0,1], x[1,0];

display: sum{i in BD} if i = 0 then (y[i] * bd[i]) else (y[i] * (bd[i] - bd[i-1]));

end;