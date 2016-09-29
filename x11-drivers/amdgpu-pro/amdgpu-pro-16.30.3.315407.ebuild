# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

MULTILIB_COMPAT=( abi_x86_{32,64} )
inherit eutils multilib-build unpacker

DESCRIPTION="Ati precompiled drivers for Radeon Evergreen (HD5000 Series) and newer chipsets"
HOMEPAGE="http://support.amd.com/en-us/kb-articles/Pages/AMDGPU-PRO-Beta-Driver-for-Vulkan-Release-Notes.aspx"
BUILD_VER=16.30.3-315407

SRC_URI="https://www2.ati.com/drivers/beta/${PN}_${BUILD_VER}.tar.xz"

RESTRICT="fetch strip"

IUSE="gles2 opencl +opengl vdpau +vulkan"

LICENSE="AMD GPL-2 QPL-1.0"
KEYWORDS=""
SLOT="1"

RDEPEND="
	>=app-eselect/eselect-opengl-1.0.7
	app-eselect/eselect-opencl
	sys-kernel/amdgpu-pro-dkms
	x11-libs/libX11[${MULTILIB_USEDEP}]
	x11-libs/libXext[${MULTILIB_USEDEP}]
	x11-libs/libXinerama[${MULTILIB_USEDEP}]
	x11-libs/libXrandr[${MULTILIB_USEDEP}]
	x11-libs/libXrender[${MULTILIB_USEDEP}]
	!x11drivers/ati-drivers
"

DEPEND="${RDEPEND}
	x11-proto/inputproto
	x11-proto/xf86miscproto
	x11-proto/xf86vidmodeproto
	x11-proto/xineramaproto
"

S="${WORKDIR}"

pkg_nofetch() {
	einfo "Please download"
	einfo "  - ${PN}_${BUILD_VER}.tar.xz" for Ubuntu 16.04
	einfo "from ${HOMEPAGE} and place them in ${DISTDIR}"
}

unpack_deb() {
	echo ">>> Unpacking ${1##*/} to ${PWD}"
	unpack $1
	unpacker ./data.tar*

	# Clean things up #458658.  No one seems to actually care about
	# these, so wait until someone requests to do something else ...
	rm -f debian-binary {control,data}.tar*
}

src_prepare() {
	default

	unpack_deb "./amdgpu-pro-driver/amdgpu-pro-core_${BUILD_VER}_amd64.deb"
	unpack_deb "./amdgpu-pro-driver/amdgpu-pro-graphics_${BUILD_VER}_amd64.deb"

	rm -rf ./lib

	if use opencl ; then
		if use amd64 ; then
			unpack_deb "./amdgpu-pro-driver/amdgpu-pro-clinfo_${BUILD_VER}_amd64.deb"

			unpack_deb "./amdgpu-pro-driver/amdgpu-pro-libopencl-dev_${BUILD_VER}_amd64.deb"
			unpack_deb "./amdgpu-pro-driver/amdgpu-pro-libopencl1_${BUILD_VER}_amd64.deb"
			unpack_deb "./amdgpu-pro-driver/amdgpu-pro-opencl-icd_${BUILD_VER}_amd64.deb"

			mkdir -p ./usr/lib64/OpenCL/vendors/amdgpu-pro
			cp -d ./usr/lib/x86_64-linux-gnu/amdgpu-pro/* ./usr/lib64/OpenCL/vendors/amdgpu-pro

			echo "/usr/lib64/OpenCL/vendors/amdgpu-pro/libamdocl64.so" > ./etc/OpenCL/vendors/amdocl64.icd
		fi
		unpack_deb "./amdgpu-pro-driver/amdgpu-pro-libopencl-dev_${BUILD_VER}_i386.deb"
		unpack_deb "./amdgpu-pro-driver/amdgpu-pro-libopencl1_${BUILD_VER}_i386.deb"
		unpack_deb "./amdgpu-pro-driver/amdgpu-pro-opencl-icd_${BUILD_VER}_i386.deb"

		mkdir -p ./usr/lib32/OpenCL/vendors/amdgpu-pro
		cp -d ./usr/lib/i386-linux-gnu/amdgpu-pro/* ./usr/lib32/OpenCL/vendors/amdgpu-pro

		echo "/usr/lib32/OpenCL/vendors/amdgpu-pro/libamdocl32.so" > ./etc/OpenCL/vendors/amdocl32.icd

		chmod -x ./etc/OpenCL/vendors/*
		rm -rf ./usr/lib
	fi

	if use vulkan ; then
		if use amd64 ; then
			unpack_deb "./amdgpu-pro-driver/amdgpu-pro-vulkan-driver_${BUILD_VER}_amd64.deb"

			mkdir -p ./usr/lib64/vulkan
			cp -d ./usr/lib/x86_64-linux-gnu/* ./usr/lib64/vulkan
			sed -i 's|/usr/lib/x86_64-linux-gnu|/usr/lib64/vulkan|g' ./etc/vulkan/icd.d/amd_icd64.json
		fi
		unpack_deb "./amdgpu-pro-driver/amdgpu-pro-vulkan-driver_${BUILD_VER}_i386.deb"

		mkdir -p ./usr/lib32/vulkan
		cp -d ./usr/lib/i386-linux-gnu/* ./usr/lib32/vulkan
		sed -i 's|/usr/lib/i386-linux-gnu|/usr/lib32/vulkan|g' ./etc/vulkan/icd.d/amd_icd32.json

		chmod -x ./etc/vulkan/icd.d/*
		rm -rf ./usr/lib
	fi

	if use opengl ; then
		if use amd64 ; then
			unpack_deb "./amdgpu-pro-driver/libgl1-amdgpu-pro-dev_${BUILD_VER}_amd64.deb"
			unpack_deb "./amdgpu-pro-driver/libgl1-amdgpu-pro-dri_${BUILD_VER}_amd64.deb"
			unpack_deb "./amdgpu-pro-driver/libgl1-amdgpu-pro-glx_${BUILD_VER}_amd64.deb"

			mkdir -p ./usr/lib64/opengl/amdgpu-pro/lib
			cp -dR ./usr/lib/x86_64-linux-gnu/amdgpu-pro/* ./usr/lib64/opengl/amdgpu-pro/lib
			mkdir -p ./usr/lib64/dri
			cp -dR ./usr/lib/x86_64-linux-gnu/dri/* ./usr/lib64/dri
		fi
		unpack_deb "./amdgpu-pro-driver/libgl1-amdgpu-pro-dev_${BUILD_VER}_i386.deb"
		unpack_deb "./amdgpu-pro-driver/libgl1-amdgpu-pro-dri_${BUILD_VER}_i386.deb"
		unpack_deb "./amdgpu-pro-driver/libgl1-amdgpu-pro-glx_${BUILD_VER}_i386.deb"

		mkdir -p ./usr/lib32/opengl/amdgpu-pro/lib
		cp -dR ./usr/lib/i386-linux-gnu/amdgpu-pro/* ./usr/lib32/opengl/amdgpu-pro/lib
		mkdir -p ./usr/lib32/dri
		cp -dR ./usr/lib/i386-linux-gnu/dri/* ./usr/lib32/dri

		rm -rf ./usr/lib
	fi

	if use gles2 ; then
		if use amd64 ; then
			unpack_deb "./amdgpu-pro-driver/libgles2-amdgpu-pro-dev_${BUILD_VER}_amd64.deb"
			unpack_deb "./amdgpu-pro-driver/libgles2-amdgpu-pro_${BUILD_VER}_amd64.deb"

			mkdir -p ./usr/lib64/opengl/amdgpu-pro/lib
			cp -d ./usr/lib/x86_64-linux-gnu/amdgpu-pro/* ./usr/lib64/opengl/amdgpu-pro/lib
		fi
		unpack_deb "./amdgpu-pro-driver/libgles2-amdgpu-pro-dev_${BUILD_VER}_i386.deb"
		unpack_deb "./amdgpu-pro-driver/libgles2-amdgpu-pro_${BUILD_VER}_i386.deb"

		mkdir -p ./usr/lib32/opengl/amdgpu-pro/lib
		cp -d ./usr/lib/i386-linux-gnu/amdgpu-pro/* ./usr/lib32/opengl/amdgpu-pro/lib

		rm -rf ./usr/lib
	fi

	if use vdpau ; then
		if use amd64 ; then
			unpack_deb "./amdgpu-pro-driver/libvdpau-amdgpu-pro_${BUILD_VER}_amd64.deb"

			mkdir -p ./usr/lib64/vdpau
			cp -d ./usr/lib/x86_64-linux-gnu/vdpau/* ./usr/lib64/vdpau
		fi
		#unpack_deb "./amdgpu-pro-driver/libvdpau-amdgpu-pro_${BUILD_VER}_i386.deb"

		rm -rf ./usr/lib
	fi

	if use amd64 ; then
		unpack_deb "./amdgpu-pro-driver/libdrm-amdgpu-pro-amdgpu1_${BUILD_VER}_amd64.deb"
		unpack_deb "./amdgpu-pro-driver/libdrm-amdgpu-pro-dev_${BUILD_VER}_amd64.deb"
		unpack_deb "./amdgpu-pro-driver/libdrm2-amdgpu-pro_${BUILD_VER}_amd64.deb"
		unpack_deb "./amdgpu-pro-driver/libegl1-amdgpu-pro-dev_${BUILD_VER}_amd64.deb"
		unpack_deb "./amdgpu-pro-driver/libegl1-amdgpu-pro_${BUILD_VER}_amd64.deb"
		unpack_deb "./amdgpu-pro-driver/libgbm-amdgpu-pro-dev_${BUILD_VER}_amd64.deb"
		unpack_deb "./amdgpu-pro-driver/libgbm1-amdgpu-pro_${BUILD_VER}_amd64.deb"

		unpack_deb "./amdgpu-pro-driver/xserver-xorg-video-amdgpu-pro_${BUILD_VER}_amd64.deb"

		mkdir -p ./usr/lib64/xorg/amdgpu-pro/{1.15,1.16,1.17,1.18}
		cp -dR ./usr/lib/x86_64-linux-gnu/amdgpu-pro/1.15/* ./usr/lib64/xorg/amdgpu-pro/1.15
		cp -dR ./usr/lib/x86_64-linux-gnu/amdgpu-pro/1.16/* ./usr/lib64/xorg/amdgpu-pro/1.16
		cp -dR ./usr/lib/x86_64-linux-gnu/amdgpu-pro/1.17/* ./usr/lib64/xorg/amdgpu-pro/1.17
		cp -dR ./usr/lib/x86_64-linux-gnu/amdgpu-pro/1.18/* ./usr/lib64/xorg/amdgpu-pro/1.18

		rm ./usr/lib/x86_64-linux-gnu/amdgpu-pro/xorg

		# Default to X.org 1.18
		ln -s ../../xorg/amdgpu-pro/1.18/modules/drivers    ./usr/lib64/opengl/amdgpu-pro/drivers
		ln -s ../../xorg/amdgpu-pro/1.18/modules/extensions ./usr/lib64/opengl/amdgpu-pro/extensions

		cp -d ./usr/lib/x86_64-linux-gnu/amdgpu-pro/gbm/* ./usr/lib64/opengl/amdgpu-pro/lib
		cp -d ./usr/lib/x86_64-linux-gnu/amdgpu-pro/*     ./usr/lib64/opengl/amdgpu-pro/lib

		rm -rf ./usr/share/X11
	fi
	unpack_deb "./amdgpu-pro-driver/libdrm-amdgpu-pro-amdgpu1_${BUILD_VER}_i386.deb"
	unpack_deb "./amdgpu-pro-driver/libdrm-amdgpu-pro-dev_${BUILD_VER}_i386.deb"
	unpack_deb "./amdgpu-pro-driver/libdrm2-amdgpu-pro_${BUILD_VER}_i386.deb"
	unpack_deb "./amdgpu-pro-driver/libegl1-amdgpu-pro-dev_${BUILD_VER}_i386.deb"
	unpack_deb "./amdgpu-pro-driver/libegl1-amdgpu-pro_${BUILD_VER}_i386.deb"
	unpack_deb "./amdgpu-pro-driver/libgbm-amdgpu-pro-dev_${BUILD_VER}_i386.deb"
	unpack_deb "./amdgpu-pro-driver/libgbm1-amdgpu-pro_${BUILD_VER}_i386.deb"

	mkdir -p ./usr/lib32/opengl/amdgpu-pro/lib
	cp -d ./usr/lib/i386-linux-gnu/amdgpu-pro/gbm/* ./usr/lib32/opengl/amdgpu-pro/lib
	cp -d ./usr/lib/i386-linux-gnu/amdgpu-pro/*     ./usr/lib32/opengl/amdgpu-pro/lib

	rm -rf ./usr/lib
	rm -rf ./amdgpu-pro-driver

	chmod -x ./etc/amd/*
	chmod -x ./etc/gbm/*
	chmod -x ./usr/share/X11/xorg.conf.d/*
}

src_install() {
	cp -dR -t "${D}" * || die "Install failed!"

	# Hack for libGL.so hardcoded directory path for amdgpu_dri.so
	if use amd64 ; then
		dosym ../../../lib64/dri/amdgpu_dri.so /usr/lib/x86_64-linux-gnu/dri/amdgpu_dri.so
	fi
	dosym ../../../lib32/dri/amdgpu_dri.so /usr/lib/i386-linux-gnu/dri/amdgpu_dri.so
}