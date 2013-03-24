include theos/makefiles/common.mk

BUNDLE_NAME = booverpreferences
booverpreferences_FILES = booverpreferences.mm
booverpreferences_INSTALL_PATH = /Library/PreferenceBundles
booverpreferences_FRAMEWORKS = UIKit
booverpreferences_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/booverpreferences.plist$(ECHO_END)
