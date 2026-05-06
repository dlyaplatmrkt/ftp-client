cmake_minimum_required(VERSION 3.14)

set(EPHEMERAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ephemeral")

include(${EPHEMERAL_DIR}/generated_config.cmake)

include(${EPHEMERAL_DIR}/flutter_export.cmake OPTIONAL)
include(${EPHEMERAL_DIR}/flutter_windows.cmake OPTIONAL)

add_library(flutter INTERFACE)
add_library(flutter_wrapper_app STATIC
  ${CPP_WRAPPER_SOURCES_APP}
)
add_library(flutter_wrapper_plugin STATIC
  ${CPP_WRAPPER_SOURCES_PLUGIN}
)
add_library(flutter_wrapper_plugin_library STATIC
  ${CPP_WRAPPER_SOURCES_LIBRARY}
)

target_include_directories(flutter INTERFACE
  "${EPHEMERAL_DIR}"
)
target_include_directories(flutter_wrapper_app PUBLIC
  "${WRAPPER_ROOT}/include"
)
target_include_directories(flutter_wrapper_plugin PUBLIC
  "${WRAPPER_ROOT}/include"
)
target_include_directories(flutter_wrapper_plugin_library PUBLIC
  "${WRAPPER_ROOT}/include"
)

target_link_libraries(flutter INTERFACE "${FLUTTER_LIBRARY}")

target_link_libraries(flutter_wrapper_app PUBLIC flutter)
target_link_libraries(flutter_wrapper_plugin PUBLIC flutter)
target_link_libraries(flutter_wrapper_plugin_library PUBLIC flutter)

set_target_properties(flutter_wrapper_app PROPERTIES
  CXX_STANDARD 17
)
set_target_properties(flutter_wrapper_plugin PROPERTIES
  CXX_STANDARD 17
)
set_target_properties(flutter_wrapper_plugin_library PROPERTIES
  CXX_STANDARD 17
)

function(apply_standard_settings TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_17)
  target_compile_options(${TARGET} PRIVATE /W4 /WX /wd"4100")
  target_compile_options(${TARGET} PRIVATE /EHsc)
  target_compile_definitions(${TARGET} PRIVATE "_HAS_EXCEPTIONS=0")
  target_compile_definitions(${TARGET} PRIVATE "$<$<CONFIG:Debug>:_DEBUG>")
endfunction()
