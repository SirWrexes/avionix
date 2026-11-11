final: prev: {
  options = {
    mkDisableOption =
      target:
      prev.mkEnableOption target
      // {
        default = true;
        example = false;
      };
  };
}
