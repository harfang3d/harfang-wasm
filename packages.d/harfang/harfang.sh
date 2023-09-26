#!/bin/bash

export SDKROOT=${SDKROOT:-/opt/python-wasm-sdk}
export CONFIG=${CONFIG:-$SDKROOT/config}


. ${CONFIG}

echo "

    * building Harfang3D for ${CIVER}, PYBUILD=$PYBUILD => CPython${PYMAJOR}.${PYMINOR}
            PYBUILD=$PYBUILD
            EMFLAVOUR=$EMFLAVOUR
            SDKROOT=$SDKROOT
            SYS_PYTHON=${SYS_PYTHON}

" 1>&2




mkdir -p src
pushd $(pwd)/src
    if [ -d harfang ]
    then
        pushd $(pwd)/harfang
        git restore .
        git pull
    else
        git clone --no-tags --depth 1 --single-branch --branch main https://github.com/harfang3d/harfang3d harfang
        pushd $(pwd)/harfang
        git submodule update --init --recursive
        git clone --depth 1 https://github.com/ejulien/FABGen fabgen

        echo "


    applying patches


"
        cat ${ROOT}/packages.d/harfang/patches.emsdk/*.diff | patch -p1
    fi

    # https://github.com/harfang3d/harfang3d/pull/20 has been merged
    # wget -O- https://patch-diff.githubusercontent.com/raw/harfang3d/harfang3d/pull/20.diff | patch -p1

    # merged
    # wget -O- https://patch-diff.githubusercontent.com/raw/harfang3d/harfang3d/pull/38.diff | patch -p1

    export HG_SRC_DIR=$(pwd)

    FABGEN=$HG_SRC_DIR/fabgen
    sed -i 's|error|warning|g' ${HG_SRC_DIR}/extern/cmft/src/cmft/common/platform.h

    VERSION=$(cat harfang/version.txt)
popd
popd


mkdir -p build/harfang

pushd build/harfang

if which cmake
then
    echo "
    * using local cmake
" 1>&2
else
    $SYS_PYTHON -m pip install cmake
fi

# $SYS_PYTHON -m pip install pypeg2
/opt/python-wasm-sdk/python3-wasm -m pip install pypeg2

. ${SDKROOT}/emsdk/emsdk_env.sh
export EMSDK_PYTHON=$SYS_PYTHON


emcmake cmake $HG_SRC_DIR \
 -DCMAKE_INSTALL_PREFIX=$PREFIX \
 -DHG_CPPSDK_PATH=${PREFIX} \
 -DHG_FABGEN_PATH=${FABGEN} \
 -DHG_GRAPHIC_API=GLES \
 -DHG_USE_GLFW=OFF \
 -DHG_BUILD_GLTF_EXPORTER=OFF \
 -DHG_BUILD_GLTF_IMPORTER=OFF \
 -DHG_BUILD_SPHERICAL_HARMONICS_EXTRACTOR=OFF \
 -DHG_BUILD_ASSETC=OFF \
 -DHG_ENABLE_OPENVR_API=OFF \
 -DHG_ENABLE_OPENXR_API=OFF \
 -DHG_ENABLE_BULLET3_SCENE_PHYSICS=OFF \
 -DHG_BUILD_ASSIMP_CONVERTER=OFF \
 -DHG_BUILD_FBX_CONVERTER=OFF \
 -DHG_BUILD_TESTS=OFF \
 -DHG_BUILD_ASSETC=OFF \
 -DHG_BUILD_HG_LUA=OFF \
 -DHG_BUILD_CPP_SDK=OFF \
 -DHG_BUILD_HARFANG_STATIC=ON \
 -DHG_BUILD_HG_PYTHON:BOOL=ON \
    -DPython3_EXECUTABLE:FILEPATH=${SDKROOT}/python3-wasm \
    -DPython3_INCLUDE_DIR=${SDKROOT}/devices/emsdk/usr/include/python${PYBUILD} \
    -DPython3_LIBRARY=${SDKROOT}/devices/emsdk/usr/lib \
    -DPython3_FOUND=TRUE \
    -DPython3_Development_FOUND=TRUE \
    -DPython3_Development.Module_FOUND=TRUE \
    -DPython3_Development.Embed_FOUND=TRUE \


# cannot use -fno-exceptions
if EMCC_CFLAGS="-sDISABLE_EXCEPTION_CATCHING=1 -fno-rtti -DBX_CONFIG_DEBUG=0 -I${SDKROOT}/devices/emsdk/usr/include/python${PYBUILD} -Wno-unused-command-line-argument -lopenal" make -j4
then
    HG=$(pwd)

    LINKALL=""

    for lib in $(find ${HG}/extern| grep lib.*.a$|grep -v stb_vorbis)
    do
        LINKALL="$LINKALL $lib"
    done

    for lib in\
      harfang/foundation/libfoundation.a\
      harfang/platform/libplatform.a\
      harfang/script/libscript.a\
      harfang/engine/libengine.a
    do
        LINKALL="$LINKALL ${HG}/$lib"
    done

    LD_HARFANG="-lopenal -lSDL2 $LINKALL"

#    if [ -d $HG_SRC_DIR/wasm_test ]
#    then
#        cd $HG_SRC_DIR/wasm_test
#        echo "
#        *   building cpp test :
#http://localhost:8000/archives/${PYGBAG_BUILD}/harfang_cpptest.html
#" 1>&2


#        em++ \
#         -sUSE_WEBGL2 \
#         -sALLOW_MEMORY_GROWTH \
#         -I${HG_SRC_DIR}/harfang \
#         -I${HG_SRC_DIR}/extern \
#         -I${HG_SRC_DIR}/extern/bgfx/bgfx/include \
#         -I${HG_SRC_DIR}/extern/bgfx/bimg/include \
#         -o $DIST_DIR/harfang_cpptest.html app.cpp mdl_gles_fsb.cpp mdl_gles_vsb.cpp $LD_HARFANG

#    fi


    lib=languages/hg_python/harfang.a
    LINKALL="$LINKALL ${HG}/$lib"

    echo "

Linking ${VERSION}:
    $LINKALL
Into : ${SDKROOT}/prebuilt/emsdk/libharfang${PYBUILD}.a

" 1>&2
    emcc -r -Wl,--whole-archive -o libharfang${PYBUILD}.o $LINKALL
    emar cr ${SDKROOT}/prebuilt/emsdk/libharfang${PYBUILD}.a libharfang${PYBUILD}.o

    du -hs ${SDKROOT}/prebuilt/emsdk/libharfang${PYBUILD}.a


else
    echo build failed
    exit 66
fi

popd

EMPIC=${SDKROOT}/emsdk/upstream/emscripten/cache/sysroot/lib/wasm32-emscripten/pic
SDL2="-sUSE_ZLIB=1 -sUSE_BZIP2=1 -sUSE_LIBPNG -sUSE_SDL=2 -sUSE_SDL_MIXER=2 -lSDL2 -L${SDKROOT}/devices/emsdk/usr/lib -lSDL2_image -lSDL2_gfx -lSDL2_mixer -lSDL2_mixer_ogg -lSDL2_ttf -lvorbis -logg -lwebp -ljpeg -lpng -lharfbuzz -lfreetype"
SDL2="$SDL2 -lssl -lcrypto -lffi -lbz2 -lz -ldl -lm"


if [ -d testing/harfang-${VERSION}-cp32-abi3-wasm32_mvp_emscripten ]
then
    TARGET_FOLDER=$(pwd)/testing/harfang-${VERSION}-cp32-abi3-wasm32_${WASM_FLAVOUR}_emscripten
    TARGET_FILE=${TARGET_FOLDER}/harfang/harfang.so

    mkdir -p $TARGET_FOLDER
    /bin/cp -rf testing/harfang-${VERSION}-cp32-abi3-wasm32_mvp_emscripten/. ${TARGET_FOLDER}/

    mkdir -p build/web/archives/repo/pkg



    emcc -Os -g0 -shared -fpic -o ${TARGET_FILE} \
     /opt/python-wasm-sdk/prebuilt/emsdk/libharfang${PYBUILD}.a $SDL2

    [ -f ${TEST_FILE}.map ] && rm ${TEST_FILE}.map
    pushd testing/harfang-${VERSION}-cp32-abi3-wasm32_${WASM_FLAVOUR}_emscripten
    if [ -d /data/git/archives/repo ]
    then
        whl=/data/git/archives/repo/pkg/$(basename $(pwd)).whl
    else
        mkdir -p ${ROOT}/build/web/archives/repo/pkg
        whl=${ROOT}/build/web/archives/repo/pkg/$(basename $(pwd)).whl
    fi
    [ -f $whl ] && rm $whl
    zip $whl -r .
    popd

fi



