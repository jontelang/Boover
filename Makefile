export TARGET=:clang
ARCHS = armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = Boover
Boover_FILES = Tweak.xm
Boover_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += booverpreferences
include $(THEOS_MAKE_PATH)/aggregate.mk