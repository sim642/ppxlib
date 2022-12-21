open Ppxlib.Expansion_helpers.Mangle ;;

mangle (Prefix "pre") "foo";;
[%%expect{|
- : string = "pre_foo"
|}]

mangle (Suffix "suf") "foo";;
[%%expect{|
- : string = "foo_suf"
|}]

mangle (PrefixSuffix ("pre", "suf")) "foo";;
[%%expect{|
- : string = "pre_foo_suf"
|}]

mangle (Prefix "pre") "t";;
[%%expect{|
- : string = "pre"
|}]

mangle (Suffix "suf") "t";;
[%%expect{|
- : string = "suf"
|}]

mangle (PrefixSuffix ("pre", "suf")) "t";;
[%%expect{|
- : string = "pre_suf"
|}]

mangle ~fixpoint:"foo" (Prefix "pre") "foo";;
[%%expect{|
- : string = "pre"
|}]

mangle ~fixpoint:"foo" (Suffix "suf") "foo";;
[%%expect{|
- : string = "suf"
|}]

mangle ~fixpoint:"foo" (PrefixSuffix ("pre", "suf")) "foo";;
[%%expect{|
- : string = "pre_suf"
|}]
