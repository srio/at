function ok=atgetcells(cellarray, field, varargin)
%ATGETCELLS performs a search on MATLAB cell arrays of structures
%
% OK = ATGETCELLS(RING, 'field')
%   returns indexes of elements that have a field named 'field'
%
% OK = ATGETCELLS(RING, 'field', VALUE1...)
%   returns indexes of elements whose field 'field'
%   is equal to VALUE1, VALUE2, ... or VALUEN. Where VALUE can either be
%   character strings or a number. If its a character string REGULAR
%   expressions can be used.
%
% OK = ATGETCELLS(RING, 'field', @TESTFUNCTION, ARGS...)
%   Uses the user-defined TESTFUNCTION to select array elements
%   TESTFUNCTION must be of the form:
%       OK=TESTFUNTION(ATELEM,FIELDVALUE,ARGS...)
%
% OK is a logical array with the same size as RING, refering to matching
% elements in RING
%
% See also ATGETFIELDVALUES, ATSETFIELDVALUES, FINDCELLS, REGEXPI

% Check if the first argument is the cell array of structures
if ~iscell(cellarray)
    error('The first argument must be a cell array of structures')
end
% Check if the second argument is a string
if(~ischar(field))
    error('The second argument must be a character string')
end

if nargin<3
    tesfunc=@(elem,field) true;
    vals={};
elseif isa(varargin{1},'function_handle')
    tesfunc=varargin{1};
    vals=varargin(2:end);
else
    tesfunc=@defaultfunc;
    vals=varargin;
end

ok=cellfun(@(elem) isfield(elem,field) && tesfunc(elem,elem.(field),vals{:}), cellarray);

    function ok=defaultfunc(el,fieldval,varargin) %#ok<INUSL>
        ok=false;
        if ischar(fieldval)
            %ok=any(cellfun(@charcompare,varargin))
            for j=1:length(varargin)
                if ischar(varargin{j}) && ~isempty(regexpi(fieldval,['^' varargin{j} '$']))
                    ok=true;
                    break;
                end
            end
        elseif isnumeric(fieldval)
            %ok=any(cellfun(@numcompare,varargin))
            for j=1:length(varargin)
                if isnumeric(varargin{j}) && fieldval==varargin{j}
                    ok=true;
                    break;
                end
            end
        end
%         function ok=charcompare(val)
%             ok=ischar(val) && ~isempty(regexpi(fieldval,['^' val '$']));
%         end
%         function ok=numcompare(val)
%             ok=isnumeric(val) && fieldval==val;
%         end
    end

end
