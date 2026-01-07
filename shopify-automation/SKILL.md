---
name: shopify-automation
description: Automate Shopify store setup with collections, products, pages, and blog using Client Credentials Grant OAuth (2026+ method) for complete hands-free store configuration
license: MIT
compatibility: "Requires: Node.js 18+, npm, Shopify Partner account, Dev Dashboard app created, internet access"
---

# Shopify Automation

## Overview

Automate creation of Shopify store content (collections, products, pages, blog) using the 2026+ Client Credentials Grant OAuth flow instead of deprecated legacy custom apps.

## When to Use This Skill

- Setting up a new Shopify store with multiple products and collections
- Migrating content from another platform to Shopify
- Creating test/dev stores with realistic data
- Batch importing products from external sources
- When you see: "Starting January 1, 2026, you won't be able to create new legacy custom apps"
- When you need OAuth-based authentication instead of permanent `shpat_` tokens

## Workflow

### Step 1: Create Shopify Dev Dashboard App

**Option A: If you have a real Shopify store**
1. Go to store Admin: `https://your-store.myshopify.com/admin`
2. **Settings** ⚙️ → **Apps and sales channels**
3. **Develop apps** → **Create an app**
4. Name: `Store Automation`
5. Configure scopes → Install → Get Admin API token (`shpat_`)

**Option B: If using Dev Dashboard (2026+ method)** ✅
1. Go to [Shopify Partners](https://partners.shopify.com)
2. Navigate to **Apps** → **Create app**
3. Name: `[Store Name] Automation`
4. In **Settings**:
   - Set **App URL**: `https://example.com` (placeholder OK)
   - **Distribution**: Select "Custom app" or "Single merchant"
5. In **Versions** → Create version:
   - **Scopes** (comma-separated):
     ```
     write_products,read_products,write_content,read_content,write_inventory
     ```
   - Click **Save** or **Create version**
6. Click **Release** to activate the version
7. **Install app** on your target store
8. In **Settings** → **Credentials**:
   - Copy **Client ID** (long alphanumeric string)
   - Copy **Secret** (starts with `shpss_`)

### Step 2: Setup Project Structure

Create automation project:

```bash
mkdir shopify-store-automation
cd shopify-store-automation

# Create package.json
cat > package.json << 'EOF'
{
  "name": "shopify-automation",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "setup": "node scripts/setup-shopify.js"
  },
  "dependencies": {
    "dotenv": "^16.3.1",
    "node-fetch": "^3.3.2"
  }
}
EOF

# Install dependencies
npm install

# Create directories
mkdir -p scripts/data
```

### Step 3: Configure Environment

Create `.env` file:

```bash
# Shopify Dev Dashboard App Credentials (2026+ method)
SHOPIFY_CLIENT_ID=your_client_id_here
SHOPIFY_CLIENT_SECRET=shpss_your_secret_here
SHOPIFY_STORE_URL=your-store.myshopify.com

# Optional: Social links to add
INSTAGRAM_URL=https://instagram.com/yourstore
WHATSAPP_NUMBER=1234567890
```

**Important:** Never commit `.env` - add to `.gitignore`!

### Step 4: Create Data Files

**scripts/data/collections.js** - Product categories:

```javascript
export const collections = [
  {
    title: "Category Name",
    handle: "category-slug",
    body_html: "<p>Description here...</p>",
    published: true,
  },
  // Add more collections...
];
```

**scripts/data/products.js** - Products:

```javascript
export const products = [
  {
    title: "Product Name",
    body_html: "<p>Product description...</p>",
    vendor: "Your Brand",
    product_type: "Product Type",
    tags: ["tag1", "tag2"],
    published: true,
    collection: "category-slug", // Links to collection handle
    variants: [
      {
        option1: "Default",
        price: "29.99",
        sku: "PROD-001",
        inventory_management: "shopify",
        inventory_quantity: 100,
        weight: 500,
        weight_unit: "g",
      },
    ],
  },
  // Add more products...
];
```

**scripts/data/pages.js** - Static pages:

```javascript
export const pages = [
  {
    title: "About Us",
    handle: "about",
    body_html: "<p>About page content...</p>",
    published: true,
  },
  // Add more pages...
];
```

### Step 5: Create Automation Script

**scripts/setup-shopify.js**:

```javascript
import 'dotenv/config';
import fetch from 'node-fetch';
import { collections } from './data/collections.js';
import { products } from './data/products.js';
import { pages } from './data/pages.js';

const CLIENT_ID = process.env.SHOPIFY_CLIENT_ID;
const CLIENT_SECRET = process.env.SHOPIFY_CLIENT_SECRET;
const STORE_URL = process.env.SHOPIFY_STORE_URL;

if (!CLIENT_ID || !CLIENT_SECRET || !STORE_URL) {
  console.error('❌ Missing credentials in .env file');
  process.exit(1);
}

const API_VERSION = '2024-01';

// Generate access token using Client Credentials Grant
async function getAccessToken() {
  const url = `https://${STORE_URL}/admin/oauth/access_token`;

  const response = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
      grant_type: 'client_credentials',
    }),
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(`Failed to get token: ${JSON.stringify(data)}`);
  }

  return data.access_token;
}

// Make API requests with generated token
async function shopifyRequest(endpoint, method = 'GET', body = null, token) {
  const url = `https://${STORE_URL}/admin/api/${API_VERSION}${endpoint}`;

  const options = {
    method,
    headers: {
      'Content-Type': 'application/json',
      'X-Shopify-Access-Token': token,
    },
  };

  if (body) options.body = JSON.stringify(body);

  const response = await fetch(url, options);
  const data = await response.json();

  if (!response.ok) {
    console.error(`❌ API Error:`, data);
    return null;
  }

  return data;
}

// Create collections
async function createCollections(token) {
  console.log('\n📦 Creating collections...');
  const collectionMap = {};

  for (const collection of collections) {
    console.log(`  ⏳ ${collection.title}...`);

    const result = await shopifyRequest(
      '/custom_collections.json',
      'POST',
      { custom_collection: collection },
      token
    );

    if (result?.custom_collection) {
      collectionMap[collection.handle] = result.custom_collection.id;
      console.log(`  ✅ Created (ID: ${result.custom_collection.id})`);
    }

    await new Promise(r => setTimeout(r, 500)); // Rate limit
  }

  return collectionMap;
}

// Create products and link to collections
async function createProducts(collectionMap, token) {
  console.log('\n🛍️  Creating products...');
  let successCount = 0;

  for (const product of products) {
    console.log(`  ⏳ ${product.title}...`);

    const { collection, ...productData } = product;

    const result = await shopifyRequest(
      '/products.json',
      'POST',
      { product: productData },
      token
    );

    if (result?.product) {
      const productId = result.product.id;
      console.log(`  ✅ Created (ID: ${productId})`);
      successCount++;

      // Link to collection
      if (collection && collectionMap[collection]) {
        await shopifyRequest(
          '/collects.json',
          'POST',
          {
            collect: {
              product_id: productId,
              collection_id: collectionMap[collection],
            },
          },
          token
        );
        console.log(`     → Added to "${collection}"`);
      }
    }

    await new Promise(r => setTimeout(r, 500));
  }

  console.log(`\n✨ ${successCount}/${products.length} products created`);
}

// Create pages
async function createPages(token) {
  console.log('\n📄 Creating pages...');
  let successCount = 0;

  for (const page of pages) {
    console.log(`  ⏳ ${page.title}...`);

    const result = await shopifyRequest(
      '/pages.json',
      'POST',
      { page },
      token
    );

    if (result?.page) {
      console.log(`  ✅ Created (ID: ${result.page.id})`);
      successCount++;
    }

    await new Promise(r => setTimeout(r, 500));
  }

  console.log(`\n✨ ${successCount}/${pages.length} pages created`);
}

// Create blog
async function createBlog(token) {
  console.log('\n📰 Creating blog...');

  const result = await shopifyRequest(
    '/blogs.json',
    'POST',
    {
      blog: {
        title: 'News',
        handle: 'news',
        commentable: 'no',
      },
    },
    token
  );

  if (result?.blog) {
    console.log(`  ✅ Blog created (ID: ${result.blog.id})`);
  }
}

// Main execution
async function main() {
  console.log('🚀 SHOPIFY AUTOMATION');
  console.log(`🏪 Store: ${STORE_URL}\n`);

  try {
    // Generate fresh access token
    console.log('🔑 Generating access token...');
    const token = await getAccessToken();
    console.log('✅ Token obtained (valid 24h)');

    // Create everything
    const collectionMap = await createCollections(token);
    await createProducts(collectionMap, token);
    await createPages(token);
    await createBlog(token);

    console.log('\n🎉 AUTOMATION COMPLETE!');
  } catch (error) {
    console.error('\n💥 Fatal error:', error.message);
    process.exit(1);
  }
}

main();
```

### Step 6: Run Automation

```bash
# Execute automation
npm run setup
```

**Expected output:**

```
🚀 SHOPIFY AUTOMATION
🏪 Store: your-store.myshopify.com

🔑 Generating access token...
✅ Token obtained (valid 24h)

📦 Creating collections...
  ⏳ Category 1...
  ✅ Created (ID: 123456)

🛍️  Creating products...
  ⏳ Product 1...
  ✅ Created (ID: 789012)
     → Added to "category-1"

✨ 10/10 products created

📄 Creating pages...
  ⏳ About Us...
  ✅ Created (ID: 345678)

✨ 3/3 pages created

📰 Creating blog...
  ✅ Blog created (ID: 901234)

🎉 AUTOMATION COMPLETE!
```

### Step 7: Verify in Shopify Admin

1. Go to your store admin
2. Check **Products** - All products should be there
3. Check **Products > Collections** - All categories created
4. Check **Online Store > Pages** - Pages created
5. Check **Online Store > Blog posts** - Blog ready

## Guidelines

**Do:**
- Use Client Credentials Grant for Dev Dashboard apps (2026+)
- Store credentials in `.env`, never commit
- Add `.env` to `.gitignore`
- Include rate limiting delays (500ms between requests)
- Test with small dataset first (2-3 products)
- Generate fresh tokens before long operations
- Handle API errors gracefully
- Use descriptive SKUs for inventory tracking
- Validate data structure before running

**Don't:**
- Don't use legacy `shpat_` tokens (deprecated 2026+)
- Don't commit API credentials to git
- Don't exceed Shopify API rate limits (2 requests/second)
- Don't create duplicate products (check existing first)
- Don't skip error handling
- Don't use Client Secret for public/frontend apps
- Don't share access tokens publicly
- Don't forget token expires in 24h

## Examples

### Example 1: E-commerce Store Setup

Complete store with 50 products across 5 categories:

```javascript
// collections.js
export const collections = [
  { title: "Men's Clothing", handle: "mens-clothing", ... },
  { title: "Women's Clothing", handle: "womens-clothing", ... },
  { title: "Accessories", handle: "accessories", ... },
  { title: "Shoes", handle: "shoes", ... },
  { title: "Sale", handle: "sale", ... },
];

// products.js - 50 products with variants
export const products = [
  {
    title: "Classic T-Shirt",
    variants: [
      { option1: "Small", price: "19.99", sku: "TSHIRT-S", ... },
      { option1: "Medium", price: "19.99", sku: "TSHIRT-M", ... },
      { option1: "Large", price: "19.99", sku: "TSHIRT-L", ... },
    ],
    collection: "mens-clothing",
  },
  // ... 49 more products
];
```

Run: `npm run setup` → Store ready in 2 minutes

### Example 2: Content Site with Blog

Documentation/content site:

```javascript
// pages.js
export const pages = [
  { title: "About", handle: "about", body_html: "..." },
  { title: "Privacy Policy", handle: "privacy", body_html: "..." },
  { title: "Terms of Service", handle: "terms", body_html: "..." },
  { title: "Contact", handle: "contact", body_html: "..." },
  { title: "FAQ", handle: "faq", body_html: "..." },
];

// No products, just blog + pages
export const products = [];
export const collections = [];
```

### Example 3: Artisanal Store (Real-world)

Rita La Rosa - Réunion artisanal products:

```javascript
// 4 collections
- Huiles Essentielles (2 products)
- Fruits Séchés (2 products)
- Herbes Aromatiques (4 products)
- Confitures Artisanales (2 products)

// 11 products total with poetic descriptions
// 3 pages (About, Partners, Contact)
// 1 blog (Nouvelles/News)
```

**Result:** Complete boutique setup in ~90 seconds

## Resources

- [Client Credentials Grant - Shopify Docs](https://shopify.dev/docs/apps/build/authentication-authorization/access-tokens/client-credentials-grant)
- [Admin API Reference](https://shopify.dev/docs/api/admin)
- [API Rate Limits](https://shopify.dev/docs/api/usage/rate-limits)
- [Shopify Dev Dashboard](https://partners.shopify.com/organizations)

## Tools & Commands

- `npm run setup` - Run automation script
- `node --version` - Check Node.js (need 18+)
- `wc -l scripts/data/*.js` - Count data entries
- `git add .gitignore` - Ensure credentials protected

## Troubleshooting

### "Failed to get token" Error

**Problem:** Client Credentials Grant failing

**Solutions:**
1. Verify Client ID and Secret are correct (copy-paste from Dev Dashboard)
2. Ensure app is **installed** on target store
3. Check app **Distribution** is set to "Custom app"
4. Verify store URL format: `store-name.myshopify.com` (no https://)
5. Ensure app version is **released** (not draft)

### "Invalid scope" Error

**Problem:** Requested scope not available

**Solutions:**
1. In Dev Dashboard → Versions → Edit scopes
2. Use only these scopes: `write_products,read_products,write_content,read_content,write_inventory`
3. Save and **release new version**
4. **Reinstall app** on store

### API Rate Limit Hit

**Problem:** "429 Too Many Requests"

**Solutions:**
```javascript
// Increase delay between requests
await new Promise(r => setTimeout(r, 1000)); // 1 second

// Or add exponential backoff
async function retryRequest(fn, retries = 3) {
  for (let i = 0; i < retries; i++) {
    try {
      return await fn();
    } catch (err) {
      if (err.status === 429 && i < retries - 1) {
        await new Promise(r => setTimeout(r, 2000 * (i + 1)));
        continue;
      }
      throw err;
    }
  }
}
```

### Products Not Appearing in Collections

**Problem:** Products created but not in collections

**Solutions:**
1. Check collection `handle` matches exactly
2. Verify `collectionMap` has collection IDs
3. Manual fix: In Shopify Admin → Products → [Product] → Organization → Add to collection

### Token Expired Mid-Script

**Problem:** Long script, token expired after 24h

**Solution:**
```javascript
// Regenerate token periodically
let token = await getAccessToken();
let tokenTime = Date.now();

async function ensureValidToken() {
  // Refresh if token > 20 hours old
  if (Date.now() - tokenTime > 20 * 60 * 60 * 1000) {
    console.log('♻️  Refreshing token...');
    token = await getAccessToken();
    tokenTime = Date.now();
  }
  return token;
}

// Use in requests
const currentToken = await ensureValidToken();
await shopifyRequest('/products.json', 'POST', data, currentToken);
```

---

## Notes

- **2026+ Authentication:** Client Credentials Grant is the new standard
- **Token Lifespan:** 24 hours (regenerate for long operations)
- **Rate Limits:** 2 requests/second for Admin API
- **Scopes:** Minimum required scopes for basic automation
- **Security:** Client Secret is sensitive - never expose publicly
- **Dev Stores:** Perfect for testing automation before production
- **Idempotency:** Script creates new records each run - check for duplicates first if re-running
