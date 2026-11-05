# One add_subdirectory() per application. Applications are thin: they wire
# libraries together and handle I/O; all logic lives in libs/.
add_subdirectory(cli)
