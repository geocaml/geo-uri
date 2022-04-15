(lang dune 2.9)

(name geo-uri)

(using mdx 0.1)

(generate_opam_files true)

(source
 (github geocaml/geo-uri))

(license MIT)

(authors "Patrick Ferris")

(maintainers "patrick@sirref.org")

(package
 (name geo-uri)
 (synopsis "Pure OCaml parser for URIs for Geographic Locations")
 (description "This library provides a parser and a builder for URIs for Geographic Locations (RFC5870) using Eio.")
 (depends
   (eio (>= 0.2))
   (mdx :with-test)))