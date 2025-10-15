// models.js — Spazigo (single file models)
// Uses Mongoose. Assumes Node with "type": "module".

import mongoose from 'mongoose';

const { Schema, model, Types } = mongoose;

/* --------------------------- Common Sub-Schemas --------------------------- */
const GeoPointSchema = new Schema(
  {
    type: { type: String, enum: ['Point'], required: true, default: 'Point' },
    coordinates: {
      type: [Number], // [lng, lat]
      required: true,
      validate: {
        validator: (v) => Array.isArray(v) && v.length === 2,
        message: 'coordinates must be [lng, lat]'
      }
    }
  },
  { _id: false }
);

const AddressSchema = new Schema(
  {
    label: String,
    line1: { type: String, required: true },
    line2: String,
    city: String,
    state: String,
    pincode: String,
    loc: { type: GeoPointSchema }
  },
  { _id: false }
);

/* --------------------------------- Users --------------------------------- */
const UserSchema = new Schema(
  {
    name: { type: String, required: true, trim: true },
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    phone: { type: String, unique: true, sparse: true },
    passwordHash: { type: String, required: true },
    role: {
      type: String,
      enum: ['admin', 'driver', 'merchant', 'logistic', 'sanjit'],
      required: true
    },
    status: { type: String, enum: ['active', 'suspended', 'deleted'], default: 'active' },
    provider: { type: String, enum: ['local', 'google', 'apple'], default: 'local' },
    meta: { type: Schema.Types.Mixed },
    lastLoginAt: { type: Date }
  },
  { timestamps: true }
);
UserSchema.index({ email: 1 }, { unique: true });
UserSchema.index({ phone: 1 }, { unique: true, sparse: true });

/* --------------------------- Driver Profile ------------------------------ */
const DriverDocumentSchema = new Schema(
  {
    type: {
      type: String,
      enum: ['driving_license', 'aadhar', 'rc_book', 'insurance', 'pollution', 'other'],
      required: true
    },
    number: String,
    url: { type: String, required: true },
    expiryDate: Date,
    verified: { type: Boolean, default: false },
    verifiedBy: { type: Types.ObjectId, ref: 'User' },
    verifiedAt: Date,
    notes: String
  },
  { _id: true, timestamps: true }
);

const DriverProfileSchema = new Schema(
  {
    user: { type: Types.ObjectId, ref: 'User', required: true, unique: true },
    licenseNo: { type: String },
    licenseExpiry: { type: Date },
    vehicle: { type: Types.ObjectId, ref: 'Vehicle' },
    currentStatus: { type: String, enum: ['offline', 'idle', 'en_route', 'delivering'], default: 'offline' },
    lastKnownLocation: { type: GeoPointSchema },
    servicePincodes: [{ type: String }],
    documents: [DriverDocumentSchema]
  },
  { timestamps: true }
);
DriverProfileSchema.index({ user: 1 }, { unique: true });
DriverProfileSchema.index({ lastKnownLocation: '2dsphere' });

/* -------------------------- Merchant Profile ----------------------------- */
const MerchantProfileSchema = new Schema(
  {
    user: { type: Types.ObjectId, ref: 'User', required: true, unique: true },
    companyName: { type: String, required: true },
    gstNo: { type: String },
    contactName: { type: String },
    primaryPhone: { type: String },
    addresses: [AddressSchema],
    walletBalance: { type: Number, default: 0 }
  },
  { timestamps: true }
);
MerchantProfileSchema.index({ user: 1 }, { unique: true });
MerchantProfileSchema.index({ 'addresses.loc': '2dsphere' });

/* -------------------------- Optional Other Profiles ---------------------- */
const LogisticProfileSchema = new Schema(
  {
    user: { type: Types.ObjectId, ref: 'User', required: true, unique: true },
    companyName: String,
    notes: String
  },
  { timestamps: true }
);
LogisticProfileSchema.index({ user: 1 }, { unique: true });

const AdminProfileSchema = new Schema(
  {
    user: { type: Types.ObjectId, ref: 'User', required: true, unique: true },
    permissions: [{ type: String }]
  },
  { timestamps: true }
);
AdminProfileSchema.index({ user: 1 }, { unique: true });

/* -------------------------------- Vehicles ------------------------------- */
const VehicleSchema = new Schema(
  {
    numberPlate: { type: String, required: true, unique: true, uppercase: true, trim: true },
    type: { type: String, enum: ['bike', 'scooter', 'car', 'van', 'mini_truck', 'truck'], required: true },
    capacityKg: { type: Number, required: true },
    capacityVolCft: { type: Number },
    dimensions: { l: Number, w: Number, h: Number },
    ownerType: { type: String, enum: ['driver', 'company', 'merchant'], default: 'driver' },
    ownerId: { type: Types.ObjectId, ref: 'User' },
    rcDoc: { url: String },
    fitnessExpiry: { type: Date },
    status: { type: String, enum: ['active', 'maintenance', 'retired'], default: 'active' }
  },
  { timestamps: true }
);
VehicleSchema.index({ numberPlate: 1 }, { unique: true });

/* -------------------------------- Shipments ------------------------------ */
const ShipmentSchema = new Schema(
  {
    code: { type: String, required: true, unique: true },
    merchant: { type: Types.ObjectId, ref: 'User', required: true },
    pickup: {
      address: { type: String, required: true },
      pincode: { type: String },
      loc: { type: GeoPointSchema },
      contactName: String,
      phone: String,
      scheduledAt: Date
    },
    drop: {
      address: { type: String, required: true },
      pincode: { type: String },
      loc: { type: GeoPointSchema },
      contactName: String,
      phone: String
    },
    package: {
      pieces: { type: Number, default: 1 },
      weightKg: { type: Number, default: 0 },
      volCft: { type: Number },
      fragile: { type: Boolean, default: false },
      category: { type: String },
      codAmount: { type: Number }
    },
    pricing: {
      subtotal: { type: Number, default: 0 },
      tax: { type: Number, default: 0 },
      discount: { type: Number, default: 0 },
      total: { type: Number, default: 0 }
    },
    status: {
      type: String,
      enum: [
        'created',
        'queued',
        'assigned',
        'picked_up',
        'in_transit',
        'out_for_delivery',
        'delivered',
        'failed',
        'canceled'
      ],
      default: 'created'
    },
    assignedDriver: { type: Types.ObjectId, ref: 'User' },
    notes: String,
    assignedAt: Date,
    pickedAt: Date,
    deliveredAt: Date,
    canceledAt: Date,
    proofOfDelivery: { type: Types.ObjectId, ref: 'Proof' }
  },
  { timestamps: true }
);
ShipmentSchema.index({ code: 1 }, { unique: true });
ShipmentSchema.index({ merchant: 1, status: 1 });
ShipmentSchema.index({ 'pickup.loc': '2dsphere' });
ShipmentSchema.index({ 'drop.loc': '2dsphere' });

/* ------------------------------- Assignments ----------------------------- */
const AssignmentSchema = new Schema(
  {
    shipment: { type: Types.ObjectId, ref: 'Shipment', required: true },
    driver: { type: Types.ObjectId, ref: 'User', required: true },
    status: {
      type: String,
      enum: ['offered', 'accepted', 'rejected', 'started', 'completed', 'canceled', 'expired'],
      default: 'offered'
    },
    offeredAt: { type: Date, default: () => new Date() },
    acceptedAt: Date,
    rejectedAt: Date,
    startedAt: Date,
    completedAt: Date,
    canceledAt: Date,
    reason: String,
    autoAssigned: { type: Boolean, default: false }
  },
  { timestamps: true }
);
AssignmentSchema.index({ shipment: 1 });
AssignmentSchema.index({ driver: 1 });
AssignmentSchema.index({ status: 1 });

/* ------------------------------ Tracking Events -------------------------- */
const TrackingEventSchema = new Schema(
  {
    shipment: { type: Types.ObjectId, ref: 'Shipment', required: true },
    driver: { type: Types.ObjectId, ref: 'User' },
    type: {
      type: String,
      enum: ['status_change', 'location', 'scan', 'photo', 'note', 'delay', 'exception'],
      required: true
    },
    message: String,
    location: { type: GeoPointSchema },
    photos: [{ url: String, label: String }],
    data: Schema.Types.Mixed,
    at: { type: Date, default: () => new Date() }
  },
  { timestamps: true }
);
TrackingEventSchema.index({ shipment: 1, type: 1, at: -1 });
TrackingEventSchema.index({ location: '2dsphere' });

/* ---------------------------------- Proofs ------------------------------- */
const ProofSchema = new Schema(
  {
    subjectType: { type: String, enum: ['shipment', 'user', 'vehicle', 'merchant', 'other'], required: true },
    subjectId: { type: Types.ObjectId, required: true },
    proofType: {
      type: String,
      enum: ['pod', 'driving_license', 'aadhar', 'rc_book', 'insurance', 'gst', 'photo', 'other'],
      required: true
    },
    fileUrls: [{ type: String }],
    signatureImageUrl: String,
    recipientName: String,
    recipientPhone: String,
    otpUsed: { type: Boolean, default: false },
    metadata: Schema.Types.Mixed,
    verified: { type: Boolean, default: false },
    verifiedBy: { type: Types.ObjectId, ref: 'User' },
    verifiedAt: Date,
    collectedAt: Date
  },
  { timestamps: true }
);
ProofSchema.index({ subjectType: 1, subjectId: 1 });

/* ------------------------------- Notifications --------------------------- */
const NotificationSchema = new Schema(
  {
    user: { type: Types.ObjectId, ref: 'User', required: true },
    type: { type: String, enum: ['push', 'sms', 'email', 'inapp'], default: 'inapp' },
    title: { type: String, required: true },
    body: { type: String, required: true },
    data: Schema.Types.Mixed,
    read: { type: Boolean, default: false },
    sentAt: { type: Date, default: () => new Date() },
    readAt: Date
  },
  { timestamps: true }
);
NotificationSchema.index({ user: 1, read: 1 });

/* --------------------------------- Sessions ------------------------------ */
const SessionSchema = new Schema(
  {
    user: { type: Types.ObjectId, ref: 'User', required: true },
    refreshTokenHash: { type: String, required: true, unique: true },
    device: { ua: String, platform: String, ip: String },
    expiresAt: { type: Date, required: true },
    revoked: { type: Boolean, default: false },
    revokedAt: Date
  },
  { timestamps: true }
);
SessionSchema.index({ user: 1 });
SessionSchema.index({ refreshTokenHash: 1 }, { unique: true });

/* --------------------------------- OTP Codes ----------------------------- */
const OtpCodeSchema = new Schema(
  {
    channel: { type: String, enum: ['phone', 'email'], required: true },
    value: { type: String, required: true }, // phone or email value
    codeHash: { type: String, required: true },
    purpose: { type: String, enum: ['login', 'pod', 'password_reset'], required: true },
    expiresAt: { type: Date, required: true },
    attempts: { type: Number, default: 0 },
    maxAttempts: { type: Number, default: 5 },
    consumed: { type: Boolean, default: false }
  },
  { timestamps: true }
);
OtpCodeSchema.index({ channel: 1, value: 1, purpose: 1 });
OtpCodeSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 }); // TTL index once past expiresAt

/* --------------------------------- Exports ------------------------------- */
export const User = model('User', UserSchema);
export const DriverProfile = model('DriverProfile', DriverProfileSchema);
export const MerchantProfile = model('MerchantProfile', MerchantProfileSchema);
export const LogisticProfile = model('LogisticProfile', LogisticProfileSchema);
export const AdminProfile = model('AdminProfile', AdminProfileSchema);
export const Vehicle = model('Vehicle', VehicleSchema);
export const Shipment = model('Shipment', ShipmentSchema);
export const Assignment = model('Assignment', AssignmentSchema);
export const TrackingEvent = model('TrackingEvent', TrackingEventSchema);
export const Proof = model('Proof', ProofSchema);
export const Notification = model('Notification', NotificationSchema);
export const Session = model('Session', SessionSchema);
export const OtpCode = model('OtpCode', OtpCodeSchema);

// Helpful default export when importing everything at once
export default {
  User,
  DriverProfile,
  MerchantProfile,
  LogisticProfile,
  AdminProfile,
  Vehicle,
  Shipment,
  Assignment,
  TrackingEvent,
  Proof,
  Notification,
  Session,
  OtpCode
};
