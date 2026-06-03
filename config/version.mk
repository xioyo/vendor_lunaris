PRODUCT_VERSION_MAJOR = 16
PRODUCT_VERSION_MINOR = 0

# Increase Lunaris Version with each major release.
LUNARIS_VERSION := 3.11
LUNARIS_BUILD_TYPE ?= Community

ifeq ($(WITH_GMS),true)
LUNARIS_BUILD_VARIANT := GMS
else
LUNARIS_BUILD_VARIANT := VANILLA
endif

# Internal version
LINEAGE_VERSION := Lunaris-AOSP-$(LINEAGE_BUILD)-$(LUNARIS_BUILD_TYPE)-$(LUNARIS_VERSION)-$(LUNARIS_BUILD_VARIANT)-$(shell date -u +%Y%m%d%H)

# Display version
LINEAGE_DISPLAY_VERSION := v$(LUNARIS_VERSION)-$(shell date -u +%Y%m%d)

# LineageOS version properties
PRODUCT_PRODUCT_PROPERTIES += \
    ro.lunaris.build.version=$(LUNARIS_VERSION) \
    ro.lunaris.display.version=$(LINEAGE_DISPLAY_VERSION) \
    ro.lunaris.version=$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR) \
    ro.lunaris.package.type=$(LUNARIS_BUILD_VARIANT)-$(LUNARIS_BUILD_TYPE)
