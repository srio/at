function [NewRing,penalty,dmin]=atmatch(...
    Ring,Variables,Constraints,Tolerance,Calls,algo,verbose)
% this functions modifies the Variables (parameters in THERING) to obtain
% a new THERING with the Constraints verified
%
% Variables   : a cell array of structures of parameters to vary with step size.
% Constraints : a cell array of structures
%
%
%
% Variables  struct('Indx',{[indx],...
%                           @(ring,varval)fun(ring,varval,...),...
%                          },...
%                   'Parameter',{{'paramname',{M,N,...},...},...
%                                [initialvarval],...
%                               },...
%                   'LowLim',{[val],[val],...},...
%                   'HighLim',{[val],[val],...},...
%                   )
%
%
% Constraints: structure array struct(...
%                     'Fun',@functname(ring,lindata,globaldata),
%                     'Min',min,
%                     'Max',max,
%                     'Weight',w,
%                     'RefPoints',refpts);
%
% lindata is the output of atlinopt at the requested locations
% globdata.fractune=tune fromk atlinopt
% globdata.chromaticity=chrom from atlinopt
%
% functname must return a row vector of values to be optimized
%
% min, max and weight must have the same size as the return value of
% functname
%
% verbose to print out results.
%                               0 (no output)
%                               1 (initial values)
%                               2 (iterations)
%                               3 (result)
%
% Variables are changed within the range min<res<max with a Tolerance Given
% by Tolerance
%
% using least square.
%
%

% History of changes
% created : 27-8-2012
% updated : 28-8-2012 constraints 'Fun' may output vectors
% updated : 17-9-2012 output dmin
% updated : 6-11-2012 added simulated annealing (annealing)
%                     and simplex-simulated-annealing (simpsa)
%                     for global minimum search.
% updated : 21-02-2013 TipicalX included in
% updated : 11-03-2013  (major)
%                   function named 'atmatch'.
%                   anonimous functions constraints and variable
%                   Variable limits in variable.
% update : 23-03-2013
%                   atGetVaraiblesNumber added.
%                   fixed Low High lim bug.
%                   fixed function variables treat input values as
%                                  independent parameters to match.
%                   introduced verbose flag.
% updated 25-3-2013 varibles as absolute values and not variations.
%                   Indx and Parmaeter switched in case of function.
%                   setfield(...Parameter{:}) instead of Parameter{1} or{2}
%                   reshaped initialization of tipx for lsqnonlin
%                   atlinopt call optimized in the constraint evaluation call
%                   changed constraint structure

%%
IniVals=atGetVariableValue(Ring,Variables);
splitvar=@(varvec) reshape(mat2cell(varvec,cellfun(@length,IniVals),1),size(Variables));

initval=cat(1,IniVals{:});
Blow=cat(1,Variables.LowLim);
Bhigh=cat(1,Variables.HighLim);

% tolfun is the precisin of the minimum value tolx the accuracy of the
% parameters (delta_0)
% tipicalx is the value of tipical change of a variable
% (useful if varibles have different ranges)
tipx=ones(size(initval));
notzero=initval~=0;
tipx(notzero)=initval(notzero);

[posarray,~,ic]=unique(cat(2,Constraints.RefPoints));
indinposarray=reshape(...
    mat2cell(ic(:),arrayfun(@(s) length(s.RefPoints), Constraints),1),...
    size(Constraints));
evalfunc={Constraints.Fun};

switch algo
    case 'lsqnonlin'
        if verbose>1
            display('verbose display iterations')
            
            options = optimset(...
                'Display','iter',...%
                'MaxFunEvals',Calls*100,...
                'MaxIter',Calls,...
                'TypicalX',tipx,...
                'TolFun',Tolerance,...
                'TolX',Tolerance);
        else
            options = optimset(...
                'MaxFunEvals',Calls*100,...
                'MaxIter',Calls,...
                'TypicalX',tipx,...
                'TolFun',Tolerance,...
                'TolX',Tolerance);
        end
        % Difference between Target constraints and actual value.
        f = @(d) evalvector(Ring,Variables,Constraints,splitvar(d),...
            evalfunc,posarray,indinposarray); % vector
    case {'fminsearch','annealing'}
        if verbose>1
            options = optimset(...
                'Display','iter',...%
                'MaxFunEvals',Calls*100,...
                'MaxIter',Calls,...
                'TolFun',Tolerance,...
                'TolX',Tolerance);
        else
            options = optimset(...
                'MaxFunEvals',Calls*100,...
                'MaxIter',Calls,...
                'TolFun',Tolerance,...
                'TolX',Tolerance);
        end
        
        f = @(d)evalsum(Ring,Variables,Constraints,...
            splitvar(d),evalfunc,posarray,indinposarray); % scalar (sum of squares of f)
end

cstr1=atEvaluateConstraints(Ring,evalfunc,posarray,indinposarray);
penalty0=atGetPenalty(cstr1,Constraints);

if verbose>0
    
    disp('f2: ');
    disp(num2str(penalty0.^2));
    disp('Sum of f2: ');
    disp(num2str(sum(penalty0.^2)));
    
end

%% Least Squares
if sum(penalty0)>Tolerance
    % minimize sum(f_2)
    switch algo
        case 'lsqnonlin'
            
            dmin=lsqnonlin(f,initval,Blow,Bhigh,options);
            % dmin=lsqnonlin(f,delta_0,[],[],options);
            
        case 'fminsearch'
            %options = optimset('OutputFcn', @stopFminsearchAtTOL);
            dmin = fminsearch(f,initval,options); % wants  a scalar
            
    end
else
    dmin=initval;
end
%%

NewRing=atApplyVariation(Ring,Variables,splitvar(dmin));

cstr2=atEvaluateConstraints(NewRing,evalfunc,posarray,indinposarray);
penalty=atGetPenalty(cstr2,Constraints);

if verbose>1
    
    disp('-----oooooo----oooooo----oooooo----')
    disp('   ')
    disp('f²: ');
    disp(num2str(penalty.^2));
    disp('Sum of f²: ');
    disp(num2str(sum(penalty.^2)));
    disp('   ')
    disp('-----oooooo----oooooo----oooooo----')
    
end
if verbose>2
    splitpen=@(pen) reshape(mat2cell(pen,1,cellfun(@length,cstr1)),size(Constraints));
    results=struct(...
        'val1',cstr1,...
        'val2',cstr2,...
        'penalty1',splitpen(penalty0),...
        'penalty2',splitpen(penalty));
    atDisplayConstraintsChange(Constraints,results);
    atDisplayVariableChange(Ring,NewRing,Variables);
end

    function Val=evalvector(R,v,c,d,e,posarray,indinposarray)
        R=atApplyVariation(R,v,d);
        cstr=atEvaluateConstraints(R,e,posarray,indinposarray);
        Val=atGetPenalty(cstr,c);
    end

    function sVal=evalsum(R,v,c,d,e,posarray,indinposarray)
        Val=evalvector(R,v,c,d,e,posarray,indinposarray);
        sVal=sum(Val.^2);
    end

end
