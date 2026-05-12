param(
    [Parameter(Mandatory=$true)]
    [string]$dbname
)

$pythonScript = @'
import json, sys, os, re, pathlib

raw         = sys.argv[1]
home        = pathlib.Path.home()
mcp_path    = str(home / 'credentials' / 'mcp-mssql' / 'server.py')
claude_path = str(home / '.claude.json')
cursor_path = str(home / '.cursor' / 'mcp.json')
server_name = 'mssql'

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
    if re.match(r'^qa\d+$', client_key):
        database = 'QASandbox' + client_key[2:]
    elif re.match(r'^bdt\d+$', client_key):
        database = 'BDTSandbox' + client_key[3:]
    else:
        database = client_key

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
    'command': 'python',
    'args': [mcp_path],
    'env': {
        'MSSQL_CONNECTION_STRING': conn_str,
        'MSSQL_DATABASE': database,
    }
}

def load_json(path, default):
    try:
        with open(path, encoding='utf-8-sig') as f:
            data = json.load(f)
        return data if isinstance(data, dict) else default
    except (FileNotFoundError, json.JSONDecodeError):
        return default

# Update ~/.claude.json
claude = load_json(claude_path, {})
raw_key = os.environ.get('BYDESIGN_REPO') or os.environ.get('CLAUDE_PROJECT_KEY') or 'c:/Code/ByDesign.bd'
project_key = raw_key.replace('\\', '/')
if not isinstance(claude.get('projects'), dict):
    claude['projects'] = {}
proj = claude['projects'].setdefault(project_key, {})
if not isinstance(proj.get('mcpServers'), dict):
    proj['mcpServers'] = {}
proj['mcpServers'][server_name] = new_entry
os.makedirs(os.path.dirname(claude_path), exist_ok=True)
with open(claude_path, 'w', encoding='utf-8') as f:
    json.dump(claude, f, indent=2)
print(f'Claude Code: updated ({project_key})')

# Update ~/.cursor/mcp.json
cursor = load_json(cursor_path, {})
if not isinstance(cursor.get('mcpServers'), dict):
    cursor['mcpServers'] = {}
cursor['mcpServers'][server_name] = new_entry
os.makedirs(os.path.dirname(cursor_path), exist_ok=True)
with open(cursor_path, 'w', encoding='utf-8') as f:
    json.dump(cursor, f, indent=2)
print(f'Cursor:      updated')
print(f'Resolved:    {raw}  ->  {server_addr} / {database}')
'@

python -c $pythonScript $dbname

Write-Host ""
Write-Host "Switched to '$dbname'. Reload VS Code window and restart Cursor to connect." -ForegroundColor Yellow
