/* ====================================================================================
NUCORE ++
SECOND STEP: OPTIMIZE ALPHA */

/* set of nodes */
set N;

/* local bandwidth variable when multiple threads run */
var l{i in N};

/* local bandwidth demand */
var ld{i in N};

/* % of shared pages placed on node i */
param beta{i in N};

/* shared memory demand */
param s_r; /* bytes read per second */
param s_w; /* bytes written per second */

/* private/local memory demand */
param p;

/* local bandwidth values for solo run*/
param l_solo{i in N} := (p + ((beta[i]/100) * (s_w + s_r)));

/* number of cores per node */
param n;

/* core allocation fixed for this model*/
var alpha{i in N}, integer, >= 0, <= n;

/* bandwidth between the nodes */
var x{i in N, j in N};

/* inter-node read/write bandwidth */
var r{i in N, j in N};
var w{i in N, j in N};

/* toplogy bandwidths */
param unimax{i in N, j in N};
param bimax{i in N, j in N};

/* maximum bandwidth of node[i] */
param max_bw;
param b;

# Objective function: MAXIMIZE THROUGHPUT, MINIMIZE ALPHA
#maximize bandwidth: sum{i in N, j in N: i != j} x[i,j];
maximize bandwidth: (sum{i in N, j in N: i != j} x[i,j] + sum{i in N} l[i]) - (sum{i in N} alpha[i]);

# bound alpha
s.t. constraintalpha{i in N}: 0 <= alpha[i] <= n;

# INTERCONNECT USAGE WHEN MULTIPLE THREADS RUN
s.t. constraintnodereads{i in N, j in N: i != j }: r[i,j] <= s_r * alpha[i] * (beta[i]/100);
s.t. constraintnodewrites{i in N, j in N: i != j }: w[i,j] <= s_w * alpha[i] * (beta[j]/100);

# Handling Multi-hop Links - fictious Machine
#node 0
s.t. n01: x[0,1] = r[0,1] + w[0,1] + r[0,2] + w[0,2];
s.t. n02: x[0,2] = r[0,2] + w[0,2];

#node 1
s.t. n10: x[1,0] = r[1,0] + w[1,0] + r[2,0] + w[2,0];
s.t. n12: x[1,2] = r[1,2] + w[1,2] + r[0,2] + w[0,2];

#node 2
s.t. n20: x[2,0] = r[2,0] + w[2,0];
s.t. n21: x[2,1] = r[2,1] + w[2,1] + r[2,0] + w[2,0];

# INTERCONNECT BANDWIDTH
s.t. constraint4a{i in N, j in N: i != j}: x[i,j] <= unimax[i,j];
s.t. constraint4b{i in N, j in N: i != j}: x[i,j] + x[j,i] <= bimax[i,j];

# LOCAL MEMORY DEMAND
# solo thread demand
# s.t. constraintlsolo{i in N}: l_solo[i] = (p + (beta[i] * (s_w + s_r)));
# multiple threads demand - Assumes the local bandwidth usage is linear...in reality this is not the case{DraMon}
s.t. constraintlmultiple{i in N}: ld[i] = l_solo[i] * alpha[i];

# sum of the total out-going bandwdth and the local bandwidth of node[i], can't exceed its maximum bandwidth alpha 
s.t. constraintmax_bw{i in N}: sum{j in N: j != i} x[i,j] + l[i] <= max_bw;

# constraint of the local and remote access contention
s.t. constraintlocal_remote{i in N}: sum{j in N: j != i} x[i,j] + b * ld[i] <= max_bw;

# local bandwidth usage is limited by its local bandwidth demand
s.t. constraintbwdemand{i in N}: l[i] <= ld[i];

solve;
display{i in N}: l[i];
display{i in N}: beta[i];
display{i in N, j in N}: x[i,j];
display{i in N, j in N}: unimax[i,j];
display: p, s_r, s_w, alpha;

end;
