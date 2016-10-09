#!/bin/sh
# build.sh

GLOBAL_OUTDIR="`pwd`/dependencies"
LOCAL_OUTDIR="./outdir"
LEPTON_LIB="`pwd`/leptonica-1.69"
TESSERACT_LIB="`pwd`/tesseract-ocr"

IOS_BASE_SDK="9.3"
IOS_DEPLOY_TGT="8.0"

setenv_all()
{
  # Add internal libs
  export CFLAGS="$CFLAGS -I$GLOBAL_OUTDIR/include -L$GLOBAL_OUTDIR/lib"
  
  export CXX="/usr/bin/llvm-g++"
  export CC="/usr/bin/llvm-gcc"

  export LD=/usr/bin/ld
  export AR=/usr/bin/ar
  export AS=/usr/bin/as
  export NM=/usr/bin/nm
  export RANLIB=/usr/bin/ranlib
  export LDFLAGS="-L$SDKROOT/usr/lib/"
  
  export CPPFLAGS=$CFLAGS
  export CXXFLAGS=$CFLAGS
}

setenv_arm7()
{
  unset DEVROOT SDKROOT CFLAGS CC LD CPP CXX AR AS NM CXXCPP RANLIB LDFLAGS CPPFLAGS CXXFLAGS
  
  export DEVROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer
  export SDKROOT=$DEVROOT/SDKs/iPhoneOS$IOS_BASE_SDK.sdk
  
  export CFLAGS="-arch armv7 -fembed-bitcode-marker -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT -I$SDKROOT/usr/include/"
  
  setenv_all
}

setenv_arm7s()
{
  unset DEVROOT SDKROOT CFLAGS CC LD CPP CXX AR AS NM CXXCPP RANLIB LDFLAGS CPPFLAGS CXXFLAGS
  
  export DEVROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer
  export SDKROOT=$DEVROOT/SDKs/iPhoneOS$IOS_BASE_SDK.sdk
  
  export CFLAGS="-arch armv7s -fembed-bitcode-marker -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT -I$SDKROOT/usr/include/"
  
  setenv_all
}

setenv_arm64()
{
unset DEVROOT SDKROOT CFLAGS CC LD CPP CXX AR AS NM CXXCPP RANLIB LDFLAGS CPPFLAGS CXXFLAGS

export DEVROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer
export SDKROOT=$DEVROOT/SDKs/iPhoneOS$IOS_BASE_SDK.sdk

export CFLAGS="-arch arm64 -fembed-bitcode-marker -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT -I$SDKROOT/usr/include/"

setenv_all
}

setenv_i386()
{
  unset DEVROOT SDKROOT CFLAGS CC LD CPP CXX AR AS NM CXXCPP RANLIB LDFLAGS CPPFLAGS CXXFLAGS
  
  export DEVROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer
  export SDKROOT=$DEVROOT/SDKs/iPhoneSimulator$IOS_BASE_SDK.sdk
  
  export CFLAGS="-arch i386 -fembed-bitcode-marker -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT"
  
  setenv_all
}

create_outdir_lipo()
{
  for lib_i386 in `find $LOCAL_OUTDIR/i386 -name "lib*.a"`; do
    lib_arm7=`echo $lib_i386 | sed "s/i386/arm7/g"`
    lib_arm7s=`echo $lib_i386 | sed "s/i386/arm7s/g"`
    lib_arm64=`echo $lib_i386 | sed "s/i386/arm64/g"`
    lib=`echo $lib_i386 | sed "s/i386//g"`
    xcrun -sdk iphoneos lipo -arch arm64 $lib_arm64 -arch armv7s $lib_arm7s -arch armv7 $lib_arm7 -arch i386 $lib_i386 -create -output $lib
  done
}

merge_libfiles()
{
  DIR=$1
  LIBNAME=$2
  
  cd $DIR
  for i in `find . -name "lib*.a"`; do
    $AR -x $i
  done
  $AR -r $LIBNAME *.o
  rm -rf *.o __*
  cd -
}


#######################
# LEPTONLIB
#######################
cd $LEPTON_LIB
rm -rf $LOCAL_OUTDIR
mkdir -p $LOCAL_OUTDIR/arm7 $LOCAL_OUTDIR/i386 $LOCAL_OUTDIR/arm7s $LOCAL_OUTDIR/arm64

make clean 2> /dev/null
make distclean 2> /dev/null

setenv_arm64
./configure --host=arm-apple-darwin7 --enable-shared=no --disable-programs --without-zlib --without-libpng --without-jpeg --without-giflib --without-libtiff
make -j12
cp -rvf src/.libs/lib*.a $LOCAL_OUTDIR/arm64


make clean 2> /dev/null
make distclean 2> /dev/null

setenv_arm7
./configure --host=arm-apple-darwin7 --enable-shared=no --disable-programs --without-zlib --without-libpng --without-jpeg --without-giflib --without-libtiff
make -j12
cp -rvf src/.libs/lib*.a $LOCAL_OUTDIR/arm7

make clean 2> /dev/null
make distclean 2> /dev/null
setenv_arm7s
./configure --host=arm-apple-darwin7s --enable-shared=no --disable-programs --without-zlib --without-libpng --without-jpeg --without-giflib --without-libtiff
make -j12
cp -rvf src/.libs/lib*.a $LOCAL_OUTDIR/arm7s

make clean 2> /dev/null
make distclean 2> /dev/null
setenv_i386
./configure --enable-shared=no --disable-programs --without-zlib --without-libpng --without-jpeg --without-giflib --without-libtiff
make -j12
cp -rvf src/.libs/lib*.a $LOCAL_OUTDIR/i386

create_outdir_lipo
mkdir -p $GLOBAL_OUTDIR/include/leptonica && cp -rvf src/*.h $GLOBAL_OUTDIR/include/leptonica
mkdir -p $GLOBAL_OUTDIR/lib && cp -rvf $LOCAL_OUTDIR/lib*.a $GLOBAL_OUTDIR/lib
cd ..


#######################
# TESSERACT-OCR (v3)
#######################
cd $TESSERACT_LIB
rm -rf $LOCAL_OUTDIR
mkdir -p $LOCAL_OUTDIR/arm7 $LOCAL_OUTDIR/i386 $LOCAL_OUTDIR/arm7s $LOCAL_OUTDIR/arm64


make clean 2> /dev/null
make distclean 2> /dev/null
setenv_arm64
bash autogen.sh
./configure --host=arm-apple-darwin7 --enable-shared=no LIBLEPT_HEADERSDIR=$GLOBAL_OUTDIR/include/
make -j12
for i in `find . -name "lib*.a" | grep -v arm`; do cp -rvf $i $LOCAL_OUTDIR/arm64; done
merge_libfiles $LOCAL_OUTDIR/arm64 libtesseract_all.a


make clean 2> /dev/null
make distclean 2> /dev/null
setenv_arm7
bash autogen.sh
./configure --host=arm-apple-darwin7 --enable-shared=no LIBLEPT_HEADERSDIR=$GLOBAL_OUTDIR/include/
make -j12
for i in `find . -name "lib*.a" | grep -v arm`; do cp -rvf $i $LOCAL_OUTDIR/arm7; done
merge_libfiles $LOCAL_OUTDIR/arm7 libtesseract_all.a

make clean 2> /dev/null
make distclean 2> /dev/null
setenv_arm7s
bash autogen.sh
./configure --host=arm-apple-darwin7s --enable-shared=no LIBLEPT_HEADERSDIR=$GLOBAL_OUTDIR/include/
make -j12
for i in `find . -name "lib*.a" | grep -v arm`; do cp -rvf $i $LOCAL_OUTDIR/arm7s; done
merge_libfiles $LOCAL_OUTDIR/arm7s libtesseract_all.a

make clean 2> /dev/null
make distclean 2> /dev/null
setenv_i386
bash autogen.sh
./configure --enable-shared=no LIBLEPT_HEADERSDIR=$GLOBAL_OUTDIR/include/
make -j12

for i in `find . -name "lib*.a" | grep -v arm`; do cp -rvf $i $LOCAL_OUTDIR/i386; done
merge_libfiles $LOCAL_OUTDIR/i386 libtesseract_all.a

create_outdir_lipo
mkdir -p $GLOBAL_OUTDIR/include/tesseract
tess_inc=( api/apitypes.h api/baseapi.h ccmain/pageiterator.h ccmain/resultiterator.h  ccmain/ltrresultiterator.h ccmain/thresholder.h ccstruct/publictypes.h ccutil/errcode.h
    ccutil/unicharset.h ccutil/strngs.h ccutil/memry.h ccutil/unicharmap.h ccutil/genericvector.h ccutil/helpers.h ccutil/host.h ccutil/ndminx.h ccutil/ocrclass.h
    ccutil/platform.h ccutil/tesscallback.h ccutil/unichar.h )
for i in "${tess_inc[@]}"; do
   cp -rvf $i $GLOBAL_OUTDIR/include/tesseract
done
mkdir -p $GLOBAL_OUTDIR/lib && cp -rvf $LOCAL_OUTDIR/lib*.a $GLOBAL_OUTDIR/lib
make clean 2> /dev/null
make distclean 2> /dev/null
rm -rf $LOCAL_OUTDIR
cd ..

echo "Finished!"