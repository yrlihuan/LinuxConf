function HeaderFileMacroId()
  " Strip path prefix from filepath
  let filepath = expand('%')
  for prefix in split(&path, ',')
    if filepath[:strlen(prefix) - 1] == prefix
      let filepath = filepath[strlen(prefix):]
    endif
  endfor

  let header_id = substitute(filepath, "[-\/\\.]", "_", "g")
  if header_id[0] == '_'
    let header_id = header_id[1:]
  end
  if header_id[-1] != '_'
    let header_id = header_id . '_'
  endif

  return toupper(header_id)
endfunction
