# Database Design for Networking Features

## Overview

This document explains the database structure for network codes, QR profiles, connections, and connection requests.

---

## Collections

### 1. Network Codes

**Purpose:** Group networking codes for events or sessions

**Key Features:**
- **Unique ID Generation:** Each network code has a unique ID (e.g., `nc_1732789012345`)
- **Auto-Connect:** If `autoConnect: true`, connections are made automatically without requests
- **Auto-Connect:** If `autoConnect: false`, connection requests are created and must be approved

**Schema:**
```json
{
  "id": "nc_<timestamp>",           // Unique ID
  "code": "TECH2024",                // Human-readable code
  "name": "Event Name",
  "description": "Description",
  "createdBy": "user_id",
  "createdAt": "ISO timestamp",
  "expiresAt": "ISO timestamp",
  "autoConnect": true/false,         // Auto-connect feature
  "isActive": true/false,
  "maxConnections": 100,
  "currentConnections": 12,
  "tags": ["tag1", "tag2"]
}
```

**ID Generation:**
- Use `metadata.nextNetworkCodeId` to get the next ID
- Increment after creating a new network code
- Format: `nc_<incrementing_number>`

---

### 2. QR Profiles

**Purpose:** User-specific QR codes for different contexts

**Schema:**
```json
{
  "id": "qr_<timestamp>",
  "userId": "user_id",
  "title": "Profile Title",
  "description": "Description",
  "context": "fundraising|professional|investing|mentorship|hiring",
  "customMessage": "Custom message",
  "isActive": true/false,
  "createdAt": "ISO timestamp",
  "scannedCount": 15
}
```

**ID Generation:**
- Use `metadata.nextQrProfileId`
- Format: `qr_<incrementing_number>`

---

### 3. Connections

**Purpose:** Store established connections between users

**Schema:**
```json
{
  "id": "conn_<timestamp>",
  "userId1": "user_id",
  "userId2": "user_id",
  "status": "connected",
  "connectedAt": "ISO timestamp",
  "connectionSource": "qr_scan|network_code",
  "sourceId": "qr_id or nc_id",
  "notes": "Optional notes",
  "tags": ["tag1", "tag2"]
}
```

**Connection Flow:**

**If Auto-Connect is TRUE:**
1. User scans QR or enters network code
2. Check if network code has `autoConnect: true`
3. Create connection directly in `connections` collection
4. No request needed!

**If Auto-Connect is FALSE:**
1. User scans QR or enters network code
2. Create entry in `connectionRequests` with status "pending"
3. Other user approves/rejects
4. If approved, move to `connections` collection

---

### 4. Connection Requests

**Purpose:** Pending connection requests that need approval

**Schema:**
```json
{
  "id": "req_<timestamp>",
  "fromUserId": "user_id",
  "toUserId": "user_id",
  "status": "pending|accepted|rejected",
  "requestedAt": "ISO timestamp",
  "respondedAt": "ISO timestamp",      // When accepted/rejected
  "message": "Optional message",
  "source": "qr_scan|network_code",
  "sourceId": "qr_id or nc_id",
  "expiresAt": "ISO timestamp",
  "rejectionReason": "Optional reason"  // If rejected
}
```

**Request Statuses:**
- `pending` - Waiting for response
- `accepted` - Approved, connection created
- `rejected` - Declined

---

## Workflows

### Workflow 1: Create Network Code

```javascript
// 1. Get next ID from metadata
const nextId = metadata.nextNetworkCodeId;

// 2. Create network code
const networkCode = {
  id: `nc_${nextId}`,
  code: "UNIQUE_CODE",  // User-provided or generated
  name: "Event Name",
  autoConnect: true,    // User choice
  // ... other fields
};

// 3. Save to networkCodes collection

// 4. Update metadata
metadata.nextNetworkCodeId = nextId + 1;
```

### Workflow 2: Scan QR Code (Auto-Connect)

```javascript
// 1. Scan QR code, get qrProfile.id
const qrProfile = findQRProfile(scannedId);
const targetUser = qrProfile.userId;

// 2. Check if already connected
if (alreadyConnected(currentUser, targetUser)) {
  return "Already connected";
}

// 3. Create connection directly (no request)
const connection = {
  id: `conn_${metadata.nextConnectionId}`,
  userId1: currentUser.id,
  userId2: targetUser,
  status: "connected",
  connectedAt: new Date().toISOString(),
  connectionSource: "qr_scan",
  sourceId: qrProfile.id
};

// 4. Save to connections
// 5. Update metadata.nextConnectionId
```

### Workflow 3: Join Network Code (Auto-Connect TRUE)

```javascript
// 1. User enters network code
const networkCode = findNetworkCode(code);

// 2. Check if autoConnect is true
if (networkCode.autoConnect === true) {
  // 3. Get all members of this network code
  const members = getNetworkCodeMembers(networkCode.id);
  
  // 4. Create connections with ALL members automatically
  members.forEach(member => {
    if (!alreadyConnected(currentUser, member)) {
      createConnection(currentUser, member, networkCode.id);
    }
  });
  
  // 5. Update currentConnections count
  networkCode.currentConnections++;
}
```

### Workflow 4: Join Network Code (Auto-Connect FALSE)

```javascript
// 1. User enters network code
const networkCode = findNetworkCode(code);

// 2. Check if autoConnect is false
if (networkCode.autoConnect === false) {
  // 3. Get all members
  const members = getNetworkCodeMembers(networkCode.id);
  
  // 4. Create connection REQUESTS for each member
  members.forEach(member => {
    if (!alreadyConnected(currentUser, member)) {
      createConnectionRequest(currentUser, member, networkCode.id);
    }
  });
  
  // 5. Members will see requests and can approve/reject
}
```

### Workflow 5: Approve Connection Request

```javascript
// 1. User approves a request
const request = findRequest(requestId);

// 2. Update request status
request.status = "accepted";
request.respondedAt = new Date().toISOString();

// 3. Create connection
const connection = {
  id: `conn_${metadata.nextConnectionId}`,
  userId1: request.fromUserId,
  userId2: request.toUserId,
  status: "connected",
  connectedAt: new Date().toISOString(),
  connectionSource: request.source,
  sourceId: request.sourceId
};

// 4. Save connection
// 5. Update metadata
```

---

## Sample Data Included

**4 Users:**
- demo@waytree.com (Founder)
- test@example.com (Investor)
- mentor@example.com (Mentor)
- founder@startup.com (Founder)

**4 Network Codes:**
- TECH2024 (auto-connect: true)
- INVEST2024 (auto-connect: false)
- STARTUP2024 (auto-connect: true)
- HIRING2024 (auto-connect: false)

**5 QR Profiles:**
- Various contexts (fundraising, professional, investing, mentorship, hiring)

**5 Connections:**
- Established connections between users

**3 Connection Requests:**
- 1 pending
- 1 accepted
- 1 rejected

---

## Key Points

1. **Unique IDs:** Always use metadata counters to generate unique IDs
2. **Auto-Connect:** Determines if connections are automatic or require approval
3. **Connection Source:** Track how users connected (QR scan vs network code)
4. **Expiration:** Network codes and requests can expire
5. **Status Tracking:** Connections and requests have clear status fields

---

## Testing

**Login Credentials:**
- demo@waytree.com / demo123
- test@example.com / test123
- mentor@example.com / mentor123
- founder@startup.com / founder123

**Test Network Codes:**
- TECH2024 (auto-connect)
- INVEST2024 (requires approval)
- STARTUP2024 (auto-connect)
- HIRING2024 (requires approval)

---

**Created:** November 28, 2024  
**Version:** 1.0.0
