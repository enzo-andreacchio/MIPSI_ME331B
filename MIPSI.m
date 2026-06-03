function [t,VAR,Output] = MIPSI
%===========================================================================
% File: MIPSI.m created Jun  2 2026 by MotionGenesis 6.6.
% Portions copyright (c) 2009-2025 Motion Genesis LLC.  Rights reserved.
% MotionGenesis Student Licensee: ME331 Stanford Student. (until January 2027).
% This MotionGenesis Student license is granted the right to use this code
% only until January 2027, only for legal student-academic (non-professional) purposes,
% and limited to their coursework completion at their accredited school.
% All use of this code is specifically limited to this student licensee.
% No rights are extended for other purposes or to anyone but the licensee.
% This copyright notice must appear in all uses of this code.
%===========================================================================
% The software is provided "as is", without warranty of any kind, express or
% implied, including but not limited to the warranties of merchantability or
% fitness for a particular purpose. In no event shall the authors, contributors,
% or copyright holders be liable for any claim, damages or other liability,
% whether in an action of contract, tort, or otherwise, arising from, out of, or
% in connection with the software or the use or other dealings in the software.
%===========================================================================
eventDetectedByIntegratorTerminate1OrContinue0 = [];
IyyLink=0; IzzWheel=0; FxF=0; FxR=0; FyF=0; FyR=0; qFDt=0; qRDt=0; wFDt=0; wRDt=0; qADDt=0; qBDDt=0; qCDDt=0; xDDt=0; yDDt=0; qBDesired=0;
TBA=0; TCB=0; TF=0; TR=0; xDesired=0; yDesired=0; qBDesiredDt=0; xDesiredDt=0; yDesiredDt=0; qBDesiredDDt=0; xDesiredDDt=0; yDesiredDDt=0;
yRaw=0; penDownDesired=0;
trajectoryTime=[]; trajectoryX=[]; trajectoryY=[]; trajectoryPenDown=[]; trajectoryXDt=[]; trajectoryYDt=[]; trajectoryXDDt=[]; trajectoryYDDt=[];
tracePointCount=50;


%-------------------------------+--------------------------+-------------------+-----------------
% Quantity                      | Value                    | Units             | Description
%-------------------------------|--------------------------|-------------------|-----------------
g                               =  9.8;                    % m/s^2               Constant
L                               =  1.0;                    % m                   Constant
mLink                           =  1;                      % kg                  Constant
mWheel                          =  0.5;                    % kg                  Constant
qBMid                           =  0;                      % deg                 Constant
qBRange                         =  0;                      % deg                 Constant
rLink                           =  0.05;                   % meters              Constant
rWheel                          =  0.25;                   % meters              Constant
wnQB                            =  10;                     % rad/sec             Constant
wnX                             =  5;                      % rad/sec             Constant
wnY                             =  20;                     % rad/sec             Constant

qA                              =  10;                     % deg                 Initial Value
qB                              =  0;                      % deg                 Initial Value
qC                              =  10;                     % deg                 Initial Value
qF                              =  0;                      % deg                 Initial Value
qR                              =  0;                      % deg                 Initial Value
wF                              =  0;                      % rad/sec             Initial Value
wR                              =  0;                      % rad/sec             Initial Value
x                               =  0;                      % m                   Initial Value
y                               =  0.4236481776669303;     % m                   Initial Value
%y                               =  0.9571067811865475;     % m                   Initial Value
qADt                            =  0;                      % rad/sec             Initial Value
qBDt                            =  0;                      % rad/sec             Initial Value
qCDt                            =  0;                      % rad/sec             Initial Value
xDt                             =  0;                      % m/s                 Initial Value
yDt                             =  0;                      % m/s                 Initial Value

tInitial                        =  0.0;                    % second              Initial Time
tFinal                          =  10;                     % sec                 Final Time
tStep                           =  0.02;                   % sec                 Integration Step
printIntScreen                  =  1;                      % 0 or +integer       0 is NO screen output
printIntFile                    =  1;                      % 0 or +integer       0 is NO file   output
absError                        =  1.0E-09;                %                     Absolute Error
relError                        =  1.0E-08;                %                     Relative Error
%-------------------------------+--------------------------+-------------------+-----------------

% Unit conversions
DEGtoRAD = pi / 180.0;
RADtoDEG = 180.0 / pi;
qBMid = qBMid * DEGtoRAD;
qBRange = qBRange * DEGtoRAD;
qA = qA * DEGtoRAD;
qB = qB * DEGtoRAD;
qC = qC * DEGtoRAD;
qF = qF * DEGtoRAD;
qR = qR * DEGtoRAD;

% Evaluate constants
IzzWheel = 0.5*mWheel*rWheel^2;
IyyLink = 0.08333333333333333*mLink*(L^2+3*rLink^2);

LoadRobotTrajectory;
tInitial = trajectoryTime(1);
tFinal = trajectoryTime(end);


VAR = SetMatrixFromNamedQuantities;
[t,VAR,Output] = IntegrateForwardOrBackward( tInitial, tFinal, tStep, absError, relError, VAR, printIntScreen, printIntFile );
OutputToScreenOrFile( [], 0, 0 );   % Close output files.


%===========================================================================
   function LoadRobotTrajectory
      %===========================================================================
      trajectoryFile = fullfile( fileparts(mfilename('fullpath')), 'csv_files', 'robot_trajectory.csv' );
      trajectoryData = readtable( trajectoryFile );
      requiredTrajectoryColumns = {'t', 'x', 'y', 'penDown'};
      if( ~all(ismember(requiredTrajectoryColumns, trajectoryData.Properties.VariableNames)) )
         error('Error: %s must contain columns t, x, y, penDown', trajectoryFile);
      end
      
      trajectoryTimeRaw = trajectoryData.t(:);
      trajectoryXRaw = trajectoryData.x(:);
      trajectoryYRaw = trajectoryData.y(:);
      trajectoryPenDownRaw = trajectoryData.penDown(:);
      if( any(~isfinite(trajectoryTimeRaw)) || any(~isfinite(trajectoryXRaw)) || any(~isfinite(trajectoryYRaw)) || any(~isfinite(trajectoryPenDownRaw)) )
         error('Error: %s contains non-finite trajectory values', trajectoryFile);
      end
      
      [trajectoryTime, trajectoryUniqueIndex] = unique( trajectoryTimeRaw, 'last' );
      trajectoryX = trajectoryXRaw(trajectoryUniqueIndex);
      trajectoryY = trajectoryYRaw(trajectoryUniqueIndex);
      trajectoryPenDown = trajectoryPenDownRaw(trajectoryUniqueIndex);
      if( length(trajectoryTime) < 2 )
         error('Error: %s must contain at least two unique trajectory times', trajectoryFile);
      end
      
      trajectoryXDt = gradient( trajectoryX, trajectoryTime );
      trajectoryYDt = gradient( trajectoryY, trajectoryTime );
      trajectoryXDDt = gradient( trajectoryXDt, trajectoryTime );
      trajectoryYDDt = gradient( trajectoryYDt, trajectoryTime );
   end


%===========================================================================
   function sys = mdlDerivatives( t, VAR, uSimulink )
      %===========================================================================
      SetNamedQuantitiesFromMatrix( VAR );
      
      qRDt = wR;
      qFDt = wF;
      
      % Quantities previously specified in MotionGenesis.
      xDesired = interp1( trajectoryTime, trajectoryX, t, 'linear', 'extrap' );
      xDesiredDt = interp1( trajectoryTime, trajectoryXDt, t, 'linear', 'extrap' );
      xDesiredDDt = interp1( trajectoryTime, trajectoryXDDt, t, 'linear', 'extrap' );
      yDesired = interp1( trajectoryTime, trajectoryY, t, 'linear', 'extrap' );
      yDesiredDt = interp1( trajectoryTime, trajectoryYDt, t, 'linear', 'extrap' );
      yDesiredDDt = interp1( trajectoryTime, trajectoryYDDt, t, 'linear', 'extrap' );
      penDownDesired = interp1( trajectoryTime, trajectoryPenDown, t, 'previous', 'extrap' );
      qBDesired = qBMid + qBRange*cos(2*t);
      qBDesiredDt = -2*qBRange*sin(2*t);
      qBDesiredDDt = -4*qBRange*cos(2*t);
      
      COEF = zeros( 15, 15 );
      COEF(1,1) = 0.5*(mLink+2*mWheel)*L*sin(qA);
      COEF(1,3) = -0.5*(mLink+2*mWheel)*L*sin(qC);
      COEF(1,4) = 2*mWheel + 3*mLink;
      COEF(1,12) = -1;
      COEF(1,14) = -1;
      COEF(2,1) = -0.5*(mLink+2*mWheel)*L*cos(qA);
      COEF(2,3) = -0.5*(mLink+2*mWheel)*L*cos(qC);
      COEF(2,5) = 2*mWheel + 3*mLink;
      COEF(2,13) = -1;
      COEF(2,15) = -1;
      COEF(3,1) = IyyLink + mWheel*L^2 + 0.25*mLink*L^2;
      COEF(3,2) = 0.25*(mLink+2*mWheel)*L^2*cos(qA-qB);
      COEF(3,4) = 0.5*(mLink+2*mWheel)*L*sin(qA);
      COEF(3,5) = -0.5*(mLink+2*mWheel)*L*cos(qA);
      COEF(3,8) = -1;
      COEF(3,9) = 1;
      COEF(3,12) = -L*sin(qA);
      COEF(3,13) = L*cos(qA);
      COEF(4,1) = 0.25*(mLink+2*mWheel)*L^2*cos(qA-qB);
      COEF(4,2) = IyyLink + 0.5*mLink*L^2 + 0.5*mWheel*L^2;
      COEF(4,3) = -0.25*(mLink+2*mWheel)*L^2*cos(qB+qC);
      COEF(4,9) = -1;
      COEF(4,10) = 1;
      COEF(4,12) = -0.5*L*sin(qB);
      COEF(4,13) = 0.5*L*cos(qB);
      COEF(4,14) = 0.5*L*sin(qB);
      COEF(4,15) = -0.5*L*cos(qB);
      COEF(5,2) = -0.25*(mLink+2*mWheel)*L^2*cos(qB+qC);
      COEF(5,3) = IyyLink + mWheel*L^2 + 0.25*mLink*L^2;
      COEF(5,4) = -0.5*(mLink+2*mWheel)*L*sin(qC);
      COEF(5,5) = -0.5*(mLink+2*mWheel)*L*cos(qC);
      COEF(5,10) = 1;
      COEF(5,11) = -1;
      COEF(5,14) = L*sin(qC);
      COEF(5,15) = L*cos(qC);
      COEF(6,6) = IzzWheel;
      COEF(6,8) = 1;
      COEF(6,12) = -rWheel;
      COEF(7,7) = IzzWheel;
      COEF(7,11) = -1;
      COEF(7,14) = -rWheel;
      COEF(8,1) = -L*cos(qA);
      COEF(8,2) = -0.5*L*cos(qB);
      COEF(8,5) = 1;
      COEF(9,2) = 0.5*L*cos(qB);
      COEF(9,3) = -L*cos(qC);
      COEF(9,5) = 1;
      COEF(10,1) = L*sin(qA);
      COEF(10,2) = 0.5*L*sin(qB);
      COEF(10,4) = 1;
      COEF(10,6) = rWheel;
      COEF(11,2) = -0.5*L*sin(qB);
      COEF(11,3) = -L*sin(qC);
      COEF(11,4) = 1;
      COEF(11,7) = rWheel;
      COEF(12,4) = -1;
      COEF(13,5) = -1;
      COEF(14,2) = -1;
      COEF(15,8) = 1;
      COEF(15,11) = 1;
      RHS = zeros( 1, 15 );
      RHS(1) = -0.5*L*(mLink*cos(qA)*qADt^2+2*mWheel*cos(qA)*qADt^2-2*mWheel*cos(qC)*qCDt^2-mLink*cos(qC)*qCDt^2);
      RHS(2) = -3*mLink*g - 2*mWheel*g - 0.5*L*(mLink*sin(qA)*qADt^2+mLink*sin(qC)*qCDt^2+2*mWheel*sin(qA)*qADt^2+2*mWheel*sin(qC)*qCDt^2);
      RHS(3) = 0.25*L*(2*mLink*g*cos(qA)+4*mWheel*g*cos(qA)-(mLink+2*mWheel)*L*sin(qA-qB)*qBDt^2);
      RHS(4) = -0.25*L^2*(mLink*sin(qB+qC)*qCDt^2+2*mWheel*sin(qB+qC)*qCDt^2-2*mWheel*sin(qA-qB)*qADt^2-mLink*sin(qA-qB)*qADt^2);
      RHS(5) = 0.25*L*(2*mLink*g*cos(qC)+4*mWheel*g*cos(qC)-(mLink+2*mWheel)*L*sin(qB+qC)*qBDt^2);
      RHS(8) = -0.5*L*(sin(qB)*qBDt^2+2*sin(qA)*qADt^2);
      RHS(9) = 0.5*L*(sin(qB)*qBDt^2-2*sin(qC)*qCDt^2);
      RHS(10) = -0.5*L*(cos(qB)*qBDt^2+2*cos(qA)*qADt^2);
      RHS(11) = 0.5*L*(cos(qB)*qBDt^2+2*cos(qC)*qCDt^2);
      RHS(12) = -xDesiredDDt - wnX^2*(xDesired-x) - 2*wnX*(xDesiredDt-xDt);
      RHS(13) = -yDesiredDDt - wnY^2*(yDesired-y) - 2*wnY*(yDesiredDt-yDt);
      RHS(14) = -qBDesiredDDt - wnQB^2*(qBDesired-qB) - 2*wnQB*(qBDesiredDt-qBDt);
      SolutionToAlgebraicEquations = COEF \ transpose(RHS);
      
      % Update variables after uncoupling equations
      qADDt = SolutionToAlgebraicEquations(1);
      qBDDt = SolutionToAlgebraicEquations(2);
      qCDDt = SolutionToAlgebraicEquations(3);
      xDDt = SolutionToAlgebraicEquations(4);
      yDDt = SolutionToAlgebraicEquations(5);
      wRDt = SolutionToAlgebraicEquations(6);
      wFDt = SolutionToAlgebraicEquations(7);
      TR = SolutionToAlgebraicEquations(8);
      TBA = SolutionToAlgebraicEquations(9);
      TCB = SolutionToAlgebraicEquations(10);
      TF = SolutionToAlgebraicEquations(11);
      FxR = SolutionToAlgebraicEquations(12);
      FyR = SolutionToAlgebraicEquations(13);
      FxF = SolutionToAlgebraicEquations(14);
      FyF = SolutionToAlgebraicEquations(15);
      
      sys = transpose( SetMatrixOfDerivativesPriorToIntegrationStep );
   end



%===========================================================================
   function VAR = SetMatrixFromNamedQuantities
      %===========================================================================
      VAR = zeros( 1, 14 );
      VAR(1) = qA;
      VAR(2) = qB;
      VAR(3) = qC;
      VAR(4) = qF;
      VAR(5) = qR;
      VAR(6) = wF;
      VAR(7) = wR;
      VAR(8) = x;
      VAR(9) = y;
      VAR(10) = qADt;
      VAR(11) = qBDt;
      VAR(12) = qCDt;
      VAR(13) = xDt;
      VAR(14) = yDt;
   end


%===========================================================================
   function SetNamedQuantitiesFromMatrix( VAR )
      %===========================================================================
      qA = VAR(1);
      qB = VAR(2);
      qC = VAR(3);
      qF = VAR(4);
      qR = VAR(5);
      wF = VAR(6);
      wR = VAR(7);
      x = VAR(8);
      y = VAR(9);
      qADt = VAR(10);
      qBDt = VAR(11);
      qCDt = VAR(12);
      xDt = VAR(13);
      yDt = VAR(14);
   end


%===========================================================================
   function VARp = SetMatrixOfDerivativesPriorToIntegrationStep
      %===========================================================================
      VARp = zeros( 1, 14 );
      VARp(1) = qADt;
      VARp(2) = qBDt;
      VARp(3) = qCDt;
      VARp(4) = qFDt;
      VARp(5) = qRDt;
      VARp(6) = wFDt;
      VARp(7) = wRDt;
      VARp(8) = xDt;
      VARp(9) = yDt;
      VARp(10) = qADDt;
      VARp(11) = qBDDt;
      VARp(12) = qCDDt;
      VARp(13) = xDDt;
      VARp(14) = yDDt;
   end



%===========================================================================
   function Output = mdlOutputs( t, VAR, uSimulink )
      %===========================================================================
      SetNamedQuantitiesFromMatrix( VAR );
      persistent tracePointX tracePointY tracePointTime;
      tracePointTimeSpacing = 0.1;
      hiddenTracePointPosition = 100.0;
      Output = zeros( 1, 87 + 4*tracePointCount );
      isAtStartOfTrajectory = t <= trajectoryTime(1) + 10*eps(max(1,abs(trajectoryTime(1))));
      if( isempty(tracePointX) || isAtStartOfTrajectory )
         tracePointX = hiddenTracePointPosition*ones( 1, tracePointCount );
         tracePointY = hiddenTracePointPosition*ones( 1, tracePointCount );
         tracePointTime = NaN;
      end
      if( isnan(tracePointTime) || t >= tracePointTime + tracePointTimeSpacing - 10*eps(max(1,abs(t))) )
         penDownDesired = interp1( trajectoryTime, trajectoryPenDown, t, 'previous', 'extrap' );
         if( penDownDesired >= 0.5 )
            nextTracePointX = x;
            nextTracePointY = y;
         else
            nextTracePointX = hiddenTracePointPosition;
            nextTracePointY = hiddenTracePointPosition;
         end
         tracePointX = [nextTracePointX tracePointX(1:tracePointCount-1)];
         tracePointY = [nextTracePointY tracePointY(1:tracePointCount-1)];
         tracePointTime = t;
      end
      Output(1) = t;
      Output(2) = x;
      Output(3) = y;
      Output(4) = TR;
      Output(5) = TBA;
      Output(6) = TCB;
      Output(7) = TF;
      Output(8) = qA*RADtoDEG;
      Output(9) = qB*RADtoDEG;
      Output(10) = qC*RADtoDEG;
      
      Output(11) = t;
      Output(12) = x-0.5*L*cos(qA)-0.5*L*cos(qB);
      Output(13) = y-0.5*L*sin(qA)-0.5*L*sin(qB);
      Output(14) = 0.0;
      Output(15) = cos(qA);
      Output(16) = -sin(qA);
      Output(17) = 0.0;
      Output(18) = sin(qA);
      Output(19) = cos(qA);
      Output(20) = 0.0;
      Output(21) = 0.0;
      Output(22) = 0.0;
      Output(23) = 1.0;
      
      Output(24) = t;
      Output(25) = x-0.5*L*cos(qB);
      Output(26) = y-0.5*L*sin(qB);
      Output(27) = 0.0;
      Output(28) = cos(qB);
      Output(29) = -sin(qB);
      Output(30) = 0.0;
      Output(31) = sin(qB);
      Output(32) = cos(qB);
      Output(33) = 0.0;
      Output(34) = 0.0;
      Output(35) = 0.0;
      Output(36) = 1.0;
      
      Output(37) = t;
      Output(38) = x+0.5*L*cos(qB);
      Output(39) = y+0.5*L*sin(qB);
      Output(40) = 0.0;
      Output(41) = cos(qC);
      Output(42) = sin(qC);
      Output(43) = 0.0;
      Output(44) = -sin(qC);
      Output(45) = cos(qC);
      Output(46) = 0.0;
      Output(47) = 0.0;
      Output(48) = 0.0;
      Output(49) = 1.0;
      
      Output(50) = t;
      Output(51) = x+L*cos(qC)+0.5*L*cos(qB);
      Output(52) = y+0.5*L*sin(qB)-L*sin(qC);
      Output(53) = 0.0;
      Output(54) = cos(qF);
      Output(55) = -sin(qF);
      Output(56) = 0.0;
      Output(57) = sin(qF);
      Output(58) = cos(qF);
      Output(59) = 0.0;
      Output(60) = 0.0;
      Output(61) = 0.0;
      Output(62) = 1.0;
      
      Output(63) = t;
      Output(64) = x-L*cos(qA)-0.5*L*cos(qB);
      Output(65) = y-L*sin(qA)-0.5*L*sin(qB);
      Output(66) = 0.0;
      Output(67) = cos(qR);
      Output(68) = -sin(qR);
      Output(69) = 0.0;
      Output(70) = sin(qR);
      Output(71) = cos(qR);
      Output(72) = 0.0;
      Output(73) = 0.0;
      Output(74) = 0.0;
      Output(75) = 1.0;
      
      Output(76) = t;
      Output(77) = x+L*cos(qC)+0.5*L*cos(qB);
      Output(78) = y+0.5*L*sin(qB)-rWheel-L*sin(qC);
      Output(79) = 0.0;
      
      Output(80) = t;
      Output(81) = x;
      Output(82) = y;
      Output(83) = 0.0;
      
      Output(84) = t;
      Output(85) = x-L*cos(qA)-0.5*L*cos(qB);
      Output(86) = y-rWheel-L*sin(qA)-0.5*L*sin(qB);
      Output(87) = 0.0;
      
      for( i = 1 : tracePointCount )
         outputIndex = 88 + 4*(i-1);
         Output(outputIndex) = t;
         Output(outputIndex+1) = tracePointX(i);
         Output(outputIndex+2) = tracePointY(i);
         Output(outputIndex+3) = 0.0;
      end
   end


%===========================================================================
   function OutputToScreenOrFile( Output, shouldPrintToScreen, shouldPrintToFile )
      %===========================================================================
      persistent FileIdentifier hasHeaderInformationBeenWritten;
      
      if( isempty(Output) ),
         if( ~isempty(FileIdentifier) ),
            for( i = 1 : tracePointCount + 9 ),  fclose( FileIdentifier(i) );  end
            clear FileIdentifier;
            fprintf( 1, '\n Output is in the files MIPSI.i  (i=1, ..., %d)\n', tracePointCount + 9 );
            fprintf( 1, '\n Note: To automate plotting, issue the command OutputPlot in MotionGenesis.\n' );
            fprintf( 1, '\n To load and plot columns 1 and 2 with a solid line and columns 1 and 3 with a dashed line, enter:\n' );
            fprintf( 1, '    someName = load( ''MIPSI.1'' );\n' );
            fprintf( 1, '    plot( someName(:,1), someName(:,2), ''-'', someName(:,1), someName(:,3), ''--'' )\n\n' );
         end
         clear hasHeaderInformationBeenWritten;
         return;
      end
      
      if( isempty(hasHeaderInformationBeenWritten) ),
         if( shouldPrintToScreen ),
            fprintf( 1,                '%%       t              x              y             TR             TBA            TCB            TF             qA             qB             qC\n' );
            fprintf( 1,                '%%     (sec)        (meters)       (meters)         (N*m)          (N*m)          (N*m)          (N*m)          (deg)          (deg)          (deg)\n\n' );
         end
         if( shouldPrintToFile && isempty(FileIdentifier) ),
            FileIdentifier = zeros( 1, tracePointCount + 9 );
            FileIdentifier(1) = fopen('MIPSI.1', 'wt');   if( FileIdentifier(1) == -1 ), error('Error: unable to open file MIPSI.1'); end
            fprintf(FileIdentifier(1), '%% FILE: MIPSI.1\n%%\n' );
            fprintf(FileIdentifier(1), '%%       t              x              y             TR             TBA            TCB            TF             qA             qB             qC\n' );
            fprintf(FileIdentifier(1), '%%     (sec)        (meters)       (meters)         (N*m)          (N*m)          (N*m)          (N*m)          (deg)          (deg)          (deg)\n\n' );
            FileIdentifier(2) = fopen('MIPSI.2', 'wt');   if( FileIdentifier(2) == -1 ), error('Error: unable to open file MIPSI.2'); end
            fprintf(FileIdentifier(2), '%% FILE: MIPSI.2\n%%\n' );
            fprintf(FileIdentifier(2), '%%       t         P_No_Acm[1]    P_No_Acm[2]    P_No_Acm[3]     N_A[1,1]       N_A[1,2]       N_A[1,3]       N_A[2,1]       N_A[2,2]       N_A[2,3]       N_A[3,1]       N_A[3,2]       N_A[3,3]\n' );
            fprintf(FileIdentifier(2), '%%   (second)        (meter)        (meter)        (meter)       (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)\n\n' );
            FileIdentifier(3) = fopen('MIPSI.3', 'wt');   if( FileIdentifier(3) == -1 ), error('Error: unable to open file MIPSI.3'); end
            fprintf(FileIdentifier(3), '%% FILE: MIPSI.3\n%%\n' );
            fprintf(FileIdentifier(3), '%%       t         P_No_Bo[1]     P_No_Bo[2]     P_No_Bo[3]      N_B[1,1]       N_B[1,2]       N_B[1,3]       N_B[2,1]       N_B[2,2]       N_B[2,3]       N_B[3,1]       N_B[3,2]       N_B[3,3]\n' );
            fprintf(FileIdentifier(3), '%%   (second)        (meter)        (meter)        (meter)       (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)\n\n' );
            FileIdentifier(4) = fopen('MIPSI.4', 'wt');   if( FileIdentifier(4) == -1 ), error('Error: unable to open file MIPSI.4'); end
            fprintf(FileIdentifier(4), '%% FILE: MIPSI.4\n%%\n' );
            fprintf(FileIdentifier(4), '%%       t         P_No_Co[1]     P_No_Co[2]     P_No_Co[3]      N_C[1,1]       N_C[1,2]       N_C[1,3]       N_C[2,1]       N_C[2,2]       N_C[2,3]       N_C[3,1]       N_C[3,2]       N_C[3,3]\n' );
            fprintf(FileIdentifier(4), '%%   (second)        (meter)        (meter)        (meter)       (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)\n\n' );
            FileIdentifier(5) = fopen('MIPSI.5', 'wt');   if( FileIdentifier(5) == -1 ), error('Error: unable to open file MIPSI.5'); end
            fprintf(FileIdentifier(5), '%% FILE: MIPSI.5\n%%\n' );
            fprintf(FileIdentifier(5), '%%       t         P_No_Fcm[1]    P_No_Fcm[2]    P_No_Fcm[3]     N_F[1,1]       N_F[1,2]       N_F[1,3]       N_F[2,1]       N_F[2,2]       N_F[2,3]       N_F[3,1]       N_F[3,2]       N_F[3,3]\n' );
            fprintf(FileIdentifier(5), '%%   (second)        (meter)        (meter)        (meter)       (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)\n\n' );
            FileIdentifier(6) = fopen('MIPSI.6', 'wt');   if( FileIdentifier(6) == -1 ), error('Error: unable to open file MIPSI.6'); end
            fprintf(FileIdentifier(6), '%% FILE: MIPSI.6\n%%\n' );
            fprintf(FileIdentifier(6), '%%       t         P_No_Rcm[1]    P_No_Rcm[2]    P_No_Rcm[3]     N_R[1,1]       N_R[1,2]       N_R[1,3]       N_R[2,1]       N_R[2,2]       N_R[2,3]       N_R[3,1]       N_R[3,2]       N_R[3,3]\n' );
            fprintf(FileIdentifier(6), '%%   (second)        (meter)        (meter)        (meter)       (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)      (NoUnits)\n\n' );
            FileIdentifier(7) = fopen('MIPSI.7', 'wt');   if( FileIdentifier(7) == -1 ), error('Error: unable to open file MIPSI.7'); end
            fprintf(FileIdentifier(7), '%% FILE: MIPSI.7\n%%\n' );
            fprintf(FileIdentifier(7), '%%       t         P_No_FN[1]     P_No_FN[2]     P_No_FN[3]\n' );
            fprintf(FileIdentifier(7), '%%   (second)        (meter)        (meter)        (meter)\n\n' );
            FileIdentifier(8) = fopen('MIPSI.8', 'wt');   if( FileIdentifier(8) == -1 ), error('Error: unable to open file MIPSI.8'); end
            fprintf(FileIdentifier(8), '%% FILE: MIPSI.8\n%%\n' );
            fprintf(FileIdentifier(8), '%%       t       P_No_Pencil[1] P_No_Pencil[2] P_No_Pencil[3]\n' );
            fprintf(FileIdentifier(8), '%%   (second)        (meter)        (meter)        (meter)\n\n' );
            FileIdentifier(9) = fopen('MIPSI.9', 'wt');   if( FileIdentifier(9) == -1 ), error('Error: unable to open file MIPSI.9'); end
            fprintf(FileIdentifier(9), '%% FILE: MIPSI.9\n%%\n' );
            fprintf(FileIdentifier(9), '%%       t         P_No_RN[1]     P_No_RN[2]     P_No_RN[3]\n' );
            fprintf(FileIdentifier(9), '%%   (second)        (meter)        (meter)        (meter)\n\n' );
            for( i = 1 : tracePointCount )
               fileNumber = i + 9;
               FileIdentifier(fileNumber) = fopen(sprintf('MIPSI.%d', fileNumber), 'wt');   if( FileIdentifier(fileNumber) == -1 ), error('Error: unable to open file MIPSI.%d', fileNumber); end
               fprintf(FileIdentifier(fileNumber), '%% FILE: MIPSI.%d\n%%\n', fileNumber );
               fprintf(FileIdentifier(fileNumber), '%%       t          P_No_P%d[1]    P_No_P%d[2]    P_No_P%d[3]\n', i, i, i );
               fprintf(FileIdentifier(fileNumber), '%%   (second)        (meter)        (meter)        (meter)\n\n' );
            end
         end
         hasHeaderInformationBeenWritten = 1;
      end
      
      if( shouldPrintToScreen ), WriteNumericalData( 1,                 Output(1:10) );  end
      if( shouldPrintToFile ),   WriteNumericalData( FileIdentifier(1), Output(1:10) );  end
      if( shouldPrintToFile ),   WriteNumericalData( FileIdentifier(2), Output(11:23) );  end
      if( shouldPrintToFile ),   WriteNumericalData( FileIdentifier(3), Output(24:36) );  end
      if( shouldPrintToFile ),   WriteNumericalData( FileIdentifier(4), Output(37:49) );  end
      if( shouldPrintToFile ),   WriteNumericalData( FileIdentifier(5), Output(50:62) );  end
      if( shouldPrintToFile ),   WriteNumericalData( FileIdentifier(6), Output(63:75) );  end
      if( shouldPrintToFile ),   WriteNumericalData( FileIdentifier(7), Output(76:79) );  end
      if( shouldPrintToFile ),   WriteNumericalData( FileIdentifier(8), Output(80:83) );  end
      if( shouldPrintToFile ),   WriteNumericalData( FileIdentifier(9), Output(84:87) );  end
      for( i = 1 : tracePointCount )
         outputIndex = 88 + 4*(i-1);
         if( shouldPrintToFile ), WriteNumericalData( FileIdentifier(i+9), Output(outputIndex:outputIndex+3) ); end
      end
   end


%===========================================================================
   function WriteNumericalData( fileIdentifier, Output )
      %===========================================================================
      numberOfOutputQuantities = length( Output );
      if( numberOfOutputQuantities > 0 ),
         for( i = 1 : numberOfOutputQuantities ),
            fprintf( fileIdentifier, ' %- 14.6E', Output(i) );
         end
         fprintf( fileIdentifier, '\n' );
      end
   end



%===========================================================================
   function [functionsToEvaluateForEvent, eventTerminatesIntegration1Otherwise0ToContinue, eventDirection_AscendingIs1_CrossingIs0_DescendingIsNegative1] = EventDetection( t, VAR, uSimulink )
      %===========================================================================
      % Detects when designated functions are zero or cross zero with positive or negative slope.
      % Step 1: Uncomment call to mdlDerivatives and mdlOutputs.
      % Step 2: Change functionsToEvaluateForEvent,                      e.g., change  []  to  [t - 5.67]  to stop at t = 5.67.
      % Step 3: Change eventTerminatesIntegration1Otherwise0ToContinue,  e.g., change  []  to  [1]  to stop integrating.
      % Step 4: Change eventDirection_AscendingIs1_CrossingIs0_DescendingIsNegative1,  e.g., change  []  to  [1].
      % Step 5: Possibly modify function EventDetectedByIntegrator (if eventTerminatesIntegration1Otherwise0ToContinue is 0).
      %---------------------------------------------------------------------------
      % mdlDerivatives( t, VAR, uSimulink );        % UNCOMMENT FOR EVENT HANDLING
      % mdlOutputs(     t, VAR, uSimulink );        % UNCOMMENT FOR EVENT HANDLING
      functionsToEvaluateForEvent = [];
      eventTerminatesIntegration1Otherwise0ToContinue = [];
      eventDirection_AscendingIs1_CrossingIs0_DescendingIsNegative1 = [];
      eventDetectedByIntegratorTerminate1OrContinue0 = eventTerminatesIntegration1Otherwise0ToContinue;
   end


%===========================================================================
   function [isIntegrationFinished, VAR] = EventDetectedByIntegrator( t, VAR, nIndexOfEvents )
      %===========================================================================
      isIntegrationFinished = eventDetectedByIntegratorTerminate1OrContinue0( nIndexOfEvents );
      if( ~isIntegrationFinished ),
         SetNamedQuantitiesFromMatrix( VAR );
         %  Put code here to modify how integration continues.
         VAR = SetMatrixFromNamedQuantities;
      end
   end



%===========================================================================
   function [t,VAR,Output] = IntegrateForwardOrBackward( tInitial, tFinal, tStep, absError, relError, VAR, printIntScreen, printIntFile )
      %===========================================================================
      OdeMatlabOptions = odeset( 'RelTol',relError, 'AbsTol',absError, 'MaxStep',tStep, 'Events',@EventDetection );
      t = tInitial;                 epsilonT = 0.001*tStep;                   tFinalMinusEpsilonT = tFinal - epsilonT;
      printCounterScreen = 0;       integrateForward = tFinal >= tInitial;    tAtEndOfIntegrationStep = t + tStep;
      printCounterFile   = 0;       isIntegrationFinished = 0;
      mdlDerivatives( t, VAR, 0 );
      while 1,
         if( (integrateForward && t >= tFinalMinusEpsilonT) || (~integrateForward && t <= tFinalMinusEpsilonT) ), isIntegrationFinished = 1;  end
         shouldPrintToScreen = printIntScreen && ( isIntegrationFinished || printCounterScreen <= 0.01 );
         shouldPrintToFile   = printIntFile   && ( isIntegrationFinished || printCounterFile   <= 0.01 );
         if( isIntegrationFinished || shouldPrintToScreen || shouldPrintToFile ),
            Output = mdlOutputs( t, VAR, 0 );
            OutputToScreenOrFile( Output, shouldPrintToScreen, shouldPrintToFile );
            if( isIntegrationFinished ), break;  end
            if( shouldPrintToScreen ), printCounterScreen = printIntScreen;  end
            if( shouldPrintToFile ),   printCounterFile   = printIntFile;    end
         end
         [TimeOdeArray, VarOdeArray, timeEventOccurredInIntegrationStep, nStatesArraysAtEvent, nIndexOfEvents] = ode45( @mdlDerivatives, [t tAtEndOfIntegrationStep], VAR, OdeMatlabOptions, 0 );
         if( isempty(timeEventOccurredInIntegrationStep) ),
            lastIndex = length( TimeOdeArray );
            t = TimeOdeArray( lastIndex );
            VAR = VarOdeArray( lastIndex, : );
            printCounterScreen = printCounterScreen - 1;
            printCounterFile   = printCounterFile   - 1;
            if( abs(tAtEndOfIntegrationStep - t) >= abs(epsilonT) ), warning('numerical integration failed'); break;  end
            tAtEndOfIntegrationStep = t + tStep;
            if( (integrateForward && tAtEndOfIntegrationStep > tFinal) || (~integrateForward && tAtEndOfIntegrationStep < tFinal) ) tAtEndOfIntegrationStep = tFinal;  end
         else
            t = timeEventOccurredInIntegrationStep( 1 );    % time  at firstEvent = 1 during this integration step.
            VAR = nStatesArraysAtEvent( 1, : );             % state at firstEvent = 1 during this integration step.
            printCounterScreen = 0;
            printCounterFile   = 0;
            [isIntegrationFinished, VAR] = EventDetectedByIntegrator( t, VAR, nIndexOfEvents(1) );
         end
      end
   end


%==============================
end    % End of function MIPSI
%==============================
