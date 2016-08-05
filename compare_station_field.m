

gres = input('what grid resolution?   (e.g., 10, 30, etc.)  ');
stanum = input('what station number?  1] LB V  2] GB 1200  3] GB Sontek  4] Apro 1  5] GB 1200  ');
if stanum == 4,
	st2 = input('which location:  1]  GB01  2] GB02  3] GB03  4]  GB04  ');
	stanum = 40 + st2;
end;
adcpid = stanum;
tminute = input('enter avg time (in minutes) for data to get:  ');
%%tminute = 10;  %% averaging time in minutes
nbavg = input('enter number of vertical bins to average in the OBSERVATIONS:  [1 == dont avg any]  ');

[ta, pa, ua, va, wa, zbins, lat, lon] = get_gb2015_data(adcpid, tminute, nbavg);
%%t0 = 246.025;
t0 = 241.345;
if (adcpid ==1 | adcpid == 2 | adcpid ==5)
	nzu = 10;
end;
if (adcpid ==3)
	nzu = 10;
end;
if ( adcpid >= 40)
	nzu = 10;
end


[tm, pm, um, vm, wm, bum, bvm, lat_rho, lon_rho, Zsens, hb] = get_station_data(gres, stanum, t0, tminute);
t1 = tm(1);
t2 = tm(end);


if (1),
	df = find(ta >= t1 & ta <= t2);
	ta = ta(df);
	ua = ua(df,:);
	va = va(df,:);
	wa = wa(df,:);
	pa = pa(df,:);
end;

%% interpolate model data onto observations vertical locations
nz = length(zbins);
nt = length(ta);
uma = nan*ones(nt, nz);
vma = nan*ones(nt, nz);

for n=1:nt
	dg = find(isnan(um(:,n).*vm(:,n))==0);
	if numel(dg),
		uma(n,:) = interp1(Zsens(dg,n), um(dg,n), zbins-hb);
		vma(n,:) = interp1(Zsens(dg,n), vm(dg,n), zbins-hb);
	end;
end;

figure(1);
clf;
sax(1) = subplot(2,2,1);
plot(tm, um);
hold on;
dl = line([t1 t2], [0 0]);

sax(2) = subplot(2,2,2);
plot(tm, vm);
hold on;
dl = line([t1 t2], [0 0]);

sax(3) = subplot(2,2,3);
plot(ta, ua);
hold on;
dl = line([t1 t2], [0 0]);

sax(4) = subplot(2,2,4);
plot(ta, va);
hold on;
dl = line([t1 t2], [0 0]);

linkaxes(sax, 'x');

figure(2)
clf;
plot(ta, (pa-nanmean(pa)), 'b', tm, (pm-nanmean(pm)), 'r');

figure(3);
clf;
for n=1:nzu
	tax(n) = subplot(nzu,1,nzu-n+1);
	plot(ta, ua(:,n), 'b', ta, uma(:,n), 'r');
	hold on;
	dl = line([ta(1) ta(end)], [0 0], 'color','k','linestyle', '--');
end;
title('u');
linkaxes(tax, 'x');

figure(4);
clf;
nzu = 10;
for n=1:nzu
	pax(n) = subplot(nzu,1,nzu-n+1);
	plot(ta, va(:,n), 'b', ta, vma(:,n), 'r');
	hold on;
	dl = line([ta(1) ta(end)], [0 0], 'color','k','linestyle', '--');
end;
title('v');
linkaxes(pax, 'x');

figure(30);
clf;
nzu = 10;
for n=1:nzu
	pax(n) = subplot(nzu,1,nzu-n+1);
	vamag = sqrt(ua(:,n).^2 + va(:,n).^2);
	vmamag = sqrt(uma(:,n).^2 + vma(:,n).^2);
	plot(ta, vamag, 'b', ta, vmamag, 'r');
	hold on;
	dl = line([ta(1) ta(end)], [0 0], 'color','k','linestyle', '--');
end;
title('MAG');
linkaxes(pax, 'x');

figure(40);
clf;
nzu = 10;
for n=1:nzu
	pax(n) = subplot(nzu,1,nzu-n+1);
	vadir = atan2(ua(:,n), va(:,n))*180/pi;
	vmadir = atan2(uma(:,n), vma(:,n))*180/pi;
	plot(ta, vadir, 'b.', ta, vmadir, 'r.');
	hold on;
	dl = line([ta(1) ta(end)], [0 0], 'color','k','linestyle', '--');
end;
title('DIR');
linkaxes(pax, 'x');


figure(5);
clf;
for n=1:length(tm)
	plot(um(:,n), Zsens(:, n), 'b.-', vm(:,n), Zsens(:,n), 'r.-');
	axis([-1.5 1.5 -18 4]);
	hold on;
	pl = plot(ua(n, :), zbins-hb, 'c.-', va(n, :), zbins-hb, 'm.-');
	dl = line([-1.5 1.5], [pm(n) pm(n)]);
	dl = line([-1.5 1.5], [pa(n) pa(n)]-hb, 'linestyle', '--');
	dl = line([0 0], [-18 4]);
	df = line([-1.5 1.5], [-hb -hb], 'color', 'k', 'linestyle', '--');
	df = line([-1.5 1.5], [zbins(1) zbins(1)]-hb-1.19-0.52, 'color', 'k', 'linestyle', '-.');
	pause
	hold off
end


