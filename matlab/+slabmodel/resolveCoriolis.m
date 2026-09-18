function f = resolveCoriolis(f, latitude)
% RESOLVECORIOLIS Resolve the Coriolis parameter from a direct value or a latitude.
%   F = RESOLVECORIOLIS(F, LATITUDE) resolves the Coriolis parameter, in
%   rad/s. Exactly one of F or LATITUDE must be given. LATITUDE is in
%   degrees, used to compute F = 2*OMEGA*sind(LATITUDE).
arguments
    f double {mustBeScalarOrEmpty} = []
    latitude double {mustBeScalarOrEmpty} = []
end
omega = 7.2921159e-5;
if isempty(f) == isempty(latitude)
    error("slabmodel:resolveCoriolis:invalidArguments", ...
        "specify exactly one of f or latitude")
end
if ~isempty(latitude)
    f = 2 * omega * sind(latitude);
end
end
