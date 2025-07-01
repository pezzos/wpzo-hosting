# wpzo-hosting Project Configuration

## Project Overview
Multi-site WordPress hosting infrastructure with automated site provisioning, deployment, and management.

## Technology Stack
- **Web Server**: Nginx with modular configuration
- **PHP**: PHP-FPM with per-site pools for isolation
- **Database**: MariaDB/MySQL with per-site databases
- **WordPress**: Bedrock boilerplate with Composer
- **Automation**: Bash scripts for lifecycle management
- **SSL**: Let's Encrypt certificates
- **CDN**: Cloudflare integration
- **Storage**: AWS S3 for static site sync

## Architecture Patterns
- **Site Isolation**: Each site has separate directories, PHP-FPM pools, and databases
- **Template-Based Config**: Using envsubst for dynamic configuration generation
- **Automated Provisioning**: Scripts handle complete site lifecycle
- **Security First**: Hardened configurations with proper isolation
- **Git Versioning**: All config changes tracked and committed

## File Structure
```
/path/to/servers/$DOMAIN/$SUB/  # Per-site directories
├── webroot/                   # Site files
├── conf/                      # Site-specific configs
└── php/                       # PHP session/cache dirs

/nginx/
├── sites-available/           # Nginx site configs
├── sites-enabled/            # Active site configs
└── globals/                  # Shared config snippets

/php-fpm.d/                   # PHP-FPM pool configs
/scripts/                     # Automation scripts
```

## Key Scripts
- `host_create.sh` - Create new site with Nginx/PHP-FPM configs
- `db_create.sh` - Provision database and user
- `wp_install.sh` - Install WordPress with Bedrock
- `host_remove.sh` - Remove site and configs
- `s3_fullsync.sh` - Deploy static files to S3

## Security Features
- Per-site PHP-FPM pools with unique sockets
- Nginx restrictions on sensitive files (.git, .htaccess, etc.)
- Automated SSL certificate management
- Security headers (X-Frame-Options, HSTS, etc.)
- Database isolation with per-site credentials
- Real IP handling for Cloudflare

## Development Workflow
1. Create site: `./scripts/host_create.sh domain.tld subdomain`
2. Create database: `./scripts/db_create.sh domain.tld subdomain`
3. Install WordPress: `./scripts/wp_install.sh domain.tld subdomain`
4. Deploy static files: `./scripts/s3_fullsync.sh` (if needed)

## Configuration Templates
Located in `/scripts/template/`:
- `nginx.conf` - Nginx virtual host template
- `phpfpm.conf` - PHP-FPM pool template
- `wp-config.php` - WordPress configuration template
- `env.php` - Environment variables template

## Build/Test Commands
- **Nginx validation**: `nginx -t` - Test Nginx configuration syntax
- **PHP-FPM validation**: `php-fpm -t` - Test PHP-FPM configuration
- **Service status**: `systemctl status nginx php-fpm mariadb` - Check service health
- **Configuration reload**: `systemctl reload nginx php-fpm` - Apply changes
- **Log monitoring**: `tail -f /var/log/nginx/error.log /var/log/php-fpm/error.log`

## Best Practices
- Always test configs before reload (`nginx -t`, `php-fpm -t`)
- Commit configuration changes to Git
- Use consistent naming: `${DOMAIN_STRIP}_${SUB}` for technical names
- Maintain per-site logs for debugging
- Regular Cloudflare IP list updates
- Run validation commands after any configuration changes