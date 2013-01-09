function newring=atfittune(ring,newtunes,famname1,famname2,varargin)
%ATFITTUNE fits linear tunes by scaling 2 quadrupole families
% NEWRING = ATFITTUNE(RING,NEWTUNES,QUADFAMILY1,QUADFAMILY2)
%
%RING:          Cell array
%NEWTUNES:      Desired tune values (fractional part only)
%QUADFAMILY1:   1st quadrupole family
%QUADFAMILY2:   2nd quadrupole family
%
%QUADFAMILY may be:
%   string: Family name
%   logical array: mask of selected elements in RING
%   Numeric array: list of selected elements in RING
%   Cell array: All elements selected by each cell

idx1=varelem(ring,famname1);
idx2=varelem(ring,famname2);
newtunes=newtunes-floor(newtunes);

kl1=atgetfieldvalues(ring,idx1,'PolynomB',{2});
kl2=atgetfieldvalues(ring,idx2,'PolynomB',{2});
if true
    delta = 1e-6;

    % Compute initial tunes before fitting
    [lindata, tunes] = atlinopt(ring,0);

    % Take Derivative
    [lindata, tunes1] = atlinopt(setqp(ring,idx1,kl1,delta),0);
    [lindata, tunes2] = atlinopt(setqp(ring,idx2,kl2,delta),0);

    %Construct the Jacobian
    J = ([tunes1(:) tunes2(:)] - [tunes(:) tunes(:)])/delta;
    dK = J\(newtunes(:)-tunes(:));
else
    dK=0.01*fminsearch(@funtune,[0;0],...
        optimset(optimset('fminsearch'),'Display','iter','TolX',1.e-5));
end
newring = setqp(ring,idx1,kl1,dK(1));
newring = setqp(newring,idx2,kl2,dK(2));

    function c=funtune(dK)
        ring2 = setqp(ring ,idx1,kl1,0.01*dK(1));
        ring2 = setqp(ring2,idx2,kl2,0.01*dK(2));
        [lindata,tunes]=atlinopt(ring2,0); %#ok<SETNU>
        dt=abs(newtunes(:)-tunes(:));
        c=sum(dt.*dt);
    end

    function ring2=setqp(ring,idx,k0,delta)
        k=k0*(1+delta);
        ring2=atsetfieldvalues(ring,idx,'K',k);
        ring2=atsetfieldvalues(ring2,idx,'PolynomB',{2},k);
    end

    function res=varelem(ring,arg)
        if islogical(arg)
            res=arg;
        elseif isnumeric(arg)
            res=false(size(ring));
            res(arg)=true;
        elseif ischar(arg)
            res=atgetcells(ring,'FamName',arg);
        elseif iscell(arg)
            res=false(size(ring));
            for i=1:length(arg)
                res=res|varelem(ring,arg{i});
            end
        else
            error('AT:GetElemList:WrongArg','Cannot parse argument');
        end
    end
end
