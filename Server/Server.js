// Server.js — Main entry point for Spazigo backend
// Includes: DB init, user seeding, and route setup

import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import bcrypt from "bcryptjs";

import connectDB from "./Config/DbConfig.js";
import AuthRoutes from "./Routes/AuthRoutes.js";
import {
  User,
  DriverProfile,
  MerchantProfile,
  LogisticProfile,
  AdminProfile,
} from "./Models/models.js";

dotenv.config();

// -----------------------------------------------------------------------------
// 1️⃣ App & Middleware Setup
// -----------------------------------------------------------------------------
const app = express();
app.use(cors());
app.use(express.json());

// -----------------------------------------------------------------------------
// 2️⃣ MongoDB Connection
// -----------------------------------------------------------------------------
await connectDB();

// -----------------------------------------------------------------------------
// 3️⃣ Default Users to Seed (defined here directly)
// -----------------------------------------------------------------------------
const defaultUsers = [
  {
    name: "Admin User",
    email: "admin@spazigo.com",
    password: "Admin@123",
    role: "admin",
    phone: "9000000001",
  },
  {
    name: "Merchant One",
    email: "merchant@spazigo.com",
    password: "Merchant@123",
    role: "merchant",
    phone: "9000000002",
    companyName: "Demo Mart",
  },
  {
    name: "Driver One",
    email: "driver@spazigo.com",
    password: "Driver@123",
    role: "driver",
    phone: "9000000003",
  },
  {
    name: "Logistic Lead",
    email: "logistic@spazigo.com",
    password: "Logistic@123",
    role: "logistic",
    phone: "9000000004",
  },
];

const allowedRoles = new Set(["admin", "driver", "merchant", "logistic", "sanjit"]);

// -----------------------------------------------------------------------------
// 4️⃣ Role-based Profile Creation Helper
// -----------------------------------------------------------------------------
async function ensureRoleProfile(user, seed) {
  switch (user.role) {
    case "driver":
      await DriverProfile.updateOne(
        { user: user._id },
        { $setOnInsert: { user: user._id, currentStatus: "offline" } },
        { upsert: true }
      );
      break;

    case "merchant":
      await MerchantProfile.updateOne(
        { user: user._id },
        {
          $setOnInsert: {
            user: user._id,
            companyName: seed.companyName || user.name,
            primaryPhone: user.phone,
          },
        },
        { upsert: true }
      );
      break;

    case "logistic":
      await LogisticProfile.updateOne(
        { user: user._id },
        {
          $setOnInsert: {
            user: user._id,
            companyName: seed.companyName || user.name,
          },
        },
        { upsert: true }
      );
      break;

    case "admin":
      await AdminProfile.updateOne(
        { user: user._id },
        {
          $setOnInsert: {
            user: user._id,
            permissions: ["*:*"],
          },
        },
        { upsert: true }
      );
      break;

    default:
      break;
  }
}

// -----------------------------------------------------------------------------
// 5️⃣ Seed Users (runs every startup, skips existing)
// -----------------------------------------------------------------------------
async function seedDefaultUsers() {
  console.log("🚀 Checking default users...");
  let created = 0;
  let skipped = 0;

  for (const seed of defaultUsers) {
    try {
      const { name, email, password, role, phone } = seed;
      if (!name || !email || !password || !role) {
        console.warn("⚠️  Missing required fields in seed:", seed);
        skipped++;
        continue;
      }

      if (!allowedRoles.has(role)) {
        console.warn(`⚠️  Invalid role '${role}' in seed. Skipped.`);
        skipped++;
        continue;
      }

      const existing = await User.findOne({ email: email.toLowerCase() });
      if (existing) {
        console.log(`➡️  User exists: ${email}`);
        skipped++;
        continue;
      }

      const passwordHash = await bcrypt.hash(password, 10);
      const user = await User.create({
        name,
        email: email.toLowerCase(),
        phone,
        passwordHash,
        role,
        status: "active",
        provider: "local",
      });

      await ensureRoleProfile(user, seed);

      created++;
      console.log(`✅ Created user: ${email} (role=${role})`);
    } catch (err) {
      console.error(`❌ Error seeding ${seed.email}:`, err.message);
      skipped++;
    }
  }

  console.log(`📦 Seeding complete → created: ${created}, skipped: ${skipped}`);
}

await seedDefaultUsers();

// -----------------------------------------------------------------------------
// 6️⃣ Routes Setup
// -----------------------------------------------------------------------------
app.use("/api/auth", AuthRoutes);

app.get("/", (req, res) => {
  res.send("✅ Spazigo API is running...");
});

// -----------------------------------------------------------------------------
// 7️⃣ Start Server
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// 7️⃣ Start Server (bind to 0.0.0.0 so phone can reach it)
// -----------------------------------------------------------------------------
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0';
// quick health/ping endpoint for debugging from phone
app.get("/ping", (req, res) => {
  console.log("🟢 /ping received from", req.ip || req.headers['x-forwarded-for']);
  res.json({ ok: true, message: "pong", host: req.hostname });
});

app.listen(PORT, HOST, () => {
  console.log(`🌍 Server running on http://${HOST}:${PORT}`);
});


