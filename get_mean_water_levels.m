tidid = input('which tides:  1] observed at Ft. Point  2] predicted ft. point  3] predicted seavey island   ');

if (tidid == 1),
	%%% Fort Point Tide Station
	lat1 =  43 + 4.3/60;
	lon1 = -( 70 + 42.7/60);
	[N1, E1, zone] = lltoutm(lat1, lon1, 23);
	z1navd88 = 0;  
	[t11, z11] = get_tides_fortpoint('2013', '11');
	[t12, z12] = get_tides_fortpoint('2013', '12');
	[t01, z01] = get_tides_fortpoint('2014', '01');
	ta1 = [t11(:); t12(:); t01(:)];
	pa1 = [z11(:); z12(:); z01(:)];
	
end;

%% select one for tide, and find highs and lows.
if tidid == 1, 
	ttide = ta1;  
	ztide = pa1-nanmean(pa1); 
end;
if tidid >= 2, 
	[tap, zap] = read_predicted_tides(tidid-1);
	ttide = tap;
	ztide = zap - nanmean(zap);
end;

nt = length(ztide);
%% rising tides
df = find(ztide(2:nt) >= 0 & ztide(1:nt-1) < 0);
ndf = length(df);

%% falling tides
dg = find(ztide(1:nt-1) >= 0 & ztide(2:nt) < 0);
ndg = length(dg);

tlow = zeros(ndf, 1);
zlow = zeros(ndf, 1);
thigh = zeros(ndf, 1);
zhigh = zeros(ndf, 1);

di = [1:dg(1)];
[dmax, dmaxi] = max(ztide(di));
thigh(1) = ttide(di(dmaxi));
zhigh(1) = dmax;
di = [dg(ndg):nt];
[dmin, dmini] = min(ztide(di));
tlow(ndf) = ttide(di(dmini));
zlow(ndf) = dmin;

%%for m=1:ndf-1,
for m=1:ndg-1,
	di = [dg(m):dg(m+1)];
	[dmin, dmini] = min(ztide(di));
	tlow(m) = ttide(di(dmini));
	zlow(m) = dmin;
	[dmax, dmaxi] = max(ztide(di));
	thigh(m+1) = ttide(di(dmaxi));
	zhigh(m+1) = dmax;
end;

dze = find(tlow ~= 0);
tlow = tlow(dze);
zlow = zlow(dze);
ndg = length(dze);
dze = find(thigh ~= 0);
thigh = thigh(dze);
zhigh = zhigh(dze);
ndf = length(dze);

if length(thigh) > length(tlow), ndf = length(tlow); end;
if length(thigh) < length(tlow), ndf = length(thigh); end;
thigh = thigh(1:ndf);
zhigh = zhigh(1:ndf);
tlow = tlow(1:ndf);
tlow = tlow(1:ndf);


tiderange = zhigh - zlow;
tmid = (tlow + thigh)/2;
zmid = interp1(ttide, ztide, tmid);

tidefrac = ones(nt, 1)*nan;
tidephase = ones(nt, 1)*nan;
tideperiod = 12.4/24;

for n=1:nt
	if ttide(n) < thigh(1),
		tidefrac(n) = 2*(ztide(n) - zmid(ndf))/tiderange(1);
		tidephase(n) = (1 - (thigh(1)-ttide(n))/tideperiod)*180;
	end;
	if ttide(n) > tlow(ndf),
		tidefrac(n) = 2*(ztide(n) - zmid(ndf))/tiderange(ndf);
		tidephase(n) = ((ttide(n)-tlow(ndf))/tideperiod)*360;
	end;
	if (ttide(n) >= thigh(1) & ttide(n) <= tlow(ndf)),
		for m=1:ndf-1
			if (ttide(n) >= thigh(m) & ttide(n) < tlow(m)),
				tidefrac(n) = 2*(ztide(n) - zmid(m))/tiderange(m);
				tidephase(n) = ((ttide(n)-thigh(m)+tideperiod/2)/tideperiod)*360;
			end;
			if (ttide(n) >= tlow(m) & ttide(n) < thigh(m+1)),
				tidefrac(n) = 2*(ztide(n) - zmid(m+1))/tiderange(m+1);
				tidephase(n) = ((ttide(n)-tlow(m))/tideperiod)*360;
			end;
		end;
		if (ttide(n) >= thigh(ndf) & ttide(n) <= tlow(ndf)),
			tidefrac(n) = 2*(ztide(n) - zmid(m))/tiderange(m);
			tidephase(n) = ((ttide(n)-thigh(ndf)+tideperiod/2)/tideperiod)*360;
		end;
	end;

end;
dh = find(tidefrac > 1);
if numel(dh),
	tidefrac(dh) = 1;
end;
dh = find(tidefrac < -1);
if numel(dh),
	tidefrac(dh) = -1;
end;

figure(1);
clf;
plot(ttide, ztide, 'b.-');
dl = line([min(ttide) max(ttide)], [0 0], 'color', 'k');
hold on;
pl = plot(ttide(df), ztide(df), 'r.');
pl = plot(ttide(df+1), ztide(df+1), 'g.');
pl = plot(ttide(dg), ztide(dg), 'm.');
pl = plot(ttide(dg+1), ztide(dg+1), 'y.');
pl = plot(tlow, zlow, 'co', 'markerfacecolor', 'c', 'markersize', 8);
pl = plot(thigh, zhigh, 'ko', 'markerfacecolor', 'k', 'markersize', 4);


if (tidid == 1),
	figure(2);
	clf;
	plot(ta1, pa1, 'b');
	ax = axis;

end;

outpath = '/users/lippmann/field_work/pnsy/tides/';
if tidid == 1,
	outname = [outpath 'water_levels_moorings.mat'];
	fprintf(1, 'saving data to %s\n', outname);
	eval(['save ' outname ' ttide ztide ta1 pa1 N1 E1 lat1 lon1 z1navd88 tlow thigh zlow zhigh tmid zmid tiderange tidefrac tidephase']);

else

	if tidid == 2
		outname = [outpath 'water_levels_predicted_ft_point.mat'];
	else
		outname = [outpath 'water_levels_predicted_seavey.mat'];
	end;
	fprintf(1, 'saving data to %s\n', outname);
	eval(['save ' outname ' ttide ztide tap zap tlow thigh zlow zhigh tmid zmid tiderange tidefrac tidephase']);
end;
