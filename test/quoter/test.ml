open Ppxlib
open Expansion_helpers

module Ast = Ast_builder.Default
[%%expect{|
module Ast = Ppxlib.Ast_builder.Default
|}]


let loc = Location.none
[%%ignore]

let quoter = Quoter.create ();;
[%%expect{|
val quoter : Quoter.t = <abstr>
|}]

let expr1 =
  Ast.evar "foo" ~loc:Location.none
  |> Quoter.quote quoter
[%%ignore]

Pprintast.string_of_expression expr1;;
[%%expect{|
- : string = "__0"
|}]

let expr2 =
  Ast_builder.Default.evar ~loc:Location.none "bar"
  |> Quoter.quote quoter
[%%ignore]

Pprintast.string_of_expression expr2;;
[%%expect{|
- : string = "__1"
|}]

let expr3 =
  Ast.eapply ~loc:Location.none (Ast.evar "foo" ~loc:Location.none) [Ast.eunit ~loc:Location.none]
  |> Quoter.quote quoter
[%%ignore]

Pprintast.string_of_expression expr3;;
[%%expect{|
- : string = "__2 ()"
|}]

let quoted =
  let expr = Ast.elist ~loc:Location.none [expr1; expr2; expr3] in
  Quoter.sanitize quoter expr
[%%ignore]

Pprintast.string_of_expression quoted;;
[%%expect{|
- : string =
"let __2 () = foo ()\nand __1 = bar\nand __0 = foo in [__0; __1; __2 ()]"
|}]

let quoted2 =
  let expr = [%expr fun x -> x] in
  Quoter.sanitize quoter expr
[%%ignore]

Pprintast.string_of_expression quoted2;;
[%%expect{|
- : string =
"fun x -> let __2 () = foo ()\n         and __1 = bar\n         and __0 = foo in x"
|}]

let quoted3 =
  let expr = [%expr function _ -> [%e expr1]] in
  Quoter.sanitize quoter expr
[%%ignore]

Pprintast.string_of_expression quoted3;;
[%%expect{|
- : string =
"fun __arg ->\n  let __2 () = foo ()\n  and __1 = bar\n  and __0 = foo in match __arg with | _ -> __0"
|}]
