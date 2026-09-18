import numpy as np
import pytest

from slabmodel import compute_kinematic_wind_stress

_RHO_AIR = 1.225


def test_pa_units_just_divides_by_rho0():
    amplitude = np.array([10.0, 20.0])
    result = compute_kinematic_wind_stress(amplitude, "Pa", rho0=1025.0)
    np.testing.assert_allclose(result, amplitude / 1025.0)


def test_kts_matches_equivalent_ms():
    speed_kts = np.array([5.0, 12.0, 20.0])
    speed_ms = speed_kts * 0.514444
    result_kts = compute_kinematic_wind_stress(speed_kts, "kts", rho0=1025.0)
    result_ms = compute_kinematic_wind_stress(speed_ms, "m/s", rho0=1025.0)
    np.testing.assert_allclose(result_kts, result_ms)


def test_low_wind_speed_drag_coefficient():
    # Large & Pond (1981): Cd = 1.2e-3 for U10 < 11 m/s.
    amplitude = np.array([5.0])
    rho0 = 1025.0
    expected_tau = _RHO_AIR * 1.2e-3 * 5.0**2
    result = compute_kinematic_wind_stress(amplitude, "m/s", rho0)
    assert result[0] == pytest.approx(expected_tau / rho0)


def test_high_wind_speed_drag_coefficient():
    # Large & Pond (1981): Cd = (0.49 + 0.065*U10)*1e-3 for U10 >= 11 m/s.
    amplitude = np.array([15.0])
    rho0 = 1025.0
    cd = (0.49 + 0.065 * 15.0) * 1e-3
    expected_tau = _RHO_AIR * cd * 15.0**2
    result = compute_kinematic_wind_stress(amplitude, "m/s", rho0)
    assert result[0] == pytest.approx(expected_tau / rho0)


def test_unknown_units_raises():
    units: str = "furlongs/fortnight"
    with pytest.raises(ValueError):
        compute_kinematic_wind_stress(np.array([1.0]), units, rho0=1025.0)  # ty: ignore[invalid-argument-type]
