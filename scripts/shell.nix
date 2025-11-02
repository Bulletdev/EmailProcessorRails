{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    ruby_3_4_5
    libyaml
    bundler
    postgresql
    redis
    nodejs
  ];
  
  shellHook = ''
    export GEM_HOME=$PWD/.gem
    export PATH=$GEM_HOME/bin:$PATH
    export BUNDLE_PATH=$PWD/.bundle
    echo "Ruby/Rails environment ready with libyaml support"
  '';
}
