final: prev: rec {
  options = prev.options // {
    mkDisableOption =
      target:
      prev.mkEnableOption target
      // {
        default = true;
        example = false;
      };
  };

  inherit (options)
    literalCode
    mkDisableOption
    ;
}
