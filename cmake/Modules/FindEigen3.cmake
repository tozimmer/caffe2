# - Try to find Eigen3
#
# The following variables are optionally searched for defaults
#  EIGEN3_ROOT_DIR:            Base directory where all Eigen3 components are found
#
# The following are set after configuration is done:
#  EIGEN3_INCLUDE_DIRS

include(FindPackageHandleStandardArgs)


find_path(EIGEN3_INCLUDE_DIRS NAMES Eigen/Eigen PATHS "${EIGEN3_ROOT_DIR}")

find_package_handle_standard_args(EIGEN3 DEFAULT_MSG EIGEN3_INCLUDE_DIRS)

if(EIGEN3_FOUND)
    set(EIGEN3_INCLUDE_DIRS ${EIGEN3_INCLUDE_DIRS})
    message(STATUS "Found Eigen3  (include: ${EIGEN3_INCLUDE_DIRS})")
    mark_as_advanced(EIGEN3_INCLUDE_DIRS EIGEN3_ROOT_DIR)
endif()
