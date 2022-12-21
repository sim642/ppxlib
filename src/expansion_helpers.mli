(** Various helpers for expansion. *)

open Import

(** {2 Mangling} *)

(** Derive mangled names from type names in a deriver. *)
module Mangle : sig
  (** Specification for name mangling. *)
  type affix =
    | Prefix of string  (** [Prefix p] adds prefix [p]. *)
    | Suffix of string  (** [Suffix s] adds suffix [s]. *)
    | PrefixSuffix of string * string
        (** [PrefixSuffix (p, s)] adds both prefix [p] and suffix [s]. *)

  val mangle : ?fixpoint:string -> affix -> string -> string
  (** [mangle ~fixpoint affix s] derives a mangled name from [s] with the
      mangling specified by [affix]. If [s] is equal to [fixpoint] (["t"] by
      default), then [s] is omitted from the mangled name. *)

  val mangle_type_decl : ?fixpoint:string -> affix -> type_declaration -> string
  (** [mangle_type_decl ~fixpoint affix td] does the same as {!mangle}, but for
      the name of [td]. *)

  val mangle_lid : ?fixpoint:string -> affix -> Longident.t -> Longident.t
  (** [mangle_lid ~fixpoint affix lid] does the same as {!mangle}, but for the
      last component of [lid]. *)
end

(** {2 Quoting} *)

module Quoter : sig
  (** Generate expressions in a hygienic way.

      The idea is that whenever we want to refer to an expression in generated
      code we first quote it. The result will be an identifier that is
      guaranteed to refer to the expression it was created from. This way it is
      impossible for quoted fragments to refer to newly introduced expressions. *)

  open Import

  type t

  val create : unit -> t
  (** Creates a quoter. A quoter guarantees to give names that do not clash with
      any other names used before *)

  val quote : t -> expression -> expression
  (** [quote t e] returns the expression that is safe to use in place of [e] in
      generated code*)

  val sanitize : t -> expression -> expression
  (** [sanitize t e] Returns [e] wrapped with bindings for all quoted
      expressions in the quoter [t] *)
end
