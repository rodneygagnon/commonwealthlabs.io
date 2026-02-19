# Opus Populi Landing Page

The official landing page for [opuspopuli.org](https://opuspopuli.org) - open-source civic technology for engaged democracy.

## Development

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Run E2E tests
npm run e2e

# Run accessibility tests (WCAG 2.2 AA)
npm run e2e:a11y
```

## Technology Stack

- **[Astro](https://astro.build)** - Static site generator
- **[Tailwind CSS](https://tailwindcss.com)** - Styling
- **[TypeScript](https://typescriptlang.org)** - Type safety
- **[Playwright](https://playwright.dev)** - E2E and accessibility testing (WCAG 2.2 AA)

## Project Structure

```
opuspopuli.org/
├── src/
│   ├── components/     # Reusable UI components
│   ├── layouts/        # Page layouts
│   ├── pages/          # Site pages (index, about, why, network, get-involved)
│   └── styles/         # Global styles
├── public/             # Static assets (logos, favicons)
├── infra/              # Terraform infrastructure (S3 + CloudFront)
└── .github/workflows/  # CI/CD pipeline
```

## Deployment

The site automatically deploys to AWS S3 + CloudFront when changes are pushed to `main`.

### Required Secrets

Configure these in GitHub repository settings:

| Secret | Description |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | AWS access key for deployment |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key |
| `S3_BUCKET_NAME` | S3 bucket name (from Terraform output) |
| `CLOUDFRONT_DISTRIBUTION_ID` | CloudFront distribution ID (from Terraform output) |

### Infrastructure Setup

See [infra/README.md](infra/README.md) for Terraform setup instructions.

## Pages

- **Home** (`/`) - Mission, features, calls to action
- **About** (`/about`) - Mission, what we build, open source commitment
- **Why** (`/why`) - Philosophy and why citizen-built civic tools matter
- **Network** (`/network`) - How the network works, benefits, current members
- **Get Involved** (`/get-involved`) - Requirements, steps to join, FAQ

## License

MIT License - See [LICENSE](LICENSE) file.
