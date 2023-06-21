#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "openstudio::openstudiolib" for configuration "Release"
set_property(TARGET openstudio::openstudiolib APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(openstudio::openstudiolib PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libopenstudiolib.dylib"
  IMPORTED_SONAME_RELEASE "@rpath/libopenstudiolib.dylib"
  )

list(APPEND _cmake_import_check_targets openstudio::openstudiolib )
list(APPEND _cmake_import_check_files_for_openstudio::openstudiolib "${_IMPORT_PREFIX}/lib/libopenstudiolib.dylib" )

# Import target "openstudio::openstudio_rb" for configuration "Release"
set_property(TARGET openstudio::openstudio_rb APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(openstudio::openstudio_rb PROPERTIES
  IMPORTED_COMMON_LANGUAGE_RUNTIME_RELEASE ""
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/Ruby/openstudio.bundle"
  IMPORTED_NO_SONAME_RELEASE "TRUE"
  )

list(APPEND _cmake_import_check_targets openstudio::openstudio_rb )
list(APPEND _cmake_import_check_files_for_openstudio::openstudio_rb "${_IMPORT_PREFIX}/Ruby/openstudio.bundle" )

# Import target "openstudio::rubyengine" for configuration "Release"
set_property(TARGET openstudio::rubyengine APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(openstudio::rubyengine PROPERTIES
  IMPORTED_COMMON_LANGUAGE_RUNTIME_RELEASE ""
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/librubyengine.so"
  IMPORTED_NO_SONAME_RELEASE "TRUE"
  )

list(APPEND _cmake_import_check_targets openstudio::rubyengine )
list(APPEND _cmake_import_check_files_for_openstudio::rubyengine "${_IMPORT_PREFIX}/lib/librubyengine.so" )

# Import target "openstudio::openstudio" for configuration "Release"
set_property(TARGET openstudio::openstudio APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(openstudio::openstudio PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/openstudio"
  )

list(APPEND _cmake_import_check_targets openstudio::openstudio )
list(APPEND _cmake_import_check_files_for_openstudio::openstudio "${_IMPORT_PREFIX}/bin/openstudio" )

# Import target "openstudio::pythonengine" for configuration "Release"
set_property(TARGET openstudio::pythonengine APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(openstudio::pythonengine PROPERTIES
  IMPORTED_COMMON_LANGUAGE_RUNTIME_RELEASE ""
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libpythonengine.so"
  IMPORTED_NO_SONAME_RELEASE "TRUE"
  )

list(APPEND _cmake_import_check_targets openstudio::pythonengine )
list(APPEND _cmake_import_check_files_for_openstudio::pythonengine "${_IMPORT_PREFIX}/lib/libpythonengine.so" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
