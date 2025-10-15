// Routes/AuthRoutes.js — Spazigo Auth endpoints (ESM)
// Handles: register, login, refresh, logout, verify/me
// Depends on: Models/models.js, Middleware/Auth.js, Config/DbConfig.js

import express from "express";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import crypto from "crypto";

import {
  User,
  Session,
  DriverProfile,
  MerchantProfile,
  LogisticProfile,
  AdminProfile,
} from "../Models/models.js";

import { verifyToken, signAccessToken } from "../Middleware/Auth.js";

const router = express.Router();

/* --------------------------------------------------------------------------
 * Helpers & Config
 * -------------------------------------------------------------------------- */
const ACCESS_TOKEN_TTL = process.env.JWT_EXPIRES_IN || "2h"; // e.g., "2h"
const REFRESH_TOKEN_TTL = process.env.JWT_REFRESH_EXPIRES_IN || "30d"; // e.g., "30d"
const REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET; // use a different secret in prod

if (!REFRESH_SECRET) {
  throw new Error("JWT_REFRESH_SECRET (or JWT_SECRET) missing in .env");
}

function signRefreshToken(user, { expiresIn = REFRESH_TOKEN_TTL } = {}) {
  // Keep payload minimal; use 'sub' and a token type for clarity
  const payload = { sub: String(user._id), typ: "refresh" };
  return jwt.sign(payload, REFRESH_SECRET, { expiresIn });
}

function sha256(value) {
  return crypto.createHash("sha256").update(value).digest("hex");
}

async function persistSession(user, refreshToken, req) {
  const refreshTokenHash = sha256(refreshToken);
  const { exp } = jwt.decode(refreshToken); // seconds since epoch
  const expiresAt = new Date(exp * 1000);

  // NOTE: we store device metadata for security/ops visibility
  const device = {
    ua: req.headers["user-agent"],
    platform: req.headers["sec-ch-ua-platform"],
    ip: req.headers["x-forwarded-for"]?.split(",")[0] || req.socket?.remoteAddress || undefined,
  };

  return Session.create({
    user: user._id,
    refreshTokenHash,
    device,
    expiresAt,
    revoked: false,
  });
}

function sanitizeUser(u) {
  if (!u) return null;
  const { passwordHash, __v, ...rest } = u;
  return rest;
}

/* --------------------------------------------------------------------------
 * Validation (basic and pragmatic)
 * -------------------------------------------------------------------------- */
function requireFields(body, fields) {
  for (const f of fields) {
    if (!body?.[f]) return `Missing field: ${f}`;
  }
  return null;
}

const allowedRoles = new Set(["admin", "driver", "merchant", "logistic", "sanjit"]);

/* --------------------------------------------------------------------------
 * POST /api/auth/register
 * Body: { name, email, phone?, password, role }
 * Creates user + role profile (minimal), returns tokens + user
 * -------------------------------------------------------------------------- */
router.post("/register", async (req, res) => {
  try {
    const err = requireFields(req.body, ["name", "email", "password", "role"]);
    if (err) return res.status(400).json({ ok: false, message: err });

    const { name, email, phone, password, role } = req.body;

    if (!allowedRoles.has(role)) {
      return res.status(400).json({ ok: false, message: "Invalid role" });
    }

    const existing = await User.findOne({ $or: [{ email }, phone ? { phone } : null].filter(Boolean) });
    if (existing) {
      return res.status(409).json({ ok: false, message: "User already exists (email/phone)" });
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

    // Minimal role profile bootstrap (optional but handy)
    if (role === "driver") {
      await DriverProfile.create({ user: user._id, currentStatus: "offline" });
    } else if (role === "merchant") {
      await MerchantProfile.create({ user: user._id, companyName: name });
    } else if (role === "logistic") {
      await LogisticProfile.create({ user: user._id, companyName: name });
    } else if (role === "admin") {
      await AdminProfile.create({ user: user._id, permissions: ["*:"] });
    }

    const accessToken = signAccessToken(user, { expiresIn: ACCESS_TOKEN_TTL });
    const refreshToken = signRefreshToken(user);
    await persistSession(user, refreshToken, req);

    return res.status(201).json({
      ok: true,
      message: "Registered",
      user: sanitizeUser(user.toObject()),
      tokens: { accessToken, refreshToken },
    });
  } catch (e) {
    console.error("/register error:", e);
    return res.status(500).json({ ok: false, message: "Registration failed" });
  }
});

/* --------------------------------------------------------------------------
 * POST /api/auth/login
 * Body: { email, password }
 * Verifies credentials, issues tokens, stores refresh session
 * -------------------------------------------------------------------------- */
router.post("/login", async (req, res) => {
  try {
    const err = requireFields(req.body, ["email", "password"]);
    if (err) return res.status(400).json({ ok: false, message: err });

    const { email, password } = req.body;

    const user = await User.findOne({ email: String(email).toLowerCase() });
    if (!user) return res.status(401).json({ ok: false, message: "Invalid credentials" });

    if (user.status !== "active") {
      return res.status(403).json({ ok: false, message: `User ${user.status}` });
    }

    const valid = await bcrypt.compare(password, user.passwordHash);
    if (!valid) return res.status(401).json({ ok: false, message: "Invalid credentials" });

    // Update last login (best-effort; don't block response on error)
    user.lastLoginAt = new Date();
    user.save().catch(() => {});

    const accessToken = signAccessToken(user, { expiresIn: ACCESS_TOKEN_TTL });
    const refreshToken = signRefreshToken(user);
    await persistSession(user, refreshToken, req);

    return res.json({
      ok: true,
      message: "Logged in",
      user: sanitizeUser(user.toObject()),
      tokens: { accessToken, refreshToken },
    });
  } catch (e) {
    console.error("/login error:", e);
    return res.status(500).json({ ok: false, message: "Login failed" });
  }
});

/* --------------------------------------------------------------------------
 * POST /api/auth/refresh
 * Body: { refreshToken }
 * Issues a new access token (and optionally rotates refresh token)
 * -------------------------------------------------------------------------- */
router.post("/refresh", async (req, res) => {
  try {
    const err = requireFields(req.body, ["refreshToken"]);
    if (err) return res.status(400).json({ ok: false, message: err });

    const { refreshToken } = req.body;

    let payload;
    try {
      payload = jwt.verify(refreshToken, REFRESH_SECRET, { clockTolerance: 5 });
    } catch (_e) {
      return res.status(401).json({ ok: false, message: "Invalid or expired refresh token" });
    }

    const refreshTokenHash = sha256(refreshToken);
    const session = await Session.findOne({ refreshTokenHash });
    if (!session || session.revoked || session.expiresAt < new Date()) {
      return res.status(401).json({ ok: false, message: "Refresh session invalid" });
    }

    const user = await User.findById(payload.sub);
    if (!user || user.status !== "active") {
      return res.status(403).json({ ok: false, message: "User inactive or missing" });
    }

    const accessToken = signAccessToken(user, { expiresIn: ACCESS_TOKEN_TTL });

    // (Optional) rotate refresh token for extra security
    const rotate = true;
    if (rotate) {
      session.revoked = true;
      session.revokedAt = new Date();
      await session.save();

      const newRefreshToken = signRefreshToken(user);
      await persistSession(user, newRefreshToken, req);
      return res.json({ ok: true, tokens: { accessToken, refreshToken: newRefreshToken } });
    }

    return res.json({ ok: true, tokens: { accessToken } });
  } catch (e) {
    console.error("/refresh error:", e);
    return res.status(500).json({ ok: false, message: "Token refresh failed" });
  }
});

/* --------------------------------------------------------------------------
 * POST /api/auth/logout
 * Body: { refreshToken }
 * Revokes the session for the refresh token
 * -------------------------------------------------------------------------- */
router.post("/logout", async (req, res) => {
  try {
    const err = requireFields(req.body, ["refreshToken"]);
    if (err) return res.status(400).json({ ok: false, message: err });

    const { refreshToken } = req.body;
    const refreshTokenHash = sha256(refreshToken);
    const session = await Session.findOne({ refreshTokenHash });
    if (!session) return res.json({ ok: true, message: "Already logged out" });

    session.revoked = true;
    session.revokedAt = new Date();
    await session.save();

    return res.json({ ok: true, message: "Logged out" });
  } catch (e) {
    console.error("/logout error:", e);
    return res.status(500).json({ ok: false, message: "Logout failed" });
  }
});

/* --------------------------------------------------------------------------
 * GET /api/auth/verify
 * Header: Authorization: Bearer <accessToken>
 * Quick check to validate access token and return user/basic info
 * -------------------------------------------------------------------------- */
router.get("/verify", verifyToken(), async (req, res) => {
  // verifyToken already attached req.user and req.auth if valid
  return res.json({ ok: true, user: sanitizeUser(req.user) });
});

/* --------------------------------------------------------------------------
 * GET /api/auth/me
 * Same as verify but a more semantic path; requires valid token
 * -------------------------------------------------------------------------- */
router.get("/me", verifyToken(), async (req, res) => {
  return res.json({ ok: true, user: sanitizeUser(req.user) });
});

export default router;
