cmake_minimum_required(VERSION 3.15)
set(PROJECT_NAME "clipboard_manager")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "clipboard_manager_plugin")

add_library(${PLUGIN_NAME} SHARED
  "clipboard_manager_plugin.cpp"
)

apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES CXX_VISIBILITY_PRESET hidden)

target_compile_definitions(${PLUGIN_NAME} PRIVATE _SILENCE_CXX17_CODECVT_HEADER_DEPRECATION_WARNING)
target_compile_definitions(${PLUGIN_NAME} PRIVATE "CLIPBOARD_MANAGER_PLUGIN_IMPL")
target_compile_options(${PLUGIN_NAME} PRIVATE /wd4275)

target_include_directories(${PLUGIN_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)
target_link_libraries(${PLUGIN_NAME} PRIVATE User32)

set(clipboard_manager_bundled_libraries
  ""
  PARENT_SCOPE
)