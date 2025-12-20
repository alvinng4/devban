
```
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // user info
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
      allow delete: if request.auth.uid == userId;
    }
    
    // team data
    match /teams/{teamId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Team discussion data
    match /discussion/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // LLM data
    match /askllm_transcripts/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // tasks data
    match /tasks/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // create-team invite code
    match /licenses/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // team invite code
    match /team_invite_codes/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```