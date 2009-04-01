INCLUDE(${QT_USE_FILE})
INCLUDE(SimMSVC)

# SIM_QT4_WRAP_CPP(outfiles infiles ... )
MACRO(SIM_QT4_AUTO_WRAP_CPP outfiles )
  # Clear list to be sure - QT4_WRAP_CPP doesnt do it
  # FIXME: Is this what we want, really? Several of the built-in macros
  # behave as "append", not "set" - rolvs
  SET(${outfiles} )

  FOREACH(_current_FILE ${ARGN})
    # Read file
    GET_FILENAME_COMPONENT(_abs_FILE ${_current_FILE} ABSOLUTE)
    FILE(READ ${_abs_FILE} _contents)

    # Process file
    STRING(REGEX MATCHALL "Q_OBJECT" _match "${_contents}")

    IF(_match)
      # Found a file that needs to be moc'ed, do it
      #GET_FILENAME_COMPONENT(_basename ${_current_FILE} NAME_WE)
      #SET(_moced_FILE "moc_${_basename}.cpp"}}
      QT4_WRAP_CPP(${outfiles} ${_current_FILE})
    ENDIF(_match)

  ENDFOREACH(_current_FILE)
ENDMACRO(SIM_QT4_AUTO_WRAP_CPP)


# SIM_QT4_WRAP_UI_TO(outfiles todirectory inputfiles ... )
MACRO (SIM_QT4_WRAP_UI_TO outfiles todirectory )
  FOREACH (it ${ARGN})
    GET_FILENAME_COMPONENT(outfile ${it} NAME_WE)
    GET_FILENAME_COMPONENT(infile ${it} ABSOLUTE)
    SET(outfile ${CMAKE_CURRENT_BINARY_DIR}/${todirectory}/ui_${outfile}.h)
    ADD_CUSTOM_COMMAND(OUTPUT ${outfile}
      COMMAND ${QT_UIC_EXECUTABLE}
      ARGS -o ${outfile} ${infile}
      MAIN_DEPENDENCY ${infile})
    SET(${outfiles} ${${outfiles}} ${outfile})
  ENDFOREACH (it)
ENDMACRO (SIM_QT4_WRAP_UI_TO)

# SIM_QT4_ADD_RESOURCES_TO(outfiles todirectory inputfiles ... )
MACRO (SIM_QT4_ADD_RESOURCES_TO outfiles todirectory )
  SET(rcc_files ${ARGN})

  FOREACH (it ${rcc_files})
    GET_FILENAME_COMPONENT(outfilename ${it} NAME_WE)
    GET_FILENAME_COMPONENT(infile ${it} ABSOLUTE)
    GET_FILENAME_COMPONENT(rc_path ${infile} PATH)
    SET(outfile ${CMAKE_CURRENT_BINARY_DIR}/${todirectory}/qrc_${outfilename}.cxx)
    #  parse file for dependencies
    #  all files are absolute paths or relative to the location of the qrc file
    FILE(READ "${infile}" _RC_FILE_CONTENTS)
    STRING(REGEX MATCHALL "<file[^<]+" _RC_FILES "${_RC_FILE_CONTENTS}")
    SET(_RC_DEPENDS)
    FOREACH(_RC_FILE ${_RC_FILES})
      STRING(REGEX REPLACE "^<file[^>]*>" "" _RC_FILE "${_RC_FILE}")
      STRING(REGEX MATCH "^/|([A-Za-z]:/)" _ABS_PATH_INDICATOR "${_RC_FILE}")
      IF(NOT _ABS_PATH_INDICATOR)
        SET(_RC_FILE "${rc_path}/${_RC_FILE}")
      ENDIF(NOT _ABS_PATH_INDICATOR)
      SET(_RC_DEPENDS ${_RC_DEPENDS} "${_RC_FILE}")
    ENDFOREACH(_RC_FILE)
    ADD_CUSTOM_COMMAND(OUTPUT ${outfile}
      COMMAND ${QT_RCC_EXECUTABLE}
      ARGS -name ${outfilename} -o ${outfile} ${infile}
      MAIN_DEPENDENCY ${infile}
      DEPENDS ${_RC_DEPENDS})
    SET(${outfiles} ${${outfiles}} ${outfile})
  ENDFOREACH (it)
ENDMACRO(SIM_QT4_ADD_RESOURCES_TO)

# - Set up a simple unittest, with name header and source
# SIM_CREATE_QT4_UNITTEST(NAME HEADER SOURCE LIBRARIES...)
#  NAME - the name of the unittest as it will be registred
#  HEADER - Headerfile of the testrunner
#  SOURCE - Sourcefile, with main().
#
# Use together with a header and source for a QtTest unittest, and
# QTEST_MAIN() in the sourcefile, to set up a simple unittest with
# executable name NAME_t(.exe) and testname NAME.
MACRO(SIM_CREATE_QT4_UNITTEST name header source)
    QT4_WRAP_CPP(unittest_moc_SRCS ${header})
    SET(runner_NAME ${name})
    SET(link_LIBS ${ARGN}) # Empty, if no extra params

    # Add header as source when generating MSVC projects
    IF(MSVC_IDE)
      ADD_EXECUTABLE(${runner_NAME} ${unittest_moc_SRCS} ${source} ${header})
    ELSE(MSVC_IDE)
      ADD_EXECUTABLE(${runner_NAME} ${unittest_moc_SRCS} ${source})
    ENDIF(MSVC_IDE)

    TARGET_LINK_LIBRARIES(${runner_NAME} ${link_LIBS} ${QT_QTTEST_LIBRARY})
    ADD_TEST(${name} ${runner_NAME})
    set(unittest_moc_SRCS)
ENDMACRO(SIM_CREATE_QT4_UNITTEST)

# - Set up a simple unittest, from a base-name
# SIM_CREATE_QT4_UNITTEST2( basename libs...)
#
# Creates a simple unittest with executable name "basename_t(.exe)", testname
# "basename", from the files basename.h and basename.cpp, which must exist,
# QtTest tests, using QTEST_MAIN().
MACRO(SIM_CREATE_QT4_UNITTEST2 name)
    # FIXME: We are not guarranteed that the filename is .cpp - could perhaps
    # check for the other c++ extensions.
    SIM_CREATE_QT4_UNITTEST(${name} ${name}.h ${name}.cpp ${ARGN})
ENDMACRO(SIM_CREATE_QT4_UNITTEST2)

# Creates a plugin from one header and cpp file.
# SIM_CREATE_QT_PLUGIN(targetname ...)
# - targetname is the name of the plugin. There must be a header and a cpp
#   file correspoding to the targetname given.
# - remaining params are libraries that the plugin is to be linked against
MACRO(SIM_CREATE_QT_PLUGIN targetname)
  SET(Source ${targetname}.cpp)
  SET(Header ${targetname}.h)
  SET(LinkLibs ${ARGN})

  SIM_QT4_AUTO_WRAP_CPP(Moc ${Header})
  IF(MSVC_IDE)
    ADD_LIBRARY(${targetname} ${Source} ${Header} ${Moc})
  ELSE(MSVC_IDE)
    ADD_LIBRARY(${targetname} ${Source} ${Moc})
  ENDIF(MSVC_IDE)

  IF(${LinkLibs})
   TARGET_LINK_LIBRARIES(${Library} ${LinkLibs})
  ENDIF(${LinkLibs})
ENDMACRO(SIM_CREATE_QT_PLUGIN)

# Creates a plugin from one header and cpp file and
# creates an optional make install target for the plugin.
#
# SIM_CREATE_QT_PLUGIN(TARGET targetname [SOURCE file1 file2])
#
#  - TARGET            The name of the target (required)
#  - SOURCE            The source files. If not specified, a moc is generated
#                      from ${targetname}.h, and compiled along with ${targetname}.cpp.
MACRO(SIM_CREATE_QT_PLUGIN)
  SIM_VALIDATE_ARGUMENTS(ValidArguments SIM_CREATE_QT_PLUGIN
                         "TARGET"                               # Required
                         "TARGET;SOURCE"                        # Allowed
                         "${ARGV}")
  # Required arguments
  SIM_FETCH_ARGUMENTS(Target TARGET ${ARGV})
  # Optional arguments
  SIM_HAS_ARGUMENT(Source SOURCE ${ARGV})
  SIM_FETCH_ARGUMENTS(Source SOURCE ${ARGV})

  IF(ValidArguments)
    IF(HasSource)
      # Build plugin using custom source files
      ADD_LIBRARY(${Target} SHARED ${Source})
    ELSE(HasSource)
      # Automatic source
      SET(Source ${Target}.cpp)
      SET(Header ${Target}.h)

      SIM_QT4_AUTO_WRAP_CPP(Moc ${Header})

      IF(MSVC_IDE)
        ADD_LIBRARY(${Target} SHARED ${Source} ${Header} ${Moc})
      ELSE(MSVC_IDE)
        ADD_LIBRARY(${Target} SHARED ${Source} ${Moc})
      ENDIF(MSVC_IDE)
    ENDIF(HasSource)
  ENDIF(ValidArguments)
ENDMACRO(SIM_CREATE_QT_PLUGIN)

# Stores the path to Qt in the argument given. Uses
# QT_MOC_EXECUTABLE to extract the path.
# 
# SIM_GET_QT_ROOT(variable)
MACRO(SIM_GET_QT_ROOT variable)
  GET_FILENAME_COMPONENT(${variable} ${QT_MOC_EXECUTABLE} PATH)
  FILE(TO_CMAKE_PATH "${${variable}}/../" ${variable}) 
ENDMACRO(SIM_GET_QT_RO
