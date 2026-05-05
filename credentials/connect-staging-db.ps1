param(
    [Parameter(Mandatory=$true)]
    [string]$dbname
)

$pythonScript = @"
import json, sys

raw = sys.argv[1]
mcp_path    = r'C:\Code\AI-Examples\mcp\mcp-sqlserver\dist\index.js'
server_name = 'mssql-dbstaging'

# --- Shorthand resolution ---

client_shorthands = {
    'hh':          'HealthyHome',
    'hh-old':      '839229_HealthyHome',
    'adp-clean':   'AdaptureClean',
    'adp-demo':    'AdaptureDemo',
    'adp-shopify': 'AdaptureShopifyDemo',
    'annuity':     'annuity',
    'anovite':     'Anovite',
    'arieyl':      'Arieyl',
    'avere':       'averelife',
    'avroy':       'avroyshlain',
    'beacon':      'beaconofhope',
    'beni':        'benivita',
    'blen':        'blenusa',
    'bodywise':    'BodyWise',
    'bravenly':    'Bravenly',
    'bd':          'ByDesign',
    'bdrev':       'ByDesignRevolution',
    'bduni':       'ByDesignUniversity',
    'cili':        'Cili',
    'crunchi':     'crunchi',
    'ethos':       'ethoslending',
    'faster':      'fasterway',
    'fcd':         'FreedomCD',
    'frc':         'FreedomRC',
    'ght':         'GHTHealth',
    'ghs':         'GlobalHealthSafety',
    'gfp':         'goodfeelingproducts',
    'heavenly':    'heavenlyenhanced',
    'impax':       'ImpaxWorld',
    'jbloom':      'jBloom',
    'jh':          'JHilburn',
    'joi':         'joiandblokes',
    'jordan':      'JordanEssentials',
    'kyani':       'KyaniSun_archive',
    'lbri':        'Lbri',
    'lemon':       'lemongrassspa',
    'lumi':        'lumiceuticals',
    'lmc':         'lunchmoneyclub',
    'magnetu':     'MagnetudeJewelry',
    'magnolia':    'magnoliadesignco',
    'maquira':     'maquira',
    'maysense':    'Maysense',
    'nefful':      'Nefful',
    'phoenix':     'newphoenixrising',
    'newulife':    'NewULife',
    'nuvi':        'NuviGlobalLife',
    'nuvita':      'Nuvitacbd',
    'oliveda':     'OlivedaNT-732',
    'omg':         'omgcontigo',
    'opena':       'opena',
    'oqata':       'oqata',
    'papa':        'Paparazzi',
    'pharma':      'Pharmaziegasse',
    'pixingo':     'Pixingo',
    'pomi':        'Pomifera',
    'purehaven':   'PureHaven',
    'quantum':     'QuantumLifestyle',
    'sendout':     'SendoutCards',
    'sharelife':   'sharelife',
    'shoppy':      'shoppyshop',
    'shopme':      'shopwithme',
    'somnvie':     'somnvie',
    'syona':       'Syona',
    'te':          'TeamEffort',
    'movie':       'TheMovieBookClub',
    'tropic':      'tropicskincare',
    'truaura':     'truaurabeauty',
    'vfinity':     'Vfinity',
    'vista':       'VistaLife',
    'voxx':        'VoxxLife',
    'wayroo':      'wayroo1',
    'wine':        'WineShop',
    'youngevity':  'Youngevity',
    'zilis':       'Zilis',
}

server_shorthands = {
    'stg': '192.168.100.65,9123',
    'cs':  'dbcs,9123',
}

# Parse db-{server}-{client}
parts = raw.split('-')
if len(parts) >= 3 and parts[0] == 'db':
    server_key = parts[1]
    client_key = '-'.join(parts[2:])
else:
    server_key = 'stg'
    client_key = raw

server_addr = server_shorthands.get(server_key, '192.168.100.65,9123')
database    = client_shorthands.get(client_key)
if database is None:
    import re
    if re.match(r'^qa\d+$', client_key):
        database = 'QASandbox' + client_key[2:]
    elif re.match(r'^bdt\d+$', client_key):
        database = 'BDTSandbox' + client_key[3:]
    else:
        database = client_key

# Build connection string directly — no credentials file needed
conn_str = (
    f'Driver={{ODBC Driver 17 for SQL Server}};'
    f'Server={server_addr};'
    f'Database={database};'
    f'Trusted_Connection=yes;'
    f'Encrypt=yes;'
    f'TrustServerCertificate=yes;'
)

new_entry = {
    'type': 'stdio',
    'command': 'node',
    'args': [mcp_path],
    'env': {
        'MSSQL_CONNECTION_STRING': conn_str,
        'MSSQL_DATABASE': database,
        'MSSQL_WINDOWS_INTEGRATED': 'true',
    }
}

# Update ~/.claude.json
with open(r'C:\Users\malu.loynaz\.claude.json', encoding='utf-8') as f:
    claude = json.load(f)
project_key = 'c:/Code/ByDesign.bd'
claude['projects'][project_key]['mcpServers'][server_name] = new_entry
with open(r'C:\Users\malu.loynaz\.claude.json', 'w', encoding='utf-8') as f:
    json.dump(claude, f, indent=2)
print('Claude Code: updated')

# Update ~/.cursor/mcp.json
with open(r'C:\Users\malu.loynaz\.cursor\mcp.json', encoding='utf-8') as f:
    cursor = json.load(f)
cursor['mcpServers'][server_name] = new_entry
with open(r'C:\Users\malu.loynaz\.cursor\mcp.json', 'w', encoding='utf-8') as f:
    json.dump(cursor, f, indent=2)
print('Cursor:      updated')
print(f'Resolved:    {raw}  ->  {server_addr} / {database}')
"@

python -c $pythonScript $dbname

Write-Host ""
Write-Host "Switched to '$dbname'. Restart Claude Code and Cursor to connect." -ForegroundColor Yellow
