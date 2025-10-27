# 資料庫安裝教學

## step 1 安裝docker

```bash
sudo apt update 
```
```bash
sudo apt install -y ca-certificates curl gnupg lsb-release
```
```bash
sudo mkdir -p /etc/apt/keyrings
```
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

```bash 
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
```bash
sudo apt update
```
```bash
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
```bash
cat /etc/wsl.conf
```
```bash
sudo usermod -aG docker $USER
```

## step 2 安裝 supabase

```bash
git clone --filter=blob:none --no-checkout https://github.com/supabase/supabase
```
```bash
git sparse-checkout set --cone docker && git checkout master
```
```bash
cd ..
```
```bash
mkdir database
```
```bash
cp -rf supabase/docker/* database
```
```bash
cp supabase/docker/.env.example database/.env
```
```bash
cd database
```
```bash
docker compose pull
```

### 安裝 npm

```bash
sudo apt install npm
```

```bash
npm install jsonwebtoken
```

```bash
openssl rand -hex 32
```
先創一個檔案 

```javascript
import jwt from "jsonwebtoken";

const secret = "<上面指令產生的32位字符>";

const anon = jwt.sign({ role: "anon" }, secret, { algorithm: "HS256" });
const service = jwt.sign({ role: "service_role" }, secret, { algorithm: "HS256" });

console.log("ANON_KEY=", anon);
console.log("SERVICE_ROLE_KEY=", service);
```

```bash
node gen-jwt.mjs
```

### 將產生的資料填到.env裡面

ANON_KEY=xxxx

SERVICE_ROLE_KEY=xxxxx

DASHBOARD_USERNAME=coselig

DASHBOARD_PASSWORD=ctc53537826

ENABLE_EMAIL_AUTOCONFIRM=true

```
POSTGRES_PASSWORD=your-super-secret-and-long-postgres-password
JWT_SECRET=your-super-secret-jwt-token-with-at-least-32-characters-long
ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlhdCI6MTc2MTUyOTYxNX0.U8n30bwTbJ5SdPRdOT_P1oSoWEMvqQeSZnUvTq5a4I0
SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoic2VydmljZV9yb2xlIiwiaWF0IjoxNzYxNTI5NjE1fQ.6CwLitFM23aYEKtICBnJavde9iCQfBRko5mxQODh_pk
DASHBOARD_USERNAME=coselig
DASHBOARD_PASSWORD=ctc53537826
SECRET_KEY_BASE=UpNVntn3cDxHJpq99YMc1T1AQgQpc8kfYTuRgBiYa15BLrx8etQoXz3gZv1/u2oq
VAULT_ENC_KEY=your-encryption-key-32-chars-min
PG_META_CRYPTO_KEY=your-encryption-key-32-chars-min

POSTGRES_HOST=db
POSTGRES_DB=postgres
POSTGRES_PORT=5432

POOLER_PROXY_PORT_TRANSACTION=6543
POOLER_DEFAULT_POOL_SIZE=20
POOLER_MAX_CLIENT_CONN=100
POOLER_TENANT_ID=your-tenant-id
POOLER_DB_POOL_SIZE=5


KONG_HTTP_PORT=8001
KONG_HTTPS_PORT=8443

PGRST_DB_SCHEMAS=public,storage,graphql_public

SITE_URL=http://192.168.1.10:3000
ADDITIONAL_REDIRECT_URLS=
JWT_EXPIRY=3600
DISABLE_SIGNUP=false
API_EXTERNAL_URL=http://192.168.1.10:${KONG_HTTP_PORT}

MAILER_URLPATHS_CONFIRMATION="/auth/v1/verify"
MAILER_URLPATHS_INVITE="/auth/v1/verify"
MAILER_URLPATHS_RECOVERY="/auth/v1/verify"
MAILER_URLPATHS_EMAIL_CHANGE="/auth/v1/verify"

ENABLE_EMAIL_SIGNUP=true
ENABLE_EMAIL_AUTOCONFIRM=true
SMTP_ADMIN_EMAIL=admin@example.com
SMTP_HOST=supabase-mail
SMTP_PORT=2500
SMTP_USER=fake_mail_user
SMTP_PASS=fake_mail_password
SMTP_SENDER_NAME=fake_sender
ENABLE_ANONYMOUS_USERS=false
ENABLE_PHONE_SIGNUP=true
ENABLE_PHONE_AUTOCONFIRM=true

STUDIO_DEFAULT_ORGANIZATION=Default Organization
STUDIO_DEFAULT_PROJECT=Default Project

SUPABASE_PUBLIC_URL=http://192.168.1.10:${KONG_HTTP_PORT}

IMGPROXY_ENABLE_WEBP_DETECTION=true

OPENAI_API_KEY=

FUNCTIONS_VERIFY_JWT=false

LOGFLARE_PUBLIC_ACCESS_TOKEN=your-super-secret-and-long-logflare-key-public
LOGFLARE_PRIVATE_ACCESS_TOKEN=your-super-secret-and-long-logflare-key-private

DOCKER_SOCKET_LOCATION=/var/run/docker.sock

GOOGLE_PROJECT_ID=GOOGLE_PROJECT_ID
GOOGLE_PROJECT_NUMBER=GOOGLE_PROJECT_NUMBER
```


```bash
docker compose up -d
```
