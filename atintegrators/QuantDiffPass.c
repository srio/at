#include "at.h"
#include <time.h>
#if !(defined PCWIN || defined PCWIN32 || defined PCWIN64)
#include <sys/time.h>
#endif
#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

double drand();   /* uniform distribution, (0..1] */

double random_normal();  /* normal distribution, centered on 0, std dev 1 */

void QuantDiffPass(double *r_in, double* Lmatp , double *Seed, int nturn, int num_particles)
/* Lmatp 6x6 matrix
 * r_in - 6-by-N matrix of initial conditions reshaped into
 * 1-d array of 6*N elements
 */
{
  double *r6;
  int c, i, j;
  double randnorm[6];
  double diffusion[6] = {0.0,0.0,0.0,0.0,0.0,0.0};
  static int initSeed = 1;	/* 	If this variable is 1, then I initialize the seed
				 * 	to the clock and I change the variable to 0
				 */
  
  if(Seed)
    {
      if(nturn==0)
        {
	  srand((int)Seed[0]);
        }
    }
  else if(initSeed)
    {
#if !(defined PCWIN || defined PCWIN32 || defined PCWIN64)
      {
        struct timeval time;
        gettimeofday(&time,NULL);
        srand((time.tv_sec * 1000000) + (time.tv_usec));
      }
#endif
      initSeed = 0;
    }
  for (c = 0; c<num_particles; c++)
    { /*Loop over particles  */
      r6 = r_in+c*6;
      for (i=0;i<6;i++)
        {
	  diffusion[i]=0.0;
	  randnorm[i]=random_normal();
        }
      
      for (i=0;i<6;i++)
        {
	  for (j=0;j<=i;j++)
            {
	      diffusion[i]+=randnorm[j]*Lmatp[i+6*j];
            }
        }
      if(!mxIsNaN(r6[0]))
        {
	  r6[0] += diffusion[0];
	  r6[1] += diffusion[1];
	  r6[2] += diffusion[2];
	  r6[3] += diffusion[3];
	  r6[4] += diffusion[4];
	  r6[5] += diffusion[5];
        }
    }
}


double drand()   /* uniform distribution, (0..1] */
{
    return (rand()+1.0)/(RAND_MAX+1.0);
}
double random_normal()  /* normal distribution, centered on 0, std dev 1 */
{
    return sqrt(-2*log(drand())) * cos(2*M_PI*drand());
}

#ifdef MATLAB_MEX_FILE

#include "elempass.h"
#include "mxutils.c"

ExportMode int* trackFunction(const mxArray *ElemData,int *FieldNumbers,
        double *r_in, int num_particles, struct parameters *Param)
#define NUM_FIELDS_2_REMEMBER 2
{
    double *Lmatp;
    double *Seed;
    int nturn;
	nturn=Param->nturn;
    switch(Param->mode) {
        case MAKE_LOCAL_COPY: 	/* Find field numbers first
         * Save a list of field number in an array
         * and make returnptr point to that array
         */
            
            FieldNumbers = (int*)mxCalloc(NUM_FIELDS_2_REMEMBER,sizeof(int));
            
            /* Populate */
            FieldNumbers[0] = GetRequiredFieldNumber(ElemData, "Lmatp");
            /* Optional field */
            FieldNumbers[1] = mxGetFieldNumber(ElemData,"Seed");
            
            /* Fall through next section... */
        case USE_LOCAL_COPY:	/* Get fields from MATLAB using field numbers
         * The second argument ponter to the array of field
         * numbers is previously created with
         * QuadLinPass( ..., MAKE_LOCAL_COPY)
         */
            
            Lmatp = mxGetPr(mxGetFieldByNumber(ElemData,0,FieldNumbers[0]));
            Seed = (FieldNumbers[1] >= 0) ? mxGetPr(mxGetFieldByNumber(ElemData, 0, FieldNumbers[1])) : NULL;

            break;
        default:
            mexErrMsgTxt("No match for calling mode in function QuantDiffPass\n");
    }
    QuantDiffPass(r_in, Lmatp, Seed, nturn, num_particles);
    return FieldNumbers;
}

void mexFunction(	int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (nrhs == 2) {
        double *r_in;
        double *Lmatp;
        double *Seed;
        mxArray *tmpmxptr;
        int i;
        int num_particles = mxGetN(prhs[1]);
        if (mxGetM(prhs[1]) != 6) mexErrMsgIdAndTxt("AT:WrongArg","Second argument must be a 6 x N matrix");
        /* ALLOCATE memory for the output array of the same size as the input  */
        plhs[0] = mxDuplicateArray(prhs[1]);
        tmpmxptr = mxGetField(prhs[0],0,"Lmatp");
        if(tmpmxptr)
            Lmatp = mxGetPr(tmpmxptr);
        else
            mexErrMsgTxt("Required field 'Lmatp' was not found in the element data structure");
        tmpmxptr = mxGetField(prhs[0],0,"Seed");
        Seed = tmpmxptr ? mxGetPr(tmpmxptr) : NULL;
        r_in = mxGetPr(plhs[0]);
        QuantDiffPass(r_in, Lmatp, Seed, 0, num_particles);
    }
    else if (nrhs == 0) {
        /* list of required fields */
        plhs[0] = mxCreateCellMatrix(1,1);
        mxSetCell(plhs[0],0,mxCreateString("Lmatp"));
        if (nlhs>1) {
            /* list of optional fields */
            plhs[1] = mxCreateCellMatrix(1,1);
            mxSetCell(plhs[1],0,mxCreateString("Seed"));
        }
    }
    else {
        mexErrMsgIdAndTxt("AT:WrongArg","Needs 0 or 2 arguments");
    }
}
#endif

