<?php
header('Content-Type: text/plain; charset=utf-8');
print "MYENV1: " . getenv('MYENV1') . "\n" .
      "MYENV2: " . getenv('MYENV2') . "\n" .
      "MYSECRETENV: " . getenv('MYSECRETENV') . "\n";
?>