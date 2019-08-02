"
A BtNodeTree is xxxxxxxxx.

Instance Variables
	left:		<Object>
	rigth:		<Object>

left
	- xxxxx

rigth
	- xxxxx

"
Class {
	#name : #BtBucketTree,
	#superclass : #SortedCollection,
	#instVars : [
		'left',
		'rigth',
		'firstID',
		'lastID',
		'k',
		'lastChangeTime'
	],
	#classVars : [
		'DefaultFirstID',
		'DefaultK',
		'DefaultLastID'
	],
	#category : #'BitTalk-DHT'
}

{ #category : #accesing }
BtBucketTree class >> defaultK [
	^ DefaultK 
]

{ #category : #'instance creation' }
BtBucketTree class >> firstID: firstID lastID: lastID k: k [
	^ BtBucketTree new
		firstID: firstID;
		lastID: lastID;
		k: k
]

{ #category : #'initialize-release' }
BtBucketTree class >> initialize [
	super initialize.
	DefaultK := 8.
	DefaultFirstID := 0.
	DefaultLastID := (2 raisedTo: 160) - 1
]

{ #category : #'instance creation' }
BtBucketTree class >> new [
	^ super new initialize
]

{ #category : #adding }
BtBucketTree >> add: aNode [
	self checkClass: aNode.
	self checkBeforeAdding: aNode.
	self checkRange: aNode id.
	^ super add: aNode
]

{ #category : #accessing }
BtBucketTree >> bucketForID: aNodeID [
	self checkRange: aNodeID.
	^ (left isNotNil and: [ aNodeID between: left firstID and: left lastID ])
		ifTrue: [ left bucketForID: aNodeID ]
		ifFalse: [ 
			(rigth isNotNil and: [ aNodeID between: rigth firstID and: rigth lastID ])
				ifTrue: [ rigth bucketForID: aNodeID ]
				ifFalse: [ self ] ]
]

{ #category : #private }
BtBucketTree >> checkBeforeAdding: aNode [
	self size = k
		ifTrue: [ BtDHTFullBucket signal ].
	(left isNotNil or: [ rigth isNotNil ])
		ifTrue: [ BtDHTBucketIsNotLeaf signal ].
	self checkUniqueness: aNode.
]

{ #category : #private }
BtBucketTree >> checkClass: aNode [
	aNode species ~= BtDHTRemoteNode
		ifTrue: [ BtDHTBadClass signal ].
]

{ #category : #private }
BtBucketTree >> checkRange: aNodeID [
	(aNodeID between: firstID and: lastID)
		ifFalse: [ BtDHTOutOfRange signal ]
]

{ #category : #private }
BtBucketTree >> checkUniqueness: aNode [
	(self includes: aNode)
		ifTrue: [ BtDHTNodeAlreadyExists signal ]
]

{ #category : #accessing }
BtBucketTree >> firstID [
	^ firstID
]

{ #category : #accessing }
BtBucketTree >> firstID: anObject [
	firstID := anObject
]

{ #category : #'initialize-release' }
BtBucketTree >> initialize [
	super initialize.
	firstID := DefaultFirstID.
	lastID := DefaultLastID.
	left := rigth := nil.
	lastChangeTime := Time millisecondClockValue.
	k := DefaultK.
	self sortBlock: [ :a :b | a lessOrEqualRecentlySeenThan: b ]
]

{ #category : #accessing }
BtBucketTree >> k [
	^ k
]

{ #category : #accessing }
BtBucketTree >> k: anObject [
	k := anObject
]

{ #category : #accessing }
BtBucketTree >> lastID [
	^ lastID
]

{ #category : #accessing }
BtBucketTree >> lastID: anObject [
	lastID := anObject
]

{ #category : #accessing }
BtBucketTree >> left [
	^ left
]

{ #category : #accessing }
BtBucketTree >> left: anObject [
	left := anObject
]

{ #category : #accessing }
BtBucketTree >> pickNode: aNodeID [
	^ (self bucketForID: aNodeID) detect: [ :node | node id = aNodeID ] ifNone: [ nil ]
]

{ #category : #operations }
BtBucketTree >> pickRandomID [
	^ (firstID to: lastID) atRandom
]

{ #category : #accessing }
BtBucketTree >> rigth [
	^ rigth
]

{ #category : #accessing }
BtBucketTree >> rigth: anObject [
	^ rigth := anObject
]

{ #category : #enumerating }
BtBucketTree >> selectGood [
	^ self select: [ :node | node isGood ]
]

{ #category : #enumerating }
BtBucketTree >> selectQuestionable [
	^ self select: [ :node | node isQuestionable ]
]

{ #category : #operations }
BtBucketTree >> split [
	| middle |
	self size < k
		ifTrue: [ BtDHTNotFullBucket signal ].
	middle := (firstID + lastID) quo: 2.
	(middle - firstID + 1 < k or: [ lastID - middle < k ])
		ifTrue: [ BtDHTIDSpaceTooSmall signal ].
	left := BtBucketTree firstID: firstID lastID: middle k: k.
	rigth := BtBucketTree firstID: middle + 1 lastID: lastID k: k.
	[ self isEmpty ]
		whileFalse: [ 
			| node |
			((node := self removeLast) within: left)
				ifTrue: [ left add: node ]
				ifFalse: [ rigth add: node ] ]
]

{ #category : #operations }
BtBucketTree >> updateLastChangeTime [
	lastChangeTime := Time millisecondClockValue
]
