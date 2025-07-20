################################################################################
#
# neatvnc
#
################################################################################

WAYVNC_VERSION = 0.9.1
WAYVNC_SITE = $(call github,any1,wayvnc,v$(WAYVNC_VERSION))
WAYVNC_LICENSE = ISC
WAYVNC_LICENSE_FILES = COPYING
WAYVNC_DEPENDENCIES = host-pkgconf aml libdrm libxkbcommon neatvnc pixman jansson wayland

WAYVNC_CONF_OPTS = \
	-Dman-pages=disabled \
	-Dsystemtap=false \
	-Dtests=false

ifeq ($(BR2_PACKAGE_HAS_LIBGBM),y)
WAYVNC_CONF_OPTS += -Dscreencopy-dmabuf=enabled
WAYVNC_DEPENDENCIES += libgbm
else
WAYVNC_CONF_OPTS += -Dscreencopy-dmabuf=disabled
endif

ifeq ($(BR2_PACKAGE_LINUX_PAM),y)
WAYVNC_CONF_OPTS += -Dpam=enabled
WAYVNC_DEPENDENCIES += linux-pam
else
WAYVNC_CONF_OPTS += -Dpam=disabled
endif

$(eval $(meson-package))
