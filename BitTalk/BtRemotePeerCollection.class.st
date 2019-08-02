"
A BtRemotePeerCollection is xxxxxxxxx.

Instance Variables
	remotePeers:		<Object>

remotePeers
	- xxxxx

"
Class {
	#name : #BtRemotePeerCollection,
	#superclass : #SortedCollection,
	#instVars : [
		'mode'
	],
	#classVars : [
		'CompleteMode',
		'CompleteSortBlock',
		'NotCompleteMode',
		'NotCompleteSortBlock'
	],
	#category : #'BitTalk-P2P'
}

{ #category : #'instance creation' }
BtRemotePeerCollection class >> completeMode [
	^ BtRemotePeerCollection new
		setCompleteMode;
		yourself
]

{ #category : #accessing }
BtRemotePeerCollection class >> completeSortBlock [
	^ CompleteSortBlock
]

{ #category : #'initialize-release' }
BtRemotePeerCollection class >> initialize [
	super initialize.
	CompleteSortBlock := [ :a :b | a downloadRate >= b downloadRate ].
	NotCompleteSortBlock := [ :a :b | a uploadRate >= b uploadRate ].
	CompleteMode := 0.
	NotCompleteMode := 1
]

{ #category : #'instance creation' }
BtRemotePeerCollection class >> new [
	^ super new initialize
]

{ #category : #accessing }
BtRemotePeerCollection class >> notCompleteBlock [
	^ NotCompleteSortBlock
]

{ #category : #'instance creation' }
BtRemotePeerCollection class >> notCompleteMode [
	^ BtRemotePeerCollection new
		setNotCompleteMode;
		yourself
]

{ #category : #accessing }
BtRemotePeerCollection >> at: anInteger put: aRemotePeer [
	aRemotePeer species ~= BtRemotePeer ifTrue:[self error: 'Bad class'].
	^ super at: anInteger put: aRemotePeer
]

{ #category : #enumerating }
BtRemotePeerCollection >> detectLucky [
	^ self detect: [ :peer | peer isLucky ] ifNone: [ nil ]
]

{ #category : #enumerating }
BtRemotePeerCollection >> doCancel: blockRequest [
	self do: [ :peer | peer cancel: blockRequest ]
]

{ #category : #enumerating }
BtRemotePeerCollection >> doHave: index [
	self do: [ :peer| peer sendHave: index ]
]

{ #category : #enumerating }
BtRemotePeerCollection >> doRestartMeasuringRates [
	self do: [ :peer | peer restartMeasuringRates ]
]

{ #category : #enumerating }
BtRemotePeerCollection >> doUpdateInterest: bitfield [
	self do: [ :peer | peer updateInterest: bitfield ]
]

{ #category : #operations }
BtRemotePeerCollection >> ensureAcceptFirst: anInteger [
	self
		doWithIndex: [ :peer :index | 
			index <= anInteger
				ifTrue: [ 
					peer isAccepted
						ifFalse: [ peer accept ] ]
				ifFalse: [ 
					peer isAccepted
						ifTrue: [ peer notAccept ] ] ]
]

{ #category : #operations }
BtRemotePeerCollection >> ensureNotAccept [
	self
		do: [ :peer | 
			peer isAccepted
				ifTrue: [ peer notAccept ] ]
]

{ #category : #'initialize-release' }
BtRemotePeerCollection >> initialize [
	super initialize.
	self setNotCompleteMode.
	mode:= NotCompleteMode
]

{ #category : #printing }
BtRemotePeerCollection >> printOn: aStream [
	self do: [ :each | aStream nextPutAll: each asString ] separatedBy: [ aStream nextPutAll: String cr ] 
]

{ #category : #enumerating }
BtRemotePeerCollection >> rejectAccepted [
	^ self reject: [ :peer | peer isAccepted ]
]

{ #category : #enumerating }
BtRemotePeerCollection >> selectAccepted [
	^ self select: [ :peer| peer isAccepted]
]

{ #category : #enumerating }
BtRemotePeerCollection >> selectAcceptsMe [
	^ self select: [ :peer| peer acceptsMe ]
]

{ #category : #enumerating }
BtRemotePeerCollection >> selectInterested [
	^ self select: [ :peer | peer isInterested ]
]

{ #category : #enumerating }
BtRemotePeerCollection >> selectPieceOwnersOf: pieceIndex [
	^ self select: [ :peer | (peer bitfield at: pieceIndex) = 1 ]
]

{ #category : #enumerating }
BtRemotePeerCollection >> selectSeeders [
	^ self select: [ :peer | peer bitfield isComplete ]
]

{ #category : #enumerating }
BtRemotePeerCollection >> selectWhoIHaveRequested: blockRequest [
	^ self select: [ :peer | peer haveIRequested: blockRequest ]
]

{ #category : #enumerating }
BtRemotePeerCollection >> selectWithUnfulfilledIncomingRequests [
	^ self select: [ :peer | peer unfulfilledIncomingRequests isNotEmpty ]
]

{ #category : #enumerating }
BtRemotePeerCollection >> selectWithUnfulfilledOutgoingRequests [
	^ self select: [ :peer | peer unfulfilledOutgoingRequests isNotEmpty ]
]

{ #category : #operations }
BtRemotePeerCollection >> setCompleteMode [
	mode ~= CompleteMode
		ifTrue: [ 
			self sortBlock: CompleteSortBlock.
			mode := CompleteMode ]
]

{ #category : #operations }
BtRemotePeerCollection >> setNotCompleteMode [
	mode ~= NotCompleteMode
		ifTrue: [ 
			self sortBlock: NotCompleteSortBlock.
			mode := NotCompleteMode ]
]
