# Copyright 2023 Open Source Robotics Foundation, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Parse information from the underlying git repository to retrieve the version.
# This is used in various config.hh files throughout the gazebo codebase.

#################################################
# gz_generate_version_header
#   [DESIGNATION <designation>]
#   [PROJECT_INCLUDE_DIR] <dir>]
#   [NO_PREFIX])
#
# Create a Version.hh header from git version control information to be installed
# with the package being built.
#
# DESIGNATION - The gazebo package being build, eg utils, msgs
# PROJECT_INCLUDE_DIR - The relative include directory to install to (gz/utils, gz/msgs)
# NO_PREFIX - Don't define variables with the "GZ_" prefix, mainly for sdformat

function(gz_generate_version_header)

  #------------------------------------
  # Define the expected arguments
  set(options NO_PREFIX)
  set(oneValueArgs PROJECT_INCLUDE_DIR DESIGNATION)
  set(multiValueArgs)

  #------------------------------------
  # Parse the arguments
  cmake_parse_arguments(gz_generate_version_header "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(${gz_generate_version_header_NO_PREFIX})
    set(PREFIX "")
  else()
    set(PREFIX "GZ_")
  endif()

  set(DESIGNATION ${gz_generate_version_header_DESIGNATION})
  string(TOUPPER ${DESIGNATION} DESIGNATION_UPPER)
  string(TOLOWER ${DESIGNATION} DESIGNATION_LOWER)
  set(PROJECT_INCLUDE_DIR "${gz_generate_version_header_PROJECT_INCLUDE_DIR}")
  set(install_path "include/${PROJECT_INCLUDE_DIR}")

  # Branch Name
  execute_process(
    COMMAND git rev-parse --abbrev-ref HEAD
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    OUTPUT_VARIABLE GZ_GIT_BRANCH_NAME
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )

  # Commit Hash
  execute_process(
    COMMAND git rev-parse --short HEAD
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    OUTPUT_VARIABLE GZ_GIT_COMMIT_HASH
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )

  # Last Tag
  execute_process(
    COMMAND git describe --tags --abbrev=0
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    OUTPUT_VARIABLE GZ_GIT_TAG_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  # Last Tag
  execute_process(
    COMMAND git describe --tags
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    OUTPUT_VARIABLE GZ_GIT_DESCRIBE_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  message(STATUS "Parsing version from git: (Branch: ${GZ_GIT_BRANCH_NAME}) (Hash: ${GZ_GIT_COMMIT_HASH}) (Last Tag: ${GZ_GIT_TAG_VERSION})")
  string(REGEX REPLACE "^[a-z_-]+[0-9]+_([0-9]+)\\..*" "\\1" PROJECT_VERSION_MAJOR "${GZ_GIT_TAG_VERSION}")
  string(REGEX REPLACE "^[a-z_-]+[0-9]+_[0-9]+\\.([0-9]+).*" "\\1" PROJECT_VERSION_MINOR "${GZ_GIT_TAG_VERSION}")
  string(REGEX REPLACE "^[a-z_-]+[0-9]+_[0-9]+\\.[0-9]+.*\\.([0-9]+).*" "\\1" PROJECT_VERSION_PATCH "${GZ_GIT_TAG_VERSION}")

  set(PROJECT_VERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}")
  set(PROJECT_VERSION_FULL "${GZ_GIT_DESCRIBE_VERSION}")


  configure_file(
    "${ament_cmake_gazebo_DIR}/../resource/Version.hh.in"
    "${CMAKE_BINARY_DIR}/${install_path}/Version.hh"
  )

  # Configure the installation of the automatically generated file.
  install(
    FILES "${CMAKE_BINARY_DIR}/${install_path}/Version.hh"
    DESTINATION "${install_path}")
endfunction()
