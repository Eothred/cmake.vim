func! cmake#commands#build()
  echomsg "[cmake] Building all targets..."
  echomsg cmake#util#run_make("all")
endfunc

func! cmake#commands#clean()
  echomsg "[cmake] Cleaning..."
  echomsg cmake#util#run_make("clean")
endfunc

func! cmake#commands#test()
  echomsg "[cmake] Testing project..."
  echomsg cmake#util#run_make("test")
endfunc

func! cmake#commands#install()
  echomsg "[cmake] Installing project..."
  echomsg cmake#util#run_make("install")
endfunc

" TODO: Check if there was a failure of sorts on configuring.
func! cmake#commands#create_build(directory)
  if count(g:cmake_build_directories, a:directory) == 0
    echomsg "[cmake] You should add '" . a:directory . "' to 'g:cmake_build_directories so CMake will be able to find it in the future."
    return 0
  endif

  " Make the directory.
  call mkdir(a:directory, "p")
  if filereadable(a:directory . "/CMakeCache.txt")
    if confirm("[cmake] Remove existing project configuration?", "&Yes\&No") == 1
      call system("rm " a:directory . "/CMakeCache.txt") 
    else
      return
    endif
  endif

  " Prepopulate options for new CMake build.
  let l:build_options = s:get_build_opts()

  " Make the build.
  echomsg "[cmake] Configuring project for the first time..."
  let l:command = "cd " . getcwd() . "/" . a:directory . " && " .
        \ "cmake .. " . l:build_options
  if g:cmake_use_vimux == 1 && g:loaded_vimux
    call VimuxRunCommand(l:command)
  else
    echomsg system(l:command)
  end
  echomsg "[cmake] Project configured."
endfunc

func! s:get_build_opts()
  let l:command =  [ "-DCMAKE_INSTALL_PREFIX:FILEPATH="  . g:cmake_install_prefix ]
  let l:command += [ "-DCMAKE_BUILD_TYPE:STRING="        . g:cmake_build_type ]
  let l:command += [ "-DCMAKE_CXX_COMPILER:FILEPATH="    . g:cmake_cxx_compiler ]
  let l:command += [ "-DCMAKE_C_COMPILER:FILEPATH="      . g:cmake_c_compiler ] 
  "let l:command += [ "-DBUILD_SHARED_LIBS:BOOL="         . g:cmake_build_shared_libs ]
  let l:commandstr = join(l:command, " ")

  return l:commandstr
endfunc!
