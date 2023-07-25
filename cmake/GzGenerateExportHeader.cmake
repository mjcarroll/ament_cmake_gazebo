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
# gz_generate_export_header
#   [TARGET] <target>
#   [DESIGNATION <designation>]
#   [PROJECT_INCLUDE_DIR] <dir>]
#   [NO_PREFIX])
#
# Create a Export.hh header for a package being built.
#
# TARGET - Target to include the export header with
# DESIGNATION - The gazebo package being built, eg utils, msgs
# PROJECT_INCLUDE_DIR - The relative include directory to install to (gz/utils, gz/msgs)
# NO_PREFIX - Don't define variables with the "GZ_" prefix, mainly for sdformat

function(gz_generate_export_header)

  #------------------------------------
  # Define the expected arguments
  set(options NOPREFIX)
  set(oneValueArgs TARGET DESIGNATION PROJECT_INCLUDE_DIR)
  set(multiValueArgs)

  #------------------------------------
  # Parse the arguments
  cmake_parse_arguments(generate_gz_export_header "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(${generate_gz_export_header_NO_PREFIX})
    set(PREFIX "")
  else()
    set(PREFIX "GZ_")
  endif()

  set(DESIGNATION ${generate_gz_export_header_DESIGNATION})
  string(TOUPPER ${DESIGNATION} DESIGNATION_UPPER)
  string(TOLOWER ${DESIGNATION} DESIGNATION_LOWER)
  set(PROJECT_INCLUDE_DIR "${generate_gz_export_header_PROJECT_INCLUDE_DIR}")
  set(install_path "include/${PROJECT_INCLUDE_DIR}")

  include(GenerateExportHeader)
  generate_export_header(
    ${generate_gz_export_header_TARGET}
    BASE_NAME "${PREFIX}${DESIGNATION_UPPER}"
    EXPORT_FILE_NAME "${CMAKE_BINARY_DIR}/${install_path}/detail/Export.hh"
    EXPORT_MACRO_NAME DETAIL_${PREFIX}${DESIGNATION_UPPER}_VISIBLE
    NO_EXPORT_MACRO_NAME DETAIL_${PREFIX}${DESIGNATION_UPPER}_HIDDEN
    DEPRECATED_MACRO_NAME ${PREFIX}DEPRECATED_ALL_VERSIONS)

  # Configure the installation of the automatically generated file.
  install(
    FILES "${CMAKE_BINARY_DIR}/${install_path}/detail/Export.hh"
    DESTINATION "${install_path}/detail")


  configure_file(
    "${ament_cmake_gazebo_DIR}/../resource/Export.hh.in"
    "${CMAKE_BINARY_DIR}/${install_path}/Export.hh"
  )

  # Configure the installation of the automatically generated file.
  install(
    FILES "${CMAKE_BINARY_DIR}/${install_path}/Export.hh"
    DESTINATION "${install_path}")

endfunction()
