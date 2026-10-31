#!/bin/bash

# Callers consume the fields set by jetbrains_product.
# shellcheck disable=SC2034

# Package launchers and desktop IDs from the AUR packages, not Toolbox names.
# Keep the runtime packages: several IDEs split the bundled JBR out of the IDE.
jetbrains_product() {
  jetbrains_is_editor=true
  case "$1" in
  air)
    jetbrains_name="Air"
    # `air` on PATH may be the unrelated Go live-reload tool.
    jetbrains_command="/opt/jetbrains-air/bin/Air"
    jetbrains_desktop="jetbrains-air"
    jetbrains_packages=(jetbrains-air jetbrains-air-jre)
    ;;
  clion)
    jetbrains_name="CLion"
    jetbrains_command="clion"
    jetbrains_desktop="jetbrains-clion"
    jetbrains_packages=(clion clion-jre clion-cmake clion-gdb clion-lldb)
    ;;
  datagrip)
    jetbrains_name="DataGrip"
    jetbrains_command="datagrip"
    jetbrains_desktop="jetbrains-datagrip"
    jetbrains_packages=(datagrip datagrip-jre)
    ;;
  goland)
    jetbrains_name="GoLand"
    jetbrains_command="goland"
    jetbrains_desktop="jetbrains-goland"
    jetbrains_packages=(goland goland-jre)
    ;;
  intellij-idea)
    jetbrains_name="IntelliJ IDEA"
    jetbrains_command="intellij-idea-ultimate-edition"
    jetbrains_desktop="jetbrains-idea"
    jetbrains_packages=(intellij-idea-ultimate-edition)
    ;;
  phpstorm)
    jetbrains_name="PhpStorm"
    jetbrains_command="phpstorm"
    jetbrains_desktop="jetbrains-phpstorm"
    jetbrains_packages=(phpstorm phpstorm-jre)
    ;;
  pycharm)
    jetbrains_name="PyCharm"
    jetbrains_command="pycharm"
    jetbrains_desktop="pycharm"
    jetbrains_packages=(pycharm)
    ;;
  rider)
    jetbrains_name="Rider"
    jetbrains_command="rider"
    jetbrains_desktop="jetbrains-rider"
    jetbrains_packages=(rider)
    ;;
  rubymine)
    jetbrains_name="RubyMine"
    jetbrains_command="jetbrains-rubymine"
    jetbrains_desktop="rubymine"
    jetbrains_packages=(rubymine)
    ;;
  rustrover)
    jetbrains_name="RustRover"
    jetbrains_command="rustrover"
    jetbrains_desktop="jetbrains-rustrover"
    jetbrains_packages=(rustrover rustrover-jre)
    ;;
  webstorm)
    jetbrains_name="WebStorm"
    jetbrains_command="webstorm"
    jetbrains_desktop="jetbrains-webstorm"
    jetbrains_packages=(webstorm webstorm-jre)
    ;;
  toolbox)
    jetbrains_name="JetBrains Toolbox"
    jetbrains_command="jetbrains-toolbox"
    jetbrains_desktop="jetbrains-toolbox"
    jetbrains_packages=(jetbrains-toolbox)
    jetbrains_is_editor=false
    ;;
  gateway)
    jetbrains_name="JetBrains Gateway"
    jetbrains_command="jetbrains-gateway"
    jetbrains_desktop="jetbrains-gateway"
    jetbrains_packages=(jetbrains-gateway jetbrains-gateway-jre)
    jetbrains_is_editor=false
    ;;
  mps)
    jetbrains_name="JetBrains MPS"
    jetbrains_command="jetbrains-mps"
    jetbrains_desktop="jetbrains-mps"
    jetbrains_packages=(jetbrains-mps)
    jetbrains_is_editor=false
    ;;
  *) return 1 ;;
  esac
}
