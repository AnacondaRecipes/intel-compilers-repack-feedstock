#!/bin/bash
set -eux

# for subpackages, we have named our extracted locations according to the subpackage name
#    That's what this $PKG_NAME is doing - picking the right subfolder to rsync

src="${SRC_DIR}/${PKG_NAME}"

cp -av "${src}"/* "${PREFIX}/"

# special case to set up compilers with host prepended.
if [[ ${PKG_NAME} =~ dpcpp_impl_.* ]]; then
    pushd "${PREFIX}"/bin
        for file in *; do
            ln -sfv ${file} ${CHOST}-${file}
        done
    popd
fi

# replace old info folder with our new regenerated one
rm -rf "${PREFIX}/info"
