#!/usr/bin/env python3
"""Generate lib/src/data/islamic_tr_diyanet.g.dart.

Computes Islamic month starts with the criterion of the 2016 International
Hijri Calendar Union Congress (Istanbul), which Diyanet uses:

  Main rule. A new month starts on the day after the evening when, somewhere
  on Earth and before 24:00 UTC, the moon is at least 5 degrees above the
  horizon at sunset and at least 8 degrees from the sun (elongation).

  Exception. If that only happens after 24:00 UTC, the month still starts
  when (a) the criterion is met on land in the Americas and (b) the
  conjunction happened before dawn (fajr) in New Zealand.

How the criterion is evaluated here
  * Altitude and elongation are topocentric, without refraction.
  * Main rule: the best place is always on the line where the sun sets just
    before 24:00 UTC, so only that line is scanned (every 0.5 degrees of
    latitude, 60S to 60N).
  * Exception: "land in the Americas" is the western-most land (mainland or
    island, Hawaii excluded) between 170W and 34W for every 0.5 degrees of
    latitude, 56S to 60N, taken from a 1 km land mask.
  * TOLERANCE: Diyanet's published dates accept crescents that this
    calculation puts up to 0.06 degrees under a limit and reject ones that
    are 0.29 degrees under. The cut-off is set in the middle of that gap.
    With it the calculation reproduces every month start in
    tool/diyanet_reference.csv.

Months that a small change of method would move by a day are listed in the
generated table as `borderlineMonths` and in doc/tr-diyanet.md.

Usage:
    pip install astronomy-engine global-land-mask numpy
    python3 tool/generate_tr_diyanet.py            # writes both files
    python3 tool/generate_tr_diyanet.py --check    # only validate
"""
import argparse
import csv
import datetime as dt
import math
import os
from multiprocessing import Pool

import astronomy as A
import numpy as np
from global_land_mask import globe

ALT_MIN, ELONG_MIN = 5.0, 8.0
TOLERANCE = 0.17  # degrees; see the module docstring
BAND = 0.12  # margins this close to the cut-off are "borderline"
FAJR_BAND = 15  # minutes
FIRST_HIJRI_YEAR = 1438
WELLINGTON = A.Observer(-41.29, 174.78, 0)
SUNSET_ALT = math.radians(-0.8333)
EPOCH = dt.date(1970, 1, 1)
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MONTHS = ["Muharrem", "Safer", "Rebiülevvel", "Rebiülahir", "Cemaziyelevvel",
          "Cemaziyelahir", "Recep", "Şaban", "Ramazan", "Şevval", "Zilkade",
          "Zilhicce"]


def at(d):
    return A.Time.Make(d.year, d.month, d.day, getattr(d, "hour", 0),
                       getattr(d, "minute", 0), getattr(d, "second", 0))


def utc(t):
    u = t.Utc()
    return dt.datetime(u.year, u.month, u.day, u.hour, u.minute, int(u.second))


def margin(obs, t):
    """How far the crescent is above both limits (negative = below)."""
    moon = A.Equator(A.Body.Moon, t, obs, True, True)
    sun = A.Equator(A.Body.Sun, t, obs, True, True)
    alt = A.Horizon(t, obs, moon.ra, moon.dec, A.Refraction.Airless).altitude
    return min(alt - ALT_MIN, A.AngleBetween(moon.vec, sun.vec) - ELONG_MIN)


def main_margin(day):
    """Best margin where the sun sets just before 24:00 UTC of `day`."""
    t = at(dt.datetime(day.year, day.month, day.day)
           + dt.timedelta(days=1, minutes=-1))
    sun = A.Equator(A.Body.Sun, t, A.Observer(0, 0, 0), True, True)
    dec, gast = math.radians(sun.dec), A.SiderealTime(t) * 15
    best = -99.0
    for i in range(241):
        lat = -60 + i * 0.5
        phi = math.radians(lat)
        c = ((math.sin(SUNSET_ALT) - math.sin(phi) * math.sin(dec))
             / (math.cos(phi) * math.cos(dec)))
        if abs(c) >= 1:
            continue
        lon = (math.degrees(math.acos(c)) - gast + sun.ra * 15 + 180) % 360 - 180
        best = max(best, margin(A.Observer(lat, lon, 0), t))
    return best


def americas_west_coast():
    lons = np.arange(-170, -34, 0.1)
    points = []
    for lat in np.arange(-56, 60.01, 0.5):
        land = globe.is_land(np.full_like(lons, lat), lons)
        run = 0
        for j, is_land in enumerate(land):
            lon = lons[j]
            excluded = ((lat < 30 and lon < -125)  # Hawaii, Pacific islands
                        or (lat > 59 and lon > -73)  # Greenland
                        or (-3 < lat < 3 and -95 < lon < -85))  # Galápagos
            run = run + 1 if (is_land and not excluded) else 0
            if run >= 2:
                points.append((float(lat), float(lons[j - 1])))
                break
    return points


WEST_COAST = americas_west_coast()


def americas_margin(day):
    """Best margin on Americas land at sunsets after 24:00 UTC of `day`."""
    midnight = dt.datetime(day.year, day.month, day.day) + dt.timedelta(days=1)
    best = -99.0
    for lat, lon in WEST_COAST:
        obs = A.Observer(lat, lon, 0)
        local_midnight = (dt.datetime(day.year, day.month, day.day)
                          - dt.timedelta(hours=lon / 15))
        sunset = A.SearchRiseSet(A.Body.Sun, obs, A.Direction.Set,
                                 at(local_midnight), 1.2)
        if sunset is None or utc(sunset) < midnight:
            continue
        best = max(best, margin(obs, sunset))
    return best


def nz_fajr(day):
    start = (dt.datetime(day.year, day.month, day.day)
             + dt.timedelta(days=1) - dt.timedelta(hours=174.78 / 15))
    return utc(A.SearchAltitude(A.Body.Sun, WELLINGTON, A.Direction.Rise,
                                at(start), 1.0, -18))


def month_start(conj_iso):
    """Returns (first day of the month, rule used, borderline?, note)."""
    conj = dt.datetime.fromisoformat(conj_iso)
    cut = -TOLERANCE
    borderline, notes = False, []

    def near(value, what, day):
        nonlocal borderline
        if abs(value - cut) <= BAND:
            borderline = True
            notes.append(f"{what} {day}: {value - cut:+.2f}°")

    for k in range(3):
        day = conj.date() + dt.timedelta(days=k)
        midnight = dt.datetime(day.year, day.month, day.day) + dt.timedelta(days=1)
        m = main_margin(day) if conj < midnight else -99.0
        near(m, "main rule", day)
        if m >= cut:
            return day + dt.timedelta(days=1), "main", borderline, "; ".join(notes)
        fajr_minutes = (nz_fajr(day) - conj).total_seconds() / 60
        e = americas_margin(day)
        if fajr_minutes > -FAJR_BAND:
            near(e, "Americas", day)
        if e >= cut and abs(fajr_minutes) <= FAJR_BAND:
            borderline = True
            notes.append(f"NZ dawn {day}: {fajr_minutes:+.0f} min")
        if fajr_minutes > 0 and e >= cut:
            return day + dt.timedelta(days=1), "exception", borderline, "; ".join(notes)
    raise RuntimeError(f"no month start found after conjunction {conj_iso}")


def conjunctions(count):
    # The first conjunction after this date starts 1 Muharrem 1438.
    t, out = at(dt.datetime(2016, 9, 25)), []
    for _ in range(count):
        t = A.SearchMoonPhase(0, t, 40)
        out.append(utc(t).isoformat())
        t = t.AddDays(20)
    return out


def reference():
    rows = {}
    with open(os.path.join(ROOT, "tool", "diyanet_reference.csv")) as f:
        for row in csv.reader(line for line in f if not line.startswith("#")):
            rows[(int(row[0]) - FIRST_HIJRI_YEAR) * 12 + int(row[1]) - 1] = \
                dt.date.fromisoformat(row[2])
    return rows


def label(index):
    return f"{MONTHS[index % 12]} {FIRST_HIJRI_YEAR + index // 12}"


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--lunations", type=int, default=516)
    p.add_argument("--check", action="store_true")
    args = p.parse_args()

    with Pool() as pool:
        results = pool.map(month_start, conjunctions(args.lunations), chunksize=4)
    starts = [r[0] for r in results]
    assert set((b - a).days for a, b in zip(starts, starts[1:])) <= {29, 30}

    ref = reference()
    wrong = [(label(i), str(starts[i]), str(d)) for i, d in ref.items()
             if starts[i] != d]
    print(f"reference months matched: {len(ref) - len(wrong)}/{len(ref)}")
    if wrong:
        raise SystemExit(f"mismatch with Diyanet: {wrong}")
    if args.check:
        return

    verified = max(ref)  # months up to here are published by Diyanet
    months = len(starts) - 1
    borderline = [i for i in range(verified + 1, months) if results[i][2]]
    lengths = "".join("1" if (b - a).days == 30 else "0"
                      for a, b in zip(starts, starts[1:]))
    last = months - 1

    out = [
        "// GENERATED by tool/generate_tr_diyanet.py — do not edit by hand.",
        "// Diyanet / 2016 Unified Hijri Calendar month starts,",
        f"// 1 Muharrem 1438 ({starts[0]}) to {MONTHS[last % 12]} "
        f"{FIRST_HIJRI_YEAR + last // 12} ({starts[last]}).",
        "",
        f"const int firstHijriYear = {FIRST_HIJRI_YEAR};",
        "const int firstHijriMonth = 1;",
        f"const int firstEpochDay = {(starts[0] - EPOCH).days}; // {starts[0]}",
        "",
        "/// One character per month: '1' = 30 days, '0' = 29 days.",
        "const String monthLengths =",
    ]
    for i in range(0, len(lengths), 60):
        end = ";" if i + 60 >= len(lengths) else ""
        out.append(f"    '{lengths[i:i + 60]}'{end}")
    out += [
        "",
        "/// Months (0 = the first month of the table) checked against dates",
        "/// published by Diyanet end here.",
        f"const int lastVerifiedMonth = {verified}; // {label(verified)}",
        "",
        "/// Later months whose start is within the method's tolerance of the",
        "/// visibility limits and could move by one day. See doc/tr-diyanet.md.",
        "const List<int> borderlineMonths = [",
    ]
    for b in borderline:  # one per line, as `dart format` writes it
        out.append(f"  {b},")
    out.append("];")
    path = os.path.join(ROOT, "lib", "src", "data", "islamic_tr_diyanet.g.dart")
    with open(path, "w") as f:
        f.write("\n".join(out) + "\n")

    doc = [
        "# Türkiye (Diyanet) Islamic calendar table",
        "",
        "Generated by `tool/generate_tr_diyanet.py`. Do not edit by hand.",
        "",
        f"* Range: 1 Muharrem 1438 ({starts[0]}) to the end of "
        f"{label(last)} ({starts[months] - dt.timedelta(days=1)}).",
        f"* Checked against {len(ref)} month starts published by Diyanet "
        f"(`tool/diyanet_reference.csv`), the latest being {label(verified)}. "
        "All match.",
        f"* {sum(1 for r in results[:months] if r[1] == 'exception')} of "
        f"{months} months are decided by the Americas / New Zealand exception.",
        f"* {len(borderline)} later months are borderline: the crescent is within "
        f"{BAND}° of the cut-off (or the conjunction within {FAJR_BAND} minutes "
        "of dawn in New Zealand). Their start could move by one day, so dates "
        "in them are returned with `estimated: true`.",
        "",
        "## Borderline months",
        "",
        "| Month | Calculated start | Rule | Distance from the cut-off |",
        "|---|---|---|---|",
    ]
    for i in borderline:
        doc.append(f"| {label(i)} | {starts[i]} | {results[i][1]} | {results[i][3]} |")
    with open(os.path.join(ROOT, "doc", "tr-diyanet.md"), "w") as f:
        f.write("\n".join(doc) + "\n")
    print(f"wrote {path} and doc/tr-diyanet.md; borderline: {len(borderline)}")


if __name__ == "__main__":
    main()
