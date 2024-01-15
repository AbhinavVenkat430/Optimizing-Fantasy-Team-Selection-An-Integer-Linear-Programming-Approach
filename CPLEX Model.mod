
// SETS
{string} P = ...; // Set of all players
{string} Q = ...; // Set of all positions
int Rounds = ...; // Number of rounds
range R = 1..Rounds;

// Players in each position
{string} Q_GK = ...;
{string} Q_DEF =...;
{string} Q_MID =...;
{string} Q_FWD =...;

// PARAMETERS
float points[P][R]= ...;   // points of player p in round R
float price[P][R]= ...;   // Price of player p in round R
float B = ...;           // Budget
int Q_max[Q]= ...;;     // min Available spots of Postion Q
int Q_Points[Q]= ...;  // Number of players of each position allowed to score points    
int X = ...;          // Number of players whose scores count towards team score in each round
int T_total = ...;   // max number of trades that can be used
int T = ...;        // trades per round

// DECISION VARIABLES
dvar boolean x[P][R];     // If player p is in team for round r
dvar boolean y[P][R];     // If the score of player p is included in round r
dvar boolean C[P][R];     // If player p is captain for round r
dvar boolean t_in[P][R];  // If player p is traded into the team for round r (r > 1)
dvar boolean t_out[P][R]; // If player p is traded out of the team for round r (r > 1)
dvar float+ b[R];         // Remaining budget at round r
 
// 1.OBJECTIVE FUNCTION
maximize sum(p in P, r in R) (points[p][r] * (y[p][r] + C[p][r]));

// CONSTRAINTS
subject to {
  // 2.Trade constraint per season
  forall (p in P, r in R: r > 1)
     t_in[p][r] <= T_total;

// 3.Limiting the number of trades per round
  forall (r in R)
     sum(p in P) t_in[p][r] <= T;

// 4.Update of trades per round
  forall (p in P, r in R: r > 1)
    x[p][r] - x[p][r-1] == t_in[p][r] - t_out[p][r];

// 5.Captain selection
  forall (r in R) 
  	sum(p in P) C[p][r] == 1;

// 6.Captain position selection
  forall (r in R, p in P)
     x[p][r] >= C[p][r];
     
// 7.Available spots of each position
  forall (r in R) {
    sum(p in Q_GK) x[p][r] == Q_max["GK"];
    sum(p in Q_DEF) x[p][r] == Q_max["DEF"];
    sum(p in Q_MID) x[p][r] == Q_max["MID"];
    sum(p in Q_FWD) x[p][r] == Q_max["FWD"];
  }

// 8.Player has to be in scoring position for score to be counted
  forall (p in P, r in R)
     y[p][r] <= x[p][r];

// 9.Max number of players from Each position allowed
  forall (r in R) {
	  sum(p in Q_GK) y[p][r] == Q_Points["GK"];
	  sum(p in Q_DEF) y[p][r] == Q_Points["DEF"];
	  sum(p in Q_MID) y[p][r] == Q_Points["MID"];
	  sum(p in Q_FWD) y[p][r] == Q_Points["FWD"];
	}
	

// 10.Number of players whose scores count towards team score in each round
  forall (r in R)
     sum(p in P) y[p][r] == X;

// 11.Value of initial side + Remaining budget <= Budget
  forall (r in R)
  b[r] + sum(p in P) price[p][r] * x[p][r] <= B;

// 12.Remaining budget calculation
  forall(r in R:r>1) 
    b[r] == b[r-1] + sum(p in P) price[p][r] * t_out[p][r] - sum(p in P) price[p][r] * t_in[p][r];
       
}  