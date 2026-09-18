function tauTilde = computeKinematicWindStress(amplitude, units, rho0)
% COMPUTEKINEMATICWINDSTRESS Convert a wind amplitude array to kinematic wind stress magnitude.
%   TAUTILDE = COMPUTEKINEMATICWINDSTRESS(AMPLITUDE, UNITS, RHO0) converts
%   AMPLITUDE to kinematic wind stress magnitude, in m^2/s^2. For "m/s"/
%   "kts" units, wind speed is converted to wind stress via the Large &
%   Pond (1981) bulk drag coefficient formula, then normalized by RHO0.
%   For "Pa", AMPLITUDE is already a wind stress magnitude and is only
%   normalized by RHO0.
arguments
    amplitude double
    units (1, 1) string {mustBeMember(units, ["m/s", "kts", "Pa"])}
    rho0 (1, 1) double
end
if units == "Pa"
    tauTilde = amplitude / rho0;
    return
end

rhoAir = 1.225;
ktsToMs = 0.514444;
if units == "kts"
    amplitude = amplitude * ktsToMs;
end

dragCoefficient = 1.2e-3 * ones(size(amplitude));
highWind = amplitude >= 11.0;
dragCoefficient(highWind) = (0.49 + 0.065 * amplitude(highWind)) * 1e-3;
windStress = rhoAir * dragCoefficient .* amplitude .^ 2;
tauTilde = windStress / rho0;
end
