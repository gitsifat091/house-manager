# -*- coding: utf-8 -*-
"""Generate firestore.indexes.json.

Written rather than hand-listed because the listing search combines four
optional equality filters independently, so every subset of them can reach
Firestore and each needs its own composite index with the createdAt ordering.
"""
import io
import json
from itertools import combinations

ASC = "ASCENDING"
DESC = "DESCENDING"


def idx(collection, *fields):
    return {
        "collectionGroup": collection,
        "queryScope": "COLLECTION",
        "fields": [{"fieldPath": f, "order": o} for f, o in fields],
    }


indexes = [
    # Payments and utilities: owner, then newest period first.
    idx("payments", ("landlordId", ASC), ("year", DESC), ("month", DESC)),
    idx("payments", ("tenantId", ASC), ("year", DESC), ("month", DESC)),
    idx("utilities", ("landlordId", ASC), ("year", DESC), ("month", DESC)),
    idx("utilities", ("tenantId", ASC), ("year", DESC), ("month", DESC)),
    # Newest first.
    idx("maintenance", ("landlordId", ASC), ("createdAt", DESC)),
    idx("maintenance", ("tenantId", ASC), ("createdAt", DESC)),
    idx("notices", ("landlordId", ASC), ("createdAt", DESC)),
    idx("listings", ("landlordId", ASC), ("createdAt", DESC)),
    idx("rentalRequests", ("landlordId", ASC), ("createdAt", DESC)),
    idx("rentalRequests", ("tenantUserId", ASC), ("createdAt", DESC)),
    # Most recently active conversation first.
    idx("chatRooms", ("landlordId", ASC), ("lastMessageAt", DESC)),
]

# The public to-let search. isActive is always filtered; the other four are
# independent checkboxes and text fields, so any subset can arrive.
OPTIONAL = ["division", "district", "thana", "roomType"]
for n in range(len(OPTIONAL) + 1):
    for combo in combinations(OPTIONAL, n):
        fields = [("isActive", ASC)]
        fields += [(f, ASC) for f in combo]
        fields.append(("createdAt", DESC))
        indexes.append(idx("listings", *fields))

out = {"indexes": indexes, "fieldOverrides": []}
with io.open("firestore.indexes.json", "w", encoding="utf-8", newline="\n") as f:
    f.write(json.dumps(out, indent=2))
    f.write("\n")

print("wrote %d indexes (%d for the listing search)" % (
    len(indexes), 2 ** len(OPTIONAL)))
