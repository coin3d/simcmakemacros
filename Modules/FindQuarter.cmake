SET(CMAKE_ALLOW_LOOSE_LOOP_CONSTRUCTS True)

IF(USE_SIM_FIND)
  # FIXME: Experimental find mechanism. Should be tested on several platforms with several
  # configurations and someone extended before becomming the one and only thing. 20081105 larsm
  INCLUDE(SimFind)
  SIM_FIND(Quarter RELEASELIBNAMES Quarter Quarter0 Quarter1
                  DEBUGLIBNAMES Quarterd Quarter0d Quarter1d
                  INCLUDEFILE Quarter/Quarter.h)
ELSE(USE_SIM_FIND)
  IF(NOT QUARTERDIR)
    SET(QUARTERDIR $ENV{QUARTERDIR})
    IF(QUARTERDIR)
      MESSAGE(STATUS "Setting QUARTERDIR to \"${QUARTERDIR}\" from environment variable")
    ENDIF(QUARTERDIR)
  ENDIF(NOT QUARTERDIR)

  SET(Quarter_NAMES Quarter Quarter0 Quarter1)
  SET(Quarter_NAMES_DEBUG Quarterd Quarter0d Quarter1d)

  IF(WIN32 AND NOT QUARTERDIR)
    #Try registry entry if environment variable does not exist.
    #NB! Experimental, but should work e.g with the NSIS generated Quarter
    #installer. Could be expanded with versioning info etc. 2008-05-29, oyshole
    SET(QUARTERDIR "[HKEY_LOCAL_MACHINE\\Software\\Kongsberg SIM\\Quarter;]")

    IF(QUARTERDIR)
      GET_FILENAME_COMPONENT(Quarter_DYNAMIC_LINK "[HKEY_LOCAL_MACHINE\\Software\\Kongsberg SIM\\Quarter;Dynamic]" NAME)

      #Check for the magic value "registry" which is set when the key is not found
      IF(${Quarter_DYNAMIC_LINK} STREQUAL registry)
	MESSAGE(STATUS "Could not find Quarter linkage mode in the registry..")
      ELSE()
	SET(Quarter_REGISTRY_FOUND true)
	IF(Quarter_DYNAMIC_LINK)
          SET(Quarter_DEFINES -DQUARTER_DLL)
	ELSE()
          SET(Quarter_DEFINES -DQUARTER_NOT_DLL)
	ENDIF()
      ENDIF()
    ENDIF()
  ENDIF()

  IF(QUARTERDIR)
    # Look for Quarter in environment variable QUARTERDIR
    FIND_LIBRARY(Quarter_LIBRARY_RELEASE NAMES ${Quarter_NAMES} PATHS ${QUARTERDIR} PATH_SUFFIXES src src/Quarter bin lib . NO_DEFAULT_PATH)
    FIND_LIBRARY(Quarter_LIBRARY_DEBUG NAMES ${Quarter_NAMES_DEBUG} PATHS ${QUARTERDIR} PATH_SUFFIXES src src/Quarter bin lib . NO_DEFAULT_PATH)

    #Use only release library if debug library is not found
    IF(Quarter_LIBRARY_RELEASE AND NOT Quarter_LIBRARY_DEBUG)
      SET(Quarter_LIBRARY_DEBUG ${Quarter_LIBRARY_RELEASE})
      SET(Quarter_LIBRARY       ${Quarter_LIBRARY_RELEASE})
      SET(Quarter_LIBRARIES     ${Quarter_LIBRARY_RELEASE})
    ENDIF()

    #Use only debug library if release library is not found
    IF(Quarter_LIBRARY_DEBUG AND NOT Quarter_LIBRARY_RELEASE)
      SET(Quarter_LIBRARY_RELEASE ${Quarter_LIBRARY_DEBUG})
      SET(Quarter_LIBRARY       ${Quarter_LIBRARY_DEBUG})
      SET(Quarter_LIBRARIES     ${Quarter_LIBRARY_DEBUG})
    ENDIF()

    IF(Quarter_LIBRARY_DEBUG AND Quarter_LIBRARY_RELEASE)
      IF(CMAKE_CONFIGURATION_TYPES OR CMAKE_BUILD_TYPE)
	#If the generator supports configuration types then set
	#optimized and debug libraries, or if the CMAKE_BUILD_TYPE has a value
	SET(Quarter_LIBRARY optimized ${Quarter_LIBRARY_RELEASE} debug ${Quarter_LIBRARY_DEBUG})
      ELSE()
	#If there are no configuration types and CMAKE_BUILD_TYPE has no value
	#then just use the release libraries
	SET(Quarter_LIBRARY ${Quarter_LIBRARY_RELEASE})
      ENDIF()
      SET(Quarter_LIBRARIES optimized ${Quarter_LIBRARY_RELEASE} debug ${Quarter_LIBRARY_DEBUG})
    ENDIF()

    SET(Quarter_LIBRARY ${Quarter_LIBRARY} CACHE FILEPATH "The Quarter library")
    MARK_AS_ADVANCED(Quarter_LIBRARY_RELEASE Quarter_LIBRARY_DEBUG)

    FIND_PATH(Quarter_INCLUDE_DIR Quarter/Quarter.h PATHS ${QUARTERDIR} PATH_SUFFIXES include src . NO_DEFAULT_PATH)

    IF(Quarter_INCLUDE_DIR AND Quarter_LIBRARY)
      SET(Quarter_FOUND TRUE)
    ENDIF()

    IF (Quarter_FOUND)
      IF (NOT Quarter_FIND_QUIETLY)
        MESSAGE(STATUS "Found Quarter: ${Quarter_LIBRARY}")
      ENDIF (NOT Quarter_FIND_QUIETLY)
    ELSE (Quarter_FOUND)
      IF (Quarter_FIND_REQUIRED)
        MESSAGE(FATAL_ERROR "Could not find Quarter in ${QUARTERDIR}.")
      ENDIF (Quarter_FIND_REQUIRED)
    ENDIF (Quarter_FOUND)

  ELSE(QUARTERDIR)

    # Automatic find
    FIND_PATH(Quarter_INCLUDE_DIR Quarter/Quarter.h)
    FIND_LIBRARY(Quarter_LIBRARY NAMES Quarter Quarter0)

    IF (Quarter_INCLUDE_DIR AND Quarter_LIBRARY)
      SET(Quarter_FOUND TRUE)
    ENDIF (Quarter_INCLUDE_DIR AND Quarter_LIBRARY)

    IF (Quarter_FOUND)
      IF (NOT Quarter_FIND_QUIETLY)
        MESSAGE(STATUS "Found Quarter: ${Quarter_LIBRARY}")
      ENDIF (NOT Quarter_FIND_QUIETLY)
    ELSE (Quarter_FOUND)
      IF (Quarter_FIND_REQUIRED)
        MESSAGE(FATAL_ERROR "Could not find Quarter. Try setting the QUARTERDIR environment variable.")
      ENDIF (Quarter_FIND_REQUIRED)
    ENDIF (Quarter_FOUND)
  ENDIF(QUARTERDIR)

  IF (Quarter_FOUND AND WIN32 AND NOT Quarter_REGISTRY_FOUND)
    FIND_FILE(Quarter_pc NAMES Quarter.pc PATHS ${Quarter_INCLUDE_DIR}/../ PATH_SUFFIXES . lib/pkgconfig/ NO_DEFAULT_PATH)
    MARK_AS_ADVANCED(Quarter_pc)
    IF(EXISTS ${Quarter_pc})
      FILE(READ ${Quarter_pc} QuarterPC)
      IF (${QuarterPC} MATCHES QUARTER_DLL)
	MESSAGE(STATUS "Found Quarter.pc with -DQUARTER_DLL")
	SET(Quarter_DEFINES -DQUARTER_DLL)
      ELSE()
	MESSAGE(STATUS "Found Quarter.pc with -DQUARTER_NOT_DLL")
	SET(Quarter_DEFINES -DQUARTER_NOT_DLL)
      ENDIF()
    ELSEIF(QUARTER_NOT_DLL)
      SET(Quarter_DEFINES -DQUARTER_NOT_DLL)
    ELSEIF(QUARTER_DLL)
      SET(Quarter_DEFINES -DQUARTER_DLL)
    ELSE()
      MESSAGE(STATUS "WARNING: Could not find Quarter.pc, using -DQUARTER_DLL=1. Override or remove this warning using cmake -DQUARTER_NOT_DLL=1 or cmake -DAUARTER_DLL=1.")
      # Cross your fingers...
      SET(Quarter_DEFINES -DQUARTER_DLL)
    ENDIF()
  ENDIF()
ENDIF(USE_SIM_FIND)
