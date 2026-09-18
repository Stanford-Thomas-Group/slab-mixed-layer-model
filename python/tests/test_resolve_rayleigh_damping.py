import pytest

from slabmodel import resolve_rayleigh_damping


def test_r_given_directly():
    assert resolve_rayleigh_damping(1.5e-5, None, f=1.0e-4) == 1.5e-5


def test_neither_given_defaults_to_zero():
    assert resolve_rayleigh_damping(None, None, f=1.0e-4) == 0.0


def test_factor_given_positive_f():
    assert resolve_rayleigh_damping(None, 0.1, f=1.0e-4) == pytest.approx(1.0e-5)


def test_factor_given_negative_f_stays_positive():
    # Southern Hemisphere: f < 0, r must still come out positive (r > 0 invariant).
    assert resolve_rayleigh_damping(None, 0.1, f=-1.0e-4) == pytest.approx(1.0e-5)


def test_both_given_raises():
    with pytest.raises(ValueError):
        resolve_rayleigh_damping(1.0e-5, 0.1, f=1.0e-4)
