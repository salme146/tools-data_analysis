function [tm, pm, um, vm, wm, bum, bvm, lat_rho, lon_rho, Zsens, hb] = get_station_data(gres, stanum, t0, tavg);
%%function [tm, pm, um, vm, wm, bum, bvm, lat_rho, lon_rho, Zsens, hb] = get_station_data(gres, stanum, t0, tavg);
%
%	inputs:		gres		= grid resolution in m (e.g., 10, 30)
%			stanum		= station number: 1] LB V  2] GB 1200  3] GB Sontek  4] Apro 1  5] GB 1200  6] Apro 2  7] Apro 3  8] Apro 4  ');
%			t0		= shift start time for model data (in fraction julian days)
%			tavg		= averaging time in minutes (OPTIONAL, default = 0, no averaging)
%
%	outputs:	tm		= model time vector shifted bt t0, in julian days
%			pm 		= sea surface elevation relative to MSL (m)
%			um, vm		= horiz. currents at each s_rho-level (m/s)
%			wm		= verti. currents at each s_w-level (m/s) (one more level than s_rho)
%			bum, bvm	= bottom stresses in u and v directions (N/m^2)
%			lat_rho		= latitude at rho points (deg)
%			lon_rho		= longitude at rho points (deg)
%			Zsens		= s-elevation relative to MSL of sensors (m) changing with each data point
%			hb		= bottom depth (m)

if (0),
	gres = input('what grid resolution?   (e.g., 10, 30, etc.)  ');
	stanum = input('what station number?  1] LB V  2] GB 1200  3] GB Sontek  4] Apro 1  5] GB 1200  6] Apro 2  7] Apro 3  8] Apro 4  ');
	tavg = input('Enter averaging time, in minutes:  ');
	t0 = 241.345;

end;

if stanum == 41, stanum = 4; end;
if stanum == 42, stanum = 6; end;
if stanum == 43, stanum = 7; end;
if stanum == 44, stanum = 8; end;

if nargin < 4,
	tavg = 0;
end;
tavg = tavg * 60;  %% convert to seconds

if gres == 10,
	fname = 'ocean_sta_run04Cv13.nc';
end;
if gres == 30,
	fname = 'ocean_sta_run02G.nc';
end;

pathname = ['/Users/tlippmann/research/coawst_roms_modeling/modeldata/stationdata/' num2str(gres) 'm/'];

ncname = [pathname fname];

t = ncread(ncname, 'ocean_time');
h = ncread(ncname, 'h');
[a, b] = size(h);
lat_rho = ncread(ncname, 'lat_rho');
lon_rho = ncread(ncname, 'lon_rho');
zeta = ncread(ncname, 'zeta');
srho = ncread(ncname, 's_rho');
srho_len = length(srho);
sw = ncread(ncname, 's_w');
sw_len = length(sw);
hc = ncread(ncname, 'hc');
bustr = ncread(ncname, 'bustr');
bvstr = ncread(ncname, 'bvstr');
u = ncread(ncname, 'u');
v = ncread(ncname, 'v');
w = ncread(ncname, 'w');



tm = t/3600/24 + t0;

df = find(tm > tm(1)+2);   %% skip the spin-up time, about 2 days
tm = tm(df);
tlen = length(tm);
um = reshape(u(:, stanum, df), srho_len, tlen);
vm = reshape(v(:, stanum, df), srho_len, tlen);
wm = reshape(w(:, stanum, df), sw_len, tlen);
pm = zeta(stanum, df);
bum = bustr(stanum, df);
bvm = bvstr(stanum, df);

if (tavg),
	samint = floor(10*(t(2)-t(1)))/10;  %% sampling interval in seconds
	nptsavg = floor(tavg/samint);
	nlen = floor(tlen/nptsavg);
	nused = nlen*nptsavg;
	uma = nan*ones(srho_len, nlen);
	vma = nan*ones(srho_len, nlen);
	wma = nan*ones(sw_len, nlen);

	tma = nanmean(reshape(tm(1:nused), nptsavg, nlen));
	pma = nanmean(reshape(pm(1:nused), nptsavg, nlen));
	buma = nanmean(reshape(bum(1:nused), nptsavg, nlen));
	bvma = nanmean(reshape(bvm(1:nused), nptsavg, nlen));
	for n=1:srho_len
		uma(n,:) = nanmean(reshape(um(n,1:nused), nptsavg, nlen));
		vma(n,:) = nanmean(reshape(vm(n,1:nused), nptsavg, nlen));
		wma(n,:) = nanmean(reshape(wm(n,1:nused), nptsavg, nlen));
	end;
	wma(n+1,:) = nanmean(reshape(wm(n+1,1:nused), nptsavg, nlen));

	if (1),
		tm = tma;
		pm = pma;
		um = uma;
		vm = vma;
		wm = wma;
		bum = buma;
		bvm = bvma;
	end;
end;


Dp = h(stanum) + pm;  %% elevation above the bottom to SSE
Zbed = -(h(stanum) + zeta(stanum,1));   %% elevation of the sea bed relative to MSL
Zsens = Zbed + (1+srho(:))*Dp;
hb = -Zbed;

pm = pm - zeta(stanum,1);   %% make sse relative to msl

return;



