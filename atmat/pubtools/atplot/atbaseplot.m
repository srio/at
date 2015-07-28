function curve = atbaseplot(varargin)
%ATBASEPLOT Plots data generated by a user-supplied function
%
%ATBASEPLOT             Plots THERING in the current axes
%
%ATBASEPLOT(RING)       Plots the lattice specified by RING
%
%ATBASEPLOT(RING,DPP)   Plots at momentum deviation DPP (default: 0)
%
%ATBASEPLOT(...,[SMIN SMAX])  Zoom on the specified range
%
%ATBASEPLOT(...,@PLOTFUNCTION,PLOTARGS)
%   PLOTFUNCTION: User supplied function providing the values to be plotted
%   PLOTARGS:     Optional cell array of arguments to PLOTFUNCTION
%   PLOTFUNCTION is called as: 
%   [S,PLOTDATA]=PLOTFUNCTION(RING,DPP,PLOTARGS{:})
%
%       S:        longitudinal position, length(ring)+1 x 1
%       PLOTDATA: structure array,
%         PLOTDATA(1) describes data for the left (main) axis
%           PLOTDATA(1).VALUES: data to be plotted, length(ring)+1 x nbcurve
%           PLOTDATA(1).LABELS: curve labels, cell array, 1 x nbcurve
%           PLOTDATA(1).AXISLABEL: string
%         PLOTDATA(2) optional, describes data for the right (secondary) axis
%
%ATBASEPLOT(...,'OptionName',OptionValue,...) Available options:
%   'synopt',true|false         Plots the lattice elements
%   'labels',REFPTS             Display the names of selected element names
%   'leftargs',{properties}     properties set on the left axis
%   'rightargs',{properties}    properties set on the right axis
%
%ATBASEPLOT(AX,...)     Plots in the axes specified by AX. AX can precede
%                       any previous argument combination
%
%CURVE=ATBASEPLOT(...)  Returns handles to some objects:
%   CURVE.PERIODICIY ring periodicity
%   CURVE.LENGTH    structure length
%   CURVE.DPP       deltap/p
%   CURVE.LEFT      Handles to the left axis plots
%   CURVE.RIGHT     Handles to the right axis plots
%   CURVE.LATTICE   Handles to the Element patches: structure with fields
%          Dipole,Quadrupole,Sextupole,Multipole,BPM,Label
%

global THERING

npts=400;
narg=1;
% Select axes for the plot
if narg<=length(varargin) && isscalar(varargin{narg}) && ishandle(varargin{narg});
    ax=varargin{narg};
    narg=narg+1;
else
    ax=gca;
end
% Select the lattice
if narg<=length(varargin) && iscell(varargin{narg});
    [elt0,curve.periodicity,ring0]=get1cell(varargin{narg});
    narg=narg+1;
else
    [elt0,curve.periodicity,ring0]=get1cell(THERING);
end
s0=findspos(ring0,1:elt0+1);
curve.length=s0(end);
% Select the momentum deviation
if narg<=length(varargin) && isscalar(varargin{narg}) && isnumeric(varargin{narg});
    curve.dpp=varargin{narg};
    narg=narg+1;
else
    curve.dpp=0;
end
% Select the plotting range
if narg<=length(varargin) && isnumeric(varargin{narg}) && (numel(varargin{narg})==2)
    srange=varargin{narg};
    els=find(srange(1)>s0,1,'last');
    if ~isempty(els), el1=els; end
    els=find(s0>srange(2),1,'first');
    if ~isempty(els), el2=els; end
    narg=narg+1;
else
    srange=[0 curve.length];
    el1=1;
    el2=elt0+1;
end
% select the plotting function
plotargs={};
if narg<=length(varargin) && isa(varargin{narg},'function_handle')
    plotfun=varargin{narg};
    narg=narg+1;
    if narg<=length(varargin) && iscell(varargin{narg})
        plotargs=varargin{narg};
        narg=narg+1;
    end
else
    plotfun=@defaultplot;
end

rsrc=varargin(narg:end);
[synopt,rsrc]=getoption(rsrc,'synopt',true);
[leftargs,rsrc]=getoption(rsrc,'leftargs',{});
[rightargs,rsrc]=getoption(rsrc,'rightargs',{});
elmlength=findspos(ring0(el1:el2-1),el2-el1+1)/npts;
r2=cellfun(@splitelem,ring0(el1:el2-1),'UniformOutput',false);
ring=cat(1,ring0(1:el1-1),r2{:},ring0(el2:elt0));
elt=length(ring);
plrange=el1:el2+elt-elt0;

[s,outp]=plotfun(ring,curve.dpp,plotargs{:});
if numel(outp) >= 2
    [ax2,curve.left,curve.right]=plotyy(ax,...
        s(plrange),outp(1).values(plrange,:),...
        s(plrange),outp(2).values(plrange,:));
    set(ax2(1),leftargs{:},'FontSize',12);
    set(ax2(2),rightargs{:},'XTick',[],'FontSize',12);
    ylabel(ax2(1),outp(1).axislabel);
    ylabel(ax2(2),outp(2).axislabel);
    linkaxes([ax2(1) ax2(2)],'x');% allows zoom on both right and left plots
elseif numel(outp) == 1
    curve.left=plot(ax,s(plrange),outp(1).values(plrange,:));
    curve.right=[];
    ax2=ax;
    set(ax2(1),leftargs{:},'FontSize',12);
    ylabel(ax2(1),outp(1).axislabel);
else
    curve.left=[];
    curve.right=[];
    ax2=ax;
    set(ax2(1),leftargs{:},'YLim',[0 1],'FontSize',12);
end
set(ax2,'XLim',srange);
xlabel(ax2(1),'s [m]');
if synopt
    [curve.lattice]=atplotsyn(ax2(1),ring0,rsrc{:});  % Plot lattice elements
    lts=get(ax2(1),'Children');                 % Put them in the background
    nsy=length(lts)-length(curve.left);
    set(ax2(1),'Children',lts([nsy+1:end 1:nsy]));
end
lines=[curve.left;curve.right];
if ~isempty(lines)
    set(lines,'LineWidth',1);
    legend(lines,[outp.labels],'FontSize',12);
end
grid on

    function newelems=splitelem(elem)
        if isfield(elem,'Length') && elem.Length > 0
            nslices=ceil(elem.Length/elmlength);
            newelems=atdivelem(elem,ones(1,nslices)./nslices);
        else
            newelems={elem};
        end
    end

    function [cellsize,np,cell]=get1cell(ring)
        [cellsize,np]=size(ring);
        cell=ring(:,1);
        params=atgetcells(cell,'Class','RingParam');
        if any(params)
            np=ring{find(params,1)}.Periodicity;
        end
    end
end

function [s,plotdata]=defaultplot(ring,dpp,varargin) %#ok<INUSD>
%DEFAULTPLOT    Default plotting function for ATBASEPLOT
%Plots nothing

s=[];
plotdata=[];
end
