#!/usr/bin/awk -f
################################################################
#     unexported_symbols.awk
#
# Called by unexported_symbols.sh , though can be used like this:
#
# lipo -extract arm64 OptimizelySDKiOS -output OptimizelySDKiOS-arm64
# nm -g OptimizelySDKiOS-arm64 > OptimizelySDKiOS-arm64.txt
# ./UnexportedSymbols.awk < OptimizelySDKiOS-arm64.txt > UnexportedSymbols.txt
################################################################
{
    if ((NF == 3) \
        && ($3 !~ /^.*OPTLY.*$/) \
        && ($3 !~ /^.*Optimizely.*$/) \
        && ($3 !~ /^.*optly.*$/)) {
        print $3;
    }
}
