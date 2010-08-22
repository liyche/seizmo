function [mout]=iasp91(varargin)
%IASP91    Returns the IASP91 Earth Model
%
%    Usage:    model=iasp91
%              model=iasp91(...,'depths',depths,...)
%              model=iasp91(...,'dcbelow',false,...)
%              model=iasp91(...,'range',[top bottom],...)
%              model=iasp91(...,'crust',true|false,...)
%
%    Description: MODEL=IASP91 returns a struct containing the 1D radial
%     Earth model IASP91.  The struct has the following fields:
%      MODEL.name      - model name ('IASP91')
%           .ocean     - always false here
%           .crust     - true/false
%           .isotropic - always true here
%           .refperiod - always 1sec here
%           .flattened - always false here (see FLATTEN_1DMODEL)
%           .depth     - km depths from 0 to 6371
%           .vp        - isotropic p-wave velocity (km/s)
%           .vs        - isotropic s-wave velocity (km/s)
%           .rho       - density (g/cm^3)
%     Note that the model includes repeated depths at discontinuities.
%
%     MODEL=IASP91(...,'DEPTHS',DEPTHS,...) returns the model parameters
%     only at the depths in DEPTHS.  DEPTHS is assumed to be in km.  The
%     model parameters are found by linear interpolation between known
%     values.  DEPTHS at discontinuities return values from the deeper side
%     of the discontinuity.
%
%     MODEL=IASP91(...,'DCBELOW',FALSE,...) returns values from the shallow
%     (top) side of the discontinuity if a depth is specified at one using
%     the DEPTHS option.
%
%     MODEL=IASP91(...,'RANGE',[TOP BOTTOM],...) specifies the range of
%     depths that known model parameters are returned.  [TOP BOTTOM] must
%     be a 2 element array in km.  Note this does not block depths given by
%     the DEPTHS option.
%
%     MODEL=IASP91(...,'CRUST',TRUE|FALSE,...) indicates if the crust of
%     IASP91 is to be removed or not.  Setting CRUST to FALSE will return a
%     crustless model (the mantle is extended to the surface using linear
%     interpolation).
%
%    Notes:
%     - IASP91 reference:
%        Kennett & Engdahl 1991, Traveltimes for global earthquake location
%        and phase identification, Geophys. J. Int. 105, pp. 429-465
%
%    Examples:
%     Plot parameters for the CMB region:
%      model=iasp91('r',[2600 3400]);
%      figure;
%      plot(model.depth,model.vp,'r',...
%           model.depth,model.vs,'g',...
%           model.depth,model.rho,'b','linewidth',2);
%      title('IASP91')
%      legend({'Vp' 'Vs' '\rho'})
%
%    See also: AK135, PREM

%     Version History:
%        May  19, 2010 - initial version
%        May  20, 2010 - discon on edge handling, quicker
%        May  24, 2010 - added several struct fields for info
%        Aug.  8, 2010 - minor doc touch, dcbelow option
%        Aug. 17, 2010 - added reference
%
%     Written by Garrett Euler (ggeuler at wustl dot edu)
%     Last Updated Aug. 17, 2010 at 14:45 GMT

% todo:

% check nargin
if(mod(nargin,2))
    error('seizmo:iasp91:badNumInputs',...
        'Unpaired Option/Value!');
end

% option defaults
varargin=[{'d' [] 'b' true 'c' true 'r' [0 6371]} varargin];

% check options
if(~iscellstr(varargin(1:2:end)))
    error('seizmo:iasp91:badOption',...
        'All Options must be specified with a string!');
end
for i=1:2:numel(varargin)
    % skip empty
    skip=false;
    if(isempty(varargin{i+1})); skip=true; end

    % check option is available
    switch lower(varargin{i})
        case {'d' 'dep' 'depth' 'depths'}
            if(~isempty(varargin{i+1}) && (~isreal(varargin{i+1}) ...
                    || any(varargin{i+1}<0 | varargin{i+1}>6371)))
                error('seizmo:iasp91:badDEPTHS',...
                    ['DEPTHS must be real-valued km depths within ' ...
                    'the range [0 6371] in km!']);
            end
            depths=varargin{i+1}(:);
        case {'dcb' 'dc' 'below' 'b' 'dcbelow'}
            if(skip); continue; end
            if(~islogical(varargin{i+1}) || ~isscalar(varargin{i+1}))
                error('seizmo:iasp91:badDCBELOW',...
                    'DCBELOW must be a TRUE or FALSE!');
            end
            dcbelow=varargin{i+1};
        case {'c' 'cru' 'crust'}
            if(skip); continue; end
            if(~islogical(varargin{i+1}) || ~isscalar(varargin{i+1}))
                error('seizmo:iasp91:badCRUST',...
                    'CRUST must be a TRUE or FALSE!');
            end
            crust=varargin{i+1};
        case {'r' 'rng' 'range'}
            if(skip); continue; end
            if(~isreal(varargin{i+1}) || numel(varargin{i+1})~=2)
                error('seizmo:iasp91:badRANGE',...
                    ['RANGE must be a 2 element vector specifying ' ...
                    '[TOP BOTTOM] in km!']);
            end
            range=sort(varargin{i+1});
        otherwise
            error('seizmo:iasp91:badOption',...
                'Unknown Option: %s',varargin{i});
    end
end

% the iasp91 model
model=[
     0.000    5.8000    3.3600    2.7200
    20.000    5.8000    3.3600    2.7200
    20.000    6.5000    3.7500    2.9200
    35.000    6.5000    3.7500    2.9200
    35.000    8.0400    4.4700    3.3198
    77.500    8.0450    4.4850    3.3455
   120.000    8.0500    4.5000    3.3713
   165.000    8.1750    4.5090    3.3985
   210.000    8.3000    4.5180    3.4258
   210.000    8.3000    4.5220    3.4258
   260.000    8.4825    4.6090    3.4561
   310.000    8.6650    4.6960    3.4864
   360.000    8.8475    4.7830    3.5167
   410.000    9.0300    4.8700    3.5470
   410.000    9.3600    5.0700    3.7557
   460.000    9.5280    5.1760    3.8175
   510.000    9.6960    5.2820    3.8793
   560.000    9.8640    5.3880    3.9410
   610.000   10.0320    5.4940    4.0028
   660.000   10.2000    5.6000    4.0646
   660.000   10.7900    5.9500    4.3714
   710.000   10.9229    6.0797    4.4010
   760.000   11.0558    6.2095    4.4305
   809.500   11.1440    6.2474    4.4596
   859.000   11.2300    6.2841    4.4885
   908.500   11.3140    6.3199    4.5173
   958.000   11.3960    6.3546    4.5459
  1007.500   11.4761    6.3883    4.5744
  1057.000   11.5543    6.4211    4.6028
  1106.500   11.6308    6.4530    4.6310
  1156.000   11.7056    6.4841    4.6591
  1205.500   11.7787    6.5143    4.6870
  1255.000   11.8504    6.5438    4.7148
  1304.500   11.9205    6.5725    4.7424
  1354.000   11.9893    6.6006    4.7699
  1403.500   12.0568    6.6280    4.7973
  1453.000   12.1231    6.6547    4.8245
  1502.500   12.1881    6.6809    4.8515
  1552.000   12.2521    6.7066    4.8785
  1601.500   12.3151    6.7317    4.9052
  1651.000   12.3772    6.7564    4.9319
  1700.500   12.4383    6.7807    4.9584
  1750.000   12.4987    6.8046    4.9847
  1799.500   12.5584    6.8282    5.0109
  1849.000   12.6174    6.8514    5.0370
  1898.500   12.6759    6.8745    5.0629
  1948.000   12.7339    6.8972    5.0887
  1997.500   12.7915    6.9199    5.1143
  2047.000   12.8487    6.9423    5.1398
  2096.500   12.9057    6.9647    5.1652
  2146.000   12.9625    6.9870    5.1904
  2195.500   13.0192    7.0093    5.2154
  2245.000   13.0758    7.0316    5.2403
  2294.500   13.1325    7.0540    5.2651
  2344.000   13.1892    7.0765    5.2898
  2393.500   13.2462    7.0991    5.3142
  2443.000   13.3034    7.1218    5.3386
  2492.500   13.3610    7.1449    5.3628
  2542.000   13.4190    7.1681    5.3869
  2591.500   13.4774    7.1917    5.4108
  2641.000   13.5364    7.2156    5.4345
  2690.500   13.5961    7.2398    5.4582
  2740.000   13.6564    7.2645    5.4817
  2740.000   13.6564    7.2645    5.4817
  2789.670   13.6679    7.2768    5.5051
  2839.330   13.6793    7.2892    5.5284
  2889.000   13.6908    7.3015    5.5515
  2889.000    8.0088    0.0000    9.9145
  2939.330    8.0963    0.0000    9.9942
  2989.660    8.1821    0.0000   10.0722
  3039.990    8.2662    0.0000   10.1485
  3090.320    8.3486    0.0000   10.2233
  3140.660    8.4293    0.0000   10.2964
  3190.990    8.5083    0.0000   10.3679
  3241.320    8.5856    0.0000   10.4378
  3291.650    8.6611    0.0000   10.5062
  3341.980    8.7350    0.0000   10.5731
  3392.310    8.8072    0.0000   10.6385
  3442.640    8.8776    0.0000   10.7023
  3492.970    8.9464    0.0000   10.7647
  3543.300    9.0134    0.0000   10.8257
  3593.640    9.0787    0.0000   10.8852
  3643.970    9.1424    0.0000   10.9434
  3694.300    9.2043    0.0000   11.0001
  3744.630    9.2645    0.0000   11.0555
  3794.960    9.3230    0.0000   11.1095
  3845.290    9.3798    0.0000   11.1623
  3895.620    9.4349    0.0000   11.2137
  3945.950    9.4883    0.0000   11.2639
  3996.280    9.5400    0.0000   11.3127
  4046.620    9.5900    0.0000   11.3604
  4096.950    9.6383    0.0000   11.4069
  4147.280    9.6848    0.0000   11.4521
  4197.610    9.7297    0.0000   11.4962
  4247.940    9.7728    0.0000   11.5391
  4298.270    9.8143    0.0000   11.5809
  4348.600    9.8540    0.0000   11.6216
  4398.930    9.8920    0.0000   11.6612
  4449.260    9.9284    0.0000   11.6998
  4499.600    9.9630    0.0000   11.7373
  4549.930    9.9959    0.0000   11.7737
  4600.260   10.0271    0.0000   11.8092
  4650.590   10.0566    0.0000   11.8437
  4700.920   10.0844    0.0000   11.8772
  4751.250   10.1105    0.0000   11.9098
  4801.580   10.1349    0.0000   11.9414
  4851.910   10.1576    0.0000   11.9722
  4902.240   10.1785    0.0000   12.0021
  4952.580   10.1978    0.0000   12.0311
  5002.910   10.2154    0.0000   12.0593
  5053.240   10.2312    0.0000   12.0867
  5103.570   10.2454    0.0000   12.1133
  5153.900   10.2578    0.0000   12.1391
  5153.900   11.0914    3.4385   12.7037
  5204.610   11.1036    3.4488   12.7289
  5255.320   11.1153    3.4587   12.7530
  5306.040   11.1265    3.4681   12.7760
  5356.750   11.1371    3.4770   12.7980
  5407.460   11.1472    3.4856   12.8188
  5458.170   11.1568    3.4937   12.8387
  5508.890   11.1659    3.5013   12.8574
  5559.600   11.1745    3.5085   12.8751
  5610.310   11.1825    3.5153   12.8917
  5661.020   11.1901    3.5217   12.9072
  5711.740   11.1971    3.5276   12.9217
  5762.450   11.2036    3.5330   12.9351
  5813.160   11.2095    3.5381   12.9474
  5863.870   11.2150    3.5427   12.9586
  5914.590   11.2199    3.5468   12.9688
  5965.300   11.2243    3.5505   12.9779
  6016.010   11.2282    3.5538   12.9859
  6066.720   11.2316    3.5567   12.9929
  6117.440   11.2345    3.5591   12.9988
  6168.150   11.2368    3.5610   13.0036
  6218.860   11.2386    3.5626   13.0074
  6269.570   11.2399    3.5637   13.0100
  6320.290   11.2407    3.5643   13.0117
  6371.000   11.2409    3.5645   13.0122];

% remove crust if desired
if(~crust)
    % linear extrapolation to the surface
    model(1,:)=[0 8.0359 4.4576 3.2986];
    model(2:4,:)=[];
end

% interpolate depths if desired
if(~isempty(depths))
    %depths=depths(depths>=range(1) & depths<=range(2));
    if(dcbelow)
        model=interpdc1(model(:,1),model(:,2:end),depths);
    else
        [model,model]=interpdc1(model(:,1),model(:,2:end),depths);
    end
    model=[depths model];
else
    % get index range (assumes depths are always non-decreasing in model)
    idx1=find(model(:,1)>range(1),1);
    idx2=find(model(:,1)<range(2),1,'last');
    
    % are range points amongst the knots?
    tf=ismember(range,model(:,1));
    
    % if they are, just use the knot, otherwise interpolate
    if(tf(1))
        idx1=idx1-1;
    else
        vtop=interp1q(model(idx1-1:idx1,1),model(idx1-1:idx1,2:end),range(1));
    end
    if(tf(2))
        idx2=idx2+1;
    else
        vbot=interp1q(model(idx2:idx2+1,1),model(idx2:idx2+1,2:end),range(2));
    end
    
    % clip model
    model=model(idx1:idx2,:);
    
    % pad range knots if not there
    if(~tf(1)); model=[range(1) vtop; model]; end
    if(~tf(2)); model=[model; range(2) vbot]; end
end

% array to struct
mout.name='IASP91';
mout.ocean=false;
mout.crust=crust;
mout.isotropic=true;
mout.refperiod=1;
mout.flattened=false;
mout.depth=model(:,1);
mout.vp=model(:,2);
mout.vs=model(:,3);
mout.rho=model(:,4);

end