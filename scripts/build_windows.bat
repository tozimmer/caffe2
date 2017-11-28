:: #############################################################################
:: Example command to build on Windows.
:: #############################################################################

:: This script shows how one can build a Caffe2 binary for windows.

@echo off

SET ORIGINAL_DIR=%cd%
SET CAFFE2_ROOT=%~dp0%..

if NOT DEFINED CMAKE_BUILD_TYPE (
  set CMAKE_BUILD_TYPE=Release
)

if NOT DEFINED USE_CUDA (
  :: In default we use CUDA
  set USE_CUDA=ON
)

if NOT DEFINED CMAKE_GENERATOR (
  if DEFINED APPVEYOR_BUILD_WORKER_IMAGE (
    if "%APPVEYOR_BUILD_WORKER_IMAGE%" == "Visual Studio 2017" (
      set CMAKE_GENERATOR="Visual Studio 15 2017 Win64"
    ) else if "%APPVEYOR_BUILD_WORKER_IMAGE%" == "Visual Studio 2015" (
      set CMAKE_GENERATOR="Visual Studio 14 2015 Win64"
    ) else (
      echo "You made a programming error: unknown APPVEYOR_BUILD_WORKER_IMAGE:"
      echo %APPVEYOR_BUILD_WORKER_IMAGE%
      exit /b
    )
  ) else (
    :: In default we use win64 VS 2015.
    set CMAKE_GENERATOR="Visual Studio 14 2015 Win64"
  )
)

:: build_host_protoc.bat is not used, compiled version of protobuf is present (C:\bin C:\lib C:\include)
:: if not exist %CAFFE2_ROOT%\build_host_protoc\bin\protoc.exe call %CAFFE2_ROOT%\scripts\build_host_protoc.bat || goto :label_error

echo CAFFE2_ROOT=%CAFFE2_ROOT%
echo CMAKE_GENERATOR=%CMAKE_GENERATOR%
echo CMAKE_BUILD_TYPE=%CMAKE_BUILD_TYPE%

if not exist %CAFFE2_ROOT%\build mkdir %CAFFE2_ROOT%\build
cd %CAFFE2_ROOT%\build

:: Set up cmake. We will skip building the test files right now.
cmake .. ^
  -Wno-dev ^
  -G%CMAKE_GENERATOR% ^
  -DCMAKE_VERBOSE_MAKEFILE=1 ^
  -DBUILD_TEST=OFF ^
  -DBUILD_SHARED_LIBS=OFF ^
  -DCMAKE_BUILD_TYPE=%CMAKE_BUILD_TYPE% ^
  -DUSE_CUDA=%USE_CUDA% ^
  -DUSE_NNPACK=OFF ^
  -DUSE_GLOG=OFF ^
  -DUSE_GFLAGS=OFF ^
  -DUSE_LMDB=ON ^
  -DUSE_LEVELDB=OFF ^
  -DUSE_ROCKSDB=OFF ^
  -DUSE_OPENCV=OFF ^
  -DBUILD_SHARED_LIBS=OFF ^
  -DBUILD_PYTHON=ON ^
  -DBUILD_BINARY=OFF ^
  -DProtobuf_PROTOC_EXECUTABLE=%CAFFE2_ROOT%\\vs2015\\bin\\protoc.exe ^
  -DProtobuf_INCLUDE_DIR=%CAFFE2_ROOT%\\vs2015\\include ^
  -DProtobuf_LIBRARIES=%CAFFE2_ROOT%\\vs2015\\lib\\libprotobuf.lib ^
  -DProtobuf_PROTOC_LIBRARIES=%CAFFE2_ROOT%\\vs2015\\lib\\libprotoc.lib ^
  -DProtobuf_LITE_LIBRARIES=%CAFFE2_ROOT%\\vs2015\\lib\\libprotobuf-lite.lib ^
  -DEIGEN3_ROOT_DIR=%CAFFE2_ROOT%\\third_party\\eigen ^
  -DCUB_INCLUDE_DIR=%CAFFE2_ROOT%\\vs2015\\include ^
  -DLMDB_DIR=%CAFFE2_ROOT%\\vs2015 ^
  -DLEVELDB_ROOT=%CAFFE2_ROOT%\\vs2015 ^
  -DSNAPPY_ROOT_DIR=%CAFFE2_ROOT%\\vs2015 ^
  -DGLOG_ROOT_DIR=%CAFFE2_ROOT%\\vs2015 ^
  -DGFLAGS_ROOT_DIR=%CAFFE2_ROOT%\\vs2015 ^
  -Dpybind11_ROOT_DIR=%CAFFE2_ROOT%\\vs2015 ^
  || goto :label_error

:: Actually run the build
cmake --build . --config %CMAKE_BUILD_TYPE% || goto :label_error

echo "Caffe2 built successfully"
cd %ORIGINAL_DIR%
exit /b 0

:label_error
echo "Caffe2 building failed"
cd %ORIGINAL_DIR%
exit /b 1
