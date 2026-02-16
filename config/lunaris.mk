# Additional props
PRODUCT_PRODUCT_PROPERTIES += \
    dalvik.vm.debug.alloc=0 \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.error.receiver.system.apps=com.google.android.gms \
    ro.setupwizard.enterprise_mode=1 \
    ro.atrace.core.services=com.google.android.gms,com.google.android.gms.ui,com.google.android.gms.persistent \
    ro.setupwizard.rotation_locked=true \
    ro.com.google.ime.theme_id=5 \
    ro.opa.eligible_device=true \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.network_required=false \
    ro.setupwizard.gservices_delay=-1 \
    ro.setupwizard.mode=OPTIONAL \
    setupwizard.feature.predeferred_enabled=false \
    drm.service.enabled=true \
    persist.sys.dun.override=0 \
    persist.sys.disable_rescue=true

# Disable touch video heatmap to reduce latency, motion jitter, and CPU usage
# on supported devices with Deep Press input classifier HALs and models
PRODUCT_PRODUCT_PROPERTIES += \
    ro.input.video_enabled=false

# Enable blur
TARGET_ENABLE_BLUR ?= true
ifeq ($(TARGET_ENABLE_BLUR),true)
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    ro.custom.blur.enable=true \
    persist.sysui.disableBlur=false \
    ro.surface_flinger.supports_background_blur=1
else
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    ro.custom.blur.enable=false \
    persist.sysui.disableBlur=true \
    ro.surface_flinger.supports_background_blur=0
endif

# Cloned app exemption
PRODUCT_COPY_FILES += \
    vendor/lineage/prebuilt/common/etc/sysconfig/preinstalled-packages-platform-crdroid-product.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/preinstalled-packages-platform-crdroid-product.xml

# ColumbusService
ifneq ($(TARGET_SUPPORTS_QUICK_TAP),false)
PRODUCT_PACKAGES += \
    ColumbusService
endif

# Use a generic profile based boot image by default
PRODUCT_USE_PROFILE_FOR_BOOT_IMAGE := true
PRODUCT_COPY_FILES += \
    art/build/boot/preloaded-classes:$(TARGET_COPY_OUT_SYSTEM)/etc/preloaded-classes

PRODUCT_DEX_PREOPT_BOOT_IMAGE_PROFILE_LOCATION := \
    art/build/boot/boot-image-profile.txt

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/etc/preloaded-classes

# Disable async MTE on a few processes
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    persist.arm64.memtag.app.com.android.se=off \
    persist.arm64.memtag.app.com.google.android.bluetooth=off \
    persist.arm64.memtag.app.com.android.nfc=off \
    persist.arm64.memtag.process.system_server=off

# Enable Material Design 3 Expressive
PRODUCT_PRODUCT_PROPERTIES += is_expressive_design_enabled=true

# Enable dex2oat64 to do dexopt
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    dalvik.vm.dex2oat64.enabled=true

# Dexopt
ART_BUILD_HOST_DEBUG := false
ART_BUILD_TARGET_DEBUG := false

ifeq ($(TARGET_BUILD_VARIANT),user)
    PRODUCT_SYSTEM_SERVER_DEBUG_INFO := false
    WITH_DEXPREOPT_DEBUG_INFO := false
endif

PRODUCT_PRODUCT_PROPERTIES += \
    pm.dexopt.downgrade_after_inactive_days=10 \
    dalvik.vm.enable_pr_dexopt=true \
    dalvik.vm.finalizer-timeout-ms=40000 \
    dalvik.vm.ps-min-first-save-ms=150000

PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.minidebuginfo=false \
    dalvik.vm.dex2oat-minidebuginfo=false

PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true
USE_DEX2OAT_DEBUG := false
OVERRIDE_DISABLE_DEXOPT_ALL := false
PRODUCT_SYSTEM_SERVER_COMPILER_FILTER := speed-profile

TARGET_OPTIMIZED_DEXOPT ?= false
ifeq ($(TARGET_OPTIMIZED_DEXOPT),true)
    PRODUCT_DEX_PREOPT_DEFAULT_COMPILER_FILTER := speed-profile
    PRODUCT_SYSTEM_EXT_PROPERTIES += \
        pm.dexopt.post-boot=speed-profile \
        pm.dexopt.first-boot=verify \
        pm.dexopt.boot-after-ota=verify \
        pm.dexopt.boot-after-mainline-update=verify \
        pm.dexopt.install=speed-profile \
        pm.dexopt.install-fast=speed-profile \
        pm.dexopt.install-bulk=speed-profile \
        pm.dexopt.install-bulk-secondary=speed \
        pm.dexopt.install-bulk-downgraded=speed \
        pm.dexopt.install-bulk-secondary-downgraded=speed \
        pm.dexopt.bg-dexopt=speed \
        pm.dexopt.ab-ota=speed-profile \
        pm.dexopt.inactive=verify \
        pm.dexopt.cmdline=speed \
        pm.dexopt.first-use=speed-profile \
        pm.dexopt.secondary=speed-profile \
        pm.dexopt.shared=speed \
        dalvik.vm.dex2oat-filter=speed \
        dalvik.vm.image-dex2oat-filter=speed \
        dalvik.vm.dex2oat-cpu-set=0,1,2,3,4,5,6 \
        dalvik.vm.dex2oat-threads=6

    PRODUCT_DEX_PREOPT_DEFAULT_FLAGS += \
        --compiler-filter=speed-profile

    $(call add-product-dex-preopt-module-config,services,--compiler-filter=speed)
    $(call add-product-dex-preopt-module-config,wifi-service,--compiler-filter=speed)
    $(call add-product-dex-preopt-module-config,framework,--compiler-filter=speed-profile)

endif

# Extra packages
PRODUCT_PACKAGES += \
    AxQuickLook \
    AxSandbox \
    AxThemeStore \
    BatteryStatsViewer \
    GameSpace \
    LMOFreeform \
    LMOFreeformSidebar \
    OmniJaws \
    OmniStyle

ifneq ($(TARGET_DISABLE_MATLOG),true)
PRODUCT_PACKAGES += \
    MatLog
endif

ifneq ($(TARGET_FACE_UNLOCK_SUPPORTED),false)
PRODUCT_PACKAGES += \
    FaceUnlock

PRODUCT_SYSTEM_EXT_PROPERTIES += \
    ro.face.sense_service=true

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.biometrics.face.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/android.hardware.biometrics.face.xml
endif

# DeviceAsWebcam
ifeq ($(TARGET_BUILD_DEVICE_AS_WEBCAM), true)
PRODUCT_PACKAGES += \
    DeviceAsWebcam

PRODUCT_VENDOR_PROPERTIES += \
    ro.usb.uvc.enabled=true
endif

PRODUCT_PRODUCT_PROPERTIES += \
    remote_provisioning.enable_rkpd=true \
    remote_provisioning.hostname=remoteprovisioning.googleapis.com

# sound
PRODUCT_PRODUCT_PROPERTIES += \
    audio.safemedia.bypass=1

PRODUCT_PRODUCT_PROPERTIES += \
    persist.sys.display_refresh_rates_list=$(TARGET_SUPPORTED_REFRESH_RATES)

# UDFPS properties
TARGET_CUSTOM_UDFPS ?= false
BYPASS_CHARGE_SUPPORTED ?= false
HBM_SUPPORTED ?= false
HBM_NODE ?= /sys/class/backlight/panel0-backlight/hbm_mode
USE_REALITY_ENGINE ?= false

PRODUCT_PRODUCT_PROPERTIES += \
    persist.sys.battery_bypass_supported=$(BYPASS_CHARGE_SUPPORTED) \
    persist.sys.hbmservice_file=$(HBM_NODE) \
    persist.display.reality.engine.enabled=$(USE_REALITY_ENGINE) \
    persist.sys.udfps.custom=$(TARGET_CUSTOM_UDFPS)

# Quick Switch (Pixel Launcher)
ifeq ($(WITH_GMS),true)
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    persist.sys.default_launcher=1 \
    persist.sys.quickswitch_pixel_shipped=1
else
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    persist.sys.default_launcher=0
endif

ifeq ($(SURFACE_FLINGER_BOOST),true)
PRODUCT_PRODUCT_PROPERTIES += \
    ro.surface_flinger.uclamp.min=135
endif

# Google Wallpaper Overlays
PRODUCT_PACKAGES += \
    WallpaperPicker2Overlay \
    WallpaperPicker2PixelOverlay

