# wpzo-hosting Architecture

## System Overview

wpzo-hosting is a comprehensive WordPress hosting infrastructure designed for multi-site management with automated provisioning, security isolation, and deployment capabilities.

## Core Components

### 1. Web Layer (Nginx)
- **Primary web server** handling HTTP/HTTPS requests
- **Modular configuration** with shared snippets in `globals/`
- **Per-site virtual hosts** in `sites-available/` and `sites-enabled/`
- **Security hardening** with file restrictions and headers
- **SSL termination** with Let's Encrypt integration
- **Caching support** for popular WordPress plugins (WP Rocket, W3 Total Cache, etc.)

### 2. Application Layer (PHP-FPM)
- **Per-site isolation** with dedicated PHP-FPM pools
- **Unique sockets** for each site (`/run/php-fpm-${TECHNAME}.sock`)
- **Resource limits** and security restrictions per pool
- **Separate session/upload directories** per site
- **Error logging** with per-site log files

### 3. Database Layer (MariaDB/MySQL)
- **Per-site databases** with isolated users and permissions
- **Automated provisioning** with strong password generation
- **Credential management** through environment files
- **Database cleanup** scripts for site removal

### 4. Automation Layer (Bash Scripts)
- **Lifecycle management** for sites and databases  
- **Template-based configuration** using `envsubst`
- **Service validation** before configuration reload
- **Git integration** for configuration versioning
- **Error handling** with colored output and validation

## Data Flow

```
Internet → Cloudflare → Nginx → PHP-FPM → MariaDB
                     ↓
                Static Files → AWS S3 (optional)
```

## Directory Structure

```
/path/to/
├── work/                    # Working directory (this repo)
│   ├── nginx/              # Nginx configurations
│   ├── php-fpm.d/          # PHP-FPM pool configs
│   ├── scripts/            # Automation scripts
│   └── conf/               # Site registry
└── servers/                # Site storage
    └── $DOMAIN/
        └── $SUB/
            ├── webroot/    # WordPress files
            ├── conf/       # Site-specific configs
            ├── php/        # PHP temp directories
            └── static/     # Static site files (S3 sync)
```

## Security Architecture

### Site Isolation
- **Separate PHP-FPM pools** prevent cross-site contamination
- **Individual file permissions** with nginx:nginx ownership
- **Database isolation** with per-site users and passwords
- **Logging separation** for security auditing

### Web Security
- **File access restrictions** for sensitive files (.git, .env, etc.)
- **Security headers** (X-Frame-Options, X-Content-Type-Options, HSTS)
- **SSL enforcement** with strong cipher suites
- **Rate limiting** and DDoS protection via Cloudflare
- **Real IP restoration** for accurate logging and security

### Application Security
- **PHP hardening** with disabled dangerous functions
- **Upload restrictions** and execution prevention
- **Error display disabled** in production
- **Session security** with separate directories

## Deployment Patterns

### Traditional WordPress Hosting
1. **Site Creation**: `host_create.sh` → Nginx/PHP-FPM configs
2. **Database Setup**: `db_create.sh` → Database and user creation
3. **WordPress Installation**: `wp_install.sh` → Bedrock deployment
4. **SSL Setup**: Automated Let's Encrypt certificate

### Static Site Deployment
1. **WordPress Generation**: Site runs normally for content creation
2. **Static Export**: WordPress generates static files
3. **S3 Sync**: `s3_fullsync.sh` deploys to AWS S3
4. **CDN**: Cloudflare serves static content globally

## Scalability Considerations

### Horizontal Scaling
- **Load balancer** can distribute across multiple servers
- **Database separation** allows for dedicated DB servers
- **Static assets** served from CDN reduce server load
- **Per-site isolation** enables easy site migration

### Performance Optimization
- **Nginx caching** with plugin-specific configurations
- **PHP-FPM optimization** with per-site resource limits
- **Database tuning** with site-specific connection pools
- **Asset optimization** through Cloudflare

## Monitoring and Maintenance

### Logging Strategy
- **Per-site logs** for isolated debugging
- **Centralized error logs** for system-wide issues
- **Access logs** with real IP addresses
- **PHP error logs** with detailed stack traces

### Automated Maintenance
- **Configuration validation** before service reload
- **Git versioning** of all configuration changes
- **Service health checks** after configuration updates
- **Cloudflare IP updates** for accurate real IP detection

## Technology Decisions

### Why Nginx + PHP-FPM?
- **Performance**: Better than Apache for static files and concurrent connections
- **Isolation**: PHP-FPM pools provide better security than mod_php
- **Flexibility**: Easier to configure per-site customizations
- **Resource efficiency**: Lower memory usage for multiple sites

### Why Bedrock?
- **Modern WordPress**: Composer dependency management
- **Environment-based config**: Proper separation of code and configuration
- **Security**: Better file structure and environment variable handling
- **Development workflow**: Git-friendly WordPress deployment

### Why Template-based Configuration?
- **Consistency**: Reduces configuration errors
- **Automation**: Enables script-based site provisioning
- **Maintainability**: Single template updates affect all sites
- **Flexibility**: Easy customization through environment variables