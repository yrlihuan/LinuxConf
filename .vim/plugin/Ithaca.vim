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

function! s:ReadFutureL2Line(line)
  let parts = split(a:line, ',')

  let d = {}
  let variables = ['LocalTimeStamp', "UpdateTime", "UpdateMillisec", "LastPrice", "Volume", "OpenInterest", "Turnover", "AveragePrice", "AskPrice5", "AskVolume5", "AskPrice4", "AskVolume4", "AskPrice3", "AskVolume3", "AskPrice2", "AskVolume2", "AskPrice1", "AskVolume1", "BidPrice1", "BidVolume1", "BidPrice2", "BidVolume2", "BidPrice3", "BidVolume3", "BidPrice4", "BidVolume4", "BidPrice5", "BidVolume5"]

  let i = 0
  for var in variables
    if var != 'UpdateTime'
      let d[var] = eval(get(parts, i))
    else
      let d[var] = get(parts, i)
    endif

    let i = i + 1
  endfor

  return d

endfunction

function! s:ReadFutureLine(line)
  let parts = split(a:line, ',')

  let d = {}
  let variables = ['LocalTimeStamp', "UpdateTime", "UpdateMillisec", "LastPrice", "Volume", "OpenInterest", "Turnover", "AveragePrice", "AskPrice1", "AskVolume1", "BidPrice1", "BidVolume1"]

  let i = 0
  for var in variables
    if var != 'UpdateTime'
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

function! s:CalcFutureOrderbookDelta(price, vol, bid_or_ask, d_prev)
  if a:price == 0
    return 0
  endif

  if a:bid_or_ask
    for entry in ['1', '2', '3', '4', '5']
      let price_prev = a:d_prev['BidPrice'.entry]
      let vol_prev = a:d_prev['BidVolume'.entry]

      if price_prev == a:price
        return a:vol - vol_prev
      endif
    endfor

    if a:price > a:d_prev['BidPrice1']
      return a:vol
    else
      return 0
    endif
  else
    for entry in ['1', '2', '3', '4', '5']
      let price_prev = a:d_prev['AskPrice'.entry]
      let vol_prev = a:d_prev['AskVolume'.entry]

      if price_prev == a:price
        return a:vol - vol_prev
      endif
    endfor

    if a:price < a:d_prev['AskPrice1']
      return a:vol
    else
      return 0
    endif
  endif

endfunction

function! s:UpdateLevel2Content()
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
  let volume = float2nr(d2['TotalVolumeTrade'] / 100)
  let volume_prev = float2nr(d1['TotalVolumeTrade'] / 100)
  let volume_delta = float2nr(volume - volume_prev)
  call setline(current_line, printf('  成交手数 %s', printf('%-10d%s', volume, s:DeltaNumber2String(volume_delta))))

  let current_line = current_line + 1
  let offer_volume = float2nr(d2['TotalOfferQty'] / 100)
  let offer_volume_prev = float2nr(d1['TotalOfferQty'] / 100)
  let offer_volume_delta = float2nr(offer_volume - offer_volume_prev)
  call setline(current_line, printf('  卖盘手数 %s', printf('%-10d%s', offer_volume, s:DeltaNumber2String(offer_volume_delta))))

  let current_line = current_line + 1
  let bid_volume = float2nr(d2['TotalBidQty'] / 100)
  let bid_volume_prev = float2nr(d1['TotalBidQty'] / 100)
  let bid_volume_delta = float2nr(bid_volume - bid_volume_prev)
  call setline(current_line, printf('  买盘手数 %s', printf('%-10d%s', bid_volume, s:DeltaNumber2String(bid_volume_delta))))

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

endfunction

function! s:UpdateFutureL2Content()
  let l1 = getline(line('.')-1)
  let d1 = s:ReadFutureL2Line(l1)

  let l2 = getline('.')
  let d2 = s:ReadFutureL2Line(l2)

  call s:GoToSidePanel()

  " remove previous content
  execute 'normal gg0vG$d'

  let current_line = 1
  call setline(current_line, printf('  远程时间 %s', d2['UpdateTime']))

  let current_line = current_line + 1
  call setline(current_line, printf('  本地时间 %s', strftime('%H:%M:%S', float2nr(d2['LocalTimeStamp']))))

  let current_line = current_line + 1
  let price = d2['LastPrice']
  let price_prev = d1['LastPrice']
  call setline(current_line, printf('  最新价格 %s', printf('%-10.2f%s', price, s:DeltaFloat2String(price - price_prev))))

  let current_line = current_line + 1
  let volume = float2nr(d2['Volume'])
  let volume_prev = float2nr(d1['Volume'])
  let volume_delta = float2nr(volume - volume_prev)
  call setline(current_line, printf('  成交手数 %s', printf('%-10d%s', volume, s:DeltaNumber2String(volume_delta))))

  let current_line = current_line + 1
  let open_interest = float2nr(d2['OpenInterest'])
  let open_interest_prev = float2nr(d1['OpenInterest'])
  let open_interest_delta = float2nr(open_interest - open_interest_prev)
  call setline(current_line, printf('  持仓量   %s', printf('%-10d%s', open_interest, s:DeltaNumber2String(open_interest_delta))))

  let current_line = current_line + 1
  call setline(current_line, '')

  let current_line = current_line + 1

  let tags = {'5': '卖五', '4': '卖四', '3': '卖三', '2': '卖二', '1': '卖一'}
  for entry in ['5', '4', '3', '2', '1']
    let price = d2['AskPrice'.entry]
    let vol = d2['AskVolume'.entry]
    let delta_vol = s:CalcFutureOrderbookDelta(price, vol, 0, d1)

    if delta_vol != 0
      let delta_s = s:DeltaNumber2String(delta_vol)
    else
      let delta_s = ''
    endif

    if entry == '1'
      if d2['AskPrice1'] > d1['AskPrice1']
        let arrow = '^'
      elseif d2['AskPrice1'] < d1['AskPrice1']
        let arrow = 'v'
      else
        let arrow = ' '
      endif
    else
      let arrow = ' '
    endif

    let first_part = printf(' %s %s %5.2f %.0f', arrow, tags[entry], price, vol)

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

  if d1['Volume'] == d2['Volume']
    let traded = d2['LastPrice']
  else
    let traded = (d2['Turnover'] - d1['Turnover']) / (d2['Volume'] - d1['Volume']) / 300.0
  endif

  call setline(current_line, printf('   成交 %5.2f %d', traded, volume_delta))
  let current_line = current_line + 1

  call setline(current_line, '')
  let current_line = current_line + 1

  let tags = {'5': '买五', '4': '买四', '3': '买三', '2': '买二', '1': '买一'}
  for entry in ['1', '2', '3', '4', '5']
    let price = d2['BidPrice'.entry]
    let vol = d2['BidVolume'.entry]
    let delta_vol = s:CalcFutureOrderbookDelta(price, vol, 1, d1)

    if delta_vol != 0
      let delta_s = s:DeltaNumber2String(delta_vol)
    else
      let delta_s = ''
    endif

    if entry == '1'
      if d2['BidPrice1'] > d1['BidPrice1']
        let arrow = '^'
      elseif d2['BidPrice1'] < d1['BidPrice1']
        let arrow = 'v'
      else
        let arrow = ' '
      endif
    else
      let arrow = ' '
    endif

    let first_part = printf(' %s %s %5.2f %.0f', arrow, tags[entry], price, vol)

    let spaces = '                       '
    if delta_s != ''
      let spaces_appended = strpart(spaces, strlen(first_part))
    else
      let spaces_appended = ''
    endif

    call setline(current_line, printf('%s%s%s', first_part, spaces_appended, delta_s))

    let current_line = current_line + 1
  endfor

endfunction

function! s:UpdateFutureContent()
  let l1 = getline(line('.')-1)
  let d1 = s:ReadFutureLine(l1)

  let l2 = getline('.')
  let d2 = s:ReadFutureLine(l2)

  call s:GoToSidePanel()

  " remove previous content
  execute 'normal gg0vG$d'

  let current_line = 1
  call setline(current_line, printf('  远程时间 %s', d2['UpdateTime']))

  let current_line = current_line + 1
  call setline(current_line, printf('  本地时间 %s', strftime('%H:%M:%S', float2nr(d2['LocalTimeStamp']))))

  let current_line = current_line + 1
  let price = d2['LastPrice']
  let price_prev = d1['LastPrice']
  call setline(current_line, printf('  最新价格 %s', printf('%-10.2f%s', price, s:DeltaFloat2String(price - price_prev))))

  let current_line = current_line + 1
  let volume = float2nr(d2['Volume'])
  let volume_prev = float2nr(d1['Volume'])
  let volume_delta = float2nr(volume - volume_prev)
  call setline(current_line, printf('  成交手数 %s', printf('%-10d%s', volume, s:DeltaNumber2String(volume_delta))))

  let current_line = current_line + 1
  let open_interest = float2nr(d2['OpenInterest'])
  let open_interest_prev = float2nr(d1['OpenInterest'])
  let open_interest_delta = float2nr(open_interest - open_interest_prev)
  call setline(current_line, printf('  持仓量   %s', printf('%-10d%s', open_interest, s:DeltaNumber2String(open_interest_delta))))

  let current_line = current_line + 1
  call setline(current_line, '')

  let current_line = current_line + 1

  let tags = {'1': '卖一'}
  for entry in ['1']
    let price = d2['AskPrice'.entry]
    let vol = d2['AskVolume'.entry]
    let delta_vol = 0

    if delta_vol != 0
      let delta_s = s:DeltaNumber2String(delta_vol)
    else
      let delta_s = ''
    endif

    let first_part = printf('  %s %5.2f %.0f', tags[entry], price, vol)
    let spaces = '                       '
    if delta_s != ''
      let spaces_appended = strpart(spaces, strlen(first_part))
    else
      let spaces_appended = ''
    endif

    if d2['AskPrice1'] > d1['AskPrice1']
      let arrow = '^'
    elseif d2['AskPrice1'] < d1['AskPrice1']
      let arrow = 'v'
    else
      let arrow = ' '
    endif

    call setline(current_line, printf(' %s%s%s%s', arrow, first_part, spaces_appended, delta_s))

    let current_line = current_line + 1
  endfor

  "call setline(current_line, '')
  "let current_line = current_line + 1

  if d1['Volume'] == d2['Volume']
    let traded = d2['LastPrice']
  else
    let buf = bufname(1)
    if match(buf, 'ru') != -1
      let mult = 10.0
    elseif match(buf, 'cu') != -1
      let mult = 10.0
    else
      let mult = 300.0
    endif

    let traded = (d2['Turnover'] - d1['Turnover']) / (d2['Volume'] - d1['Volume']) / mult
  endif

  call setline(current_line, printf('    成交 %5.2f %d', traded, volume_delta))
  let current_line = current_line + 1

  "call setline(current_line, '')
  "let current_line = current_line + 1

  let tags = {'1': '买一'}
  for entry in ['1']
    let price = d2['BidPrice'.entry]
    let vol = d2['BidVolume'.entry]
    let delta_vol = 0

    if delta_vol != 0
      let delta_s = s:DeltaNumber2String(delta_vol)
    else
      let delta_s = ''
    endif

    let first_part = printf('  %s %5.2f %.0f', tags[entry], price, vol)
    let spaces = '                       '
    if delta_s != ''
      let spaces_appended = strpart(spaces, strlen(first_part))
    else
      let spaces_appended = ''
    endif

    if d2['BidPrice1'] > d1['BidPrice1']
      let arrow = '^'
    elseif d2['BidPrice1'] < d1['BidPrice1']
      let arrow = 'v'
    else
      let arrow = ' '
    endif

    call setline(current_line, printf(' %s%s%s%s', arrow, first_part, spaces_appended, delta_s))

    let current_line = current_line + 1
  endfor

endfunction

function! s:UpdateSidePanelContent()
  let w = bufwinnr(s:DataWinName)
  if w == -1
    call ToggleLevel2DataWindow()
  endif

  let l = getline('.')
  let parts = split(l, ',')

  if len(parts) == 69
    call s:UpdateLevel2Content()
  elseif len(parts) == 12
    call s:UpdateFutureContent()
  elseif len(parts) == 28
    call s:UpdateFutureL2Content()
  endif

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

"nnoremap <F4> :call ToggleLevel2DataWindow()<CR>

