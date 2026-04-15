const { FusesPlugin } = require('@electron-forge/plugin-fuses');
const { FuseV1Options, FuseVersion } = require('@electron/fuses');
const path = require('path');
module.exports = {
  packagerConfig: {
    asar: true,
    icon: path.resolve(__dirname, 'assets/icon'), 
  },
  rebuildConfig: {},
  makers: [
    // Windows Installer
    {
      name: '@electron-forge/maker-squirrel',
      config: {
        setupIcon: path.resolve(__dirname, 'assets/logo.ico')
      }
    },
    // macOS DMG Installer
    {
      name: '@electron-forge/maker-dmg',
      config: {},
    },
    // Zip for all platforms (optional)
    {
      name: '@electron-forge/maker-zip',
      platforms: ['darwin', 'win32'],
    },
    // Linux DEB Installer
    {
      name: '@electron-forge/maker-deb',
      config: {},
    },
    // Linux RPM Installer
    {
      name: '@electron-forge/maker-rpm',
      config: {},
    },
  ],
  plugins: [
    {
      name: '@electron-forge/plugin-auto-unpack-natives',
      config: {},
    },
    new FusesPlugin({
      version: FuseVersion.V1,
      [FuseV1Options.RunAsNode]: false,
      [FuseV1Options.EnableCookieEncryption]: true,
      [FuseV1Options.EnableNodeOptionsEnvironmentVariable]: false,
      [FuseV1Options.EnableNodeCliInspectArguments]: false,
      [FuseV1Options.EnableEmbeddedAsarIntegrityValidation]: true,
      [FuseV1Options.OnlyLoadAppFromAsar]: true,
    }),
  ],
};
