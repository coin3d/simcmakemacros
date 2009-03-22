SET(SMALLCHANGEDIR $ENV{SMALLCHANGEDIR})

SET(SmallChange_LIBRARY_NAMES SmallChange SmallChange1 SmallChange1s SmallChange1d)

IF(SMALLCHANGEDIR)

  # Look for SmallChange in environment variable SMALLCHANGEDIR
  FIND_LIBRARY(SmallChange_LIBRARY NAMES ${SmallChange_LIBRARY_NAMES} PATHS ${SMALLCHANGEDIR} PATH_SUFFIXES src bin lib lib/SmallChange . NO_DEFAULT_PATH)
  FIND_PATH(SmallChange_INCLUDE_DIR SmallChange/misc/Init.h PATHS ${SMALLCHANGEDIR} PATH_SUFFIXES include lib . NO_DEFAULT_PATH)

  IF (SmallChange_INCLUDE_DIR AND SmallChange_LIBRARY)
     SET(SmallChange_FOUND TRUE)
  ENDIF (SmallChange_INCLUDE_DIR AND SmallChange_LIBRARY)

  IF (SmallChange_FOUND)
     IF (NOT SmallChange_FIND_QUIETLY)
        MESSAGE(STATUS "Found SmallChange: ${SmallChange_LIBRARY}")
     ENDIF (NOT SmallChange_FIND_QUIETLY)
  ELSE (SmallChange_FOUND)
     IF (SmallChange_FIND_REQUIRED)
        MESSAGE(FATAL_ERROR "Could not find SmallChange in ${SMALLCHANGEDIR}.")
     ENDIF (SmallChange_FIND_REQUIRED)
  ENDIF (SmallChange_FOUND)

ELSE(SMALLCHANGEDIR)

  # Automatic find
  FIND_PATH(SmallChange_INCLUDE_DIR SmallChange/misc/Init.h)
  FIND_LIBRARY(SmallChange_LIBRARY NAMES ${SmallChange_LIBRARY_NAMES})

  IF (SmallChange_INCLUDE_DIR AND SmallChange_LIBRARY)
     SET(SmallChange_FOUND TRUE)
  ENDIF (SmallChange_INCLUDE_DIR AND SmallChange_LIBRARY)

  IF (SmallChange_FOUND)
     IF (NOT SmallChange_FIND_QUIETLY)
        MESSAGE(STATUS "Found SmallChange: ${SmallChange_LIBRARY}")
     ENDIF (NOT SmallChange_FIND_QUIETLY)
  ELSE (SmallChange_FOUD)
     IF (SmallChange_FIND_REQUIRED)
        MESSAGE(FATAL_ERROR "Could not find SmallChange. Try setting the SMALLCHANGEDIR environment variable.")
     ENDIF (SmallChange_FIND_REQUIRED)
  ENDIF (SmallChange_FOUND)

ENDIF(SMALLCHANGEDIR)
