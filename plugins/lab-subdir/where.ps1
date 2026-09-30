# Minimal MCP stdio server in pure PowerShell: one tool that reports where the
# plugin files were placed. Probe for plugin source types; no binaries.
$utf8 = New-Object System.Text.UTF8Encoding $false
[Console]::InputEncoding = $utf8
[Console]::OutputEncoding = $utf8
function Send($obj) { [Console]::Out.WriteLine(($obj | ConvertTo-Json -Depth 10 -Compress)); [Console]::Out.Flush() }
while ($null -ne ($line = [Console]::In.ReadLine())) {
  if (-not $line.Trim()) { continue }
  $req = $line | ConvertFrom-Json
  if ($null -eq $req.id) { continue }
  switch ($req.method) {
    'initialize' { Send @{ jsonrpc = '2.0'; id = $req.id; result = @{ protocolVersion = $req.params.protocolVersion; capabilities = @{ tools = @{} }; serverInfo = @{ name = 'where'; version = '0.1.0' } } } }
    'tools/list' { Send @{ jsonrpc = '2.0'; id = $req.id; result = @{ tools = @(@{ name = 'where'; description = 'Report the folder this plugin was installed to.'; inputSchema = @{ type = 'object'; properties = @{} } }) } } }
    'tools/call' { Send @{ jsonrpc = '2.0'; id = $req.id; result = @{ content = @(@{ type = 'text'; text = "plugin root: $PSScriptRoot" }) } } }
    default { Send @{ jsonrpc = '2.0'; id = $req.id; error = @{ code = -32601; message = "method not found: $($req.method)" } } }
  }
}
