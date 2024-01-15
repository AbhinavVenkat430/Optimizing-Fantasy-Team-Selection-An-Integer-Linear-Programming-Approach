/*********************************************
 * OPL 22.1.0.0 Model
 * Author: Abhinav
 * Creation Date: 16-Jun-2023 at 7:25:19 PM
 *********************************************/
// SETS
{string} P = ...; // Set of all players
{string} Q = ...; // Set of all positions
int Rounds = ...; // Number of rounds

tuple Player {
  string name;
  string position;
}

Player players[P] = ...; // Tuple of all players

range R = 1..Rounds;

// PARAMETERS
float points[P][R] = ...;
float price[P][R] = ...;
float B = ...; // Budget
int Q_max[Q] = ...; // Max available spots of position Q
int X = ...; // Number of players whose scores count towards team score in each round
int T_total = ...; // Max number of trades that can be used
int T = ...; // Trades per round

// DECISION VARIABLES
dvar boolean x[P][R]; // If player p is in team for round r
dvar boolean y[P][R]; // If the score of player p is included in round r
dvar boolean C[P][R]; // If player p is captain for round r
dvar boolean t_in[P][R]; // If player p is traded into the team for round r (r > 1)
dvar boolean t_out[P][R]; // If player p is traded out of the team for round r (r > 1)
dvar float+ b[R]; // Remaining budget at round r

// 1.OBJECTIVE FUNCTION
maximize sum(p in P, r in R) (points[p][r] * (y[p][r] + 2 * C[p][r]));

// CONSTRAINTS
subject to {
  // 2.Trade constraint per season
  forall (p in P, r in R: r > 1)
     t_in[p][r] <= T_total;

  // 3.Limiting the number of trades per round
  forall (r in R)
     sum(p in P) t_in[p][r] <= T[r];

  // 4.Update of trades per round
  forall (p in P, r in R: r > 1)
    x[p][r] - x[p][r - 1] == t_in[p][r] - t_out[p][r];

  // 5.Captain selection
  forall (r in R) 
  	sum(p in P) C[p][r] == 1;

  // 6.Captain position selection
  forall (r in R, p in P)
     x[p][r] >= C[p][r];

  // 7.Available spots of each position
  forall (r in R, q in Q)
     sum(p in P : players[p].position == q) x[p][r] == Q_max[q];


  // 8.Player has to be in scoring position for score to be counted
  forall (p in P, r in R)
     y[p][r] <= x[p][r];

  // 9.Number of players whose scores count towards team score in each round
  forall (r in R)
     sum(p in P) y[p][r] == X;

  // 10.Value of initial side + Remaining budget <= Budget
  b[1] + sum(p in P) price[p][1] * x[p][1] == B;

  // 11.Remaining budget calculation
  forall (r in R : r > 1)
    b[r] + sum(p in P) price[p][r] * (x[p][r] - t_in[p][r] + t_out[p][r]) == b[r - 1];
}