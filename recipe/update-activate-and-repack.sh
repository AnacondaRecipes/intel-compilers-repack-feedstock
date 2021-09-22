#!/bin/bash

set -exuo pipefail

src="${SRC_DIR}/${PKG_NAME}"

CBUILD=$(${PREFIX}/bin/icx -dumpmachine | sed "s/unknown/conda/")
CHOST=$(${PREFIX}/bin/icx -dumpmachine | sed "s/unknown/conda/")

FINAL_CFLAGS="-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe"
FINAL_DEBUG_CFLAGS="-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fvar-tracking-assignments -ffunction-sections -pipe"
FINAL_CPPFLAGS="-DNDEBUG -D_FORTIFY_SOURCE=2 -O2 -fuse-ld=lld"
FINAL_DEBUG_CPPFLAGS="-D_DEBUG -D_FORTIFY_SOURCE=2 -Og -fuse-ld=lld"
FINAL_CXXFLAGS="-fvisibility-inlines-hidden -std=c++17 -fmessage-length=0 -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe"
FINAL_DEBUG_CXXFLAGS="-fvisibility-inlines-hidden -std=c++17 -fmessage-length=0 -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fvar-tracking-assignments -ffunction-sections -pipe"
FINAL_LDFLAGS="-Wl,-O2 -Wl,--sort-common -Wl,--as-needed -Wl,-z,relro -Wl,-z,now -Wl,--disable-new-dtags -Wl,--gc-sections -fuse-ld=lld"
FINAL_LDFLAGS_LD="-O2 --sort-common --as-needed -z relro -z now --disable-new-dtags --gc-sections -fuse-ld=lld"

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