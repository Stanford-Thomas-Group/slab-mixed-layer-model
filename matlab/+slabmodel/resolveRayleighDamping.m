function r = resolveRayleighDamping(f, r, factor)
% RESOLVERAYLEIGHDAMPING Resolve the Rayleigh damping coefficient.
%   R = RESOLVERAYLEIGHDAMPING(F, R, FACTOR) resolves the Rayleigh damping
%   coefficient, in 1/s. F is the Coriolis parameter, in rad/s, used when
%   FACTOR is given: R = FACTOR * abs(F). At most one of R or FACTOR may
%   be given; if neither is given, R defaults to zero (undamped).
arguments
    f (1, 1) double
    r double {mustBeScalarOrEmpty} = []
    factor double {mustBeScalarOrEmpty} = []
end
if ~isempty(r) && ~isempty(factor)
    error("slabmodel:resolveRayleighDamping:invalidArguments", ...
        "specify at most one of r or factor")
end
if ~isempty(factor)
    r = factor * abs(f);
elseif isempty(r)
    r = 0.0;
end
end
