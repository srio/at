function R=ParseAtributesMADX_2_AT(R,elname,var,val)
% determines atribute and sets field in sxs{i} structure AT
%
% created 6-sept-2012

%disp(['checking atribute: ' S8STRING((strfind(S8STRING,'=')+1):end-1)]);

%val=S8STRING((strfind(S8STRING,'=')+1):end);

val0=val;
%S8STRING(1:end)
if ~isempty(val)
    
    val=strrep(val,'=','');
    val=strrep(val,',','');
    val=strrep(val,' ','');
    
    var=strrep(var,'=','');
    var=strrep(var,',','');
    var=strrep(var,' ','');
    
    val=strrep(val,'&','0');
%    val=strrep(val,'E','e');
 %  disp([var '= ' val])
    
    switch var
        case {'l','L'}
            R=[R elname '.(''Length'')=' val '; \n'];
        %disp([var '= ' val])
        case {'angle','ANGLE'}
            R=[R elname '.(''BendingAngle'')=' val '; \n'];
        case {'K1','k1'} % quadrupole
            R=[R elname '.(''PolynomB'')(2)=' val '; \n'];
        case {'K1S',''} % skew quadrupole
            R=[R elname '.(''PolynomA'')(2)=' val '; \n'];
        case {'K2','k2'} % sextupole
            R=[R elname '.(''PolynomB'')(3)=' val '; \n'];
        case {'K3','k3'} % octupole
            R=[R elname '.(''PolynomB'')(4)=' val '; \n'];
        case {'KS','ks'} % solenoid
            % R=[R elname '.(''')=[0 val];
        case {'E1','e1'} % entrance angle
            R=[R elname '.(''EntranceAngle'')=' val '; \n'];
        case {'E2','e2'} %exit angle
            R=[R elname '.(''ExitAngle'')=' val '; \n'];
            % case 'TILT' % tilt
            %R=[R elname '.(''R1'')=' val '; \n'];
            % case 'APERTURE' % max aperture
            %R=[R elname '.('''')=' val '; \n'];
        case {'HGAP','hgap'} % bending magnet gap
            R=[R elname '.(''FullGap'')=' val '; \n'];
            % case 'FINT' %
            % R=[R elname '.(''FringeInt'')=' val '; \n'];
            % case 'FINTX' %
            % R=[R elname '.(''FringeInt'')=' val '; \n'];
        case {'K1L','k1l'} % mulitpole component
            R=[R elname '.(''PolynomB'')(1)=' val '; \n'];
        case {'K2L','k2l'} % mulitpole component
            R=[R elname '.(''PolynomB'')(2)=' val '; \n'];
        case {'K3L','k3l'} % mulitpole component
            R=[R elname '.(''PolynomB'')(3)=' val '; \n'];
        case {'K4L','k4l'} % mulitpole component
            R=[R elname '.(''PolynomB'')(4)=' val '; \n'];
        case {'K5L','k5l'} % mulitpole component
            R=[R elname '.(''PolynomB'')(5)=' val '; \n'];
        case {'K6L','k6l'} % mulitpole component
            R=[R elname '.(''PolynomB'')(6)=' val '; \n'];
        case {'K1SL','k1sl'} % mulitpole component skew
            R=[R elname '.(''PolynomA'')(1)=' val '; \n'];
        case {'K2SL','k2sl'} % mulitpole component skew
            R=[R elname '.(''PolynomA'')(2)=' val '; \n'];
        case {'K3SL','k3sl'} % mulitpole component skew
            R=[R elname '.(''PolynomA'')(3)=' val '; \n'];
        case {'K4SL','k4sl'} % mulitpole component skew
            R=[R elname '.(''PolynomA'')(4)=' val '; \n'];
        case {'K5SL','k5sl'} % mulitpole component skew
            R=[R elname '.(''PolynomA'')(5)=' val '; \n'];
        case {'K6SL','k6sl'} % mulitpole component skew
            R=[R elname '.(''PolynomA'')(6)=' val '; \n'];
        case {'KNL','knl'} % mulitpole component skew
            R=[R elname '.(''PolynomB'')=' val0 '; \n'];
        case {'KSL','ksl'} % mulitpole component skew
            R=[R elname '.(''PolynomA'')=' val0 '; \n'];
        case {'VOLT','volt'} %
            R=[R elname '.(''Voltage'')=abs(' val ')*1e6; %% convert to MV \n'];
        case {'FREQ','freq'} %
            R=[R elname '.(''Frequency'')=' val '*1e6; %% convert to MHz  \n'];
        case {'HARMON','harmon'} %
            R=[R elname '.(''HarmNumber'')=' val '; \n'];
            %     case '' %
            %          R=[R elname '.(''')=S8STRING;
            %     case '' %
            %          R=[R elname '.(''')=S8STRING;
        otherwise
            % disp([newel ' : unrecognized element attribute']);
    end
end

%R=[R '\n'];
    
