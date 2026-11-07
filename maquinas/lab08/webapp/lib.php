<?php
// Grade calculator logic (no I/O, so it can be tested from the CLI).

const WEIGHTS = [0.30, 0.30, 0.40]; // first third, second third, last third of the semester
const PASSING_GRADE = 3.0;

// Accepts "4.5" or "4,5". Returns a float in [0, 5] or null when the value is not valid.
function parse_grade(string $raw): ?float
{
    $raw = trim(str_replace(',', '.', $raw));
    if ($raw === '' || !is_numeric($raw)) {
        return null;
    }
    $grade = (float) $raw;
    return ($grade >= 0.0 && $grade <= 5.0) ? $grade : null;
}

// Final semester grade: 30% + 30% + 40%, rounded to two decimals.
function final_grade(float $g1, float $g2, float $g3): float
{
    return round($g1 * WEIGHTS[0] + $g2 * WEIGHTS[1] + $g3 * WEIGHTS[2], 2);
}

function is_passing(float $final): bool
{
    return $final >= PASSING_GRADE;
}
