cmake_minimum_required(VERSION 3.14)
project(ftp_client LANGUAGES CXX)

set(BINARY_NAME "ftp_client")
set(APPLICATION_ID "lol.ftpvpn.client")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/run" CACHE PATH "..." FORCE)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED YES)

add_subdirectory("flutter")
add_subdirectory("runner")

install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}"
  COMPONENT Runtime)
