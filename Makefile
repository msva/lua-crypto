# LibName and LibVersion
T= crypto
V= 0.3.0

CRYPTO_ENGINE= openssl
# Getting needed variables from OS
UNAME := $(shell uname)
LUA_LIBDIR= $(shell pkg-config --variable INSTALL_LMOD lua)
LUA_INC= $(shell pkg-config --variable INSTALL_INC lua)
LUA_VERSION_NUM= ${$(shell pkg-config --variable R lua)//.}


ifeq ($(CRYPTO_ENGINE), openssl)
LUACRYPTO_LIBS= -L$(shell pkg-config --variable libdir openssl) -lcrypto -lssl
LUACRYPTO_INCS= -I$(shell pkg-config --variable includedir openssl) -DCRYPTO_OPENSSL=1
endif
ifeq ($(CRYPTO_ENGINE), gcrypt)
LUACRYPTO_LIBS= $(shell libgcrypt-config --libs)
LUACRYPTO_INCS= $(shell libgcrypt-config --cflags) -DCRYPTO_GCRYPT=1
endif
ifeq ($(UNAME), Linux)
LIB_OPTION= -shared
endif
ifeq ($(UNAME), Darwin)
LIB_OPTION= -bundle -undefined dynamic_lookup
endif

# Compilation directives
WARN= -O2 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings
INCS= -I$(LUA_INC)
CC= gcc


OBJ= src/${T}.o
SRC= src/${T}.c
HDR= src/${T}.h
LIBNAME= ${T}.so.${V}
LIBPATH= src/${LIBNAME}

all: ${LIBPATH}

${OBJ}:
	$(CC) $(WARN) $(LUACRYPTO_INCS) $(INCS) $(CFLAGS) $(LDFLAGS) ${LIB_OPTION} -c -o ${OBJ} ${SRC}

${LIBPATH}: ${OBJ}
	@export MACOSX_DEPLOYMENT_TARGET="10.3";
	$(CC) $(WARN) $(LUACRYPTO_INCS) $(INCS) $(CFLAGS) $(LDFLAGS) ${LIB_OPTION} -o ${LIBPATH} ${OBJ} ${LUACRYPTO_LIBS}

install:
	mkdir -p $(LUA_LIBDIR)
	cp ${LIBPATH} $(LUA_LIBDIR)
	cd $(LUA_LIBDIR);
	ln -f -s ${LIBNAME} $T.so

clean:
	rm -f ${LIBPATH} ${OBJ}

uninstall: clean
	cd $(LUA_LIBDIR);
	rm -f ${LIBNAME} ${T}.so