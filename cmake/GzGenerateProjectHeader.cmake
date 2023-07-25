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

function(gz_generate_project_header)

  #------------------------------------
  # Define the expected arguments
  set(options NO_PREFIX)
  set(oneValueArgs SOURCE_INCLUDE_DIR PROJECT_INCLUDE_DIR DESIGNATION)
  set(multiValueArgs EXCLUDE_FILES EXCLUDE_DIRS)

  #------------------------------------
  # Parse the arguments
  cmake_parse_arguments(gz_generate_project_header "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(${gz_generate_project_header_NO_PREFIX})
    set(PREFIX "")
  else()
    set(PREFIX "GZ_")
  endif()

  set(DESIGNATION ${gz_generate_project_header_DESIGNATION})
  string(TOLOWER ${DESIGNATION} DESIGNATION_LOWER)
  string(TOUPPER ${DESIGNATION} DESIGNATION_UPPER)
  set(PROJECT_INCLUDE_DIR "${gz_generate_project_header_PROJECT_INCLUDE_DIR}")
  set(SOURCE_INCLUDE_DIR "${gz_generate_project_header_SOURCE_INCLUDE_DIR}")

  file(GLOB_RECURSE all_files LIST_DIRECTORIES TRUE RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}/${gz_generate_porject_header_SOURCE_INCLUDE_DIR}/" "*")
  list(SORT all_files)

  message(STATUS ${all_files})

  set(directories)
  foreach(f ${all_files})
    # Check if this file is a directory
    if(IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${f})

      # Check if it is in the list of excluded directories
      list(FIND gz_generate_project_header_EXCLUDE_DIRS ${f} f_index)

      set(append_file TRUE)
      foreach(subdir ${gz_generate_project_header_EXCLUDE_DIRS})

        # Check if ${f} contains ${subdir} as a substring
        string(FIND ${f} ${subdir} pos)

        # If ${subdir} is a substring of ${f} at the very first position, then
        # we should not include anything from this directory. This makes sure
        # that if a user specifies "EXCLUDE_DIRS foo" we will also exclude
        # the directories "foo/bar/..." and so on. We will not, however, exclude
        # a directory named "bar/foo/".
        if(${pos} EQUAL 0)
          set(append_file FALSE)
          break()
        endif()

      endforeach()

      if(append_file)
        list(APPEND directories ${f})
      endif()
    endif()
  endforeach()

  # Append the current directory to the list
  list(APPEND directories ".")

  #------------------------------------
  # Install all the non-excluded header directories along with all of their
  # non-excluded headers
  foreach(dir ${directories})

    # GLOB all the header files in dir
    file(GLOB headers RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "${dir}/*.h" "${dir}/*.hh" "${dir}/*.hpp")
    list(SORT headers)

    # Remove the excluded headers
    if(headers)
      foreach(exclude ${gz_generate_project_header_EXCLUDE_FILES})
        list(REMOVE_ITEM headers ${exclude})
      endforeach()
    endif()

    # Add each header, prefixed by its directory, to the auto headers variable
    foreach(header ${headers})
      set(gz_headers "${gz_headers}#include <${PROJECT_INCLUDE_DIR}/${header}>\n")
    endforeach()
  endforeach()

  configure_file(
    "${ament_cmake_gazebo_DIR}/../resource/gz_auto_headers.hh.in"
    "${CMAKE_BINARY_DIR}/${SOURCE_INCLUDE_DIR}/${PROJECT_INCLUDE_DIR}/${DESIGNATION_LOWER}.hh"
  )

  # Configure the installation of the automatically generated file.
  install(
    FILES "${CMAKE_BINARY_DIR}/${SOURCE_INCLUDE_DIR}/${PROJECT_INCLUDE_DIR}/${DESIGNATION_LOWER}.hh"
    DESTINATION "include/${PROJECT_INCLUDE_DIR}")
endfunction()
