(*---------------------------------------------------------------------
   Copyright (c) 2022 Patrick Ferris <patrick@sirref.org>
   Distributed under the MIT license, see terms at the end of the file.
  ---------------------------------------------------------------------*)

let scheme = "geo"

type t = {
  coords : float array;
  crs : [ `WGS84 | `Other of string ] option;
  uncertainty : float option;
  params : (string * string option) list;
}

let v ?crs ?uncertainty ?(params = []) ?z x y =
  {
    coords = (match z with Some z -> [| x; y; z |] | _ -> [| x; y |]);
    crs;
    uncertainty;
    params;
  }

let coords { coords; _ } =
  (coords.(0), coords.(1), try Some coords.(2) with _ -> None)

let coords_arr t = t.coords

let pp_crs ppf = function
  | None -> ()
  | Some `WGS84 -> Format.fprintf ppf ";crs=wgs84"
  | Some (`Other s) -> Format.fprintf ppf ";crs=%s" s

let pp_u ppf = function None -> () | Some f -> Format.fprintf ppf ";u=%.16g" f
let pp_z ppf = function None -> () | Some f -> Format.fprintf ppf ",%.16g" f

let pp_params ppf =
  let pp_param ppf = function
    | name, None -> Format.fprintf ppf ";%s" name
    | name, Some value -> Format.fprintf ppf ";%s=%s" name value
  in
  Format.fprintf ppf "%a"
    (Format.pp_print_list ~pp_sep:(fun _ _ -> ()) pp_param)

let pp ppf t =
  let x, y, z = coords t in
  Format.fprintf ppf "geo:%.16g,%.16g%a%a%a%a" x y pp_z z pp_crs t.crs pp_u
    t.uncertainty pp_params t.params

let to_string t =
  Format.(fprintf str_formatter "%a" pp t);
  Format.flush_str_formatter ()

module Parser = struct
  open Eio.Buf_read
  open Syntax

  let scheme = string scheme
  let colon = char ':'
  let comma = char ','
  let return x _ = x

  let at_end_then v f =
    let* at_end = at_end_of_input in
    if at_end then return v else f

  let check_string (s : string) (f : 'a parser) b : 'a option =
    let l = String.length s in
    let buf = peek b in
    match String.equal s Cstruct.(to_string ~off:0 ~len:l buf) with
    | true ->
        consume b l;
        let v = f b in
        Some v
    | false -> None

  let is_numberish = function '0' .. '9' | '-' | '.' -> true | _ -> false

  let is_alphanum = function
    | 'a' .. 'z' | 'A' .. 'Z' -> true
    | '.' -> false
    | c -> is_numberish c

  let number =
    let+ num = take_while is_numberish in
    try float_of_string num with _ -> invalid_arg "Failed to parse number"

  let coordinates =
    let* x = number <* comma in
    let* y = number in
    let* c = peek_char in
    match c with
    | Some ',' ->
        let+ z = number in
        [| x; y; z |]
    | _ ->
        let+ () = skip 0 in
        [| x; y |]

  let alphanum = take_while is_alphanum

  let crs =
    let+ crs = check_string ";crs=" alphanum in
    match (crs, Option.map String.lowercase_ascii crs) with
    | _, Some "wgs84" -> Some `WGS84
    | Some crs, Some _ -> Some (`Other crs)
    | _ -> None

  let uncertainty =
    (* TODO: definition must have 1 digit on each side of the decimal point *)
    check_string ";u=" number

  let params =
    let pv s =
      match String.split_on_char '=' s with
      | [ n; v ] -> (n, Some v)
      | _ -> (s, None)
    in
    let* c = peek_char in
    match c with
    | Some ';' ->
        let+ params = take_all in
        let params = String.split_on_char ';' params in
        List.map pv
          (List.filter_map (function "" -> None | s -> Some s) params)
    | Some _ | None -> return []

  let parse =
    let+ coords = scheme *> colon *> coordinates
    and+ crs = at_end_then None crs
    and+ uncertainty = at_end_then None uncertainty
    and+ params = at_end_then [] params in
    { coords; crs; uncertainty; params }
end

let of_source src = Eio.Buf_read.parse_exn ~max_size:max_int Parser.parse src

let of_string s =
  let src = Eio.Flow.string_source s in
  of_source src

(*---------------------------------------------------------------------------
   Copyright (c) 2022 Patrick Ferris <patrick@sirref.org>

   Permission to use, copy, modify, and/or distribute this software for any
   purpose with or without fee is hereby granted, provided that the above
   copyright notice and this permission notice appear in all copies.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
   THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
   DEALINGS IN THE SOFTWARE.
  ---------------------------------------------------------------------------*)
