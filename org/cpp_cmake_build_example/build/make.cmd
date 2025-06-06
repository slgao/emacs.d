rem use llvm clang toolset and msvc generator
cmake -G "Visual Studio 14 2015 Win64" -T "LLVM-vs2014"  ..
rem use llvm clang toolset and Ninja generator
rem cmake -G Ninja -T "LLVM-vs2014" ..
cmake --build ./ --config Release

