#!/bin/sh

cd src/ ; make BOOST=$1 BOOST_OPT=$2; cd ../

#cd src/ ; make ; cd ../

cd Weaver_SV/src/ ; make


