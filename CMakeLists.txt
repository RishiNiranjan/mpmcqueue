cmake_minimum_required(VERSION 3.5)

project(MPMCQueue VERSION 1.0 LANGUAGES CXX)


function(version_fetch _full _major _minor _patch _pre_release _addition _commit)
    find_program(gitex git)
    execute_process(
        COMMAND "${gitex}" describe --long --tags --abbrev=10 --match "v*"
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        RESULT_VARIABLE git_describe_r
        OUTPUT_VARIABLE git_describe)
    if (git_describe_r)
        message(FATAL_ERROR "can't do 'git describe' on ${CMAKE_CURRENT_SOURCE_DIR}")
    endif()
    string(REGEX MATCH "^v([0-9]+).([0-9]+).([0-9]+)(.*)-([0-9]+)-g([0-9a-f]*)"
                        regex_out
                       "${git_describe}")

    if (NOT CMAKE_MATCH_0)
        message(FATAL_ERROR "unexpected git describe result: ${git_describe}")
    else()
        set(${_full}     "${CMAKE_MATCH_0}" PARENT_SCOPE)
        set(${_major}    "${CMAKE_MATCH_1}" PARENT_SCOPE)
        set(${_minor}    "${CMAKE_MATCH_2}" PARENT_SCOPE)
        set(${_patch}    "${CMAKE_MATCH_3}" PARENT_SCOPE)
        set(${_pre_release} "${CMAKE_MATCH_4}" PARENT_SCOPE)
        set(${_addition} "${CMAKE_MATCH_5}" PARENT_SCOPE)
        set(${_commit}   "${CMAKE_MATCH_6}" PARENT_SCOPE)
    endif()
endfunction()

version_fetch(
    WRT_SDK_VERSION_FULL
    WRT_SDK_VERSION_MAJOR
    WRT_SDK_VERSION_MINOR
    WRT_SDK_VERSION_PATCH
    WRT_SDK_VERSION_PRE_RELEASE
    WRT_SDK_VERSION_ADDITION
    WRT_SDK_VERSION_COMMIT
)


set(VERSION "${WRT_SDK_VERSION_MAJOR}.${WRT_SDK_VERSION_MINOR}.${WRT_SDK_VERSION_PATCH}${WRT_SDK_VERSION_PRE_RELEASE}")
# configure_file(version version)

file(WRITE ${CMAKE_BINARY_DIR}/versioN "${VERSION}")


file(STRINGS ${CMAKE_BINARY_DIR}/versioN VersionNumber)

message("Version Number: ${VersionNumber}")


# add_subdirectory(config-cxx)

add_library(${PROJECT_NAME} INTERFACE)
add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_compile_features(${PROJECT_NAME} INTERFACE cxx_std_11)

target_include_directories(${PROJECT_NAME} INTERFACE
		$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
		$<INSTALL_INTERFACE:include>)

# Tests and examples
if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
	if (MSVC)
		add_compile_options(/permissive- /W4 /wd4172 /wd4324 /wd4530)
	else()
		add_compile_options(-Wall -Wextra -Wpedantic)
	endif()

	find_package(Threads REQUIRED)

	add_executable(MPMCQueueExample src/MPMCQueueExample.cpp)
	target_link_libraries(MPMCQueueExample MPMCQueue Threads::Threads)

	add_executable(MPMCQueueTest src/MPMCQueueTest.cpp)
	target_link_libraries(MPMCQueueTest MPMCQueue Threads::Threads)

	enable_testing()
	add_test(MPMCQueueTest MPMCQueueTest)
endif()

# Install
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
  COMPATIBILITY SameMajorVersion
)

export(
    TARGETS ${PROJECT_NAME}
    NAMESPACE ${PROJECT_NAME}::
    FILE "${PROJECT_NAME}Config.cmake"
)

if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    install(
        DIRECTORY "include/"
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )

    install(
        TARGETS ${PROJECT_NAME}
        EXPORT "${PROJECT_NAME}Config"
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )

    install(
        EXPORT "${PROJECT_NAME}Config"
        NAMESPACE ${PROJECT_NAME}::
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}"
    )

    install(
        FILES "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}"
    )
endif()