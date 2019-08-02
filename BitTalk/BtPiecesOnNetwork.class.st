"
A BtPieceCounterCollection is xxxxxxxxx.

"
Class {
	#name : #BtPiecesOnNetwork,
	#superclass : #Object,
	#instVars : [
		'mode',
		'collection'
	],
	#classVars : [
		'IndexMode',
		'RarityMode'
	],
	#category : #BitTalk
}

{ #category : #'instance creation' }
BtPiecesOnNetwork class >> indexMode: numPieces [
	^ (BtPiecesOnNetwork new: numPieces) setIndexMode ; yourself
]

{ #category : #'initialize-release' }
BtPiecesOnNetwork class >> initialize [
	super initialize.
	RarityMode := 'RarityMode'.
	IndexMode := 'IndexMode'.
]

{ #category : #'instance creation' }
BtPiecesOnNetwork class >> new: numPieces [
	^ BtPiecesOnNetwork new
		numPieces: numPieces;
		yourself
]

{ #category : #'instance creation' }
BtPiecesOnNetwork class >> rarityMode: numPieces [
	^ (BtPiecesOnNetwork new: numPieces) setRarityMode ; yourself
]

{ #category : #testing }
BtPiecesOnNetwork >> hasIndexMode [
	^ mode = IndexMode
]

{ #category : #testing }
BtPiecesOnNetwork >> hasRarityMode [
	^ mode = RarityMode
]

{ #category : #'initialize-release' }
BtPiecesOnNetwork >> initialize [
	super initialize.
	collection := SortedCollection new.
	self setRarityMode .
]

{ #category : #operations }
BtPiecesOnNetwork >> modifyAt: index by: amount [
	"Positive amount to increment. Negative amount to decrement."

	| pieceCounter |
	pieceCounter := collection remove: (BtPieceCounter index: index count: 0) ifAbsent: [ nil ].
	pieceCounter
		ifNotNil: [ 
			pieceCounter modifyCountBy: amount.
			collection add: pieceCounter ]
]

{ #category : #'initialize-release' }
BtPiecesOnNetwork >> numPieces: numPieces [
	collection removeAll.
	0 to: numPieces - 1 do: [ :index | collection addLast: (BtPieceCounter index: index count: 0) ]
]

{ #category : #printing }
BtPiecesOnNetwork >> printOn: aStream [
	aStream
		nextPutAll: 'index->count';
		nextPutAll: String cr.
	collection do: [ :each | aStream nextPutAll: each asString ] separatedBy: [ aStream nextPutAll: String cr ]
]

{ #category : #enumerating }
BtPiecesOnNetwork >> selectAll [
	^ (collection collect: [ :pieceCounter | pieceCounter index ]) asOrderedCollection
]

{ #category : #enumerating }
BtPiecesOnNetwork >> selectExistingPieces [
	^ (collection select: [ :pieceCounter | pieceCounter count > 0 ] thenCollect: [ :pieceCounter | pieceCounter index ])
		asOrderedCollection
]

{ #category : #enumerating }
BtPiecesOnNetwork >> selectMissingPieces [
	^ (collection select: [ :pieceCounter | pieceCounter count <= 0 ] thenCollect: [ :pieceCounter | pieceCounter index ])
		asOrderedCollection
]

{ #category : #sorting }
BtPiecesOnNetwork >> setIndexMode [
	collection sortBlock: [ :a :b | a lowerOrEqualThan: b ].
	mode := IndexMode
]

{ #category : #sorting }
BtPiecesOnNetwork >> setRarityMode [
	collection sortBlock: [ :a :b | a rarestOrEqualThan: b ].
	mode := RarityMode
]
