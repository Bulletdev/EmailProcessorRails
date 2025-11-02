#  Bullet Mail: Email Processor on Rails

[![CI](https://github.com/bulletdev/EmailProcessorRails/actions/workflows/ci.yml/badge.svg)](https://github.com/bulletdev/EmailProcessorRails/actions/workflows/ci.yml)
[![Ruby Version](https://img.shields.io/badge/ruby-3.4.5-CC342D?logo=ruby)](https://www.ruby-lang.org/)
[![Rails Version](https://img.shields.io/badge/rails-7.2-CC342D?logo=rubyonrails)](https://rubyonrails.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14+-blue.svg?logo=postgresql)](https://www.postgresql.org/)
[![Redis](https://img.shields.io/badge/Redis-6+-red.svg?logo=redis)](https://redis.io/)
[![Sidekiq](https://img.shields.io/badge/sidekiq-7.3-orange.svg)](https://sidekiq.org)
[![License](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)](http://creativecommons.org/licenses/by-nc-sa/4.0/)

> **E-mail processing system with intelligent natural language parsing**

A robust Ruby on Rails application that processes .eml email files from multiple vendors, 
extracting structured customer data using an intelligent, vendor-specific parsing system. 

Built with scalability, maintainability, and real-world use cases in mind.

---
<details>
<summary>Key Features & DifferentiatorsArchitecture (click 2 show details)</summary>


###  Modern User Experience
- ✅ **Bulk Upload**: Process multiple .eml files simultaneously (ideal for real-world scenarios)
- ✅ **Real-time Dashboard**: Live statistics showing total emails, success/failure rates, and customer count
- ✅ **Auto-refresh**: Pages automatically update when emails are being processed
- ✅ **Modern UI**: Gradient design, animations, drag & drop support, and responsive layout
- ✅ **Smart Status Display**: Three-state system (Pending/Success/Failed) prevents user confusion
- ✅ **Modal Data Viewing**: Clean interface with popup windows for detailed data inspection

###  Product Code Extraction
Unlike basic regex parsers, our system uses **multi-strategy natural language processing** to extract product codes even when customers write in natural language:

- ✅ **Structured formats**: `Produto: ABC123`, `Código: XYZ789`
- ✅ **Natural language**: "interessado no produto de código ABC123"
- ✅ **Subject line extraction**: Automatically parses subjects like "Pedido - Produto XYZ987"
- ✅ **Intelligent fallback**: Pattern recognition for standalone codes (e.g., `ABC123`, `PROD-999`)
- ✅ **100% extraction rate** on real-world test data
  </details>

**Why this matters**: Most competitors fail when customers don't follow exact formats.

my system handles real human communication, significantly reducing manual intervention.

<details>
<summary>Architecture</summary>

- **Strategy Pattern** implementation for vendor-specific parsers
- **Async processing** with Sidekiq for high-throughput scenarios
- **SOLID principles** - easily extend without modifying existing code
- **Comprehensive logging** with automatic retention policies
- **UTF-8 encoding handling** to prevent common parsing errors
- CI/CD pipeline with GitHub Actions
-  test coverage (RSpec)
- Secure Sidekiq web interface with authentication
- Automatic data cleanup with configurable retention policies

</details>

---

##  Table of Contents

- [Technologies](#-technologies)
- [Quick Start](#-quick-start)
- [Architecture Deep Dive](#-architecture-deep-dive)
- [Intelligent Parser System](#-intelligent-parser-system)
- [Usage](#-usage)
- [Testing](#-testing)
- [API & Integration](#-api--integration)
- [Deployment](#-deployment)
- [Contributing](#-contributing)

---

##  Technologies

| Category | Technology | Version | Purpose |
|----------|-----------|---------|---------|
| **Backend** | Ruby | 3.4.5 | Application runtime |
| **Framework** | Rails | 7.2.3 | Web framework |
| **Database** | PostgreSQL | 15+ | Primary data store with JSONB support |
| **Cache/Queue** | Redis | 7+ | Job queue & caching |
| **Jobs** | Sidekiq | 7.3.9 | Async job processing |
| **Scheduling** | Sidekiq-Cron | 1.12 | Scheduled jobs (log cleanup) |
| **Frontend** | Bootstrap | 5.3.2 | Responsive UI framework |
| **Icons** | Bootstrap Icons | 1.11.1 | Modern icon set |
| **Email Parsing** | Mail Gem | 2.8+ | RFC822 email parsing |
| **Storage** | Active Storage | - | .eml file management |
| **Testing** | RSpec | 3.13+ | Comprehensive test suite |
| **Containerization** | Docker | Latest | Consistent deployment |

---

## Quick Start

### Prerequisites
- Docker & Docker Compose (recommended)
- OR: Ruby 3.4+, PostgreSQL 15+, Redis 7+

### Installation (Docker - Recommended)

```bash
# 1. Clone the repository
git clone https://github.com/bulletdev/EmailProcessorRails.git
cd EmailProcessorRails

# 2. Configure environment (optional - defaults provided)
cp .env.example .env

# 3. Build and start all services
docker-compose up --build

# 4. Run database migrations
docker-compose exec -T app bundle exec rails db:migrate

# 5. Access the application
open http://localhost:5999
```

**That's it!** The application is now running with:
- Web app: http://localhost:5999
- Sidekiq UI: http://localhost:5999/sidekiq
- PostgreSQL: localhost:5499
- Redis: localhost:6399

### Manual Installation (Alternative)

<details>
<summary>Click to expand manual installation steps</summary>

```bash
# 1. Install dependencies
bundle install

# 2. Configure database
cp config/database.yml.example config/database.yml
# Edit with your PostgreSQL credentials

# 3. Create and migrate database
bundle exec rails db:create db:migrate

# 4. Start Redis (separate terminal)
redis-server

# 5. Start Sidekiq (separate terminal)
bundle exec sidekiq

# 6. Start Rails server
bundle exec rails server -p 5999
```

</details>

---

### System Overview

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   User/API  │────▶│ Rails Server │────▶│  PostgreSQL │
└─────────────┘     └──────────────┘     └─────────────┘
                           │
                           ▼
                    ┌────────────────┐
                    │ Active Storage │
                    │  (.eml files)  │
                    └────────────────┘
                           │
                           ▼
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Sidekiq   │◀────│  Redis Queue │◀────│ Process Job │
└─────────────┘     └──────────────┘     └─────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────┐
│          EmailProcessorService (Context)            │
├─────────────────────────────────────────────────────┤
│  • Selects parser based on sender email             │
│  • Handles errors gracefully                        │
│  • Updates logs with detailed status                │
└──────────────┬──────────────────────────────────────┘
               │
               ▼
    ┌──────────────────┐
    │   BaseParser     │  ◀── Strategy Pattern Interface
    │   (Module)       │
    └──────────────────┘
            △
            │
    ┌───────┴────────┐
    │                │
┌───▼────────┐  ┌───▼────────┐
│Fornecedor  │  │ Parceiro   │
│A Parser    │  │ B Parser   │
└────────────┘  └────────────┘
```

### Design Patterns Used

#### 1. **Strategy Pattern**
Each vendor has a dedicated parser implementing `BaseParser` interface:

```ruby
# Context
class EmailProcessorService
  PARSERS = {
    "loja@fornecedorA.com" => FornecedorAParser,
    "contato@parceiroB.com" => ParceiroBParser
  }
end

# Strategy Interface
module BaseParser
  def parse(mail_content)
    # Template method defining parsing flow
  end
end

# Concrete Strategies
class FornecedorAParser
  include BaseParser
  # Vendor-specific extraction logic
end
```

**Benefits:**
- ✅ Open/Closed Principle - add new vendors without modifying existing code
- ✅ Single Responsibility - each parser handles one vendor's format
- ✅ Easy testing - mock/test parsers independently

#### 2. **Template Method Pattern**
`BaseParser` defines the parsing algorithm structure, subclasses implement specific steps:

```ruby
def parse(mail_content)
  mail = Mail.read_from_string(mail_content)

  {
    name: extract_name(mail),           # ← Subclass implements
    email: extract_email(mail),         # ← Subclass implements
    phone: extract_phone(mail),         # ← Subclass implements
    product_code: extract_product_code(mail), # ← Subclass implements
    subject: mail.subject
  }
end
```

#### 3. **Active Job Pattern**
Background processing with automatic retries and monitoring:

```ruby
class ProcessEmailJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 3

  def perform(email_log_id)
    # Async processing with error handling
  end
end
```

### Data Flow

```
1. User uploads .eml file
         ↓
2. EmailLog created (status: pending) + File stored in Active Storage
         ↓
3. ProcessEmailJob enqueued to Sidekiq
         ↓
4. Job picks up email_log_id from queue
         ↓
5. EmailProcessorService.process(email_log)
         ↓
6. Select parser based on sender email
         ↓
7. Parser extracts structured data
         ↓
8. Customer record created
         ↓
9. EmailLog updated (status: success/failed)
```

---

## 🧠 Intelligent Parser System

### The Problem

Traditional email parsers fail when users don't follow exact formats:

```ruby
# ❌ Traditional approach - only works with exact format
/Produto:\s*([A-Z0-9\-]+)/i
```

This fails on:
- "interessado no produto de código ABC123"
- "Preciso de informações sobre XYZ987"
- Subject: "Pedido - Produto LMN456"

###  Solution: Multi-Strategy Parsing

my intelligent parser uses **cascading pattern matching** with 6 extraction strategies:

```ruby
def extract_product_code(mail)
  # Strategy 1: Structured formats (highest priority)
  extract_from_body(mail, /Produto:\s*([A-Z0-9\-]+)/i) ||
  extract_from_body(mail, /Código:\s*([A-Z0-9\-]+)/i) ||

  # Strategy 2: Natural language patterns
  extract_from_body(mail, /produto\s+de\s+código\s+([A-Z0-9\-]+)/i) ||
  extract_from_body(mail, /produto\s+([A-Z][A-Z0-9\-]{2,})/i) ||

  # Strategy 3: Subject line extraction
  extract_from_subject(mail, /Produto\s+([A-Z][A-Z0-9\-]{2,})/i) ||

  # Strategy 4: Intelligent fallback - pattern recognition
  extract_from_body(mail, /\b([A-Z]{3,}[\-]?\d{3,})\b/)
end
```

### Real-World Results

**Test Data Performance:**

| Email | Customer Input | Extracted Code | Strategy Used |
|-------|---------------|----------------|---------------|
| email1.eml | "produto de código ABC123" | ✅ ABC123 | Natural Language |
| email2.eml | "interessado no produto XYZ987" | ✅ XYZ987 | Natural Language |
| email3.eml | Subject: "Produto LMN456" | ✅ LMN456 | Subject Line |
| email6.eml | "Produto: PROD-999" | ✅ PROD-999 | Structured |

**📊 Extraction Success Rate: 100%**

### UTF-8 Encoding Handling

Common issue: "incompatible encoding regexp match (UTF-8 regexp with BINARY string)"

**solution:**
```ruby
def extract_from_body(mail, pattern)
  body = mail_body_text(mail)
  # Force UTF-8 encoding to prevent errors
  body = body.force_encoding('UTF-8') unless body.encoding == Encoding::UTF_8
  match = body.match(pattern)
  match ? match[1].strip : nil
end
```

This prevents encoding errors that crash most parsers when handling international characters or different email clients.

### Adding a New Parser

**Step 1:** Create parser class in `app/parsers/`:

```ruby
class NewVendorParser
  include BaseParser

  private

  def extract_name(mail)
    extract_from_body(mail, /Name:\s*(.+)/i)
  end

  def extract_email(mail)
    extract_from_body(mail, /Email:\s*([^\s]+@[^\s]+)/i)
  end

  def extract_phone(mail)
    extract_from_body(mail, /Phone:\s*([\d\s\-\(\)]+)/i)
  end

  def extract_product_code(mail)
    # Implement vendor-specific patterns
  end
end
```

**Step 2:** Register in `EmailProcessorService`:

```ruby
PARSERS = {
  "loja@fornecedorA.com" => FornecedorAParser,
  "contato@parceiroB.com" => ParceiroBParser,
  "newvendor@example.com" => NewVendorParser  # ← Add here
}.freeze
```

**That's it!** No changes to controllers, jobs, or tests needed. ✨

---

##  Usage

### Web Interface

#### 1. Dashboard (Home)
**URL:** `/` or `/dashboard`

The main dashboard provides a comprehensive overview:
- **Statistics Cards**: Total emails, successful, failed, and customer count
- **Recent Activity**: Last 5 email logs with real-time status
- **New Customers**: Recently added customers from processed emails
- **Quick Actions**: Fast access to upload, logs, and customer pages
- **Auto-refresh**: Automatically updates when emails are being processed

#### 2. Bulk Upload Email Files
**URL:** `/emails/new`

**Features:**
- **Multi-file upload**: Select multiple .eml files at once (ideal for batch processing)
- **Drag & Drop**: Drag files directly into the upload zone
- **Progress tracking**: Shows count of selected files with full list
- **Async processing**: All files are queued and processed in parallel via Sidekiq

**How to use:**
1. Navigate to **Upload Email**
2. Click "Choose Files" or drag & drop multiple .eml files
3. Review the list of selected files
4. Click "Upload and Process"
5. Files are processed in background - watch progress in Email Logs

Sample emails available in `emails/` and `sample_emails/` directories for testing.

#### 3. View Customers
**URL:** `/customers`

- Paginated list (20 per page)
- Displays: Name, Email, Phone, Product Code, Subject, Creation Date
- Clean, modern table design with Bootstrap Icons
- Empty state with call-to-action when no customers exist

#### 4. Monitor Email Logs
**URL:** `/email_logs`

**Features:**
- **Real-time status**: Three-state system (Pending/Success/Failed)
- **Auto-refresh**: Page refreshes every 3 seconds when emails are pending
- **Modal data viewing**: Click "View Data" to see extracted information in popup
- **Error inspection**: Click "View Error" to see detailed error messages
- **Status filters**: Quick filter buttons for All/Success/Failed emails
- **Reprocess capability**: One-click reprocessing for failed emails
- **Responsive table**: All columns properly sized, no text cutoff

**Status indicators:**
- 🟢 **Success** - Email processed successfully, customer data extracted
- 🔴 **Failed** - Processing error (view error details for debugging)
- 🟡 **Processing** - Email currently being processed (with spinner animation)

#### 5. Sidekiq Dashboard
**URL:** `/sidekiq`

**Features:**
- Real-time job queue monitoring
- Job statistics and history
- Worker performance metrics
- Scheduled jobs (cron) management

**Security:**
- Production: Basic HTTP Auth required
- Set `SIDEKIQ_USERNAME` and `SIDEKIQ_PASSWORD` env vars
- Development: Open access (no auth)

### Command Line Interface

#### Process Test Emails
```bash
# Process all test emails
docker-compose exec -T app bundle exec rails runner lib/scripts/process_all_emails.rb

# Test product code extraction specifically
docker-compose exec -T app bundle exec rails runner lib/scripts/test_product_extraction.rb

# View customer data
docker-compose exec -T app bundle exec rails runner lib/scripts/show_customers.rb
```

#### Database Operations
```bash
# Rails console
docker-compose exec app bundle exec rails console

# Run migrations
docker-compose exec -T app bundle exec rails db:migrate

# Reset database (CAUTION: Deletes all data)
docker-compose exec -T app bundle exec rails db:reset
```

#### Log Management
```bash
# Clean up logs older than 90 days (default)
docker-compose exec -T app bundle exec rake email_logs:cleanup

# Custom retention period (60 days)
docker-compose exec -T app bundle exec rake email_logs:cleanup[60]

# View statistics
docker-compose exec -T app bundle exec rake email_logs:stats
```

**Automatic Cleanup:**
- Runs daily at 2:00 AM (configurable in `config/schedule.yml`)
- Default retention: 90 days
- Includes .eml file attachments

### Sample Data

**8 test emails provided** in `emails/` directory:

| File | Vendor | Status | Notes |
|------|--------|--------|-------|
| email1.eml | Fornecedor A | ✅ Success | Natural language product code |
| email2.eml | Fornecedor A | ✅ Success | Product code in sentence |
| email3.eml | Fornecedor A | ✅ Success | Product code in subject |
| email4.eml | Parceiro B | ❌ Expected Fail | Missing contact info |
| email5.eml | Parceiro B | ❌ Expected Fail | Missing name |
| email6.eml | Parceiro B | ✅ Success | Structured format |
| email7.eml | Fornecedor A | ❌ Expected Fail | No email/phone |
| email8.eml | Parceiro B | ❌ Expected Fail | Incomplete data |

---

## 🧪 Testing

### Run Full Test Suite
```bash
docker-compose exec -T app bundle exec rspec
```

### Run Specific Tests
```bash
# Parser tests (includes product code extraction)
docker-compose exec -T app bundle exec rspec spec/parsers/

# Service tests
docker-compose exec -T app bundle exec rspec spec/services/

# Model tests
docker-compose exec -T app bundle exec rspec spec/models/

# Job tests
docker-compose exec -T app bundle exec rspec spec/jobs/

# Integration tests
docker-compose exec -T app bundle exec rspec spec/requests/
```

### Test with Documentation Format
```bash
docker-compose exec -T app bundle exec rspec --format documentation
```

### Code Quality
```bash
# Run Rubocop linter
docker-compose exec -T app bundle exec rubocop

# Auto-fix issues
docker-compose exec -T app bundle exec rubocop -A
```

### Test Coverage

- **Models:** Customer, EmailLog
- **Parsers:** FornecedorAParser, ParceiroBParser (including natural language extraction)
- **Services:** EmailProcessorService
- **Jobs:** ProcessEmailJob, CleanupEmailLogsJob
- **Controllers:** Customers, EmailLogs, Emails

---

##  API & Integration

### REST Endpoints

#### Upload Single Email (POST)
```bash
curl -X POST http://localhost:5999/emails \
  -F "eml_files[]=@emails/email1.eml"
```

#### Upload Multiple Emails (POST) - Bulk Upload
```bash
curl -X POST http://localhost:5999/emails \
  -F "eml_files[]=@emails/email1.eml" \
  -F "eml_files[]=@emails/email2.eml" \
  -F "eml_files[]=@emails/email3.eml"
```

**Response:** Redirects to `/email_logs` with success message showing count of uploaded files

**Example response messages:**
- Single file: "📧 1 email uploaded successfully! Processing will complete in a few seconds..."
- Multiple files: "📧 10 emails uploaded successfully! Processing will complete in a few seconds..."

#### Reprocess Failed Email (POST)
```bash
curl -X POST http://localhost:5999/emails/{id}/reprocess
```

#### Get Customers (GET)
```http
GET /customers
GET /customers?page=2
```

#### Get Email Logs (GET)
```http
GET /email_logs
GET /email_logs?status=failed
```

### Programmatic Usage

```ruby
# In Rails console or custom script
email_log = EmailLog.create!(
  filename: "customer_inquiry.eml",
  status: :pending
)

email_log.eml_file.attach(
  io: File.open("path/to/email.eml"),
  filename: "customer_inquiry.eml",
  content_type: "message/rfc822"
)

# Process synchronously
EmailProcessorService.process(email_log)

# OR process asynchronously (recommended)
ProcessEmailJob.perform_later(email_log.id)

# Check result
email_log.reload
puts email_log.status  # => "success" or "failed"
puts email_log.extracted_data  # => Hash of extracted fields
```

---

##  Deployment

### Docker Production Deployment

**docker-compose.prod.yml example:**

```yaml
services:
  app:
    build: .
    environment:
      RAILS_ENV: production
      RAILS_SERVE_STATIC_FILES: "true"
      RAILS_LOG_TO_STDOUT: "true"
      SIDEKIQ_USERNAME: ${SIDEKIQ_USERNAME}
      SIDEKIQ_PASSWORD: ${SIDEKIQ_PASSWORD}
      SECRET_KEY_BASE: ${SECRET_KEY_BASE}
    ports:
      - "80:5000"
```

### Environment Variables

Required for production:

```bash
# Rails
SECRET_KEY_BASE=<generate with: rails secret>
RAILS_ENV=production

# Database
DATABASE_URL=postgresql://user:pass@host:5432/db_name

# Redis
REDIS_URL=redis://redis:6379/0

# Sidekiq Auth
SIDEKIQ_USERNAME=admin
SIDEKIQ_PASSWORD=<strong-password>

# Optional
RAILS_MAX_THREADS=5
```

### Health Checks

```bash
# Application health
curl http://localhost:5999/up

# Database connectivity
docker-compose exec app bundle exec rails db:migrate:status

# Redis connectivity
docker-compose exec app bundle exec rails runner "puts Sidekiq.redis(&:ping)"
```

### CI/CD Pipeline

GitHub Actions automatically:
1. Runs tests on every push/PR
2. Runs Rubocop linter
3. Builds Docker image
4. Validates docker-compose

**Badge:** Shows real-time build status in README

---

## 📊 Performance Considerations

### Async Processing
- All email processing happens in background jobs
- Non-blocking user experience
- Automatic retry on transient failures (3 attempts)

### Database Optimization
- Indexed fields: `email`, `phone`, `status`, `created_at`
- JSONB storage for flexible `extracted_data`
- GIN index on JSONB for fast queries

### Caching Strategy
- Redis caches Sidekiq job data
- Active Storage caching for .eml files

### Scalability
- **Horizontal scaling:** Add more Sidekiq workers
- **Vertical scaling:** Increase `RAILS_MAX_THREADS`
- **Database:** PostgreSQL connection pooling
- **File storage:** Active Storage supports S3/GCS for production

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/amazing-parser`
3. **Write tests** for your changes
4. **Ensure** all tests pass: `bundle exec rspec`
5. **Ensure** code quality: `bundle exec rubocop -A`
6. **Commit** with clear messages: `git commit -m 'Add parser for Vendor X'`
7. **Push** to your fork: `git push origin feature/amazing-parser`
8. **Open** a Pull Request with detailed description

### Code Style
- Follow Ruby Style Guide
- Write descriptive commit messages
- Add RSpec tests for new features
- Update documentation

---
<details>
<summary>Roadmap</summary>

- [x] Bulk upload for multiple email files
- [x] Real-time dashboard with statistics
- [x] Auto-refresh for pending emails
- [ ] REST API with authentication (JWT)
- [ ] Real-time notifications (Action Cable)
- [ ] Machine learning for parser auto-improvement
- [ ] Multi-tenancy support
- [ ] Advanced analytics and reporting
- [ ] Email template generation
- [ ] S3/GCS integration for production storage
- [ ] Export data to CSV/Excel
- [ ] Webhook integrations

</details>
##  Acknowledgments

- Built with [Ruby on Rails](https://rubyonrails.org/)
- Email parsing powered by [Mail gem](https://github.com/mikel/mail)
- Background jobs by [Sidekiq](https://sidekiq.org/)
- UI components from [Bootstrap](https://getbootstrap.com/)

---

##  Support

- **Issues:** [GitHub Issues](https://github.com/yourusername/EmailProcessorRails/issues)
- **Discussions:** [GitHub Discussions](https://github.com/yourusername/EmailProcessorRails/discussions)
- **Documentation:** This README + inline code comments

---

# Copyright & License

© 2025 BulletOnRails .  All rights reserved.


O código-fonte contido aqui é disponibilizado sob a licença Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.

Você pode encontrar o texto completo da licença no arquivo [LICENSE](license.md) neste repositório.

Shield:

[![CC BY-NC-SA 4.0][cc-by-nc-sa-shield]][cc-by-nc-sa]

This work is licensed under a
[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License][cc-by-nc-sa].

[![CC BY-NC-SA 4.0][cc-by-nc-sa-image]][cc-by-nc-sa]

[cc-by-nc-sa]: http://creativecommons.org/licenses/by-nc-sa/4.0/
[cc-by-nc-sa-image]: https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png
[cc-by-nc-sa-shield]: https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg

---



**❤️  understand that real-world data is messy.**
