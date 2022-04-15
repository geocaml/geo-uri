let test uri =
  let t = Geo_uri.of_string uri in
  let test = Geo_uri.to_string t in
  print_endline test;
  assert (String.equal uri test)

let () =
  test "geo:1.345,-783.23";
  test "geo:37.786971,-122.399677;crs=Moon-2011;u=35";
  test "geo:37.786971,-122.399677;u=35";
  test "geo:-37.786971,-122.399677;n1=v1;n2;n3=v3"
