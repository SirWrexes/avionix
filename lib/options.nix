lib:
let
  base = lib.options;
  inherit (base)
    mkEnableOption
    ;
in
{
  options = base // {
    mkDisableOption =
      target:
      mkEnableOption target
      // {
        default = true;
        example = false;
      };
  };
}
