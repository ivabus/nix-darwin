{ pkgs, config, ... }:

let
  # Maybe I should rebase them to my own trusted location one day
  root_ca = pkgs.fetchurl {
    url = "https://gu-st.ru/content/lending/russian_trusted_root_ca_pem.crt";
    hash = "sha256-k2pD/qbo5SW8wPgazZw9IbT8S5torOp5BtaYAFr8ZQQ=";
  };
  sub_ca = pkgs.fetchurl {
    url = "https://gu-st.ru/content/lending/russian_trusted_sub_ca_pem.crt";
    hash = "sha256-8K5YnzZ3TynvNkj3mEsI1C/M5vH/7rYjbXc9rrJ0TqY=";
  };
in
{

  system.activationScripts.postActivation.text =
    if config.networking.hostName != "effundam-x" then
      ''
        if ! /usr/bin/security verify-cert \
          -k /Library/Keychains/System.keychain \
          -c ${root_ca} >/dev/null 2>&1
        then
          echo "Installing trusted root CA..."

          /usr/bin/security add-trusted-cert \
            -d \
            -r trustRoot \
            -k /Library/Keychains/System.keychain \
            ${root_ca}
        fi

        if ! /usr/bin/security verify-cert \
          -k /Library/Keychains/System.keychain \
          -c ${sub_ca} >/dev/null 2>&1
        then
          echo "Installing trusted root CA..."

          /usr/bin/security add-trusted-cert \
            -d \
            -r trustRoot \
            -k /Library/Keychains/System.keychain \
            ${sub_ca}
        fi
      ''
    else
      "";

  # security.pki.certificateFiles = [
  # "${root_ca}"
  # "${sub_ca}"
  # ];
}
