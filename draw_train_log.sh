#!/bin/bash

OUTFILE="train.png"

rm -f $OUTFILE
gnuplot draw_train_log.gnuplot
