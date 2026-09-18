import numpy as np
import pytest

from slabmodel import resolve_coriolis

_OMEGA = 7.2921159e-5


def test_f_given_directly():
    assert resolve_coriolis(1.23e-4, None) == 1.23e-4


def test_latitude_equator_gives_zero_f():
    assert resolve_coriolis(None, 0.0) == pytest.approx(0.0)


def test_latitude_north_pole():
    assert resolve_coriolis(None, 90.0) == pytest.approx(2.0 * _OMEGA)


def test_latitude_south_pole():
    assert resolve_coriolis(None, -90.0) == pytest.approx(-2.0 * _OMEGA)


def test_latitude_matches_formula():
    latitude = 37.5
    expected = 2.0 * _OMEGA * np.sin(np.radians(latitude))
    assert resolve_coriolis(None, latitude) == pytest.approx(expected)


def test_both_given_raises():
    with pytest.raises(ValueError):
        resolve_coriolis(1.0e-4, 45.0)


def test_neither_given_raises():
    with pytest.raises(ValueError):
        resolve_coriolis(None, None)
