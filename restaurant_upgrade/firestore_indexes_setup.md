# Firestore Indexes Setup

## Cần tạo các composite indexes sau trong Firebase Console:

### 1. Index cho Restaurants Collection

**Collection ID:** `restaurants`

**Fields:**
1. `isActive` - Ascending
2. `averageRating` - Descending

**URL để tạo index:**
```
https://console.firebase.google.com/v1/r/project/restaurant-183c3/firestore/indexes?create_composite=ClRwcm9qZWN0cy9yZXN0YXVyYW50LTE4M2MzL2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9yZXN0YXVyYW50cy9pbmRleGVzL18QARoMCghpc0FjdGl2ZRABGhEKDWF2ZXJhZ2VSYXRpbmcQAhoMCghfX25hbWVfXxAC
```

### 2. Index cho Restaurants với Categories

**Collection ID:** `restaurants`

**Fields:**
1. `categories` - Array-contains
2. `isActive` - Ascending  
3. `averageRating` - Descending

**URL để tạo index:**
```
https://console.firebase.google.com/v1/r/project/restaurant-183c3/firestore/indexes?create_composite=ClRwcm9qZWN0cy9yZXN0YXVyYW50LTE4M2MzL2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9yZXN0YXVyYW50cy9pbmRleGVzL18QARoOCgpjYXRlZ29yaWVzGAEaDAoIaXNBY3RpdmUQARoRCg1hdmVyYWdlUmF0aW5nEAIaDAoIX19uYW1lX18QAg
```

### 3. Index cho Notifications Collection

**Collection ID:** `notifications`

**Fields:**
1. `userId` - Ascending
2. `createdAt` - Descending

**URL để tạo index:**
```
https://console.firebase.google.com/v1/r/project/restaurant-183c3/firestore/indexes?create_composite=ClZwcm9qZWN0cy9yZXN0YXVyYW50LTE4M2MzL2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9ub3RpZmljYXRpb25zL2luZGV4ZXMvXxABGgoKBnVzZXJJZBABGg0KCWNyZWF0ZWRBdBACGgwKCF9fbmFtZV9fEAI
```

## Cách tạo indexes:

1. Mở Firebase Console: https://console.firebase.google.com/
2. Chọn project `restaurant-183c3`
3. Vào Firestore Database
4. Chọn tab "Indexes"
5. Click "Create Index" hoặc sử dụng các URL trên
6. Đợi indexes được build (có thể mất vài phút)

## Hoặc sử dụng Firebase CLI:

```bash
firebase deploy --only firestore:indexes
```

Với file `firestore.indexes.json`:

```json
{
  "indexes": [
    {
      "collectionGroup": "restaurants",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "isActive", "order": "ASCENDING"},
        {"fieldPath": "averageRating", "order": "DESCENDING"}
      ]
    },
    {
      "collectionGroup": "restaurants", 
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "categories", "arrayConfig": "CONTAINS"},
        {"fieldPath": "isActive", "order": "ASCENDING"},
        {"fieldPath": "averageRating", "order": "DESCENDING"}
      ]
    },
    {
      "collectionGroup": "notifications",
      "queryScope": "COLLECTION", 
      "fields": [
        {"fieldPath": "userId", "order": "ASCENDING"},
        {"fieldPath": "createdAt", "order": "DESCENDING"}
      ]
    }
  ]
}
```