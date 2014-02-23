set term png
set output "train.png"
plot "train.log" u 1:2 w lines
