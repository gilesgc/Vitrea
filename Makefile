INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Vitrea

Vitrea_FILES = Tweak.xm
Vitrea_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
