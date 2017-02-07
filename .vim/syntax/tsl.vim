syn case ignore

syn keyword tslBlocks begin end
syn keyword tslConditional if then else
syn keyword tslRepeat for do while to
syn keyword tslJump return continue break
syn keyword tslTryCatch try except with
syn keyword tslInclude uses
syn keyword tslClass class type function
syn keyword tslAccessControl global public private
syn keyword tslUnit unit interface implementation initialization finalization
syn keyword tslOperator and or div mod in union
syn keyword tslBuiltin true false array mcell mcol mrow mtic mtoc
syn keyword tslBuiltinMethods ifnil format echo rdo2 length
syn keyword tslParams setsysparam pn_stock pn_date pn_cycle pn_rate pn_rateday
syn keyword tslParamsValues cy_day cy_week cy_month cy_year
syn keyword tslParamsValues rt_none rt_scale rt_complex rd_firstday
syn keyword tslStockMethods open high low close vol
"syn keyword tslSQL select update from where order by delete
"syn keyword tslSQLSpecial sselect vselect
syn match tslComment "//.*$"
syn match tslFunction
      \ "\%(\%(type\s\|function\s\|unit\s\)\s*\)\@<=\h\%(\w\|\.\)*"

syn region tslString start=+L\="+ skip=+\\\\\|\\"+ end=+"+ contains=@Spell extend
syn region tslString start=+L\='+ skip=+\\\\\|\\'+ end=+'+ contains=@Spell extend
syn region tslSQLBlock start="L\=select" end="end"
syn region tslSQLBlock start="L\=sselect" end="end"
syn region tslSQLBlock start="L\=vselect" end="end"
syn region tslSQLBlock start="L\=update" end="end"

hi link tslComment        Comment
hi link tslBlocks         Special
hi link tslConditional    Conditional
hi link tslRepeat         Repeat
hi link tslInclude        Include
hi link tslClass          Statement
hi link tslJump           Statement
hi link tslAccessControl  Statement
hi link tslTryCatch       Statement
hi link tslUnit           Statement
hi link tslFunction       Function
hi link tslBuiltin        Function
hi link tslBuiltinMethods Function
hi link tslParams         Function
hi link tslParamsValues   Function
hi link tslStockMethods   Function
hi link tslOperator       Operator
hi link tslString         String
hi link tslSQLBlock       Statement
