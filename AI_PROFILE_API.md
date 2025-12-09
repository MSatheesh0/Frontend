# AI Profile & Extended Features API Documentation

## Overview

The basic `/me` endpoint provides core profile fields (name, role, company, etc.), but the AI Profile screen displays additional AI-generated content that requires separate endpoints.

---

## 🤖 AI-Generated Profile Content

### 1. Get AI Profile Summary
**Endpoint:** `GET /me/ai-profile`

**Description:** Retrieves AI-generated profile content including summary, focus areas, strengths, and highlights.

**Headers:**
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

**Response (200 OK):**
```json
{
  "summary": "Founder with 5+ years of experience in AI/ML, passionate about building products that solve real problems. Currently raising Series A funding.",
  "currentFocus": [
    "Raising Series A funding ($3M target)",
    "Building AI-powered analytics dashboard",
    "Expanding team: hiring 2 senior engineers",
    "Launching beta in Q1 2025"
  ],
  "strengths": [
    "Product Management",
    "Technical Architecture",
    "Fundraising",
    "Team Building",
    "Go-to-Market Strategy"
  ],
  "highlights": [
    "Built and scaled product to 10K users",
    "Raised $500K in pre-seed funding",
    "Former Senior PM at Google",
    "Published 3 technical papers on ML"
  ],
  "generatedAt": "2024-01-20T15:45:00.000Z",
  "lastUpdated": "2024-01-20T15:45:00.000Z"
}
```

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `summary` | string | AI-generated 2-3 sentence profile summary |
| `currentFocus` | string[] | Array of current focus areas/activities |
| `strengths` | string[] | Key skills and strengths |
| `highlights` | string[] | Major achievements and credentials |
| `generatedAt` | string | When AI profile was first generated |
| `lastUpdated` | string | Last time AI profile was updated |

---

### 2. Regenerate AI Profile
**Endpoint:** `POST /me/ai-profile/regenerate`

**Description:** Triggers AI to regenerate profile content based on current profile data, documents, and goals.

**Headers:**
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

**Request Body (Optional):**
```json
{
  "includeGoals": true,
  "includeDocuments": true,
  "tone": "professional"
}
```

**Response (200 OK):**
```json
{
  "summary": "Updated AI-generated summary...",
  "currentFocus": [...],
  "strengths": [...],
  "highlights": [...],
  "generatedAt": "2024-01-20T16:00:00.000Z",
  "lastUpdated": "2024-01-20T16:00:00.000Z"
}
```

---

## 📄 Documents Management

### 3. Get Documents List
**Endpoint:** `GET /me/documents`

**Description:** Retrieves all documents attached to user's profile.

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Response (200 OK):**
```json
{
  "documents": [
    {
      "id": "doc_123",
      "title": "Pitch Deck",
      "description": "Series A funding pitch deck",
      "type": "pdf",
      "url": "https://storage.example.com/docs/pitch-deck.pdf",
      "uploadedAt": "2024-01-15T10:00:00.000Z",
      "size": 2048576,
      "metadata": {
        "pages": 15,
        "category": "fundraising"
      }
    },
    {
      "id": "doc_124",
      "title": "Resume",
      "description": "Professional resume",
      "type": "pdf",
      "url": "https://storage.example.com/docs/resume.pdf",
      "uploadedAt": "2024-01-10T09:00:00.000Z",
      "size": 512000,
      "metadata": {
        "pages": 2,
        "category": "professional"
      }
    },
    {
      "id": "doc_125",
      "title": "Product Demo",
      "description": null,
      "type": "link",
      "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      "uploadedAt": "2024-01-18T14:30:00.000Z",
      "metadata": {
        "platform": "youtube",
        "category": "demo"
      }
    }
  ],
  "total": 3
}
```

---

### 4. Upload Document
**Endpoint:** `POST /me/documents`

**Description:** Upload a new document or add a link to profile.

**Headers:**
```
Authorization: Bearer <jwt_token>
Content-Type: multipart/form-data (for file upload)
OR
Content-Type: application/json (for link)
```

**Request (File Upload):**
```
POST /me/documents
Content-Type: multipart/form-data

file: [binary file data]
title: "Pitch Deck"
description: "Series A pitch deck"
type: "pdf"
category: "fundraising"
```

**Request (Link):**
```json
{
  "title": "Product Demo Video",
  "description": "Demo of our product features",
  "type": "link",
  "url": "https://youtube.com/watch?v=...",
  "category": "demo"
}
```

**Response (201 Created):**
```json
{
  "id": "doc_126",
  "title": "Pitch Deck",
  "description": "Series A pitch deck",
  "type": "pdf",
  "url": "https://storage.example.com/docs/pitch-deck-126.pdf",
  "uploadedAt": "2024-01-20T16:15:00.000Z",
  "size": 2048576,
  "metadata": {
    "pages": 15,
    "category": "fundraising"
  }
}
```

---

### 5. Delete Document
**Endpoint:** `DELETE /me/documents/:documentId`

**Description:** Delete a document from profile.

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Response (200 OK):**
```json
{
  "message": "Document deleted successfully",
  "documentId": "doc_123"
}
```

---

## 🎯 Goals Management

### 6. Get Current Goals
**Endpoint:** `GET /me/goals`

**Description:** Retrieves user's active goals.

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Query Parameters:**
- `status` (optional): Filter by status - `active`, `completed`, `archived`
- `limit` (optional): Number of goals to return (default: 10)

**Response (200 OK):**
```json
{
  "goals": [
    {
      "id": "goal_789",
      "title": "Raise Series A Funding",
      "description": "Secure $3M in Series A funding",
      "category": "fundraising",
      "status": "active",
      "progress": 60,
      "targetDate": "2025-03-31T00:00:00.000Z",
      "milestones": [
        {
          "id": "milestone_1",
          "title": "Complete pitch deck",
          "completed": true,
          "completedAt": "2024-01-10T10:00:00.000Z"
        },
        {
          "id": "milestone_2",
          "title": "Contact 20 investors",
          "completed": false
        }
      ],
      "createdAt": "2024-01-05T08:00:00.000Z",
      "updatedAt": "2024-01-20T14:30:00.000Z"
    },
    {
      "id": "goal_790",
      "title": "Hire 2 Senior Engineers",
      "description": "Expand engineering team",
      "category": "hiring",
      "status": "active",
      "progress": 30,
      "targetDate": "2025-02-28T00:00:00.000Z",
      "milestones": [
        {
          "id": "milestone_3",
          "title": "Post job listings",
          "completed": true,
          "completedAt": "2024-01-15T12:00:00.000Z"
        },
        {
          "id": "milestone_4",
          "title": "Interview candidates",
          "completed": false
        }
      ],
      "createdAt": "2024-01-08T09:00:00.000Z",
      "updatedAt": "2024-01-18T16:00:00.000Z"
    }
  ],
  "total": 2
}
```

**Goal Categories:**
- `fundraising` - Raising capital
- `hiring` - Recruiting talent
- `product` - Product development
- `growth` - Business growth
- `networking` - Building connections
- `learning` - Skill development
- `other` - Other goals

**Goal Status:**
- `active` - Currently working on
- `completed` - Achieved
- `paused` - Temporarily on hold
- `archived` - No longer relevant

---

### 7. Create Goal
**Endpoint:** `POST /me/goals`

**Description:** Create a new goal.

**Request Body:**
```json
{
  "title": "Launch Beta Product",
  "description": "Launch beta version to first 100 users",
  "category": "product",
  "targetDate": "2025-04-30T00:00:00.000Z",
  "milestones": [
    {
      "title": "Complete MVP features"
    },
    {
      "title": "Recruit beta testers"
    },
    {
      "title": "Deploy to production"
    }
  ]
}
```

**Response (201 Created):**
```json
{
  "id": "goal_791",
  "title": "Launch Beta Product",
  "description": "Launch beta version to first 100 users",
  "category": "product",
  "status": "active",
  "progress": 0,
  "targetDate": "2025-04-30T00:00:00.000Z",
  "milestones": [
    {
      "id": "milestone_5",
      "title": "Complete MVP features",
      "completed": false
    },
    {
      "id": "milestone_6",
      "title": "Recruit beta testers",
      "completed": false
    },
    {
      "id": "milestone_7",
      "title": "Deploy to production",
      "completed": false
    }
  ],
  "createdAt": "2024-01-20T16:30:00.000Z",
  "updatedAt": "2024-01-20T16:30:00.000Z"
}
```

---

### 8. Update Goal
**Endpoint:** `PUT /me/goals/:goalId`

**Description:** Update goal details or progress.

**Request Body:**
```json
{
  "title": "Updated Goal Title",
  "progress": 75,
  "status": "active"
}
```

---

### 9. Delete Goal
**Endpoint:** `DELETE /me/goals/:goalId`

**Description:** Delete or archive a goal.

**Query Parameters:**
- `archive` (optional): Set to `true` to archive instead of delete

---

## 🔗 Integration with Current Flutter App

### Current Implementation Status

**✅ Already Working:**
- Basic profile data (name, role, company, etc.) - uses `/me`
- Mock AI profile summary, focus, strengths (currently hardcoded)
- Mock documents list (currently hardcoded)
- Mock goals list (currently hardcoded)

**❌ Needs Backend APIs:**
- AI profile generation/regeneration
- Real documents upload/management
- Real goals CRUD operations
- Sync between AI profile and actual data

### Flutter Implementation Plan

#### 1. Create AI Profile Service
```dart
// lib/services/ai_profile_service.dart
class AIProfileService {
  Future<AIProfileData> getAIProfile() async {
    // GET /me/ai-profile
  }
  
  Future<AIProfileData> regenerateAIProfile() async {
    // POST /me/ai-profile/regenerate
  }
}
```

#### 2. Create Documents Service
```dart
// lib/services/documents_service.dart
class DocumentsService {
  Future<List<Document>> getDocuments() async {
    // GET /me/documents
  }
  
  Future<Document> uploadDocument(File file, ...) async {
    // POST /me/documents
  }
  
  Future<void> deleteDocument(String id) async {
    // DELETE /me/documents/:id
  }
}
```

#### 3. Create Goals Service
```dart
// lib/services/goals_service.dart
class GoalsService {
  Future<List<Goal>> getGoals({String? status}) async {
    // GET /me/goals
  }
  
  Future<Goal> createGoal(Goal goal) async {
    // POST /me/goals
  }
  
  Future<Goal> updateGoal(String id, Map<String, dynamic> updates) async {
    // PUT /me/goals/:id
  }
  
  Future<void> deleteGoal(String id, {bool archive = false}) async {
    // DELETE /me/goals/:id
  }
}
```

---

## 🎯 Summary of Required Backend APIs

| Feature | Endpoint | Status | Priority |
|---------|----------|--------|----------|
| Basic Profile | `GET /me`, `PUT /me` | ✅ Exists | Critical |
| AI Profile | `GET /me/ai-profile` | ❌ Needed | High |
| Regenerate AI | `POST /me/ai-profile/regenerate` | ❌ Needed | Medium |
| List Documents | `GET /me/documents` | ❌ Needed | High |
| Upload Document | `POST /me/documents` | ❌ Needed | High |
| Delete Document | `DELETE /me/documents/:id` | ❌ Needed | Medium |
| List Goals | `GET /me/goals` | ❌ Needed | High |
| Create Goal | `POST /me/goals` | ❌ Needed | High |
| Update Goal | `PUT /me/goals/:id` | ❌ Needed | High |
| Delete Goal | `DELETE /me/goals/:id` | ❌ Needed | Medium |

---

## 🚀 Next Steps

1. **Backend Team**: Implement the 9 additional endpoints listed above
2. **Frontend Team**: Create service classes for AI Profile, Documents, and Goals
3. **Integration**: Replace mock data with real API calls
4. **Testing**: Test end-to-end flow with real data

Once these APIs are ready, the AI Profile screen will be fully functional with real data! 🎉
