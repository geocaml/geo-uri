(*---------------------------------------------------------------------
   Copyright (c) 2022 Patrick Ferris <patrick@sirref.org>
   Distributed under the MIT license, see terms at the end of the file.
  ---------------------------------------------------------------------*)

(* {1 Geo URI scheme} *)

type t
(** A URI following the [geo] scheme. *)

val v :
  ?crs:[ `WGS84 | `Other of string ] ->
  ?uncertainty:float ->
  ?params:(string * string option) list ->
  ?z:float ->
  float ->
  float ->
  t
(** [v x y] creates a new geo URI with an [x] and [y] coordinate.

  @param crs The coordinate reference system
  @param uncertainity The level of precision
  @param params A list of user supplied key-value pairs
  @param z An optional z coordinate
*)

val scheme : string
(** The URI scheme name for geo URIs *)

val coords : t -> float * float * float option
(** [coords t] extracts the coordinate values from the URI. The third 
    coordinate is optional. *)

val coords_arr : t -> float array
(** [coords_arr t] passes the coordinates as a float array that may 
    be of length [2] or [3]. If you want to avoid the extra allocation
    caused by the optional value returned by {! coords}, then use this 
    function. *)

(** {2 Reading} *)

val of_string : string -> t
(** [of_string s] parses the string [s] as a URI in the {i geo} scheme.
    For example, [of_string "geo:1.23,4.56"]. *)

val of_source : Eio.Flow.source -> t
(** Low-level access to the basic parser using an {! Eio.Flow.source}. *)

(** {2 Writing} *)

val to_string : t -> string
(** [to_string t] converts the URI to well-formatted string. *)

val pp : Format.formatter -> t -> unit
(** A pretty-printer for geo URIs. *)

module Parser : sig
  val parse : t Eio.Buf_read.parser
  (** The underlying parses for geo URIs. *)
end

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
