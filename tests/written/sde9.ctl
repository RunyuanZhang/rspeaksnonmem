$PROBLEM PK ODE HANDS ON ONE
$INPUT ID TIME DV AMT CMT FLAG MDV SDE
$DATA   sde9.csv IGNORE=@
$SUBROUTINE ADVAN6 TOL=9 DP OTHER=sde.f90
$MODEL 
COMP = (CENTRAL);
COMP = (DFDX1)
COMP = (DPDT11)
$PK
IF(NEWIND.NE.2) OT = 0
MU_1  = THETA(1)
CL    = EXP(MU_1+ETA(1)) 
MU_2  = THETA(2)
VD    = EXP(MU_2+ETA(2))
SGW1 = THETA(4)
$DES
" FIRST
" REAL*8 SGW(3)
FIRSTEM=1
DADT(1) = - CL/VD*A(1)
; NEXT DERIVATIVES ARE ACUALLY PREDICTIVE VALUES FOR COMPARTMENTS 1 AND 2, RESPECTIVELY
;  Derivatives of these with respect to A() will be calcualted symbolically by DES routine created by NMTRAN
DADT(2) = A(1)/VD
; DUMMY PLACEMENT FOR DERIVATIVES OF THE STOCHASTIC ERROR SYSTEM.  THESE ARE FILLED OUT BY SDE_DER
" SGW(1)=SGW1
;  the DA() array THEN contains all derivatives of DADT (=DXDT) with respect to A(=X).
; Number of compartments=1, number of base model derivative equations=1
"LAST
"      CALL SDE_DER(DADT,A,DA,IR,SGW,1.0d+00,1.0d+00)
$ERROR (OBS ONLY)
IPRED = A(1)/VD
IRES  = DV - IPRED
W     = THETA(3)
IWRES = IRES/W
WS=1000.0
; CENTRAL COMPARTMENT, PLASMA LEVELS
; EPS(1) = USER MODEL ERROR CONTRIBUTION
; EPS(2) = STOCHASTIC ERROR CONTRIBUTION.  THE WS IS JUST A PLACEHOLDER COEFFICIENT.  SDE_CADD WILL REPLACE THIS
; WITH THE CORRECT VALUE
Y     = IPRED+W*EPS(1) + WS*EPS(2)
; SDE_CADD WILL EVALUATE THE TRUE COEFFICIENTS (WS) TO THE STOCHASTIC COMPONENTS.
; Number of compartments=1, number of base model derivative equations=1
"LAST
"       CALL SDE_CADD(A,HH,TIME,DV,CMT,1.0D+00,1.0D+00,SDE)
$THETA (0, 2.3, ) ; 1 CL
(0, 3.5, ) ; 2 VD
(0, 2, ) ; 4 SIGMA
(0, 1, ) ; SGW1
$OMEGA 0.1  ; 1 CL
$OMEGA 0.01  ; 2 VD
$SIGMA 1 FIX ; PK 
1 FIX ; PK
$EST METHOD=ITS INTERACTION LAPLACE NUMERICAL SLOW NOABORT PRINT=1 CTYPE=3 SIGL=5
 $EST METHOD=IMP INTERACTION NOABORT SIGL=5 PRINT=1 IACCEPT=1.0 CTYPE=3
 $EST MAXEVAL=9999 METHOD=1 LAPLACE INTER NOABORT NUMERICAL SLOW NSIG=3 PRINT=1 MSFO=sde9.msf
$COV MATRIX=R 

$TABLE ID TIME FLAG AMT CMT IPRED IRES IWRES APPEND ONEHEADER NOPRINT FILE=sde9.fit