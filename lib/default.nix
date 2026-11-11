final: prev: {
  options = import ./options final prev;
  inherit (final.options)
    mkDisableOption
    literalCode
    ;
}
