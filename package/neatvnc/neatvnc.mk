################################################################################
#
# neatvnc
#
################################################################################

NEATVNC_VERSION = 0.9.4
NEATVNC_SITE = $(call github,any1,neatvnc,v$(NEATVNC_VERSION))
NEATVNC_LICENSE = ISC
NEATVNC_LICENSE_FILES = COPYING
NEATVNC_INSTALL_STAGING = YES
NEATVNC_DEPENDENCIES = host-pkgconf libdrm aml pixman zlib

NEATVNC_CONF_OPTS = \
	-Dbenchmarks=false \
	-Dexamples=false \
	-Dtests=false \
	-Dexperimental=false \
	-Dsystemtap=false

ifeq ($(BR2_PACKAGE_JPEG_TURBO),y)
NEATVNC_CONF_OPTS += -Djpeg=enabled
NEATVNC_DEPENDENCIES += jpeg-turbo
else
NEATVNC_CONF_OPTS += -Djpeg=disabled
endif

ifeq ($(BR2_PACKAGE_GNUTLS),y)
NEATVNC_CONF_OPTS += -Dtls=enabled
NEATVNC_DEPENDENCIES += gnutls
else
NEATVNC_CONF_OPTS += -Dtls=disabled
endif

ifeq ($(BR2_PACKAGE_NETTLE),y)
NEATVNC_CONF_OPTS += -Dnettle=enabled
NEATVNC_DEPENDENCIES += nettle
else
NEATVNC_CONF_OPTS += -Dnettle=disabled
endif

ifeq ($(BR2_PACKAGE_HAS_LIBGBM),y)
NEATVNC_CONF_OPTS += -Dgbm=enabled
NEATVNC_DEPENDENCIES += libgbm
else
NEATVNC_CONF_OPTS += -Dgbm=disabled
endif

ifeq ($(BR2_PACKAGE_FFMPEG),y)
NEATVNC_CONF_OPTS += -Dh264=enabled
NEATVNC_DEPENDENCIES += ffmpeg
else
NEATVNC_CONF_OPTS += -Dh264=disabled
endif

$(eval $(meson-package))
