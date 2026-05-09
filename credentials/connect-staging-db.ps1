param(
    [Parameter(Mandatory=$true)]
    [string]$dbname
)

$pythonScript = @'
import json, sys

raw = sys.argv[1]
config_path = r'C:\Users\malu.loynaz\credentials\msp-sql-credentials.json'
server_name = 'mssql'
mcp_package = 'mssql-mcp@latest'

# Published MCP server (npm): https://www.npmjs.com/package/mssql-mcp
# Env: DB_SERVER, DB_PORT, DB_DATABASE, DB_USER, DB_PASSWORD (optional),
#      DB_ENCRYPT, DB_TRUST_SERVER_CERTIFICATE

def parse_odbc(conn):
    out = {}
    for segment in conn.split(';'):
        segment = segment.strip()
        if not segment or '=' not in segment:
            continue
        k, v = segment.split('=', 1)
        out[k.strip().lower()] = v.strip()
    return out


def connection_string_to_db_env(parts):
    server_raw = parts.get('server') or parts.get('data source') or ''
    if not server_raw:
        raise ValueError('connectionString missing Server')
    db = parts.get('database') or parts.get('initial catalog')
    if not db:
        raise ValueError('connectionString missing Database')
    host_s, _, port_s = server_raw.partition(',')
    host = host_s.strip()
    port = int(port_s.strip()) if port_s.strip().isdigit() else 1433
    trusted = (parts.get('trusted_connection') or '').lower() == 'yes'
    enc = (parts.get('encrypt') or 'yes').lower() != 'false'
    trust = (parts.get('trustservercertificate') or '').lower() == 'yes'
    env = {
        'DB_SERVER': host,
        'DB_PORT': str(port),
        'DB_DATABASE': db,
        'DB_ENCRYPT': 'true' if enc else 'false',
        'DB_TRUST_SERVER_CERTIFICATE': 'true' if trust else 'false',
    }
    uid = parts.get('uid') or parts.get('user id')
    pwd = parts.get('pwd')
    if not trusted:
        if uid:
            env['DB_USER'] = uid
        if pwd:
            env['DB_PASSWORD'] = pwd
    return env, trusted


# --- Shorthand resolution (same client keys as in msp-sql-credentials.json) ---

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

environment_by_server_key = {'stg': 'staging', 'cs': 'cs'}

parts = raw.split('-')
if len(parts) >= 3 and parts[0] == 'db':
    server_key = parts[1]
    client_key = '-'.join(parts[2:])
else:
    server_key = 'stg'
    client_key = raw

mssql_environment = environment_by_server_key.get(server_key)
if mssql_environment is None:
    print(f'ERROR: Unknown server shorthand "{server_key}". Use stg or cs.')
    sys.exit(1)

client = client_shorthands.get(client_key)
if client is None:
    import re
    if re.match(r'^qa\d+$', client_key):
        client = 'QASandbox' + client_key[2:]
    elif re.match(r'^bdt\d+$', client_key):
        client = 'BDTSandbox' + client_key[3:]
    else:
        client = client_key

with open(config_path, encoding='utf-8') as f:
    cfg = json.load(f)
clients = cfg.get(mssql_environment, {}).get('clients', {})
if client not in clients:
    print(f'ERROR: No client "{client}" under "{mssql_environment}" in {config_path}')
    sys.exit(1)

entry = clients[client]
conn_str = entry.get('connectionString')
if not conn_str:
    print(f'ERROR: Client "{client}" has no connectionString in {config_path}')
    sys.exit(1)

try:
    db_env, trusted = connection_string_to_db_env(parse_odbc(conn_str))
except ValueError as e:
    print(f'ERROR: {e}')
    sys.exit(1)

new_entry = {
    'type': 'stdio',
    'command': 'npx',
    'args': ['-y', mcp_package],
    'env': db_env,
}

# ~/.claude.json (ByDesign.bd project)
with open(r'C:\Users\malu.loynaz\.claude.json', encoding='utf-8') as f:
    claude = json.load(f)
project_key = 'c:/Code/ByDesign.bd'
proj = claude.setdefault('projects', {}).setdefault(project_key, {})
ms = proj.setdefault('mcpServers', {})
ms[server_name] = new_entry
ms.pop('mssql-dbstaging', None)
with open(r'C:\Users\malu.loynaz\.claude.json', 'w', encoding='utf-8') as f:
    json.dump(claude, f, indent=2)
print('Claude Code: updated')

with open(r'C:\Users\malu.loynaz\.cursor\mcp.json', encoding='utf-8') as f:
    cursor = json.load(f)
cursor.setdefault('mcpServers', {})
cursor['mcpServers'][server_name] = new_entry
cursor['mcpServers'].pop('mssql-dbstaging', None)
with open(r'C:\Users\malu.loynaz\.cursor\mcp.json', 'w', encoding='utf-8') as f:
    json.dump(cursor, f, indent=2)
print('Cursor:      updated')
auth = 'Trusted_Connection' if trusted else 'SQL auth'
msg = (
    'Resolved:    ' + raw + '  ->  npx ' + mcp_package + '  '
    + db_env['DB_SERVER'] + ':' + db_env['DB_PORT'] + ' / '
    + db_env['DB_DATABASE'] + ' (' + auth + ')'
)
print(msg)
'@

python -c $pythonScript $dbname

Write-Host ""
Write-Host "Switched '$dbname' to npm mssql-mcp (DB_* from credentials). Restart MCP." -ForegroundColor Yellow
Write-Host "Note: mssql-mcp uses the tedious driver; Windows Integrated auth may need SQL login - test connect." -ForegroundColor DarkYellow
