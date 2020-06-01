export TARGET=iphone::11.2:11.0 #simulator:clang::11.0
export ARCHS = arm64 arm64e #x86_64
export DEBUG = 0

PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = aurorad
$(BUNDLE_NAME)_FILES = $(wildcard *.m)
$(BUNDLE_NAME)_FRAMEWORKS = CoreLocation
$(BUNDLE_NAME)_CODESIGN_FLAGS = -Sent.plist
$(BUNDLE_NAME)_CFLAGS = -fobjc-arc
$(BUNDLE_NAME)_DYNAMIC_LIBRARY = 0
$(BUNDLE_NAME)_INSTALL_PATH = /Library/Application Support/libaurora

include $(THEOS_MAKE_PATH)/bundle.mk

# i love you conrad
before-all::
	@if [ ! -f "$(THEOS_INCLUDE_PATH)/sys/kern_memorystatus.h" ]; then \
		mkdir -p "$(THEOS_INCLUDE_PATH)/sys"; \
		curl -s -o "$(THEOS_INCLUDE_PATH)/sys/kern_memorystatus.h" -L "http://www.opensource.apple.com/source/xnu/xnu-2782.1.97/bsd/sys/kern_memorystatus.h?txt"; \
	fi

after-aurorad-stage::
	$(ECHO_NOTHING)$(FAKEROOT) chown root:wheel $(THEOS_STAGING_DIR)/Library/LaunchDaemons/dev.ayden.ios.lib.sys.aurora.plist$(ECHO_END)

after-install::
	install.exec "launchctl stop dev.ayden.ios.lib.sys.aurora && launchctl start dev.ayden.ios.lib.sys.aurora"