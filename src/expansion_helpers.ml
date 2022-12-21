open Import

module Mangle = struct
  type affix =
    | Prefix of string
    | Suffix of string
    | PrefixSuffix of string * string

  let mangle ?(fixpoint = "t") affix name =
    match (String.(name = fixpoint), affix) with
    | true, (Prefix x | Suffix x) -> x
    | true, PrefixSuffix (p, s) -> p ^ "_" ^ s
    | false, PrefixSuffix (p, s) -> p ^ "_" ^ name ^ "_" ^ s
    | false, Prefix x -> x ^ "_" ^ name
    | false, Suffix x -> name ^ "_" ^ x

  let mangle_type_decl ?fixpoint affix { ptype_name = { txt = name; _ }; _ } =
    mangle ?fixpoint affix name

  let mangle_lid ?fixpoint affix lid =
    match lid with
    | Lident s -> Lident (mangle ?fixpoint affix s)
    | Ldot (p, s) -> Ldot (p, mangle ?fixpoint affix s)
    | Lapply _ -> invalid_arg "Ppxlib.Expansion_helpers.mangle_lid: Lapply"
end

module Quoter = struct
  type t = {
    mutable next_id : int;
    mutable bindings : Parsetree.value_binding list;
  }

  let create () = { next_id = 0; bindings = [] }

  let sanitize t e =
    match t.bindings with
    | [] -> e
    | bindings ->
        let (module Ast) = Ast_builder.make e.pexp_loc in
        Ast.pexp_let Recursive bindings e

  let quote t (e : expression) =
    let loc = e.pexp_loc in
    let (module Ast) = Ast_builder.make loc in
    let name = "__" ^ Int.to_string t.next_id in
    let binding_expr, quoted_expr =
      match e with
      (* Optimize identifier quoting by avoiding closure.
         See https://github.com/ocaml-ppx/ppx_deriving/pull/252. *)
      | { pexp_desc = Pexp_ident _; _ } -> (e, Ast.evar name)
      | _ ->
          let binding_expr =
            Ast.pexp_fun Nolabel None
              (let unit = Ast_builder.Default.Located.lident ~loc "()" in
               Ast.ppat_construct unit None)
              e
          in
          let quoted_expr = Ast.eapply (Ast.evar name) [ Ast.eunit ] in
          (binding_expr, quoted_expr)
    in
    let binding =
      let pat = Ast.pvar name in
      Ast.value_binding ~pat ~expr:binding_expr
    in
    t.bindings <- binding :: t.bindings;
    t.next_id <- t.next_id + 1;
    quoted_expr
end
