ARCHS = arm64 arm64e
TARGET := iphone:clang:14.4:14

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = notchbanners

notchbanners_LIBRARIES = gscommon
notchbanners_FILES = $(shell find Sources/notchbanners -name '*.swift') $(shell find Sources/notchbannersC -name '*.m' -o -name '*.c' -o -name '*.mm' -o -name '*.cpp')
notchbanners_INSTALL_PATH = /Library/PreferenceBundles
notchbanners_SWIFTFLAGS = -ISources/notchbannersC/include
notchbanners_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
