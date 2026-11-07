<?php
// CLI check for lib.php. Run:  php tests/test_calculo.php   (exit code 0 = all good)
require __DIR__ . '/../lib.php';

$fail = 0;
function check(string $name, $got, $expected): void
{
    global $fail;
    $ok = ($got === $expected);
    echo ($ok ? 'OK   ' : 'FAIL ') . $name . ($ok ? '' : ' got=' . var_export($got, true) . ' expected=' . var_export($expected, true)) . PHP_EOL;
    if (!$ok) {
        $fail++;
    }
}

check('weights add up to 1', round(array_sum(WEIGHTS), 10), 1.0);
check('all fives', final_grade(5, 5, 5), 5.0);
check('all zeros', final_grade(0, 0, 0), 0.0);
check('30/30/40 example', final_grade(4.0, 3.0, 5.0), 4.1);   // 1.2 + 0.9 + 2.0
check('last third weighs more', final_grade(0, 0, 5), 2.0);
check('first third weighs 30%', final_grade(5, 0, 0), 1.5);
check('rounding to 2 decimals', final_grade(3.33, 3.33, 3.33), 3.33);
check('passing at 3.0', is_passing(3.0), true);
check('failing at 2.99', is_passing(2.99), false);
check('parse dot', parse_grade('4.5'), 4.5);
check('parse comma', parse_grade('4,5'), 4.5);
check('parse spaces', parse_grade(' 3 '), 3.0);
check('reject above 5', parse_grade('5.1'), null);
check('reject negative', parse_grade('-1'), null);
check('reject text', parse_grade('abc'), null);
check('reject empty', parse_grade(''), null);

echo $fail === 0 ? 'ALL TESTS PASSED' . PHP_EOL : $fail . ' TEST(S) FAILED' . PHP_EOL;
exit($fail === 0 ? 0 : 1);
