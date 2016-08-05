function [ta, pa, ua, va, wa, zbins, lat, lon] = get_gb2015_data(adcpid, tminute, nbavg);
%%function [ta, pa, ua, va, wa, zbins, lat, lon] = get_gb2015_data(adcpid, tminute, nbavg);
%
%	inputs		adcpid		= which adcp:  1] 18m V    2] 12m 1200   3] 6m argonaut   4]  aquapro ~1.5m   5] 5m 1200
%			tminute		= number of minutes averaged in minutes (e.g., 10, 30)
%			nbavg		= how many vertical bins to average together (1==don't avg any bins

if (0),
	adcpid = input('which adcp:  1] 18m V    2] 12m 1200   3] 6m argonaut   4]  aquapro ~1.5m   5] 5m 1200  ');

	tminute = input('enter avg time (in minutes) for data to get:  ');
	%%tminute = 10;  %% averaging time in minutes
	nbavg = input('enter number of vertical bins to average:  [1 == dont avg any]  ');
end;

if adcpid == 1,  %%% Little Bay sentinel V,
        pathname = '/users/lippmann/field_work/great_bay_2015/adcp/data/ADCP-1_500khz/sentinel_v_500khz/';
        fname = [pathname 'sentinel_' num2str(tminute, '%3.3d') 'min.mat'];
end;
if adcpid == 2,  %%% 12 m RDI 1200 khz in Great Bay channel
        pathname = '/users/lippmann/field_work/great_bay_2015/adcp/data/ADCP-2_1200khz/rdi_1200khz/';
        fname = [pathname 'ADCP1001_' num2str(tminute, '%3.3d') 'min.mat'];
end;
if adcpid == 3,  %%% 7 m Sontek Argonaut in West GB lobe
        pathname = '/users/lippmann/field_work/great_bay_2015/adcp/data/ADCP-3_3mhz/sontek_argonaut_xr/';
        fname = [pathname 'sontek_adcp3_' num2str(tminute, '%3.3d') 'min.mat'];
end;
if adcpid >= 41,
        pathname = ['/users/lippmann/field_work/great_bay_2015/adcp/data/ADCP-4_aquapro/GB0' num2str(adcpid-40) '/'];
        fname = [pathname 'GB0' num2str(adcpid-40) '_' num2str(tminute, '%3.3d') 'min.mat'];
	if adcpid == 41, adcpid = 4; end;
	if adcpid == 42, adcpid = 6; end;
	if adcpid == 43, adcpid = 7; end;
	if adcpid == 44, adcpid = 8; end;
end;
if adcpid == 5,  %%% 5 m RDI 1200 khz in Eastern Great Bay lobe
        pathname = '/users/lippmann/field_work/great_bay_2015/adcp/data/ADCP-5_1200khz/rdi_1200khz/';
        fname = [pathname 'GB_05002_' num2str(tminute, '%3.3d') 'min.mat'];
end;

eval(['load ' fname]);

[N, E, Z, lat, lon, tstart, tend] = get_instrument_locations;

instid = adcpid;

lat = lat(instid);
lon = lon(instid);

if nbavg > 1,

	[nlen, ncells] = size(ua);
	nb = floor(ncells/nbavg);
	ncells2use = nb*nbavg;
	
	uan = zeros(nlen, nb);
	van = zeros(nlen, nb);
	wan = zeros(nlen, nb);
	
	for n=1:nlen
		uan(n, :) = nanmean(reshape(ua(n,1:ncells2use), nbavg, nb));
		van(n, :) = nanmean(reshape(va(n,1:ncells2use), nbavg, nb));
		wan(n, :) = nanmean(reshape(wa(n,1:ncells2use), nbavg, nb));
	end;
	
	zbins = nanmean(reshape(zbins(1:ncells2use), nbavg, nb));

	ua = uan;
	va = van;
	wa = wan;

end;
return;
