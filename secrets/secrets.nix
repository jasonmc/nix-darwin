let
  system-secure-enclave = "age1tag1qdlalyfmgr6v8t9c9007lvzw0vcw9nhw08k7hd2de2zzt4zkekzh6a356uy";
in
{
  "niks3-api-token.age".publicKeys = [ system-secure-enclave ];
}
