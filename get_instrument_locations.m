function [N, E, Z, lat, lon, tstart, tend] = get_instrument_locations;
%%function [N, E, Z, lat, lon, tstart, tend] = get_instrument_locations;
%
%	outputs:	N, E		= UTM northing and easting (m)
%			Z		= approximated mean depth (m)
%			lat, lon	= N latitude and E Longitude (deg)
%			tstart, tend	= local julian day of start and stop time of records (EDT, fraction days)
%

inpath = '/Users/tlippmann/field_work/great_bay_2015/adcp/';
infile = 'deployed_instrument_locations_201508.txt';
fid = fopen([inpath infile], 'r');

n = 0;
while(1),
	aline = fgetl(fid);
	if ~isstr(aline), break; end;

	[A, na] = sscanf(aline, '%*s %d: N %f %f W %f %f ~%f ft %f:%f EDT %f %f %f %f %f', 13);
	n = n + 1;
	lat(n) = A(2) + A(3)/60;
	lon(n) = -(A(4) + A(5)/60);
	Z(n) = A(6)*(0.3048);

	hr = A(7);
	mn = A(8);
	yr = A(9);
	mon = A(10);
	day = A(11);
	deploy_jday_time_EDT(n) = julian(yr, mon, day, hr+mn/60) - julian(yr-1, 12, 31, 0);

	tstart(n) = A(12);
	tend(n) = A(13);
end;
fclose(fid);

[N, E, zone] = lltoutm(lat, lon, 23);

return;

