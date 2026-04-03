
Help()
{
    echo
    echo "Build .dll or .so for this operating system and cpu architecture."
    echo
    echo " -b     (re)build oneTBB"
    echo " -d     (re)build dcon generator"
    echo " -l     (re)build lua generator"
    echo " -g     run generator script"
    echo " -f     fetch repositories and (re)build all"
    echo " -c     clean build folder"
    echo
}

Clean=false
FetchTBB=false
FetchDCon=false
CompileTBB=false
CompileLua=false
CompileDCon=false
GenerateScript=false

# match bash OSTYPE to python platform.machine()
case "$OSTYPE" in
  darwin*)  System="Mac" ;; 
  linux*)   System="Linux" ;;
  msys*)    System="Windows" ;;
  cygwin*)  System="Windows" ;;
  *)        System="unknown: $OSTYPE" ;;
esac
Machine="$(uname -p)"
echo "sh $System $Machine"

#check for optional rebuilding options
while getopts ":hbdlgfc" option; do
    case $option in
        h) # display Help
            Help
            exit;;
        b) # build generators
            CompileTBB=true;;
        d) # build dcon
            CompileDCon=true;;
        l) # compile lua
            CompileLua=true;;
        g) # run generator
            GenerateScript=true;;
        f) # update and build
            rm -rf ./build
            rm -rf ./lib/$System/$Machine
            CompileTBB=true;;
        c) # clean build folder
            Clean=true;;
        \?) # Invalid option
            echo "Error: Invalid option $OPTARG"
            Help
            exit;;
    esac
done

# check for generators
if ! [ -f "./build/$System/$Machine/LuaDLLGenerator" ]; then
    CompileLua=true
fi
if ! [ -f "./build/$System/$Machine/DataContainerGenerator" ]; then
    CompileDCon=true
fi

# check for tbb librariers and includes
if [[ $CompileLua || $CompileDCon ]]; then
    if ! [ -f "./lib/$System/$Machine/libtbb.so" ]; then
        CompileTBB=true
    fi
    if ! [ -d "./build/$System/$Machine/include" ]; then
        CompileTBB=true
    fi
fi

if $CompileTBB && ! [ -d "./build/oneTBB/.git" ]; then
    echo "Fetching oneTBB repository..."
    rm -rf ./build/oneTBB
    git clone https://github.com/uxlfoundation/oneTBB.git ./build/oneTBB --depth 1
fi

if $CompileTBB; then
    echo "Building oneTBB libraries..."
    CompileDCon=true
    CompileLua=true
    rm -rf ./build/libtbb/$System/$Machine
    cmake -S ./build/oneTBB -B ./build/libtbb/$System/$Machine \
        -DCMAKE_POLICY_DEFAULT_CMP0177=NEW -Wno-deprecated \
        -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang \
        -DCMAKE_CXX_STANDARD=20 \
        -DCMAKE_INSTALL_PREFIX=./build/$System/$Machine \
        -DCMAKE_INSTALL_LIBDIR=../../../lib/$System/$Machine \
        -DCMAKE_INSTALL_INCLUDEDIR=./include \
        -DTBB_TEST=OFF #-DCMAKE_BUILD_TYPE=Release
    cmake --build ./build/libtbb/$System/$Machine
    cmake --install ./build/libtbb/$System/$Machine
fi

# clean and redownload repositories
if [[ $CompileDCon || $CompileLua ]] && ! [ -d "./build/DataContainer/.git" ]; then
    echo "Fetching DataContainer repository..."
    git clone https://github.com/ineveraskedforthis/DataContainer.git ./build/DataContainer --depth 1
fi
if [[ $GenerateScript || $CompileDCon || $CompileLua ]]; then
    echo "Running python build script..."
    python3 codegen/generator.py $CompileDCon $CompileLua true true
fi

echo "Running python build script..."
python3 codegen/build.py $CompileDCon $CompileLua true true

if $Clean; then
    echo "Removing build files..."
    rm -rf ./build
fi
