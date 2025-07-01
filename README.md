# 🚀 WPZO Hosting Infrastructure

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Nginx](https://img.shields.io/badge/nginx-%23009639.svg?style=flat&logo=nginx&logoColor=white)](https://nginx.org/)
[![PHP](https://img.shields.io/badge/php-%23777BB4.svg?style=flat&logo=php&logoColor=white)](https://php.net/)
[![WordPress](https://img.shields.io/badge/WordPress-%23117AC9.svg?style=flat&logo=WordPress&logoColor=white)](https://wordpress.org/)
[![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=flat&logo=mariadb&logoColor=white)](https://mariadb.org/)

> **A production-ready, security-focused WordPress hosting infrastructure with automated site provisioning, isolation, and deployment capabilities.**

## ✨ Features

### 🔐 **Security First**
- **Per-site isolation** with dedicated PHP-FPM pools and database users
- **Automated SSL certificates** via Let's Encrypt integration
- **Security headers** and file access restrictions
- **Real IP handling** for Cloudflare CDN integration
- **Hardened configurations** for all services

### 🤖 **Fully Automated**
- **One-command site creation** with complete infrastructure setup
- **Template-based configurations** with environment variable substitution
- **Automated WordPress installation** using modern Bedrock boilerplate
- **Service validation** and automatic reloading
- **Git-based configuration management**

### 🏗️ **Production Ready**
- **Multi-site architecture** supporting unlimited WordPress installations
- **High-performance Nginx** with caching and optimization
- **Resource isolation** and monitoring capabilities
- **Static site deployment** to AWS S3
- **Comprehensive logging** and error handling

### 📦 **Modern Stack**
- **Nginx** - High-performance web server
- **PHP-FPM** - Scalable PHP process manager
- **MariaDB/MySQL** - Reliable database server
- **WordPress Bedrock** - Modern WordPress boilerplate
- **Let's Encrypt** - Free SSL certificate automation
- **Cloudflare** - CDN and DDoS protection

## 🏛️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Cloudflare    │ -> │     Nginx       │ -> │    PHP-FPM      │
│     (CDN)       │    │  (Web Server)   │    │  (App Server)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │                        │
                              v                        v
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Let's Encrypt │    │   File System   │    │   MariaDB       │
│     (SSL)       │    │   (Websites)    │    │  (Databases)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              v
                       ┌─────────────────┐
                       │     AWS S3      │
                       │ (Static Deploy) │
                       └─────────────────┘
```

### Directory Structure
```
/path/to/servers/
├── domain1.com/
│   ├── www/
│   │   ├── webroot/     # WordPress files
│   │   ├── conf/        # Site configs
│   │   ├── php/         # PHP temp dirs
│   │   └── static/      # Static files
│   └── api/
│       └── webroot/
└── domain2.com/
    └── www/
        └── webroot/
```

## 🚀 Quick Start

### Prerequisites
- **Linux server** (Ubuntu 20.04+ or CentOS 8+ recommended)
- **Root access** or sudo privileges
- **Domain names** with DNS pointing to your server
- **Basic shell scripting knowledge**

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/wpzo-hosting.git
   cd wpzo-hosting
   ```

2. **Install dependencies**
   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt install nginx php-fpm mariadb-server certbot python3-certbot-nginx

   # CentOS/RHEL
   sudo yum install nginx php-fpm mariadb-server certbot python3-certbot-nginx
   ```

3. **Configure base directories**
   ```bash
   # Create working directories
   sudo mkdir -p /path/to/servers
   sudo mkdir -p /path/to/work
   
   # Set permissions
   sudo chown -R nginx:nginx /path/to/servers
   ```

4. **Update configuration paths**
   ```bash
   # Edit scripts to match your directory structure
   export SERVERDIR="/path/to/servers"
   export WORKDIR="/path/to/work"
   ```

### Creating Your First Site

```bash
# 1. Create the hosting infrastructure
./scripts/host_create.sh example.com www

# 2. Create the database
./scripts/db_create.sh example.com www

# 3. Install WordPress
./scripts/wp_install.sh example.com www

# 4. Your site is now live at https://www.example.com
```

## 📚 Usage Guide

### Site Management

#### Create a New Site
```bash
# Standard WordPress site
./scripts/host_create.sh domain.com subdomain
./scripts/db_create.sh domain.com subdomain
./scripts/wp_install.sh domain.com subdomain

# Example: Create blog.mysite.com
./scripts/host_create.sh mysite.com blog
./scripts/db_create.sh mysite.com blog
./scripts/wp_install.sh mysite.com blog
```

#### Remove a Site
```bash
# Remove site infrastructure
./scripts/host_remove.sh domain.com subdomain

# Remove database
./scripts/db_remove.sh domain.com subdomain

# Example: Remove blog.mysite.com
./scripts/host_remove.sh mysite.com blog
./scripts/db_remove.sh mysite.com blog
```

#### Deploy Static Site
```bash
# Sync static files to S3 (requires AWS CLI configuration)
./scripts/s3_fullsync.sh
```

### Configuration Management

#### Nginx Configuration
- **Global settings**: `nginx/nginx.conf`
- **Site templates**: `scripts/template/nginx.conf`
- **Security settings**: `nginx/globals/`
- **Cache configurations**: `nginx/globals/cache/`

#### PHP-FPM Configuration
- **Pool template**: `scripts/template/phpfpm.conf`
- **Site-specific pools**: `php-fpm.d/`
- **PHP settings**: `php.ini`

#### WordPress Configuration
- **WordPress template**: `scripts/template/wp-config.php`
- **Environment template**: `scripts/template/env.php`
- **Plugin configuration**: Built into installation script

### Monitoring and Maintenance

#### Check Service Status
```bash
# Service health
systemctl status nginx php-fpm mariadb

# Test configurations
nginx -t
php-fpm -t

# View logs
tail -f /var/log/nginx/error.log
tail -f /var/log/php-fpm/error.log
```

#### Update Cloudflare IPs
```bash
# Update real IP list for accurate logging
./nginx/scripts/update-cloudflare-ip-list.sh
```

## 🔧 Advanced Configuration

### Custom Site Templates

Create custom templates in `scripts/template/` for specialized deployments:

```bash
# Custom Nginx configuration
cp scripts/template/nginx.conf scripts/template/nginx-custom.conf
# Edit nginx-custom.conf with your modifications

# Use custom template
NGINX_TEMPLATE="nginx-custom.conf" ./scripts/host_create.sh domain.com subdomain
```

### SSL Certificate Management

```bash
# Manual certificate generation
certbot --nginx -d domain.com -d www.domain.com

# Certificate renewal (automated via cron)
certbot renew --quiet
```

### Performance Optimization

#### PHP-FPM Tuning
```ini
# In php-fpm pool configuration
pm = dynamic
pm.max_children = 20
pm.start_servers = 5
pm.min_spare_servers = 3
pm.max_spare_servers = 8
```

#### Nginx Caching
```nginx
# Enable caching for static assets
location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

## 🛡️ Security Features

### Per-Site Isolation
- **Separate PHP-FPM pools** prevent cross-site contamination
- **Individual database users** with minimal privileges
- **Isolated file permissions** with proper ownership
- **Separate log files** for security auditing

### Web Security
- **Security headers** (HSTS, X-Frame-Options, CSP)
- **File access restrictions** (.git, .env, sensitive files)
- **SSL enforcement** with strong cipher suites
- **Rate limiting** via Cloudflare integration

### Application Security
- **PHP hardening** with disabled dangerous functions
- **Upload restrictions** and execution prevention
- **Error display disabled** in production
- **Session security** with separate directories

## 📊 Monitoring

### Built-in Health Checks
```bash
# Service validation
nginx -t && echo "Nginx OK"
php-fpm -t && echo "PHP-FPM OK"
systemctl is-active nginx php-fpm mariadb

# Site accessibility
curl -I https://your-domain.com
```

### Log Analysis
```bash
# Error monitoring
tail -f /var/log/nginx/error.log | grep ERROR

# Access patterns
tail -f /var/log/nginx/access.log | grep "POST\|404"

# PHP errors
tail -f /var/log/php-fpm/www-error.log
```

## 🚦 Troubleshooting

### Common Issues

#### Site Creation Fails
```bash
# Check directory permissions
ls -la /path/to/servers/

# Verify service status
systemctl status nginx php-fpm

# Test configuration
nginx -t
php-fpm -t
```

#### SSL Certificate Issues
```bash
# Check certificate status
certbot certificates

# Manual renewal
certbot renew --dry-run

# Check domain DNS
dig your-domain.com
```

#### Database Connection Problems
```bash
# Test database connection
mysql -u username -p database_name

# Check MySQL status
systemctl status mariadb

# Review database logs
tail -f /var/log/mysql/error.log
```

### Getting Help

1. **Check the logs** - Most issues are logged in service logs
2. **Validate configurations** - Use built-in test commands
3. **Review permissions** - Ensure proper file ownership
4. **Check DNS** - Verify domain resolution
5. **Test connectivity** - Use curl/telnet for network issues

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup
```bash
# Fork and clone the repository
git clone https://github.com/yourusername/wpzo-hosting.git

# Create a feature branch
git checkout -b feature/your-feature-name

# Make your changes and test thoroughly
./scripts/test_configuration.sh

# Submit a pull request
```

### Code Standards
- **Shell scripts** should be POSIX-compliant where possible
- **Configuration files** must include inline documentation
- **All changes** require validation scripts
- **Commit messages** should be descriptive and reference issues

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Nginx** community for excellent documentation
- **WordPress Bedrock** for modern WordPress architecture
- **Let's Encrypt** for free SSL certificates
- **Cloudflare** for CDN and security services
- **PHP-FPM** team for robust process management

## 📈 Project Status

This project is **production-ready** and actively maintained. It has been used to host multiple WordPress sites in production environments.

### Roadmap
- [ ] Web-based management interface
- [ ] Advanced monitoring dashboard
- [ ] Multi-server clustering support
- [ ] Container-based deployments
- [ ] Enhanced backup automation

---

**Made with ❤️ for the WordPress community**

*If this project helped you, please consider giving it a ⭐ on GitHub!*