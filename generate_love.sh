#!/bin/bash

rm -rf build/
mkdir build

find . -iname "*.lua" -exec cp {} build/ \;
find . -iname "*.png" -exec cp {} build/ \;

pushd build/
zip -r jake.love *
popd
