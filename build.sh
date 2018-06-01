#!/bin/bash

hugo
rm -rf ../a8uhnf.github.io/public
cp -a public/. ../a8uhnf.github.io/
