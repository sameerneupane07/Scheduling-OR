/*********************************************
 * OPL 12.8.0.0 Model
 * Author: sam
 * Creation Date: Sep 4, 2018 at 9:15:02 PM
 *********************************************/
int nJobs=...;
int NbMachine=...;
range Job = 1..nJobs;
range Machine = 1..NbMachine;
range Batch= 1..nJobs;  //considering each job can be in each of the one batch in worst case
float MachineCapacity[Machine]=...;

float p[Job] = ...;
float r[Job]= ...;
float s[Job]= ...;
float d[Job]= ...;

dvar boolean X[Job][Batch][Machine];
dvar float+ BatchReadyTime[Batch][Machine];
dvar float+ BatchProcessTime[Batch][Machine];
dvar float+ BatchCompletionTime[Batch][Machine];
dvar float+ JobCompletionTime[Job];
dvar boolean NbTardy[Job];


float E=...;
float e=...;
dexpr float Objective = sum(j in Job) NbTardy[j]; 

execute {cplex.tilim= 1800;}  // limit the time to 1800 seconds

minimize Objective;

subject to {
	forall(j in Job)
	  Constraint1:
	  sum(b in Batch, m in Machine) X[j][b][m] == 1;
	  
	  forall(b in Batch, m in Machine)
	   Constraint2:
	   sum(j in Job) s[j]*X[j][b][m] <= MachineCapacity[m];
	    
	  forall(j in Job, b in Batch, m in Machine)
	    Constraint3:
	    BatchReadyTime[b][m] >= r[j]*X[j][b][m];
	    
	  forall(j in Job, b in Batch, m in Machine)
	     Constraint4:
	    BatchProcessTime[b][m] >= p[j]*X[j][b][m];
	    
	  forall(m in Machine)
	    Constraint5: //for first batch
	  BatchCompletionTime[1][m]==BatchReadyTime[1][m] + BatchProcessTime[1][m];
	  
	  forall(m in Machine, b in Batch:b>1)
	    Constraint6:
	  BatchCompletionTime[b][m] >= BatchCompletionTime[b-1][m]+ BatchProcessTime[b][m];
	  
	  forall(m in Machine, b in Batch:b>1)
	    Constraint7:
	  BatchCompletionTime[b][m] >= BatchReadyTime[b][m]+ BatchProcessTime[b][m];
	  
	  forall(j in Job, b in Batch, m in Machine)
	    Constraint8:
	  JobCompletionTime[j] >= BatchCompletionTime[b][m]-E+E*X[j][b][m];
	  
	  forall(j in Job)
	    Constraint9:
	  JobCompletionTime[j]-d[j] <= E*NbTardy[j];
	  
	  forall(j in Job)
	    Constraint10:
	  JobCompletionTime[j]-d[j] >= e - E + E*NbTardy[j];

}
