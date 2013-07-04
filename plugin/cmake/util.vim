func! cmake#util#rootdir()
  " We need to find the folder at which the file `CMakeCache.txt` can be 
  " found. Hopefully we don't have to transverse up the tree too far to find 
  " it. We'd start from the current working directory and begin to work 
  " our way up. Using some of the names of folders to include in a search like 
  " `build`, `bin`, etc would help sharpen the search.

  if exists("b:cmake_current_binary_dir")
    return b:cmake_current_binary_dir
  else
    let current_dir = getcwd()
    while 1
      let current_dir = cmake#util#find_cmake_build_dir(current_dir)
      if !isdirectory(current_dir)
        let items = split(current_dir, "/")
        if !len(items)
          return 0
        endif

        let current_dir = substitute(current_dir, "/" . items[-1], "", "g")
        continue
      else
        let b:cmake_current_binary_dir = current_dir
        break
      endif
    endwhile
  endif

  return b:cmake_current_binary_dir
endfunc

" TODO: Proper detection of the build directory.
func! cmake#util#run_cmake(argstr)
  " To make life SO much easier for us, we'd just execute CMake in a wrapped 
  " call. It'd be nice to just grab stuff.
  let l:dir = cmake#util#rootdir()
  if !isdirectory(l:dir)
    echoerr "[cmake] Can't find build directory."
    return 0
  else
    let l:command =  [ "cd", l:dir, "&&"]
    let l:command += [ "cmake", l:dir . "/.." ]
    let l:command += [ "-DCMAKE_INSTALL_PREFIX:FILEPATH="  . g:cmake_install_prefix ]
    let l:command += [ "-DCMAKE_BUILD_TYPE:STRING="        . g:cmake_build_type ]
    let l:command += [ "-DCMAKE_CXX_COMPILER:FILEPATH="    . g:cmake_cxx_compiler ]
    let l:command += [ "-DCMAKE_C_COMPILER:FILEPATH="      . g:cmake_c_compiler ] 
    let l:command += [ "-DBUILD_SHARED_LIBS:BOOL="         . g:cmake_build_shared_libs ]
    let l:command += [ a:argstr ]
    let l:commandstr = join(l:command, " ")
    let l:output = system(l:commandstr)
    return l:output
  endif
endfunc

func! cmake#util#run_make(argstr)
  " To make life SO much easier for us, we'd just execute CMake in a wrapped 
  " call. It'd be nice to just grab stuff.
  let l:dir = cmake#util#rootdir()
  if !isdirectory(l:dir)
    echoerr "[cmake] Can't find build directory."
    return 0
  else
    let l:output = system("make -C " . cmake#util#rootdir() . " " . a:argstr)
    return l:output
  endif
endfunc

func! cmake#util#find_cmake_build_dir(dir)
  if filereadable(a:dir . "/CMakeCache.txt")
    return a:dir
  else
    for folder in g:cmake_build_dirs
      if filereadable(a:dir . "/" . folder . "/CMakeCache.txt")
        return a:dir . "/" .folder
      else
        continue
      endif
    endfor
  endif
  return 0
endfunc
