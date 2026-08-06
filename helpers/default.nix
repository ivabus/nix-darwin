{
  no_check =
    drv:
    drv.overrideAttrs {
      doCheck = false;
      doInstallCheck = false;
    };
}
