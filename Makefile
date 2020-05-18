export THEOS_DEVICE_IP = 192.168.50.144

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = fakeDeviceModel

SUBPROJECTS += Prefs

fakeDeviceModel_FILES = Tweak.x
fakeDeviceModel_CFLAGS = -fobjc-arc
fakeDeviceModel_FRAMEWORKS = UIKit
fakeDeviceModel_EXTRA_FRAMEWORKS = Cephei

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS)/makefiles/bundle.mk
include $(THEOS_MAKE_PATH)/aggregate.mk