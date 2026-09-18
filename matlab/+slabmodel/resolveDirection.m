function theta = resolveDirection(direction, convention)
% RESOLVEDIRECTION Convert a wind direction array to the polar angle convention.
%   THETA = RESOLVEDIRECTION(DIRECTION, CONVENTION) converts DIRECTION to a
%   polar angle in radians. In the "polar" convention, DIRECTION is already
%   a polar angle in radians (returned unchanged). In the "bearing"
%   convention, DIRECTION is a compass bearing in degrees, clockwise from
%   North, giving the direction the wind is coming from.
arguments
    direction double
    convention (1, 1) string {mustBeMember(convention, ["polar", "bearing"])}
end
if convention == "polar"
    theta = direction;
else
    theta = mod(1.5 * pi - deg2rad(direction), 2 * pi);
end
end
