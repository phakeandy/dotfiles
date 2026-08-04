let @j = "^~yiwuA	`json:\"\"`€kl€kl\"€ý5"

if executable('goimports')
	setlocal formatprg=goimports\ -srcdir=%:p:h
endif
setlocal formatexpr=

setlocal makeprg=go\ build
