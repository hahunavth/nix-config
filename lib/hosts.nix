# Host registry loader: validates and enriches hosts.nix entries.
# Adapted from mlgruby/dotfile-nix (lib/hosts.nix).
{ hostsPath }:
let
  hostsConfigPresent = builtins.pathExists hostsPath;
  hostsConfig = if hostsConfigPresent then import hostsPath else { };
  hostsCommonConfig = hostsConfig.common or { };
  hostsEntries = hostsConfig.hosts or { };
  hostsEntryNames = builtins.attrNames hostsEntries;

  requiredAttrs = [
    "username"
    "hostname"
    "fullName"
    "githubUsername"
  ];

  # merge common identity into each host entry and fill defaults
  mkEnhancedConfig =
    commonConfig: rawConfig:
    let
      mergedConfig = commonConfig // rawConfig;
    in
    mergedConfig
    // {
      email = mergedConfig.email or "";
      workEmail = mergedConfig.workEmail or "";
      profile = mergedConfig.profile or "personal";
      signingKey = mergedConfig.signingKey or "";
    };

  validateConfig =
    sourceName: config:
    let
      missingAttrs = builtins.filter (attr: !(builtins.hasAttr attr config)) requiredAttrs;
      hostname = config.hostname or "";
      email = config.email or "";
      validEmail =
        email == "" || builtins.match "[^[:space:]@]+@[^[:space:]@]+\\.[^[:space:]@]+" email != null;
      validFormat = builtins.match "[a-zA-Z0-9]+(-[a-zA-Z0-9]+)*" hostname != null;
      validProfiles = [
        "personal"
        "work"
      ];
      profile = config.profile or "personal";
    in
    if builtins.length missingAttrs > 0 then
      throw "Missing required attributes in ${sourceName}: ${builtins.toString missingAttrs}"
    else if !validEmail then
      throw "Invalid email in ${sourceName}: '${email}'. Use a valid email like name@example.com."
    else if hostname == "" || !validFormat then
      throw "Invalid hostname format in ${sourceName}: ${hostname}. Use only letters, numbers, and hyphens."
    else if !(builtins.elem profile validProfiles) then
      throw "Invalid profile '${profile}' in ${sourceName}. Allowed values: ${builtins.toString validProfiles}"
    else
      config;

  sourceConfigs =
    if !hostsConfigPresent then
      throw ''
        hosts.nix not found.
        Create it from hosts.example.nix:
          cp hosts.example.nix hosts.nix
      ''
    else if builtins.length hostsEntryNames == 0 then
      throw "hosts.nix is missing entries under `hosts`."
    else
      builtins.map (name: {
        sourceName = "hosts.nix:${name}";
        rawConfig = hostsEntries.${name};
        commonConfig = hostsCommonConfig;
      }) hostsEntryNames;

  validatedConfigs = builtins.map (
    source: validateConfig source.sourceName (mkEnhancedConfig source.commonConfig source.rawConfig)
  ) sourceConfigs;
  hostnames = builtins.map (cfg: cfg.hostname) validatedConfigs;
  uniqueHostnames = builtins.attrNames (
    builtins.listToAttrs (
      builtins.map (hostname: {
        name = hostname;
        value = true;
      }) hostnames
    )
  );
in
{
  validatedConfigsChecked =
    if builtins.length hostnames == builtins.length uniqueHostnames then
      validatedConfigs
    else
      throw "Duplicate hostnames found in host config entries: ${builtins.toString hostnames}";
}
