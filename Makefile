TARGET := iphone:8.4:7.0
ARCHS := armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = NoScreenshotty
NoScreenshotty_FILES = Tweak.xm
NoScreenshotty_FRAMEWORKS = UIKit Foundation
NoScreenshotty_LIBRARIES = applist

include $(THEOS_MAKE_PATH)/tweak.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp Resources/* $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -name .DS_Store | xargs rm -rf$(ECHO_END)

after-install::
	install.exec "killall -9 SpringBoard"
