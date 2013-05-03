#!/bin/sh

pid=$(pidof munged)
[ -n "$pid" ] && kill $pid
