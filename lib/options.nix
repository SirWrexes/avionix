final: prev: {
  options = prev.options // {
    mkDisableOption =
      target:
      prev.mkEnableOption target
      // {
        default = true;
        example = false;
      };
  };

  inherit (final.options)
    mkDisableOption
    literalCode
    ;
}
