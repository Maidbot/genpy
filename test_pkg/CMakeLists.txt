cmake_minimum_required(VERSION 2.8.3)
project(test_pkg)

find_package(catkin REQUIRED COMPONENTS
  message_generation
  roscpp
  std_msgs
)

add_message_files(
   FILES
   Range.msg
 )

generate_messages(
  DEPENDENCIES
  std_msgs
)

catkin_package(
#  INCLUDE_DIRS include
#  LIBRARIES custom_msgs
  CATKIN_DEPENDS  
  roscpp 
  message_runtime
  std_msgs
#  DEPENDS system_lib
)
