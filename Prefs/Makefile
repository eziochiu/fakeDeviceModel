include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = FakeDeviceModelPrefs

FakeDeviceModelPrefs_FILES = ECRootListController.m ECAppListController.m ECDeviceListController.m
FakeDeviceModelPrefs_INSTALL_PATH = /Library/PreferenceBundles
FakeDeviceModelPrefs_FRAMEWORKS = UIKit
FakeDeviceModelPrefs_PRIVATE_FRAMEWORKS = Preferences
FakeDeviceModelPrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs
FakeDeviceModelPrefs_LIBRARIES = applist
FakeDeviceModelPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/$(BUNDLE_NAME).plist$(ECHO_END)
