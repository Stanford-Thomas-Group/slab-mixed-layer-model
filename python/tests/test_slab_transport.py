import numpy as np
import pytest

from slabmodel import slab_transport


def test_constant_forcing_matches_closed_form():
    # For r=0 and constant forcing, dW/dt + ifW = tau_tilde*exp(i*theta) has the
    # closed-form solution W(t) = tau_tilde*exp(i*theta)*(1-exp(-i*f*t))/(i*f).
    latitude = 30.0
    f = 7.2921159e-5  # 2*OMEGA*sin(30deg) == OMEGA
    theta = np.pi / 4.0
    tau_tilde = 2.0
    time = np.linspace(0.0, 6 * 3600.0, 361)

    result = slab_transport(
        time,
        amplitude=tau_tilde,
        direction=theta,
        latitude=latitude,
        units="Pa",
        rho0=1.0,
    )

    expected = tau_tilde * np.exp(1j * theta) * (1 - np.exp(-1j * f * time)) / (1j * f)
    np.testing.assert_allclose(result.U, expected.real, rtol=1e-3)
    np.testing.assert_allclose(result.V, expected.imag, rtol=1e-3)


def test_rotating_direction_matches_closed_form():
    # For constant amplitude and direction rotating at constant angular velocity
    # omega, T(t) = tau_tilde*exp(i*(theta0+omega*t)) = A*exp(i*omega*t), and
    # dW/dt + (r+if)W = T(t) has closed-form solution (W(0)=0):
    #   W(t) = [A/(r+i*(omega+f))] * (exp(i*omega*t) - exp(-(r+if)*t))
    # (reduces to the non-rotating closed form above when omega=0).
    latitude = 30.0
    f = 7.2921159e-5  # 2*OMEGA*sin(30deg) == OMEGA
    factor = 0.1
    r = factor * abs(f)
    omega = 8.0e-4  # >> f
    theta0 = 0.5
    tau_tilde = 3.0
    time = np.linspace(0.0, 20000.0, 2001)
    direction = theta0 + omega * time

    result = slab_transport(
        time,
        amplitude=tau_tilde,
        direction=direction,
        latitude=latitude,
        factor=factor,
        units="Pa",
        rho0=1.0,
    )

    a = tau_tilde * np.exp(1j * theta0)
    expected = (a / (r + 1j * (omega + f))) * (
        np.exp(1j * omega * time) - np.exp(-(r + 1j * f) * time)
    )
    np.testing.assert_allclose(result.U, expected.real, rtol=1e-3)
    np.testing.assert_allclose(result.V, expected.imag, rtol=1e-3)


def test_nan_in_constant_series_reproduces_same_result():
    time = np.linspace(0.0, 3600.0, 61)
    amplitude = np.full_like(time, 3.0)
    direction = np.full_like(time, 1.0)

    baseline = slab_transport(
        time, amplitude, direction, latitude=45.0, units="Pa", rho0=1.0
    )

    amplitude_gap = amplitude.copy()
    direction_gap = direction.copy()
    amplitude_gap[30] = np.nan
    direction_gap[30] = np.nan
    with_gap = slab_transport(
        time, amplitude_gap, direction_gap, latitude=45.0, units="Pa", rho0=1.0
    )

    np.testing.assert_allclose(with_gap.U, baseline.U, rtol=1e-10)
    np.testing.assert_allclose(with_gap.V, baseline.V, rtol=1e-10)


def test_nan_gap_matches_removing_the_sample():
    # With f=0 and r=0, h(t) == g(t) exactly (no exponential weighting), and if
    # the underlying forcing is exactly linear in time, the trapezoidal rule is
    # exact: interpolating a linearly-consistent value at a gap and integrating
    # normally must reproduce precisely the same result, at every surviving time,
    # as removing that sample and integrating across the doubled timestep.
    time = np.array([0.0, 60.0, 120.0, 180.0, 240.0, 300.0])
    amplitude = 5.0 + 0.01 * time  # exactly linear in time
    direction = np.full_like(time, 0.3)

    with_gap_amplitude = amplitude.copy()
    with_gap_direction = direction.copy()
    with_gap_amplitude[2] = np.nan
    with_gap_direction[2] = np.nan
    with_gap = slab_transport(
        time,
        with_gap_amplitude,
        with_gap_direction,
        latitude=0.0,
        units="Pa",
        rho0=1.0,
    )

    removed = slab_transport(
        np.delete(time, 2),
        np.delete(amplitude, 2),
        np.delete(direction, 2),
        latitude=0.0,
        units="Pa",
        rho0=1.0,
    )

    np.testing.assert_allclose(np.delete(with_gap.U, 2), removed.U, rtol=1e-9)
    np.testing.assert_allclose(np.delete(with_gap.V, 2), removed.V, rtol=1e-9)
    assert np.isfinite(with_gap.U[2])
    assert np.isfinite(with_gap.V[2])


def test_all_nan_raises():
    time = np.array([0.0, 60.0, 120.0])
    amplitude = np.full_like(time, np.nan)
    direction = np.full_like(time, np.nan)
    with pytest.raises(ValueError):
        slab_transport(time, amplitude, direction, latitude=45.0)


def test_scalar_amplitude_and_direction_broadcast():
    time = np.linspace(0.0, 3600.0, 50)
    result = slab_transport(time, amplitude=5.0, direction=0.2, latitude=45.0)
    assert result.U.shape == time.shape
    assert result.V.shape == time.shape
    assert np.all(np.isfinite(result.U))
    assert np.all(np.isfinite(result.V))
