function [U, V] = slabTransport(time, amplitude, direction, options)
% SLABTRANSPORT Compute the slab mixed layer response to a wind forcing timeseries.
%   [U, V] = SLABTRANSPORT(TIME, AMPLITUDE, DIRECTION, ...) solves the
%   exact analytical solution of the slab mixed layer equations (see the
%   project README) given a wind amplitude and direction timeseries. NaN
%   gaps in AMPLITUDE/DIRECTION are filled by linear interpolation of the
%   Cartesian wind stress components before integrating, so the result
%   contains no NaNs as long as at least one sample is valid.
%
%   Name-value arguments:
%     F, LATITUDE  - Coriolis parameter (rad/s) or latitude (degrees) used
%                    to compute it. Exactly one must be given.
%     R, FACTOR    - Rayleigh damping coefficient (1/s), or a factor of
%                    abs(F) used to compute it. At most one may be given;
%                    defaults to R=0 if neither is given.
%     CONVENTION   - "polar" (default) or "bearing", for DIRECTION.
%     UNITS        - "m/s" (default), "kts", or "Pa", for AMPLITUDE.
%     RHO0         - Reference density of the ocean, in kg/m^3 (default
%                    1025.0).
arguments
    time double
    amplitude double
    direction double
    options.f double {mustBeScalarOrEmpty} = []
    options.latitude double {mustBeScalarOrEmpty} = []
    options.r double {mustBeScalarOrEmpty} = []
    options.factor double {mustBeScalarOrEmpty} = []
    options.convention (1, 1) string {mustBeMember(options.convention, ["polar", "bearing"])} = "polar"
    options.units (1, 1) string {mustBeMember(options.units, ["m/s", "kts", "Pa"])} = "m/s"
    options.rho0 (1, 1) double = 1025.0
end

f = slabmodel.resolveCoriolis(options.f, options.latitude);
r = slabmodel.resolveRayleighDamping(f, options.r, options.factor);

theta = slabmodel.resolveDirection(direction, options.convention);
tauTilde = slabmodel.computeKinematicWindStress(amplitude, options.units, options.rho0);

gx = tauTilde .* cos(theta) + zeros(size(time));
gy = tauTilde .* sin(theta) + zeros(size(time));

valid = ~isnan(gx);
if ~any(valid)
    error("slabmodel:slabTransport:allNaN", ...
        "amplitude/direction are NaN at every sample")
end
% interp1 returns NaN outside the sample domain by default, and 'extrap'
% linearly extrapolates -- neither matches Python's np.interp, which flat-
% extrapolates using the nearest boundary value. Clamp the query times into
% the valid domain first so a NaN gap at the start/end of the series is
% filled the same way in both implementations.
validTime = time(valid);
queryTime = min(max(time, validTime(1)), validTime(end));
gx = interp1(validTime, gx(valid), queryTime, "linear");
gy = interp1(validTime, gy(valid), queryTime, "linear");

growth = exp((r + 1i * f) * time);
h = (gx + 1i * gy) .* growth;
w = cumtrapz(time, h) ./ growth;

U = real(w);
V = imag(w);
end
