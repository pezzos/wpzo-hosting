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

### 💰 **Cost-Effective Static Hosting**
- **Ultra-low cost operations** - EC2 instances can be shut down when not editing content
- **High availability static sites** - Deploy to S3 + CloudFront for 99.99% uptime
- **Near-zero hosting costs** - AWS Free Tier covers most static site hosting needs
- **Dynamic editing, static delivery** - Best of both worlds: WordPress admin when needed, lightning-fast static sites for visitors

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
                              │
                              v
                       ┌─────────────────┐
                       │   CloudFront    │
                       │ (Global CDN)    │
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

#### Deploy Static Site for Ultra-Low Cost Hosting
```bash
# Sync static files to S3 (requires AWS CLI configuration)
./scripts/s3_fullsync.sh
```

**💡 Cost-Effective Hosting Strategy:**
1. **Content Creation Phase**: Run EC2 instance with full WordPress stack for editing
2. **Static Generation**: Use WordPress to generate content, then export static files
3. **Deploy to S3**: Sync static files to S3 bucket configured for static hosting  
4. **CloudFront Distribution**: Set up CloudFront for global CDN and HTTPS
5. **Shut Down EC2**: Stop expensive EC2 instances when not editing content
6. **Result**: 99.99% uptime static sites with near-zero costs (often free with AWS Free Tier)

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

## 💸 **Ultra-Low Cost Static Hosting Model**

This infrastructure enables a revolutionary cost-effective hosting approach that combines the power of WordPress with the economics of static hosting:

### 📊 **Cost Breakdown**
```
Traditional WordPress Hosting:
├── EC2 t3.small (24/7): ~$15-20/month
├── RDS MySQL: ~$15-25/month  
├── Load Balancer: ~$18/month
└── Total: ~$48-63/month per site

WPZO Static Hosting Model:
├── EC2 t3.small (editing only): ~$2-5/month
├── S3 Storage (1GB): ~$0.02/month
├── CloudFront (100GB): ~$8.50/month
├── Route53 DNS: ~$0.50/month
└── Total: ~$11-14/month (often FREE with AWS Free Tier)
```

### 🚀 **Operational Model**

#### **Phase 1: Content Creation** 
```bash
# Start your WordPress infrastructure for editing
aws ec2 start-instances --instance-ids i-1234567890abcdef0

# Edit content using full WordPress admin
# - Write blog posts
# - Update pages  
# - Install plugins
# - Customize themes
```

#### **Phase 2: Static Deployment**
```bash
# Generate static version of your site
./scripts/s3_fullsync.sh

# Deploy to S3 + CloudFront for global delivery
# Site now serves from AWS edge locations worldwide
```

#### **Phase 3: Cost Optimization**
```bash
# Shut down EC2 instances to save money
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# Your site continues running on S3/CloudFront
# 99.99% uptime, global CDN, HTTPS included
# Cost: Nearly free with AWS Free Tier
```

### 🎯 **Benefits of This Approach**

#### **Performance**
- **Lightning fast**: Static files served from AWS edge locations
- **Global CDN**: CloudFront delivers content from 200+ locations worldwide  
- **Zero server load**: No PHP/MySQL processing for visitors
- **Infinite scalability**: Handle traffic spikes without breaking

#### **Reliability** 
- **99.99% uptime**: AWS S3 SLA guarantee
- **No server crashes**: Static files never go down
- **No security vulnerabilities**: No WordPress exposed to public
- **Automatic failover**: Built into AWS infrastructure

#### **Cost Efficiency**
- **90% cost reduction**: Compared to traditional WordPress hosting
- **Pay only when editing**: EC2 costs only during content updates
- **Free tier eligible**: Most small sites cost $0/month on AWS Free Tier
- **No overprovisioning**: Scale resources exactly to usage

#### **Security**
- **Attack surface = 0**: No WordPress admin exposed to internet
- **No SQL injection**: Static files can't be hacked
- **No plugin vulnerabilities**: WordPress runs in isolated environment
- **DDoS protection**: CloudFront includes DDoS mitigation

### 📈 **Perfect For**
- **Blogs and content sites**: Update weekly/monthly, serve 24/7
- **Portfolio websites**: Rarely updated, always available  
- **Landing pages**: High performance, low maintenance
- **Documentation sites**: Static content with dynamic editing capability
- **E-commerce catalogs**: Update products periodically, serve globally

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