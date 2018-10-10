#  vim: set ft=zsh

cpedit() {
   if (( ! ${+1} )); then
      echo "missing argument"
   fi
   if (( ! ${+KBUILD_OUTPUT} )); then
      echo  "\$KBUILD_OUTPUT not set ... run in devshell!"
   fi

   command mkdir $KBUILD_OUTPUT/../../work
   # if [[ -e $KBUILD_OUTPUT/../../work/$1 ]]; then
   #    read -p  "$KBUILD_OUTPUT/../../work/$1 exits.. continue? (y/N)" answer
   #    (( $answer != y )) && return
   # fi

   command cp --parent $1 $KBUILD_OUTPUT/../../work -v
   lnedit $1
}

lnedit() {
   if (( ! ${+1} )); then
      echo "missing argument"
   fi
   if (( ! ${+KBUILD_OUTPUT} )); then
      echo  "\$KBUILD_OUTPUT not set ... run in devshell!"
   fi

   if [[ ! -f $KBUILD_OUTPUT/../../work/$1 ]]; then
      echo  "$KBUILD_OUTPUT/../../work/$1 does not exits.. abort"
      return
   fi
   command ln $KBUILD_OUTPUT/../../work/$1 $1 -vsf
}

setup-python2() {
   # check $BBPATH

}

wait_deply_kernel() {
   TARGET_DIR=${TARGET_DIR-/home/slendl/yocto/ladekran-23/build/tmp/work/var_som_mx6-fslc-linux-gnueabi/linux-variscite/4.9.11-r1/build}
   TARGET_WAIT=${TARGET_DIR}/arch/arm/boot/uImage
   TARGET_DEPLOY=${TARGET_DEPLOY-$TARGET_WAIT}
   TARGET_BOARD=${TARGET_BOARD-imx6}
   while inotifywait -e modify ${TARGET_WAIT}; do
      scp ${=TARGET_DEPLOY} ${TARGET_BOARD}:/boot
      if (( ${+TARGET_MODULES} )); then
         # FIXME
         scp ${=TARGET_MODULES} ${TARGET_BOARD}:/lib/kernel/
      fi
      ssh ${TARGET_BOARD} /sbin/reboot
   done
}

prepare_sd_flash() {
   if (( ${+BBPATH} )); then
      YOCTO_ROOT=$BBPATH
   else
      echo "\$BBPATH not set ... taking $PWD"
      YOCTO_ROOT=$PWD
   fi
   MACHINE=${MACHINE-var-som-mx6}
   ROOTFS_DIR=${ROOTFS_DIR-/mnt/rootfs}
   IMAGE=${IMAGE-ladekran-base-image}

   if [ ! -d "$ROOTFS_DIR/opt/images/Yocto" ]; then
      echo $ROOTFS_DIR/opt/images/Yocto does not exist..
      return -1
   fi

   # Linux:
   sudo command cp -v ${YOCTO_ROOT}/tmp/deploy/images/${MACHINE}/uImage                      ${ROOTFS_DIR}/opt/images/Yocto/
   # U-boot:
   sudo command cp -v ${YOCTO_ROOT}/tmp/deploy/images/${MACHINE}/SPL-nand                    ${ROOTFS_DIR}/opt/images/Yocto/
   sudo command cp -v ${YOCTO_ROOT}/tmp/deploy/images/${MACHINE}/SPL-sd                      ${ROOTFS_DIR}/opt/images/Yocto/
   sudo command cp -v ${YOCTO_ROOT}/tmp/deploy/images/${MACHINE}/u-boot-${MACHINE}.img-sd    ${ROOTFS_DIR}/opt/images/Yocto/u-boot.img-sd
   sudo command cp -v ${YOCTO_ROOT}/tmp/deploy/images/${MACHINE}/u-boot-${MACHINE}.img-nand  ${ROOTFS_DIR}/opt/images/Yocto/u-boot.img-nand
   # File System:
   sudo command cp -v ${YOCTO_ROOT}/tmp/deploy/images/${MACHINE}/${IMAGE}-${MACHINE}.tar.gz ${ROOTFS_DIR}/opt/images/Yocto/rootfs.tar.gz
   sudo command cp -v ${YOCTO_ROOT}/tmp/deploy/images/${MACHINE}/${IMAGE}-${MACHINE}.ubi     ${ROOTFS_DIR}/opt/images/Yocto/rootfs.ubi
   # Device Tree:
   sudo command cp -v ${YOCTO_ROOT}/tmp/deploy/images/${MACHINE}/uImage-imx6*.dtb            ${ROOTFS_DIR}/opt/images/Yocto/
   # TODO sudo command rename without uImage-
   
   # sudo cp ${YOCTO_ROOT}/tmp/deploy/images/${MACHINE}/uImage-imx6dl-var-som-solo-vsc.dtb ${ROOTFS_DIR}/opt/images/Yocto/
   # sudo cp ${YOCTO_ROOT}/tmp/deploy/images/${MACHINE}/uImage-imx6dl-var-som.dtb ${ROOTFS_DIR}/opt/images/Yocto/
   # sudo cp ${YOCTO_ROOT}/tmp/deploy/images/${MACHINE}/uImage-imx6q-var-som.dtb ${ROOTFS_DIR}/opt/images/Yocto/
   # sudo cp ${YOCTO_ROOT}/tmp/deploy/images/${MACHINE}/uImage-imx6q-var-som-vsc.dtb ${ROOTFS_DIR}/opt/images/Yocto/
   # sudo cp ${YOCTO_ROOT}/tmp/deploy/images/${MACHINE}/uImage-imx6q-var-dart.dtb ${ROOTFS_DIR}/opt/images/Yocto/

   sync
}
