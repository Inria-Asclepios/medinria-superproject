## #############################################################################
## Add common variable for all external-projects
## #############################################################################

set(ep_common_c_flags 
  "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_INIT} ${ADDITIONAL_C_FLAGS}"
  )

set(ep_common_cxx_flags 
  "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_INIT} ${ADDITIONAL_CXX_FLAGS}"
  )

if (${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
  set(ep_common_cxx_flags 
    "${ep_common_cxx_flags} -fpermissive "
    )
endif()

set(ep_common_cache_args
  -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
  -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
  -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
  -DBUILD_TESTING:BOOL=OFF
)

if (CMAKE_EXTRA_GENERATOR)
  set(gen "${CMAKE_EXTRA_GENERATOR} -G ${CMAKE_GENERATOR}")
else()
  set(gen "${CMAKE_GENERATOR}")
endif()


## #############################################################################
## Include cmake module
## #############################################################################
include(ExternalProject) 
include(CMakeParseArguments)


## #############################################################################
## Include common configuration steps
## #############################################################################

include(EP_Initialisation)
include(EP_SetDirectories)
include(EP_ForceBuild)


## #############################################################################
## Include specific modules of each project
## #############################################################################

file(GLOB projects_modules RELATIVE ${CMAKE_SOURCE_DIR} 
  "cmake/externals/projects_modules/*.cmake"
  )
foreach(module ${projects_modules})
    include(${module})
endforeach()


## #############################################################################
## Call specific module of each project
## #############################################################################

macro(call func_name)
    string(REPLACE "-" "_" func ${func_name})
    file(WRITE tmp_call.cmake "${func}(${ARGN})")
    include(tmp_call.cmake OPTIONAL)
    file(REMOVE tmp_call.cmake)
endmacro()

foreach (external_project ${external_projects})
  if (NOT USE_SYSTEM_${external_project})
    call(${external_project}_project)
  else ()
    find_package(${external_project} REQUIRED)
  endif ()
endforeach()
