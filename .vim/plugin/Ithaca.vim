"=============================================================================
" Copyright (c) Huan Li
"
"=============================================================================

let g:MyVimTips = "off"

let s:Level2WinName = "LEVEL2VIEW"
let s:DataWinName = ""

function! s:GetSidePanelNum()
  if exists("s:Level2WinName")
    return bufwinnr(s:Level2WinName)
  else
    return -1
  endif
endfunction

function! s:OpenSidePanelIfNotExist()
  if s:GetSidePanelNum() == -1
    let w=winnr()
    let b=winbufnr(w)
    let s:DataWinName=bufname(b)

    exec 'botright ' . 'vertical ' . 30 . ' new'
    exec 'edit ' . s:Level2WinName
    exec 'set nonumber'

    call s:GoToDataWin()
  endif
endfunction

function! s:CloseSidePanel()
  if s:GetSidePanelNum() != -1
    call s:GoToSidePanel()
    exec 'q!'
  endif
endfunction

function! s:StartUpdate()
  autocmd CursorHold * call s:UpdateSidePanelContent()
endfunction

function! s:StopUpdate()
  autocmd! CursorHold
endfunction

function! s:GoToSidePanel()
  exec s:GetSidePanelNum() . ' wincmd w'
endfunction

function! s:GoToDataWin()
  let w = bufwinnr(s:DataWinName)
  exec w . ' wincmd w'
endfunction

function! s:ReadLevel2Line(line)
  let parts = split(a:line, ',')

  let d = {}
  let variables = ['LocalTimeStamp','DataTimeStamp','LastPx','TotalVolumeTrade','NumTrades','WeightedAvgOfferPx','TotalOfferQty','WeightedAvgBidPx','TotalBidQty','OfferPxA','OfferOrderQtyA','OfferNumOrderA','OfferPx9','OfferOrderQty9','OfferNumOrder9','OfferPx8','OfferOrderQty8','OfferNumOrder8','OfferPx7','OfferOrderQty7','OfferNumOrder7','OfferPx6','OfferOrderQty6','OfferNumOrder6','OfferPx5','OfferOrderQty5','OfferNumOrder5','OfferPx4','OfferOrderQty4','OfferNumOrder4','OfferPx3','OfferOrderQty3','OfferNumOrder3','OfferPx2','OfferOrderQty2','OfferNumOrder2','OfferPx1','OfferOrderQty1','OfferNumOrder1','BidPx1','BidOrderQty1','BidNumOrder1','BidPx2','BidOrderQty2','BidNumOrder2','BidPx3','BidOrderQty3','BidNumOrder3','BidPx4','BidOrderQty4','BidNumOrder4','BidPx5','BidOrderQty5','BidNumOrder5','BidPx6','BidOrderQty6','BidNumOrder6','BidPx7','BidOrderQty7','BidNumOrder7','BidPx8','BidOrderQty8','BidNumOrder8','BidPx9','BidOrderQty9','BidNumOrder9','BidPxA','BidOrderQtyA','BidNumOrderA']

  let i = 0
  for var in variables
    if var != 'DataTimeStamp'
      let d[var] = eval(get(parts, i))
    else
      let d[var] = get(parts, i)
    endif

    let i = i + 1
  endfor

  return d

endfunction

function! s:DeltaFloat2String(delta)
  if a:delta == 0.0
    return '---'
  elseif a:delta > 0
    return printf('+%.2f', a:delta)
  else
    return printf('%.2f', a:delta)
  endif
endfunction

function! s:DeltaNumber2String(delta)
  if a:delta == 0.0
    return '---'
  elseif a:delta > 0
    return printf('+%d', a:delta)
  else
    return printf('%d', a:delta)
  endif
endfunction

function! s:CalcOrderbookDelta(price, vol, bid_or_ask, d_prev)
  if a:price == 0
    return 0
  endif

  if a:bid_or_ask
    for entry in ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'A']
      let price_prev = a:d_prev['BidPx'.entry]
      let vol_prev = a:d_prev['BidOrderQty'.entry]

      if price_prev == a:price
        return a:vol - vol_prev
      endif
    endfor

    if a:price > a:d_prev['BidPx1']
      return a:vol
    else
      return 0
    endif
  else
    for entry in ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'A']
      let price_prev = a:d_prev['OfferPx'.entry]
      let vol_prev = a:d_prev['OfferOrderQty'.entry]

      if price_prev == a:price
        return a:vol - vol_prev
      endif
    endfor

    if a:price < a:d_prev['OfferPx1']
      return a:vol
    else
      return 0
    endif
  endif

endfunction

function! s:UpdateSidePanelContent()
  let w = bufwinnr(s:DataWinName)
  if w == -1
    call ToggleLevel2DataWindow()
  endif

  let l1 = getline(line('.')-1)
  let d1 = s:ReadLevel2Line(l1)

  let l2 = getline('.')
  let d2 = s:ReadLevel2Line(l2)

  call s:GoToSidePanel()

  " remove previous content
  execute 'normal gg0vG$d'

  let current_line = 1
  call setline(current_line, printf('  远程时间 %s', d2['DataTimeStamp']))

  let current_line = current_line + 1
  call setline(current_line, printf('  本地时间 %s', strftime('%H:%M:%S', float2nr(d2['LocalTimeStamp']))))

  let current_line = current_line + 1
  let price = d2['LastPx']
  let price_prev = d1['LastPx']
  call setline(current_line, printf('  最新价格 %s', printf('%-10.2f%s', price, s:DeltaFloat2String(price - price_prev))))

  let current_line = current_line + 1
  let volume = d2['TotalVolumeTrade'] / 100
  let volume_prev = d1['TotalVolumeTrade'] / 100
  call setline(current_line, printf('  成交手数 %s', printf('%-10d%s', volume, s:DeltaNumber2String(volume - volume_prev))))

  let current_line = current_line + 1
  call setline(current_line, '')

  let current_line = current_line + 1

  let tags = {'A': '卖十', '9': '卖九', '8': '卖八', '7': '卖七', '6': '卖六', '5': '卖五', '4': '卖四', '3': '卖三', '2': '卖二', '1': '卖一'}
  for entry in ['A', '9', '8', '7', '6', '5', '4', '3', '2', '1']
    let price = d2['OfferPx'.entry]
    let vol = d2['OfferOrderQty'.entry]
    let delta_vol = s:CalcOrderbookDelta(price, vol, 0, d1)

    if delta_vol != 0
      let delta_s = s:DeltaNumber2String(delta_vol / 100)
    else
      let delta_s = ''
    endif

    let first_part = printf('  %s %5.2f %.0f', tags[entry], price, vol / 100)
    let spaces = '                       '
    if delta_s != ''
      let spaces_appended = strpart(spaces, strlen(first_part))
    else
      let spaces_appended = ''
    endif

    call setline(current_line, printf('%s%s%s', first_part, spaces_appended, delta_s))

    let current_line = current_line + 1
  endfor

  call setline(current_line, '')
  let current_line = current_line + 1

  let tags = {'A': '买十', '9': '买九', '8': '买八', '7': '买七', '6': '买六', '5': '买五', '4': '买四', '3': '买三', '2': '买二', '1': '买一'}
  for entry in ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'A']
    let price = d2['BidPx'.entry]
    let vol = d2['BidOrderQty'.entry]
    let delta_vol = s:CalcOrderbookDelta(price, vol, 1, d1)

    if delta_vol != 0
      let delta_s = s:DeltaNumber2String(delta_vol / 100)
    else
      let delta_s = ''
    endif

    let first_part = printf('  %s %5.2f %.0f', tags[entry], price, vol / 100)
    let spaces = '                       '
    if delta_s != ''
      let spaces_appended = strpart(spaces, strlen(first_part))
    else
      let spaces_appended = ''
    endif

    call setline(current_line, printf('%s%s%s', first_part, spaces_appended, delta_s))

    let current_line = current_line + 1
  endfor

  call s:GoToDataWin()

endfunction

function ToggleLevel2DataWindow()
  if g:MyVimTips == "on"
    let g:MyVimTips="off"
    call s:CloseSidePanel()
    call s:StopUpdate()
  else
    let g:MyVimTips="on"
    "pedit ~/vimtips.txt
    call s:OpenSidePanelIfNotExist()
    call s:StartUpdate()
  endif
endfunction

nnoremap <F4> :call ToggleLevel2DataWindow()<CR>

