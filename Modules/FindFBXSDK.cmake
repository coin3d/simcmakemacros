# Input:
#   Environment variable "FBXSDKDIR" pointing to the base dir of
#   the FBX SDK installation. e.g. c:/Program Files/Autodesk/FBXSDK-2009.3
#
# Output:
#   FBXSDK_INCLUDE_DIR
#   FBXSDK_LIBRARIES
#   FBXSDK_FOUND
#   FBXSDK_DEFINES
#

SET(FBXSDKDIR $ENV{FBXSDKDIR})
SET(FBXSDK_FOUND FALSE)

IF (FBXSDKDIR)
  FIND_LIBRARY(FBXSDK_LIBRARY 
               NAMES fbxsdk_md2008 fbxsdk_gcc4_ub fbxsdk_gcc4 fbxsdk_gcc4d
               PATHS ${FBXSDKDIR}
               PATH_SUFFIXES lib
               NO_DEFAULT_PATH)
  FIND_PATH(FBXSDK_INCLUDE_DIR
            NAME fbxsdk.h 
            PATHS ${FBXSDKDIR} 
            PATH_SUFFIXES include 
            NO_DEFAULT_PATH)

  IF (FBXSDK_LIBRARY AND FBXSDK_INCLUDE_DIR)
    # OS-dependent configuration
    IF (WIN32)
      SET(FBXSDK_SYSTEM_LIBRARIES "advapi32.lib" "wininet.lib")
      SET(FBXSDK_DEFINES -DK_PLUGIN -DK_FBXSDK -DK_NODLL -DBOOST_MATH_TR1_NO_LIB)
    ELSEIF (APPLE)
      SET(FBXSDK_SYSTEM_LIBRARIES -liconv "-framework SystemConfiguration" "-framework CoreServices")
      SET(FBXSDK_DEFINES "")
    ELSE ()
      SET(FBXSDK_SYSTEM_LIBRARIES "")
      SET(FBXSDK_DEFINES "")
    ENDIF ()
    SET(FBXSDK_LIBRARIES ${FBXSDK_LIBRARY} ${FBXSDK_SYSTEM_LIBRARIES})
    SET(FBXSDK_FOUND TRUE)
    IF (NOT FBXSDK_FIND_QUIETLY)
      MESSAGE(STATUS "Found FBX SDK: ${FBXSDK_LIBRARY} with includes ${FBXSDK_INCLUDE_DIR}")
    ENDIF ()
  ELSE ()
    IF (FBXSDK_FIND_REQUIRED)
      MESSAGE(FATAL_ERROR "Could not find FBX SDK in ${FBXSDKDIR}")
    ELSE ()
      MESSAGE(STATUS "Could not find FBX SDK in ${FBXSDKDIR}")
    ENDIF ()
  ENDIF ()
ELSEIF (FBXSDK_FIND_REQUIRED)
  MESSAGE(FATAL_ERROR "Automatic find of FBX SDK not implemented. "
        "Set the environment variable FBXSDKDIR to point to the directory "
        "where the FBX SDK is located.")
ENDIF ()
