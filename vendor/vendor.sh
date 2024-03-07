if echo $PACKAGES |grep -q harfang
then
    echo $PACKAGES
else
    # it is an abi3 module just use stable python
    export ABI3=true

    # build the mininimum
    export PACKAGES="emsdk harfang"

    # link the python module static to be sure all syms are solved.
    export STATIC=true
fi
export VENDOR=harfang
export LD_VENDOR="$LD_VENDOR -sUSE_GLFW=3 -sUSE_WEBGL2 -sMIN_WEBGL_VERSION=2 -sMAX_WEBGL_VERSION=2 -sFULL_ES2 -sFULL_ES3"
