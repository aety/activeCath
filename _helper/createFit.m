function [fitresult, gof] = createFit(pdt1, pdt2, rsp_o)
%CREATEFIT(PDT1,PDT2,RSP_O)
%  Create a fit.
%
%  Data for 'pdt1' fit:
%      X Input : pdt1
%      Y Input : pdt2
%      Z Output: rsp_o
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 05-Mar-2019 16:49:36


%% Fit: 'pdt1'.
[xData, yData, zData] = prepareSurfaceData( pdt1, pdt2, rsp_o );

% Set up fittype and options.
ft = 'linearinterp';

% Fit model to data.
[fitresult, gof] = fit( [xData, yData], zData, ft, 'Normalize', 'on' );

% Plot fit with data.
% figure( 'Name', 'pdt1' );
% h = plot( fitresult, [xData, yData], zData );
% legend( h, 'pdt1', 'rsp_o_1 vs. pdt1, pdt2', 'Location', 'NorthEast' );
% % Label axes
% xlabel pdt1
% ylabel pdt2
% zlabel rsp_o
% grid on


