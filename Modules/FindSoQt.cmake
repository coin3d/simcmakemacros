SET(SOQTDIR $ENV{SOQTDIR})

IF(SOQTDIR)

  # Look for SoQt in environment variable SOQTDIR
  FIND_LIBRARY(SoQt_LIBRARY NAMES SoQt SoQt1 PATHS ${SOQTDIR} PATH_SUFFIXES src "src/Inventor/Qt" bin lib .)
  FIND_PATH(SoQt_INCLUDE_DIR Inventor/Qt/SoQt.h PATHS ${SOQTDIR} PATH_SUFFIXES include src .)

  IF (SoQt_INCLUDE_DIR AND SoQt_LIBRARY)
     SET(SoQt_FOUND TRUE)
  ENDIF (SoQt_INCLUDE_DIR AND SoQt_LIBRARY)

  IF (SoQt_FOUND)
     IF (NOT SoQt_FIND_QUIETLY)
        MESSAGE(STATUS "Found SoQt: ${SoQt_LIBRARY}")
     ENDIF (NOT SoQt_FIND_QUIETLY)
  ELSE (SoQt_FOUND)
     IF (SoQt_FIND_REQUIRED)
        MESSAGE(FATAL_ERROR "Could not find SoQt in ${SOQTDIR}.")
     ENDIF (SoQt_FIND_REQUIRED)
  ENDIF (SoQt_FOUND)

ELSE(SOQTDIR)

  # Automatic find
  FIND_PATH(SoQt_INCLUDE_DIR Inventor/Qt/SoQt.h)
  FIND_LIBRARY(SoQt_LIBRARY NAMES SoQt SoQt1)

  IF (SoQt_INCLUDE_DIR AND SoQt_LIBRARY)
     SET(SoQt_FOUND TRUE)
  ENDIF (SoQt_INCLUDE_DIR AND SoQt_LIBRARY)

  IF (SoQt_FOUND)
     IF (NOT SoQt_FIND_QUIETLY)
        MESSAGE(STATUS "Found SoQt: ${SoQt_LIBRARY}")
     ENDIF (NOT SoQt_FIND_QUIETLY)
  ELSE (SoQt_FOUND)
     IF (SoQt_FIND_REQUIRED)
        MESSAGE(FATAL_ERROR "Could not find SoQt. Try setting the SOQTDIR environment variable.")
     ENDIF (SoQt_FIND_REQUIRED)
  ENDIF (SoQt_FOUND)

ENDIF(SOQTDIR)

# SoQt_DEFINES - only on WIN32
IF (SoQt_FOUND AND WIN32)
  FIND_FILE(SoQt_pc NAMES SoQt.pc PATHS ${SoQt_INCLUDE_DIR}/../ PATH_SUFFIXES . lib/pkgconfig/ NO_DEFAULT_PATH)
  MARK_AS_ADVANCED(SoQt_pc)
  IF(EXISTS ${SoQt_pc})
    FILE(READ ${SoQt_pc} SoQtPC)
    IF (${SoQtPC} MATCHES SOQT_DLL)
      MESSAGE(STATUS "Found SoQt.pc with -DSOQT_DLL")
      SET(SoQt_DEFINES -DSOQT_DLL)
    ELSE()
      MESSAGE(STATUS "Found SoQt.pc with -DSOQT_NOT_DLL")
      SET(SoQt_DEFINES -DSOQT_NOT_DLL)
    ENDIF()
  ELSE()
    MESSAGE(STATUS "WARNING: Could not find SoQt.pc, using -DSOQT_DLL. This may be wrong though...")
    # Cross your fingers...
    SET(SoQt_DEFINES -DSOQT_DLL)
  ENDIF()
ENDIF()
