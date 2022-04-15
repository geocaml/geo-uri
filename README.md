geo-uri
-------

A pure OCaml library for building and parsing the `geo` URI scheme (a.k.a [RFC5870](https://datatracker.ietf.org/doc/html/rfc5870)).

### Usage

You can build values using the `v` function. The simplest geo URI only has two components, each a coordinate.

```ocaml
# let geo = Geo_uri.v 12.34 45.67;;
val geo : Geo_uri.t = <abstr>
# Geo_uri.to_string geo;;
- : string = "geo:12.34,45.67"
```

More complex examples can add coordinate reference system (CRS) information, the level of uncertainty and additional key-value parameters.

```ocaml
# let geo = Geo_uri.v ~crs:`WGS84 ~uncertainty:1.2 ~params:[ "key", Some "value" ] 12.34 45.67;;
val geo : Geo_uri.t = <abstr>
# let s = Geo_uri.to_string geo;;
val s : string = "geo:12.34,45.67;crs=wgs84;u=1.2;key=value"
```

There are functions to get an OCaml value representing a geo URI from a string too.

```ocaml
# let geo' = Geo_uri.of_string s;;
val geo' : Geo_uri.t = <abstr>
# Geo_uri.coords_arr geo';;
- : float array = [|12.34; 45.67|]
# geo = geo' && s = Geo_uri.to_string geo';;
- : bool = true
```
