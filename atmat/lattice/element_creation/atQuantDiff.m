function elem=atQuantDiff(fname,varargin)
%atQuantDiff creates a quantum diffusion element
%
%ELEM=ATQUANTDIFF(FAMNAME,DIFFMAT) uses the given diffusion matrix
%   FAMNAME:   family name
%   DIFFMAT:   Diffusion matrix
%
%ELEM=ATQUANTDIFF(FAMNANE,RING) computes the diffusion matrix of the ring
%   FAMNAME:   family name
%   RING:      lattice without radiation
%
%  The optional field Seed can be added. In that case, the seed of the
%  random number generator is set at the first turn.
%  ELEM=ATQUANTDIFF(FAMNANE,RING,'Seed',4)
%
%See also quantumDiff

[rsrc,arg,method]=decodeatargs({[],'QuantDiffPass'},varargin);
[method,rsrc]=getoption(rsrc,'PassMethod',method);
[cl,rsrc]=getoption(rsrc,'Class','QuantDiff');
if iscell(arg)
    [ring2,radindex]=atradon(arg);
    dmat=quantumDiff(ring2,radindex);
else
    dmat=arg;
end
elem=atbaselem(fname,method,'Class',cl,'Lmatp',lmatp(dmat),rsrc{:});

    function lmatp = lmatp(dmat)
        %lmat does Cholesky decomp of dmat unless diffusion is 0 in
        %vertical.  Then do chol on 4x4 hor-long matrix and put 0's
        %in vertical
        try
            lmat66 = chol(dmat);
        catch
            lm=[chol(dmat([1 2 5 6],[1 2 5 6])) zeros(4,2);zeros(2,6)];
            lmat66=lm([1 2 5 6 3 4],[1 2 5 6 3 4]);
        end
        lmatp=lmat66';
    end
end
