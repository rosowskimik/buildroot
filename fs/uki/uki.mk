################################################################################
#
# UKI
#
################################################################################
ROOTFS_UKI_NAME = rootfs-uki
ROOTFS_UKI_TYPE = rootfs
ROOTFS_UKI_DEPENDENCIES = host-systemd systemd linux rootfs-cpio

.PHONY: rootfs-uki rootfs-uki-show-depends

rootfs-uki: rootfs-cpio
	@$(call MESSAGE,"Generating Unified Kernel Image")
	$(ROOTFS_UKI_SETUP_CMDLINE)
	$(ROOTFS_UKI_CONVERT_SPLASH)
	$(ROOTFS_UKI_BUILD_IMAGE)

rootfs-uki-show-depends:
	@echo systemd rootfs-cpio

ifeq ($(BR2_TARGET_ROOTFS_UKI),y)
TARGETS_ROOTFS += rootfs-uki
endif

ROOTFS_UKI_IMAGE_NAME = $(patsubst %.efi,%,$(LINUX_IMAGE_NAME)).uki.efi
ROOTFS_UKI_BUILD_OPTS = \
	--linux $(BINARIES_DIR)/$(LINUX_IMAGE_NAME) \
	--initrd $(BINARIES_DIR)/rootfs.cpio$(ROOTFS_CPIO_COMPRESS_EXT) \
	--stub $(BINARIES_DIR)/sd-stub.efi \
	--os-release @$(TARGET_DIR)/etc/os-release \
	--efi-arch $(SYSTEMD_STUB_EFI_ARCH) \
	--uname $(LINUX_VERSION_PROBED) \
	--output $(BINARIES_DIR)/$(ROOTFS_UKI_IMAGE_NAME)

ROOTFS_UKI_CMDLINE_FILE = $(call qstrip,$(BR2_TARGET_ROOTFS_UKI_CMDLINE_FILE))
ROOTFS_UKI_CMDLINE = $(call qstrip,$(BR2_TARGET_ROOTFS_UKI_CMDLINE))
ifneq ($(ROOTFS_UKI_CMDLINE_FILE)$(ROOTFS_UKI_CMDLINE),)
ROOTFS_UKI_BUILD_OPTS += --cmdline @$(BINARIES_DIR)/uki.cmdline

define ROOTFS_UKI_SETUP_CMDLINE
	$(if $(and $(ROOTFS_UKI_CMDLINE_FILE),$(ROOTFS_UKI_CMDLINE)), \
		cp $(ROOTFS_UKI_CMDLINE_FILE) $(BINARIES_DIR)/uki.cmdline; \
		printf " %s" "$(ROOTFS_UKI_CMDLINE)" >> $(BINARIES_DIR)/uki.cmdline, \
	$(if $(ROOTFS_UKI_CMDLINE_FILE), \
		cp $(ROOTFS_UKI_CMDLINE_FILE) $(BINARIES_DIR)/uki.cmdline, \
	$(if $(ROOTFS_UKI_CMDLINE), \
		printf " %s" "$(ROOTFS_UKI_CMDLINE)" >> $(BINARIES_DIR)/uki.cmdline, \
	)))
endef
endif

ROOTFS_UKI_SPLASH_IMAGE = $(call qstrip,$(BR2_TARGET_ROOTFS_UKI_SPLASH_IMAGE))
ifneq ($(ROOTFS_UKI_SPLASH_IMAGE),)
ROOTFS_UKI_DEPENDENCIES += host-imagemagick
ROOTFS_UKI_BUILD_OPTS += --splash $(BINARIES_DIR)/splash.bmp

define ROOTFS_UKI_CONVERT_SPLASH
	$(HOST_DIR)/bin/convert \
		$(ROOTFS_UKI_SPLASH_IMAGE) \
		-type TrueColor -define bmp:format=bmp3 \
		$(BINARIES_DIR)/splash.bmp
endef
endif

define ROOTFS_UKI_BUILD_IMAGE
	$(HOST_DIR)/bin/python3 \
		$(HOST_DIR)/lib/systemd/ukify build \
		$(ROOTFS_UKI_BUILD_OPTS)
endef

ifeq ($(BR2_TARGET_ROOTFS_UKI_DEVICETREE),y)
ROOTFS_UKI_DTBS = $(addsuffix .dtb,$(LINUX_DTS_NAME))
ROOTFS_UKI_BUILD_OPTS += \
	$(foreach dtb,$(ROOTFS_UKI_DTBS), \
		--devicetree \
		$(BINARIES_DIR)/$(if $(BR2_LINUX_KERNEL_DTB_KEEP_DIRNAME),$(dtb),$(notdir $(dtb))) \
	)
endif

ifeq ($(BR2_TARGET_ROOTFS_UKI_NEED_ZBOOT),y)
define ROOTFS_UKI_LINUX_ENABLE_ZBOOT
	$(call KCONFIG_ENABLE_OPT,CONFIG_EFI_ZBOOT)
endef
endif

define ROOTFS_UKI_LINUX_CONFIG_FIXUPS
	$(call KCONFIG_ENABLE_OPT,CONFIG_EFI)
	$(call KCONFIG_ENABLE_OPT,CONFIG_EFI_STUB)
	$(ROOTFS_UKI_LINUX_ENABLE_ZBOOT)
endef
