#!/bin/bash

res=$(pidof oneko)
arr=( $res )
if [ ${#arr[@]} -ne 0 ];
then
    for i in "${arr[@]}"
    do
        `kill "$i"`
    done
fi