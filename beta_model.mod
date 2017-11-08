
/* =====================================================================================
FIRST STEP: MODEL TO OPTIMIZE BETA
Here we assume a fictional workload: same number of threads per node (unknown), uniform private demand and shared demand

Question: what private and shared demand should we consider? Is there any magical numbers, or should we get these values from a real workload?


parameters:
- topology (unidirectional bandwidths, local bw)
- workload demands (private and shared demands)
- alpha : fixed and uniform (same for all nodes; start by 1)

optimization: beta[i in N]

maximize throughput

reuse the constraints of nucore++
===========================================================================================
*/

/* set of nodes */
set N;

/* local bandwidth variables for solo run*/
var l_solo{i in N};

/* local bandwidth variable when multiple threads run */
var l{i in N};

/* local bandwidth demand */
var ld{i in N};

/* % of shared pages placed on node i */
var beta{i in N}, integer, >= 0, <= 100;

/* shared memory demand */
param s_r; /* bytes read per second */
param s_w; /* bytes written per second */

/* private/local memory demand */
param p;

/* number of cores per node */
param n;

/* core allocation fixed for this model*/
param alpha := 1;

param b;

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

# Objective function: MAXIMIZE THROUGHPUT
#maximize bandwidth: sum{i in N, j in N: i != j} x[i,j];
maximize bandwidth: sum{i in N, j in N: i != j} x[i,j] + sum{i in N} l[i];

# bound beta
s.t. constraintsumofbeta: sum{i in N} beta[i] = 100;

# INTERCONNECT USAGE WHEN MULTIPLE THREADS RUN
s.t. constraintnodereads{i in N, j in N: i != j }: r[i,j] <= s_r * alpha * (beta[i]/100);
s.t. constraintnodewrites{i in N, j in N: i != j }: w[i,j] <= s_w * alpha * (beta[j]/100);
#s.t. constraintsumreadwrite{i in N, j in N: i != j}: x[i,j] = r[i,j] + w[i,j];

# Handling Multi-hop Links - Deimos Machine

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
s.t. constraintlsolo{i in N}: l_solo[i] = (p + ((beta[i]/100) * (s_w + s_r)));
# multiple threads demand - Assumes the local bandwidth usage is linear...in reality this is not the case{DraMon}
s.t. constraintlmultiple{i in N}: ld[i] = l_solo[i] * alpha;

# sum of the total out-going bandwdth and the local bandwidth of node[i], can't exceed its maximum bandwidth alpha 
s.t. constraintmax_bw{i in N}: sum{j in N: j != i} x[i,j] + l[i] <= max_bw;

# constraint of the local and remote access contention
s.t. constraintlocal_remote{i in N}: sum{j in N: j != i} x[i,j] + b * ld[i] <= max_bw;

# local bandwidth usage is limited by its local bandwidth demand
s.t. constraintbwdemand{i in N}: l[i] <= ld[i];

/*solve;
display{i in N}: l[i];
display{i in N}: beta[i];
display{i in N, j in N}: x[i,j];
display{i in N, j in N}: unimax[i,j];
display: p, s_r, s_w, alpha;*/

end;