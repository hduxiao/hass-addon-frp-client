# FRP Client Add-on Documentation

## Configuration file
- The add-on reads `/share/frp/frpc.toml` for all FRP client settings.
- On first start, the bundled template (`frp-client/frpc.toml`) is copied to `/share/frp/frpc.toml` if the file does not already exist.
- Edit `/share/frp/frpc.toml` to match your FRP server details (such as `serverAddr`, `serverPort`, and proxy definitions).
- Logs are written to `/share/frp/log/frpc.log` by default; adjust the path in the TOML file if needed.

After saving your changes to `/share/frp/frpc.toml`, restart the add-on to apply the configuration.
