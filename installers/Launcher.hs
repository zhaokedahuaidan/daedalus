module Launcher where

import qualified Data.List       as L
import           Data.Monoid     ((<>))
import           System.FilePath (pathSeparator)

-- OS dependent configuration
data Launcher = Launcher
    { nodePath             :: String
    , nodeLogPath          :: String
    , walletPath           :: String
    , installerPath        :: String
    , windowsInstallerPath :: Maybe String
    , installerArgs        :: [String]
    , installerArchivePath :: Maybe String
    , runtimePath          :: String
    }

launcherArgs :: Launcher -> String
launcherArgs launcher = unwords $
    maybe [] (("--updater-windows-runner":) . (:[]) . quote) (windowsInstallerPath launcher) ++
  [ "--node", quote (nodePath launcher)
  , "--node-log-path", quote (nodeLogPath launcher)
  , "--wallet", quote (walletPath launcher)
  , "--updater", quote (installerPath launcher)
  , unwords $ map ("-u " ++) (installerArgs launcher)
  , maybe "" (("--update-archive " ++) . quote) (installerArchivePath launcher)
  , "--node-timeout 5"
  , unwords $ map ("-n " ++) nodeArgs
  ]
    where
      nodeArgs = [
        "--report-server", "http://report-server.aws.iohk.io:8080",
        "--listen", "127.0.0.1:12100",
        "--log-config", "log-config-prod.yaml",
        "--update-latest-path", quote (installerPath launcher),
        "--keyfile", quote (runtimePath launcher <> "Secrets" <> (pathSeparator : "secret.key")),
        "--logs-prefix", quote (runtimePath launcher <> "Logs"),
        "--db-path", quote (runtimePath launcher <> "DB-0.4"),
        "--wallet-db-path", quote (runtimePath launcher <> "Wallet-0.4"),
        "--peers-file", "ip-dht-mappings",
        "--system-start", "1492428658",
        "--wallet",
        "--explicit-initial"
        ]

quote :: String -> String
quote p = "\"" <> p <> "\""
