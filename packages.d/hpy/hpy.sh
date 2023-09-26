#!/bin/bash

export SDKROOT=${SDKROOT:-/opt/python-wasm-sdk}
export CONFIG=${CONFIG:-$SDKROOT/config}


. ${CONFIG}

echo "

    * building HPy for ${CIVER}, PYBUILD=$PYBUILD => CPython${PYMAJOR}.${PYMINOR}
            PYBUILD=$PYBUILD
            EMFLAVOUR=$EMFLAVOUR
            SDKROOT=$SDKROOT
            SYS_PYTHON=${SYS_PYTHON}

" 1>&2




mkdir -p src
pushd $(pwd)/src

if [ -d hpy ]
then
    pushd $(pwd)/hpy
    git restore .
    git pull
else
    git clone --no-tags --depth 1 --single-branch --branch master https://github.com/hpyproject/hpy

    wget https://github.com/hpyproject/hpy/archive/refs/tags/0.9.0rc2.tar.gz
    tar xvfz 0.9.0rc2.tar.gz

    pushd $(pwd)/hpy
    # git submodule update --init --recursive

    echo "


    applying patches


"

        # cat ${ROOT}/packages.d/hpy/patches.emsdk/*.diff | patch -p1
fi

wget -O- https://patch-diff.githubusercontent.com/raw/pmp-p/hpy-pygbag/pull/1.diff | patch -p1

popd
popd


#mkdir -p build/hpy

pushd src/hpy

# build for host simulator
${HPY} setup.py install

# build for wasm
${SDKROOT}/python3-wasm setup.py install


# link static
. ${SDKROOT}/emsdk/emsdk_env.sh

    $SDKROOT/emsdk/upstream/emscripten/emar rcs /opt/python-wasm-sdk/prebuilt/emsdk/libhpy${PYMAJOR}.${PYMINOR}.a \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/debug/src/_debugmod.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/debug/src/autogen_debug_wrappers.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/debug/src/debug_ctx.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/debug/src/debug_ctx_cpython.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/debug/src/debug_handles.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/debug/src/dhqueue.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/debug/src/memprotect.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/debug/src/stacktrace.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/devel/src/runtime/argparse.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/devel/src/runtime/buildvalue.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/devel/src/runtime/ctx_bytes.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/devel/src/runtime/ctx_call.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/devel/src/runtime/ctx_capsule.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/devel/src/runtime/ctx_contextvar.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/devel/src/runtime/ctx_err.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/devel/src/runtime/ctx_eval.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/devel/src/runtime/ctx_listbuilder.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/devel/src/runtime/ctx_long.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/devel/src/runtime/ctx_module.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/devel/src/runtime/ctx_object.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/devel/src/runtime/ctx_tracker.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/devel/src/runtime/ctx_tuple.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/devel/src/runtime/ctx_tuplebuilder.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/devel/src/runtime/ctx_type.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/devel/src/runtime/format.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/devel/src/runtime/helpers.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/devel/src/runtime/structseq.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/trace/src/_tracemod.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/trace/src/autogen_trace_func_table.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/trace/src/autogen_trace_wrappers.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/trace/src/trace_ctx.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/universal/src/ctx.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/universal/src/ctx_meth.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/universal/src/ctx_misc.o \
 build/temp.wasm32-${WASM_FLAVOUR}-emscripten-cpython-311/hpy/universal/src/hpymodule.o

popd





