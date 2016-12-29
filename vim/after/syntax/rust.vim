" See also https://github.com/rust-lang/rust.vim/issues/123
syn match rustQuestionMarkOperator "?" skipwhite skipempty
hi def link rustQuestionMarkOperator rustKeyword
