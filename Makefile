# Some functions for candiness-looking
err =						\
	@echo -e "\e[1;31m*\e[0m $(1)\e[0m";	\
	@exit 1;
inf =						\
	@echo -e "\e[1;32m*\e[0m $(1)\e[0m";
wrn =						\
	@echo -e "\e[1;33m*\e[0m $(1)\e[0m";
ext =						\
	@echo -e "\e[1;35m*\e[0m $(1)\e[0m";

# LibName and LibVersion
T= crypto
V= 0.3.1

CRYPTO_ENGINE := openssl
# Getting needed variables from OS
UNAME := $(shell uname)
DESTDIR := "/"
PKG_CONFIG := "pkg-config"
GCRYPT_CONFIG := "libgcrypt-config"
LUA_IMPL := "lua"
LUA_LIBDIR= ${DESTDIR}$(shell $(PKG_CONFIG) --variable INSTALL_CMOD $(LUA_IMPL))
LUA_CF= $(shell $(PKG_CONFIG) --cflags $(LUA_IMPL))


ifeq ($(CRYPTO_ENGINE), openssl)
LUACRYPTO_LD= -L$(shell $(PKG_CONFIG) --variable libdir openssl) -lcrypto -lssl
LUACRYPTO_CF= -I$(shell $(PKG_CONFIG) --variable includedir openssl) -DCRYPTO_OPENSSL=1
endif
ifeq ($(CRYPTO_ENGINE), gcrypt)
LUACRYPTO_LD= $(shell $(GCRYPT_CONFIG) --libs)
LUACRYPTO_CF= $(shell $(GCRYPT_CONFIG) --cflags) -DCRYPTO_GCRYPT=1
endif
ifeq ($(UNAME), Linux)
LIB_OPTION= -shared
endif
ifeq ($(UNAME), Darwin)
LIB_OPTION= -bundle -undefined dynamic_lookup
endif

# Compilation directives
OPTS= -O2 -fPIC -std=c99
CF= $(OPTS) $(CFLAGS) $(LUA_CF) $(LUACRYPTO_CF)
LF= $(LDFLAGS) $(LIB_OPTION) $(LUACRYPTO_LD)
CC := "gcc"


OBJ= src/${T}.o
SRC= src/${T}.c
HDR= src/${T}.h
LIBNAME= ${T}.so
LIBPATH= src/${LIBNAME}

all: ${LIBPATH}

${OBJ}:
	@$(call ext,"Object files compliling in progress...")
	@$(CC) $(CF) $(LF) -c -o ${OBJ} ${SRC}
	@$(call inf,"Object files compliling is done!")

${LIBPATH}: ${OBJ}
	@$(call ext,"Library compiling and linking...")
	@export MACOSX_DEPLOYMENT_TARGET="10.3";
	@$(CC) $(CF) $(LF) -o ${LIBPATH} ${OBJ}
	@$(call inf,"Library compiling and linking is done!")

install:
	@$(call ext,"Installing...")
	@mkdir -p $(LUA_LIBDIR)
	@cp -f ${LIBPATH} $(LUA_LIBDIR)
	@$(call inf,"Installing is done!")

clean:
	@$(call wrn,"Cleaning...")
	@rm -f ${LIBPATH} ${OBJ}
	@$(call inf,"Cleaning is done!")

uninstall: clean
	@$(call wrn,"Uninstalling...")
	@cd $(LUA_LIBDIR);
	@rm -f ${LIBNAME}
	@$(call inf,"Uninstalling is done!")
