;O'Reilly RA, Aggeler PM, Leong LS. Studies of the coumarin anticoagulant
;drugs: The pharmacodynamics of warfarin in man.
;Journal of Clinical Investigation 1963;42(10):1542-1551
;O'Reilly RA, Aggeler PM. Studies on coumarin anticoagulant drugs
;Initiation of warfarin therapy without a loading dose.
;Circulation 1968;38:169-177
	
$PROB WARFARIN PK
$INPUT
ID TIME WT AGE SEX AMT DVID DV MDV

$DATA warfarin_conc_pca.csv
	IGNORE=#
IGNORE (DVID.EQ.2)


$SUBR
ADVAN2 TRANS2 


$PK
GRPCL = THETA(1)*(WT/70)**0.75
GRPV = THETA(2)*WT/70
GRPKA = THETA(3)
GRPLG = THETA(4)
CL = GRPCL*EXP(ETA(1)) 
V = GRPV*EXP(ETA(2)) 
KA = GRPKA*EXP(ETA(3)) 
ALAG1 = GRPLG*EXP(ETA(4)) 
S2 = V

$ERROR (ONLY OBSERVATIONS)
CENTRAL = F
CC = (CENTRAL/V)
IPRED = CC

W = THETA(5)+THETA(6)*CC
Y = CC + W*EPS(1)
IRES = DV - IPRED
IWRES = IRES/W

IF (ICALL.EQ.4) THEN
   IF (F.GT.0) THEN
	Y = CC
   ELSE 
	Y = 0
   ENDIF
ENDIF

$THETA
(0.001, 0.1, ) ; POP_CL
(0.001, 8, ) ; POP_V
(0.001, 2, ) ; POP_KA
0.25 FIX ; POP_TLAG

(0, 0.01) ; RUV_ADD
(0, 0.05) ; RUV_PROP

$OMEGA BLOCK (2) 
0.1 ; PPV_CL
0.01 0.1 ; PPV_V

$OMEGA
0.1 ; PPV_KA
0 FIX ; PPV_TLAG

$SIGMA
1.0 FIX

$EST METHOD=COND INTER
MAX=9990 SIG=3 NOABORT ;PRINT=1
$COV

$TABLE ID TIME IPRED IRES RES PRED WRES NOPRINT ONEHEADER FILE=sdtab0
$TABLE ID CL V KA ALAG1 ETA(1) ETA(2) ETA(3) ETA(4) NOPRINT NOAPPEND ONEHEADER FILE=patab0
$TABLE ID AGE WT NOPRINT NOAPPEND ONEHEADER FILE=cotab0
$TABLE ID SEX NOPRINT NOAPPEND ONEHEADER FILE=catab0
