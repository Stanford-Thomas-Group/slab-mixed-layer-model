"""Slab mixed layer model."""

from typing import Literal, NamedTuple

import numpy as np
import numpy.typing as npt

_OMEGA = 7.2921159e-5
_RHO_AIR = 1.225
_KTS_TO_MS = 0.514444


def resolve_coriolis(f: float | None, latitude: float | None) -> float:
    """Resolve the Coriolis parameter from a direct value or a latitude.

    Exactly one of `f` or `latitude` must be given.

    Parameters
    ----------
    f : float or None
        Coriolis parameter, in rad/s.
    latitude : float or None
        Latitude, in degrees, used to compute ``f = 2 * OMEGA * sin(latitude)``.

    Returns
    -------
    float
        Coriolis parameter, in rad/s.

    Raises
    ------
    ValueError
        If both or neither of `f` and `latitude` are given.
    """
    if (f is None) == (latitude is None):
        raise ValueError("specify exactly one of f or latitude")
    if latitude is not None:
        return float(2.0 * _OMEGA * np.sin(np.radians(latitude)))
    assert f is not None
    return f


def resolve_rayleigh_damping(r: float | None, factor: float | None, f: float) -> float:
    """Resolve the Rayleigh damping coefficient from a direct value or a factor.

    At most one of `r` or `factor` may be given. If neither is given, `r`
    defaults to zero (undamped).

    Parameters
    ----------
    r : float or None
        Rayleigh damping coefficient, in 1/s.
    factor : float or None
        Rayleigh damping expressed as a factor of the Coriolis parameter
        magnitude, such that ``r = factor * abs(f)``.
    f : float
        Coriolis parameter, in rad/s, used when `factor` is given.

    Returns
    -------
    float
        Rayleigh damping coefficient, in 1/s.

    Raises
    ------
    ValueError
        If both `r` and `factor` are given.
    """
    if r is not None and factor is not None:
        raise ValueError("specify at most one of r or factor")
    if factor is not None:
        return factor * abs(f)
    if r is not None:
        return r
    return 0.0


def resolve_direction(
    direction: npt.NDArray[np.float64], convention: Literal["polar", "bearing"]
) -> npt.NDArray[np.float64]:
    """Convert a wind direction array to the polar angle convention.

    Parameters
    ----------
    direction : ndarray
        Wind direction. In the ``"polar"`` convention, radians positive
        counterclockwise from the x-axis (East), pointing in the direction the
        wind blows *toward*. In the ``"bearing"`` convention, degrees clockwise
        from North, giving the direction the wind is coming *from*.
    convention : {"polar", "bearing"}
        Convention `direction` is expressed in.

    Returns
    -------
    ndarray
        Direction as a polar angle, in radians.

    Raises
    ------
    ValueError
        If `convention` is not ``"polar"`` or ``"bearing"``.
    """
    if convention == "polar":
        return direction
    if convention == "bearing":
        return (1.5 * np.pi - np.radians(direction)) % (2.0 * np.pi)
    raise ValueError(f"unknown convention: {convention!r}")


def compute_kinematic_wind_stress(
    amplitude: npt.NDArray[np.float64],
    units: Literal["m/s", "kts", "Pa"],
    rho0: float,
) -> npt.NDArray[np.float64]:
    """Convert a wind amplitude array to kinematic wind stress magnitude.

    For ``"m/s"``/``"kts"`` units, wind speed is converted to wind stress via
    the Large & Pond (1981) bulk drag coefficient formula, then normalized by
    `rho0`. For ``"Pa"``, `amplitude` is already a wind stress magnitude and is
    only normalized by `rho0`.

    Parameters
    ----------
    amplitude : ndarray
        Wind forcing magnitude.
    units : {"m/s", "kts", "Pa"}
        Units `amplitude` is expressed in.
    rho0 : float
        Reference density of the ocean, in kg/m^3.

    Returns
    -------
    ndarray
        Kinematic wind stress magnitude, in m^2/s^2.

    Raises
    ------
    ValueError
        If `units` is not one of ``"m/s"``, ``"kts"``, or ``"Pa"``.
    """
    if units == "Pa":
        return amplitude / rho0
    if units == "kts":
        amplitude = amplitude * _KTS_TO_MS
    elif units != "m/s":
        raise ValueError(f"unknown units: {units!r}")
    drag_coefficient = np.where(
        amplitude < 11.0, 1.2e-3, (0.49 + 0.065 * amplitude) * 1e-3
    )
    wind_stress = _RHO_AIR * drag_coefficient * amplitude**2
    return wind_stress / rho0


class SlabTransportResult(NamedTuple):
    """Result of :func:`slab_transport`.

    Attributes
    ----------
    U : ndarray
        Zonal (x) mixed layer transport component.
    V : ndarray
        Meridional (y) mixed layer transport component.
    """

    U: npt.NDArray[np.float64]
    V: npt.NDArray[np.float64]


def slab_transport(
    time: npt.ArrayLike,
    amplitude: npt.ArrayLike,
    direction: npt.ArrayLike,
    *,
    f: float | None = None,
    latitude: float | None = None,
    r: float | None = None,
    factor: float | None = None,
    convention: Literal["polar", "bearing"] = "polar",
    units: Literal["m/s", "kts", "Pa"] = "m/s",
    rho0: float = 1025.0,
) -> SlabTransportResult:
    """Compute the slab mixed layer response to a wind forcing timeseries.

    Solves the exact analytical solution of the slab mixed layer equations
    (see the project README for the full derivation) given a wind amplitude
    and direction timeseries. NaN gaps in `amplitude`/`direction` are filled
    by linear interpolation of the Cartesian wind stress components before
    integrating, so the result contains no NaNs as long as at least one sample
    is valid.

    Parameters
    ----------
    time : array_like
        Elapsed time, in seconds.
    amplitude : array_like
        Wind forcing magnitude, in the units given by `units`.
    direction : array_like
        Wind direction, in the convention given by `convention`.
    f : float or None, optional
        Coriolis parameter, in rad/s. Exactly one of `f` or `latitude` must be
        given.
    latitude : float or None, optional
        Latitude, in degrees, used to compute `f`. Exactly one of `f` or
        `latitude` must be given.
    r : float or None, optional
        Rayleigh damping coefficient, in 1/s. At most one of `r` or `factor`
        may be given; if neither is given, `r` defaults to zero.
    factor : float or None, optional
        Rayleigh damping expressed as a factor of the Coriolis parameter
        magnitude, such that ``r = factor * abs(f)``.
    convention : {"polar", "bearing"}, optional
        Convention `direction` is expressed in. Default is ``"polar"``.
    units : {"m/s", "kts", "Pa"}, optional
        Units `amplitude` is expressed in. Default is ``"m/s"``.
    rho0 : float, optional
        Reference density of the ocean, in kg/m^3. Default is 1025.0.

    Returns
    -------
    SlabTransportResult
        The mixed layer transport components `U` and `V`.

    Raises
    ------
    ValueError
        If `f`/`latitude` or `r`/`factor` are not specified correctly, if
        `convention` or `units` is not recognized, or if `amplitude`/
        `direction` are NaN at every sample.
    """
    f = resolve_coriolis(f, latitude)
    r = resolve_rayleigh_damping(r, factor, f)

    time = np.asarray(time, dtype=np.float64)
    amplitude = np.asarray(amplitude, dtype=np.float64)
    direction = np.asarray(direction, dtype=np.float64)

    theta = resolve_direction(direction, convention)
    tau_tilde = compute_kinematic_wind_stress(amplitude, units, rho0)

    gx = tau_tilde * np.cos(theta)
    gy = tau_tilde * np.sin(theta)
    gx, gy, _ = np.broadcast_arrays(gx, gy, time)

    valid = ~np.isnan(gx)
    if not valid.any():
        raise ValueError("amplitude/direction are NaN at every sample")
    gx = np.interp(time, time[valid], gx[valid])
    gy = np.interp(time, time[valid], gy[valid])

    growth = np.exp((r + 1j * f) * time)
    h = (gx + 1j * gy) * growth
    integral = np.concatenate(
        ([0.0], np.cumsum(0.5 * (h[1:] + h[:-1]) * np.diff(time)))
    )
    w = integral / growth

    return SlabTransportResult(U=w.real, V=w.imag)
