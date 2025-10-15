// Middleware/Auth.js — JWT auth & role guards (ESM)

import jwt from "jsonwebtoken";
import { User } from "../Models/models.js";

const ACCESS_TOKEN_SECRET = process.env.JWT_SECRET;
if (!ACCESS_TOKEN_SECRET) {
  throw new Error("JWT_SECRET missing in .env");
}

/**
 * Extract Bearer token from Authorization header.
 */
function getBearer(req) {
  const auth = req.headers.authorization || req.headers.Authorization;
  if (!auth || typeof auth !== "string") return null;
  const [scheme, token] = auth.split(" ");
  if (scheme?.toLowerCase() !== "bearer" || !token) return null;
  return token.trim();
}

/**
 * Verify access token, attach payload to req.auth, and (optionally) attach user doc to req.user.
 * Fails with 401 on missing/invalid token, 403 on banned/suspended user.
 */
export function verifyToken({ attachUser = true } = {}) {
  return async (req, res, next) => {
    try {
      const token = getBearer(req);
      if (!token) {
        return res.status(401).json({ ok: false, message: "No token provided" });
      }

      let payload;
      try {
        payload = jwt.verify(token, ACCESS_TOKEN_SECRET, {
          clockTolerance: 5, // seconds tolerance for small clock drift
        });
      } catch (err) {
        return res.status(401).json({ ok: false, message: "Invalid or expired token" });
      }

      req.auth = payload; // { sub, role, email, iat, exp, ... }

      if (!attachUser) return next();

      // Attach live user document (ensures status/rbac checks use freshest data)
      const user = await User.findById(payload.sub).lean();
      if (!user) {
        return res.status(401).json({ ok: false, message: "User not found" });
      }
      if (user.status && user.status !== "active") {
        return res.status(403).json({ ok: false, message: `User ${user.status}` });
      }
      req.user = user;
      return next();
    } catch (err) {
      console.error("verifyToken error:", err);
      return res.status(500).json({ ok: false, message: "Auth middleware error" });
    }
  };
}

/**
 * Allow requests without a token, but if present, validate and attach req.auth/req.user.
 * Never throws 401—only enriches the request when possible.
 */
export function optionalAuth({ attachUser = true } = {}) {
  return async (req, res, next) => {
    const token = getBearer(req);
    if (!token) return next();
    try {
      const payload = jwt.verify(token, ACCESS_TOKEN_SECRET, { clockTolerance: 5 });
      req.auth = payload;
      if (attachUser) {
        const user = await User.findById(payload.sub).lean();
        if (user && user.status === "active") req.user = user;
      }
    } catch (_) {
      // ignore token errors silently for optional paths
    }
    return next();
  };
}

/**
 * Role-based guard. Use after verifyToken().
 * Example: app.get("/admin", verifyToken(), requireRoles("admin"), handler)
 */
export function requireRoles(...roles) {
  return (req, res, next) => {
    const role = req?.auth?.role || req?.user?.role;
    if (!role) {
      return res.status(401).json({ ok: false, message: "Not authenticated" });
    }
    if (!roles.includes(role)) {
      return res.status(403).json({ ok: false, message: "Forbidden (role)" });
    }
    return next();
  };
}

/**
 * Ownership/identity guard helper.
 * - checks if req.user._id equals param id OR user has privileged role(s)
 * Usage: app.get("/users/:id", verifyToken(), requireSelfOrRoles("admin"), handler)
 */
export function requireSelfOrRoles(...roles) {
  return (req, res, next) => {
    const userId = String(req?.user?._id || "");
    const paramId = String(req.params?.id || "");
    const role = req?.user?.role || req?.auth?.role;

    if (userId && paramId && userId === paramId) return next();
    if (role && roles.includes(role)) return next();

    return res.status(403).json({ ok: false, message: "Forbidden (ownership/role)" });
  };
}

/* ---------------------------------------------------------
 * OPTIONAL: Utility to issue access tokens.
 * You can also place this in your AuthRoutes controller.
 * --------------------------------------------------------- */
export function signAccessToken(user, { expiresIn = "2h" } = {}) {
  // keep payload minimal; never embed sensitive data
  const payload = {
    sub: String(user._id),
    role: user.role,
    email: user.email,
  };
  return jwt.sign(payload, ACCESS_TOKEN_SECRET, { expiresIn });
}
