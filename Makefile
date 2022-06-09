ARCHS = arm64 arm64e
THEOS_DEVICE_IP = 192.168.0.253
TARGET := iphone:clang:14.4:14
INSTALL_TARGET_PROCESSES = SpringBoard
PACKAGE_VERSION = 2.0.6

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NotchBanners

NotchBanners_PRIVATE_FRAMEWORKS = UserNotificationsKit ToneLibrary SpringBoardFoundation DoNotDisturbKit DoNotDisturb
NotchBanners_FILES = $(shell find Sources/NotchBanners -name '*.swift') $(shell find Sources/NotchBannersC -name '*.m' -o -name '*.c' -o -name '*.mm' -o -name '*.cpp')
NotchBanners_SWIFTFLAGS = -ISources/NotchBannersC/include
NotchBanners_CFLAGS = -fobjc-arc -ISources/NotchBannersC/include

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += notchbanners
include $(THEOS_MAKE_PATH)/aggregate.mk
