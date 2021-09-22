#!/bin/bash

set -exuo pipefail

src="${SRC_DIR}/${PKG_NAME}"

CBUILD=$(${PREFIX}/bin/icx -dumpmachine | sed "s/unknown/conda/")
CHOST=$(${PREFIX}/bin/icx -dumpmachine | sed "s/unknown/conda/")

FINAL_CFLAGS="-Wformat -Wformat-security -O3 -fp-model strict -fomit-frame-pointer -xSSE4.2 -axCORE-AVX2,COMMON-AVX512 -fPIC -fstack-protector-all -fno-plt -ftree-vectorize -ffunction-sections -pipe"
FINAL_DEBUG_CFLAGS="-Wformat -Wformat-security -O0g -g -fp-model strict -fomit-frame-pointer -xSSE4.2 -axCORE-AVX2,COMMON-AVX512 -fPIC -fstack-protector-all -fno-plt -ftree-vectorize -ffunction-sections -pipe"
FINAL_CPPFLAGS="-DNDEBUG -D_FORTIFY_SOURCE=2"
FINAL_DEBUG_CPPFLAGS="-D_DEBUG -D_FORTIFY_SOURCE=2 -Og"
FINAL_CXXFLAGS="-std=c++17 -Wformat -Wformat-security -O3 -fp-model strict -fomit-frame-pointer -xSSE4.2 -axCORE-AVX2,COMMON-AVX512 -fPIC -fstack-protector-all"
FINAL_DEBUG_CXXFLAGS="-std=c++17 -Wformat -Wformat-security -O0g -g -fp-model strict -fomit-frame-pointer -xSSE4.2 -axCORE-AVX2,COMMON-AVX512 -fPIC -fstack-protector-all"
FINAL_LDFLAGS="-Wl,-O3 -Wl,--sort-common -Wl,--as-needed -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now -Wl,--disable-new-dtags -Wl,--gc-sections -fuse-ld=lld"
FINAL_LDFLAGS_LD="-O0g -g --sort-common --as-needed -z noexecstack -z relro -z now --disable-new-dtags --gc-sections -fuse-ld=lld"

# if [[ "$target_platform" == "$ctng_target_platform" ]]; then
#   export CONDA_BUILD_CROSS_COMPILATION=""
# else
#   export CONDA_BUILD_CROSS_COMPILATION="1"
# fi
# do not support cross compilation.
export CONDA_BUILD_CROSS_COMPILATION=""

pushd "${src}"

find . -name "*activate*.sh" -exec sed -i.bak "s|@CBUILD@|${CBUILD}|g"                                                              "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@CHOST@|${CHOST}|g"                                                                "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@CFLAGS@|${FINAL_CFLAGS}|g"                                                       "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@DEBUG_CFLAGS@|${FINAL_DEBUG_CFLAGS}|g"                                           "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@CPPFLAGS@|${FINAL_CPPFLAGS}|g"                                                    "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@DEBUG_CPPFLAGS@|${FINAL_DEBUG_CPPFLAGS}|g"                                        "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@CXXFLAGS@|${FINAL_CXXFLAGS}|g"                                                   "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@DEBUG_CXXFLAGS@|${FINAL_DEBUG_CXXFLAGS}|g"                                       "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@LDFLAGS@|${FINAL_LDFLAGS}|g"                                                     "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@LDFLAGS_LD@|${FINAL_LDFLAGS_LD}|g"                                               "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@CONDA_BUILD_CROSS_COMPILATION@|${CONDA_BUILD_CROSS_COMPILATION}|g"                "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@_PYTHON_SYSCONFIGDATA_NAME@|${FINAL_PYTHON_SYSCONFIGDATA_NAME}|g"                 "{}" \;

find . -name "*activate*.sh.bak" -exec rm "{}" \;

popd

# for subpackages, we have named our extracted locations according to the subpackage name
#    That's what this $PKG_NAME is doing - picking the right subfolder to rsync

cp -rv "${src}"/* "${PREFIX}/"

# replace old info folder with our new regenerated one
rm -rf "${PREFIX}/info"