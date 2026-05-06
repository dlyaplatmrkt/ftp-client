cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

set(BINARY_NAME "ftp_client")
set(APP_VERSION "1.0.0")

string(REPLACE "." "," VERSION_AS_COMMA_LIST ${APP_VERSION})

configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/Runner.rc.in"
  "${CMAKE_CURRENT_BINARY_DIR}/Runner.rc"
)

add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "${CMAKE_CURRENT_BINARY_DIR}/Runner.rc"
  "runner.exe.manifest"
)

apply_standard_settings(${BINARY_NAME})

target_compile_definitions(${BINARY_NAME} PRIVATE
  "FLUTTER_VERSION=\"${APP_VERSION}\""
  "FLUTTER_VERSION_MAJOR=1"
  "FLUTTER_VERSION_MINOR=0"
  "FLUTTER_VERSION_PATCH=0"
  "FLUTTER_VERSION_BUILD=0"
)

target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_link_libraries(${BINARY_NAME} PRIVATE "dwmapi.lib")
target_link_libraries(${BINARY_NAME} PRIVATE "comctl32.lib")

set_target_properties(${BINARY_NAME} PROPERTIES
  LINK_FLAGS "/SUBSYSTEM:WINDOWS"
)
