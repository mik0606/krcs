// Config/DbConfig.js — Mongo connection for Spazigo (ESM)

import mongoose from "mongoose";
import dotenv from "dotenv";
import { fileURLToPath } from "url";
import path from "path";

// Load .env reliably relative to this file (Server/.env)
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
dotenv.config({ path: path.join(__dirname, "..", ".env") });

mongoose.set("strictQuery", true);

const uri = process.env.MONGO_URI;
if (!uri) {
  throw new Error("MONGO_URI missing in .env");
}

let isConnecting = false;

export async function connectDB() {
  if (mongoose.connection.readyState === 1) return mongoose.connection; // already connected
  if (isConnecting) {
    return new Promise((r) => mongoose.connection.once("connected", () => r(mongoose.connection)));
  }

  try {
    isConnecting = true;

    await mongoose.connect(uri, {
      autoIndex: process.env.NODE_ENV !== "production",
      dbName: process.env.MONGO_DB || undefined,
      maxPoolSize: 20,
    });

    mongoose.connection.on("error", (err) => console.error("🔴 MongoDB error:", err?.message || err));
    mongoose.connection.on("disconnected", () => console.warn("🟠 MongoDB disconnected"));
    mongoose.connection.on("connected", () => console.log("🟢 MongoDB connected"));

    return mongoose.connection;
  } catch (err) {
    console.error("❌ MongoDB connection failed:", err?.message || err);
    throw err;
  } finally {
    isConnecting = false;
  }
}

export async function disconnectDB() {
  if (mongoose.connection.readyState !== 0) {
    await mongoose.disconnect();
    console.log("🟡 MongoDB disconnected by app");
  }
}

export function getDbStatus() {
  // 0 = disconnected, 1 = connected, 2 = connecting, 3 = disconnecting
  return mongoose.connection.readyState;
}

export default connectDB;
