<?php
// Basic grade calculator for School courses (Lab 6, point 3).
// Asks for the student's name and the grade of each third of the semester, computes the final grade
// (30%, 30%, 40%) and saves the record in PostgreSQL.
require __DIR__ . '/lib.php';

header('Content-Type: text/html; charset=utf-8');

function e(string $s): string
{
    return htmlspecialchars($s, ENT_QUOTES, 'UTF-8');
}

function connect(): PDO
{
    $c = require __DIR__ . '/config.php';
    $dsn = sprintf('pgsql:host=%s;port=%d;dbname=%s', $c['host'], $c['port'], $c['dbname']);
    return new PDO($dsn, $c['user'], $c['password'], [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
}

$errors = [];
$result = null;
$saved = false;
$values = ['estudiante' => '', 'nota1' => '', 'nota2' => '', 'nota3' => ''];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    foreach ($values as $k => $_) {
        $values[$k] = trim((string) ($_POST[$k] ?? ''));
    }
    $name = $values['estudiante'];
    if ($name === '' || mb_strlen($name) > 100) {
        $errors[] = 'Escribe el nombre del estudiante (máximo 100 caracteres).';
    }
    $grades = [];
    foreach (['nota1' => 'primer tercio', 'nota2' => 'segundo tercio', 'nota3' => 'último tercio'] as $k => $label) {
        $g = parse_grade($values[$k]);
        if ($g === null) {
            $errors[] = "La nota del $label debe ser un número entre 0 y 5.";
        }
        $grades[$k] = $g;
    }
    if (!$errors) {
        $final = final_grade($grades['nota1'], $grades['nota2'], $grades['nota3']);
        $result = ['final' => $final, 'passing' => is_passing($final)];
        try {
            $stmt = connect()->prepare(
                'INSERT INTO notas (estudiante, nota1, nota2, nota3, nota_final) VALUES (?, ?, ?, ?, ?)'
            );
            $stmt->execute([$name, $grades['nota1'], $grades['nota2'], $grades['nota3'], $final]);
            $saved = true;
        } catch (Throwable $ex) {
            error_log('notas: ' . $ex->getMessage());
            $errors[] = 'Se calculó la nota, pero no se pudo guardar en la base de datos.';
        }
    }
}

$records = [];
try {
    $records = connect()->query(
        'SELECT estudiante, nota1, nota2, nota3, nota_final, creado FROM notas ORDER BY id DESC LIMIT 10'
    )->fetchAll();
} catch (Throwable $ex) {
    error_log('notas: ' . $ex->getMessage());
}
?>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Calculadora de notas</title>
  <style>
    body { font-family: Arial, sans-serif; max-width: 640px; margin: 2rem auto; padding: 0 1rem; color: #111; }
    label { display: block; margin-top: .8rem; font-weight: bold; }
    input { width: 100%; padding: .5rem; box-sizing: border-box; }
    button { margin-top: 1rem; padding: .6rem 1.2rem; }
    .error { color: #a00; } .ok { color: #070; font-weight: bold; }
    table { border-collapse: collapse; width: 100%; margin-top: 1rem; }
    th, td { border: 1px solid #999; padding: .4rem; text-align: left; }
  </style>
</head>
<body>
  <h1>Calculadora de notas</h1>
  <p>Escribe el nombre y la nota de cada tercio del semestre (de 0 a 5). La nota final pondera 30 %, 30 % y 40 %.</p>
  <?php foreach ($errors as $m): ?><p class="error"><?= e($m) ?></p><?php endforeach; ?>
  <form method="post" action="">
    <label for="estudiante">Nombre del estudiante</label>
    <input id="estudiante" name="estudiante" maxlength="100" value="<?= e($values['estudiante']) ?>" required>
    <label for="nota1">Nota del primer tercio (30 %)</label>
    <input id="nota1" name="nota1" inputmode="decimal" value="<?= e($values['nota1']) ?>" required>
    <label for="nota2">Nota del segundo tercio (30 %)</label>
    <input id="nota2" name="nota2" inputmode="decimal" value="<?= e($values['nota2']) ?>" required>
    <label for="nota3">Nota del último tercio (40 %)</label>
    <input id="nota3" name="nota3" inputmode="decimal" value="<?= e($values['nota3']) ?>" required>
    <button type="submit">Calcular y guardar</button>
  </form>
  <?php if ($result): ?>
    <h2>Resultado</h2>
    <p class="ok">Nota final: <?= e(number_format($result['final'], 2, '.', '')) ?>
      (<?= $result['passing'] ? 'aprueba' : 'no aprueba' ?>)<?= $saved ? ' · registro guardado' : '' ?></p>
  <?php endif; ?>
  <h2>Últimos registros</h2>
  <?php if ($records): ?>
    <table>
      <tr><th>Estudiante</th><th>Nota 1</th><th>Nota 2</th><th>Nota 3</th><th>Final</th><th>Fecha</th></tr>
      <?php foreach ($records as $r): ?>
        <tr><td><?= e($r['estudiante']) ?></td><td><?= e($r['nota1']) ?></td><td><?= e($r['nota2']) ?></td>
            <td><?= e($r['nota3']) ?></td><td><?= e($r['nota_final']) ?></td><td><?= e($r['creado']) ?></td></tr>
      <?php endforeach; ?>
    </table>
  <?php else: ?>
    <p>Todavía no hay registros.</p>
  <?php endif; ?>
</body>
</html>
