-- ============================================================
-- FreshMart Database Schema
-- Run this in your Supabase SQL Editor
-- Project: https://jgpegypquuzhqqeiubez.supabase.co
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── USERS TABLE ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  full_name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  address TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ── PRODUCTS TABLE ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS products (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN (
    'Fruits & Vegetables',
    'Dairy & Eggs',
    'Beverages',
    'Snacks & Cereals'
  )),
  price_ksh DECIMAL(10,2) NOT NULL,
  stock_quantity INTEGER NOT NULL DEFAULT 0,
  image_url TEXT,
  description TEXT,
  is_available BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ── CART ITEMS TABLE ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS cart_items (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 1,
  added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- ── ORDERS TABLE ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS orders (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  total_amount_ksh DECIMAL(10,2) NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN (
    'pending', 'confirmed', 'processing', 'delivered', 'cancelled'
  )),
  delivery_address TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ── ORDER ITEMS TABLE ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS order_items (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  quantity INTEGER NOT NULL,
  unit_price_ksh DECIMAL(10,2) NOT NULL
);

-- ── ROW LEVEL SECURITY ───────────────────────────────────────
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Products are readable by everyone
CREATE POLICY "Products are viewable by everyone"
  ON products FOR SELECT USING (true);

-- Users can read/write their own data
CREATE POLICY "Users can view own profile"
  ON users FOR SELECT USING (true);
CREATE POLICY "Users can insert own profile"
  ON users FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE USING (true);

-- Cart policies
CREATE POLICY "Users can manage own cart"
  ON cart_items FOR ALL USING (true);

-- Orders policies
CREATE POLICY "Users can view own orders"
  ON orders FOR SELECT USING (true);
CREATE POLICY "Users can create orders"
  ON orders FOR INSERT WITH CHECK (true);

-- Order items policies
CREATE POLICY "Users can view own order items"
  ON order_items FOR SELECT USING (true);
CREATE POLICY "Users can create order items"
  ON order_items FOR INSERT WITH CHECK (true);

-- ── SEED PRODUCTS DATA ───────────────────────────────────────
INSERT INTO products (name, category, price_ksh, stock_quantity, description, is_available) VALUES

-- Fruits & Vegetables
('Sukuma Wiki (Kale)', 'Fruits & Vegetables', 30.00, 100, 'Fresh sukuma wiki, per bunch', true),
('Tomatoes', 'Fruits & Vegetables', 80.00, 80, 'Fresh ripe tomatoes, per kg', true),
('Onions', 'Fruits & Vegetables', 60.00, 90, 'Red onions, per kg', true),
('Avocado', 'Fruits & Vegetables', 25.00, 60, 'Fresh Kenyan avocado, each', true),
('Bananas', 'Fruits & Vegetables', 50.00, 70, 'Sweet bananas, per bunch', true),
('Spinach', 'Fruits & Vegetables', 30.00, 50, 'Fresh spinach, per bunch', true),
('Carrots', 'Fruits & Vegetables', 50.00, 65, 'Fresh carrots, per kg', true),
('Mangoes', 'Fruits & Vegetables', 100.00, 45, 'Sweet Kenyan mangoes, per kg', true),

-- Dairy & Eggs
('Brookside Milk 500ml', 'Dairy & Eggs', 60.00, 120, 'Fresh pasteurised milk', true),
('Fresha Yoghurt 500g', 'Dairy & Eggs', 120.00, 55, 'Strawberry flavoured yoghurt', true),
('Eggs (Tray of 30)', 'Dairy & Eggs', 480.00, 40, 'Fresh farm eggs, tray of 30', true),
('KCC Butter 250g', 'Dairy & Eggs', 280.00, 35, 'KCC unsalted butter', true),
('Brookside Cheese 200g', 'Dairy & Eggs', 350.00, 25, 'Cheddar cheese slices', true),
('Mala (Sour Milk) 500ml', 'Dairy & Eggs', 70.00, 60, 'Traditional fermented milk', true),

-- Beverages
('Coca-Cola 500ml', 'Beverages', 80.00, 200, 'Refreshing Coca-Cola', true),
('Tusker Cider 500ml', 'Beverages', 150.00, 80, 'Tusker Cider alcoholic beverage', true),
('Minute Maid Orange 300ml', 'Beverages', 60.00, 150, 'Orange juice drink', true),
('Ricoffy 200g', 'Beverages', 380.00, 40, 'Rich coffee blend', true),
('Milo 400g', 'Beverages', 580.00, 30, 'Chocolate malt drink powder', true),
('Keringet Water 1L', 'Beverages', 70.00, 300, 'Natural mineral water', true),
('Fanta Orange 500ml', 'Beverages', 80.00, 180, 'Fanta orange soda', true),

-- Snacks & Cereals
('Unga Jogoo 2kg', 'Snacks & Cereals', 170.00, 100, 'Maize flour, 2kg pack', true),
('Weetabix 430g', 'Snacks & Cereals', 380.00, 45, 'Whole wheat breakfast cereal', true),
('Pringles Original 165g', 'Snacks & Cereals', 480.00, 35, 'Original flavour crisps', true),
('Safari Nuts 100g', 'Snacks & Cereals', 120.00, 80, 'Mixed nuts and raisins', true),
('Kenchic Crisps 100g', 'Snacks & Cereals', 60.00, 100, 'Tasty potato crisps', true),
('Pembe Flour 2kg', 'Snacks & Cereals', 160.00, 90, 'Wheat flour for baking', true),
('Quaker Oats 500g', 'Snacks & Cereals', 280.00, 50, 'Rolled oats for breakfast', true);
