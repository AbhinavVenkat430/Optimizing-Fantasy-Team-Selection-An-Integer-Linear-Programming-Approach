/*********************************************
 * OPL 22.1.0.0 Model
 * Author: Abhinav
 * Creation Date: 29-Jun-2023 at 4:36:59 PM
 *********************************************/
//SETS
{string} P = ...; //Set of all players
{string} Q = ...; // Set of all positions
int Rounds = ...; // number of rounds


{string} Pq[Q]; // Set of all players p in P who are allowed to play in position q in Q
//{string} Qp[P]; // Set of all positions q in Q, where player p in P is allowed to play
range R = 1..Rounds;

// PARAMETERS
float points[P][R]; // points of player p in round R
float price[P][R]; // Price of player p in round R
float B = ...; // Budget
int C_min[Q]; // min Available spots of Postion Q
int C_max[Q]; // Max available spots of Position Q
int X[R] = ...; // Number of players whose scores count towards team score in each round
int T_total = ...; // max number of trades that can be used
int T[R] = ...; // trades per round


//DECISION VARIABLES
dvar boolean x[P][R]; // If player p is in team for round r
dvar boolean y[P][R]; // If the score of player p is included in round r
dvar boolean C[P][R]; // If player p is captain for round r
dvar boolean t_in[P][R]; // If player p is traded into the team for round r (r > 1)
dvar boolean t_out[P][R]; // If player p is traded out of the team for round r (r > 1)
dvar float+ b[R]; // Remaining budget at round r

 //12.1 OBJECTIVE FN
 
maximize sum(p in P, r in R) (points[p][r] * (y[p][r] + 2*C[p][r]));  


// CONSTRAINTS

subject to{
// 12.2 trade constraint per season
  forall(p in P, r in R: r > 1) 
    t_in[p][r] <= T_total;
    
// 12.3 Limiting the number of trades per round
  forall(r in R) 
    sum(p in P) t_in[p][r] <= T[r];  
    
// 12.4 update of  trades per round -> Q removed as each player can only play one postions
  forall (p in P, r in R: r > 1) 
      x[p][r] - x[p][r-1] ==  t_in[p][r] - t_out[p][r];
   
     
// 12.5 Captain selection  
   forall (r in R) 
    sum(p in P) C[p][r] == 1;
  	  	
//12.6 captain position selection -> removed Q as again, all positions assumed scoring
   forall(r in R, p in P) 
   	  x[p][r] >= C[p][r];
   		   		
// 12.7 Max available spots of each position
  	forall (r in R, q in Q) 
    sum(p in Pq[q]) x[p][r] <= C_max[q];
  
 // 12.7a Min available spots of each position  
  forall (r in R, q in Q)   
    sum(p in Pq[q]) x[p][r] >= C_min[q];
  
 	
//12.9 player has to be in scoring position for score to be counted
 forall(p in P, r in R) 
  	y[p][r] ==  x[p][r];
  
  
// 12.10 No of players whose scores count towards team score in each round	
  forall(r in R) 
    sum(p in P) y[p][r] == X[r]; 
    
    
// 12.11 Value of initial side + Remaining budget <= Budget
	b[1] + sum(p in P) price[p][1] * x[p][1] == B;
  
// 12.12 remaining budget calculation
  forall(r in R:r>1) 
    b[r] == b[r-1] + sum(p in P) price[p][r] * t_out[p][r] - sum(p in P) price[p][r] * t_in[p][r];
  
}